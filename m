From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v10 7/7] ixgbevf: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Mon, 30 Mar 2015 21:35:29 +0300
Message-ID: <1427740529-9605-8-git-send-email-vladz@cloudius-systems.com>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34855 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbbC3Sfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 14:35:48 -0400
Received: by wicne17 with SMTP id ne17so41683757wic.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 11:35:47 -0700 (PDT)
In-Reply-To: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops callbacks
implementations.

This enables the ethtool's "-x" and "--show-rxfh[-indir]" options for VF devices.

This patch adds the support for 82599 and x540 devices only. Support for other
devices will be added later.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v10:
   - Move the mailbox locks outside the vf.c functions.
   - Use IXGBEVF_82599_RETA_SIZE macro.

New in v9:
   - Use IXGBEVF_RSS_HASH_KEY_SIZE macro.

New in v6:
   - Added a required get_rxnfc callback to ixgbevf_ethtool_ops.

New in v4:
   - Removed not needed braces in if-statement in ixgbevf_get_rxfh_indir_size().

New in v3:
   - Added a proper support for x550 devices: return the correct redirection table size.

New in v2:
   - Added a detailed description to the patch.
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
2.1.0
