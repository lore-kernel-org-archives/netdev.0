From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v3 4/7] kirkwood: Add fixups for DT based mv643xx ethernet.
Date: Tue,  7 Aug 2012 15:34:49 +0100
Message-ID: <1344350092-24050-5-git-send-email-ian.molton@codethink.co.uk>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:50816 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881Ab2HGOfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 10:35:07 -0400
In-Reply-To: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds auxdata for kirkwood ethernet and an ethernet clock setup
helper function allowing the mv643xx clock to be kept enabled after boot so
that the MAC address(es) are not lost.

Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
---
 arch/arm/mach-kirkwood/board-dt.c |    7 +++++++
 arch/arm/mach-kirkwood/common.c   |   22 ++++++++++++++++++++++
 arch/arm/mach-kirkwood/common.h   |    3 +++
 3 files changed, 32 insertions(+)

diff --git a/arch/arm/mach-kirkwood/board-dt.c b/arch/arm/mach-kirkwood/board-dt.c
index 7679f7f..aa213b6 100644
--- a/arch/arm/mach-kirkwood/board-dt.c
+++ b/arch/arm/mach-kirkwood/board-dt.c
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <linux/of.h>
 #include <linux/of_platform.h>
+#include <linux/mv643xx_eth.h>
 #include <linux/kexec.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -33,6 +34,10 @@ struct of_dev_auxdata kirkwood_auxdata_lookup[] __initdata = {
 	OF_DEV_AUXDATA("marvell,orion-wdt", 0xf1020300, "orion_wdt", NULL),
 	OF_DEV_AUXDATA("marvell,orion-sata", 0xf1080000, "sata_mv.0", NULL),
 	OF_DEV_AUXDATA("marvell,orion-nand", 0xf4000000, "orion_nand", NULL),
+	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1072000, "mv643xx_eth_port.0",
+			NULL),
+	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1076000, "mv643xx_eth_port.1",
+			NULL),
 	{},
 };
 
@@ -92,6 +97,8 @@ static void __init kirkwood_dt_init(void)
 
 	of_platform_populate(NULL, kirkwood_dt_match_table,
 			     kirkwood_auxdata_lookup, NULL);
+
+	kirkwood_eth_clock_fixup();
 }
 
 static const char *kirkwood_dt_board_compat[] = {
diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwood/common.c
index c4b64ad..57b91cf 100644
--- a/arch/arm/mach-kirkwood/common.c
+++ b/arch/arm/mach-kirkwood/common.c
@@ -18,6 +18,7 @@
 #include <linux/clk-provider.h>
 #include <linux/spinlock.h>
 #include <linux/mv643xx_i2c.h>
+#include <linux/of.h>
 #include <net/dsa.h>
 #include <asm/page.h>
 #include <asm/timex.h>
@@ -293,6 +294,27 @@ void __init kirkwood_ehci_init(void)
 	orion_ehci_init(USB_PHYS_BASE, IRQ_KIRKWOOD_USB, EHCI_PHY_NA);
 }
 
+/* Fixup ethernet clocks for DT based kirkwood platforms.
+ * This is required because if the clock is not kept running, the
+ * Interface will forget its MAC address.
+ */
+#ifdef CONFIG_OF
+void __init kirkwood_eth_clock_fixup(void)
+{
+	struct device_node *np;
+
+	np = of_find_node_by_name(NULL, "egiga0");
+	if (np && of_device_is_available(np))
+		clk_prepare_enable(ge0);
+	of_node_put(np);
+
+	np = of_find_node_by_name(NULL, "egiga1");
+	if (np && of_device_is_available(np))
+		clk_prepare_enable(ge1);
+	of_node_put(np);
+
+}
+#endif
 
 /*****************************************************************************
  * GE00
diff --git a/arch/arm/mach-kirkwood/common.h b/arch/arm/mach-kirkwood/common.h
index 8aab1ae..7183718 100644
--- a/arch/arm/mach-kirkwood/common.h
+++ b/arch/arm/mach-kirkwood/common.h
@@ -36,6 +36,9 @@ void kirkwood_enable_pcie(void);
 void kirkwood_pcie_id(u32 *dev, u32 *rev);
 
 void kirkwood_ehci_init(void);
+#ifdef CONFIG_OF
+void kirkwood_eth_clock_fixup(void);
+#endif
 void kirkwood_ge00_init(struct mv643xx_eth_platform_data *eth_data);
 void kirkwood_ge01_init(struct mv643xx_eth_platform_data *eth_data);
 void kirkwood_ge00_switch_init(struct dsa_platform_data *d, int irq);
-- 
1.7.9.5
