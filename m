From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [V2 PATCH net-next 1/2] xdp: implement xdp_redirect_map for generic
 XDP
Date: Fri, 08 Sep 2017 12:41:05 +0200
Message-ID: <59B273C1.9060806@iogearbox.net>
References: <150478756604.28665.6915020425359475729.stgit@firesoul>     <150478759310.28665.17184783248584070473.stgit@firesoul>        <59B15334.4070103@iogearbox.net> <20170908103601.21cdecb2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        alexei.starovoitov@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52071 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753132AbdIHKlI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 06:41:08 -0400
In-Reply-To: <20170908103601.21cdecb2@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2017 10:36 AM, Jesper Dangaard Brouer wrote:
> On Thu, 07 Sep 2017 16:09:56 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 09/07/2017 02:33 PM, Jesper Dangaard Brouer wrote:
>>> Using bpf_redirect_map is allowed for generic XDP programs, but the
>>> appropriate map lookup was never performed in xdp_do_generic_redirect().
>>>
>>> Instead the map-index is directly used as the ifindex.  For the
>>> xdp_redirect_map sample in SKB-mode '-S', this resulted in trying
>>> sending on ifindex 0 which isn't valid, resulting in getting SKB
>>> packets dropped.  Thus, the reported performance numbers are wrong in
>>> commit 24251c264798 ("samples/bpf: add option for native and skb mode
>>> for redirect apps") for the 'xdp_redirect_map -S' case.
>>>
>>> It might seem innocent this was lacking, but it can actually crash the
>>> kernel.  The potential crash is caused by not consuming redirect_info->map.
>>> The bpf_redirect_map helper will set this_cpu_ptr(&redirect_info)->map
>>> pointer, which will survive even after unloading the xdp bpf_prog and
>>> deallocating the devmap data-structure.  This leaves a dead map
>>> pointer around.  The kernel will crash when loading the xdp_redirect
>>> sample (in native XDP mode) as it doesn't reset map (via bpf_redirect)
>>> and returns XDP_REDIRECT, which will cause it to dereference the map
>>> pointer.
>>>
>>> Fixes: 6103aa96ec07 ("net: implement XDP_REDIRECT for xdp generic")
>>> Fixes: 24251c264798 ("samples/bpf: add option for native and skb mode for redirect apps")
>>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>>> ---
>>>    include/trace/events/xdp.h |    4 ++--
>>>    net/core/filter.c          |   14 +++++++++++---
>>>    2 files changed, 13 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
>>> index 862575ac8da9..4e16c43fba10 100644
>>> --- a/include/trace/events/xdp.h
>>> +++ b/include/trace/events/xdp.h
>>> @@ -138,11 +138,11 @@ DEFINE_EVENT_PRINT(xdp_redirect_template, xdp_redirect_map_err,
>>>
>>>    #define _trace_xdp_redirect_map(dev, xdp, fwd, map, idx)		\
>>>    	 trace_xdp_redirect_map(dev, xdp, fwd ? fwd->ifindex : 0,	\
>>> -				0, map, idx);
>>> +				0, map, idx)
>>>
>>>    #define _trace_xdp_redirect_map_err(dev, xdp, fwd, map, idx, err)	\
>>>    	 trace_xdp_redirect_map_err(dev, xdp, fwd ? fwd->ifindex : 0,	\
>>> -				    err, map, idx);
>>> +				    err, map, idx)
>>>
>>>    #endif /* _TRACE_XDP_H */
>>>
>>> diff --git a/net/core/filter.c b/net/core/filter.c
>>> index 5912c738a7b2..3767470cab6c 100644
>>> --- a/net/core/filter.c
>>> +++ b/net/core/filter.c
>>> @@ -2566,13 +2566,19 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
>>>    			    struct bpf_prog *xdp_prog)
>>>    {
>>>    	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
>>> +	struct bpf_map *map = ri->map;
>>>    	u32 index = ri->ifindex;
>>>    	struct net_device *fwd;
>>>    	unsigned int len;
>>>    	int err = 0;
>>>
>>> -	fwd = dev_get_by_index_rcu(dev_net(dev), index);
>>>    	ri->ifindex = 0;
>>> +	ri->map = NULL;
>>> +
>>> +	if (map)
>>> +		fwd = __dev_map_lookup_elem(map, index);
>>> +	else
>>> +		fwd = dev_get_by_index_rcu(dev_net(dev), index);
>>>    	if (unlikely(!fwd)) {
>>>    		err = -EINVAL;
>>>    		goto err;
>>> @@ -2590,10 +2596,12 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
>>>    	}
>>>
>>>    	skb->dev = fwd;
>>
>> Looks much better above, thanks!
>>
>>> -	_trace_xdp_redirect(dev, xdp_prog, index);
>>> +	map ? _trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index)
>>> +		: _trace_xdp_redirect(dev, xdp_prog, index);
>>
>> Could we rather make this in a way such that when the two
>> tracepoints are disabled and thus patched out, that we can
>> also omit the extra conditional which has no purpose then?
>
> First of all I don't think it make much of a difference, I measured the
> impact of the full patch to "cost" 1.62 nanosec (which is arguably
> below the accuracy level of the system under test)
>
> Secondly, I plan to optimize the map case for generic XDP later, where
> I would naturally split this into two functions (as V1, and as
> native-XDP), thus this extra conditional would go away.  As I've shown
> offlist (to you, John and Andy) I demonstrated a 24% speedup via a
> xmit_more hack for generic XDP.

Okay, that would be nice indeed to have xmit_more support for
generic XDP as well. If this is going to be split off anyway
later on as in xdp_do_redirect() case, then:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
