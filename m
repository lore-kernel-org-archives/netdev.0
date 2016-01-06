From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 14/22] phy_device: Move phy attributes into phy_device
Date: Wed,  6 Jan 2016 20:11:19 +0100
Message-ID: <1452107487-475-15-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42393 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959AbcAFTOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:14:20 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mdio_bus exports three attributes:

- PHY ID is the unique 32-bits identifier for a MDIO device implementing
  standard MII registers MII_PHYSID1/2, which is not guaranteed to be the
  case for non-standard compliant devices (e.g: Ethernet switches)

- PHY interface describes the data-path of the PHY/MDIO device, which is
  not strictly a PHY thing, but is required and needed for PHY devices to
  function, a MDIO device could be a control device exclusively

- PHY has fixups describes what the PHY driver may have done, so
  completely PHY specific

These are all phy attributes, not generic mdio attributes. So move the
attributes into the phy device code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
v2: Updated commit log based on Florians suggestion
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
index e0d5dbb96700..7a5222daff93 100644
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
