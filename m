From: tndave <tushar.n.dave@oracle.com>
Subject: Re: [PATCH] netpoll: Check for skb->queue_mapping
Date: Thu, 6 Apr 2017 12:07:17 -0700
Message-ID: <5927b630-865e-b7af-33a1-1a6b772e3fb7@oracle.com>
References: <1491444383-29017-1-git-send-email-tushar.n.dave@oracle.com>
 <1491474377.10124.57.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, brouer@redhat.com,
        netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24058 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbdDFTIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:08:38 -0400
In-Reply-To: <1491474377.10124.57.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/06/2017 03:26 AM, Eric Dumazet wrote:
> On Wed, 2017-04-05 at 19:06 -0700, Tushar Dave wrote:
>> Reducing real_num_tx_queues needs to be in sync with skb queue_mapping
>> otherwise skbs with queue_mapping greater than real_num_tx_queues
>> can be sent to the underlying driver and can result in kernel panic.
>>
>> One such event is running netconsole and enabling VF on the same
>> device. Or running netconsole and changing number of tx queues via
>> ethtool on same device.
>>
>> e.g.
>
>>
>> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
>> ---
>>  net/core/netpoll.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>> index 9424673..c572e49 100644
>> --- a/net/core/netpoll.c
>> +++ b/net/core/netpoll.c
>> @@ -101,6 +101,7 @@ static void queue_process(struct work_struct *work)
>>  		container_of(work, struct netpoll_info, tx_work.work);
>>  	struct sk_buff *skb;
>>  	unsigned long flags;
>> +	u16 q_index;
>>
>>  	while ((skb = skb_dequeue(&npinfo->txq))) {
>>  		struct net_device *dev = skb->dev;
>> @@ -117,6 +118,12 @@ static void queue_process(struct work_struct *work)
>>  		HARD_TX_LOCK(dev, txq, smp_processor_id());
>>  		if (netif_xmit_frozen_or_stopped(txq) ||
>>  		    netpoll_start_xmit(skb, dev, txq) != NETDEV_TX_OK) {
>> +			/* check if skb->queue_mapping has changed */
>> +			q_index = skb_get_queue_mapping(skb);
>> +			if (unlikely(q_index >= dev->real_num_tx_queues)) {
>> +				q_index = q_index % dev->real_num_tx_queues;
>> +				skb_set_queue_mapping(skb, q_index);
>> +			}
>>  			skb_queue_head(&npinfo->txq, skb);
>>  			HARD_TX_UNLOCK(dev, txq);
>>  			local_irq_restore(flags);
>
> Hi Tushar, thank you for working on this issue.
Eric,

Thank you for reviewing my change and your valuable comments.
>
> Where and when skb->queue_mapping has changed ?
Well, I should amend the comment,
"/* check if skb->queue_mapping has changed */" is misleading.
I should say, /* check if dev->real_num_tx_queues has changed */
>
> It looks that the real problem is that dev->real_num_tx_queues has been
> changed instead of skb->queue_mapping
Yes.
>
> So maybe the more correct change would be to cap skb->queue_mapping even
> before getting skb_get_tx_queue() ?
>
> Otherwise, even after your patch, we might still access an invalid queue
> on the device ?
This is the case of direct xmit (netdev_start_xmit). Most of underlying
mq device drivers retrieve tx queue index from skb->queue_mapping.
One possibility I see where device driver still get invalid queue index
(skb->queue_mapping) with my patch is when following occurs:
- after executing "txq = skb_get_tx_queue(dev, skb)" cpu is interrupted';
- some other cpu reduced dev->real_num_tx_queues;
- Interrupted cpu resume (queue_process()).
With above sequence, at the underlying driver's xmit function we can
have skb->queue_mapping > dev->real_num_tx_queues [1].

I like your suggested patch more than mine though because it checks for
change in dev->real_num_tx_queues before even we retrieve 'netdev_queue
txq'. Less chance to have wrong txq.

However even your patch has same issue like [1] ? (see my comment below).

>
> Something like the following :
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 9424673009c14e0fb288b8e4041dba596b37ee8d..16702d95f83ab884e605e3868cfef94615dcbc72 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -105,13 +105,20 @@ static void queue_process(struct work_struct *work)
>  	while ((skb = skb_dequeue(&npinfo->txq))) {
>  		struct net_device *dev = skb->dev;
>  		struct netdev_queue *txq;
> +		unsigned int q_index;
>
>  		if (!netif_device_present(dev) || !netif_running(dev)) {
>  			kfree_skb(skb);
>  			continue;
>  		}
>
> -		txq = skb_get_tx_queue(dev, skb);
> +		/* check if skb->queue_mapping is still valid */
> +		q_index = skb_get_queue_mapping(skb);
> +		if (unlikely(q_index >= dev->real_num_tx_queues)) {
> +			q_index = q_index % dev->real_num_tx_queues;
cpu interrupted here and dev->real_num_tx_queues has reduced!
> +			skb_set_queue_mapping(skb, q_index);
> +		}
> +		txq = netdev_get_tx_queue(dev, q_index);
or cpu interrupted here and dev->real_num_tx_queues has reduced!

In any case we hit the bug or am I missing something?

The other concern is concurrent execution of netpoll's direct xmit path
and updates to dev->real_num_tx_queues (by other cpu)?


Thanks.

-Tushar
>
>  		local_irq_save(flags);
>  		HARD_TX_LOCK(dev, txq, smp_processor_id());
>
>
>
>
