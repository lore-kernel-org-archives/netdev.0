From: Corinna Vinschen <vinschen@redhat.com>
Subject: [PATCH] r8169: Add values missing in @get_stats64 from HW counters
Date: Tue, 18 Aug 2015 11:04:24 +0200
Message-ID: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
Cc: nic_swsd@realtek.com, Francois Romieu <romieu@fr.zoreil.com>,
	Ivan Vecera <ivecera@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:34833 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbbHRJXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 05:23:43 -0400
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
at 0.  The TCs are only reset by a power cycle and there's no known way
to reset them programatically.  Without further considerations the values
collected by the driver would not match up against the TC values.

Therefore introduce an addition to the rtl8169_private struct and a
function rtl8169_init_tc_counter_offset to store the TCs at first
rtl_open.  Use these values as offsets in rtl8169_get_stats64.

Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c | 62 ++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f790f61..e7c7955 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -747,6 +747,14 @@ struct rtl8169_counters {
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
@@ -824,6 +832,7 @@ struct rtl8169_private {
 
 	struct mii_if_info mii;
 	struct rtl8169_counters counters;
+	struct rtl8169_tc_offsets tc_offset;
 	u32 saved_wolopts;
 	u32 opts1_mask;
 
@@ -2220,6 +2229,38 @@ static void rtl8169_update_counters(struct net_device *dev)
 	dma_free_coherent(d, sizeof(*counters), counters, paddr);
 }
 
+static void rtl8169_init_tc_counter_offset(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	/*
+	 * rtl8169_init_tc_counter_offset is called from rtl_open.  The tally
+	 * counters are only reset by a power cycle, while the counter values
+	 * collected by the driver are reset at every driver unload/load cycle.
+	 * There's also no (documented?) way to reset the tally counters
+	 * programatically.
+	 *
+	 * To make sure the HW values returned by @get_stats64 match the SW
+	 * values, we collect the initial values at first open(*) and use them
+	 * as offsets to normalize the values returned by @get_stats64.
+	 *
+	 * (*) We can't call rtl8169_init_tc_counter_offset from rtl_init_one
+	 * for the reason stated in rtl8169_update_counters; CmdRxEnb is only
+	 * set at open time by rtl_hw_start.
+	 */
+
+	if (tp->tc_offset.inited)
+		return;
+
+	rtl8169_update_counters(dev);
+
+	tp->tc_offset.tx_errors = tp->counters.tx_errors;
+	tp->tc_offset.tx_multi_collision = tp->counters.tx_multi_collision;
+	tp->tc_offset.rx_multicast = tp->counters.rx_multicast;
+	tp->tc_offset.tx_aborted = tp->counters.tx_aborted;
+	tp->tc_offset.inited = true;
+}
+
 static void rtl8169_get_ethtool_stats(struct net_device *dev,
 				      struct ethtool_stats *stats, u64 *data)
 {
@@ -7631,6 +7672,8 @@ static int rtl_open(struct net_device *dev)
 
 	rtl_hw_start(dev);
 
+	rtl8169_init_tc_counter_offset(dev);
+
 	netif_start_queue(dev);
 
 	rtl_unlock_work(tp);
@@ -7689,6 +7732,25 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
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
+	 * See rtl8169_init_tc_counter_offset for a description why we do that.
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
