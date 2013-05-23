From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: can: use platform_{get,set}_drvdata()
Date: Thu, 23 May 2013 19:47:58 +0900
Message-ID: <003901ce57a2$fd0f7450$f72e5cf0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Wolfgang Grandegger' <wg@grandegger.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-language: ko
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Also, unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/can/bfin_can.c                    |   10 ++++------
 drivers/net/can/cc770/cc770_isa.c             |    5 ++---
 drivers/net/can/cc770/cc770_platform.c        |    4 ++--
 drivers/net/can/grcan.c                       |    5 ++---
 drivers/net/can/mscan/mpc5xxx_can.c           |   10 ++++------
 drivers/net/can/sja1000/sja1000_isa.c         |    5 ++---
 drivers/net/can/sja1000/sja1000_of_platform.c |    6 ++----
 drivers/net/can/sja1000/sja1000_platform.c    |    5 ++---
 8 files changed, 20 insertions(+), 30 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index d4a15e8..a2700d2 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -580,7 +580,7 @@ static int bfin_can_probe(struct platform_device *pdev)
 	priv->pin_list = pdata;
 	priv->can.clock.freq = get_sclk();
 
-	dev_set_drvdata(&pdev->dev, dev);
+	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	dev->flags |= IFF_ECHO;	/* we support local echo */
@@ -613,7 +613,7 @@ exit:
 
 static int bfin_can_remove(struct platform_device *pdev)
 {
-	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct bfin_can_priv *priv = netdev_priv(dev);
 	struct resource *res;
 
@@ -621,8 +621,6 @@ static int bfin_can_remove(struct platform_device *pdev)
 
 	unregister_candev(dev);
 
-	dev_set_drvdata(&pdev->dev, NULL);
-
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, resource_size(res));
 
