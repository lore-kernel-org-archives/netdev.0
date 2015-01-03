From: Ed Swierk <eswierk@skyportsystems.com>
Subject: [PATCH] ethtool: Extend ethtool plugin module eeprom API to phylib
Date: Fri,  2 Jan 2015 17:27:56 -0800
Message-ID: <1420248476-110859-1-git-send-email-eswierk@skyportsystems.com>
Cc: f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	Ed Swierk <eswierk@skyportsystems.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch extends the ethtool plugin module eeprom API to support cards
whose phy support is delegated to a separate driver.

The handlers for ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEEEPROM call the
module_info and module_eeprom functions if the phy driver provides them;
otherwise the handlers call the equivalent ethtool_ops functions provided
by network drivers with built-in phy support.

Signed-off-by: Ed Swierk <eswierk@skyportsystems.com>
---
 include/linux/phy.h |  9 +++++++++
 net/core/ethtool.c  | 45 ++++++++++++++++++++++++++++++++++-----------
 2 files changed, 43 insertions(+), 11 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 565188c..04e5f5c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -472,6 +472,15 @@ struct phy_driver {
 	/* See set_wol, but for checking whether Wake on LAN is enabled. */
 	void (*get_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
 
+	/* Get the size and type of the eeprom contained within a plug-in
+	 * module */
+	int (*module_info)(struct phy_device *dev,
+			   struct ethtool_modinfo *modinfo);
+
+	/* Get the eeprom information from the plug-in module */
+	int (*module_eeprom)(struct phy_device *dev,
+			     struct ethtool_eeprom *ee, u8 *data);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 30071de..466526b 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1405,20 +1405,31 @@ static int ethtool_get_ts_info(struct net_device *dev, void __user *useraddr)
 	return err;
 }
 
+static int __ethtool_get_module_info(struct net_device *dev,
+				     struct ethtool_modinfo *modinfo)
+{
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct phy_device *phydev = dev->phydev;
+
+	if (phydev && phydev->drv && phydev->drv->module_info)
+		return phydev->drv->module_info(phydev, modinfo);
+
+	if (ops->get_module_info)
+		return ops->get_module_info(dev, modinfo);
+
+	return -EOPNOTSUPP;
+}
+
 static int ethtool_get_module_info(struct net_device *dev,
 				   void __user *useraddr)
 {
 	int ret;
 	struct ethtool_modinfo modinfo;
-	const struct ethtool_ops *ops = dev->ethtool_ops;
-
-	if (!ops->get_module_info)
-		return -EOPNOTSUPP;
 
 	if (copy_from_user(&modinfo, useraddr, sizeof(modinfo)))
 		return -EFAULT;
 
-	ret = ops->get_module_info(dev, &modinfo);
+	ret = __ethtool_get_module_info(dev, &modinfo);
 	if (ret)
 		return ret;
 
@@ -1428,21 +1439,33 @@ static int ethtool_get_module_info(struct net_device *dev,
 	return 0;
 }
 
+static int __ethtool_get_module_eeprom(struct net_device *dev,
+				       struct ethtool_eeprom *ee, u8 *data)
+{
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct phy_device *phydev = dev->phydev;
+
+	if (phydev && phydev->drv && phydev->drv->module_eeprom)
+		return phydev->drv->module_eeprom(phydev, ee, data);
+
+	if (ops->get_module_eeprom)
+		return ops->get_module_eeprom(dev, ee, data);
+
+	return -EOPNOTSUPP;
+}
+
 static int ethtool_get_module_eeprom(struct net_device *dev,
 				     void __user *useraddr)
 {
 	int ret;
 	struct ethtool_modinfo modinfo;
-	const struct ethtool_ops *ops = dev->ethtool_ops;
-
-	if (!ops->get_module_info || !ops->get_module_eeprom)
-		return -EOPNOTSUPP;
 
-	ret = ops->get_module_info(dev, &modinfo);
+	ret = __ethtool_get_module_info(dev, &modinfo);
 	if (ret)
 		return ret;
 
-	return ethtool_get_any_eeprom(dev, useraddr, ops->get_module_eeprom,
+	return ethtool_get_any_eeprom(dev, useraddr,
+				      __ethtool_get_module_eeprom,
 				      modinfo.eeprom_len);
 }
 
-- 
1.9.1
