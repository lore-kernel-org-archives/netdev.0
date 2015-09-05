From: romieu@fr.zoreil.com
Subject: [PATCH net 3/3] r8169: increase the lifespan of the hardware counters dump area.
Date: Sat,  5 Sep 2015 14:18:54 +0200
Message-ID: <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	pomidorabelisima@gmail.com, vinschen@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57773 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbbIEMTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 08:19:38 -0400
In-Reply-To: <cover.1441454454.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1441454454.git.romieu@fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

net/core/net-sysfs.c::netstat_show retrieves stats with spinlock held.

This change avoids sleepable allocation and performs some housekeeping:
- receive ring, transmit ring and counters dump area allocation failures
  are all considered fatal during open()
- netif_warn is now redundant with rtl_reset_counters_cond built-in
  failure message.
- rtl_reset_counters_cond induced failures in open() are also considered
  fatal: it takes acceptable work to unwind comfortably.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=104031
Fixes: 6e85d5ad36a2 ("r8169: Add values missing in @get_stats64 from HW counters")
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Corinna Vinschen <vinschen@redhat.com>
Cc: pomidorabelisima@gmail.com
---
 drivers/net/ethernet/realtek/r8169.c | 132 +++++++++++++++--------------------
 1 file changed, 55 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c0a5edb..ae07567 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -833,8 +833,11 @@ struct rtl8169_private {
 	unsigned features;
 
 	struct mii_if_info mii;
+
 	struct rtl8169_counters *counters;
 	struct rtl8169_tc_offsets tc_offset;
+	dma_addr_t counters_map;
+
 	u32 saved_wolopts;
 	u32 opts1_mask;
 
@@ -2197,64 +2200,33 @@ DECLARE_RTL_COND(rtl_reset_counters_cond)
 	return RTL_R32(CounterAddrLow) & CounterReset;
 }
 
-static struct rtl8169_counters *rtl8169_map_counters(struct net_device *dev,
-						     dma_addr_t *paddr,
-						     u32 counter_cmd)
+static int rtl8169_cmd_counters(struct net_device *dev, u32 counter_cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct device *d = &tp->pci_dev->dev;
-	struct rtl8169_counters *counters;
+	dma_addr_t paddr = tp->counters_map;
 	u32 cmd;
 
-	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_KERNEL);
-	if (counters) {
-		RTL_W32(CounterAddrHigh, (u64)*paddr >> 32);
-		cmd = (u64)*paddr & DMA_BIT_MASK(32);
-		RTL_W32(CounterAddrLow, cmd);
-		RTL_W32(CounterAddrLow, cmd | counter_cmd);
-	}
-	return counters;
-}
+	RTL_W32(CounterAddrHigh, (u64)paddr >> 32);
+	cmd = (u64)paddr & DMA_BIT_MASK(32);
+	RTL_W32(CounterAddrLow, cmd);
+	RTL_W32(CounterAddrLow, cmd | counter_cmd);
 
-static void rtl8169_unmap_counters (struct net_device *dev,
-				    dma_addr_t paddr,
-				    struct rtl8169_counters *counters)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	struct device *d = &tp->pci_dev->dev;
-
-	RTL_W32(CounterAddrLow, 0);
-	RTL_W32(CounterAddrHigh, 0);
-
-	dma_free_coherent(d, sizeof(*counters), counters, paddr);
+	return rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000);
 }
 
-static bool rtl8169_reset_counters(struct net_device *dev)
+static int rtl8169_reset_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	struct rtl8169_counters *counters;
-	dma_addr_t paddr;
-	bool ret = true;
 
 	/*
 	 * Versions prior to RTL_GIGA_MAC_VER_19 don't support resetting the
 	 * tally counters.
 	 */
 	if (tp->mac_version < RTL_GIGA_MAC_VER_19)
-		return true;
-
-	counters = rtl8169_map_counters(dev, &paddr, CounterReset);
-	if (!counters)
-		return false;
-
-	if (!rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000))
-		ret = false;
-
-	rtl8169_unmap_counters(dev, paddr, counters);
+		return -EINVAL;
 
-	return ret;
+	return rtl8169_cmd_counters(dev, CounterReset);
 }
 
 DECLARE_RTL_COND(rtl_counters_cond)
@@ -2264,44 +2236,30 @@ DECLARE_RTL_COND(rtl_counters_cond)
 	return RTL_R32(CounterAddrLow) & CounterDump;
 }
 
-static bool rtl8169_update_counters(struct net_device *dev)
+static int rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct rtl8169_counters *counters;
-	dma_addr_t paddr;
-	bool ret = true;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
 	 * is disabled.
 	 */
 	if ((RTL_R8(ChipCmd) & CmdRxEnb) == 0)
-		return true;
-
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
+		return -EINVAL;
 
