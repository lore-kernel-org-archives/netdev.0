From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] ixgbe: add support for get_ts_info
Date: Wed,  9 May 2012 23:46:50 -0700
Message-ID: <1336632413-19135-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51353 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756244Ab2EJGrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 02:47:05 -0400
In-Reply-To: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds support for the ethtool get_ts_info operation, which enables
access of available timestamp/timesync support for that device. It can query
which ptp clock device is associated with the particular port.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   41 ++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 082446d..3178f1e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2696,6 +2696,46 @@ static int ixgbe_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return ret;
 }
 
+static int ixgbe_get_ts_info(struct net_device *dev,
+			     struct ethtool_ts_info *info)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	switch (adapter->hw.mac.type) {
+#ifdef CONFIG_IXGBE_PTP
+	case ixgbe_mac_X540:
+	case ixgbe_mac_82599EB:
+		info->so_timestamping =
+			SOF_TIMESTAMPING_TX_HARDWARE |
+			SOF_TIMESTAMPING_RX_HARDWARE |
+			SOF_TIMESTAMPING_RAW_HARDWARE;
+
+		if (adapter->ptp_clock)
+			info->phc_index = ptp_clock_index(adapter->ptp_clock);
+		else
+			info->phc_index = -1;
+
+		info->tx_types =
+			(1 << HWTSTAMP_TX_OFF) |
+			(1 << HWTSTAMP_TX_ON);
+
+		info->rx_filters =
+			(1 << HWTSTAMP_FILTER_NONE) |
+			(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+			(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
+			(1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
+			(1 << HWTSTAMP_FILTER_SOME);
+		break;
+#endif /* CONFIG_IXGBE_PTP */
+	default:
+		return ethtool_op_get_ts_info(dev, info);
+		break;
+	}
+	return 0;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2724,6 +2764,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_rxnfc		= ixgbe_get_rxnfc,
 	.set_rxnfc		= ixgbe_set_rxnfc,
+	.get_ts_info		= ixgbe_get_ts_info,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.7.6
