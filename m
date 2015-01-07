From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v5 7/7] ixgbevf: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Wed,  7 Jan 2015 21:26:42 +0200
Message-ID: <1420658802-18061-8-git-send-email-vladz@cloudius-systems.com>
References: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:50357 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308AbbAGT1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 14:27:05 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so2361473wiw.4
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 11:27:04 -0800 (PST)
In-Reply-To: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops callbacks
implementations.

This enables the ethtool's "-x" and "-n rx-flow-hash" options for 82599 VF devices.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v4:
   - Removed not needed braces in if-statement in ixgbevf_get_rxfh_indir_size().

New in v3:
   - Added a proper support for x550 devices: return the correct redirection table size.

New in v2:
   - Added a detailed description to the patch.
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 42 ++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index cc0e5b7..ddf2d82 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -792,6 +792,45 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
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
+		err = ixgbevf_get_reta(&adapter->hw, indir);
+		if (err)
+			return err;
+	}
+
+	if (key) {
+		err = ixgbevf_get_rss_key(&adapter->hw, key);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_settings           = ixgbevf_get_settings,
 	.get_drvinfo            = ixgbevf_get_drvinfo,
@@ -809,6 +848,9 @@ static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_ethtool_stats      = ixgbevf_get_ethtool_stats,
 	.get_coalesce           = ixgbevf_get_coalesce,
 	.set_coalesce           = ixgbevf_set_coalesce,
+	.get_rxfh_indir_size    = ixgbevf_get_rxfh_indir_size,
+	.get_rxfh_key_size      = ixgbevf_get_rxfh_key_size,
+	.get_rxfh		= ixgbevf_get_rxfh,
 };
 
 void ixgbevf_set_ethtool_ops(struct net_device *netdev)
-- 
2.1.0