-	return ret;
+	return rtl8169_cmd_counters(dev, CounterDump);
 }
 
-static bool rtl8169_init_counter_offsets(struct net_device *dev)
+static int rtl_init_counter_offsets(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct rtl8169_counters *counters = tp->counters;
 	struct rtl8169_tc_offsets *offset = &tp->tc_offset;
-	bool ret = false;
+	int rc;
 
 	/*
-	 * rtl8169_init_counter_offsets is called from rtl_open.  On chip
+	 * rtl_init_counter_offsets is called from rtl_open.  On chip
 	 * versions prior to RTL_GIGA_MAC_VER_19 the tally counters are only
 	 * reset by a power cycle, while the counter values collected by the
 	 * driver are reset at every driver unload/load cycle.
@@ -2310,27 +2268,29 @@ static bool rtl8169_init_counter_offsets(struct net_device *dev)
 	 * values, we collect the initial values at first open(*) and use them
 	 * as offsets to normalize the values returned by @get_stats64.
 	 *
-	 * (*) We can't call rtl8169_init_counter_offsets from rtl_init_one
+	 * (*) We can't call rtl_init_counter_offsets from rtl_init_one
 	 * for the reason stated in rtl8169_update_counters; CmdRxEnb is only
 	 * set at open time by rtl_hw_start.
 	 */
 
 	if (offset->inited)
-		return true;
+		return 0;
 
 	/* If both, reset and update fail, propagate to caller. */
-	if (rtl8169_reset_counters(dev))
-		ret = true;
+	rc = rtl8169_reset_counters(dev);
+	if (!rc)
+		goto out;
 
-	if (rtl8169_update_counters(dev))
-		ret = true;
+	rc = rtl8169_update_counters(dev);
+	if (rc < 0)
+		goto out;
 
 	offset->tx_errors = counters->tx_errors;
 	offset->tx_multi_collision = counters->tx_multi_collision;
 	offset->tx_aborted = counters->tx_aborted;
 	offset->inited = true;
-
-	return ret;
+out:
+	return rc;
 }
 
 static void rtl8169_get_ethtool_stats(struct net_device *dev,
@@ -7674,8 +7634,8 @@ static int rtl8169_close(struct net_device *dev)
 
 	free_irq(pdev->irq, dev);
 
-	kfree(tp->counters);
-
+	dma_free_coherent(&pdev->dev, sizeof(*tp->counters), tp->counters,
+			  tp->counters_map);
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			  tp->RxPhyAddr);
 	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
@@ -7720,7 +7680,8 @@ static int rtl_open(struct net_device *dev)
 	if (!tp->RxDescArray)
 		goto err_free_tx_0;
 
-	tp->counters = kmalloc(sizeof(*tp->counters), GFP_KERNEL);
+	tp->counters = dma_alloc_coherent(&pdev->dev, sizeof(*tp->counters),
+					  &tp->counters_map, GFP_KERNEL);
 	if (!tp->counters)
 		goto err_free_rx_1;
 
@@ -7742,8 +7703,6 @@ static int rtl_open(struct net_device *dev)
 
 	rtl_lock_work(tp);
 
-	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
-
 	napi_enable(&tp->napi);
 
 	rtl8169_init_phy(dev, tp);
@@ -7754,8 +7713,22 @@ static int rtl_open(struct net_device *dev)
 
 	rtl_hw_start(dev);
 
-	if (!rtl8169_init_counter_offsets(dev))
-		netif_warn(tp, hw, dev, "counter reset/update failed\n");
+	retval = rtl_init_counter_offsets(dev);
+	if (retval < 0) {
+		/*
+		 * Late error but the current thread is still in control:
+		 * - deferred work could have been scheduled - and it could
+		 *   be actually waiting for its mutex to be released - but
+		 *   we still haven't allowed it to perform real work.
+		 * - transmit timeout timer can't run either.
+		 */
+		rtl8169_hw_reset(tp);
+		rtl_pll_power_down(tp);
+		rtl_unlock_work(tp);
+		goto err_napi_disable_4;
+	}
+
+	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
 
 	netif_start_queue(dev);
 
@@ -7768,11 +7741,16 @@ static int rtl_open(struct net_device *dev)
 out:
 	return retval;
 
+err_napi_disable_4:
+	napi_disable(&tp->napi);
+	cancel_work_sync(&tp->wk.work);
+	free_irq(pdev->irq, dev);
 err_release_fw_3:
 	rtl_release_firmware(tp);
 	rtl8169_rx_clear(tp);
 err_free_counters_2:
-	kfree(tp->counters);
+	dma_free_coherent(&pdev->dev, sizeof(*tp->counters), tp->counters,
+			  tp->counters_map);
 	tp->counters = NULL;
 err_free_rx_1:
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
-- 
2.4.3
