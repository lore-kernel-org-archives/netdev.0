From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] FEC: Turn FEC driver into platform device driver
Date: Thu, 29 Jan 2009 10:03:11 +0100
Message-ID: <1233219791-18691-10-git-send-email-s.hauer@pengutronix.de>
References: <1233219791-18691-1-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-2-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-3-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-4-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-5-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-6-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-7-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-8-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-9-git-send-email-s.hauer@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48071 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbZA2JDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 04:03:52 -0500
In-Reply-To: <1233219791-18691-9-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This turns the fec driver into a platform device driver for new
platforms. Old platforms are still supported through a FEC_LEGACY define
till they are also ported.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
Acked-by: Greg Ungerer <gerg@uclinux.org>
---
 drivers/net/fec.c |  249 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 220 insertions(+), 29 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 7631062..ea23baa 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -39,6 +39,7 @@
 #include <linux/io.h>
 #include <linux/irq.h>
 #include <linux/clk.h>
+#include <linux/platform_device.h>
 
 #include <asm/cacheflush.h>
 
@@ -49,12 +50,6 @@
 
 #include "fec.h"
 
-#if defined(CONFIG_FEC2)
-#define	FEC_MAX_PORTS	2
-#else
-#define	FEC_MAX_PORTS	1
-#endif
-
 #ifdef CONFIG_ARCH_MXC
 #include <mach/hardware.h>
 #define FEC_ALIGNMENT	0xf
@@ -62,13 +57,22 @@
 #define FEC_ALIGNMENT	0x3
 #endif
 
+#if defined CONFIG_M5272 || defined CONFIG_M527x || defined CONFIG_M523x \
+	|| defined CONFIG_M528x || defined CONFIG_M532x || defined CONFIG_M520x
+#define FEC_LEGACY
+/*
+ * Define the fixed address of the FEC hardware.
+ */
 #if defined(CONFIG_M5272)
 #define HAVE_mii_link_interrupt
 #endif
 
-/*
- * Define the fixed address of the FEC hardware.
- */
+#if defined(CONFIG_FEC2)
+#define	FEC_MAX_PORTS	2
+#else
+#define	FEC_MAX_PORTS	1
+#endif
+
 static unsigned int fec_hw[] = {
 #if defined(CONFIG_M5272)
 	(MCF_MBAR + 0x840),
@@ -106,6 +110,8 @@ static unsigned char	fec_mac_default[] = {
 #define	FEC_FLASHMAC	0
 #endif
 
+#endif /* FEC_LEGACY */
+
 /* Forward declarations of some structures to support different PHYs
 */
 
@@ -189,6 +195,8 @@ struct fec_enet_private {
 
 	struct net_device *netdev;
 
+	struct clk *clk;
+
 	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
 	unsigned char *tx_bounce[TX_RING_SIZE];
 	struct	sk_buff* tx_skbuff[TX_RING_SIZE];
@@ -1919,7 +1927,9 @@ mii_discover_phy(uint mii_reg, struct net_device *dev)
 		printk("FEC: No PHY device found.\n");
 		/* Disable external MII interface */
 		fecp->fec_mii_speed = fep->phy_speed = 0;
+#ifdef FREC_LEGACY
 		fec_disable_phy_intr();
+#endif
 	}
 }
 
@@ -2101,12 +2111,12 @@ fec_set_mac_address(struct net_device *dev)
 
 }
 
-/* Initialize the FEC Ethernet on 860T (or ColdFire 5272).
- */
  /*
   * XXX:  We need to clean up on failure exits here.
+  *
+  * index is only used in legacy code
   */
-int __init fec_enet_init(struct net_device *dev)
+int __init fec_enet_init(struct net_device *dev, int index)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	unsigned long	mem_addr;
@@ -2114,11 +2124,6 @@ int __init fec_enet_init(struct net_device *dev)
 	cbd_t		*cbd_base;
 	volatile fec_t	*fecp;
 	int 		i, j;
-	static int	index = 0;
-
-	/* Only allow us to be probed once. */
-	if (index >= FEC_MAX_PORTS)
-		return -ENXIO;
 
 	/* Allocate memory for buffer descriptors.
 	*/
@@ -2134,7 +2139,7 @@ int __init fec_enet_init(struct net_device *dev)
 
 	/* Create an Ethernet device instance.
 	*/
