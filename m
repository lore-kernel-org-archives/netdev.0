From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH v2 10/10] ixgbe: Add support for set_channels ethtool
 operation
Date: Thu, 10 Jan 2013 10:58:52 -0800
Message-ID: <20130110185846.29578.94872.stgit@ahduyck-cp1.jf.intel.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com, ycai@google.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26337 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754214Ab3AJTA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 14:00:28 -0500
In-Reply-To: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds support for the ethtool set_channels operation.

Since the ixgbe driver has to support DCB as well as the other modes the
assumption I made here is that the number of channels in DCB modes refers
to the number of queues per traffic class, not the number of queues total.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   40 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    7 +++-
 3 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 590f042..a431628 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -695,8 +695,8 @@ extern bool ixgbe_verify_lesm_fw_enabled_82599(struct ixgbe_hw *hw);
 extern void ixgbe_set_rx_mode(struct net_device *netdev);
 #ifdef CONFIG_IXGBE_DCB
 extern void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter);
-extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 #endif
+extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 extern void ixgbe_tx_ctxtdesc(struct ixgbe_ring *, u32, u32, u32, u32);
 extern void ixgbe_do_reset(struct net_device *netdev);
 #ifdef CONFIG_IXGBE_HWMON
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 688effc..31998a3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2775,6 +2775,45 @@ static void ixgbe_get_channels(struct net_device *dev,
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
@@ -2805,6 +2844,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_rxnfc		= ixgbe_set_rxnfc,
 	.get_ts_info		= ixgbe_get_ts_info,
 	.get_channels		= ixgbe_get_channels,
+	.set_channels		= ixgbe_set_channels,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4c0bcd8..798bbf6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6796,6 +6796,7 @@ static void ixgbe_set_prio_tc_map(struct ixgbe_adapter *adapter)
 	}
 }
 
+#endif /* CONFIG_IXGBE_DCB */
 /**
  * ixgbe_setup_tc - configure net_device for multiple traffic classes
  *
@@ -6821,6 +6822,7 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 		ixgbe_close(dev);
 	ixgbe_clear_interrupt_scheme(adapter);
 
+#ifdef CONFIG_IXGBE_DCB
 	if (tc) {
 		netdev_set_num_tc(dev, tc);
 		ixgbe_set_prio_tc_map(adapter);
@@ -6843,15 +6845,16 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 		adapter->dcb_cfg.pfc_mode_enable = false;
 	}
 
-	ixgbe_init_interrupt_scheme(adapter);
 	ixgbe_validate_rtr(adapter, tc);
+
+#endif /* CONFIG_IXGBE_DCB */
+	ixgbe_init_interrupt_scheme(adapter);
 	if (netif_running(dev))
 		ixgbe_open(dev);
 
 	return 0;
 }
 
-#endif /* CONFIG_IXGBE_DCB */
 void ixgbe_do_reset(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
