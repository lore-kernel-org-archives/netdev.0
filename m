From: Corinna Vinschen <vinschen@redhat.com>
Subject: [PATCH v3] r8169: Fix sleeping function called during get_stats64, v2
Date: Thu, 10 Sep 2015 10:47:35 +0200
Message-ID: <1441874855-20638-1-git-send-email-vinschen@redhat.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, pomidorabelisima@gmail.com,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	linux-kernel@vger.kernel.org, nic_swsd@realtek.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:39800 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbbIJIri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 04:47:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=104031
Fixes: 6e85d5ad36a26debc23a9a865c029cbe242b2dc8

Based on the discussion starting at
http://www.spinics.net/lists/netdev/msg342193.html

Tested locally on RTL8168evl/8111evl with various concurrent processes
accessing /proc/net/dev while changing the link state as well as
removing/reloading the r8169 module.

Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
---

v2 -> v3: Rename CntPhysAddr -> counters_phys_addr
	  Rename CntArray    -> counters
	  Fix whitespace issue
	  Fix label names in rtl_init_one.

 drivers/net/ethernet/realtek/r8169.c | 137 ++++++++++++++---------------------
 1 file changed, 54 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 24dcbe6..2b32e0c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -833,7 +833,8 @@ struct rtl8169_private {
 	unsigned features;
 
 	struct mii_if_info mii;
-	struct rtl8169_counters counters;
+	dma_addr_t counters_phys_addr;
+	struct rtl8169_counters *counters;
 	struct rtl8169_tc_offsets tc_offset;
 	u32 saved_wolopts;
 	u32 opts1_mask;
@@ -2190,53 +2191,37 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
-static struct rtl8169_counters *rtl8169_map_counters(struct net_device *dev,
-						     dma_addr_t *paddr,
-						     u32 counter_cmd)
+DECLARE_RTL_COND(rtl_counters_cond)
 {
-	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct device *d = &tp->pci_dev->dev;
-	struct rtl8169_counters *counters;
-	u32 cmd;
 
-	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_KERNEL);
-	if (counters) {
-		RTL_W32(CounterAddrHigh, (u64)*paddr >> 32);
-		cmd = (u64)*paddr & DMA_BIT_MASK(32);
-		RTL_W32(CounterAddrLow, cmd);
-		RTL_W32(CounterAddrLow, cmd | counter_cmd);
-	}
-	return counters;
+	return RTL_R32(CounterAddrLow) & (CounterReset | CounterDump);
 }
 
-static void rtl8169_unmap_counters (struct net_device *dev,
-				    dma_addr_t paddr,
-				    struct rtl8169_counters *counters)
+static bool rtl8169_do_counters(struct net_device *dev, u32 counter_cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct device *d = &tp->pci_dev->dev;
+	dma_addr_t paddr = tp->counters_phys_addr;
+	u32 cmd;
+	bool ret;
 
-	RTL_W32(CounterAddrLow, 0);
-	RTL_W32(CounterAddrHigh, 0);
+	RTL_W32(CounterAddrHigh, (u64)paddr >> 32);
+	cmd = (u64)paddr & DMA_BIT_MASK(32);
+	RTL_W32(CounterAddrLow, cmd);
+	RTL_W32(CounterAddrLow, cmd | counter_cmd);
 
-	dma_free_coherent(d, sizeof(*counters), counters, paddr);
-}
+	ret = rtl_udelay_loop_wait_low(tp, &rtl_counters_cond, 10, 1000);
 
-DECLARE_RTL_COND(rtl_reset_counters_cond)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
+	RTL_W32(CounterAddrLow, 0);
+	RTL_W32(CounterAddrHigh, 0);
 
-	return RTL_R32(CounterAddrLow) & CounterReset;
+	return ret;
 }
 
 static bool rtl8169_reset_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	struct rtl8169_counters *counters;
