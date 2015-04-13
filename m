From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH RFC] tcp: Allow sk_wmem_alloc to exceed sysctl_tcp_limit_output_bytes
Date: Mon, 13 Apr 2015 14:46:01 +0100
Message-ID: <552BC899.8090300@citrix.com>
References: <1427388414-31077-1-git-send-email-jonathan.davies@citrix.com>
	<1427390070.25985.145.camel@edumazet-glaptop2.roam.corp.google.com>
 <551555E3.80205@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	<netdev@vger.kernel.org>, James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Patrick McHardy <kaber@trash.net>
To: Jonathan Davies <jonathan.davies@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25858 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075AbbDMNqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 09:46:08 -0400
In-Reply-To: <551555E3.80205@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/03/15 13:06, Jonathan Davies wrote:
> On 26/03/15 17:14, Eric Dumazet wrote:
>> On Thu, 2015-03-26 at 16:46 +0000, Jonathan Davies wrote:
>>> Network drivers with slow TX completion can experience poor network
>>> transmit
>>> throughput, limited by hitting the sk_wmem_alloc limit check in
>>> tcp_write_xmit.
>>> The limit is 128 KB (by default), which means we are limited to two
>>> 64 KB skbs
>>> in-flight. This has been observed to limit transmit throughput with
>>> xen-netfront
>>> because its TX completion can be relatively slow compared to physical
>>> NIC
>>> drivers.
>>>
>>> There have been several modifications to the calculation of the
>>> sk_wmem_alloc
>>> limit in the past. Here is a brief history:
>>>
>>>   * Since TSQ was introduced, the queue size limit was
>>>         sysctl_tcp_limit_output_bytes.
>>>
>>>   * Commit c9eeec26 ("tcp: TSQ can use a dynamic limit") made the limit
>>>         max(skb->truesize, sk->sk_pacing_rate >> 10).
>>>     This allows more packets in-flight according to the estimated rate.
>>>
>>>   * Commit 98e09386 ("tcp: tsq: restore minimal amount of queueing")
>>> made the
>>>     limit
>>>         max_t(unsigned int, sysctl_tcp_limit_output_bytes,
>>>                             sk->sk_pacing_rate >> 10).
>>>     This ensures at least sysctl_tcp_limit_output_bytes in flight but
>>> allowed
>>>     more if rate estimation shows this to be worthwhile.
>>>
>>>   * Commit 605ad7f1 ("tcp: refine TSO autosizing") made the limit
>>>         min_t(u32, max(2 * skb->truesize, sk->sk_pacing_rate >> 10),
>>>                    sysctl_tcp_limit_output_bytes).
>>>     This meant that the limit can never exceed
>>> sysctl_tcp_limit_output_bytes,
>>>     regardless of what rate estimation suggests. It's not clear from
>>> the commit
>>>     message why this significant change was justified, changing
>>>     sysctl_tcp_limit_output_bytes from being a lower bound to an
>>> upper bound.
>>>
>>> This patch restores the behaviour that allows the limit to grow above
>>> sysctl_tcp_limit_output_bytes according to the rate estimation.
>>>
>>> This has been measured to improve xen-netfront throughput from a domU
>>> to dom0
>>> from 5.5 Gb/s to 8.0 Gb/s. Or, in the case of transmitting from one
>>> domU to
>>> another (on the same host), throughput rose from 2.8 Gb/s to 8.0
>>> Gb/s. In the
>>> latter case, TX completion is especially slow, explaining the large
>>> improvement.
>>> These values were measured against 4.0-rc5 using "iperf -c <ip> -i 1"
>>> using
>>> CentOS 7.0 VM(s) on Citrix XenServer 6.5 on a Dell R730 host with a
>>> pair of Xeon
>>> E5-2650 v3 CPUs.
>>>
>>> Fixes: 605ad7f184b6 ("tcp: refine TSO autosizing")
>>> Signed-off-by: Jonathan Davies <jonathan.davies@citrix.com>
>>> ---
>>>   net/ipv4/tcp_output.c | 2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>>> index 1db253e..3a49af8 100644
>>> --- a/net/ipv4/tcp_output.c
>>> +++ b/net/ipv4/tcp_output.c
>>> @@ -2052,7 +2052,7 @@ static bool tcp_write_xmit(struct sock *sk,
>>> unsigned int mss_now, int nonagle,
>>>            * One example is wifi aggregation (802.11 AMPDU)
>>>            */
>>>           limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
>>> -        limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
>>> +        limit = max_t(u32, limit, sysctl_tcp_limit_output_bytes);
>>>
>>>           if (atomic_read(&sk->sk_wmem_alloc) > limit) {
>>>               set_bit(TSQ_THROTTLED, &tp->tsq_flags);
>>
>>
>> That will get a NACK from me and Google TCP team of course.
>>
>> Try your patch with low throughput flows, like 64kbps, GSO off...
>>
>> And observe TCP timestamps and rtt estimations, critical for vegas or
>> any CC based on delay.
>>
>> I get line rate on 40Gbps NIC using this (low) limit of 2 TSO packets.
>>
>> This topic was discussed for wifi recently, and I suggested multiple
>> ways to solve the problem on problematic drivers.
>>
>> There is a reason sysctl_tcp_limit_output_bytes exists : You can change
>> its value to whatever you want.
>>
>> vi +652 Documentation/networking/ip-sysctl.txt
>>
>> tcp_limit_output_bytes - INTEGER
>>          Controls TCP Small Queue limit per tcp socket.
>>          TCP bulk sender tends to increase packets in flight until it
>>          gets losses notifications. With SNDBUF autotuning, this can
>>          result in a large amount of packets queued in qdisc/device
>>          on the local machine, hurting latency of other flows, for
>>          typical pfifo_fast qdiscs.
>>          tcp_limit_output_bytes limits the number of bytes on qdisc
>>          or device to reduce artificial RTT/cwnd and reduce bufferbloat.
>>          Default: 131072
>>
>> Documentation is pretty clear : This is the max value, not a min one.
> 
> Okay, thanks for your feedback. It wasn't clear to me from the commit
> message in 605ad7f1 ("tcp: refine TSO autosizing") why
> tcp_limit_output_bytes changed from being a lower bound to an upper
> bound in that patch. But it's now clear from your reply that that's the
> behaviour you intend as correct.
> 
> Thanks for drawing my attention to the wifi thread, which is helpful. As
> I understand it, the only available options for fixing the performance
> regression experienced by xen-netfront are:
>   1. Reduce TX completion latency, or
>   2. Bypass TSQ to allow buffering of more than tcp_limit_output_bytes,
> finding a way to work around that limit in the driver, e.g.
>        (a) pretending the sent packets are smaller than in reality, so
> sk_wmem_alloc doesn't grow as fast;
>        (b) using skb_orphan in xennet_start_xmit to allow the skb to be
> freed without waiting for TX completion.
> 
> Do you agree, or have I missed something?
> 
> Option 1 seems to me like the right long-term goal, but this would
> require substantial changes to xen-netback and probably can't be
> addressed in the near-term to fix this performance regression.
> 
> Option 2 risks the problems associated with bufferbloat but may be the
> only way to sustain high throughput. I have briefly tried out ideas (a)
> and (b); both look like they can give almost the same throughput as the
> patch above (around 7 Gb/s domU-to-domU) without the need to modify
> tcp_write_xmit. (I don't know much about the implications of using
> skb_orphan in ndo_start_xmit, so am not sure whether that may cause
> other problems.)
> 
> I would like to seek the opinion of the xen-netfront maintainers (cc'd).
> You have a significant performance regression since commit 605ad7f1
> ("tcp: refine TSO autosizing"). Are either of options (a) or (b) viable
> to fix it? Or is there a better solution?
> 
> For your reference, the proof-of-concept patch for idea (a) I used was:
> 
> @@ -630,6 +630,16 @@ static int xennet_start_xmit(struct sk_buff *skb,
> struct net_device *dev)
> 
>      spin_unlock_irqrestore(&queue->tx_lock, flags);
> 
> +    /* Pretend we sent less than we did, so we can squeeze more out
> +         * of the available tcp_limit_output_bytes.
> +         */
> +    if (skb->sk) {
> +        u32 fraction = (7 * skb->truesize) / 8;
> +
> +        skb->truesize -= fraction;
> +        atomic_sub(fraction, &skb->sk->sk_wmem_alloc);
> +    }

Playing games like this with skb->truesize looks dodgy to me.

> And the proof-of-concept patch for idea (b) I used was:
> 
> @@ -552,6 +552,8 @@ static int xennet_start_xmit(struct sk_buff *skb,
> struct net_device *dev)
>              goto drop;
>      }
> 
> +    skb_orphan(skb);
> +
>      page = virt_to_page(skb->data);
>      offset = offset_in_page(skb->data);
>      len = skb_headlen(skb);

No. This a bunch of allocations and  a full memcpy of all the frags.

David
