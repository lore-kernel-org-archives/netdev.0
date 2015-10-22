From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 2/3] net: dsa: Make mv88e6xxx use nested mdiobus read/write
Date: Thu, 22 Oct 2015 10:37:53 +0200
Message-ID: <5628A061.2050103@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the mv88e6xxx driver use the previously introduced nested
variants of mdiobus_read/write functions.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6xxx.c | 46 +++++++++------------------------------------
 1 file changed, 9 insertions(+), 37 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4591240..e3cc66e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -26,34 +26,6 @@
 #include <net/switchdev.h>
 #include "mv88e6xxx.h"

-/* MDIO bus access can be nested in the case of PHYs connected to the
- * internal MDIO bus of the switch, which is accessed via MDIO bus of
- * the Ethernet interface. Avoid lockdep false positives by using
- * mutex_lock_nested().
- */
-static int mv88e6xxx_mdiobus_read(struct mii_bus *bus, int addr, u32 regnum)
-{
-	int ret;
-
-	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
-	ret = bus->read(bus, addr, regnum);
-	mutex_unlock(&bus->mdio_lock);
-
-	return ret;
-}
-
-static int mv88e6xxx_mdiobus_write(struct mii_bus *bus, int addr, u32 regnum,
-				   u16 val)
-{
-	int ret;
-
-	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
-	ret = bus->write(bus, addr, regnum, val);
-	mutex_unlock(&bus->mdio_lock);
-
-	return ret;
-}
-
 /* If the switch's ADDR[4:0] strap pins are strapped to zero, it will
  * use all 32 SMI bus addresses on its SMI bus, and all switch registers
  * will be directly accessible on some {device address,register address}
@@ -68,7 +40,7 @@ static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
 	int i;

 	for (i = 0; i < 16; i++) {
-		ret = mv88e6xxx_mdiobus_read(bus, sw_addr, SMI_CMD);
+		ret = mdiobus_read_nested(bus, sw_addr, SMI_CMD);
 		if (ret < 0)
 			return ret;

@@ -84,7 +56,7 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 	int ret;

 	if (sw_addr == 0)
-		return mv88e6xxx_mdiobus_read(bus, addr, reg);
+		return mdiobus_read_nested(bus, addr, reg);

 	/* Wait for the bus to become free. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
@@ -92,8 +64,8 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 		return ret;

 	/* Transmit the read command. */
-	ret = mv88e6xxx_mdiobus_write(bus, sw_addr, SMI_CMD,
-				      SMI_CMD_OP_22_READ | (addr << 5) | reg);
+	ret = mdiobus_write_nested(bus, sw_addr, SMI_CMD,
+				   SMI_CMD_OP_22_READ | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;

@@ -103,7 +75,7 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 		return ret;

 	/* Read the data. */
-	ret = mv88e6xxx_mdiobus_read(bus, sw_addr, SMI_DATA);
+	ret = mdiobus_read_nested(bus, sw_addr, SMI_DATA);
 	if (ret < 0)
 		return ret;

@@ -147,7 +119,7 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 	int ret;

 	if (sw_addr == 0)
-		return mv88e6xxx_mdiobus_write(bus, addr, reg, val);
+		return mdiobus_write_nested(bus, addr, reg, val);

 	/* Wait for the bus to become free. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
@@ -155,13 +127,13 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 		return ret;

 	/* Transmit the data to write. */
-	ret = mv88e6xxx_mdiobus_write(bus, sw_addr, SMI_DATA, val);
+	ret = mdiobus_write_nested(bus, sw_addr, SMI_DATA, val);
 	if (ret < 0)
 		return ret;

 	/* Transmit the write command. */
-	ret = mv88e6xxx_mdiobus_write(bus, sw_addr, SMI_CMD,
-				      SMI_CMD_OP_22_WRITE | (addr << 5) | reg);
+	ret = mdiobus_write_nested(bus, sw_addr, SMI_CMD,
+				   SMI_CMD_OP_22_WRITE | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;

-- 
1.9.1
