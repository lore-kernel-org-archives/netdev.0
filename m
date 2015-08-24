From: Corinna Vinschen <vinschen@redhat.com>
Subject: [PATCH v3 net-next] r8169: Add values missing in @get_stats64 from HW counters
Date: Mon, 24 Aug 2015 12:27:53 +0200
Message-ID: <1440412073-8567-1-git-send-email-vinschen@redhat.com>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
Cc: Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:49949 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbHXK17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 06:27:59 -0400
In-Reply-To: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The r8169 driver collects statistical information returned by
@get_stats64 by counting them in the driver itself, even though many
(but not all) of the values are already collected by tally counters
(TCs) in the NIC.  Some of these TC values are not returned by
@get_stats64.  Especially the received multicast packages are missing
from /proc/net/dev.

Rectify this by fetching the TCs and returning them from
rtl8169_get_stats64.

The counters collected in the driver obviously disappear as soon as the
driver is unloaded so after a driver is loaded the counters always start
at 0. The TCs on the other hand are only reset by a power cycle.  Without
further considerations the values collected by the driver would not match
up against the TC values.

This patch introduces a new function rtl8169_reset_counters which
resets the TCs.  Also, since rtl8169_reset_counters shares most of
its code with rtl8169_update_counters, refactor the shared code into
two new functions  rtl8169_map_counters and rtl8169_unmap_counters.

Unfortunately chip versions prior to RTL_GIGA_MAC_VER_19 don't allow
to reset the TCs programatically.  Therefore introduce an addition to
the rtl8169_private struct and a function rtl8169_init_counter_offsets
to store the TCs at first rtl_open.  Use these values as offsets in
rtl8169_get_stats64.  Propagate a failure to reset *and* update the
counters up to rtl_open and emit a warning message, if so.

Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c | 165 +++++++++++++++++++++++++++++++----
 1 file changed, 150 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f790f61..1e4322c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -637,6 +637,9 @@ enum rtl_register_content {
 	/* _TBICSRBit */
 	TBILinkOK	= 0x02000000,
 
+	/* ResetCounterCommand */
+	CounterReset	= 0x1,
+
 	/* DumpCounterCommand */
 	CounterDump	= 0x8,
 
@@ -747,6 +750,14 @@ struct rtl8169_counters {
 	__le16	tx_underun;
 };
 
+struct rtl8169_tc_offsets {
+	bool	inited;
+	__le64	tx_errors;
+	__le32	tx_multi_collision;
+	__le32	rx_multicast;
+	__le16	tx_aborted;
+};
+
 enum rtl_flag {
 	RTL_FLAG_TASK_ENABLED,
 	RTL_FLAG_TASK_SLOW_PENDING,
@@ -824,6 +835,7 @@ struct rtl8169_private {
 
 	struct mii_if_info mii;
 	struct rtl8169_counters counters;
+	struct rtl8169_tc_offsets tc_offset;
 	u32 saved_wolopts;
 	u32 opts1_mask;
 
@@ -2179,6 +2191,73 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+static struct rtl8169_counters *rtl8169_map_counters(struct net_device *dev,
+						     dma_addr_t *paddr,
+						     u32 counter_cmd)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct device *d = &tp->pci_dev->dev;
+	struct rtl8169_counters *counters;
+	u32 cmd;
+
+	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_KERNEL);
+	if (counters) {
+		RTL_W32(CounterAddrHigh, (u64)*paddr >> 32);
+		cmd = (u64)*paddr & DMA_BIT_MASK(32);
+		RTL_W32(CounterAddrLow, cmd);
+		RTL_W32(CounterAddrLow, cmd | counter_cmd);
+	}
+	return counters;
+}
+
+static void rtl8169_unmap_counters (struct net_device *dev,
+				    dma_addr_t paddr,
+				    struct rtl8169_counters *counters)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct device *d = &tp->pci_dev->dev;
+
+	RTL_W32(CounterAddrLow, 0);
+	RTL_W32(CounterAddrHigh, 0);
+
+	dma_free_coherent(d, sizeof(*counters), counters, paddr);
+}
+
+DECLARE_RTL_COND(rtl_reset_counters_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(CounterAddrLow) & CounterReset;
+}
+
+static bool rtl8169_reset_counters(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_counters *counters;
+	dma_addr_t paddr;
+	bool ret = true;
+
+	/*
+	 * Versions prior to RTL_GIGA_MAC_VER_19 don't support resetting the
+	 * tally counters.
+	 */
+	if (tp->mac_version < RTL_GIGA_MAC_VER_19)
+		return true;
+
+	counters = rtl8169_map_counters(dev, &paddr, CounterReset);
+	if (!counters)
+		return false;
+
+	if (!rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000))
+		ret = false;
+
+	rtl8169_unmap_counters(dev, paddr, counters);
+
+	return ret;
+}
+
 DECLARE_RTL_COND(rtl_counters_cond)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -2186,38 +2265,72 @@ DECLARE_RTL_COND(rtl_counters_cond)
 	return RTL_R32(CounterAddrLow) & CounterDump;
 }
 
