From: Marek Vasut <marex@denx.de>
Subject: [PATCH 1/3 V2] phy/micrel: Implement support for KSZ8021
Date: Fri, 21 Sep 2012 04:52:54 +0200
Message-ID: <1348195976-31703-1-git-send-email-marex@denx.de>
Cc: Marek Vasut <marex@denx.de>,
	"David J. Choi" <david.choi@micrel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:43019 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113Ab2IUCxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 22:53:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The KSZ8021 PHY was previously caught by KS8051, which is not correct.
This PHY needs additional setup if it is strapped for address 0. In such
case an reserved bit must be written in the 0x16, "Operation Mode Strap
Override" register. According to the KS8051 datasheet, that bit means
"PHY Address 0 in non-broadcast" and it indeed behaves as such on KSZ8021.
The issue where the ethernet controller (Freescale FEC) did not communicate
with network is fixed by writing this bit as 1.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: David J. Choi <david.choi@micrel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Cc: Fabio Estevam <fabio.estevam@freescale.com>
Cc: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/phy/micrel.c   |   27 +++++++++++++++++++++++++++
 include/linux/micrel_phy.h |    1 +
 2 files changed, 28 insertions(+)

V2: Also add entry into micrel_tbl

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index cf287e0..b5723b9 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -21,6 +21,12 @@
 #include <linux/phy.h>
 #include <linux/micrel_phy.h>
 
+/* Operation Mode Strap Override */
+#define MII_KSZPHY_OMSO				0x16
+#define KSZPHY_OMSO_B_CAST_OFF			(1 << 9)
+#define KSZPHY_OMSO_RMII_OVERRIDE		(1 << 1)
+#define KSZPHY_OMSO_MII_OVERRIDE		(1 << 0)
+
 /* general Interrupt control/status reg in vendor specific block. */
 #define MII_KSZPHY_INTCS			0x1B
 #define	KSZPHY_INTCS_JABBER			(1 << 15)
@@ -101,6 +107,13 @@ static int kszphy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int ksz8021_config_init(struct phy_device *phydev)
+{
+	phy_write(phydev, MII_KSZPHY_OMSO,
+		KSZPHY_OMSO_B_CAST_OFF | KSZPHY_OMSO_RMII_OVERRIDE);
+	return 0;
+}
+
 static int ks8051_config_init(struct phy_device *phydev)
 {
 	int regval;
@@ -128,6 +141,19 @@ static struct phy_driver ksphy_driver[] = {
 	.config_intr	= ks8737_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
+	.phy_id		= PHY_ID_KSZ8021,
+	.phy_id_mask	= 0x00ffffff,
+	.name		= "Micrel KSZ8021",
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= ksz8021_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= PHY_ID_KS8041,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KS8041",
@@ -203,6 +229,7 @@ static struct mdio_device_id __maybe_unused micrel_tbl[] = {
 	{ PHY_ID_KSZ9021, 0x000ffffe },
 	{ PHY_ID_KS8001, 0x00ffffff },
 	{ PHY_ID_KS8737, 0x00fffff0 },
+	{ PHY_ID_KSZ8021, 0x00ffffff },
 	{ PHY_ID_KS8041, 0x00fffff0 },
 	{ PHY_ID_KS8051, 0x00fffff0 },
 	{ }
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index 61f0905..be7f366 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -5,6 +5,7 @@
 
 #define PHY_ID_KSZ9021		0x00221610
 #define PHY_ID_KS8737		0x00221720
+#define PHY_ID_KSZ8021		0x00221555
 #define PHY_ID_KS8041		0x00221510
 #define PHY_ID_KS8051		0x00221550
 /* both for ks8001 Rev. A/B, and for ks8721 Rev 3. */
-- 
1.7.10.4
