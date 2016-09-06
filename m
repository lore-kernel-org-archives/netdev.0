From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 5/6] net: core: run cgroup eBPF egress programs
Date: Tue, 06 Sep 2016 19:14:31 +0200
Message-ID: <57CEF977.5030003@iogearbox.net>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org> <1472241532-11682-6-git-send-email-daniel@zonque.org> <57C4B12B.2070302@iogearbox.net> <634bb3e7-ea27-bf4d-5597-0cb9d4379466@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Mack <daniel@zonque.org>, htejun@fb.com, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32820 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936286AbcIFROu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 13:14:50 -0400
In-Reply-To: <634bb3e7-ea27-bf4d-5597-0cb9d4379466@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2016 04:22 PM, Daniel Mack wrote:
> On 08/30/2016 12:03 AM, Daniel Borkmann wrote:
>> On 08/26/2016 09:58 PM, Daniel Mack wrote:
>
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index a75df86..17484e6 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -141,6 +141,7 @@
>>>    #include <linux/netfilter_ingress.h>
>>>    #include <linux/sctp.h>
>>>    #include <linux/crash_dump.h>
>>> +#include <linux/bpf-cgroup.h>
>>>
>>>    #include "net-sysfs.h"
>>>
>>> @@ -3329,6 +3330,11 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
>>>    	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_SCHED_TSTAMP))
>>>    		__skb_tstamp_tx(skb, NULL, skb->sk, SCM_TSTAMP_SCHED);
>>>
>>> +	rc = cgroup_bpf_run_filter(skb->sk, skb,
>>> +				   BPF_ATTACH_TYPE_CGROUP_INET_EGRESS);
>>> +	if (rc)
>>> +		return rc;
>>
>> This would leak the whole skb by the way.
>
> Ah, right.
>
>> Apart from that, could this be modeled w/o affecting the forwarding path (at some
>> local output point where we know to have a valid socket)? Then you could also drop
>> the !sk and sk->sk_family tests, and we wouldn't need to replicate parts of what
>> clsact is doing as well. Hmm, maybe access to src/dst mac could be handled to be
>> just zeroes since not available at that point?
>
> Hmm, I wonder where this hook could be put instead then. When placed in
> ip_output() and ip6_output(), the mac headers cannot be pushed before
> running the program, resulting in bogus skb data from the eBPF program.

But as it stands right now, RX will only see a subset of packets in sk_filter()
layer (depending on where it's called in the proto handler implementation,
so might not even include all control messages, for example) as opposed to
the TX hook going that far even 'seeing' everything incl. forwarded packets
in the sense that we know a priori that these kind of skbs going through the
cgroup_bpf_run_filter() handler when the hook is enabled will just skip this
hook eventually anyway. What about letting such progs see /only/ local skbs
for RX and TX, with skb->data from L3 onwards (iirc, that would be similar
to what current sk_filter() programs see)?
