From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v8 7/7] ixgbevf: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Wed, 25 Mar 2015 19:42:42 +0200
Message-ID: <1427305362-23948-8-git-send-email-vladz@cloudius-systems.com>
References: <1427305362-23948-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com, intel-wired-lan@lists.osuosl.org,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35657 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbbCYRnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 13:43:00 -0400
Received: by wibbg6 with SMTP id bg6so34127324wib.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 10:42:59 -0700 (PDT)
In-Reply-To: <1427305362-23948-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops callbacks
implementations.

This enables the ethtool's "-x" and "--show-rxfh[-indir]" options for VF devices.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v6:
   - Added a required get_rxnfc callback to ixgbevf_ethtool_ops.

New in v4:
   - Removed not needed braces in if-statement in ixgbevf_get_rxfh_indir_size().

New in v3:
   - Added a proper support for x550 devices: return the correct redirection table size.

New in v2:
   - Added a detailed description to the patch.
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 58 ++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index e83c85b..7cb4008 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -794,6 +794,60 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
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
+	if (adapter->hw.mac.type >= ixgbe_mac_X550_vf)
+		return 64;
+	else
+		return 128;
+}
+
+static u32 ixgbevf_get_rxfh_key_size(struct net_device *netdev)
+{
+	return 40;
+}
+
+static int ixgbevf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
+			    u8 *hfunc)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	int err;
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+
+	if (indir) {
+		err = ixgbevf_get_reta(adapter, indir);
+		if (err)
+			return err;
+	}
+
+	if (key) {
+		err = ixgbevf_get_rss_key(adapter, key);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_settings		= ixgbevf_get_settings,
 	.get_drvinfo		= ixgbevf_get_drvinfo,
@@ -811,6 +865,10 @@ static const struct ethtool_ops ixgbevf_ethtool_ops = {
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
