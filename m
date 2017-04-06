From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netpoll: Check for skb->queue_mapping
Date: Thu, 06 Apr 2017 03:26:17 -0700
Message-ID: <1491474377.10124.57.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1491444383-29017-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, brouer@redhat.com,
        netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: Tushar Dave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34703 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757337AbdDFK0U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 06:26:20 -0400
Received: by mail-it0-f65.google.com with SMTP id 193so363818itm.1
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 03:26:20 -0700 (PDT)
In-Reply-To: <1491444383-29017-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-05 at 19:06 -0700, Tushar Dave wrote:
> Reducing real_num_tx_queues needs to be in sync with skb queue_mapping
> otherwise skbs with queue_mapping greater than real_num_tx_queues
> can be sent to the underlying driver and can result in kernel panic.
> 
> One such event is running netconsole and enabling VF on the same
> device. Or running netconsole and changing number of tx queues via
> ethtool on same device.
> 
> e.g.

> 
> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
> ---
>  net/core/netpoll.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 9424673..c572e49 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -101,6 +101,7 @@ static void queue_process(struct work_struct *work)
>  		container_of(work, struct netpoll_info, tx_work.work);
>  	struct sk_buff *skb;
>  	unsigned long flags;
> +	u16 q_index;
>  
>  	while ((skb = skb_dequeue(&npinfo->txq))) {
>  		struct net_device *dev = skb->dev;
> @@ -117,6 +118,12 @@ static void queue_process(struct work_struct *work)
>  		HARD_TX_LOCK(dev, txq, smp_processor_id());
>  		if (netif_xmit_frozen_or_stopped(txq) ||
>  		    netpoll_start_xmit(skb, dev, txq) != NETDEV_TX_OK) {
> +			/* check if skb->queue_mapping has changed */
> +			q_index = skb_get_queue_mapping(skb);
> +			if (unlikely(q_index >= dev->real_num_tx_queues)) {
> +				q_index = q_index % dev->real_num_tx_queues;
> +				skb_set_queue_mapping(skb, q_index);
> +			}
>  			skb_queue_head(&npinfo->txq, skb);
>  			HARD_TX_UNLOCK(dev, txq);
>  			local_irq_restore(flags);

Hi Thushar, thank you for working on this issue.

Where and when skb->queue_mapping has changed ?

It looks that the real problem is that dev->real_num_tx_queues has been
changed instead of skb->queue_mapping

So maybe the more correct change would be to cap skb->queue_mapping even
before getting skb_get_tx_queue() ?

Otherwise, even after your patch, we might still access an invalid queue
on the device ?

Something like the following :

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 9424673009c14e0fb288b8e4041dba596b37ee8d..16702d95f83ab884e605e3868cfef94615dcbc72 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -105,13 +105,20 @@ static void queue_process(struct work_struct *work)
 	while ((skb = skb_dequeue(&npinfo->txq))) {
 		struct net_device *dev = skb->dev;
 		struct netdev_queue *txq;
+		unsigned int q_index;
 
 		if (!netif_device_present(dev) || !netif_running(dev)) {
 			kfree_skb(skb);
 			continue;
 		}
 
-		txq = skb_get_tx_queue(dev, skb);
+		/* check if skb->queue_mapping is still valid */
+		q_index = skb_get_queue_mapping(skb);
+		if (unlikely(q_index >= dev->real_num_tx_queues)) {
+			q_index = q_index % dev->real_num_tx_queues;
+			skb_set_queue_mapping(skb, q_index);
+		}
+		txq = netdev_get_tx_queue(dev, q_index);
 
 		local_irq_save(flags);
 		HARD_TX_LOCK(dev, txq, smp_processor_id());
