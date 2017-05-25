From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 2/5] net: dsa: mv88e6xxx: Refactor mv88e6352 SERDES code into an op
Date: Fri, 26 May 2017 01:03:21 +0200
Message-ID: <1495753404-29943-3-git-send-email-andrew@lunn.ch>
References: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45082 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165913AbdEYXEi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 19:04:38 -0400
In-Reply-To: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 family has a different SERDES implementation. Refactor
the mv88e6352 code into an ops function, so we can later add the
mv88e6390 code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/Makefile    |  1 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 64 +++++++++---------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  6 +--
 drivers/net/dsa/mv88e6xxx/serdes.c    | 75 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/serdes.h    | 24 +++++++++++
 5 files changed, 122 insertions(+), 48 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/serdes.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/serdes.h

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index e4372eaf3bc5..5cd5551461e3 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -6,3 +6,4 @@ mv88e6xxx-objs += global1_vtu.o
 mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
 mv88e6xxx-objs += phy.o
 mv88e6xxx-objs += port.o
+mv88e6xxx-objs += serdes.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 724f3b09e077..bc7b345d91d3 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -38,6 +38,7 @@
 #include "global2.h"
 #include "phy.h"
 #include "port.h"
+#include "serdes.h"
 
 static void assert_reg_lock(struct mv88e6xxx_chip *chip)
 {
@@ -234,18 +235,6 @@ struct mii_bus *mv88e6xxx_default_mdio_bus(struct mv88e6xxx_chip *chip)
 	return mdio_bus->bus;
 }
 
-static int mv88e6xxx_serdes_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
-{
-	return mv88e6xxx_phy_page_read(chip, ADDR_SERDES, SERDES_PAGE_FIBER,
-				       reg, val);
-}
-
-static int mv88e6xxx_serdes_write(struct mv88e6xxx_chip *chip, int reg, u16 val)
-{
-	return mv88e6xxx_phy_page_write(chip, ADDR_SERDES, SERDES_PAGE_FIBER,
-					reg, val);
-}
-
 static void mv88e6xxx_g1_irq_mask(struct irq_data *d)
 {
 	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
@@ -1733,24 +1722,6 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	return mv88e6xxx_software_reset(chip);
 }
 
-static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)
-{
-	u16 val;
-	int err;
-
-	/* Clear Power Down bit */
-	err = mv88e6xxx_serdes_read(chip, MII_BMCR, &val);
-	if (err)
-		return err;
-
-	if (val & BMCR_PDOWN) {
-		val &= ~BMCR_PDOWN;
-		err = mv88e6xxx_serdes_write(chip, MII_BMCR, val);
-	}
-
-	return err;
-}
-
 static int mv88e6xxx_set_port_mode(struct mv88e6xxx_chip *chip, int port,
 				   enum mv88e6xxx_frame_mode frame, u16 egress,
 				   u16 etype)
@@ -1832,6 +1803,15 @@ static int mv88e6xxx_setup_egress_floods(struct mv88e6xxx_chip *chip, int port)
 	return 0;
 }
 
+static int mv88e6xxx_serdes_power(struct mv88e6xxx_chip *chip, int port,
+				  bool on)
+{
+	if (chip->info->ops->serdes_power)
+		return chip->info->ops->serdes_power(chip, port, on);
+
+	return 0;
+}
+
 static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -1882,22 +1862,12 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	/* If this port is connected to a SerDes, make sure the SerDes is not
-	 * powered down.
+	/* If this port is connected to a SerDes, make sure the SerDes is
+	 * powered up.
 	 */
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SERDES)) {
-		err = mv88e6xxx_port_read(chip, port, PORT_STATUS, &reg);
-		if (err)
-			return err;
-		reg &= PORT_STATUS_CMODE_MASK;
-		if ((reg == PORT_STATUS_CMODE_100BASE_X) ||
-		    (reg == PORT_STATUS_CMODE_1000BASE_X) ||
-		    (reg == PORT_STATUS_CMODE_SGMII)) {
-			err = mv88e6xxx_serdes_power_on(chip);
-			if (err < 0)
-				return err;
-		}
-	}
+	err = mv88e6xxx_serdes_power(chip, port, true);
+	if (err)
+		return err;
 
 	/* Port Control 2: don't force a good FCS, set the maximum frame size to
 	 * 10240 bytes, disable 802.1q tags checking, don't discard tagged or
@@ -2662,6 +2632,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.serdes_power = mv88e6352_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -2726,6 +2697,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.serdes_power = mv88e6352_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -2882,6 +2854,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.serdes_power = mv88e6352_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3104,6 +3077,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.serdes_power = mv88e6352_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 45b387c780a8..fb996491b111 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -37,9 +37,6 @@
 #define PHY_PAGE		0x16
 #define PHY_PAGE_COPPER		0x00
 
-#define ADDR_SERDES		0x0f
-#define SERDES_PAGE_FIBER	0x01
-
 #define PORT_STATUS		0x00
 #define PORT_STATUS_PAUSE_EN	BIT(15)
 #define PORT_STATUS_MY_PAUSE	BIT(14)
@@ -884,6 +881,9 @@ struct mv88e6xxx_ops {
 	/* Can be either in g1 or g2, so don't use a prefix */
 	int (*mgmt_rsvd2cpu)(struct mv88e6xxx_chip *chip);
 
