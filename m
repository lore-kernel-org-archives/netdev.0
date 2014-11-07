From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v4 2/8] net: can: c_can: Introduce c_can_driver_data structure
Date: Fri, 7 Nov 2014 16:49:16 +0200
Message-ID: <1415371762-29885-3-git-send-email-rogerq@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:48032 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbaKGOuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 09:50:04 -0500
In-Reply-To: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to have more data than just can_dev_id to be present
in the driver data e.g. TI platforms need RAMINIT register
description. Introduce the c_can_driver_data structure and move
the can_dev_id into it.

Tidy up the way it is used on probe().

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/can/c_can/c_can.h          |  4 +++
 drivers/net/can/c_can/c_can_platform.c | 52 +++++++++++++++++++---------------
 2 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index 99ad1aa..26c975d 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -169,6 +169,10 @@ enum c_can_dev_id {
 	BOSCH_D_CAN,
 };
 
+struct c_can_driver_data {
+	enum c_can_dev_id id;
+};
+
 /* c_can private data structure */
 struct c_can_priv {
 	struct can_priv can;	/* must be the first member */
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index b144e71..1546c2b 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -167,26 +167,34 @@ static void c_can_hw_raminit(const struct c_can_priv *priv, bool enable)
 	}
 }
 
+static struct c_can_driver_data c_can_drvdata = {
+	.id = BOSCH_C_CAN,
+};
+
+static struct c_can_driver_data d_can_drvdata = {
+	.id = BOSCH_D_CAN,
+};
+
 static struct platform_device_id c_can_id_table[] = {
-	[BOSCH_C_CAN_PLATFORM] = {
+	{
 		.name = KBUILD_MODNAME,
-		.driver_data = BOSCH_C_CAN,
+		.driver_data = (kernel_ulong_t)&c_can_drvdata,
 	},
-	[BOSCH_C_CAN] = {
+	{
 		.name = "c_can",
-		.driver_data = BOSCH_C_CAN,
+		.driver_data = (kernel_ulong_t)&c_can_drvdata,
 	},
-	[BOSCH_D_CAN] = {
+	{
 		.name = "d_can",
-		.driver_data = BOSCH_D_CAN,
-	}, {
-	}
+		.driver_data = (kernel_ulong_t)&d_can_drvdata,
+	},
+	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(platform, c_can_id_table);
 
 static const struct of_device_id c_can_of_table[] = {
-	{ .compatible = "bosch,c_can", .data = &c_can_id_table[BOSCH_C_CAN] },
-	{ .compatible = "bosch,d_can", .data = &c_can_id_table[BOSCH_D_CAN] },
+	{ .compatible = "bosch,c_can", .data = &c_can_drvdata },
+	{ .compatible = "bosch,d_can", .data = &d_can_drvdata },
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, c_can_of_table);
@@ -198,21 +206,19 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct c_can_priv *priv;
 	const struct of_device_id *match;
-	const struct platform_device_id *id;
 	struct resource *mem, *res;
 	int irq;
 	struct clk *clk;
-
-	if (pdev->dev.of_node) {
-		match = of_match_device(c_can_of_table, &pdev->dev);
-		if (!match) {
-			dev_err(&pdev->dev, "Failed to find matching dt id\n");
-			ret = -EINVAL;
-			goto exit;
-		}
-		id = match->data;
+	const struct c_can_driver_data *drvdata;
+
+	match = of_match_device(c_can_of_table, &pdev->dev);
+	if (match) {
+		drvdata = match->data;
+	} else if (pdev->id_entry->driver_data) {
+		drvdata = (struct c_can_driver_data *)
+			   pdev->id_entry->driver_data;
 	} else {
-		id = platform_get_device_id(pdev);
+		return -ENODEV;
 	}
 
 	/* get the appropriate clk */
@@ -244,7 +250,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	}
 
 	priv = netdev_priv(dev);
-	switch (id->driver_data) {
+	switch (drvdata->id) {
 	case BOSCH_C_CAN:
 		priv->regs = reg_map_c_can;
 		switch (mem->flags & IORESOURCE_MEM_TYPE_MASK) {
@@ -303,7 +309,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	priv->device = &pdev->dev;
 	priv->can.clock.freq = clk_get_rate(clk);
 	priv->priv = clk;
-	priv->type = id->driver_data;
+	priv->type = drvdata->id;
 
 	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-- 
1.8.3.2