-static void rtl8169_update_counters(struct net_device *dev)
+static bool rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct device *d = &tp->pci_dev->dev;
 	struct rtl8169_counters *counters;
 	dma_addr_t paddr;
-	u32 cmd;
+	bool ret = true;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
 	 * is disabled.
 	 */
 	if ((RTL_R8(ChipCmd) & CmdRxEnb) == 0)
-		return;
+		return true;
 
-	counters = dma_alloc_coherent(d, sizeof(*counters), &paddr, GFP_KERNEL);
+	counters = rtl8169_map_counters(dev, &paddr, CounterDump);
 	if (!counters)
-		return;
-
-	RTL_W32(CounterAddrHigh, (u64)paddr >> 32);
-	cmd = (u64)paddr & DMA_BIT_MASK(32);
-	RTL_W32(CounterAddrLow, cmd);
-	RTL_W32(CounterAddrLow, cmd | CounterDump);
+		return false;
 
 	if (rtl_udelay_loop_wait_low(tp, &rtl_counters_cond, 10, 1000))
 		memcpy(&tp->counters, counters, sizeof(*counters));
+	else
+		ret = false;
 
-	RTL_W32(CounterAddrLow, 0);
-	RTL_W32(CounterAddrHigh, 0);
+	rtl8169_unmap_counters(dev, paddr, counters);
 
-	dma_free_coherent(d, sizeof(*counters), counters, paddr);
+	return ret;
+}
+
+static bool rtl8169_init_counter_offsets(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	bool ret = false;
+
+	/*
+	 * rtl8169_init_counter_offsets is called from rtl_open.  On chip
+	 * versions prior to RTL_GIGA_MAC_VER_19 the tally counters are only
+	 * reset by a power cycle, while the counter values collected by the
+	 * driver are reset at every driver unload/load cycle.
+	 *
+	 * To make sure the HW values returned by @get_stats64 match the SW
+	 * values, we collect the initial values at first open(*) and use them
+	 * as offsets to normalize the values returned by @get_stats64.
+	 *
+	 * (*) We can't call rtl8169_init_counter_offsets from rtl_init_one
+	 * for the reason stated in rtl8169_update_counters; CmdRxEnb is only
+	 * set at open time by rtl_hw_start.
+	 */
+
+	if (tp->tc_offset.inited)
+		return true;
+
+	/* If both, reset and update fail, propagate to caller. */
+	if (rtl8169_reset_counters(dev))
+		ret = true;
+
+	if (rtl8169_update_counters(dev))
+		ret = true;
+
+	tp->tc_offset.tx_errors = tp->counters.tx_errors;
+	tp->tc_offset.tx_multi_collision = tp->counters.tx_multi_collision;
+	tp->tc_offset.rx_multicast = tp->counters.rx_multicast;
+	tp->tc_offset.tx_aborted = tp->counters.tx_aborted;
+	tp->tc_offset.inited = true;
+
+	return ret;
 }
 
 static void rtl8169_get_ethtool_stats(struct net_device *dev,
@@ -7544,7 +7657,7 @@ static int rtl8169_close(struct net_device *dev)
 
 	pm_runtime_get_sync(&pdev->dev);
 
-	/* Update counters before going down */
+	/* update counters before going down */
 	rtl8169_update_counters(dev);
 
 	rtl_lock_work(tp);
@@ -7631,6 +7744,9 @@ static int rtl_open(struct net_device *dev)
 
 	rtl_hw_start(dev);
 
+	if (!rtl8169_init_counter_offsets(dev))
+		netif_warn(tp, hw, dev, "counter reset/update failed\n");
+
 	netif_start_queue(dev);
 
 	rtl_unlock_work(tp);
@@ -7689,6 +7805,25 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	stats->rx_fifo_errors	= dev->stats.rx_fifo_errors;
 	stats->rx_missed_errors = dev->stats.rx_missed_errors;
 
+	/*
+	 * Fetch additonal counter values missing in stats collected by driver
+	 * from tally counters.
+	 */
+	rtl8169_update_counters(dev);
+
+	/*
+	 * Subtract values fetched during initalization.
+	 * See rtl8169_init_counter_offsets for a description why we do that.
+	 */
+	stats->tx_errors = le64_to_cpu(tp->counters.tx_errors) -
+		le64_to_cpu(tp->tc_offset.tx_errors);
+	stats->collisions = le32_to_cpu(tp->counters.tx_multi_collision) -
+		le32_to_cpu(tp->tc_offset.tx_multi_collision);
+	stats->multicast = le32_to_cpu(tp->counters.rx_multicast) -
+		le32_to_cpu(tp->tc_offset.rx_multicast);
+	stats->tx_aborted_errors = le16_to_cpu(tp->counters.tx_aborted) -
+		le16_to_cpu(tp->tc_offset.tx_aborted);
+
 	return stats;
 }
 
-- 
2.1.0
