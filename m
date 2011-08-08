From: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
Subject: [PATCH 4/4] ARM:FlexCAN Controller for platform_ type
Date: Mon, 8 Aug 2011 20:31:00 +0530
Message-ID: <1312815660-25828-1-git-send-email-bhaskar.upadhaya@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
To: <netdev@vger.kernel.org>, <mkl@pengutronix.de>, <holt@sgi.com>,
	<wg@grandegger.com>, <davem@davemloft.net>,
	<linuxppc-release@linux.freescale.net>, <b22300@freescale.com>,
	<socketcan-
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:21703
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754184Ab1HHPDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 11:03:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rearrange the existing ARM based FlexCAN implementation, so as to
support powerpc based FlexCAN on P1010.
Signed-off-by: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
---
 Based on http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
 Branch master

 drivers/net/can/flexcan.c       |  105 ++++++++++++++-------------------------
 drivers/net/can/flexcan_iface.c |   99 ++++++++++++++++++++++++++++++++++++
 2 files changed, 136 insertions(+), 68 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 1c1af24..b4d9afb 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -993,37 +993,29 @@ void __devexit unregister_flexcandev(struct net_device *dev)
 	unregister_candev(dev);
 }
 
-static int __devinit flexcan_probe(struct platform_device *pdev)
+int flexcan_dev_init(struct device *pdev, struct flexcan_resource flexcan_res,
+		 struct flexcan_interface *flexcan_ops)
 {
 	struct net_device *dev;
 	struct flexcan_priv *priv;
-	struct resource *mem;
 	struct clk *clk;
 	void __iomem *base;
-	resource_size_t mem_size;
-	int err, irq;
+	int err;
 
-	clk = clk_get(&pdev->dev, NULL);
+	clk = flexcan_ops->clk_get(pdev, NULL);
 	if (IS_ERR(clk)) {
-		dev_err(&pdev->dev, "no clock defined\n");
+		dev_err(pdev, "no clock defined\n");
 		err = PTR_ERR(clk);
 		goto failed_clock;
 	}
 
-	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	irq = platform_get_irq(pdev, 0);
-	if (!mem || irq <= 0) {
-		err = -ENODEV;
-		goto failed_get;
-	}
-
-	mem_size = resource_size(mem);
-	if (!request_mem_region(mem->start, mem_size, pdev->name)) {
+	if (!request_mem_region
+	    (flexcan_res.addr, flexcan_res.size, flexcan_res.drv_name)) {
 		err = -EBUSY;
-		goto failed_get;
+		goto failed_req;
 	}
 
-	base = ioremap(mem->start, mem_size);
+	base = ioremap(flexcan_res.addr, flexcan_res.size);
 	if (!base) {
 		err = -ENOMEM;
 		goto failed_map;
@@ -1036,11 +1028,11 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 	}
 
 	dev->netdev_ops = &flexcan_netdev_ops;
-	dev->irq = irq;
+	dev->irq = flexcan_res.irq;
 	dev->flags |= IFF_ECHO; /* we support local echo in hardware */
 
 	priv = netdev_priv(dev);
-	priv->can.clock.freq = clk_get_rate(clk);
+	priv->can.clock.freq = flexcan_ops->clk_get_rate(clk);
 	priv->can.bittiming_const = &flexcan_bittiming_const;
 	priv->can.do_set_mode = flexcan_set_mode;
 	priv->can.do_get_berr_counter = flexcan_get_berr_counter;
@@ -1050,20 +1042,21 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 	priv->base = base;
 	priv->dev = dev;
 	priv->clk = clk;
-	priv->pdata = pdev->dev.platform_data;
+	priv->pdata = pdev->platform_data;
+	priv->flexcan_ops = flexcan_ops;
 
 	netif_napi_add(dev, &priv->napi, flexcan_poll, FLEXCAN_NAPI_WEIGHT);
 
-	dev_set_drvdata(&pdev->dev, dev);
-	SET_NETDEV_DEV(dev, &pdev->dev);
+	dev_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, pdev);
 
 	err = register_flexcandev(dev);
 	if (err) {
-		dev_err(&pdev->dev, "registering netdev failed\n");
+		dev_err(pdev, "registering netdev failed\n");
 		goto failed_register;
 	}
 
-	dev_info(&pdev->dev, "device registered (reg_base=%p, irq=%d)\n",
+	dev_info(pdev, "device registered (reg_base=%p, irq=%d)\n",
 		 priv->base, dev->irq);
 
 	return 0;
@@ -1073,55 +1066,31 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
  failed_alloc:
 	iounmap(base);
  failed_map:
-	release_mem_region(mem->start, mem_size);
- failed_get:
+	release_mem_region(flexcan_res.addr, flexcan_res.size);
+ failed_req:
 	clk_put(clk);
  failed_clock:
 	return err;
 }
 
-static int __devexit flexcan_remove(struct platform_device *pdev)
+void flexcan_reg_dump(struct net_device *dev)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct flexcan_priv *priv = netdev_priv(dev);
-	struct resource *mem;
-
-	unregister_flexcandev(dev);
-	platform_set_drvdata(pdev, NULL);
-	iounmap(priv->base);
-
-	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(mem->start, resource_size(mem));
-
-	clk_put(priv->clk);
-
-	free_candev(dev);
-
-	return 0;
-}
-
-static struct platform_driver flexcan_driver = {
-	.driver.name = DRV_NAME,
-	.probe = flexcan_probe,
-	.remove = __devexit_p(flexcan_remove),
-};
-
-static int __init flexcan_init(void)
-{
-	pr_info("%s netdevice driver\n", DRV_NAME);
-	return platform_driver_register(&flexcan_driver);
-}
+	const struct flexcan_priv *priv = netdev_priv(dev);
+	struct flexcan_regs __iomem *regs = priv->base;
 
