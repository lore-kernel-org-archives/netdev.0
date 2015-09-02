From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/19] ixgbe: support for ethtool set_rxfh
Date: Tue,  1 Sep 2015 18:13:59 -0700
Message-ID: <1441156443-33381-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tom Barbette <tom.barbette@ulg.ac.be>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59618 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754615AbbIBBON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:13 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Barbette <tom.barbette@ulg.ac.be>

Allows to change the rxfh indirection table and/or key using
ethtool interface.

Signed-off-by: Tom Barbette <tom.barbette@ulg.ac.be>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 47 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  2 +-
 3 files changed, 49 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8830c0f..edf1fb9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -973,4 +973,5 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 				  struct ixgbe_adapter *adapter,
 				  struct ixgbe_ring *tx_ring);
 u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter);
+void ixgbe_store_reta(struct ixgbe_adapter *adapter);
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index f7aeb56..b0cc439 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2868,6 +2868,14 @@ static int ixgbe_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return ret;
 }
 
+static int ixgbe_rss_indir_tbl_max(struct ixgbe_adapter *adapter)
+{
+	if (adapter->hw.mac.type < ixgbe_mac_X550)
+		return 16;
+	else
+		return 64;
+}
+
 static u32 ixgbe_get_rxfh_key_size(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -2907,6 +2915,44 @@ static int ixgbe_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 	return 0;
 }
 
+static int ixgbe_set_rxfh(struct net_device *netdev, const u32 *indir,
+			  const u8 *key, const u8 hfunc)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int i;
+	u32 reta_entries = ixgbe_rss_indir_tbl_entries(adapter);
+
+	if (hfunc)
+		return -EINVAL;
+
+	/* Fill out the redirection table */
+	if (indir) {
+		int max_queues = min_t(int, adapter->num_rx_queues,
+				       ixgbe_rss_indir_tbl_max(adapter));
+
+		/*Allow at least 2 queues w/ SR-IOV.*/
+		if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) &&
+		    (max_queues < 2))
+			max_queues = 2;
+
+		/* Verify user input. */
+		for (i = 0; i < reta_entries; i++)
+			if (indir[i] >= max_queues)
+				return -EINVAL;
+
+		for (i = 0; i < reta_entries; i++)
+			adapter->rss_indir_tbl[i] = indir[i];
+	}
+
+	/* Fill out the rss hash key */
+	if (key)
+		memcpy(adapter->rss_key, key, ixgbe_get_rxfh_key_size(netdev));
+
+	ixgbe_store_reta(adapter);
+
+	return 0;
+}
+
 static int ixgbe_get_ts_info(struct net_device *dev,
 			     struct ethtool_ts_info *info)
 {
@@ -3159,6 +3205,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_rxfh_indir_size	= ixgbe_rss_indir_size,
 	.get_rxfh_key_size	= ixgbe_get_rxfh_key_size,
 	.get_rxfh		= ixgbe_get_rxfh,
+	.set_rxfh		= ixgbe_set_rxfh,
 	.get_channels		= ixgbe_get_channels,
 	.set_channels		= ixgbe_set_channels,
 	.get_ts_info		= ixgbe_get_ts_info,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7389c96..afdc7fb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3313,7 +3313,7 @@ u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter)
  *
  * Write the RSS redirection table stored in adapter.rss_indir_tbl[] to HW.
  */
-static void ixgbe_store_reta(struct ixgbe_adapter *adapter)
+void ixgbe_store_reta(struct ixgbe_adapter *adapter)
 {
 	u32 i, reta_entries = ixgbe_rss_indir_tbl_entries(adapter);
 	struct ixgbe_hw *hw = &adapter->hw;
-- 
2.4.3