-	dma_addr_t paddr;
-	bool ret = true;
 
 	/*
 	 * Versions prior to RTL_GIGA_MAC_VER_19 don't support resetting the
@@ -2245,32 +2230,13 @@ static bool rtl8169_reset_counters(struct net_device *dev)
 	if (tp->mac_version < RTL_GIGA_MAC_VER_19)
 		return true;
 
-	counters = rtl8169_map_counters(dev, &paddr, CounterReset);
-	if (!counters)
-		return false;
-
-	if (!rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000))
-		ret = false;
-
-	rtl8169_unmap_counters(dev, paddr, counters);
-
-	return ret;
-}
-
-DECLARE_RTL_COND(rtl_counters_cond)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	return RTL_R32(CounterAddrLow) & CounterDump;
+	return rtl8169_do_counters(dev, CounterReset);
 }
 
 static bool rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct rtl8169_counters *counters;
-	dma_addr_t paddr;
-	bool ret = true;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
@@ -2279,23 +2245,13 @@ static bool rtl8169_update_counters(struct net_device *dev)
 	if ((RTL_R8(ChipCmd) & CmdRxEnb) == 0)
 		return true;
 
-	counters = rtl8169_map_counters(dev, &paddr, CounterDump);
-	if (!counters)
-		return false;
-
-	if (rtl_udelay_loop_wait_low(tp, &rtl_counters_cond, 10, 1000))
-		memcpy(&tp->counters, counters, sizeof(*counters));
-	else
-		ret = false;
-
-	rtl8169_unmap_counters(dev, paddr, counters);
-
-	return ret;
+	return rtl8169_do_counters(dev, CounterDump);
 }
 
 static bool rtl8169_init_counter_offsets(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_counters *counters = tp->counters;
 	bool ret = false;
 
 	/*
@@ -2323,9 +2279,9 @@ static bool rtl8169_init_counter_offsets(struct net_device *dev)
 	if (rtl8169_update_counters(dev))
 		ret = true;
 
-	tp->tc_offset.tx_errors = tp->counters.tx_errors;
-	tp->tc_offset.tx_multi_collision = tp->counters.tx_multi_collision;
-	tp->tc_offset.tx_aborted = tp->counters.tx_aborted;
+	tp->tc_offset.tx_errors = counters->tx_errors;
+	tp->tc_offset.tx_multi_collision = counters->tx_multi_collision;
+	tp->tc_offset.tx_aborted = counters->tx_aborted;
 	tp->tc_offset.inited = true;
 
 	return ret;
@@ -2335,24 +2291,25 @@ static void rtl8169_get_ethtool_stats(struct net_device *dev,
 				      struct ethtool_stats *stats, u64 *data)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_counters *counters = tp->counters;
 
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
+	data[0] = le64_to_cpu(counters->tx_packets);
+	data[1] = le64_to_cpu(counters->rx_packets);
+	data[2] = le64_to_cpu(counters->tx_errors);
+	data[3] = le32_to_cpu(counters->rx_errors);
+	data[4] = le16_to_cpu(counters->rx_missed);
+	data[5] = le16_to_cpu(counters->align_errors);
+	data[6] = le32_to_cpu(counters->tx_one_collision);
+	data[7] = le32_to_cpu(counters->tx_multi_collision);
+	data[8] = le64_to_cpu(counters->rx_unicast);
+	data[9] = le64_to_cpu(counters->rx_broadcast);
+	data[10] = le32_to_cpu(counters->rx_multicast);
+	data[11] = le16_to_cpu(counters->tx_aborted);
+	data[12] = le16_to_cpu(counters->tx_underun);
 }
 
 static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -7780,6 +7737,7 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
+	struct rtl8169_counters *counters = tp->counters;
 	unsigned int start;
 
 	if (netif_running(dev))
@@ -7816,11 +7774,11 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	 * Subtract values fetched during initalization.
 	 * See rtl8169_init_counter_offsets for a description why we do that.
 	 */
-	stats->tx_errors = le64_to_cpu(tp->counters.tx_errors) -
+	stats->tx_errors = le64_to_cpu(counters->tx_errors) -
 		le64_to_cpu(tp->tc_offset.tx_errors);
-	stats->collisions = le32_to_cpu(tp->counters.tx_multi_collision) -
+	stats->collisions = le32_to_cpu(counters->tx_multi_collision) -
 		le32_to_cpu(tp->tc_offset.tx_multi_collision);
-	stats->tx_aborted_errors = le16_to_cpu(tp->counters.tx_aborted) -
+	stats->tx_aborted_errors = le16_to_cpu(counters->tx_aborted) -
 		le16_to_cpu(tp->tc_offset.tx_aborted);
 
 	return stats;
@@ -8022,6 +7980,9 @@ static void rtl_remove_one(struct pci_dev *pdev)
 
 	unregister_netdev(dev);
 
+	dma_free_coherent(&tp->pci_dev->dev, sizeof(*tp->counters),
+			  tp->counters, tp->counters_phys_addr);
+
 	rtl_release_firmware(tp);
 
 	if (pci_dev_run_wake(pdev))
@@ -8447,9 +8408,16 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 
+	tp->counters = dma_alloc_coherent (&pdev->dev, sizeof(*tp->counters),
+					   &tp->counters_phys_addr, GFP_KERNEL);
+	if (!tp->counters) {
+		rc = -ENOMEM;
+		goto err_out_msi_4;
+	}
+
 	rc = register_netdev(dev);
 	if (rc < 0)
-		goto err_out_msi_4;
+		goto err_out_cnt_5;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -8483,6 +8451,9 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
+err_out_cnt_5:
+	dma_free_coherent(&pdev->dev, sizeof(*tp->counters), tp->counters,
+			  tp->counters_phys_addr);
 err_out_msi_4:
 	netif_napi_del(&tp->napi);
 	rtl_disable_msi(pdev, tp);
-- 
2.1.0
