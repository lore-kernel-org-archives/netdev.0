From: Pavel Machek <pavel@denx.de>
Subject: Re: socfpga/sockit ethernet problems
Date: Thu, 3 Jul 2014 11:35:48 +0200
Message-ID: <20140703093548.GA9937@amd.pavel.ucw.cz>
References: <20140507104518.GB18139@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	dinguyen@altera.com, linux-arm-kernel@lists.infradead.org,
	gsi@denx.de, dzu@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:51018 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030601AbaGCJfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 05:35:50 -0400
Content-Disposition: inline
In-Reply-To: <20140507104518.GB18139@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> 
> It seems we have some problems with Ethernet on socfpga boards.
> 
> Like, "stmmac: Energy-Efficient Ethernet initialized" repeated way too
> often. Or machine failing to boot because NFS server can not be
> accessed. (And then working on next try). Or link going up and down
> and up and down. Or link taking 3 seconds, 10 seconds to estabilish.
> 
> It also seems to be picky about hubs it wants to talk to.
> 
> This time it mounted root; on last boot it just hung.
...
> u-boot talk 12.033741 Configuring PHY skew timing for Micrel ksz9021
> 
> is there something similar that needs to be done at Linux layer.

It seems there is. There is patch at
http://lists.infradead.org/pipermail/linux-arm-kernel/2013-July/184335.html
, but it does not match the code we have in u-boot (and that seems to
work).

I made this, but ethernet problems I currently see are not frequent
enough to allow easy debugging. If link takes long to  estabilish for
you, could you test the patch below?

Thanks,
								Pavel

Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/arch/arm/mach-at91/board-dt-sama5.c b/arch/arm/mach-at91/board-dt-sama5.c
index 075ec05..6a2d5f7 100644
--- a/arch/arm/mach-at91/board-dt-sama5.c
+++ b/arch/arm/mach-at91/board-dt-sama5.c
@@ -51,11 +51,11 @@ static int ksz9021rn_phy_fixup(struct phy_device *phy)
 	int value;
 
 	/* Set delay values */
-	value = MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW | 0x8000;
+	value = MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW | 0x8000;
 	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
 	value = 0xF2F4;
 	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
-	value = MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW | 0x8000;
+	value = MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW | 0x8000;
 	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
 	value = 0x2222;
 	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
diff --git a/arch/arm/mach-imx/mach-imx6q.c b/arch/arm/mach-imx/mach-imx6q.c
index e60456d..8a0ba06 100644
--- a/arch/arm/mach-imx/mach-imx6q.c
+++ b/arch/arm/mach-imx/mach-imx6q.c
@@ -45,15 +45,15 @@ static int ksz9021rn_phy_fixup(struct phy_device *phydev)
 	if (IS_BUILTIN(CONFIG_PHYLIB)) {
 		/* min rx data delay */
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
-			0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW);
+			0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW);
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
 
 		/* max rx/tx clock delay, min rx/tx control delay */
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
-			0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
+			0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0xf0f0);
 		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
-			MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
+			MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
 	}
 
 	return 0;
diff --git a/arch/arm/mach-socfpga/socfpga.c b/arch/arm/mach-socfpga/socfpga.c
index adbf383..4a953c0 100644
--- a/arch/arm/mach-socfpga/socfpga.c
+++ b/arch/arm/mach-socfpga/socfpga.c
@@ -19,6 +19,8 @@
 #include <linux/of_irq.h>
 #include <linux/of_platform.h>
 #include <linux/reboot.h>
+#include <linux/phy.h>
+#include <linux/micrel_phy.h>
 
 #include <asm/hardware/cache-l2x0.h>
 #include <asm/mach/arch.h>
@@ -85,6 +87,44 @@ static void __init socfpga_init_irq(void)
 	socfpga_sysmgr_init();
 }
 
+static int ksz9021rn_phy_fixup(struct phy_device *phydev)
+{
+        if (IS_BUILTIN(CONFIG_PHYLIB)) {
+		printk("------------- running phy fixup\n");
+
+                /* min rx data delay */
+                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
+			  0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW);
+                phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
+
+                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
+			  0x8000 | MICREL_KSZ9021_RGMII_TX_DATA_PAD_SKEW);
+                phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
+
+                /* max rx/tx clock delay, min rx/tx control delay */
+                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
+			  0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
+                phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0xf0f0);
+                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
+			  MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
+        }
+
+        return 0;
+}
+
+static void __init socfpga_init_machine(void)
+{
+	early_printk("socfpga_init_machine\n");
+        if (IS_BUILTIN(CONFIG_PHYLIB)) {
+		printk("---------- registering phy fixup\n");
+                phy_register_fixup_for_uid(PHY_ID_KSZ9021, MICREL_PHY_ID_MASK,
+					   ksz9021rn_phy_fixup);
+        }
+	early_printk("socfpga_init_machine done\n");
+
+}
+
+
 static void socfpga_cyclone5_restart(enum reboot_mode mode, const char *cmd)
 {
 	u32 temp;
@@ -109,6 +149,7 @@ DT_MACHINE_START(SOCFPGA, "Altera SOCFPGA")
 	.smp		= smp_ops(socfpga_smp_ops),
 	.map_io		= socfpga_map_io,
 	.init_irq	= socfpga_init_irq,
+	.init_late   = socfpga_init_machine,
 	.restart	= socfpga_cyclone5_restart,
 	.dt_compat	= altera_dt_match,
 MACHINE_END
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index 2e5b194..de40c89 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -40,7 +40,8 @@
 
 #define MICREL_KSZ9021_EXTREG_CTRL	0xB
 #define MICREL_KSZ9021_EXTREG_DATA_WRITE	0xC
-#define MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW	0x104
-#define MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW	0x105
+#define MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW	0x104
+#define MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW	0x105
+#define MICREL_KSZ9021_RGMII_TX_DATA_PAD_SKEW	0x106
 
 #endif /* _MICREL_PHY_H */


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
