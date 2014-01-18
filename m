From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] net: core: orphan frags before queuing to slow qdisc
Date: Sat, 18 Jan 2014 13:35:50 +0800
Message-ID: <52DA12B6.7090102@redhat.com>
References: <1389951734-13234-1-git-send-email-jasowang@redhat.com> <1389968897.31367.489.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57843 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751602AbaARFfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jan 2014 00:35:55 -0500
In-Reply-To: <1389968897.31367.489.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2014 10:28 PM, Eric Dumazet wrote:
> On Fri, 2014-01-17 at 17:42 +0800, Jason Wang wrote:
>> Many qdiscs can queue a packet for a long time, this will lead an issue
>> with zerocopy skb. It means the frags will not be orphaned in an expected
>> short time, this breaks the assumption that virtio-net will transmit the
>> packet in time.
>>
>> So if guest packets were queued through such kind of qdisc and hit the
>> limitation of the max pending packets for virtio/vhost. All packets that
>> go to another destination from guest will also be blocked.
>>
>> A case for reproducing the issue:
>>
>> - Boot two VMs and connect them to the same bridge kvmbr.
>> - Setup tbf with a very low rate/burst on eth0 which is a port of kvmbr.
>> - Let VM1 send lots of packets thorugh eth0
>> - After a while, VM1 is unable to send any packets out since the number of
>>    pending packets (queued to tbf) were exceeds the limitation of vhost/virito
> So whats the problem ? If the limit is low, you cannot sent packets.

It was just an extreme case. The problem is if zercopy packets of vm1 
were throttled by qdisc in eth0, probably all packets from vm1 were 
throttled even if it was not go through eth0.
> Solution : increase the limit, or tell the vm to lower its rate.
>
> Oh wait, are you bitten because you did some prior skb_orphan() to allow
> the vm to send unlimited number of skbs ???
>

The problem is sndbuf were defaulted to INT_MAX to prevent a similar 
issue for non-zerocopy packets. For zerocopy, only after the frags were 
orphaned can vhost notify the completion of tx for virtio-net. So 
INT_MAX sndbuf is not enough.
>> Solve this issue by orphaning the frags before queuing it to a slow qdisc (the
>> one without TCQ_F_CAN_BYPASS).
> Why orphaning the frags only solves the problem ? A skb without zerocopy
> frags should also be blocked for a while.

It's ok for non-zerocopy packet to be blocked since VM1 thought the 
packets has been sent instead of pending in the virtqueue. So VM1 can 
still send packet to other destination.
> Seriously, lets admit this zero copy stuff is utterly broken.
>
>
> TCQ_F_CAN_BYPASS is not enough. Some NIC have separate queues with
> strict priorities.
>

Yes, but looks less serious than traffic shaping.
> It seems to me that you are pushing to use FIFO (the only qdisc setting
> TCQ_F_CAN_BYPASS), by adding yet another test in fast path (I do not
> know how we can still call it a fast path), while we already have smart
> qdisc to avoid the inherent HOL and unfairness problems of FIFO.
>

It was just a workaround like the case of sndbuf before we had a better 
solution. So looks like using sfq or fq in guest can mitigate the issue?
>> Cc: Michael S. Tsirkin<mst@redhat.com>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>> ---
>>   net/core/dev.c | 7 +++++++
>>   1 file changed, 7 insertions(+)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 0ce469e..1209774 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2700,6 +2700,12 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>>   	contended = qdisc_is_running(q);
>>   	if (unlikely(contended))
>>   		spin_lock(&q->busylock);
>> +	if (!(q->flags&  TCQ_F_CAN_BYPASS)&&
>> +	    unlikely(skb_orphan_frags(skb, GFP_ATOMIC))) {
>> +		kfree_skb(skb);
>> +		rc = NET_XMIT_DROP;
>> +		goto out;
>> +	}
> Are you aware that copying stuff takes time ?
>
> If yes, why is it done after taking the busylock spinlock ?
>

Yes and it should be done outside the spinlock.
>>
>>   	spin_lock(root_lock);
>>   	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED,&q->state))) {
>> @@ -2739,6 +2745,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>>   		}
>>   	}
>>   	spin_unlock(root_lock);
>> +out:
>>   	if (unlikely(contended))
>>   		spin_unlock(&q->busylock);
>>   	return rc;
>
>
