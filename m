From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH v2 1/2] ARM: imx6: disable deeper idle states when FEC is active w/o HW workaround
Date: Fri,  3 Jun 2016 18:31:19 +0200
Message-ID: <1464971480-9203-1-git-send-email-l.stach@pengutronix.de>
Cc: devicetree@vger.kernel.org, patchwork-lst@pengutronix.de,
	kernel@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Shawn Guo <shawnguo@kernel.org>, Fugang Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:39133 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752216AbcFCQb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 12:31:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i.MX6 Q/DL has an erratum (ERR006687) that prevents the FEC from
waking the CPUs when they are in wait(unclocked) state. As the hardware
workaround isn't applicable to all boards, disable the deeper idle state
when the workaround isn't present and the FEC is in use.

This allows to safely run a kernel with CPUidle enabled on all i.MX6
boards.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
Acked-by: David S. Miller <davem@davemloft.net> (for network changes)
---
v2: Spell out "workaround" to avoid confusion.
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |  3 +++
 arch/arm/mach-imx/cpuidle-imx6q.c                 | 16 +++++++++++++++
 drivers/net/ethernet/freescale/fec.h              |  2 ++
 drivers/net/ethernet/freescale/fec_main.c         | 12 +++++++++++
 include/soc/imx/cpuidle.h                         | 25 +++++++++++++++++++++++
 5 files changed, 58 insertions(+)
 create mode 100644 include/soc/imx/cpuidle.h

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index b037a9d78d93..a1e3693cca16 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -27,6 +27,9 @@ Optional properties:
   number to 1.
 - fsl,magic-packet : If present, indicates that the hardware supports waking
   up via magic packet.
+- fsl,err006687-workaround-present: If present indicates that the system has
+  the hardware workaround for ERR006687 applied and does not need a software
+  workaround.
 
 Optional subnodes:
 - mdio : specifies the mdio bus in the FEC, used as a container for phy nodes
diff --git a/arch/arm/mach-imx/cpuidle-imx6q.c b/arch/arm/mach-imx/cpuidle-imx6q.c
index 353bb8774112..c3cc8ca8d2ff 100644
--- a/arch/arm/mach-imx/cpuidle-imx6q.c
+++ b/arch/arm/mach-imx/cpuidle-imx6q.c
@@ -62,6 +62,22 @@ static struct cpuidle_driver imx6q_cpuidle_driver = {
 	.safe_state_index = 0,
 };
 
+/*
+ * i.MX6 Q/DL has an erratum (ERR006687) that prevents the FEC from waking the
+ * CPUs when they are in wait(unclocked) state. As the hardware workaround isn't
+ * applicable to all boards, disable the deeper idle state when the workaround
+ * isn't present and the FEC is in use.
+ */
+void imx6q_cpuidle_fec_irqs_used(void)
+{
+	imx6q_cpuidle_driver.states[1].disabled = true;
+}
+
+void imx6q_cpuidle_fec_irqs_unused(void)
+{
+	imx6q_cpuidle_driver.states[1].disabled = false;
+}
+
 int __init imx6q_cpuidle_init(void)
 {
 	/* Set INT_MEM_CLK_LPM bit to get a reliable WAIT mode support */
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index f58f9ea51639..dc71a88e9c55 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -442,6 +442,8 @@ struct bufdesc_ex {
 #define FEC_QUIRK_SINGLE_MDIO		(1 << 11)
 /* Controller supports RACC register */
 #define FEC_QUIRK_HAS_RACC		(1 << 12)
+/* Interrupt doesn't wake CPU from deep idle */
+#define FEC_QUIRK_ERR006687		(1 << 13)
 
 struct bufdesc_prop {
 	int qid;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index ca2cccc594fd..8c2110b61684 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -60,6 +60,7 @@
 #include <linux/if_vlan.h>
 #include <linux/pinctrl/consumer.h>
 #include <linux/prefetch.h>
+#include <soc/imx/cpuidle.h>
 
 #include <asm/cacheflush.h>
 
@@ -2820,6 +2821,9 @@ fec_enet_open(struct net_device *ndev)
 	if (ret)
 		goto err_enet_mii_probe;
 
+	if (fep->quirks & FEC_QUIRK_ERR006687)
+		imx6q_cpuidle_fec_irqs_used();
+
 	napi_enable(&fep->napi);
 	phy_start(ndev->phydev);
 	netif_tx_start_all_queues(ndev);
@@ -2855,6 +2859,9 @@ fec_enet_close(struct net_device *ndev)
 
 	phy_disconnect(ndev->phydev);
 
+	if (fep->quirks & FEC_QUIRK_ERR006687)
+		imx6q_cpuidle_fec_irqs_unused();
+
 	fec_enet_clk_enable(ndev, false);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 	pm_runtime_mark_last_busy(&fep->pdev->dev);
@@ -3294,6 +3301,11 @@ fec_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 
+	if ((of_machine_is_compatible("fsl,imx6q") ||
+	     of_machine_is_compatible("fsl,imx6dl")) &&
+	    !of_property_read_bool(np, "fsl,err006687-workaround-present"))
+		fep->quirks |= FEC_QUIRK_ERR006687;
+
 	if (of_get_property(np, "fsl,magic-packet", NULL))
 		fep->wol_flag |= FEC_WOL_HAS_MAGIC_PACKET;
 
diff --git a/include/soc/imx/cpuidle.h b/include/soc/imx/cpuidle.h
new file mode 100644
index 000000000000..986a4823bce1
--- /dev/null
+++ b/include/soc/imx/cpuidle.h
@@ -0,0 +1,25 @@
+/*
+ * Copyright 2016 Pengutronix, <kernel@pengutronix.de>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef __SOC_IMX_CPUIDLE_H__
+#define __SOC_IMX_CPUIDLE_H__
+
+#if defined(CONFIG_CPU_IDLE) && defined(CONFIG_SOC_IMX6Q)
+void imx6q_cpuidle_fec_irqs_used(void);
+void imx6q_cpuidle_fec_irqs_unused(void);
+#else
+void imx6q_cpuidle_fec_irqs_used(void) { }
+void imx6q_cpuidle_fec_irqs_unused(void) { }
+#endif
+
+#endif /* __SOC_IMX_CPUIDLE_H__ */
-- 
2.8.1
