From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: RE: [PATCH] ep93xx_eth.c: general cleanup
Date: Wed, 16 Dec 2009 12:29:38 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200ECE7@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Lennert Buytenhek" <kernel@wantstofly.org>,
	"David Miller" <davem@davemloft.net>
To: "kernel list" <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762572AbZLPR3n@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

General cleanup of the ep93xx_eth driver.

1) Use pr_fmt() to prefix the module name and __func__ to the error 
   messages.
2) <linux/io.h> instead of <asm/io.h>
3) <mach/hardware.h> instead of <mach/ep93xx-regs.h> and <mach/platform.h>
4) Remove the DRV_MODULE_NAME and DRV_MODULE_VERSION defines and just use
   the raw string data in ep93xx_get_drvinfo().
5) Move the ep93xx_mdio_read (and ep93xx_mdio_write) function to eliminate
   the function prototype.
6) Change all the printk(<level> messages to pr_<level> and remove the 
   __func__ argument.
7) Use platform_get_{resource/irq} to get the platform resources and add
   an error check.
8) Use resource_size() for request_mem_region() and ioremap().
9) Use %pM to print the MAC address at the end of the probe.
10) Use dev->dev_addr not data->dev_addr for the MAC argument because a
   random address could be used if the platform does not supply one.
11) Remove unnecessary noise in ep93xx_eth_init_module().

The message at the end of the probe is left as a printk since it displays
cleaner without the function name that would be displayed with pr_info().

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Lennert Buytenhek <kernel@wantstofly.org>
Cc: David S. Miller <davem@davemloft.net>

---

