From: Andrew Bresticker <abrestic@chromium.org>
Subject: [PATCH V2 2/2] stmmac: Add IMG Pistachio platform glue layer
Date: Mon,  6 Apr 2015 14:42:38 -0700
Message-ID: <1428356558-18367-2-git-send-email-abrestic@chromium.org>
References: <1428356558-18367-1-git-send-email-abrestic@chromium.org>
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Bresticker <abrestic@chromium.org>,
	Govindraj Raja <govindraj.raja@imgtec.com>,
	James Hartley <james.hartley@imgtec.com>
To: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428356558-18367-1-git-send-email-abrestic@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the moment, the only additional setup required for the DWMAC
on the IMG Pistachio SoC is to request and enable a separate gate
clock for the register interface.

Signed-off-by: Andrew Bresticker <abrestic@chromium.org>
Signed-off-by: Govindraj Raja <govindraj.raja@imgtec.com>
Cc: James Hartley <james.hartley@imgtec.com>
---
Changes from v1:
 - Do not potentially assign an error pointer to pdata->sys_clk
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  3 +-
 .../net/ethernet/stmicro/stmmac/dwmac-pistachio.c  | 59 ++++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  1 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  1 +
 4 files changed, 63 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-pistachio.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 73c2715..8efb622 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -6,7 +6,8 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 
 obj-$(CONFIG_STMMAC_PLATFORM) += stmmac-platform.o
 stmmac-platform-objs:= stmmac_platform.o dwmac-meson.o dwmac-sunxi.o	\
-		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o
+		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o		\
+		       dwmac-pistachio.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-pistachio.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-pistachio.c
new file mode 100644
index 0000000..5e0b958
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-pistachio.c
@@ -0,0 +1,59 @@
+/*
+ * IMG Pistachio DWMAC glue layer
+ *
+ * Copyright (C) 2015 Google, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+#include <linux/clk.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/stmmac.h>
+
+struct pistachio_dwmac_priv_data {
+	struct clk *sys_clk;
+};
+
+static void *pistachio_dwmac_setup(struct platform_device *pdev)
+{
+	struct pistachio_dwmac_priv_data *pdata;
+	struct clk *clk;
+
+	pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
+	if (!pdata)
+		return ERR_PTR(-ENOMEM);
+
+	clk = devm_clk_get(&pdev->dev, "sys");
+	if (IS_ERR(clk)) {
+		dev_err(&pdev->dev, "Failed to get sys clock: %ld\n",
+			PTR_ERR(clk));
+		return clk;
+	}
+	pdata->sys_clk = clk;
+
+	return pdata;
+}
+
+static int pistachio_dwmac_init(struct platform_device *pdev, void *priv)
+{
+	struct pistachio_dwmac_priv_data *pdata = priv;
+
+	return clk_prepare_enable(pdata->sys_clk);
+}
+
+static void pistachio_dwmac_exit(struct platform_device *pdev, void *priv)
+{
+	struct pistachio_dwmac_priv_data *pdata = priv;
+
+	clk_disable_unprepare(pdata->sys_clk);
+}
+
+const struct stmmac_of_data pistachio_dwmac_data = {
+	.setup = pistachio_dwmac_setup,
+	.init = pistachio_dwmac_init,
+	.exit = pistachio_dwmac_exit,
+	.has_gmac = true,
+};
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index f9b42f1..d5de361 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -34,6 +34,7 @@
 static const struct of_device_id stmmac_dt_ids[] = {
 	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
+	{ .compatible = "img,pistachio-dwmac", .data = &pistachio_dwmac_data},
 	{ .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},
 	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
 	{ .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 093eb99..101e635 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -25,5 +25,6 @@ extern const struct stmmac_of_data stih4xx_dwmac_data;
 extern const struct stmmac_of_data stid127_dwmac_data;
 extern const struct stmmac_of_data socfpga_gmac_data;
 extern const struct stmmac_of_data rk3288_gmac_data;
+extern const struct stmmac_of_data pistachio_dwmac_data;
 
 #endif /* __STMMAC_PLATFORM_H__ */
-- 
2.2.0.rc0.207.ga3a616c
