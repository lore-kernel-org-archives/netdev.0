From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v2 4/6] kirkwood: Add a clock setup helper for mv643xx ethernet.
Date: Tue, 31 Jul 2012 16:45:27 +0100
Message-ID: <1343749529-17571-5-git-send-email-ian.molton@codethink.co.uk>
References: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:59911 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754230Ab2GaPzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 11:55:12 -0400
In-Reply-To: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an ethernet setup helper function allowing the mv643xx
clock to be kept enabled so that the MAC address(es) are not lost.

Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
---
 arch/arm/mach-kirkwood/board-dt.c |    2 ++
 arch/arm/mach-kirkwood/common.c   |   22 ++++++++++++++++++++++
 arch/arm/mach-kirkwood/common.h   |    3 +++
 3 files changed, 27 insertions(+)

diff --git a/arch/arm/mach-kirkwood/board-dt.c b/arch/arm/mach-kirkwood/board-dt.c
index 9816b85..1bcae22 100644
--- a/arch/arm/mach-kirkwood/board-dt.c
+++ b/arch/arm/mach-kirkwood/board-dt.c
@@ -97,6 +97,8 @@ static void __init kirkwood_dt_init(void)
 
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
