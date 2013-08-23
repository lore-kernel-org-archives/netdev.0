From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v6 2/5] net: ethernet: cpsw: add optional third memory region for CONTROL module
Date: Fri, 23 Aug 2013 21:32:07 +0200
Message-ID: <1377286330-29663-3-git-send-email-zonque@gmail.com>
References: <1377286330-29663-1-git-send-email-zonque@gmail.com>
Cc: bcousson@baylibre.com, nsekhar@ti.com,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, mugunthanvnm@ti.com, vaibhav.bedia@ti.com,
	d-gerlach@ti.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:48885 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754926Ab3HWTcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 15:32:22 -0400
In-Reply-To: <1377286330-29663-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least the AM33xx SoC has a control module register to configure
details such as the hardware ethernet interface mode.

I'm not sure whether all SoCs which feature the cpsw block have such a
register, so that third memory region is considered optional for now.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |  5 ++++-
 drivers/net/ethernet/ti/cpsw.c                 | 11 +++++++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

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
index fc3263f..485df80 100644
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
@@ -1989,6 +1990,16 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 
+	/* Don't fail hard if the optional control memory region is missing */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
+	if (res) {
+		priv->gmii_sel_reg = devm_ioremap_resource(&pdev->dev, res);
+		if (IS_ERR(priv->gmii_sel_reg)) {
+			ret = PTR_ERR(priv->gmii_sel_reg);
+			goto clean_runtime_disable_ret;
+		}
+	}
+
 	memset(&dma_params, 0, sizeof(dma_params));
 	memset(&ale_params, 0, sizeof(ale_params));
 
-- 
1.8.3.1
