From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] ixgbe: Add support for displaying the number of Tx/Rx channels
Date: Sat, 16 Feb 2013 00:33:30 -0800
Message-ID: <1361003616-3422-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486Ab3BPIdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:47 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for the ethtool get_channels operation.

Since the ixgbe driver has to support DCB as well as the other modes the
assumption I made here is that the number of channels in DCB modes refers
to the number of queues per traffic class, not the number of queues total.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 72 ++++++++++++++++++++++++
 1 file changed, 72 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index db67359..cba27c6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2731,6 +2731,77 @@ static int ixgbe_get_ts_info(struct net_device *dev,
 	return 0;
 }
 
+static unsigned int ixgbe_max_channels(struct ixgbe_adapter *adapter)
+{
+	unsigned int max_combined;
+	u8 tcs = netdev_get_num_tc(adapter->netdev);
+
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
+		/* We only support one q_vector without MSI-X */
+		max_combined = 1;
+	} else if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		/* SR-IOV currently only allows one queue on the PF */
+		max_combined = 1;
+	} else if (tcs > 1) {
+		/* For DCB report channels per traffic class */
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+			/* 8 TC w/ 4 queues per TC */
+			max_combined = 4;
+		} else if (tcs > 4) {
+			/* 8 TC w/ 8 queues per TC */
+			max_combined = 8;
+		} else {
+			/* 4 TC w/ 16 queues per TC */
+			max_combined = 16;
+		}
+	} else if (adapter->atr_sample_rate) {
+		/* support up to 64 queues with ATR */
+		max_combined = IXGBE_MAX_FDIR_INDICES;
+	} else {
+		/* support up to 16 queues with RSS */
+		max_combined = IXGBE_MAX_RSS_INDICES;
+	}
+
+	return max_combined;
+}
+
+static void ixgbe_get_channels(struct net_device *dev,
+			       struct ethtool_channels *ch)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	/* report maximum channels */
+	ch->max_combined = ixgbe_max_channels(adapter);
+
+	/* report info for other vector */
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		ch->max_other = NON_Q_VECTORS;
+		ch->other_count = NON_Q_VECTORS;
+	}
+
+	/* record RSS queues */
+	ch->combined_count = adapter->ring_feature[RING_F_RSS].indices;
+
+	/* nothing else to report if RSS is disabled */
+	if (ch->combined_count == 1)
+		return;
+
+	/* we do not support ATR queueing if SR-IOV is enabled */
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		return;
+
+	/* same thing goes for being DCB enabled */
+	if (netdev_get_num_tc(dev) > 1)
+		return;
+
+	/* if ATR is disabled we can exit */
+	if (!adapter->atr_sample_rate)
+		return;
+
+	/* report flow director queues as maximum channels */
+	ch->combined_count = adapter->ring_feature[RING_F_FDIR].indices;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2759,6 +2830,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_rxnfc		= ixgbe_get_rxnfc,
 	.set_rxnfc		= ixgbe_set_rxnfc,
+	.get_channels		= ixgbe_get_channels,
 	.get_ts_info		= ixgbe_get_ts_info,
 };
 
-- 
1.7.11.7
