From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [PATCH] ipv4: fix ipsec forward performance regression
Date: Mon, 24 Oct 2011 08:41:53 +0800
Message-ID: <4EA4B451.7010708@intel.com>
References: <4EA3C91C.3090801@intel.com> <alpine.LFD.2.00.1110231533410.1499@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Kim Phillips <kim.phillips@freescale.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22950 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533Ab1JXAlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Oct 2011 20:41:55 -0400
In-Reply-To: <alpine.LFD.2.00.1110231533410.1499@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2011 10:52 PM, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 23 Oct 2011, Yan, Zheng wrote:
> 
>> There is bug in commit 5e2b61f(ipv4: Remove flowi from struct rtable).
>> It makes xfrm4_fill_dst() modify wrong data structure.
>>
>> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
>> ---
>>  net/ipv4/xfrm4_policy.c |   14 +++++++-------
>>  1 files changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
>> index fc5368a..a0b4c5d 100644
>> --- a/net/ipv4/xfrm4_policy.c
>> +++ b/net/ipv4/xfrm4_policy.c
>> @@ -79,13 +79,13 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
>>  	struct rtable *rt = (struct rtable *)xdst->route;
>>  	const struct flowi4 *fl4 = &fl->u.ip4;
>>  
>> -	rt->rt_key_dst = fl4->daddr;
>> -	rt->rt_key_src = fl4->saddr;
>> -	rt->rt_key_tos = fl4->flowi4_tos;
>> -	rt->rt_route_iif = fl4->flowi4_iif;
>> -	rt->rt_iif = fl4->flowi4_iif;
>> -	rt->rt_oif = fl4->flowi4_oif;
>> -	rt->rt_mark = fl4->flowi4_mark;
>> +	xdst->u.rt.rt_key_dst = fl4->daddr;
>> +	xdst->u.rt.rt_key_src = fl4->saddr;
>> +	xdst->u.rt.rt_key_tos = fl4->flowi4_tos;
>> +	xdst->u.rt.rt_route_iif = fl4->flowi4_iif;
> 
> 	May be I'm missing something but I don't see where
> flowi4_iif is set for the forwarding case. __xfrm_route_forward
> calls xfrm_decode_session which does not appear to set
> flowi4_iif. When providing fl4 for output routes flowi4_iif
> is always set to 0, so it represents rt_route_iif. But
> then there are 2 variants for __ip_route_output_key:
> 
> - ip_route_output_slow sets flowi4_iif to loopback and
> flowi4_oif to outdev during lookup but never restores them
> to original values. It is assumed that caller uses outdev
> from dst, not from flowi4_oif.
> 
> - for cached route we do not update flowi4_iif and flowi4_oif
> in __ip_route_output_key, so the resulting fl4 can not be
> used for these values. I assume, the current rules are that
> only fl4.saddr and daddr are updated while flowi4_iif and
> flowi4_oif are not. It looks wrong flowi code to rely on them.
> 
> 	Currently, we have 3 values for devices:
> 
> rt_iif: indev for input routes, resulting outdev for output routes
> which plays the role as indev for loopback traffic.
> 
> rt_oif: original outdev key, 0 for input routes, can be 0 for
> output routes if socket is not bound to oif
> 
> rt_route_iif: indev for input routes, 0 for output routes
> 
> 	With above rules for flowi4_iif and flowi4_oif
> it is impossible to select value for rt_iif from fl4.
> 
> 	I don't know the xfrm code well, may be after the

Neither do I. My understanding is that xfrm_dst(s) are managed by the
flow cache (net/core/flow.c). We don't put them into the routing cache.

Regards
Yan, Zheng 

> mentioned change we damaged rt_oif and rt_route_iif values
> for cached dst which can lead to using slow path all the time.
> Even if rt_intern_hash() avoids caching similar dsts multiple
> times, if cached entry is damaged we will add more and
> more new entries after every damage.
> 
>> +	xdst->u.rt.rt_iif = fl4->flowi4_iif;
>> +	xdst->u.rt.rt_oif = fl4->flowi4_oif;
>> +	xdst->u.rt.rt_mark = fl4->flowi4_mark;
>>  
>>  	xdst->u.dst.dev = dev;
>>  	dev_hold(dev);
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
