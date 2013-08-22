From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 2/4] net: ethernet: cpsw: add optional third memory region for CONTROL module
Date: Thu, 22 Aug 2013 13:37:26 +0200
Message-ID: <1377171448-27924-3-git-send-email-zonque@gmail.com>
References: <1377171448-27924-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1377171448-27924-1-git-send-email-zonque@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At least the AM33xx SoC has a control module register to configure
details such as the hardware ethernet interface mode.

I'm not sure whether all SoCs which feature the cpsw block have such a
register, so that third memory region is considered optional for now.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |  5 ++++-
 drivers/net/ethernet/ti/cpsw.c                 | 22 ++++++++++++++++++++++
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 05d660e..4e5ca54 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -4,7 +4,10 @@ TI SoC Ethernet Switch Controller Device Tree Bindings
 Required properties:
 - compatible		: Should be "ti,cpsw"
 - reg			: physical base address and size of the cpsw
-			  registers map
+			  registers map.
+			  An optional third memory region can be supplied if
+			  the platform has a control module register to
+			  configure phy interface details
 - interrupts		: property with a value describing the interrupt
 			  number
 - interrupt-parent	: The parent interrupt controller
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 63feaae..4855d8e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -372,6 +372,7 @@ struct cpsw_priv {
 	struct cpsw_platform_data	data;
 	struct cpsw_ss_regs __iomem	*regs;
 	struct cpsw_wr_regs __iomem	*wr_regs;
+	u32 __iomem			*gmii_sel_reg;
 	u8 __iomem			*hw_stats;
 	struct cpsw_host_regs __iomem	*host_port_regs;
 	u32				msg_enable;
@@ -2012,6 +2013,27 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 
+	/* If the control memory region is unspecified, continue without it.
+	 * If it is specified, but we're unable to reserve it, bail. */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
+	if (!res) {
+		dev_err(priv->dev, "error getting control i/o resource\n");
+		goto no_gmii_sel;
+	}
+	if (!devm_request_mem_region(&pdev->dev, res->start, resource_size(res),
+				     ndev->name)) {
+		dev_err(priv->dev, "failed request control i/o region\n");
+		ret = -ENXIO;
+		goto clean_runtime_disable_ret;
+	}
+	priv->gmii_sel_reg = devm_ioremap(&pdev->dev, res->start,
+					  resource_size(res));
+	if (!priv->gmii_sel_reg) {
+		dev_err(priv->dev, "unable to map control i/o region\n");
+		goto clean_runtime_disable_ret;
+	}
+
+no_gmii_sel:
 	memset(&dma_params, 0, sizeof(dma_params));
 	memset(&ale_params, 0, sizeof(ale_params));
 
-- 
1.8.3.1

