From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Subject: [PATCH  2/3] gianfar: Fix stats support
Date: Wed, 16 Dec 2009 16:45:07 +0530
Message-ID: <1260962107-16855-1-git-send-email-Sandeep.Kumar@freescale.com>
Cc: davem@davemloft.net, Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
To: netdev@vger.kernel.org, avorontsov@ru.mvista.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35833 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762028AbZLPLPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 06:15:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the per rx/tx queue stats.
To update the per rx queue stats a new structure has been
introduced rx_q_stats.
The per tx queue stats are updated via the netdev_queue
structure itself.

Note that we update only the tx_packtes, tx_bytes, rx_packets,
rx_bytes and rx_dropped stats on a per queue basis.

Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
---
 drivers/net/gianfar.c |   42 ++++++++++++++++++++++++++++++++++++------
 drivers/net/gianfar.h |   10 ++++++++++
 2 files changed, 46 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1616531..e0620d0 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -417,6 +417,36 @@ static void gfar_init_mac(struct net_device *ndev)
 	gfar_write(&regs->fifo_tx_starve_shutoff, priv->fifo_starve_off);
 }
 
+static struct net_device_stats *gfar_get_stats(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct netdev_queue *txq;
+	unsigned long rx_packets = 0, rx_bytes = 0, rx_dropped = 0;
+	unsigned long tx_packets = 0, tx_bytes = 0;
+	int i = 0;
+
+	for (i = 0; i < priv->num_rx_queues; i++) {
+		rx_packets += priv->rx_queue[i]->stats.rx_packets;
+		rx_bytes += priv->rx_queue[i]->stats.rx_bytes;
+		rx_dropped += priv->rx_queue[i]->stats.rx_dropped;
+	}
+
+	dev->stats.rx_packets = rx_packets;
+	dev->stats.rx_bytes = rx_bytes;
+	dev->stats.rx_dropped = rx_dropped;
+
+	for (i = 0; i < priv->num_tx_queues; i++) {
+		txq = netdev_get_tx_queue(dev, i);
+		tx_bytes += txq->tx_bytes;
+		tx_packets += txq->tx_packets;
+	}
+
+	dev->stats.tx_bytes = tx_bytes;
+	dev->stats.tx_packets = tx_packets;
+
+	return &dev->stats;
+}
+
 static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_open = gfar_enet_open,
 	.ndo_start_xmit = gfar_start_xmit,
@@ -426,6 +456,7 @@ static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_tx_timeout = gfar_timeout,
 	.ndo_do_ioctl = gfar_ioctl,
 	.ndo_select_queue = gfar_select_queue,
+	.ndo_get_stats = gfar_get_stats,
 	.ndo_vlan_rx_register = gfar_vlan_rx_register,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
@@ -1943,7 +1974,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Update transmit stats */
-	dev->stats.tx_bytes += skb->len;
+	txq->tx_bytes += skb->len;
+	txq->tx_packets ++;
 
 	txbdp = txbdp_start = tx_queue->cur_tx;
 
@@ -2301,8 +2333,6 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	tx_queue->skb_dirtytx = skb_dirtytx;
 	tx_queue->dirty_tx = bdp;
 
-	dev->stats.tx_packets += howmany;
-
 	return howmany;
 }
 
@@ -2516,14 +2546,14 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 			}
 		} else {
 			/* Increment the number of packets */
-			dev->stats.rx_packets++;
+			rx_queue->stats.rx_packets++;
 			howmany++;
 
 			if (likely(skb)) {
 				pkt_len = bdp->length - ETH_FCS_LEN;
 				/* Remove the FCS from the packet length */
 				skb_put(skb, pkt_len);
-				dev->stats.rx_bytes += pkt_len;
+				rx_queue->stats.rx_bytes += pkt_len;
 
 				gfar_process_frame(dev, skb, amount_pull);
 
@@ -2531,7 +2561,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				if (netif_msg_rx_err(priv))
 					printk(KERN_WARNING
 					       "%s: Missing skb!\n", dev->name);
-				dev->stats.rx_dropped++;
+				rx_queue->stats.rx_dropped++;
 				priv->extra_stats.rx_skbmissing++;
 			}
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 68d16dc..4943cbe 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -940,6 +940,15 @@ struct gfar_priv_tx_q {
 	unsigned short txtime;
 };
 
+/*
+ * Per RX queue stats
+ */
+struct rx_q_stats {
+	unsigned long rx_packets;
+	unsigned long rx_bytes;
+	unsigned long rx_dropped;
+};
+
 /**
  *	struct gfar_priv_rx_q - per rx queue structure
  *	@rxlock: per queue rx spin lock
@@ -962,6 +971,7 @@ struct gfar_priv_rx_q {
 	struct	rxbd8 *cur_rx;
 	struct	net_device *dev;
 	struct gfar_priv_grp *grp;
+	struct rx_q_stats stats;
 	u16	skb_currx;
 	u16	qindex;
 	unsigned int	rx_ring_size;
-- 
1.6.5.6

