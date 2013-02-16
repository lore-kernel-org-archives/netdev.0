From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] ixgbe: Add support for set_channels ethtool operation
Date: Sat, 16 Feb 2013 00:33:31 -0800
Message-ID: <1361003616-3422-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14939 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752489Ab3BPIds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:48 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds support for the ethtool set_channels operation.

Since the ixgbe driver has to support DCB as well as the other modes the
assumption I made here is that the number of channels in DCB modes refers
to the number of queues per traffic class, not the number of queues total.

CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 38 ++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index cba27c6..7349a8b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2802,6 +2802,43 @@ static void ixgbe_get_channels(struct net_device *dev,
 	ch->combined_count = adapter->ring_feature[RING_F_FDIR].indices;
 }
 
+static int ixgbe_set_channels(struct net_device *dev,
+			      struct ethtool_channels *ch)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	unsigned int count = ch->combined_count;
+
+	/* verify they are not requesting separate vectors */
+	if (!count || ch->rx_count || ch->tx_count)
+		return -EINVAL;
+
+	/* verify other_count has not changed */
+	if (ch->other_count != NON_Q_VECTORS)
+		return -EINVAL;
+
+	/* verify the number of channels does not exceed hardware limits */
+	if (count > ixgbe_max_channels(adapter))
+		return -EINVAL;
+
+	/* update feature limits from largest to smallest supported values */
+	adapter->ring_feature[RING_F_FDIR].limit = count;
+
+	/* cap RSS limit at 16 */
+	if (count > IXGBE_MAX_RSS_INDICES)
+		count = IXGBE_MAX_RSS_INDICES;
+	adapter->ring_feature[RING_F_RSS].limit = count;
+
+#ifdef IXGBE_FCOE
+	/* cap FCoE limit at 8 */
+	if (count > IXGBE_FCRETA_SIZE)
+		count = IXGBE_FCRETA_SIZE;
+	adapter->ring_feature[RING_F_FCOE].limit = count;
+
+#endif
+	/* use setup TC to update any traffic class queue mapping */
+	return ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2831,6 +2868,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_rxnfc		= ixgbe_get_rxnfc,
 	.set_rxnfc		= ixgbe_set_rxnfc,
 	.get_channels		= ixgbe_get_channels,
+	.set_channels		= ixgbe_set_channels,
 	.get_ts_info		= ixgbe_get_ts_info,
 };
 
-- 
1.7.11.7
