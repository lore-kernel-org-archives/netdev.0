From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] ethtool: consolidate work with ethtool_ops
Date: Mon,  7 Jan 2013 13:26:14 +0100
Message-ID: <1357561574-14255-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	richardcochran@gmail.com, greearb@candelatech.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:64605 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab3AGMeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 07:34:13 -0500
Received: by mail-we0-f180.google.com with SMTP id t57so9806796wey.11
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 04:34:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to check if ethtool_ops == NULL since it can't be.
Use local variable "ops" in functions where it is present
instead of dev->ethtool_ops
Introduce local variable "ops" in functions where dev->ethtool_ops is used
many times.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/ethtool.c | 45 +++++++++++++++++++++------------------------
 1 file changed, 21 insertions(+), 24 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a870543..08c213e 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -175,7 +175,7 @@ static int __ethtool_get_sset_count(struct net_device *dev, int sset)
 	if (sset == ETH_SS_FEATURES)
 		return ARRAY_SIZE(netdev_features_strings);
 
-	if (ops && ops->get_sset_count && ops->get_strings)
+	if (ops->get_sset_count && ops->get_strings)
 		return ops->get_sset_count(dev, sset);
 	else
 		return -EOPNOTSUPP;
@@ -311,7 +311,7 @@ int __ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	ASSERT_RTNL();
 
-	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
+	if (!dev->ethtool_ops->get_settings)
 		return -EOPNOTSUPP;
 
 	memset(cmd, 0, sizeof(struct ethtool_cmd));
@@ -355,7 +355,7 @@ static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev,
 
 	memset(&info, 0, sizeof(info));
 	info.cmd = ETHTOOL_GDRVINFO;
-	if (ops && ops->get_drvinfo) {
+	if (ops->get_drvinfo) {
 		ops->get_drvinfo(dev, &info);
 	} else if (dev->dev.parent && dev->dev.parent->driver) {
 		strlcpy(info.bus_info, dev_name(dev->dev.parent),
@@ -370,7 +370,7 @@ static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev,
 	 * this method of obtaining string set info is deprecated;
 	 * Use ETHTOOL_GSSET_INFO instead.
 	 */
-	if (ops && ops->get_sset_count) {
+	if (ops->get_sset_count) {
 		int rc;
 
 		rc = ops->get_sset_count(dev, ETH_SS_TEST);
@@ -383,9 +383,9 @@ static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev,
 		if (rc >= 0)
 			info.n_priv_flags = rc;
 	}
-	if (ops && ops->get_regs_len)
+	if (ops->get_regs_len)
 		info.regdump_len = ops->get_regs_len(dev);
-	if (ops && ops->get_eeprom_len)
+	if (ops->get_eeprom_len)
 		info.eedump_len = ops->get_eeprom_len(dev);
 
 	if (copy_to_user(useraddr, &info, sizeof(info)))
@@ -590,13 +590,14 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 	struct ethtool_rxnfc rx_rings;
 	u32 user_size, dev_size, i;
 	u32 *indir;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
 	int ret;
 
-	if (!dev->ethtool_ops->get_rxfh_indir_size ||
-	    !dev->ethtool_ops->set_rxfh_indir ||
-	    !dev->ethtool_ops->get_rxnfc)
+	if (!ops->get_rxfh_indir_size || !ops->set_rxfh_indir ||
+	    !ops->get_rxnfc)
 		return -EOPNOTSUPP;
-	dev_size = dev->ethtool_ops->get_rxfh_indir_size(dev);
+
+	dev_size = ops->get_rxfh_indir_size(dev);
 	if (dev_size == 0)
 		return -EOPNOTSUPP;
 
@@ -613,7 +614,7 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 		return -ENOMEM;
 
 	rx_rings.cmd = ETHTOOL_GRXRINGS;
-	ret = dev->ethtool_ops->get_rxnfc(dev, &rx_rings, NULL);
+	ret = ops->get_rxnfc(dev, &rx_rings, NULL);
 	if (ret)
 		goto out;
 
@@ -639,7 +640,7 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 		}
 	}
 
-	ret = dev->ethtool_ops->set_rxfh_indir(dev, indir);
+	ret = ops->set_rxfh_indir(dev, indir);
 
 out:
 	kfree(indir);
@@ -1082,9 +1083,10 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_value id;
 	static bool busy;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
 	int rc;
 
-	if (!dev->ethtool_ops->set_phys_id)
+	if (ops->set_phys_id)
 		return -EOPNOTSUPP;
 
 	if (busy)
@@ -1093,7 +1095,7 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 	if (copy_from_user(&id, useraddr, sizeof(id)))
 		return -EFAULT;
 
-	rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ACTIVE);
+	rc = ops->set_phys_id(dev, ETHTOOL_ID_ACTIVE);
 	if (rc < 0)
 		return rc;
 
@@ -1118,7 +1120,7 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 			i = n;
 			do {
 				rtnl_lock();
-				rc = dev->ethtool_ops->set_phys_id(dev,
+				rc = ops->set_phys_id(dev,
 				    (i & 1) ? ETHTOOL_ID_OFF : ETHTOOL_ID_ON);
 				rtnl_unlock();
 				if (rc)
@@ -1133,7 +1135,7 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 	dev_put(dev);
 	busy = false;
 
-	(void)dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_INACTIVE);
+	(void) ops->set_phys_id(dev, ETHTOOL_ID_INACTIVE);
 	return rc;
 }
 
@@ -1275,7 +1277,7 @@ static int ethtool_get_dump_flag(struct net_device *dev,
 	struct ethtool_dump dump;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 
-	if (!dev->ethtool_ops->get_dump_flag)
+	if (!ops->get_dump_flag)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&dump, useraddr, sizeof(dump)))
@@ -1299,8 +1301,7 @@ static int ethtool_get_dump_data(struct net_device *dev,
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	void *data = NULL;
 
-	if (!dev->ethtool_ops->get_dump_data ||
-		!dev->ethtool_ops->get_dump_flag)
+	if (!ops->get_dump_data || !ops->get_dump_flag)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&dump, useraddr, sizeof(dump)))
@@ -1346,13 +1347,9 @@ static int ethtool_get_ts_info(struct net_device *dev, void __user *useraddr)
 	info.cmd = ETHTOOL_GET_TS_INFO;
 
 	if (phydev && phydev->drv && phydev->drv->ts_info) {
-
 		err = phydev->drv->ts_info(phydev, &info);
-
-	} else if (dev->ethtool_ops && dev->ethtool_ops->get_ts_info) {
-
+	} else if (ops->get_ts_info) {
 		err = ops->get_ts_info(dev, &info);
-
 	} else {
 		info.so_timestamping =
 			SOF_TIMESTAMPING_RX_SOFTWARE |
-- 
1.8.1
