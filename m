From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: dsa: mv88e6352: Use mnemonics for EEPROM registers and bits
Date: Sat,  8 Aug 2015 17:04:50 +0200
Message-ID: <1439046290-9522-1-git-send-email-andrew@lunn.ch>
Cc: Guenter Roeck <linux@roeck-us.net>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53960 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964791AbbHHPL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Aug 2015 11:11:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add register definitions #defines for accessing the EEPROM.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6352.c | 18 ++++++++++--------
 drivers/net/dsa/mv88e6xxx.h |  8 ++++++--
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index af210efecc55..7e935852e192 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -123,8 +123,9 @@ static int mv88e6352_read_eeprom_word(struct dsa_switch *ds, int addr)
 
 	mutex_lock(&ps->eeprom_mutex);
 
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, 0x14,
-				  0xc000 | (addr & 0xff));
+	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+				  GLOBAL2_EEPROM_OP_READ |
+				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
 	if (ret < 0)
 		goto error;
 
@@ -132,7 +133,7 @@ static int mv88e6352_read_eeprom_word(struct dsa_switch *ds, int addr)
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2, 0x15);
+	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2, GLOBAL2_EEPROM_DATA);
 error:
 	mutex_unlock(&ps->eeprom_mutex);
 	return ret;
@@ -205,11 +206,11 @@ static int mv88e6352_eeprom_is_readonly(struct dsa_switch *ds)
 {
 	int ret;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2, 0x14);
+	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP);
 	if (ret < 0)
 		return ret;
 
-	if (!(ret & 0x0400))
+	if (!(ret & GLOBAL2_EEPROM_OP_WRITE_EN))
 		return -EROFS;
 
 	return 0;
@@ -223,12 +224,13 @@ static int mv88e6352_write_eeprom_word(struct dsa_switch *ds, int addr,
 
 	mutex_lock(&ps->eeprom_mutex);
 
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, 0x15, data);
+	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, 0x14,
-				  0xb000 | (addr & 0xff));
+	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+				  GLOBAL2_EEPROM_OP_WRITE |
+				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
 	if (ret < 0)
 		goto error;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 78e37226a37d..8b017d65b691 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -285,8 +285,12 @@
 #define GLOBAL2_PRIO_OVERRIDE_FORCE_ARP		BIT(3)
 #define GLOBAL2_PRIO_OVERRIDE_ARP_SHIFT		0
 #define GLOBAL2_EEPROM_OP	0x14
-#define GLOBAL2_EEPROM_OP_BUSY	BIT(15)
-#define GLOBAL2_EEPROM_OP_LOAD	BIT(11)
+#define GLOBAL2_EEPROM_OP_BUSY		BIT(15)
+#define GLOBAL2_EEPROM_OP_WRITE		((3 << 12) | GLOBAL2_EEPROM_OP_BUSY)
+#define GLOBAL2_EEPROM_OP_READ		((4 << 12) | GLOBAL2_EEPROM_OP_BUSY)
+#define GLOBAL2_EEPROM_OP_LOAD		BIT(11)
+#define GLOBAL2_EEPROM_OP_WRITE_EN	BIT(10)
+#define GLOBAL2_EEPROM_OP_ADDR_MASK	0xff
 #define GLOBAL2_EEPROM_DATA	0x15
 #define GLOBAL2_PTP_AVB_OP	0x16
 #define GLOBAL2_PTP_AVB_DATA	0x17
-- 
2.5.0
