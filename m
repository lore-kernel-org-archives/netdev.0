From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] ksz884x: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:13:58 +0400
Message-ID: <1278332040-17160-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Denis Kirjanov <dkirjanov@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/ksz884x.c |   46 ++++++++++++++++++++++------------------------
 1 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index f715348..1d998e1 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -1457,7 +1457,6 @@ struct dev_info {
  * @adapter:		Adapter device information.
  * @port:		Port information.
  * @monitor_time_info:	Timer to monitor ports.
- * @stats:		Network statistics.
  * @proc_sem:		Semaphore for proc accessing.
  * @id:			Device ID.
  * @mii_if:		MII interface information.
@@ -1471,7 +1470,6 @@ struct dev_priv {
 	struct dev_info *adapter;
 	struct ksz_port port;
 	struct ksz_timer_info monitor_timer_info;
-	struct net_device_stats stats;
 
 	struct semaphore proc_sem;
 	int id;
@@ -4751,8 +4749,8 @@ static void send_packet(struct sk_buff *skb, struct net_device *dev)
 	hw_send_pkt(hw);
 
 	/* Update transmit statistics. */
-	priv->stats.tx_packets++;
-	priv->stats.tx_bytes += len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += len;
 }
 
 /**
@@ -5030,7 +5028,7 @@ static inline int rx_proc(struct net_device *dev, struct ksz_hw* hw,
 		/* skb->data != skb->head */
 		skb = dev_alloc_skb(packet_len + 2);
 		if (!skb) {
-			priv->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			return -ENOMEM;
 		}
 
@@ -5050,8 +5048,8 @@ static inline int rx_proc(struct net_device *dev, struct ksz_hw* hw,
 		csum_verified(skb);
 
 	/* Update receive statistics. */
-	priv->stats.rx_packets++;
-	priv->stats.rx_bytes += packet_len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += packet_len;
 
 	/* Notify upper layer for received packet. */
 	rx_status = netif_rx(skb);
@@ -5291,7 +5289,7 @@ static irqreturn_t netdev_intr(int irq, void *dev_id)
 		}
 
 		if (unlikely(int_enable & KS884X_INT_RX_OVERRUN)) {
-			priv->stats.rx_fifo_errors++;
+			dev->stats.rx_fifo_errors++;
 			hw_resume_rx(hw);
 		}
 
@@ -5522,7 +5520,7 @@ static int netdev_open(struct net_device *dev)
 	priv->promiscuous = 0;
 
 	/* Reset device statistics. */
-	memset(&priv->stats, 0, sizeof(struct net_device_stats));
+	memset(&dev->stats, 0, sizeof(struct net_device_stats));
 	memset((void *) port->counter, 0,
 		(sizeof(u64) * OID_COUNTER_LAST));
 
@@ -5622,42 +5620,42 @@ static struct net_device_stats *netdev_query_statistics(struct net_device *dev)
 	int i;
 	int p;
 
-	priv->stats.rx_errors = port->counter[OID_COUNTER_RCV_ERROR];
-	priv->stats.tx_errors = port->counter[OID_COUNTER_XMIT_ERROR];
+	dev->stats.rx_errors = port->counter[OID_COUNTER_RCV_ERROR];
+	dev->stats.tx_errors = port->counter[OID_COUNTER_XMIT_ERROR];
 
 	/* Reset to zero to add count later. */
-	priv->stats.multicast = 0;
-	priv->stats.collisions = 0;
-	priv->stats.rx_length_errors = 0;
-	priv->stats.rx_crc_errors = 0;
-	priv->stats.rx_frame_errors = 0;
-	priv->stats.tx_window_errors = 0;
+	dev->stats.multicast = 0;
+	dev->stats.collisions = 0;
+	dev->stats.rx_length_errors = 0;
+	dev->stats.rx_crc_errors = 0;
+	dev->stats.rx_frame_errors = 0;
+	dev->stats.tx_window_errors = 0;
 
 	for (i = 0, p = port->first_port; i < port->mib_port_cnt; i++, p++) {
 		mib = &hw->port_mib[p];
 
-		priv->stats.multicast += (unsigned long)
+		dev->stats.multicast += (unsigned long)
 			mib->counter[MIB_COUNTER_RX_MULTICAST];
 
-		priv->stats.collisions += (unsigned long)
+		dev->stats.collisions += (unsigned long)
 			mib->counter[MIB_COUNTER_TX_TOTAL_COLLISION];
 
-		priv->stats.rx_length_errors += (unsigned long)(
+		dev->stats.rx_length_errors += (unsigned long)(
 			mib->counter[MIB_COUNTER_RX_UNDERSIZE] +
 			mib->counter[MIB_COUNTER_RX_FRAGMENT] +
 			mib->counter[MIB_COUNTER_RX_OVERSIZE] +
 			mib->counter[MIB_COUNTER_RX_JABBER]);
-		priv->stats.rx_crc_errors += (unsigned long)
+		dev->stats.rx_crc_errors += (unsigned long)
 			mib->counter[MIB_COUNTER_RX_CRC_ERR];
-		priv->stats.rx_frame_errors += (unsigned long)(
+		dev->stats.rx_frame_errors += (unsigned long)(
 			mib->counter[MIB_COUNTER_RX_ALIGNMENT_ERR] +
 			mib->counter[MIB_COUNTER_RX_SYMBOL_ERR]);
 
-		priv->stats.tx_window_errors += (unsigned long)
+		dev->stats.tx_window_errors += (unsigned long)
 			mib->counter[MIB_COUNTER_TX_LATE_COLLISION];
 	}
 
-	return &priv->stats;
+	return &dev->stats;
 }
 
 /**
-- 
1.7.0.4
