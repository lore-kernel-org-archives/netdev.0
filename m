From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] igb: Correct PTP support query from ethtool.
Date: Wed,  5 Sep 2012 16:35:03 -0700
Message-ID: <1346888106-25638-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27164 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759942Ab2IEXfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 19:35:11 -0400
In-Reply-To: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Update ethtool_get_ts_info to not report any supported functionality on
82575 and add support for V2 Sync and V2 Delay packets. In the case
where CONFIG_IGB_PTP is not defined, we should be reporting default
values.

v2: Correct the function to return EOPNOTSUPP when there is no PTP support
    or the device does not support PTP. Also fix minor whitespace issue.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 62 +++++++++++++++++-----------
 1 file changed, 38 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index ffed4d0..2ea0128 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2295,37 +2295,53 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	}
 }
 
-#ifdef CONFIG_IGB_PTP
 static int igb_get_ts_info(struct net_device *dev,
-				   struct ethtool_ts_info *info)
+			   struct ethtool_ts_info *info)
 {
 	struct igb_adapter *adapter = netdev_priv(dev);
 
-	info->so_timestamping =
-		SOF_TIMESTAMPING_TX_HARDWARE |
-		SOF_TIMESTAMPING_RX_HARDWARE |
-		SOF_TIMESTAMPING_RAW_HARDWARE;
+	switch (adapter->hw.mac.type) {
+#ifdef CONFIG_IGB_PTP
+	case e1000_82576:
+	case e1000_82580:
+	case e1000_i350:
+	case e1000_i210:
+	case e1000_i211:
+		info->so_timestamping =
+			SOF_TIMESTAMPING_TX_HARDWARE |
+			SOF_TIMESTAMPING_RX_HARDWARE |
+			SOF_TIMESTAMPING_RAW_HARDWARE;
 
-	if (adapter->ptp_clock)
-		info->phc_index = ptp_clock_index(adapter->ptp_clock);
-	else
-		info->phc_index = -1;
+		if (adapter->ptp_clock)
+			info->phc_index = ptp_clock_index(adapter->ptp_clock);
+		else
+			info->phc_index = -1;
 
-	info->tx_types =
-		(1 << HWTSTAMP_TX_OFF) |
-		(1 << HWTSTAMP_TX_ON);
+		info->tx_types =
+			(1 << HWTSTAMP_TX_OFF) |
+			(1 << HWTSTAMP_TX_ON);
 
-	info->rx_filters =
-		(1 << HWTSTAMP_FILTER_NONE) |
-		(1 << HWTSTAMP_FILTER_ALL) |
-		(1 << HWTSTAMP_FILTER_SOME) |
-		(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
-		(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
-		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
+		info->rx_filters = 1 << HWTSTAMP_FILTER_NONE;
 
-	return 0;
-}
+		/* 82576 does not support timestamping all packets. */
+		if (adapter->hw.mac.type >= e1000_82580)
+			info->rx_filters |= 1 << HWTSTAMP_FILTER_ALL;
+		else
+			info->rx_filters |=
+				(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+				(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+				(1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
+				(1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+				(1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
+				(1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
+				(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
+
+		return 0;
 #endif /* CONFIG_IGB_PTP */
+	default:
+		return -EOPNOTSUPP;
+	}
+}
 
 static int igb_ethtool_begin(struct net_device *netdev)
 {
@@ -2366,9 +2382,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.get_ethtool_stats      = igb_get_ethtool_stats,
 	.get_coalesce           = igb_get_coalesce,
 	.set_coalesce           = igb_set_coalesce,
-#ifdef CONFIG_IGB_PTP
 	.get_ts_info            = igb_get_ts_info,
-#endif /* CONFIG_IGB_PTP */
 	.begin			= igb_ethtool_begin,
 	.complete		= igb_ethtool_complete,
 };
-- 
1.7.11.4
