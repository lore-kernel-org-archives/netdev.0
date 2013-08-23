From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v3 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw compatible string
Date: Fri, 23 Aug 2013 14:08:53 +0200
Message-ID: <1377259735-20337-4-git-send-email-zonque@gmail.com>
References: <1377259735-20337-1-git-send-email-zonque@gmail.com>
Cc: bcousson@baylibre.com, nsekhar@ti.com,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, mugunthanvnm@ti.com, vaibhav.bedia@ti.com,
	d-gerlach@ti.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:48149 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755402Ab3HWMJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 08:09:07 -0400
In-Reply-To: <1377259735-20337-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support features that are specific to the AM335x IP, we have
to add hardware types and another compatible string.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |  3 ++-
 drivers/net/ethernet/ti/cpsw.c                 | 32 ++++++++++++++++++++------
 drivers/net/ethernet/ti/cpsw.h                 |  1 +
 3 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 4e5ca54..b717458 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -2,7 +2,8 @@ TI SoC Ethernet Switch Controller Device Tree Bindings
 ------------------------------------------------------
 
 Required properties:
-- compatible		: Should be "ti,cpsw"
+- compatible		: Should be "ti,cpsw" for generic cpsw support, or
+			  "ti,am3352-cpsw" for AM3352 SoCs
 - reg			: physical base address and size of the cpsw
 			  registers map.
 			  An optional third memory region can be supplied if
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index bd0b664..b194529 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -155,6 +155,11 @@ do {								\
 		((priv->data.dual_emac) ? priv->emac_port :	\
 		priv->data.active_slave)
 
+enum {
+	CPSW_TYPE_GENERIC,
+	CPSW_TYPE_AM33XX
+};
+
 static int debug_level;
 module_param(debug_level, int, 0);
 MODULE_PARM_DESC(debug_level, "cpsw debug level (NETIF_MSG bits)");
@@ -1692,17 +1697,36 @@ static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
 	slave->port_vlan = data->dual_emac_res_vlan;
 }
 
+static const struct of_device_id cpsw_of_mtable[] = {
+	{
+		.compatible	= "ti,am3352-cpsw",
+		.data		= (void *) CPSW_TYPE_AM33XX
+	}, {
+		.compatible	= "ti,cpsw",
+		.data		= (void *) CPSW_TYPE_GENERIC
+	},
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, cpsw_of_mtable);
+
 static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			 struct platform_device *pdev)
 {
 	struct device_node *node = pdev->dev.of_node;
+	const struct of_device_id *match;
 	struct device_node *slave_node;
+	unsigned long match_data;
 	int i = 0, ret;
 	u32 prop;
 
-	if (!node)
+	match = of_match_device(cpsw_of_mtable, &pdev->dev);
+
+	if (!node || !match)
 		return -EINVAL;
 
+	match_data = (unsigned long) match->data;
+	data->hw_type = match_data;
+
 	if (of_property_read_u32(node, "slaves", &prop)) {
 		pr_err("Missing slaves property in the DT.\n");
 		return -EINVAL;
@@ -2228,12 +2252,6 @@ static const struct dev_pm_ops cpsw_pm_ops = {
 	.resume		= cpsw_resume,
 };
 
-static const struct of_device_id cpsw_of_mtable[] = {
-	{ .compatible = "ti,cpsw", },
-	{ /* sentinel */ },
-};
-MODULE_DEVICE_TABLE(of, cpsw_of_mtable);
-
 static struct platform_driver cpsw_driver = {
 	.driver = {
 		.name	 = "cpsw",
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
index eb3e101..96c374a 100644
--- a/drivers/net/ethernet/ti/cpsw.h
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -37,6 +37,7 @@ struct cpsw_platform_data {
 	u32	mac_control;	/* Mac control register */
 	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
 	bool	dual_emac;	/* Enable Dual EMAC mode */
+	u32	hw_type;	/* hardware type as specified in 'compatible' */
 };
 
 #endif /* __CPSW_H__ */
-- 
1.8.3.1