@@ -635,7 +633,7 @@ static int bfin_can_remove(struct platform_device *pdev)
 #ifdef CONFIG_PM
 static int bfin_can_suspend(struct platform_device *pdev, pm_message_t mesg)
 {
-	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct bfin_can_priv *priv = netdev_priv(dev);
 	struct bfin_can_regs __iomem *reg = priv->membase;
 	int timeout = BFIN_CAN_TIMEOUT;
@@ -658,7 +656,7 @@ static int bfin_can_suspend(struct platform_device *pdev, pm_message_t mesg)
 
 static int bfin_can_resume(struct platform_device *pdev)
 {
-	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct bfin_can_priv *priv = netdev_priv(dev);
 	struct bfin_can_regs __iomem *reg = priv->membase;
 
diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
index 8eaaac8..87a47c0 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -265,7 +265,7 @@ static int cc770_isa_probe(struct platform_device *pdev)
 	else
 		priv->clkout = COR_DEFAULT;
 
-	dev_set_drvdata(&pdev->dev, dev);
+	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = register_cc770dev(dev);
@@ -293,12 +293,11 @@ static int cc770_isa_probe(struct platform_device *pdev)
 
 static int cc770_isa_remove(struct platform_device *pdev)
 {
-	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct cc770_priv *priv = netdev_priv(dev);
 	int idx = pdev->id;
 
 	unregister_cc770dev(dev);
-	dev_set_drvdata(&pdev->dev, NULL);
 
 	if (mem[idx]) {
 		iounmap(priv->reg_base);
diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/cc770/cc770_platform.c
index d0f6bfc..034bdd8 100644
--- a/drivers/net/can/cc770/cc770_platform.c
+++ b/drivers/net/can/cc770/cc770_platform.c
@@ -216,7 +216,7 @@ static int cc770_platform_probe(struct platform_device *pdev)
 		 priv->reg_base, dev->irq, priv->can.clock.freq,
 		 priv->cpu_interface, priv->bus_config, priv->clkout);
 
-	dev_set_drvdata(&pdev->dev, dev);
+	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = register_cc770dev(dev);
@@ -240,7 +240,7 @@ exit_release_mem:
 
 static int cc770_platform_remove(struct platform_device *pdev)
 {
-	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct cc770_priv *priv = netdev_priv(dev);
 	struct resource *mem;
 
diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index 9e9d0d6..6aa737a 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -1646,7 +1646,7 @@ static int grcan_setup_netdev(struct platform_device *ofdev,
 	if (err)
 		goto exit_free_candev;
 
-	dev_set_drvdata(&ofdev->dev, dev);
+	platform_set_drvdata(ofdev, dev);
 
 	/* Reset device to allow bit-timing to be set. No need to call
 	 * grcan_reset at this stage. That is done in grcan_open.
@@ -1715,13 +1715,12 @@ exit_error:
 
 static int grcan_remove(struct platform_device *ofdev)
 {
-	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct net_device *dev = platform_get_drvdata(ofdev);
 	struct grcan_priv *priv = netdev_priv(dev);
 
 	unregister_candev(dev); /* Will in turn call grcan_close */
 
 	irq_dispose_mapping(dev->irq);
-	dev_set_drvdata(&ofdev->dev, NULL);
 	netif_napi_del(&priv->napi);
 	free_candev(dev);
 
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 668850e..5b0ee8e 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -302,7 +302,7 @@ static int mpc5xxx_can_probe(struct platform_device *ofdev)
 		goto exit_free_mscan;
 	}
 
-	dev_set_drvdata(&ofdev->dev, dev);
+	platform_set_drvdata(ofdev, dev);
 
 	dev_info(&ofdev->dev, "MSCAN at 0x%p, irq %d, clock %d Hz\n",
 		 priv->reg_base, dev->irq, priv->can.clock.freq);
@@ -321,11 +321,9 @@ exit_unmap_mem:
 
 static int mpc5xxx_can_remove(struct platform_device *ofdev)
 {
-	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct net_device *dev = platform_get_drvdata(ofdev);
 	struct mscan_priv *priv = netdev_priv(dev);
 
-	dev_set_drvdata(&ofdev->dev, NULL);
-
 	unregister_mscandev(dev);
 	iounmap(priv->reg_base);
 	irq_dispose_mapping(dev->irq);
@@ -338,7 +336,7 @@ static int mpc5xxx_can_remove(struct platform_device *ofdev)
 static struct mscan_regs saved_regs;
 static int mpc5xxx_can_suspend(struct platform_device *ofdev, pm_message_t state)
 {
-	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct net_device *dev = platform_get_drvdata(ofdev);
 	struct mscan_priv *priv = netdev_priv(dev);
 	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
 
@@ -349,7 +347,7 @@ static int mpc5xxx_can_suspend(struct platform_device *ofdev, pm_message_t state
 
 static int mpc5xxx_can_resume(struct platform_device *ofdev)
 {
-	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct net_device *dev = platform_get_drvdata(ofdev);
 	struct mscan_priv *priv = netdev_priv(dev);
 	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
 
diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sja1000/sja1000_isa.c
index 5c8da46..06a2823 100644
--- a/drivers/net/can/sja1000/sja1000_isa.c
+++ b/drivers/net/can/sja1000/sja1000_isa.c
@@ -197,7 +197,7 @@ static int sja1000_isa_probe(struct platform_device *pdev)
 	else
 		priv->cdr = CDR_DEFAULT;
 
-	dev_set_drvdata(&pdev->dev, dev);
+	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = register_sja1000dev(dev);
@@ -225,12 +225,11 @@ static int sja1000_isa_probe(struct platform_device *pdev)
 
 static int sja1000_isa_remove(struct platform_device *pdev)
 {
-	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sja1000_priv *priv = netdev_priv(dev);
 	int idx = pdev->id;
 
 	unregister_sja1000dev(dev);
-	dev_set_drvdata(&pdev->dev, NULL);
 
 	if (mem[idx]) {
 		iounmap(priv->reg_base);
diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 8e0c4a0..31ad339 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -72,13 +72,11 @@ static void sja1000_ofp_write_reg(const struct sja1000_priv *priv,
 
 static int sja1000_ofp_remove(struct platform_device *ofdev)
 {
-	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
+	struct net_device *dev = platform_get_drvdata(ofdev);
 	struct sja1000_priv *priv = netdev_priv(dev);
 	struct device_node *np = ofdev->dev.of_node;
 	struct resource res;
 
-	dev_set_drvdata(&ofdev->dev, NULL);
-
 	unregister_sja1000dev(dev);
 	free_sja1000dev(dev);
 	iounmap(priv->reg_base);
@@ -181,7 +179,7 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
 		 priv->reg_base, dev->irq, priv->can.clock.freq,
 		 priv->ocr, priv->cdr);
 
-	dev_set_drvdata(&ofdev->dev, dev);
+	platform_set_drvdata(ofdev, dev);
 	SET_NETDEV_DEV(dev, &ofdev->dev);
 
 	err = register_sja1000dev(dev);
diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 21619bb..8e259c5 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -135,7 +135,7 @@ static int sp_probe(struct platform_device *pdev)
 		break;
 	}
 
-	dev_set_drvdata(&pdev->dev, dev);
+	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = register_sja1000dev(dev);
@@ -161,12 +161,11 @@ static int sp_probe(struct platform_device *pdev)
 
 static int sp_remove(struct platform_device *pdev)
 {
-	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sja1000_priv *priv = netdev_priv(dev);
 	struct resource *res;
 
 	unregister_sja1000dev(dev);
-	dev_set_drvdata(&pdev->dev, NULL);
 
 	if (priv->reg_base)
 		iounmap(priv->reg_base);
-- 
1.7.10.4


