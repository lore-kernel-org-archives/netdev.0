From: "Andrew F. Davis" <afd@ti.com>
Subject: [PATCH] net: phy: dp83848: Add support for TI TLK10x Ethernet PHYs
Date: Fri, 5 Feb 2016 17:13:16 -0600
Message-ID: <1454713996-28851-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Andrew F. Davis" <afd@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TI TLK10x Ethernet PHYs are similar in the interrupt relevant
registers and so are compatible with the DP83848x devices already
supported. Add these and re-order code to support additional PHYs.

Signed-off-by: Andrew F. Davis <afd@ti.com>
---
 drivers/net/phy/dp83848.c | 89 ++++++++++++++++++++++++++++-------------------
 1 file changed, 53 insertions(+), 36 deletions(-)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 5e14e62..bc88259 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -1,7 +1,8 @@
 /*
  * Driver for the Texas Instruments DP83848 PHY
  *
- * Copyright (C) 2015 Texas Instruments Inc.
+ * Copyright (C) 2015-2016 Texas Instruments Incorporated - http://www.ti.com/
+ *	Andrew F. Davis <afd@ti.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -16,11 +17,13 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 
-#define DP83848_PHY_ID			0x20005c90
+#define DP83848C_PHY_ID			0x20005c90
+#define DP83848I_PHY_ID			0x20005ca0
+#define TLK10X_PHY_ID			0x2000a210
 
 /* Registers */
-#define DP83848_MICR			0x11
-#define DP83848_MISR			0x12
+#define DP83848_MICR			0x11 /* MII Interrupt Control Register */
+#define DP83848_MISR			0x12 /* MII Interrupt Status Register */
 
 /* MICR Register Fields */
 #define DP83848_MICR_INT_OE		BIT(0) /* Interrupt Output Enable */
@@ -36,6 +39,12 @@
 #define DP83848_MISR_ED_INT_EN		BIT(6) /* Energy detect */
 #define DP83848_MISR_LQM_INT_EN		BIT(7) /* Link Quality Monitor */
 
+#define DP83848_INT_EN_MASK		\
+	(DP83848_MISR_ANC_INT_EN |	\
+	 DP83848_MISR_DUP_INT_EN |	\
+	 DP83848_MISR_SPD_INT_EN |	\
+	 DP83848_MISR_LINK_INT_EN)
+
 static int dp83848_ack_interrupt(struct phy_device *phydev)
 {
 	int err = phy_read(phydev, DP83848_MISR);
@@ -45,50 +54,58 @@ static int dp83848_ack_interrupt(struct phy_device *phydev)
 
 static int dp83848_config_intr(struct phy_device *phydev)
 {
-	int err;
+	int control, ret;
+
+	control = phy_read(phydev, DP83848_MICR);
+	if (control < 0)
+		return control;
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
-		err = phy_write(phydev, DP83848_MICR,
-				DP83848_MICR_INT_OE |
-				DP83848_MICR_INTEN);
-		if (err < 0)
-			return err;
-
-		return phy_write(phydev, DP83848_MISR,
-				 DP83848_MISR_ANC_INT_EN |
-				 DP83848_MISR_DUP_INT_EN |
-				 DP83848_MISR_SPD_INT_EN |
-				 DP83848_MISR_LINK_INT_EN);
+		control |= DP83848_MICR_INT_OE;
+		control |= DP83848_MICR_INTEN;
+
+		ret = phy_write(phydev, DP83848_MISR, DP83848_INT_EN_MASK);
+		if (ret < 0)
+			return ret;
+	} else {
+		control &= ~DP83848_MICR_INTEN;
 	}
 
-	return phy_write(phydev, DP83848_MICR, 0x0);
+	return phy_write(phydev, DP83848_MICR, control);
 }
 
 static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
-	{ DP83848_PHY_ID, 0xfffffff0 },
+	{ DP83848C_PHY_ID, 0xfffffff0 },
+	{ DP83848I_PHY_ID, 0xfffffff0 },
+	{ TLK10X_PHY_ID, 0xfffffff0 },
 	{ }
 };
 MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
 
+#define DP83848_PHY_DRIVER(_id, _name)				\
+	{							\
+		.phy_id		= _id,				\
+		.phy_id_mask	= 0xfffffff0,			\
+		.name		= _name,			\
+		.features	= PHY_BASIC_FEATURES,		\
+		.flags		= PHY_HAS_INTERRUPT,		\
+								\
+		.soft_reset	= genphy_soft_reset,		\
+		.config_init	= genphy_config_init,		\
+		.suspend	= genphy_suspend,		\
+		.resume		= genphy_resume,		\
+		.config_aneg	= genphy_config_aneg,		\
+		.read_status	= genphy_read_status,		\
+								\
+		/* IRQ related */				\
+		.ack_interrupt	= dp83848_ack_interrupt,	\
+		.config_intr	= dp83848_config_intr,		\
+	}
+
 static struct phy_driver dp83848_driver[] = {
-	{
-		.phy_id		= DP83848_PHY_ID,
-		.phy_id_mask	= 0xfffffff0,
-		.name		= "TI DP83848",
-		.features	= PHY_BASIC_FEATURES,
-		.flags		= PHY_HAS_INTERRUPT,
-
-		.soft_reset	= genphy_soft_reset,
-		.config_init	= genphy_config_init,
-		.suspend	= genphy_suspend,
-		.resume		= genphy_resume,
-		.config_aneg	= genphy_config_aneg,
-		.read_status	= genphy_read_status,
-
-		/* IRQ related */
-		.ack_interrupt	= dp83848_ack_interrupt,
-		.config_intr	= dp83848_config_intr,
-	},
+	DP83848_PHY_DRIVER(DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps PHY"),
+	DP83848_PHY_DRIVER(DP83848I_PHY_ID, "TI DP83848I 10/100 Mbps PHY"),
+	DP83848_PHY_DRIVER(TLK10X_PHY_ID, "TI TLK10X 10/100 Mbps PHY"),
 };
 module_phy_driver(dp83848_driver);
 
-- 
2.7.0
