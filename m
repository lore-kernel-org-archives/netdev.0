From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH RFC] gianfar: Do not call skb recycling with disabled IRQs
Date: Thu, 5 Nov 2009 22:53:08 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950713@zin33exm22.fsl.freescale.net>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru> <E1N62ti-0003iS-K2@jdl.com> <20091105142028.GB17171@oksana.dev.rtsoft.ru> <E1N63WM-0003xK-PN@jdl.com> <E1N64UY-00049g-Hb@jdl.com> <20091105165738.GA31923@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-dev@ozlabs.org>,
	"Jason Wessel" <jason.wessel@windriver.com>,
	"Fleming Andy-AFLEMING" <afleming@freescale.com>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Lennert Buytenhek" <buytenh@wantstofly.org>,
	"Stephen Hemminger" <shemminger@vyatta.com>
To: <avorontsov@ru.mvista.com>, "Jon Loeliger" <jdl@jdl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:56415 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbZKERXF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 12:23:05 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nA5HN8IJ003121
	for <netdev@vger.kernel.org>; Thu, 5 Nov 2009 10:23:09 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id nA5HQFYY005764
	for <netdev@vger.kernel.org>; Thu, 5 Nov 2009 11:26:16 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091105165738.GA31923@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 


[.....]
> drivers/net/gianfar.c |   19 +++----------------
> 1 files changed, 3 insertions(+), 16 deletions(-)
>
>diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c 
>index 197b358..a0ae604 100644
>--- a/drivers/net/gianfar.c
>+++ b/drivers/net/gianfar.c
>@@ -1899,10 +1899,8 @@ static int gfar_start_xmit(struct 
>sk_buff *skb, struct net_device *dev)
> 	u32 lstatus;
> 	int i, rq = 0;
> 	u32 bufaddr;
>-	unsigned long flags;
> 	unsigned int nr_frags, length;
> 
>-
> 	rq = skb->queue_mapping;
> 	tx_queue = priv->tx_queue[rq];
> 	txq = netdev_get_tx_queue(dev, rq);
>@@ -1928,14 +1926,11 @@ static int gfar_start_xmit(struct 
>sk_buff *skb, struct net_device *dev)
> 	/* total number of fragments in the SKB */
> 	nr_frags = skb_shinfo(skb)->nr_frags;
> 
>-	spin_lock_irqsave(&tx_queue->txlock, flags);
>-
> 	/* check if there is space to queue this packet */
> 	if ((nr_frags+1) > tx_queue->num_txbdfree) {
> 		/* no space, stop the queue */
> 		netif_tx_stop_queue(txq);
> 		dev->stats.tx_fifo_errors++;
>-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
> 		return NETDEV_TX_BUSY;
> 	}
> 
>@@ -2033,9 +2028,6 @@ static int gfar_start_xmit(struct 
>sk_buff *skb, struct net_device *dev)
> 	/* Tell the DMA to go go go */
> 	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT >> tx_queue->qindex);
> 
>-	/* Unlock priv */
>-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
>-
> 	return NETDEV_TX_OK;
> }
> 
>@@ -2550,7 +2542,6 @@ static int gfar_poll(struct napi_struct 
>*napi, int budget)
> 	int tx_cleaned = 0, i, left_over_budget = budget;
> 	unsigned long serviced_queues = 0;
> 	int num_queues = 0;
>-	unsigned long flags;
> 
> 	num_queues = gfargrp->num_rx_queues;
> 	budget_per_queue = budget/num_queues;
>@@ -2570,13 +2561,9 @@ static int gfar_poll(struct napi_struct 
>*napi, int budget)
> 			rx_queue = priv->rx_queue[i];
> 			tx_queue = priv->tx_queue[rx_queue->qindex];
> 
>-			/* If we fail to get the lock,
>-			 * don't bother with the TX BDs */
>-			if 
>(spin_trylock_irqsave(&tx_queue->txlock, flags)) {
>-				tx_cleaned += 
>gfar_clean_tx_ring(tx_queue);
>-				
>spin_unlock_irqrestore(&tx_queue->txlock,
>-							flags);
>-			}
>+			netif_tx_lock_bh(priv->ndev);

Will this not lead to locking all the tx queues even though at this
point we are working on a "particular queue" ?

>+			tx_cleaned += gfar_clean_tx_ring(tx_queue);
>+			netif_tx_unlock_bh(priv->ndev);
> 
> 			rx_cleaned_per_queue = 
>gfar_clean_rx_ring(rx_queue,
> 							
>budget_per_queue);
>--

--

Thanks
Sandeep