V2 - Missed the resource check and resource_size()

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index b25467a..c949f9a 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -9,6 +9,8 @@
  * (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": %s: " fmt, __func__
+
 #include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -20,12 +22,9 @@
 #include <linux/moduleparam.h>
 #include <linux/platform_device.h>
 #include <linux/delay.h>
-#include <mach/ep93xx-regs.h>
-#include <mach/platform.h>
-#include <asm/io.h>
+#include <linux/io.h>
 
-#define DRV_MODULE_NAME		"ep93xx-eth"
-#define DRV_MODULE_VERSION	"0.1"
+#include <mach/hardware.h>
 
 #define RX_QUEUE_ENTRIES	64
 #define TX_QUEUE_ENTRIES	8
@@ -185,7 +184,47 @@ struct ep93xx_priv
 #define wrw(ep, off, val)	__raw_writew((val), (ep)->base_addr + (off))
 #define wrl(ep, off, val)	__raw_writel((val), (ep)->base_addr + (off))
 
-static int ep93xx_mdio_read(struct net_device *dev, int phy_id, int reg);
+static int ep93xx_mdio_read(struct net_device *dev, int phy_id, int reg)
+{
+	struct ep93xx_priv *ep = netdev_priv(dev);
+	int data;
+	int i;
+
+	wrl(ep, REG_MIICMD, REG_MIICMD_READ | (phy_id << 5) | reg);
+
+	for (i = 0; i < 10; i++) {
+		if ((rdl(ep, REG_MIISTS) & REG_MIISTS_BUSY) == 0)
+			break;
+		msleep(1);
+	}
+
+	if (i == 10) {
+		pr_info("mdio read timed out\n");
+		data = 0xffff;
+	} else {
+		data = rdl(ep, REG_MIIDATA);
+	}
+
+	return data;
+}
+
+static void ep93xx_mdio_write(struct net_device *dev, int phy_id, int reg, int data)
+{
+	struct ep93xx_priv *ep = netdev_priv(dev);
+	int i;
+
+	wrl(ep, REG_MIIDATA, data);
+	wrl(ep, REG_MIICMD, REG_MIICMD_WRITE | (phy_id << 5) | reg);
+
+	for (i = 0; i < 10; i++) {
+		if ((rdl(ep, REG_MIISTS) & REG_MIISTS_BUSY) == 0)
+			break;
+		msleep(1);
+	}
+
+	if (i == 10)
+		pr_info("mdio write timed out\n");
+}
 
 static struct net_device_stats *ep93xx_get_stats(struct net_device *dev)
 {
@@ -217,14 +256,11 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 		rstat->rstat1 = 0;
 
 		if (!(rstat0 & RSTAT0_EOF))
-			printk(KERN_CRIT "ep93xx_rx: not end-of-frame "
-					 " %.8x %.8x\n", rstat0, rstat1);
+			pr_crit("not end-of-frame %.8x %.8x\n", rstat0, rstat1);
 		if (!(rstat0 & RSTAT0_EOB))
-			printk(KERN_CRIT "ep93xx_rx: not end-of-buffer "
-					 " %.8x %.8x\n", rstat0, rstat1);
+			pr_crit("not end-of-buffer %.8x %.8x\n", rstat0, rstat1);
 		if ((rstat1 & RSTAT1_BUFFER_INDEX) >> 16 != entry)
-			printk(KERN_CRIT "ep93xx_rx: entry mismatch "
-					 " %.8x %.8x\n", rstat0, rstat1);
+			pr_crit("entry mismatch %.8x %.8x\n", rstat0, rstat1);
 
 		if (!(rstat0 & RSTAT0_RWE)) {
 			ep->stats.rx_errors++;
@@ -241,8 +277,7 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 
 		length = rstat1 & RSTAT1_FRAME_LENGTH;
 		if (length > MAX_PKT_SIZE) {
-			printk(KERN_NOTICE "ep93xx_rx: invalid length "
-					 " %.8x %.8x\n", rstat0, rstat1);
+			pr_notice("invalid length %.8x %.8x\n", rstat0, rstat1);
 			goto err;
 		}
 
@@ -371,11 +406,9 @@ static void ep93xx_tx_complete(struct net_device *dev)
 		tstat->tstat0 = 0;
 
 		if (tstat0 & TSTAT0_FA)
-			printk(KERN_CRIT "ep93xx_tx_complete: frame aborted "
-					 " %.8x\n", tstat0);
+			pr_crit("frame aborted %.8x\n", tstat0);
 		if ((tstat0 & TSTAT0_BUFFER_INDEX) != entry)
-			printk(KERN_CRIT "ep93xx_tx_complete: entry mismatch "
-					 " %.8x\n", tstat0);
+			pr_crit("entry mismatch %.8x\n", tstat0);
 
 		if (tstat0 & TSTAT0_TXWE) {
 			int length = ep->descs->tdesc[entry].tdesc1 & 0xfff;
@@ -536,7 +569,7 @@ static int ep93xx_start_hw(struct net_device *dev)
 	}
 
 	if (i == 10) {
-		printk(KERN_CRIT DRV_MODULE_NAME ": hw failed to reset\n");
+		pr_crit("hw failed to reset\n");
 		return 1;
 	}
 
@@ -581,7 +614,7 @@ static int ep93xx_start_hw(struct net_device *dev)
 	}
 
 	if (i == 10) {
-		printk(KERN_CRIT DRV_MODULE_NAME ": hw failed to start\n");
+		pr_crit("hw failed to start\n");
 		return 1;
 	}
 
@@ -617,7 +650,7 @@ static void ep93xx_stop_hw(struct net_device *dev)
 	}
 
 	if (i == 10)
-		printk(KERN_CRIT DRV_MODULE_NAME ": hw failed to reset\n");
+		pr_crit("hw failed to reset\n");
 }
 
 static int ep93xx_open(struct net_device *dev)
@@ -681,52 +714,10 @@ static int ep93xx_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return generic_mii_ioctl(&ep->mii, data, cmd, NULL);
 }
 
