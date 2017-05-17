From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/3] net: dsa: mv88e6xxx: Refactor mv88e6352 SERDES code into an op
Date: Wed, 17 May 2017 22:05:10 +0200
Message-ID: <1495051512-13554-2-git-send-email-andrew@lunn.ch>
References: <1495051512-13554-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, nikita.yoush@cogentembedded.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34781 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752529AbdEQUHI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 16:07:08 -0400
In-Reply-To: <1495051512-13554-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 family has a different SERDES implementation. Refactor
the mv88e6352 code into an ops function, so we can later add the
mv88e6390 code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/Makefile    |  1 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 62 ++++++----------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 35 +++++-----------
 drivers/net/dsa/mv88e6xxx/serdes.c    | 77 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/serdes.h    | 21 ++++++++++
 5 files changed, 122 insertions(+), 74 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/serdes.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/serdes.h

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 6edd869c8d6f..1786d14cbc3a 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -3,5 +3,6 @@ mv88e6xxx-objs := chip.o
 mv88e6xxx-objs += global1.o
 mv88e6xxx-objs += global1_atu.o
 mv88e6xxx-objs += global1_vtu.o
+mv88e6xxx-objs += serdes.o
 mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
 mv88e6xxx-objs += port.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d034d8cd7d22..6adaff3876b7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -38,6 +38,7 @@
 #include "global1.h"
 #include "global2.h"
 #include "port.h"
+#include "serdes.h"
 
 static void assert_reg_lock(struct mv88e6xxx_chip *chip)
 {
@@ -282,9 +283,6 @@ static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
 
 static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
 {
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PHY_PAGE))
-		return -EOPNOTSUPP;
-
 	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
 }
 
@@ -300,8 +298,8 @@ static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
 	}
 }
 
-static int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
-				   u8 page, int reg, u16 *val)
+int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
+			    u8 page, int reg, u16 *val)
 {
 	int err;
 
@@ -318,8 +316,8 @@ static int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
 	return err;
 }
 
-static int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
-				    u8 page, int reg, u16 val)
+int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
+			     u8 page, int reg, u16 val)
 {
 	int err;
 
@@ -336,18 +334,6 @@ static int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
 	return err;
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
@@ -1951,24 +1937,6 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
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
@@ -2100,21 +2068,13 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	/* If this port is connected to a SerDes, make sure the SerDes is not
-	 * powered down.
+	/* If this port is connected to a SerDes, make sure the SerDes is
+	 * powered up.
 	 */
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SERDES)) {
-		err = mv88e6xxx_port_read(chip, port, PORT_STATUS, &reg);
+	if (chip->info->ops->serdes_power) {
+		err = chip->info->ops->serdes_power(chip, port, true);
 		if (err)
 			return err;
-		reg &= PORT_STATUS_CMODE_MASK;
-		if ((reg == PORT_STATUS_CMODE_100BASE_X) ||
-		    (reg == PORT_STATUS_CMODE_1000BASE_X) ||
-		    (reg == PORT_STATUS_CMODE_SGMII)) {
-			err = mv88e6xxx_serdes_power_on(chip);
-			if (err < 0)
-				return err;
-		}
 	}
 
 	/* Port Control 2: don't force a good FCS, set the maximum frame size to
@@ -2880,6 +2840,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.serdes_power = mv88e6352_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
@@ -2944,6 +2905,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.serdes_power = mv88e6352_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
@@ -3100,6 +3062,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.serdes_power = mv88e6352_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -3322,6 +3285,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.serdes_power = mv88e6352_serdes_power,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 77236cd72df2..30ccd50832ff 100644
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
@@ -511,14 +508,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_SMI_CMD,		/* (0x00) SMI Command */
 	MV88E6XXX_CAP_SMI_DATA,		/* (0x01) SMI Data */
 
-	/* PHY Registers.
-	 */
-	MV88E6XXX_CAP_PHY_PAGE,		/* (0x16) Page Register */
-
-	/* Fiber/SERDES Registers (SMI address F).
-	 */
-	MV88E6XXX_CAP_SERDES,
-
 	/* Switch Global (1) Registers.
 	 */
 	MV88E6XXX_CAP_G1_ATU_FID,	/* (0x01) ATU FID Register */
@@ -553,10 +542,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SMI_CMD		BIT_ULL(MV88E6XXX_CAP_SMI_CMD)
 #define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
 
-#define MV88E6XXX_FLAG_PHY_PAGE		BIT_ULL(MV88E6XXX_CAP_PHY_PAGE)
-
-#define MV88E6XXX_FLAG_SERDES		BIT_ULL(MV88E6XXX_CAP_SERDES)
-
+#define MV88E6XXX_FLAG_G1_ATU_FID	BIT_ULL(MV88E6XXX_CAP_G1_ATU_FID)
 #define MV88E6XXX_FLAG_G1_VTU_FID	BIT_ULL(MV88E6XXX_CAP_G1_VTU_FID)
 
 #define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
@@ -577,11 +563,6 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_SMI_CMD |	\
 	 MV88E6XXX_FLAG_SMI_DATA)
 
-/* Fiber/SERDES Registers at SMI address F, page 1 */
-#define MV88E6XXX_FLAGS_SERDES		\
-	(MV88E6XXX_FLAG_PHY_PAGE |	\
-	 MV88E6XXX_FLAG_SERDES)
-
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -629,8 +610,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_SERDES)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_G1_VTU_FID |	\
@@ -651,8 +631,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_IRL |		\
-	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
-	 MV88E6XXX_FLAGS_SERDES)
+	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
@@ -889,6 +868,9 @@ struct mv88e6xxx_ops {
 			   struct mv88e6xxx_vtu_entry *entry);
 	int (*vtu_loadpurge)(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry);
+
+	/* Power on/off a SERDES interface */
+	int (*serdes_power)(struct mv88e6xxx_chip *chip, int port, bool on);
 };
 
 struct mv88e6xxx_irq_ops {
@@ -942,5 +924,8 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
 		     u16 update);
 int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg, u16 mask);
-
+int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
+			     u8 page, int reg, u16 val);
+int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
+			    u8 page, int reg, u16 *val);
 #endif
diff --git a/drivers/net/dsa/mv88e6xxx/serdes.c b/drivers/net/dsa/mv88e6xxx/serdes.c
new file mode 100644
index 000000000000..fc2d02c32908
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/serdes.c
@@ -0,0 +1,77 @@
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
+#include <linux/mii.h>
+
+#include "mv88e6xxx.h"
+#include "port.h"
+#include "serdes.h"
+
+#define MV88E6352_ADDR_SERDES		0x0f
+#define MV88E6352_SERDES_PAGE_FIBER	0x01
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
index 000000000000..e183727388cb
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/serdes.h
@@ -0,0 +1,21 @@
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
+int mv88e6352_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on);
+
+#endif
-- 
2.11.0
