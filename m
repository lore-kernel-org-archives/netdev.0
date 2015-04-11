From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbevf: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Sat, 11 Apr 2015 12:07:56 -0700
Message-ID: <1428779276-22523-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15376 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755482AbbDKTIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 15:08:04 -0400
In-Reply-To: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Zolotarov <vladz@cloudius-systems.com>

Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops
callbacks implementations.

This enables the ethtool's "-x" and "--show-rxfh[-indir]" options for VF
devices.

This patch adds the support for 82599 and x540 devices only. Support for
other devices will be added later.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 69 ++++++++++++++++++++++++++++
 1 file changed, 69 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index e83c85b..b2f5b16 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -794,6 +794,71 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static int ixgbevf_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
+			     u32 *rules __always_unused)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(dev);
+
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = adapter->num_rx_queues;
+		return 0;
+	default:
+		hw_dbg(&adapter->hw, "Command parameters not supported\n");
+		return -EOPNOTSUPP;
+	}
+}
+
+static u32 ixgbevf_get_rxfh_indir_size(struct net_device *netdev)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+
+	/* We support this operation only for 82599 and x540 at the moment */
+	if (adapter->hw.mac.type < ixgbe_mac_X550_vf)
+		return IXGBEVF_82599_RETA_SIZE;
+
+	return 0;
+}
+
+static u32 ixgbevf_get_rxfh_key_size(struct net_device *netdev)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+
+	/* We support this operation only for 82599 and x540 at the moment */
+	if (adapter->hw.mac.type < ixgbe_mac_X550_vf)
+		return IXGBEVF_RSS_HASH_KEY_SIZE;
+
+	return 0;
+}
+
+static int ixgbevf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
+			    u8 *hfunc)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	int err = 0;
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+
+	/* If neither indirection table nor hash key was requested - just
+	 * return a success avoiding taking any locks.
+	 */
+	if (!indir && !key)
+		return 0;
+
+	spin_lock_bh(&adapter->mbx_lock);
+	if (indir)
+		err = ixgbevf_get_reta_locked(&adapter->hw, indir,
+					      adapter->num_rx_queues);
+
+	if (!err && key)
+		err = ixgbevf_get_rss_key_locked(&adapter->hw, key);
+
+	spin_unlock_bh(&adapter->mbx_lock);
+
+	return err;
+}
+
 static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_settings		= ixgbevf_get_settings,
 	.get_drvinfo		= ixgbevf_get_drvinfo,
@@ -811,6 +876,10 @@ static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_ethtool_stats	= ixgbevf_get_ethtool_stats,
 	.get_coalesce		= ixgbevf_get_coalesce,
 	.set_coalesce		= ixgbevf_set_coalesce,
+	.get_rxnfc		= ixgbevf_get_rxnfc,
+	.get_rxfh_indir_size	= ixgbevf_get_rxfh_indir_size,
+	.get_rxfh_key_size	= ixgbevf_get_rxfh_key_size,
+	.get_rxfh		= ixgbevf_get_rxfh,
 };
 
 void ixgbevf_set_ethtool_ops(struct net_device *netdev)
-- 
1.9.3
