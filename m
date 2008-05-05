From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: [PATCH] airo: use netstats in net_device structure
Date: Mon, 05 May 2008 22:38:34 +0300
Message-ID: <fvnnnq$p1d$2@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060602030707080707070504"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060602030707080707070504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
Changed airo_read_stats function parameter to net_device.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>


--------------060602030707080707070504
Content-Type: text/x-patch;
 name="airo_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="airo_netstats.patch"

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 45f47c1..8a78283 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1148,7 +1148,6 @@ static u8 airo_dbm_to_pct (tdsRssiEntry *rssi_rid, u8 dbm);
 static void airo_networks_free(struct airo_info *ai);
 
 struct airo_info {
-	struct net_device_stats	stats;
 	struct net_device             *dev;
 	struct list_head              dev_list;
 	/* Note, we can have MAX_FIDS outstanding.  FIDs are 16-bits, so we
@@ -1924,7 +1923,7 @@ static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 	if (npacks >= MAXTXQ - 1) {
 		netif_stop_queue (dev);
 		if (npacks > MAXTXQ) {
-			ai->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			return 1;
 		}
 		skb_queue_tail (&ai->txq, skb);
@@ -2044,13 +2043,13 @@ static void get_tx_error(struct airo_info *ai, s32 fid)
 		bap_read(ai, &status, 2, BAP0);
 	}
 	if (le16_to_cpu(status) & 2) /* Too many retries */
-		ai->stats.tx_aborted_errors++;
+		ai->dev->stats.tx_aborted_errors++;
 	if (le16_to_cpu(status) & 4) /* Transmit lifetime exceeded */
-		ai->stats.tx_heartbeat_errors++;
+		ai->dev->stats.tx_heartbeat_errors++;
 	if (le16_to_cpu(status) & 8) /* Aid fail */
 		{ }
 	if (le16_to_cpu(status) & 0x10) /* MAC disabled */
-		ai->stats.tx_carrier_errors++;
+		ai->dev->stats.tx_carrier_errors++;
 	if (le16_to_cpu(status) & 0x20) /* Association lost */
 		{ }
 	/* We produce a TXDROP event only for retry or lifetime
@@ -2102,7 +2101,7 @@ static void airo_end_xmit(struct net_device *dev) {
 		for (; i < MAX_FIDS / 2 && (priv->fids[i] & 0xffff0000); i++);
 	} else {
 		priv->fids[fid] &= 0xffff;
-		priv->stats.tx_window_errors++;
+		dev->stats.tx_window_errors++;
 	}
 	if (i < MAX_FIDS / 2)
 		netif_wake_queue(dev);
@@ -2128,7 +2127,7 @@ static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 		netif_stop_queue(dev);
 
 		if (i == MAX_FIDS / 2) {
-			priv->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			return 1;
 		}
 	}
@@ -2167,7 +2166,7 @@ static void airo_end_xmit11(struct net_device *dev) {
 		for (; i < MAX_FIDS && (priv->fids[i] & 0xffff0000); i++);
 	} else {
 		priv->fids[fid] &= 0xffff;
-		priv->stats.tx_window_errors++;
+		dev->stats.tx_window_errors++;
 	}
 	if (i < MAX_FIDS)
 		netif_wake_queue(dev);
@@ -2199,7 +2198,7 @@ static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 		netif_stop_queue(dev);
 
 		if (i == MAX_FIDS) {
-			priv->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			return 1;
 		}
 	}
@@ -2219,8 +2218,9 @@ static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 	return 0;
 }
 
-static void airo_read_stats(struct airo_info *ai)
+static void airo_read_stats(struct net_device *dev)
 {
+	struct airo_info *ai = dev->priv;
 	StatsRid stats_rid;
 	__le32 *vals = stats_rid.vals;
 
@@ -2232,23 +2232,24 @@ static void airo_read_stats(struct airo_info *ai)
 	readStatsRid(ai, &stats_rid, RID_STATS, 0);
 	up(&ai->sem);
 
-	ai->stats.rx_packets = le32_to_cpu(vals[43]) + le32_to_cpu(vals[44]) +
+	dev->stats.rx_packets = le32_to_cpu(vals[43]) + le32_to_cpu(vals[44]) +
 			       le32_to_cpu(vals[45]);
-	ai->stats.tx_packets = le32_to_cpu(vals[39]) + le32_to_cpu(vals[40]) +
+	dev->stats.tx_packets = le32_to_cpu(vals[39]) + le32_to_cpu(vals[40]) +
 			       le32_to_cpu(vals[41]);
-	ai->stats.rx_bytes = le32_to_cpu(vals[92]);
-	ai->stats.tx_bytes = le32_to_cpu(vals[91]);
-	ai->stats.rx_errors = le32_to_cpu(vals[0]) + le32_to_cpu(vals[2]) +
+	dev->stats.rx_bytes = le32_to_cpu(vals[92]);
+	dev->stats.tx_bytes = le32_to_cpu(vals[91]);
+	dev->stats.rx_errors = le32_to_cpu(vals[0]) + le32_to_cpu(vals[2]) +
 			      le32_to_cpu(vals[3]) + le32_to_cpu(vals[4]);
-	ai->stats.tx_errors = le32_to_cpu(vals[42]) + ai->stats.tx_fifo_errors;
-	ai->stats.multicast = le32_to_cpu(vals[43]);
-	ai->stats.collisions = le32_to_cpu(vals[89]);
+	dev->stats.tx_errors = le32_to_cpu(vals[42]) +
+			      dev->stats.tx_fifo_errors;
+	dev->stats.multicast = le32_to_cpu(vals[43]);
+	dev->stats.collisions = le32_to_cpu(vals[89]);
 
 	/* detailed rx_errors: */
-	ai->stats.rx_length_errors = le32_to_cpu(vals[3]);
-	ai->stats.rx_crc_errors = le32_to_cpu(vals[4]);
-	ai->stats.rx_frame_errors = le32_to_cpu(vals[2]);
-	ai->stats.rx_fifo_errors = le32_to_cpu(vals[0]);
+	dev->stats.rx_length_errors = le32_to_cpu(vals[3]);
+	dev->stats.rx_crc_errors = le32_to_cpu(vals[4]);
+	dev->stats.rx_frame_errors = le32_to_cpu(vals[2]);
+	dev->stats.rx_fifo_errors = le32_to_cpu(vals[0]);
 }
 
 static struct net_device_stats *airo_get_stats(struct net_device *dev)
