From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 10/10] ixgbe: Add support for set_channels ethtool
	operation
Date: Fri, 29 Jun 2012 17:17:04 -0700
Message-ID: <20120630001704.29939.66556.stgit@gitlad.jf.intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63451 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755693Ab2F3AQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 20:16:45 -0400
In-Reply-To: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds support for the ethtool set_channels operation.

Since the ixgbe driver has to support DCB as well as the other modes the
assumption I made here is that the number of channels in DCB modes refers
to the number of queues per traffic class, not the number of queues total.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   40 ++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 03e369f..ec49afb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2774,6 +2774,45 @@ static void ixgbe_get_channels(struct net_device *dev,
 	ch->combined_count = adapter->ring_feature[RING_F_FDIR].indices;
 }
 
+static int ixgbe_set_channels(struct net_device *dev,
+			      struct ethtool_channels *ch)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	unsigned int count = ch->combined_count;
+
+	/* verify they are not requesting separate vectors */
+	if (ch->rx_count || ch->tx_count)
+		return -EINVAL;
+
+	/* ignore other_count since it is not changeable */
+
+	/* verify we have at least one channel requested */
+	if (!count)
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
@@ -2804,6 +2843,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_rxnfc		= ixgbe_set_rxnfc,
 	.get_ts_info		= ixgbe_get_ts_info,
 	.get_channels		= ixgbe_get_channels,
+	.set_channels		= ixgbe_set_channels,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