+	/* Power on/off a SERDES interface */
+	int (*serdes_power)(struct mv88e6xxx_chip *chip, int port, bool on);
+
 	/* VLAN Translation Unit operations */
 	int (*vtu_getnext)(struct mv88e6xxx_chip *chip,
 			   struct mv88e6xxx_vtu_entry *entry);
diff --git a/drivers/net/dsa/mv88e6xxx/serdes.c b/drivers/net/dsa/mv88e6xxx/serdes.c
new file mode 100644
index 000000000000..235f5f0c30ae
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/serdes.c
@@ -0,0 +1,75 @@
+/*
+ * Marvell 88E6xxx SERDES manipulation, via SMI bus
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2017 Andrew Lunn <andrew@lunn.ch>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/mii.h>
+
+#include "mv88e6xxx.h"
+#include "phy.h"
+#include "port.h"
+#include "serdes.h"
+
+static int mv88e6352_serdes_read(struct mv88e6xxx_chip *chip, int reg,
+				 u16 *val)
+{
+	return mv88e6xxx_phy_page_read(chip, MV88E6352_ADDR_SERDES,
+				       MV88E6352_SERDES_PAGE_FIBER,
+				       reg, val);
+}
+
+static int mv88e6352_serdes_write(struct mv88e6xxx_chip *chip, int reg,
+				  u16 val)
+{
+	return mv88e6xxx_phy_page_write(chip, MV88E6352_ADDR_SERDES,
+					MV88E6352_SERDES_PAGE_FIBER,
+					reg, val);
+}
+
+static int mv88e6352_serdes_power_set(struct mv88e6xxx_chip *chip, bool on)
+{
+	u16 val, new_val;
+	int err;
+
+	err = mv88e6352_serdes_read(chip, MII_BMCR, &val);
+	if (err)
+		return err;
+
+	if (on)
+		new_val = val & ~BMCR_PDOWN;
+	else
+		new_val = val | BMCR_PDOWN;
+
+	if (val != new_val)
+		err = mv88e6352_serdes_write(chip, MII_BMCR, new_val);
+
+	return err;
+}
+
+int mv88e6352_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on)
+{
+	int err;
+	u8 cmode;
+
+	err = mv88e6xxx_port_get_cmode(chip, port, &cmode);
+	if (err)
+		return err;
+
+	if ((cmode == PORT_STATUS_CMODE_100BASE_X) ||
+	    (cmode == PORT_STATUS_CMODE_1000BASE_X) ||
+	    (cmode == PORT_STATUS_CMODE_SGMII)) {
+		err = mv88e6352_serdes_power_set(chip, on);
+		if (err < 0)
+			return err;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/dsa/mv88e6xxx/serdes.h b/drivers/net/dsa/mv88e6xxx/serdes.h
new file mode 100644
index 000000000000..a690be09ac52
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/serdes.h
@@ -0,0 +1,24 @@
+/*
+ * Marvell 88E6xxx SERDES manipulation, via SMI bus
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2016 Andrew Lunn <andrew@lunn.ch>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _MV88E6XXX_SERDES_H
+#define _MV88E6XXX_SERDES_H
+
+#include "mv88e6xxx.h"
+
+#define MV88E6352_ADDR_SERDES		0x0f
+#define MV88E6352_SERDES_PAGE_FIBER	0x01
+
+int mv88e6352_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on);
+
+#endif
-- 
2.11.0