@@ -2261,10 +2262,10 @@ static struct net_device_stats *airo_get_stats(struct net_device *dev)
 			set_bit(JOB_STATS, &local->jobs);
 			wake_up_interruptible(&local->thr_wait);
 		} else
-			airo_read_stats(local);
+			airo_read_stats(dev);
 	}
 
-	return &local->stats;
+	return &dev->stats;
 }
 
 static void airo_set_promisc(struct airo_info *ai) {
@@ -3092,7 +3093,7 @@ static int airo_thread(void *data) {
 		else if (test_bit(JOB_XMIT11, &ai->jobs))
 			airo_end_xmit11(dev);
 		else if (test_bit(JOB_STATS, &ai->jobs))
-			airo_read_stats(ai);
+			airo_read_stats(dev);
 		else if (test_bit(JOB_WSTATS, &ai->jobs))
 			airo_read_wireless_stats(ai);
 		else if (test_bit(JOB_PROMISC, &ai->jobs))
@@ -3288,7 +3289,7 @@ static irqreturn_t airo_interrupt(int irq, void *dev_id)
 
 			skb = dev_alloc_skb( len + hdrlen + 2 + 2 );
 			if ( !skb ) {
-				apriv->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				goto badrx;
 			}
 			skb_reserve(skb, 2); /* This way the IP header is aligned */
@@ -3556,7 +3557,7 @@ static void mpi_receive_802_3(struct airo_info *ai)
 
 		skb = dev_alloc_skb(len);
 		if (!skb) {
-			ai->stats.rx_dropped++;
+			ai->dev->stats.rx_dropped++;
 			goto badrx;
 		}
 		buffer = skb_put(skb,len);
@@ -3649,7 +3650,7 @@ void mpi_receive_802_11 (struct airo_info *ai)
 
 	skb = dev_alloc_skb( len + hdrlen + 2 );
 	if ( !skb ) {
-		ai->stats.rx_dropped++;
+		ai->dev->stats.rx_dropped++;
 		goto badrx;
 	}
 	buffer = (u16*)skb_put (skb, len + hdrlen);


--------------060602030707080707070504--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
