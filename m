From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: Call bus->reset() after releasing PHYs from reset
Date: Thu, 11 May 2017 11:24:16 -0700
Message-ID: <20170511182417.17708-1-f.fainelli@gmail.com>
Cc: rogerq@ti.com, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The API convention makes it that a given MDIO bus reset should be able
to access PHY devices in its reset() callback and perform additional
MDIO accesses in order to bring the bus and PHYs in a working state.

Commit 69226896ad63 ("mdio_bus: Issue GPIO RESET to PHYs.") broke that
contract by first calling bus->reset() and then release all PHYs from
reset using their shared GPIO line, so restore the expected
functionality here.

Fixes: 69226896ad63 ("mdio_bus: Issue GPIO RESET to PHYs.")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_bus.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index a898e5c4ef1b..8e73f5f36e71 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -364,9 +364,6 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 
 	mutex_init(&bus->mdio_lock);
 
-	if (bus->reset)
-		bus->reset(bus);
-
 	/* de-assert bus level PHY GPIO resets */
 	if (bus->num_reset_gpios > 0) {
 		bus->reset_gpiod = devm_kcalloc(&bus->dev,
@@ -396,6 +393,9 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 		}
 	}
 
+	if (bus->reset)
+		bus->reset(bus);
+
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		if ((bus->phy_mask & (1 << i)) == 0) {
 			struct phy_device *phydev;
-- 
2.9.3
