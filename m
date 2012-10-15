From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 4/5] net: cpsw: Add parent<->child relation support between cpsw and mdio
Date: Mon, 15 Oct 2012 21:16:34 +0200
Message-ID: <9a4368fa1264f573072544a34169a3f0f8797989.1350327325.git.richardcochran@gmail.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55767 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab2JOTRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:17:06 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so2514895wib.1
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 12:17:05 -0700 (PDT)
In-Reply-To: <cover.1350327320.git.richardcochran@gmail.com>
In-Reply-To: <cover.1350327320.git.richardcochran@gmail.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaibhav Hiremath <hvaibhav@ti.com>

CPGMAC SubSystem consist of various sub-modules, like, mdio, cpdma,
cpsw, etc... These sub-modules are also used in some of Davinci family
of devices. Now based on requirement, use-case and available technology
nodes the integration of these sub-modules varies across devices.

So coming back to Linux net driver, currently separate and independent
platform devices & drivers for CPSW and MDIO is implemented. In case of
Davinci they both has separate control, from resources perspective,
like clock.

In case of AM33XX, the resources are shared and only one register
bit-field is provided to control module/clock enable/disable, makes it
difficult to handle common resource.

So the solution here implemented in this patch is,

Create parent<->child relationship between both the drivers, making
CPSW as a parent and MDIO as its child and enumerate all the child nodes
under cpsw module.
Both the drivers will function exactly the way it was operating before,
including runtime-pm functionality. No change is required in MDIO driver
(for that matter to any child driver).

As this is only supported during DT boot, the parent<->child relationship
is created and populated in DT execution flow. The only required change
is inside DTS file, making MDIO as a child to CPSW node.

Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index df55e24..fb1a692 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -827,7 +827,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->mac_control = prop;
 
-	for_each_child_of_node(node, slave_node) {
+	for_each_node_by_name(slave_node, "slave") {
 		struct cpsw_slave_data *slave_data = data->slave_data + i;
 		const char *phy_id = NULL;
 		const void *mac_addr = NULL;
@@ -862,6 +862,14 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		i++;
 	}
 
+	/*
+	 * Populate all the child nodes here...
+	 */
+	ret = of_platform_populate(node, NULL, NULL, &pdev->dev);
+	/* We do not want to force this, as in some cases may not have child */
+	if (ret)
+		pr_warn("Doesn't have any child node\n");
+
 	return 0;
 
 error_ret:
@@ -895,6 +903,11 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	priv->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
 	priv->rx_packet_max = max(rx_packet_max, 128);
 
+	/*
+	 * This may be required here for child devices.
+	 */
+	pm_runtime_enable(&pdev->dev);
+
 	if (cpsw_probe_dt(&priv->data, pdev)) {
 		pr_err("cpsw: platform data missing\n");
 		ret = -ENODEV;
@@ -921,7 +934,6 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	for (i = 0; i < data->slaves; i++)
 		priv->slaves[i].slave_num = i;
 
-	pm_runtime_enable(&pdev->dev);
 	priv->clk = clk_get(&pdev->dev, "fck");
 	if (IS_ERR(priv->clk)) {
 		dev_err(&pdev->dev, "fck is not found\n");
-- 
1.7.2.5
