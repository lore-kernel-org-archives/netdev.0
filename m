From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] igb: Support the get_ts_info ethtool method.
Date: Wed, 20 Jun 2012 01:44:58 -0700
Message-ID: <1340181903-16382-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60849 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754928Ab2FTIpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:45:07 -0400
In-Reply-To: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Based on original patch from Richard Cochran <richardcochran@gmail.com>

Original patch caused build errors without CONFIG_IGB_1588_CLOCK and
CONFIG_PPS enabled, since the added code was not properly wrapped.

CC: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   35 ++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 812d4f9..59d0f04 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2271,6 +2271,38 @@ static void igb_ethtool_complete(struct net_device *netdev)
 	pm_runtime_put(&adapter->pdev->dev);
 }
 
+#ifdef CONFIG_IGB_PTP
+static int igb_ethtool_get_ts_info(struct net_device *dev,
+				   struct ethtool_ts_info *info)
+{
+	struct igb_adapter *adapter = netdev_priv(dev);
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	if (adapter->ptp_clock)
+		info->phc_index = ptp_clock_index(adapter->ptp_clock);
+	else
+		info->phc_index = -1;
+
+	info->tx_types =
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON);
+
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_ALL) |
+		(1 << HWTSTAMP_FILTER_SOME) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
+
+	return 0;
+}
+
+#endif
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings           = igb_get_settings,
 	.set_settings           = igb_set_settings,
@@ -2299,6 +2331,9 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.set_coalesce           = igb_set_coalesce,
 	.begin			= igb_ethtool_begin,
 	.complete		= igb_ethtool_complete,
+#ifdef CONFIG_IGB_PTP
+	.get_ts_info		= igb_ethtool_get_ts_info,
+#endif
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.10.2