-static void __exit flexcan_exit(void)
-{
-	platform_driver_unregister(&flexcan_driver);
-	pr_info("%s: driver removed\n", DRV_NAME);
+	dev_dbg(dev->dev.parent, "can-mcr 0x%x \r\n can-ctrl 0x%x \r\n"
+			"can-ecr 0x%x \r\n can-esr 0x%x \r\n"
+			"can-rxgmask 0x%x \r\n can-rx14mask 0x%x \r\n"
+			"can-rx15mask 0x%x \r\n can-imask1 0x%x \r\n"
+			"can-iflag1 0x%x \r\n"
+			"in  func <%s> line <%d> \r\n",
+			flexcan_read(&regs->mcr),
+			flexcan_read(&regs->ctrl),
+			flexcan_read(&regs->ecr),
+			flexcan_read(&regs->esr),
+			flexcan_read(&regs->rxgmask),
+			flexcan_read(&regs->rx14mask),
+			flexcan_read(&regs->rx15mask),
+			flexcan_read(&regs->imask1),
+			flexcan_read(&regs->iflag1), __func__, __LINE__);
 }
-
-module_init(flexcan_init);
-module_exit(flexcan_exit);
-
-MODULE_AUTHOR("Sascha Hauer <kernel@pengutronix.de>, "
-	      "Marc Kleine-Budde <kernel@pengutronix.de>");
-MODULE_LICENSE("GPL v2");
-MODULE_DESCRIPTION("CAN port driver for flexcan based chip");
diff --git a/drivers/net/can/flexcan_iface.c b/drivers/net/can/flexcan_iface.c
index 0c5f6dd..faa6c07 100644
--- a/drivers/net/can/flexcan_iface.c
+++ b/drivers/net/can/flexcan_iface.c
@@ -180,7 +180,55 @@ failed_req:
 	return err;
 }
 
