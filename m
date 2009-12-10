From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Subject: [RFC] gianfar: Fix stats support
Date: Thu, 10 Dec 2009 11:12:44 +0530
Message-ID: <1260423764-21210-1-git-send-email-Sandeep.Kumar@freescale.com>
Cc: davem@davemloft.net, Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
To: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:52562 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932782AbZLJFnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 00:43:07 -0500
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
 *. The device stats are updated via  .ndo_get_stats
 *. Please provide your inputs on this patch for any other
    modifications.
 *. If per queue stats {rx_packets | rx_bytes | tx_packtes | tx_bytes }
    are to be exposed they can be done via gfar_fill_stats (via ethtool
    stats dump). Please provide inputs if we need to expose the per queue
    stats as well.
 
 drivers/net/gianfar.c |   43 +++++++++++++++++++++++++++++++++++++------
 drivers/net/gianfar.h |   10 ++++++++++
 2 files changed, 47 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 73ccb07..7e6f4e4 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -143,6 +143,7 @@ void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
 static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static struct net_device_stats *gfar_get_stats(struct net_device *dev);
 u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb);
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
@@ -426,6 +427,7 @@ static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_tx_timeout = gfar_timeout,
 	.ndo_do_ioctl = gfar_ioctl,
 	.ndo_select_queue = gfar_select_queue,
+	.ndo_get_stats = gfar_get_stats,
 	.ndo_vlan_rx_register = gfar_vlan_rx_register,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
@@ -469,6 +471,36 @@ void unlock_tx_qs(struct gfar_private *priv)
 		spin_unlock(&priv->tx_queue[i]->txlock);
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
 /* Returns 1 if incoming frames use an FCB */
 static inline int gfar_uses_fcb(struct gfar_private *priv)
 {
@@ -1943,7 +1975,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Update transmit stats */
-	dev->stats.tx_bytes += skb->len;
+	txq->tx_bytes += skb->len;
+	txq->tx_packets ++;
 
 	txbdp = txbdp_start = tx_queue->cur_tx;
 
@@ -2301,8 +2334,6 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	tx_queue->skb_dirtytx = skb_dirtytx;
 	tx_queue->dirty_tx = bdp;
 
-	dev->stats.tx_packets += howmany;
-
 	return howmany;
 }
 
@@ -2516,14 +2547,14 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
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
 
@@ -2531,7 +2562,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
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
1.5.6.5

