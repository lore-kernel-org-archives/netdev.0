From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sh-eth: use netdev stats structure and fix
 dma_map_single
Date: Tue, 07 Feb 2012 09:17:21 +0100
Message-ID: <1328602641.2476.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:50760 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349Ab2BGIR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 03:17:26 -0500
Received: by wics10 with SMTP id s10so4717046wic.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 00:17:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to maintain a parallel net_device_stats structure in
sh_eth_private, since we have a generic one in netdev

Fix two dma_map_single() incorrect parameters, passing skb->tail instead
of skb->data. Seems that there is no corresponding dmap_unmap_single()
calls for the moment in this driver.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
Please test this patch Yoshihiro before we can apply it, thanks !

 drivers/net/ethernet/renesas/sh_eth.c |   62 ++++++++++++------------
 drivers/net/ethernet/renesas/sh_eth.h |    1 
 2 files changed, 31 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 1cb5a34..dacd131 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -657,7 +657,7 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		mdp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		dma_map_single(&ndev->dev, skb->tail, mdp->rx_buf_sz,
+		dma_map_single(&ndev->dev, skb->data, mdp->rx_buf_sz,
 				DMA_FROM_DEVICE);
 		skb->dev = ndev; /* Mark as being used by this device. */
 		sh_eth_set_receive_align(skb);
@@ -881,8 +881,8 @@ static int sh_eth_txfree(struct net_device *ndev)
 		if (entry >= TX_RING_SIZE - 1)
 			txdesc->status |= cpu_to_edmac(mdp, TD_TDLE);
 
-		mdp->stats.tx_packets++;
-		mdp->stats.tx_bytes += txdesc->buffer_length;
+		ndev->stats.tx_packets++;
+		ndev->stats.tx_bytes += txdesc->buffer_length;
 	}
 	return freeNum;
 }
@@ -908,23 +908,23 @@ static int sh_eth_rx(struct net_device *ndev)
 			break;
 
 		if (!(desc_status & RDFEND))
