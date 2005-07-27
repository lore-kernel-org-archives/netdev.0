From: Matt Porter <mporter@kernel.crashing.org>
Subject: [PATCH] emac: add bamboo support
Date: Wed, 27 Jul 2005 10:42:47 -0700
Message-ID: <20050727104247.C1114@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wfarnsworth@mvista.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adds support for the Bamboo board phys in the EMAC driver.
Please apply.

Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>
Signed-off-by: Matt Porter <mporter@kernel.crashing.org>

diff -uprN linux-2.6.12/drivers/net/ibm_emac/ibm_emac_phy.c linux-2.6.12-440ep/drivers/net/ibm_emac/ibm_emac_phy.c
--- linux-2.6.12/drivers/net/ibm_emac/ibm_emac_phy.c	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12-440ep/drivers/net/ibm_emac/ibm_emac_phy.c	2005-07-25 11:32:38.000000000 -0700
@@ -24,6 +24,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/delay.h>
+#include <linux/vmalloc.h>
 
 #include "ibm_emac_phy.h"
 
@@ -78,6 +79,45 @@ static int cis8201_init(struct mii_phy *
 	return 0;
 }
 
+#ifdef CONFIG_BAMBOO
+static int ac104_init(struct mii_phy *phy)
+{
+	/*
+	 * SW2 on the Bamboo is used for ethernet configuration and is accessed
+	 * via the CONFIG2 register in the FPGA.  If the ANEG pin is set,
+	 * overwrite the supported features with the settings in SW2.
+	 */
+	u8 *config2_addr, config2_val;
+	config2_addr = ioremap64(BAMBOO_FPGA_CONFIG2_REG_ADDR, 0x8);
+	config2_val = * config2_addr;
+	iounmap(config2_addr);
+	if (BAMBOO_AUTONEGOTIATE(config2_val))
+		return 0;
+	phy->def->features = SUPPORTED_TP | SUPPORTED_MII;
+	if (BAMBOO_FORCE_100Mbps(config2_val)) {
+		phy->speed = SPEED_100;
+		if (BAMBOO_FULL_DUPLEX_EN(config2_val)) {
+			phy->def->features |= SUPPORTED_100baseT_Full;
+			phy->duplex = DUPLEX_FULL;
+		} else {
+			phy->def->features |= SUPPORTED_100baseT_Half;
+			phy->duplex = DUPLEX_HALF;
+		}
+	} else {
+		phy->speed = SPEED_10;
+		if (BAMBOO_FULL_DUPLEX_EN(config2_val)) {
+			phy->def->features |= SUPPORTED_10baseT_Full;
+			phy->duplex = DUPLEX_FULL;
+		} else {
+			phy->def->features |= SUPPORTED_10baseT_Half;
+			phy->duplex = DUPLEX_HALF;
+		}
+	}
+	
+	return 0;
+}
+#endif
+
 static int genmii_setup_aneg(struct mii_phy *phy, u32 advertise)
 {
 	u16 ctl, adv;
@@ -226,6 +266,17 @@ static struct mii_phy_ops cis8201_phy_op
 	read_link:cis8201_read_link
 };
 
+/* AC104 phy ops */
+static struct mii_phy_ops ac104_phy_ops = {
+#ifdef CONFIG_BAMBOO
+	init:ac104_init,
+#endif
+	setup_aneg:genmii_setup_aneg,
+	setup_forced:genmii_setup_forced,
+	poll_link:genmii_poll_link,
+	read_link:genmii_read_link
+};
+
 /* Generic implementation for most 10/100 PHYs */
 static struct mii_phy_ops generic_phy_ops = {
 	setup_aneg:genmii_setup_aneg,
@@ -234,6 +285,15 @@ static struct mii_phy_ops generic_phy_op
 	read_link:genmii_read_link
 };
 
+static struct mii_phy_def ac104_phy_def = {
+	phy_id:0x00225540,
+	phy_id_mask:0x00fffff0,
+	name:"AC104 Ethernet",
+	features:MII_BASIC_FEATURES,
+	magic_aneg:0,
+	ops:&ac104_phy_ops
+};
+
 static struct mii_phy_def cis8201_phy_def = {
 	phy_id:0x000fc410,
 	phy_id_mask:0x000ffff0,
@@ -254,6 +314,7 @@ static struct mii_phy_def genmii_phy_def
 
 static struct mii_phy_def *mii_phy_table[] = {
 	&cis8201_phy_def,
+	&ac104_phy_def,
 	&genmii_phy_def,
 	NULL
 };
