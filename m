From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 14/24] phy_device: Move phy attributes into phy_device
Date: Mon,  4 Jan 2016 18:36:52 +0100
Message-ID: <1451929022-5580-15-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35006 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753089AbcADRjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:39:14 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mdio_bus exports three attributes. However these are all phy
attributes, not generic mdio attributes. So move the attributes into
the phy device code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/mdio_bus.c   | 42 ------------------------------------------
 drivers/net/phy/phy_device.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+), 42 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index f28f89e109ba..e6dddb086265 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -670,52 +670,10 @@ static const struct dev_pm_ops mdio_bus_pm_ops = {
 
 #endif /* CONFIG_PM */
 
-static ssize_t
-phy_id_show(struct device *dev, struct device_attribute *attr, char *buf)
-{
-	struct phy_device *phydev = to_phy_device(dev);
-
-	return sprintf(buf, "0x%.8lx\n", (unsigned long)phydev->phy_id);
-}
-static DEVICE_ATTR_RO(phy_id);
-
-static ssize_t
-phy_interface_show(struct device *dev, struct device_attribute *attr, char *buf)
-{
-	struct phy_device *phydev = to_phy_device(dev);
-	const char *mode = NULL;
-
-	if (phy_is_internal(phydev))
-		mode = "internal";
-	else
-		mode = phy_modes(phydev->interface);
-
-	return sprintf(buf, "%s\n", mode);
-}
-static DEVICE_ATTR_RO(phy_interface);
-
-static ssize_t
-phy_has_fixups_show(struct device *dev, struct device_attribute *attr, char *buf)
-{
-	struct phy_device *phydev = to_phy_device(dev);
-
-	return sprintf(buf, "%d\n", phydev->has_fixups);
-}
-static DEVICE_ATTR_RO(phy_has_fixups);
-
-static struct attribute *mdio_dev_attrs[] = {
-	&dev_attr_phy_id.attr,
-	&dev_attr_phy_interface.attr,
-	&dev_attr_phy_has_fixups.attr,
-	NULL,
-};
-ATTRIBUTE_GROUPS(mdio_dev);
-
 struct bus_type mdio_bus_type = {
 	.name		= "mdio_bus",
 	.match		= mdio_bus_match,
 	.pm		= MDIO_BUS_PM_OPS,
-	.dev_groups	= mdio_dev_groups,
 };
 EXPORT_SYMBOL(mdio_bus_type);
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 37fc8d6269ec..4dd42f75a0d2 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -376,6 +376,48 @@ struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45)
 }
 EXPORT_SYMBOL(get_phy_device);
 
+static ssize_t
+phy_id_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+
+	return sprintf(buf, "0x%.8lx\n", (unsigned long)phydev->phy_id);
+}
+static DEVICE_ATTR_RO(phy_id);
+
+static ssize_t
+phy_interface_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+	const char *mode = NULL;
+
+	if (phy_is_internal(phydev))
+		mode = "internal";
+	else
+		mode = phy_modes(phydev->interface);
+
+	return sprintf(buf, "%s\n", mode);
+}
+static DEVICE_ATTR_RO(phy_interface);
+
+static ssize_t
+phy_has_fixups_show(struct device *dev, struct device_attribute *attr,
+		    char *buf)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+
+	return sprintf(buf, "%d\n", phydev->has_fixups);
+}
+static DEVICE_ATTR_RO(phy_has_fixups);
+
+static struct attribute *phy_dev_attrs[] = {
+	&dev_attr_phy_id.attr,
+	&dev_attr_phy_interface.attr,
+	&dev_attr_phy_has_fixups.attr,
+	NULL,
+};
+ATTRIBUTE_GROUPS(phy_dev);
+
 /**
  * phy_device_register - Register the phy device on the MDIO bus
  * @phydev: phy_device structure to be added to the MDIO bus
@@ -395,6 +437,8 @@ int phy_device_register(struct phy_device *phydev)
 		goto out;
 	}
 
+	phydev->mdio.dev.groups = phy_dev_groups;
+
 	err = device_add(&phydev->mdio.dev);
 	if (err) {
 		pr_err("PHY %d failed to add\n", phydev->mdio.addr);
-- 
2.6.4