-	fecp = (volatile fec_t *) fec_hw[index];
+	fecp = (volatile fec_t *)dev->base_addr;
 
 	fep->index = index;
 	fep->hwp = fecp;
@@ -2145,16 +2150,24 @@ int __init fec_enet_init(struct net_device *dev)
 	fecp->fec_ecntrl = 1;
 	udelay(10);
 
-	/* Set the Ethernet address.  If using multiple Enets on the 8xx,
-	 * this needs some work to get unique addresses.
-	 *
-	 * This is our default MAC address unless the user changes
-	 * it via eth_mac_addr (our dev->set_mac_addr handler).
-	 */
+	/* Set the Ethernet address */
+#ifdef FEC_LEGACY
 	fec_get_mac(dev);
+#else
+	{
+		unsigned long l;
+		l = fecp->fec_addr_low;
+		dev->dev_addr[0] = (unsigned char)((l & 0xFF000000) >> 24);
+		dev->dev_addr[1] = (unsigned char)((l & 0x00FF0000) >> 16);
+		dev->dev_addr[2] = (unsigned char)((l & 0x0000FF00) >> 8);
+		dev->dev_addr[3] = (unsigned char)((l & 0x000000FF) >> 0);
+		l = fecp->fec_addr_high;
+		dev->dev_addr[4] = (unsigned char)((l & 0xFF000000) >> 24);
+		dev->dev_addr[5] = (unsigned char)((l & 0x00FF0000) >> 16);
+	}
+#endif
 
 	cbd_base = (cbd_t *)mem_addr;
-	/* XXX: missing check for allocation failure */
 
 	/* Set receive and transmit descriptor base.
 	*/
@@ -2222,10 +2235,12 @@ int __init fec_enet_init(struct net_device *dev)
 	fecp->fec_x_des_start = (unsigned long)fep->bd_dma + sizeof(cbd_t)
 				* RX_RING_SIZE;
 
+#ifdef FEC_LEGACY
 	/* Install our interrupt handlers. This varies depending on
 	 * the architecture.
 	*/
 	fec_request_intrs(dev);
+#endif
 
 	fecp->fec_grp_hash_table_high = 0;
 	fecp->fec_grp_hash_table_low = 0;
@@ -2237,8 +2252,6 @@ int __init fec_enet_init(struct net_device *dev)
 	fecp->fec_hash_table_low = 0;
 #endif
 
-	dev->base_addr = (unsigned long)fecp;
-
 	/* The FEC Ethernet specific entries in the device structure. */
 	dev->open = fec_enet_open;
 	dev->hard_start_xmit = fec_enet_start_xmit;
@@ -2252,7 +2265,20 @@ int __init fec_enet_init(struct net_device *dev)
 	mii_free = mii_cmds;
 
 	/* setup MII interface */
+#ifdef FEC_LEGACY
 	fec_set_mii(dev, fep);
+#else
+	fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;
+	fecp->fec_x_cntrl = 0x00;
+
+	/*
+	 * Set MII speed to 2.5 MHz
+	 */
+	fep->phy_speed = ((((clk_get_rate(fep->clk) / 2 + 4999999)
+					/ 2500000) / 2) & 0x3F) << 1;
+	fecp->fec_mii_speed = fep->phy_speed;
+	fec_restart(dev, 0);
+#endif
 
 	/* Clear and enable interrupts */
 	fecp->fec_ievent = 0xffc00000;
@@ -2265,7 +2291,6 @@ int __init fec_enet_init(struct net_device *dev)
 	fep->phy_addr = 0;
 	mii_queue(dev, mk_mii_read(MII_REG_PHYIR1), mii_discover_phy);
 
-	index++;
 	return 0;
 }
 
@@ -2417,6 +2442,7 @@ fec_stop(struct net_device *dev)
 	fecp->fec_mii_speed = fep->phy_speed;
 }
 
+#ifdef FEC_LEGACY
 static int __init fec_enet_module_init(void)
 {
 	struct net_device *dev;
@@ -2428,7 +2454,8 @@ static int __init fec_enet_module_init(void)
 		dev = alloc_etherdev(sizeof(struct fec_enet_private));
 		if (!dev)
 			return -ENOMEM;
-		err = fec_enet_init(dev);
+		dev->base_addr = (unsigned long)fec_hw[i];
+		err = fec_enet_init(dev, i);
 		if (err) {
 			free_netdev(dev);
 			continue;
@@ -2443,6 +2470,170 @@ static int __init fec_enet_module_init(void)
 	}
 	return 0;
 }
