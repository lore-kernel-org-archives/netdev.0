From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 7/7] phy: add phy_device_remove()
Date: Fri, 18 Sep 2015 10:55:27 +0100
Message-ID: <E1ZcsO7-0001G8-JO@rmk-PC.arm.linux.org.uk>
References: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: devicetree@vger.kernel.org, Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Li Yang <leoli@freescale.com>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Robert Richter <rric@kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	"Soren Brinkmann" <soren.brinkmann@xilinx.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a phy_device_remove() function to complement phy_device_register(),
which undoes the effects of phy_device_register() by removing the phy
device from visibility, but not freeing it.

This allows these details to be moved out of the mdio bus code into
the phy code where this action belongs.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/gianfar.c |  5 +++--
 drivers/net/phy/mdio_bus.c               | 15 ++++++++++-----
 drivers/net/phy/phy_device.c             | 18 ++++++++++++++++++
 include/linux/phy.h                      |  1 +
 4 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 65a16086faec..903211df3288 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1702,7 +1702,6 @@ static void gfar_configure_serdes(struct net_device *dev)
 	tbiphy = of_phy_find_device(priv->tbi_node);
 	if (!tbiphy) {
 		dev_err(&dev->dev, "error: Could not get TBI device\n");
-		put_device(&tbiphy->dev);
 		return;
 	}
 
@@ -1711,8 +1710,10 @@ static void gfar_configure_serdes(struct net_device *dev)
 	 * everything for us?  Resetting it takes the link down and requires
 	 * several seconds for it to come back.
 	 */
-	if (phy_read(tbiphy, MII_BMSR) & BMSR_LSTATUS)
+	if (phy_read(tbiphy, MII_BMSR) & BMSR_LSTATUS) {
+		put_device(&tbiphy->dev);
 		return;
+	}
 
 	/* Single clk mode, mii mode off(for serdes communication) */
 	phy_write(tbiphy, MII_TBICON, TBICON_CLK_SELECT);
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 992406624b7c..c340e412b38f 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -291,8 +291,11 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 
 error:
 	while (--i >= 0) {
-		if (bus->phy_map[i])
-			device_unregister(&bus->phy_map[i]->dev);
+		struct phy_device *phydev = bus->phy_map[i];
+		if (phydev) {
+			phy_device_remove(phydev);
+			phy_device_free(phydev);
+		}
 	}
 	device_del(&bus->dev);
 	return err;
@@ -307,9 +310,11 @@ void mdiobus_unregister(struct mii_bus *bus)
 	bus->state = MDIOBUS_UNREGISTERED;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		if (bus->phy_map[i])
-			device_unregister(&bus->phy_map[i]->dev);
-		bus->phy_map[i] = NULL;
+		struct phy_device *phydev = bus->phy_map[i];
+		if (phydev) {
+			phy_device_remove(phydev);
+			phy_device_free(phydev);
+		}
 	}
 	device_del(&bus->dev);
 }
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 97a4f52addac..f761288abe66 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -384,6 +384,24 @@ int phy_device_register(struct phy_device *phydev)
 EXPORT_SYMBOL(phy_device_register);
 
 /**
+ * phy_device_remove - Remove a previously registered phy device from the MDIO bus
+ * @phydev: phy_device structure to remove
+ *
+ * This doesn't free the phy_device itself, it merely reverses the effects
+ * of phy_device_register(). Use phy_device_free() to free the device
+ * after calling this function.
+ */
+void phy_device_remove(struct phy_device *phydev)
+{
+	struct mii_bus *bus = phydev->bus;
+	int addr = phydev->addr;
+
+	device_del(&phydev->dev);
+	bus->phy_map[addr] = NULL;
+}
+EXPORT_SYMBOL(phy_device_remove);
+
+/**
  * phy_find_first - finds the first PHY device on the bus
  * @bus: the target MII bus
  */
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 11bce44f6d65..4a4e3a092337 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -745,6 +745,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     struct phy_c45_device_ids *c45_ids);
 struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45);
 int phy_device_register(struct phy_device *phy);
+void phy_device_remove(struct phy_device *phydev);
 int phy_init_hw(struct phy_device *phydev);
 int phy_suspend(struct phy_device *phydev);
 int phy_resume(struct phy_device *phydev);
-- 
2.1.0