-static int ep93xx_mdio_read(struct net_device *dev, int phy_id, int reg)
-{
-	struct ep93xx_priv *ep = netdev_priv(dev);
-	int data;
-	int i;
-
-	wrl(ep, REG_MIICMD, REG_MIICMD_READ | (phy_id << 5) | reg);
-
-	for (i = 0; i < 10; i++) {
-		if ((rdl(ep, REG_MIISTS) & REG_MIISTS_BUSY) == 0)
-			break;
-		msleep(1);
-	}
-
-	if (i == 10) {
-		printk(KERN_INFO DRV_MODULE_NAME ": mdio read timed out\n");
-		data = 0xffff;
-	} else {
-		data = rdl(ep, REG_MIIDATA);
-	}
-
-	return data;
-}
-
-static void ep93xx_mdio_write(struct net_device *dev, int phy_id, int reg, int data)
-{
-	struct ep93xx_priv *ep = netdev_priv(dev);
-	int i;
-
-	wrl(ep, REG_MIIDATA, data);
-	wrl(ep, REG_MIICMD, REG_MIICMD_WRITE | (phy_id << 5) | reg);
-
-	for (i = 0; i < 10; i++) {
-		if ((rdl(ep, REG_MIISTS) & REG_MIISTS_BUSY) == 0)
-			break;
-		msleep(1);
-	}
-
-	if (i == 10)
-		printk(KERN_INFO DRV_MODULE_NAME ": mdio write timed out\n");
-}
-
 static void ep93xx_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	strcpy(info->driver, DRV_MODULE_NAME);
-	strcpy(info->version, DRV_MODULE_VERSION);
+	strcpy(info->driver, "ep93xx-eth");
+	strcpy(info->version, "0.1");
 }
 
 static int ep93xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -825,12 +816,19 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 	struct ep93xx_eth_data *data;
 	struct net_device *dev;
 	struct ep93xx_priv *ep;
+	struct resource *mem;
+	struct resource *irq;
 	int err;
 
 	if (pdev == NULL)
 		return -ENODEV;
 	data = pdev->dev.platform_data;
 
+	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	irq = platform_get_irq(pdev, 0);
+	if (!mem || irq < 0)
+		return -ENXIO;
+
 	dev = ep93xx_dev_alloc(data);
 	if (dev == NULL) {
 		err = -ENOMEM;
@@ -842,23 +840,21 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dev);
 
-	ep->res = request_mem_region(pdev->resource[0].start,
-			pdev->resource[0].end - pdev->resource[0].start + 1,
-			dev_name(&pdev->dev));
+	ep->res = request_mem_region(mem->start, resource_size(mem),
+				     dev_name(&pdev->dev));
 	if (ep->res == NULL) {
 		dev_err(&pdev->dev, "Could not reserve memory region\n");
 		err = -ENOMEM;
 		goto err_out;
 	}
 
-	ep->base_addr = ioremap(pdev->resource[0].start,
-			pdev->resource[0].end - pdev->resource[0].start);
+	ep->base_addr = ioremap(mem->start, resource_size(mem));
 	if (ep->base_addr == NULL) {
 		dev_err(&pdev->dev, "Failed to ioremap ethernet registers\n");
 		err = -EIO;
 		goto err_out;
 	}
-	ep->irq = pdev->resource[1].start;
+	ep->irq = irq->start;
 
 	ep->mii.phy_id = data->phy_id;
 	ep->mii.phy_id_mask = 0x1f;
@@ -877,11 +873,8 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 		goto err_out;
 	}
 
-	printk(KERN_INFO "%s: ep93xx on-chip ethernet, IRQ %d, "
-			 "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x.\n", dev->name,
-			ep->irq, data->dev_addr[0], data->dev_addr[1],
-			data->dev_addr[2], data->dev_addr[3],
-			data->dev_addr[4], data->dev_addr[5]);
+	printk(KERN_INFO "%s: ep93xx on-chip ethernet, IRQ %d, %pM\n",
+			dev->name, ep->irq, dev->dev_addr);
 
 	return 0;
 
@@ -902,7 +895,6 @@ static struct platform_driver ep93xx_eth_driver = {
 
 static int __init ep93xx_eth_init_module(void)
 {
-	printk(KERN_INFO DRV_MODULE_NAME " version " DRV_MODULE_VERSION " loading\n");
 	return platform_driver_register(&ep93xx_eth_driver);
 }
  