-			mdp->stats.rx_length_errors++;
+			ndev->stats.rx_length_errors++;
 
 		if (desc_status & (RD_RFS1 | RD_RFS2 | RD_RFS3 | RD_RFS4 |
 				   RD_RFS5 | RD_RFS6 | RD_RFS10)) {
-			mdp->stats.rx_errors++;
+			ndev->stats.rx_errors++;
 			if (desc_status & RD_RFS1)
-				mdp->stats.rx_crc_errors++;
+				ndev->stats.rx_crc_errors++;
 			if (desc_status & RD_RFS2)
-				mdp->stats.rx_frame_errors++;
+				ndev->stats.rx_frame_errors++;
 			if (desc_status & RD_RFS3)
-				mdp->stats.rx_length_errors++;
+				ndev->stats.rx_length_errors++;
 			if (desc_status & RD_RFS4)
-				mdp->stats.rx_length_errors++;
+				ndev->stats.rx_length_errors++;
 			if (desc_status & RD_RFS6)
-				mdp->stats.rx_missed_errors++;
+				ndev->stats.rx_missed_errors++;
 			if (desc_status & RD_RFS10)
-				mdp->stats.rx_over_errors++;
+				ndev->stats.rx_over_errors++;
 		} else {
 			if (!mdp->cd->hw_swap)
 				sh_eth_soft_swap(
@@ -937,8 +937,8 @@ static int sh_eth_rx(struct net_device *ndev)
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
 			netif_rx(skb);
-			mdp->stats.rx_packets++;
-			mdp->stats.rx_bytes += pkt_len;
+			ndev->stats.rx_packets++;
+			ndev->stats.rx_bytes += pkt_len;
 		}
 		rxdesc->status |= cpu_to_edmac(mdp, RD_RACT);
 		entry = (++mdp->cur_rx) % RX_RING_SIZE;
@@ -957,7 +957,7 @@ static int sh_eth_rx(struct net_device *ndev)
 			mdp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
-			dma_map_single(&ndev->dev, skb->tail, mdp->rx_buf_sz,
+			dma_map_single(&ndev->dev, skb->data, mdp->rx_buf_sz,
 					DMA_FROM_DEVICE);
 			skb->dev = ndev;
 			sh_eth_set_receive_align(skb);
@@ -1007,7 +1007,7 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		felic_stat = sh_eth_read(ndev, ECSR);
 		sh_eth_write(ndev, felic_stat, ECSR);	/* clear int */
 		if (felic_stat & ECSR_ICD)
-			mdp->stats.tx_carrier_errors++;
+			ndev->stats.tx_carrier_errors++;
 		if (felic_stat & ECSR_LCHNG) {
 			/* Link Changed */
 			if (mdp->cd->no_psr || mdp->no_ether_link) {
@@ -1040,7 +1040,7 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 	if (intr_status & EESR_TWB) {
 		/* Write buck end. unused write back interrupt */
 		if (intr_status & EESR_TABT)	/* Transmit Abort int */
-			mdp->stats.tx_aborted_errors++;
+			ndev->stats.tx_aborted_errors++;
 			if (netif_msg_tx_err(mdp))
 				dev_err(&ndev->dev, "Transmit Abort\n");
 	}
@@ -1049,7 +1049,7 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		/* Receive Abort int */
 		if (intr_status & EESR_RFRMER) {
 			/* Receive Frame Overflow int */
-			mdp->stats.rx_frame_errors++;
+			ndev->stats.rx_frame_errors++;
 			if (netif_msg_rx_err(mdp))
 				dev_err(&ndev->dev, "Receive Abort\n");
 		}
@@ -1057,21 +1057,21 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 
 	if (intr_status & EESR_TDE) {
 		/* Transmit Descriptor Empty int */
-		mdp->stats.tx_fifo_errors++;
+		ndev->stats.tx_fifo_errors++;
 		if (netif_msg_tx_err(mdp))
 			dev_err(&ndev->dev, "Transmit Descriptor Empty\n");
 	}
 
 	if (intr_status & EESR_TFE) {
 		/* FIFO under flow */
-		mdp->stats.tx_fifo_errors++;
+		ndev->stats.tx_fifo_errors++;
 		if (netif_msg_tx_err(mdp))
 			dev_err(&ndev->dev, "Transmit FIFO Under flow\n");
 	}
 
 	if (intr_status & EESR_RDE) {
 		/* Receive Descriptor Empty int */
-		mdp->stats.rx_over_errors++;
+		ndev->stats.rx_over_errors++;
 
 		if (sh_eth_read(ndev, EDRRR) ^ EDRRR_R)
 			sh_eth_write(ndev, EDRRR_R, EDRRR);
@@ -1081,14 +1081,14 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 
 	if (intr_status & EESR_RFE) {
 		/* Receive FIFO Overflow int */
-		mdp->stats.rx_fifo_errors++;
+		ndev->stats.rx_fifo_errors++;
 		if (netif_msg_rx_err(mdp))
 			dev_err(&ndev->dev, "Receive FIFO Overflow\n");
 	}
 
 	if (!mdp->cd->no_ade && (intr_status & EESR_ADE)) {
 		/* Address Error */
-		mdp->stats.tx_fifo_errors++;
+		ndev->stats.tx_fifo_errors++;
 		if (netif_msg_tx_err(mdp))
 			dev_err(&ndev->dev, "Address Error\n");
 	}
@@ -1445,7 +1445,7 @@ static void sh_eth_tx_timeout(struct net_device *ndev)
 	       " resetting...\n", ndev->name, (int)sh_eth_read(ndev, EESR));
 
 	/* tx_errors count up */
-	mdp->stats.tx_errors++;
+	ndev->stats.tx_errors++;
 
 	/* timer off */
 	del_timer_sync(&mdp->timer);
@@ -1567,27 +1567,27 @@ static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 
 	pm_runtime_get_sync(&mdp->pdev->dev);
 
-	mdp->stats.tx_dropped += sh_eth_read(ndev, TROCR);
+	ndev->stats.tx_dropped += sh_eth_read(ndev, TROCR);
 	sh_eth_write(ndev, 0, TROCR);	/* (write clear) */
-	mdp->stats.collisions += sh_eth_read(ndev, CDCR);
+	ndev->stats.collisions += sh_eth_read(ndev, CDCR);
 	sh_eth_write(ndev, 0, CDCR);	/* (write clear) */
-	mdp->stats.tx_carrier_errors += sh_eth_read(ndev, LCCR);
+	ndev->stats.tx_carrier_errors += sh_eth_read(ndev, LCCR);
 	sh_eth_write(ndev, 0, LCCR);	/* (write clear) */
 	if (sh_eth_is_gether(mdp)) {
-		mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CERCR);
+		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CERCR);
 		sh_eth_write(ndev, 0, CERCR);	/* (write clear) */
-		mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CEECR);
+		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CEECR);
 		sh_eth_write(ndev, 0, CEECR);	/* (write clear) */
 	} else {
-		mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CNDCR);
+		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CNDCR);
 		sh_eth_write(ndev, 0, CNDCR);	/* (write clear) */
 	}
 	pm_runtime_put_sync(&mdp->pdev->dev);
 
-	return &mdp->stats;
+	return &ndev->stats;
 }
 
-/* ioctl to device funciotn*/
+/* ioctl to device function */
 static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq,
 				int cmd)
 {
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 47877b1..ba72976 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -762,7 +762,6 @@ struct sh_eth_private {
 	struct sh_eth_txdesc *tx_ring;
 	struct sk_buff **rx_skbuff;
 	struct sk_buff **tx_skbuff;
-	struct net_device_stats stats;
 	struct timer_list timer;
 	spinlock_t lock;
 	u32 cur_rx, dirty_rx;	/* Producer/consumer ring indices */
