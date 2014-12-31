From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v2 5/5] ixgbevf: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Wed, 31 Dec 2014 19:40:39 +0200
Message-ID: <1420047639-10862-6-git-send-email-vladz@cloudius-systems.com>
References: <1420047639-10862-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:64755 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbaLaRk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 12:40:59 -0500
Received: by mail-wg0-f44.google.com with SMTP id b13so22308877wgh.3
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 09:40:58 -0800 (PST)
In-Reply-To: <1420047639-10862-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops callbacks
implementations.

This enables the ethtool's "-x" and "-n rx-flow-hash" options for 82599 VF devices.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v2:
   - Added a detailed description to the patch.
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 37 ++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index cc0e5b7..255bbc8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -792,6 +792,40 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static u32 ixgbevf_get_rxfh_indir_size(struct net_device *netdev)
+{
+	return 128;
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
@@ -809,6 +843,9 @@ static const struct ethtool_ops ixgbevf_ethtool_ops = {
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
