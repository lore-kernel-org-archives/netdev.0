From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 09/10] net: dsa: mv88e6xxx: Fix false positive lockdep splat
Date: Wed,  6 May 2015 01:09:55 +0200
Message-ID: <1430867396-2268-10-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44504 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbbEEXO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:14:56 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA can have nested MDIO busses, where the Ethernet MDIO bus is used
to access an MDIO bus within the switch which has the PHYs connected
to it. This nesting causes lockdep to give false positives. Use
mutex_lock_nested() to avoid this.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 46 ++++++++++++++++++++++++++++++++++++---------
 1 file changed, 37 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index bd033e00c751..56ecbe49eb86 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -19,6 +19,34 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
+/* MDIO bus access can be nested in the case of PHYs connected to the
+ * internal MDIO bus of the switch, which is accessed via MDIO bus of
+ * the Ethernet interface. Avoid lockdep false positives by using
+ * mutex_lock_nested().
+ */
+static int mv88e6xxx_mdiobus_read(struct mii_bus *bus, int addr, u32 regnum)
+{
+	int ret;
+
+	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	ret = bus->read(bus, addr, regnum);
+	mutex_unlock(&bus->mdio_lock);
+
+	return ret;
+}
+
+static int mv88e6xxx_mdiobus_write(struct mii_bus *bus, int addr, u32 regnum,
+				   u16 val)
+{
+	int ret;
+
+	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	ret = bus->write(bus, addr, regnum, val);
+	mutex_unlock(&bus->mdio_lock);
+
+	return ret;
+}
+
 /* If the switch's ADDR[4:0] strap pins are strapped to zero, it will
  * use all 32 SMI bus addresses on its SMI bus, and all switch registers
  * will be directly accessible on some {device address,register address}
@@ -33,7 +61,7 @@ static int mv88e6xxx_reg_wait_ready(struct mii_bus *bus, int sw_addr)
 	int i;
 
 	for (i = 0; i < 16; i++) {
-		ret = mdiobus_read(bus, sw_addr, SMI_CMD);
+		ret = mv88e6xxx_mdiobus_read(bus, sw_addr, SMI_CMD);
 		if (ret < 0)
 			return ret;
 
@@ -49,7 +77,7 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 	int ret;
 
 	if (sw_addr == 0)
-		return mdiobus_read(bus, addr, reg);
+		return mv88e6xxx_mdiobus_read(bus, addr, reg);
 
 	/* Wait for the bus to become free. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
@@ -57,8 +85,8 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 		return ret;
 
 	/* Transmit the read command. */
-	ret = mdiobus_write(bus, sw_addr, SMI_CMD,
-			    SMI_CMD_OP_22_READ | (addr << 5) | reg);
+	ret = mv88e6xxx_mdiobus_write(bus, sw_addr, SMI_CMD,
+				      SMI_CMD_OP_22_READ | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
@@ -68,7 +96,7 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 		return ret;
 
 	/* Read the data. */
-	ret = mdiobus_read(bus, sw_addr, SMI_DATA);
+	ret = mv88e6xxx_mdiobus_read(bus, sw_addr, SMI_DATA);
 	if (ret < 0)
 		return ret;
 
@@ -112,7 +140,7 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 	int ret;
 
 	if (sw_addr == 0)
-		return mdiobus_write(bus, addr, reg, val);
+		return mv88e6xxx_mdiobus_write(bus, addr, reg, val);
 
 	/* Wait for the bus to become free. */
 	ret = mv88e6xxx_reg_wait_ready(bus, sw_addr);
@@ -120,13 +148,13 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 		return ret;
 
 	/* Transmit the data to write. */
-	ret = mdiobus_write(bus, sw_addr, SMI_DATA, val);
+	ret = mv88e6xxx_mdiobus_write(bus, sw_addr, SMI_DATA, val);
 	if (ret < 0)
 		return ret;
 
 	/* Transmit the write command. */
-	ret = mdiobus_write(bus, sw_addr, SMI_CMD,
-			    SMI_CMD_OP_22_WRITE | (addr << 5) | reg);
+	ret = mv88e6xxx_mdiobus_write(bus, sw_addr, SMI_CMD,
+				      SMI_CMD_OP_22_WRITE | (addr << 5) | reg);
 	if (ret < 0)
 		return ret;
 
-- 
2.1.4
