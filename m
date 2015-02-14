From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/2] net: dsa: mv88e6352: Refactor shareable code
Date: Sat, 14 Feb 2015 19:17:50 +0100
Message-ID: <1423937871-9180-2-git-send-email-andrew@lunn.ch>
References: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44413 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091AbbBNSUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Feb 2015 13:20:45 -0500
In-Reply-To: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6352 allows access to the port phys via an internal mdio bus
which is accessed using registers in the GLOBAL 2 range. The mv88e6171
and probably other devices use the same mechanism. Move this code into
the shared mv88e6xxx.c library.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6352.c | 77 +++++++--------------------------------------
 drivers/net/dsa/mv88e6xxx.c | 53 +++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  6 ++++
 3 files changed, 71 insertions(+), 65 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index e13adc7b3dda..1ebd8f96072a 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -22,59 +22,6 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static int mv88e6352_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
-{
-	unsigned long timeout = jiffies + HZ / 10;
-
-	while (time_before(jiffies, timeout)) {
-		int ret;
-
-		ret = REG_READ(reg, offset);
-		if (!(ret & mask))
-			return 0;
-
-		usleep_range(1000, 2000);
-	}
-	return -ETIMEDOUT;
-}
-
-static inline int mv88e6352_phy_wait(struct dsa_switch *ds)
-{
-	return mv88e6352_wait(ds, REG_GLOBAL2, 0x18, 0x8000);
-}
-
-static inline int mv88e6352_eeprom_load_wait(struct dsa_switch *ds)
-{
-	return mv88e6352_wait(ds, REG_GLOBAL2, 0x14, 0x0800);
-}
-
-static inline int mv88e6352_eeprom_busy_wait(struct dsa_switch *ds)
-{
-	return mv88e6352_wait(ds, REG_GLOBAL2, 0x14, 0x8000);
-}
-
-static int __mv88e6352_phy_read(struct dsa_switch *ds, int addr, int regnum)
-{
-	int ret;
-
-	REG_WRITE(REG_GLOBAL2, 0x18, 0x9800 | (addr << 5) | regnum);
-
-	ret = mv88e6352_phy_wait(ds);
-	if (ret < 0)
-		return ret;
-
-	return REG_READ(REG_GLOBAL2, 0x19);
-}
-
-static int __mv88e6352_phy_write(struct dsa_switch *ds, int addr, int regnum,
-				 u16 val)
-{
-	REG_WRITE(REG_GLOBAL2, 0x19, val);
-	REG_WRITE(REG_GLOBAL2, 0x18, 0x9400 | (addr << 5) | regnum);
-
-	return mv88e6352_phy_wait(ds);
-}
-
 static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
 {
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
@@ -346,12 +293,12 @@ static int mv88e6352_phy_page_read(struct dsa_switch *ds,
 	int ret;
 
 	mutex_lock(&ps->phy_mutex);
-	ret = __mv88e6352_phy_write(ds, port, 0x16, page);
+	ret = mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
 	if (ret < 0)
 		goto error;
-	ret = __mv88e6352_phy_read(ds, port, reg);
+	ret = mv88e6xxx_phy_read_indirect(ds, port, reg);
 error:
-	__mv88e6352_phy_write(ds, port, 0x16, 0x0);
+	mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
@@ -363,13 +310,13 @@ static int mv88e6352_phy_page_write(struct dsa_switch *ds,
 	int ret;
 
 	mutex_lock(&ps->phy_mutex);
-	ret = __mv88e6352_phy_write(ds, port, 0x16, page);
+	ret = mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
 	if (ret < 0)
 		goto error;
 
-	ret = __mv88e6352_phy_write(ds, port, reg, val);
+	ret = mv88e6xxx_phy_write_indirect(ds, port, reg, val);
 error:
-	__mv88e6352_phy_write(ds, port, 0x16, 0x0);
+	mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
@@ -482,7 +429,7 @@ mv88e6352_phy_read(struct dsa_switch *ds, int port, int regnum)
 		return addr;
 
 	mutex_lock(&ps->phy_mutex);
-	ret = __mv88e6352_phy_read(ds, addr, regnum);
+	ret = mv88e6xxx_phy_read_indirect(ds, addr, regnum);
 	mutex_unlock(&ps->phy_mutex);
 
 	return ret;
@@ -499,7 +446,7 @@ mv88e6352_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 		return addr;
 
 	mutex_lock(&ps->phy_mutex);
-	ret = __mv88e6352_phy_write(ds, addr, regnum, val);
+	ret = mv88e6xxx_phy_write_indirect(ds, addr, regnum, val);
 	mutex_unlock(&ps->phy_mutex);
 
 	return ret;
@@ -553,7 +500,7 @@ static int mv88e6352_read_eeprom_word(struct dsa_switch *ds, int addr)
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6352_eeprom_busy_wait(ds);
+	ret = mv88e6xxx_eeprom_busy_wait(ds);
 	if (ret < 0)
 		goto error;
 
@@ -576,7 +523,7 @@ static int mv88e6352_get_eeprom(struct dsa_switch *ds,
 
 	eeprom->magic = 0xc3ec4951;
 
-	ret = mv88e6352_eeprom_load_wait(ds);
+	ret = mv88e6xxx_eeprom_load_wait(ds);
 	if (ret < 0)
 		return ret;
 
@@ -657,7 +604,7 @@ static int mv88e6352_write_eeprom_word(struct dsa_switch *ds, int addr,
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6352_eeprom_busy_wait(ds);
+	ret = mv88e6xxx_eeprom_busy_wait(ds);
 error:
 	mutex_unlock(&ps->eeprom_mutex);
 	return ret;
@@ -681,7 +628,7 @@ static int mv88e6352_set_eeprom(struct dsa_switch *ds,
 	len = eeprom->len;
 	eeprom->len = 0;
 
-	ret = mv88e6352_eeprom_load_wait(ds);
+	ret = mv88e6xxx_eeprom_load_wait(ds);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 3e7e31a6abb7..a83ace0803e7 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -596,6 +596,59 @@ error:
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
+static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
+{
+	unsigned long timeout = jiffies + HZ / 10;
+
+	while (time_before(jiffies, timeout)) {
+		int ret;
+
+		ret = REG_READ(reg, offset);
+		if (!(ret & mask))
+			return 0;
+
+		usleep_range(1000, 2000);
+	}
+	return -ETIMEDOUT;
+}
+
+int mv88e6xxx_phy_wait(struct dsa_switch *ds)
+{
+	return mv88e6xxx_wait(ds, REG_GLOBAL2, 0x18, 0x8000);
+}
+
+int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
+{
+	return mv88e6xxx_wait(ds, REG_GLOBAL2, 0x14, 0x0800);
+}
+
+int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
+{
+	return mv88e6xxx_wait(ds, REG_GLOBAL2, 0x14, 0x8000);
+}
+
+int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum)
+{
+	int ret;
+
+	REG_WRITE(REG_GLOBAL2, 0x18, 0x9800 | (addr << 5) | regnum);
+
+	ret = mv88e6xxx_phy_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	return REG_READ(REG_GLOBAL2, 0x19);
+}
+
+int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
+				 u16 val)
+{
+	REG_WRITE(REG_GLOBAL2, 0x19, val);
+	REG_WRITE(REG_GLOBAL2, 0x18, 0x9400 | (addr << 5) | regnum);
+
+	return mv88e6xxx_phy_wait(ds);
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 03e397efde36..72942271bb67 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -82,6 +82,12 @@ int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port);
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p);
 int  mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp);
+int mv88e6xxx_phy_wait(struct dsa_switch *ds);
+int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds);
+int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds);
+int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum);
+int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
+				 u16 val);
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
-- 
2.1.4
