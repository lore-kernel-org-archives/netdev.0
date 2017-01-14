From: yuan linyu <cugyly@163.com>
Subject: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Sat, 14 Jan 2017 10:46:31 +0800
Message-ID: <1484361992-30591-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:33109 "EHLO m50-132.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751364AbdANCrE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 21:47:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

if phy device have register(s) configuration problem,
user can use this attribute to diagnose.
this feature need phy driver maintainer implement.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/net/phy/phy_device.c | 26 ++++++++++++++++++++++++++
 include/linux/phy.h          |  4 ++++
 2 files changed, 30 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 92b0838..a400748 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -617,10 +617,36 @@ phy_has_fixups_show(struct device *dev, struct device_attribute *attr,
 }
 static DEVICE_ATTR_RO(phy_has_fixups);
 
+static ssize_t
+phy_regs_show(struct device *dev, struct device_attribute *attr,
+		    char *buf)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+
+	if (!phydev->drv || !phydev->drv->read_regs)
+		return 0;
+
+	return phydev->drv->read_regs(phydev, buf, PAGE_SIZE);
+}
+
+static ssize_t
+phy_regs_store(struct device *dev, struct device_attribute *attr,
+		    const char *buf, size_t count)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+
+	if (!phydev->drv || !phydev->drv->write_regs)
+		return 0;
+
+	return phydev->drv->write_regs(phydev, buf, count);
+}
+static DEVICE_ATTR_RW(phy_regs);
+
 static struct attribute *phy_dev_attrs[] = {
 	&dev_attr_phy_id.attr,
 	&dev_attr_phy_interface.attr,
 	&dev_attr_phy_has_fixups.attr,
+	&dev_attr_phy_regs.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(phy_dev);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index f7d95f6..c9c4ab3 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -622,6 +622,10 @@ struct phy_driver {
 	int (*set_tunable)(struct phy_device *dev,
 			    struct ethtool_tunable *tuna,
 			    const void *data);
+
+	/* Diagnose PHY register configuration issue from user space */
+	ssize_t (*read_regs)(struct phy_device *dev, char *buf, size_t size);
+	int (*write_regs)(struct phy_device *dev, const char *buf, size_t size);
 };
 #define to_phy_driver(d) container_of(to_mdio_common_driver(d),		\
 				      struct phy_driver, mdiodrv)
-- 
2.7.4
