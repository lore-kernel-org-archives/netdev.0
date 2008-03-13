From: Nate Case <ncase@xes-inc.com>
Subject: Re: [Pasemi-linux] I2C MDIO support for pasemi_mac driver
Date: Thu, 13 Mar 2008 16:57:53 -0500
Message-ID: <1205445473.8864.171.camel@localhost.localdomain>
References: <1204911643.8864.15.camel@localhost.localdomain>
	 <20080307183738.GA22366@lixom.net>  <20080307184854.GA23402@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pasemi-linux@ozlabs.org,
	afleming@freescale.com
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:50771 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754453AbYCMV6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2008 17:58:24 -0400
In-Reply-To: <20080307184854.GA23402@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-03-07 at 12:48 -0600, Olof Johansson wrote:
> On second thought, it might be a better idea to change from BUS:ID to
> BUSTYPE:BUS:ID in phylib, to separate the namespaces.
> 
> That, plus a way to get to an i2c bus number from a device tree node,
> and we should be all set. That might be tricker though.

This turned out to not be as invasive of a change as I thought.  Here's
my first attempt at it.  The changes to pasemi_mac are based on your
first patch but modified accordingly for the new bus type field.

Comments are welcome.  Patch is against 2.6.23 for now (though I
wouldn't expect any of these areas to have changed much since then).
After I get some feedback I can rebase against the latest netdev and do
a formal submission.

- Nate Case <ncase@xes-inc.com>

---
 arch/powerpc/platforms/pasemi/gpio_mdio.c |    1 +
 drivers/net/gianfar.c                     |    3 +-
 drivers/net/pasemi_mac.c                  |   58 ++++++++++++++++++++++++++---
 drivers/net/phy/mdio_bus.c                |    3 +-
 drivers/net/ucc_geth.c                    |    4 +-
 include/linux/phy.h                       |    7 ++-
 6 files changed, 64 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index 098450e..37fa0f5 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -239,6 +239,7 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 	new_bus->read = &gpio_mdio_read;
 	new_bus->write = &gpio_mdio_write;
 	new_bus->reset = &gpio_mdio_reset;
+	new_bus->type = "pas_gpio";
 
 	prop = of_get_property(np, "reg", NULL);
 	new_bus->id = *prop;
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f926905..dad8703 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -458,7 +458,8 @@ static int init_phy(struct net_device *dev)
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->einfo->bus_id, priv->einfo->phy_id);
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, "gfar", priv->einfo->bus_id,
+			priv->einfo->phy_id);
 
 	interface = gfar_get_interface(dev);
 
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 79d277f..6322215 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -181,6 +181,37 @@ static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
 	return 0;
 }
 
+/*
+ * Return the "index number" of an OF device node name.  This is for the
+ * node names of the format <device name>@<address>,<index #>
+ * (e.g., "serial@1d,1" or "i2c@1c,2").  If no index exists, 0 is
+ * returned.
+ */
+static int of_get_node_devindex(struct device_node *node)
+{
+	int i, at_index = -1, comma_index = -1;
+
+	i = strlen(node->full_name);
+	while (i > 0) {
+		if (node->full_name[i-1] == '/')
+			return 0;
+
+		if (node->full_name[i-1] == '@') {
+			at_index = i - 1;
+			break;
+		}
+
+		if (node->full_name[i-1] == ',')
+			comma_index = i -1;
+
+		i--;
+	}
+
+	if (at_index == -1 || comma_index == -1)
+		return 0;
+	
+	return simple_strtoul(&(node->full_name[comma_index+1]), NULL, 16);
+}
 
 static int mac_to_intf(const struct pasemi_mac *mac)
 {
@@ -969,9 +1000,10 @@ static int pasemi_mac_phy_init(struct net_device *dev)
 	struct pasemi_mac *mac = netdev_priv(dev);
 	struct device_node *dn, *phy_dn;
 	struct phy_device *phydev;
-	unsigned int phy_id;
+	unsigned int phy_id, bus_id;
 	const phandle *ph;
 	const unsigned int *prop;
+	const char *type;
 	struct resource r;
 	int ret;
 
@@ -982,12 +1014,26 @@ static int pasemi_mac_phy_init(struct net_device *dev)
 	phy_dn = of_find_node_by_phandle(*ph);
 
 	prop = of_get_property(phy_dn, "reg", NULL);
-	ret = of_address_to_resource(phy_dn->parent, 0, &r);
-	if (ret)
-		goto err;
+	phy_id = *prop & (PHY_MAX_ADDR - 1);
+	if (of_device_is_compatible(phy_dn->parent, "gpio-mdio")) {
+		ret = of_address_to_resource(phy_dn->parent, 0, &r);
+		if (ret)
+			goto err;
+
+		bus_id = (int)r.start;
+		type = "pas_gpio";
+	} else if (phy_dn->parent->type && !strcmp(phy_dn->parent->type,
+			"i2c")) {
+		/* PHY is on smbus.  Bus ID matches I2C bus number.*/
+		bus_id = of_get_node_devindex(phy_dn->parent);
+		type = "i2c";
+	} else {
+		printk("Unknown PHY device in device tree\n");
+		bus_id = -1;
+		type = "unknown";
+	}
 
-	phy_id = *prop;
-	snprintf(mac->phy_id, BUS_ID_SIZE, PHY_ID_FMT, (int)r.start, phy_id);
+	snprintf(mac->phy_id, BUS_ID_SIZE, PHY_ID_FMT, type, bus_id, phy_id);
 
 	of_node_put(phy_dn);
 
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index a0a706e..d873c5e 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -84,7 +84,8 @@ int mdiobus_register(struct mii_bus *bus)
 
 			phydev->dev.parent = bus->dev;
 			phydev->dev.bus = &mdio_bus_type;
-			snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, i);
+			snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT,
+					bus->type, bus->id, i);
 
 			phydev->bus = bus;
 
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 9a38dfe..1ea20d8 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1608,8 +1608,8 @@ static int init_phy(struct net_device *dev)
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->ug_info->mdio_bus,
-			priv->ug_info->phy_address);
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, "ucc_geth",
+			priv->ug_info->mdio_bus, priv->ug_info->phy_address);
 
 	phydev = phy_connect(dev, phy_id, &adjust_link, 0, priv->phy_interface);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 294f4c5..10c59da 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -68,13 +68,16 @@ typedef enum {
 
 #define PHY_MAX_ADDR	32
 
-/* Used when trying to connect to a specific phy (mii bus id:phy device id) */
-#define PHY_ID_FMT "%x:%02x"
+/*
+ * Used when trying to connect to a specific phy:
+ * (mdio bus type:bus id:phy device id) */
+#define PHY_ID_FMT "%s:%x:%02x"
 
 /* The Bus class for PHYs.  Devices which provide access to
  * PHYs should register using this structure */
 struct mii_bus {
 	const char *name;
+	const char *type;
 	int id;
 	void *priv;
 	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
-- 
1.5.3.3



