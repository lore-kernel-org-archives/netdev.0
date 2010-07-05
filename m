From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] mac89x0: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:14:09 +0400
Message-ID: <1278332051-17760-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/mac89x0.c |   52 +++++++++++++++++++++++++++---------------------
 1 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index 69fa4ef..669b317 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -110,7 +110,6 @@ static unsigned int net_debug = NET_DEBUG;
 
 /* Information that need to be kept for each board. */
 struct net_local {
-	struct net_device_stats stats;
 	int chip_type;		/* one of: CS8900, CS8920, CS8920M */
 	char chip_revision;	/* revision letter of the chip ('A'...) */
 	int send_cmd;		/* the propercommand used to send a packet. */
@@ -444,13 +443,18 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 			net_rx(dev);
 			break;
 		case ISQ_TRANSMITTER_EVENT:
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 			netif_wake_queue(dev);
-			if ((status & TX_OK) == 0) lp->stats.tx_errors++;
-			if (status & TX_LOST_CRS) lp->stats.tx_carrier_errors++;
-			if (status & TX_SQE_ERROR) lp->stats.tx_heartbeat_errors++;
-			if (status & TX_LATE_COL) lp->stats.tx_window_errors++;
-			if (status & TX_16_COL) lp->stats.tx_aborted_errors++;
+			if ((status & TX_OK) == 0)
+				dev->stats.tx_errors++;
+			if (status & TX_LOST_CRS)
+				dev->stats.tx_carrier_errors++;
+			if (status & TX_SQE_ERROR)
+				dev->stats.tx_heartbeat_errors++;
+			if (status & TX_LATE_COL)
+				dev->stats.tx_window_errors++;
+			if (status & TX_16_COL)
+				dev->stats.tx_aborted_errors++;
 			break;
 		case ISQ_BUFFER_EVENT:
 			if (status & READY_FOR_TX) {
@@ -469,10 +473,10 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
                         }
 			break;
 		case ISQ_RX_MISS_EVENT:
-			lp->stats.rx_missed_errors += (status >>6);
+			dev->stats.rx_missed_errors += (status >> 6);
 			break;
 		case ISQ_TX_COL_EVENT:
-			lp->stats.collisions += (status >>6);
+			dev->stats.collisions += (status >> 6);
 			break;
 		}
 	}
@@ -483,19 +487,22 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	int status, length;
 
 	status = readreg(dev, PP_RxStatus);
 	if ((status & RX_OK) == 0) {
-		lp->stats.rx_errors++;
-		if (status & RX_RUNT) lp->stats.rx_length_errors++;
-		if (status & RX_EXTRA_DATA) lp->stats.rx_length_errors++;
-		if (status & RX_CRC_ERROR) if (!(status & (RX_EXTRA_DATA|RX_RUNT)))
+		dev->stats.rx_errors++;
+		if (status & RX_RUNT)
+				dev->stats.rx_length_errors++;
+		if (status & RX_EXTRA_DATA)
+				dev->stats.rx_length_errors++;
+		if ((status & RX_CRC_ERROR) &&
+		    !(status & (RX_EXTRA_DATA|RX_RUNT)))
 			/* per str 172 */
-			lp->stats.rx_crc_errors++;
-		if (status & RX_DRIBBLE) lp->stats.rx_frame_errors++;
+			dev->stats.rx_crc_errors++;
+		if (status & RX_DRIBBLE)
+				dev->stats.rx_frame_errors++;
 		return;
 	}
 
@@ -504,7 +511,7 @@ net_rx(struct net_device *dev)
 	skb = alloc_skb(length, GFP_ATOMIC);
 	if (skb == NULL) {
 		printk("%s: Memory squeeze, dropping packet.\n", dev->name);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb_put(skb, length);
@@ -519,8 +526,8 @@ net_rx(struct net_device *dev)
 
         skb->protocol=eth_type_trans(skb,dev);
 	netif_rx(skb);
-	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += length;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += length;
 }
 
 /* The inverse routine to net_open(). */
@@ -548,16 +555,15 @@ net_close(struct net_device *dev)
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	local_irq_save(flags);
 	/* Update the statistics from the device registers. */
-	lp->stats.rx_missed_errors += (readreg(dev, PP_RxMiss) >> 6);
-	lp->stats.collisions += (readreg(dev, PP_TxCol) >> 6);
+	dev->stats.rx_missed_errors += (readreg(dev, PP_RxMiss) >> 6);
+	dev->stats.collisions += (readreg(dev, PP_TxCol) >> 6);
 	local_irq_restore(flags);
 
-	return &lp->stats;
+	return &dev->stats;
 }
 
 static void set_multicast_list(struct net_device *dev)
-- 
1.7.0.4
