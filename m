From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH v2 09/10] ixgbe: Add support for displaying the number
 of Tx/Rx channels
Date: Thu, 10 Jan 2013 10:58:41 -0800
Message-ID: <20130110185835.29578.88663.stgit@ahduyck-cp1.jf.intel.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com, ycai@google.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7969 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754214Ab3AJTAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 14:00:15 -0500
In-Reply-To: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the ethtool get_channels operation.

Since the ixgbe driver has to support DCB as well as the other modes the
assumption I made here is that the number of channels in DCB modes refers
to the number of queues per traffic class, not the number of queues total.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   72 ++++++++++++++++++++++
 1 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 3268584..688effc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2704,6 +2704,77 @@ static int ixgbe_get_ts_info(struct net_device *dev,
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
@@ -2733,6 +2804,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_rxnfc		= ixgbe_get_rxnfc,
 	.set_rxnfc		= ixgbe_set_rxnfc,
 	.get_ts_info		= ixgbe_get_ts_info,
+	.get_channels		= ixgbe_get_channels,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
