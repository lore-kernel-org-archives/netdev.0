From: Andy Fleming <afleming@freescale.com>
Subject: [RFC...ish] Add 8568 PHY workaround to board code
Date: Wed,  9 Apr 2008 19:29:33 -0500
Message-ID: <1207787373-9073-1-git-send-email-afleming@freescale.com>
Cc: Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:56908 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbYDJA3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 20:29:38 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m3A0TYrP000187
	for <netdev@vger.kernel.org>; Wed, 9 Apr 2008 17:29:34 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m3A0TXGi001388
	for <netdev@vger.kernel.org>; Wed, 9 Apr 2008 19:29:33 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 8568 MDS needs some configuration changes to the PHY in order to work
properly.  These are done in the firmware, normally, but Linux shouldn't
need to rely on the firmware running such things (someone could disable
the PHY support in the firmware to save space, for instance).

Signed-off-by: Andy Fleming <afleming@freescale.com>
---

An example of the sort of workaround that can be done with the PHY board code

 arch/powerpc/platforms/85xx/mpc85xx_mds.c |  114 +++++++++++++++++++++++++++++
 1 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/platforms/85xx/mpc85xx_mds.c b/arch/powerpc/platforms/85xx/mpc85xx_mds.c
index 25f8bc7..b1bf06d 100644
--- a/arch/powerpc/platforms/85xx/mpc85xx_mds.c
+++ b/arch/powerpc/platforms/85xx/mpc85xx_mds.c
@@ -32,6 +32,7 @@
 #include <linux/fsl_devices.h>
 #include <linux/of_platform.h>
 #include <linux/of_device.h>
+#include <linux/phy.h>
 
 #include <asm/system.h>
 #include <asm/atomic.h>
@@ -56,6 +57,95 @@
 #define DBG(fmt...)
 #endif
 
+#define MV88E1111_SCR	0x10
+#define MV88E1111_SCR_125CLK	0x0010
+static int mpc8568_fixup_125_clock(struct phy_device *phydev)
+{
+	int scr;
+	int err;
+
+	/* Workaround for the 125 CLK Toggle */
+	scr = phy_read(phydev, MV88E1111_SCR);
+
+	if (scr < 0)
+		return scr;
+
+	err = phy_write(phydev, MV88E1111_SCR, scr & ~(MV88E1111_SCR_125CLK));
+
+	if (err)
+		return err;
+
+	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+
+	if (err)
+		return err;
+
+	scr = phy_read(phydev, MV88E1111_SCR);
+
+	if (scr < 0)
+		return err;
+
+	err = phy_write(phydev, MV88E1111_SCR, scr | 0x0008);
+
+	return err;
+}
+
+static int mpc8568_mds_phy_fixups(struct phy_device *phydev)
+{
+	int temp;
+	int err;
+
+	/* Errata */
+	err = phy_write(phydev,29, 0x0006);
+
+	if (err)
+		return err;
+
+	temp = phy_read(phydev, 30);
+
+	if (temp < 0)
+		return temp;
+
+	temp = (temp & (~0x8000)) | 0x4000;
+	err = phy_write(phydev,30, temp);
+
+	if (err)
+		return err;
+
+	err = phy_write(phydev,29, 0x000a);
+
+	if (err)
+		return err;
+
+	temp = phy_read(phydev, 30);
+
+	if (temp < 0)
+		return temp;
+
+	temp = phy_read(phydev, 30);
+
+	if (temp < 0)
+		return temp;
+
+	temp &= ~0x0020;
+
+	err = phy_write(phydev,30,temp);
+
+	if (err)
+		return err;
+
+	/* Disable automatic MDI/MDIX selection */
+	temp = phy_read(phydev, 16);
+
+	if (temp < 0)
+		return temp;
+
+	temp &= ~0x0060;
+	err = phy_write(phydev,16,temp);
+
+	return err;
+}
+
 /* ************************************************************************
  *
  * Setup the architecture
@@ -138,6 +228,30 @@ static void __init mpc85xx_mds_setup_arch(void)
 #endif	/* CONFIG_QUICC_ENGINE */
 }
 
+
+static int __init board_fixups(void)
+{
+	char phy_id[BUS_ID_SIZE];
+	struct device_node *mdio;
+	struct resource res;
+
+	/* Register a workaround to fixup the clock source */
+	mdio = of_find_node_by_name(NULL, "mdio");
+
+	of_address_to_resource(mdio, 0, &res);
+	snprintf(phy_id, BUS_ID_SIZE, "%x:%02x", res.start, 1);
+
+	phy_register_fixup_for_id(phy_id, mpc8568_fixup_125_clock);
+	phy_register_fixup_for_id(phy_id, mpc8568_mds_phy_fixups);
+
+	/* Register a workaround for errata */
+	snprintf(phy_id, BUS_ID_SIZE, "%x:%02x", res.start, 7);
+	phy_register_fixup_for_id(phy_id, mpc8568_mds_phy_fixups);
+
+	return 0;
+}
+arch_initcall(board_fixups);
+
 static struct of_device_id mpc85xx_ids[] = {
 	{ .type = "soc", },
 	{ .compatible = "soc", },
-- 
1.5.4.GIT

