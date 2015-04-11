From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] ixgbe: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Sat, 11 Apr 2015 12:07:49 -0700
Message-ID: <1428779276-22523-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32506 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755383AbbDKTH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 15:07:59 -0400
In-Reply-To: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Zolotarov <vladz@cloudius-systems.com>

Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops
callbacks implementations.

This enables the ethtool's "-x" and "--show-rxfh[-indir]" options.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 42 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  2 +-
 3 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index d13ab87..d3d27ec 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -964,4 +964,5 @@ void ixgbe_sriov_reinit(struct ixgbe_adapter *adapter);
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 				  struct ixgbe_adapter *adapter,
 				  struct ixgbe_ring *tx_ring);
+u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter);
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index ccaecb1..eafa9ec 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2853,6 +2853,45 @@ static int ixgbe_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return ret;
 }
 
+static u32 ixgbe_get_rxfh_key_size(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	return sizeof(adapter->rss_key);
+}
+
+static u32 ixgbe_rss_indir_size(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	return ixgbe_rss_indir_tbl_entries(adapter);
+}
+
+static void ixgbe_get_reta(struct ixgbe_adapter *adapter, u32 *indir)
+{
+	int i, reta_size = ixgbe_rss_indir_tbl_entries(adapter);
+
+	for (i = 0; i < reta_size; i++)
+		indir[i] = adapter->rss_indir_tbl[i];
+}
+
+static int ixgbe_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
+			  u8 *hfunc)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+
+	if (indir)
+		ixgbe_get_reta(adapter, indir);
+
+	if (key)
+		memcpy(key, adapter->rss_key, ixgbe_get_rxfh_key_size(netdev));
+
+	return 0;
+}
+
 static int ixgbe_get_ts_info(struct net_device *dev,
 			     struct ethtool_ts_info *info)
 {
@@ -3110,6 +3149,9 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_rxnfc		= ixgbe_get_rxnfc,
 	.set_rxnfc		= ixgbe_set_rxnfc,
+	.get_rxfh_indir_size	= ixgbe_rss_indir_size,
+	.get_rxfh_key_size	= ixgbe_get_rxfh_key_size,
+	.get_rxfh		= ixgbe_get_rxfh,
 	.get_channels		= ixgbe_get_channels,
 	.set_channels		= ixgbe_set_channels,
 	.get_ts_info		= ixgbe_get_ts_info,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 57a3ec4..fb096dd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3237,7 +3237,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
  *  - X550(non-SRIOV mode): 512
  *  - X550(SRIOV mode):     64
  */
-static u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter)
+u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter)
 {
 	if (adapter->hw.mac.type < ixgbe_mac_X550)
 		return 128;
-- 
1.9.3
