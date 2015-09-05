From: romieu@fr.zoreil.com
Subject: [PATCH net 1/3] r8169: decouple the counters data and the device private area.
Date: Sat,  5 Sep 2015 14:18:52 +0200
Message-ID: <cc3b19f13a82e27928eb8cb3ee0d831d7fea62f8.1441454454.git.romieu@fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	pomidorabelisima@gmail.com, vinschen@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57779 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbbIEMTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 08:19:44 -0400
In-Reply-To: <cover.1441454454.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1441454454.git.romieu@fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Corinna Vinschen <vinschen@redhat.com>
Cc: pomidorabelisima@gmail.com
---
 drivers/net/ethernet/realtek/r8169.c | 70 +++++++++++++++++++++---------------
 1 file changed, 42 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 24dcbe6..73a60a7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -833,7 +833,7 @@ struct rtl8169_private {
 	unsigned features;
 
 	struct mii_if_info mii;
-	struct rtl8169_counters counters;
+	struct rtl8169_counters *counters;
 	struct rtl8169_tc_offsets tc_offset;
 	u32 saved_wolopts;
 	u32 opts1_mask;
@@ -2296,6 +2296,8 @@ static bool rtl8169_update_counters(struct net_device *dev)
 static bool rtl8169_init_counter_offsets(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_counters *counters = tp->counters;
+	struct rtl8169_tc_offsets *offset = &tp->tc_offset;
 	bool ret = false;
 
 	/*
@@ -2313,7 +2315,7 @@ static bool rtl8169_init_counter_offsets(struct net_device *dev)
 	 * set at open time by rtl_hw_start.
 	 */
 
-	if (tp->tc_offset.inited)
+	if (offset->inited)
 		return true;
 
 	/* If both, reset and update fail, propagate to caller. */
@@ -2323,10 +2325,10 @@ static bool rtl8169_init_counter_offsets(struct net_device *dev)
 	if (rtl8169_update_counters(dev))
 		ret = true;
 
-	tp->tc_offset.tx_errors = tp->counters.tx_errors;
-	tp->tc_offset.tx_multi_collision = tp->counters.tx_multi_collision;
-	tp->tc_offset.tx_aborted = tp->counters.tx_aborted;
-	tp->tc_offset.inited = true;
+	offset->tx_errors = counters->tx_errors;
+	offset->tx_multi_collision = counters->tx_multi_collision;
+	offset->tx_aborted = counters->tx_aborted;
+	offset->inited = true;
 
 	return ret;
 }
@@ -2335,24 +2337,25 @@ static void rtl8169_get_ethtool_stats(struct net_device *dev,
 				      struct ethtool_stats *stats, u64 *data)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_counters *c = tp->counters;
 
 	ASSERT_RTNL();
 
 	rtl8169_update_counters(dev);
 
-	data[0] = le64_to_cpu(tp->counters.tx_packets);
-	data[1] = le64_to_cpu(tp->counters.rx_packets);
-	data[2] = le64_to_cpu(tp->counters.tx_errors);
-	data[3] = le32_to_cpu(tp->counters.rx_errors);
-	data[4] = le16_to_cpu(tp->counters.rx_missed);
-	data[5] = le16_to_cpu(tp->counters.align_errors);
-	data[6] = le32_to_cpu(tp->counters.tx_one_collision);
-	data[7] = le32_to_cpu(tp->counters.tx_multi_collision);
-	data[8] = le64_to_cpu(tp->counters.rx_unicast);
-	data[9] = le64_to_cpu(tp->counters.rx_broadcast);
-	data[10] = le32_to_cpu(tp->counters.rx_multicast);
-	data[11] = le16_to_cpu(tp->counters.tx_aborted);
-	data[12] = le16_to_cpu(tp->counters.tx_underun);
+	data[ 0] = le64_to_cpu(c->tx_packets);
+	data[ 1] = le64_to_cpu(c->rx_packets);
+	data[ 2] = le64_to_cpu(c->tx_errors);
+	data[ 3] = le32_to_cpu(c->rx_errors);
+	data[ 4] = le16_to_cpu(c->rx_missed);
+	data[ 5] = le16_to_cpu(c->align_errors);
+	data[ 6] = le32_to_cpu(c->tx_one_collision);
+	data[ 7] = le32_to_cpu(c->tx_multi_collision);
+	data[ 8] = le64_to_cpu(c->rx_unicast);
+	data[ 9] = le64_to_cpu(c->rx_broadcast);
+	data[10] = le32_to_cpu(c->rx_multicast);
+	data[11] = le16_to_cpu(c->tx_aborted);
+	data[12] = le16_to_cpu(c->tx_underun);
 }
 
 static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -7671,6 +7674,8 @@ static int rtl8169_close(struct net_device *dev)
 
 	free_irq(pdev->irq, dev);
 
+	kfree(tp->counters);
+
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			  tp->RxPhyAddr);
 	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
@@ -7715,9 +7720,13 @@ static int rtl_open(struct net_device *dev)
 	if (!tp->RxDescArray)
 		goto err_free_tx_0;
 
+	tp->counters = kmalloc(sizeof(*tp->counters), GFP_KERNEL);
+	if (!tp->counters)
+		goto err_free_rx_1;
+
 	retval = rtl8169_init_ring(dev);
 	if (retval < 0)
-		goto err_free_rx_1;
+		goto err_free_counters_2;
 
 	INIT_WORK(&tp->wk.work, rtl_task);
 
@@ -7729,7 +7738,7 @@ static int rtl_open(struct net_device *dev)
 			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
 			     dev->name, dev);
 	if (retval < 0)
-		goto err_release_fw_2;
+		goto err_release_fw_3;
 
 	rtl_lock_work(tp);
 
@@ -7759,9 +7768,12 @@ static int rtl_open(struct net_device *dev)
 out:
 	return retval;
 
-err_release_fw_2:
+err_release_fw_3:
 	rtl_release_firmware(tp);
 	rtl8169_rx_clear(tp);
+err_free_counters_2:
+	kfree(tp->counters);
+	tp->counters = NULL;
 err_free_rx_1:
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			  tp->RxPhyAddr);
@@ -7779,6 +7791,8 @@ static struct rtnl_link_stats64 *
 rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_tc_offsets *offset = &tp->tc_offset;
+	struct rtl8169_counters *counters = tp->counters;
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int start;
 
@@ -7816,12 +7830,12 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	 * Subtract values fetched during initalization.
 	 * See rtl8169_init_counter_offsets for a description why we do that.
 	 */
-	stats->tx_errors = le64_to_cpu(tp->counters.tx_errors) -
-		le64_to_cpu(tp->tc_offset.tx_errors);
-	stats->collisions = le32_to_cpu(tp->counters.tx_multi_collision) -
-		le32_to_cpu(tp->tc_offset.tx_multi_collision);
-	stats->tx_aborted_errors = le16_to_cpu(tp->counters.tx_aborted) -
-		le16_to_cpu(tp->tc_offset.tx_aborted);
+	stats->tx_errors = le64_to_cpu(counters->tx_errors) -
+			   le64_to_cpu(offset->tx_errors);
+	stats->collisions = le32_to_cpu(counters->tx_multi_collision) -
+			    le32_to_cpu(offset->tx_multi_collision);
+	stats->tx_aborted_errors = le16_to_cpu(counters->tx_aborted) -
+				   le16_to_cpu(offset->tx_aborted);
 
 	return stats;
 }
-- 
2.4.3