+/**
+ * flexcan_plt_resource_init - initialize the resources for
+ *				"platform" type architecture like "ARM"
+ * @flexcan_res: input buffer filled with address for accessing h/w registers
+ *		of CAN
+ * @pdev: the CAN device to be used
+ * @flexcan_ops: input buffer containing different utility functions
+ *
+ * fills the flexcan_res with the address detail
+ * for accessing the h/w registers of FlexCAN block.
+ * flexcan_ops is filled with different clock functions and normal read/write
+ *
+ * Return value
+ *    - On Success
+ *	       0
+ *    - On Failure
+ *	   error value
+ */
+static int flexcan_plt_resource_init(struct flexcan_resource *flexcan_res,
+				 struct platform_device *pdev,
+				 struct flexcan_interface *flexcan_ops)
+{
+	int err, irq;
+	resource_size_t mem_size;
+	struct resource *mem;
+
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	irq = platform_get_irq(pdev, 0);
+	if (!mem || irq <= 0) {
+		dev_err(&pdev->dev, "Cannot map to irq\n");
+		err = -ENODEV;
+		goto failed_get;
+	}
+
+	mem_size = resource_size(mem);
+	flexcan_res->addr = mem->start;
+	flexcan_res->size = mem_size;
+	flexcan_res->drv_name = pdev->name;
+
+	flexcan_ops->clk_enable = clk_enable;
+	flexcan_ops->clk_disable = clk_disable;
+	flexcan_ops->clk_get_rate = clk_get_rate;
+	flexcan_ops->clk_get = clk_get;
+	flexcan_ops->clk_put = clk_put;
+	return 0;
 
+failed_get:
+	return err;
+}
 
 /**
  * flexcan_probe - performs the resource initialization
@@ -212,6 +260,15 @@ static int flexcan_probe(struct platform_device *pdev)
 			err = -EINVAL;
 			goto failed_req;
 		}
+	} else {
+		err = flexcan_plt_resource_init(&flexcan_res, pdev,
+						&flexcan_ops);
+		if (err) {
+			dev_err(&pdev->dev, "Flexcan Initialization"
+				 "failed with err (%d)\n", err);
+			err = -EINVAL;
+			goto failed_req;
+		}
 	}
 
 	err = flexcan_dev_init(&pdev->dev, flexcan_res, &flexcan_ops);
@@ -251,6 +308,9 @@ static int flexcan_remove(struct platform_device *pdev)
 		addr = of_translate_address(pdev->dev.of_node,
 		    of_get_address(pdev->dev.of_node, 0, &size, NULL));
 		release_mem_region(addr, size);
+	} else {
+		mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+		release_mem_region(addr, size);
 	}	clk_put(priv->clk);
 
 	platform_set_drvdata(pdev, NULL);
@@ -259,3 +319,42 @@ static int flexcan_remove(struct platform_device *pdev)
 	return 0;
 }
 
+
+static struct of_device_id flexcan_match[] = {
+	{
+	 .compatible = "fsl,flexcan-v1.0",
+	 },
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, flexcan_match);
+
+static struct platform_driver flexcan_driver = {
+	.driver = {
+		.name = "DRV_NAME",
+		.owner = THIS_MODULE,
+#ifdef CONFIG_OF
+		.of_match_table = flexcan_match,
+#endif
+	},
+	.probe = flexcan_probe,
+	.remove = flexcan_remove,
+};
+
+static int __init flexcan_init(void)
+{
+	return platform_driver_register(&flexcan_driver);
+}
+
+static void __exit flexcan_exit(void)
+{
+	platform_driver_unregister(&flexcan_driver);
+}
+
+module_init(flexcan_init);
+module_exit(flexcan_exit);
+
+MODULE_AUTHOR("Sascha Hauer <kernel@pengutronix.de>, "
+		"Marc Kleine-Budde <kernel@pengutronix.de>");
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("CAN port driver for flexcan based chip");
-- 
1.5.6.5


