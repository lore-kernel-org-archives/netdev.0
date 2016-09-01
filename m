From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 2/2] net/smsc911x: Move interrupt allocation to open/stop
Date: Thu,  1 Sep 2016 11:25:41 -0500
Message-ID: <1472747141-15886-3-git-send-email-jeremy.linton@arm.com>
References: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
Cc: steve.glendinning@shawell.net, sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:35058 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754879AbcIAQZm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 12:25:42 -0400
In-Reply-To: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The /proc/irq/xx information is incorrect for smsc911x because
the request_irq is happening before the register_netdev has the
proper device name. Moving it to the open also fixes the case
of when the device is renamed.

Reported-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 50 +++++++++++++++---------------------
 1 file changed, 20 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 6d6dcfe..8ef9776 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -154,6 +154,8 @@ struct smsc911x_data {
 /* Easy access to information */
 #define __smsc_shift(pdata, reg) ((reg) << ((pdata)->config.shift))
 
+static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id);
+
 static inline u32 __smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
 {
 	if (pdata->config.flags & SMSC911X_USE_32BIT)
@@ -1514,6 +1516,7 @@ static int smsc911x_open(struct net_device *dev)
 	unsigned int temp;
 	unsigned int intcfg;
 	int retval;
+	int irq_flags;
 
 	/* find and start the given phy */
 	if (!dev->phydev) {
@@ -1584,6 +1587,14 @@ static int smsc911x_open(struct net_device *dev)
 	pdata->software_irq_signal = 0;
 	smp_wmb();
 
+	irq_flags = irq_get_trigger_type(dev->irq);
+	if (request_irq(dev->irq, smsc911x_irqhandler,
+			irq_flags | IRQF_SHARED, dev->name, dev)) {
+		SMSC_WARN(pdata, probe,
+			  "Unable to claim requested irq: %d", dev->irq);
+		goto mii_free_out;
+	}
+
 	temp = smsc911x_reg_read(pdata, INT_EN);
 	temp |= INT_EN_SW_INT_EN_;
 	smsc911x_reg_write(pdata, INT_EN, temp);
@@ -1599,7 +1610,7 @@ static int smsc911x_open(struct net_device *dev)
 		netdev_warn(dev, "ISR failed signaling test (IRQ %d)\n",
 			    dev->irq);
 		retval = -ENODEV;
-		goto mii_free_out;
+		goto irq_stop_out;
 	}
 	SMSC_TRACE(pdata, ifup, "IRQ handler passed test using IRQ %d",
 		   dev->irq);
@@ -1645,7 +1656,8 @@ static int smsc911x_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 	return 0;
-
+irq_stop_out:
+	free_irq(dev->irq, dev);
 mii_free_out:
 	phy_disconnect(dev->phydev);
 	dev->phydev = NULL;
@@ -1672,12 +1684,15 @@ static int smsc911x_stop(struct net_device *dev)
 	dev->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
 	smsc911x_tx_update_txcounters(dev);
 
+	free_irq(dev->irq, dev);
+
 	/* Bring the PHY down */
 	if (dev->phydev) {
 		phy_stop(dev->phydev);
 		phy_disconnect(dev->phydev);
 		dev->phydev = NULL;
 	}
+	netif_carrier_off(dev);
 
 	SMSC_TRACE(pdata, ifdown, "Interface stopped");
 	return 0;
@@ -2307,7 +2322,6 @@ static int smsc911x_drv_remove(struct platform_device *pdev)
 	mdiobus_free(pdata->mii_bus);
 
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
 					   "smsc911x-memory");
 	if (!res)
@@ -2392,8 +2406,7 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	struct smsc911x_data *pdata;
 	struct smsc911x_platform_config *config = dev_get_platdata(&pdev->dev);
 	struct resource *res;
-	unsigned int intcfg = 0;
-	int res_size, irq, irq_flags;
+	int res_size, irq;
 	int retval;
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
@@ -2432,7 +2445,6 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 
 	pdata = netdev_priv(dev);
 	dev->irq = irq;
-	irq_flags = irq_get_trigger_type(irq);
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
 
 	pdata->dev = dev;
@@ -2479,38 +2491,18 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	if (retval < 0)
 		goto out_disable_resources;
 
-	/* configure irq polarity and type before connecting isr */
-	if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
-		intcfg |= INT_CFG_IRQ_POL_;
-
-	if (pdata->config.irq_type == SMSC911X_IRQ_TYPE_PUSH_PULL)
-		intcfg |= INT_CFG_IRQ_TYPE_;
-
-	smsc911x_reg_write(pdata, INT_CFG, intcfg);
-
-	/* Ensure interrupts are globally disabled before connecting ISR */
-	smsc911x_disable_irq_chip(dev);
-
-	retval = request_irq(dev->irq, smsc911x_irqhandler,
-			     irq_flags | IRQF_SHARED, dev->name, dev);
-	if (retval) {
-		SMSC_WARN(pdata, probe,
-			  "Unable to claim requested irq: %d", dev->irq);
-		goto out_disable_resources;
-	}
-
 	netif_carrier_off(dev);
 
 	retval = smsc911x_mii_init(pdev, dev);
 	if (retval) {
 		SMSC_WARN(pdata, probe, "Error %i initialising mii", retval);
-		goto out_free_irq;
+		goto out_disable_resources;
 	}
 
 	retval = register_netdev(dev);
 	if (retval) {
 		SMSC_WARN(pdata, probe, "Error %i registering device", retval);
-		goto out_free_irq;
+		goto out_disable_resources;
 	} else {
 		SMSC_TRACE(pdata, probe,
 			   "Network interface: \"%s\"", dev->name);
@@ -2551,8 +2543,6 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 
 	return 0;
 
-out_free_irq:
-	free_irq(dev->irq, dev);
 out_disable_resources:
 	pm_runtime_put(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
-- 
2.5.5
