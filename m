From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/3] net: phy: mdio-bcm-unimac: workaround initial read failures for integrated PHYs
Date: Fri, 26 Jun 2015 10:39:06 -0700
Message-ID: <1435340346-10297-4-git-send-email-f.fainelli@gmail.com>
References: <1435340346-10297-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33671 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbbFZRkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:40:43 -0400
Received: by pdjn11 with SMTP id n11so78861600pdj.0
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:40:43 -0700 (PDT)
In-Reply-To: <1435340346-10297-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All BCM7xxx integrated Gigabit PHYs have an issue in their MDIO
management controller which will make the initial read or write to them
to fail and return 0xffff. This is a real issue as the typical first
thing we do is read from MII_PHYSID1 and MII_PHYSID2 from get_phy_id()
to register a driver for these PHYs.

Coupled with the workaround in drivers/net/phy/bcm7xxx.c, this
workaround for the MDIO bus controller consists in scanning the list of
PHYs to do this initial read workaround for as part of the MDIO bus
reset routine which is invoked prior to mdiobus_scan().

Once we have a proper PHY driver/device registered, all workarounds are
located there (e.g: power management suspend/resume calls).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-bcm-unimac.c | 43 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index fc7abc50b4f1..6a52a7f0fa0d 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -120,6 +120,48 @@ static int unimac_mdio_write(struct mii_bus *bus, int phy_id,
 	return 0;
 }
 
+/* Workaround for integrated BCM7xxx Gigabit PHYs which have a problem with
+ * their internal MDIO management controller making them fail to successfully
+ * be read from or written to for the first transaction.  We insert a dummy
+ * BMSR read here to make sure that phy_get_device() and get_phy_id() can
+ * correctly read the PHY MII_PHYSID1/2 registers and successfully register a
+ * PHY device for this peripheral.
+ *
+ * Once the PHY driver is registered, we can workaround subsequent reads from
+ * there (e.g: during system-wide power management).
+ *
+ * bus->reset is invoked before mdiobus_scan during mdiobus_register and is
+ * therefore the right location to stick that workaround. Since we do not want
+ * to read from non-existing PHYs, we either use bus->phy_mask or do a manual
+ * Device Tree scan to limit the search area.
+ */
+static int unimac_mdio_reset(struct mii_bus *bus)
+{
+	struct device_node *np = bus->dev.of_node;
+	struct device_node *child;
+	u32 read_mask = 0;
+	int addr;
+
+	if (!np) {
+		read_mask = ~bus->phy_mask;
+	} else {
+		for_each_available_child_of_node(np, child) {
+			addr = of_mdio_parse_addr(&bus->dev, child);
+			if (addr < 0)
+				continue;
+
+			read_mask |= 1 << addr;
+		}
+	}
+
+	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
+		if (read_mask & 1 << addr)
+			mdiobus_read(bus, addr, MII_BMSR);
+	}
+
+	return 0;
+}
+
 static int unimac_mdio_probe(struct platform_device *pdev)
 {
 	struct unimac_mdio_priv *priv;
@@ -155,6 +197,7 @@ static int unimac_mdio_probe(struct platform_device *pdev)
 	bus->parent = &pdev->dev;
 	bus->read = unimac_mdio_read;
 	bus->write = unimac_mdio_write;
+	bus->reset = unimac_mdio_reset;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
 
 	bus->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
-- 
2.1.0