+#else
+
+static int __devinit
+fec_probe(struct platform_device *pdev)
+{
+	struct fec_enet_private *fep;
+	struct net_device *ndev;
+	int i, irq, ret = 0;
+	struct resource *r;
+
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!r)
+		return -ENXIO;
+
+	r = request_mem_region(r->start, resource_size(r), pdev->name);
+	if (!r)
+		return -EBUSY;
+
+	/* Init network device */
+	ndev = alloc_etherdev(sizeof(struct fec_enet_private));
+	if (!ndev)
+		return -ENOMEM;
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	/* setup board info structure */
+	fep = netdev_priv(ndev);
+	memset(fep, 0, sizeof(*fep));
+
+	ndev->base_addr = (unsigned long)ioremap(r->start, resource_size(r));
+
+	if (!ndev->base_addr) {
+		ret = -ENOMEM;
+		goto failed_ioremap;
+	}
+
+	platform_set_drvdata(pdev, ndev);
+
+	/* This device has up to three irqs on some platforms */
+	for (i = 0; i < 3; i++) {
+		irq = platform_get_irq(pdev, i);
+		if (i && irq < 0)
+			break;
+		ret = request_irq(irq, fec_enet_interrupt, IRQF_DISABLED, pdev->name, ndev);
+		if (ret) {
+			while (i >= 0) {
+				irq = platform_get_irq(pdev, i);
+				free_irq(irq, ndev);
+				i--;
+			}
+			goto failed_irq;
+		}
+	}
+
+	fep->clk = clk_get(&pdev->dev, "fec_clk");
+	if (IS_ERR(fep->clk)) {
+		ret = PTR_ERR(fep->clk);
+		goto failed_clk;
+	}
+	clk_enable(fep->clk);
+
+	ret = fec_enet_init(ndev, 0);
+	if (ret)
+		goto failed_init;
+
+	ret = register_netdev(ndev);
+	if (ret)
+		goto failed_register;
+
+	return 0;
+
+failed_register:
+failed_init:
+	clk_disable(fep->clk);
+	clk_put(fep->clk);
+failed_clk:
+	for (i = 0; i < 3; i++) {
+		irq = platform_get_irq(pdev, i);
+		if (irq > 0)
+			free_irq(irq, ndev);
+	}
+failed_irq:
+	iounmap((void __iomem *)ndev->base_addr);
+failed_ioremap:
+	free_netdev(ndev);
+
+	return ret;
+}
+
+static int __devexit
+fec_drv_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	platform_set_drvdata(pdev, NULL);
+
+	fec_stop(ndev);
+	clk_disable(fep->clk);
+	clk_put(fep->clk);
+	iounmap((void __iomem *)ndev->base_addr);
+	unregister_netdev(ndev);
+	free_netdev(ndev);
+	return 0;
+}
+
+static int
+fec_suspend(struct platform_device *dev, pm_message_t state)
+{
+	struct net_device *ndev = platform_get_drvdata(dev);
+	struct fec_enet_private *fep;
+
+	if (ndev) {
+		fep = netdev_priv(ndev);
+		if (netif_running(ndev)) {
+			netif_device_detach(ndev);
+			fec_stop(ndev);
+		}
+	}
+	return 0;
+}
+
+static int
+fec_resume(struct platform_device *dev)
+{
+	struct net_device *ndev = platform_get_drvdata(dev);
+
+	if (ndev) {
+		if (netif_running(ndev)) {
+			fec_enet_init(ndev, 0);
+			netif_device_attach(ndev);
+		}
+	}
+	return 0;
+}
+
+static struct platform_driver fec_driver = {
+	.driver	= {
+		.name    = "fec",
+		.owner	 = THIS_MODULE,
+	},
+	.probe   = fec_probe,
+	.remove  = __devexit_p(fec_drv_remove),
+	.suspend = fec_suspend,
+	.resume  = fec_resume,
+};
+
+static int __init
+fec_enet_module_init(void)
+{
+	printk(KERN_INFO "FEC Ethernet Driver\n");
+
+	return platform_driver_register(&fec_driver);
+}
+
+static void __exit
+fec_enet_cleanup(void)
+{
+	platform_driver_unregister(&fec_driver);
+}
+
+module_exit(fec_enet_cleanup);
+
+#endif /* FEC_LEGACY */
 
 module_init(fec_enet_module_init);
 
-- 
1.5.6.5

