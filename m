From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH 4/5] fs_enet: Remove !CONFIG_PPC_CPM_NEW_BINDING code
Date: Thu, 12 Jun 2008 08:40:33 -0500
Message-ID: <1213278034-28552-5-git-send-email-galak@kernel.crashing.org>
References: <1213278034-28552-1-git-send-email-galak@kernel.crashing.org>
	<1213278034-28552-2-git-send-email-galak@kernel.crashing.org>
	<1213278034-28552-3-git-send-email-galak@kernel.crashing.org>
	<1213278034-28552-4-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: scottwood@freescale.com, netdev@vger.kernel.org, jeff@garzik.org
To: linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1213278034-28552-4-git-send-email-galak@kernel.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Now that arch/ppc is gone we always define CONFIG_PPC_CPM_NEW_BINDING so
we can remove all the code associated with !CONFIG_PPC_CPM_NEW_BINDING.

Also fixed some asm/of_platform.h to linux/of_platform.h (and of_device.h)

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---

Jeff, if this looks ok, its easier if this can go via the powerpc tree.

- k

 drivers/net/fs_enet/Makefile       |    5 -
 drivers/net/fs_enet/fs_enet-main.c |  309 +-----------------------------------
 drivers/net/fs_enet/fs_enet.h      |    4 -
 drivers/net/fs_enet/mac-fcc.c      |   67 +--------
 drivers/net/fs_enet/mac-fec.c      |   23 +---
 drivers/net/fs_enet/mac-scc.c      |   37 +----
 drivers/net/fs_enet/mii-bitbang.c  |  107 -------------
 drivers/net/fs_enet/mii-fec.c      |  144 +-----------------
 include/linux/fs_enet_pd.h         |    4 -
 9 files changed, 5 insertions(+), 695 deletions(-)

diff --git a/drivers/net/fs_enet/Makefile b/drivers/net/fs_enet/Makefile
index 1ffbe07..d4a305e 100644
--- a/drivers/net/fs_enet/Makefile
+++ b/drivers/net/fs_enet/Makefile
@@ -8,12 +8,7 @@ fs_enet-$(CONFIG_FS_ENET_HAS_SCC) += mac-scc.o
 fs_enet-$(CONFIG_FS_ENET_HAS_FEC) += mac-fec.o
 fs_enet-$(CONFIG_FS_ENET_HAS_FCC) += mac-fcc.o
 
-ifeq ($(CONFIG_PPC_CPM_NEW_BINDING),y)
 obj-$(CONFIG_FS_ENET_MDIO_FEC) += mii-fec.o
 obj-$(CONFIG_FS_ENET_MDIO_FCC) += mii-bitbang.o
-else
-fs_enet-$(CONFIG_FS_ENET_MDIO_FEC) += mii-fec.o
-fs_enet-$(CONFIG_FS_ENET_MDIO_FCC) += mii-bitbang.o
-endif
 
 fs_enet-objs := fs_enet-main.o $(fs_enet-m)
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a5baaf5..a9f9aae 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -36,25 +36,18 @@
 #include <linux/fs.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
+#include <linux/of_platform.h>
 
 #include <linux/vmalloc.h>
 #include <asm/pgtable.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
-#include <asm/of_platform.h>
-#endif
 
 #include "fs_enet.h"
 
 /*************************************************/
 
-#ifndef CONFIG_PPC_CPM_NEW_BINDING
-static char version[] __devinitdata =
-    DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")" "\n";
-#endif
-
 MODULE_AUTHOR("Pantelis Antoniou <panto@intracom.gr>");
 MODULE_DESCRIPTION("Freescale Ethernet Driver");
 MODULE_LICENSE("GPL");
@@ -957,190 +950,6 @@ static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 extern int fs_mii_connect(struct net_device *dev);
 extern void fs_mii_disconnect(struct net_device *dev);
 
-#ifndef CONFIG_PPC_CPM_NEW_BINDING
-static struct net_device *fs_init_instance(struct device *dev,
-		struct fs_platform_info *fpi)
-{
-	struct net_device *ndev = NULL;
-	struct fs_enet_private *fep = NULL;
-	int privsize, i, r, err = 0, registered = 0;
-
-	fpi->fs_no = fs_get_id(fpi);
-	/* guard */
-	if ((unsigned int)fpi->fs_no >= FS_MAX_INDEX)
-		return ERR_PTR(-EINVAL);
-
-	privsize = sizeof(*fep) + (sizeof(struct sk_buff **) *
-			    (fpi->rx_ring + fpi->tx_ring));
-
-	ndev = alloc_etherdev(privsize);
-	if (!ndev) {
-		err = -ENOMEM;
-		goto err;
-	}
-
-	fep = netdev_priv(ndev);
-
-	fep->dev = dev;
-	dev_set_drvdata(dev, ndev);
-	fep->fpi = fpi;
-	if (fpi->init_ioports)
-		fpi->init_ioports((struct fs_platform_info *)fpi);
-
-#ifdef CONFIG_FS_ENET_HAS_FEC
-	if (fs_get_fec_index(fpi->fs_no) >= 0)
-		fep->ops = &fs_fec_ops;
-#endif
-
-#ifdef CONFIG_FS_ENET_HAS_SCC
-	if (fs_get_scc_index(fpi->fs_no) >=0)
-		fep->ops = &fs_scc_ops;
-#endif
-
-#ifdef CONFIG_FS_ENET_HAS_FCC
-	if (fs_get_fcc_index(fpi->fs_no) >= 0)
-		fep->ops = &fs_fcc_ops;
-#endif
-
-	if (fep->ops == NULL) {
-		printk(KERN_ERR DRV_MODULE_NAME
-		       ": %s No matching ops found (%d).\n",
-		       ndev->name, fpi->fs_no);
-		err = -EINVAL;
-		goto err;
-	}
-
-	r = (*fep->ops->setup_data)(ndev);
-	if (r != 0) {
-		printk(KERN_ERR DRV_MODULE_NAME
-		       ": %s setup_data failed\n",
-			ndev->name);
-		err = r;
-		goto err;
-	}
-
-	/* point rx_skbuff, tx_skbuff */
-	fep->rx_skbuff = (struct sk_buff **)&fep[1];
-	fep->tx_skbuff = fep->rx_skbuff + fpi->rx_ring;
-
-	/* init locks */
-	spin_lock_init(&fep->lock);
-	spin_lock_init(&fep->tx_lock);
-
-	/*
-	 * Set the Ethernet address.
-	 */
-	for (i = 0; i < 6; i++)
-		ndev->dev_addr[i] = fpi->macaddr[i];
-
-	r = (*fep->ops->allocate_bd)(ndev);
-
-	if (fep->ring_base == NULL) {
-		printk(KERN_ERR DRV_MODULE_NAME
-		       ": %s buffer descriptor alloc failed (%d).\n", ndev->name, r);
-		err = r;
-		goto err;
-	}
-
-	/*
-	 * Set receive and transmit descriptor base.
-	 */
-	fep->rx_bd_base = fep->ring_base;
-	fep->tx_bd_base = fep->rx_bd_base + fpi->rx_ring;
-
-	/* initialize ring size variables */
-	fep->tx_ring = fpi->tx_ring;
-	fep->rx_ring = fpi->rx_ring;
-
-	/*
-	 * The FEC Ethernet specific entries in the device structure.
-	 */
-	ndev->open = fs_enet_open;
-	ndev->hard_start_xmit = fs_enet_start_xmit;
-	ndev->tx_timeout = fs_timeout;
-	ndev->watchdog_timeo = 2 * HZ;
-	ndev->stop = fs_enet_close;
-	ndev->get_stats = fs_enet_get_stats;
-	ndev->set_multicast_list = fs_set_multicast_list;
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	ndev->poll_controller = fs_enet_netpoll;
-#endif
-
-	netif_napi_add(ndev, &fep->napi,
-		       fs_enet_rx_napi, fpi->napi_weight);
-
-	ndev->ethtool_ops = &fs_ethtool_ops;
-	ndev->do_ioctl = fs_ioctl;
-
-	init_timer(&fep->phy_timer_list);
-
-	netif_carrier_off(ndev);
-
-	err = register_netdev(ndev);
-	if (err != 0) {
-		printk(KERN_ERR DRV_MODULE_NAME
-		       ": %s register_netdev failed.\n", ndev->name);
-		goto err;
-	}
-	registered = 1;
-
-
-	return ndev;
-
-err:
-	if (ndev != NULL) {
-		if (registered)
-			unregister_netdev(ndev);
-
-		if (fep && fep->ops) {
-			(*fep->ops->free_bd)(ndev);
-			(*fep->ops->cleanup_data)(ndev);
-		}
-
-		free_netdev(ndev);
-	}
-
-	dev_set_drvdata(dev, NULL);
-
-	return ERR_PTR(err);
-}
-
-static int fs_cleanup_instance(struct net_device *ndev)
-{
-	struct fs_enet_private *fep;
-	const struct fs_platform_info *fpi;
-	struct device *dev;
-
-	if (ndev == NULL)
-		return -EINVAL;
-
-	fep = netdev_priv(ndev);
-	if (fep == NULL)
-		return -EINVAL;
-
-	fpi = fep->fpi;
-
-	unregister_netdev(ndev);
-
-	dma_free_coherent(fep->dev, (fpi->tx_ring + fpi->rx_ring) * sizeof(cbd_t),
-			  (void __force *)fep->ring_base, fep->ring_mem_addr);
-
-	/* reset it */
-	(*fep->ops->cleanup_data)(ndev);
-
-	dev = fep->dev;
-	if (dev != NULL) {
-		dev_set_drvdata(dev, NULL);
-		fep->dev = NULL;
-	}
-
-	free_netdev(ndev);
-
-	return 0;
-}
-#endif
-
 /**************************************************************************************/
 
 /* handy pointer to the immap */
@@ -1167,7 +976,6 @@ static void cleanup_immap(void)
 
 /**************************************************************************************/
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 static int __devinit find_phy(struct device_node *np,
                               struct fs_platform_info *fpi)
 {
@@ -1399,121 +1207,6 @@ static void __exit fs_cleanup(void)
 	of_unregister_platform_driver(&fs_enet_driver);
 	cleanup_immap();
 }
-#else
-static int __devinit fs_enet_probe(struct device *dev)
-{
-	struct net_device *ndev;
-
-	/* no fixup - no device */
-	if (dev->platform_data == NULL) {
-		printk(KERN_INFO "fs_enet: "
-				"probe called with no platform data; "
-				"remove unused devices\n");
-		return -ENODEV;
-	}
-
-	ndev = fs_init_instance(dev, dev->platform_data);
-	if (IS_ERR(ndev))
-		return PTR_ERR(ndev);
-	return 0;
-}
-
-static int fs_enet_remove(struct device *dev)
-{
-	return fs_cleanup_instance(dev_get_drvdata(dev));
-}
-
-static struct device_driver fs_enet_fec_driver = {
-	.name	  	= "fsl-cpm-fec",
-	.bus		= &platform_bus_type,
-	.probe		= fs_enet_probe,
-	.remove		= fs_enet_remove,
-#ifdef CONFIG_PM
-/*	.suspend	= fs_enet_suspend,	TODO */
-/*	.resume		= fs_enet_resume,	TODO */
-#endif
-};
-
-static struct device_driver fs_enet_scc_driver = {
-	.name	  	= "fsl-cpm-scc",
-	.bus		= &platform_bus_type,
-	.probe		= fs_enet_probe,
-	.remove		= fs_enet_remove,
-#ifdef CONFIG_PM
-/*	.suspend	= fs_enet_suspend,	TODO */
-/*	.resume		= fs_enet_resume,	TODO */
-#endif
-};
-
-static struct device_driver fs_enet_fcc_driver = {
-	.name	  	= "fsl-cpm-fcc",
-	.bus		= &platform_bus_type,
-	.probe		= fs_enet_probe,
-	.remove		= fs_enet_remove,
-#ifdef CONFIG_PM
-/*	.suspend	= fs_enet_suspend,	TODO */
-/*	.resume		= fs_enet_resume,	TODO */
-#endif
-};
-
-static int __init fs_init(void)
-{
-	int r;
-
-	printk(KERN_INFO
-			"%s", version);
-
-	r = setup_immap();
-	if (r != 0)
-		return r;
-
-#ifdef CONFIG_FS_ENET_HAS_FCC
-	/* let's insert mii stuff */
-	r = fs_enet_mdio_bb_init();
-
-	if (r != 0) {
-		printk(KERN_ERR DRV_MODULE_NAME
-			"BB PHY init failed.\n");
-		return r;
-	}
-	r = driver_register(&fs_enet_fcc_driver);
-	if (r != 0)
-		goto err;
-#endif
-
-#ifdef CONFIG_FS_ENET_HAS_FEC
-	r =  fs_enet_mdio_fec_init();
-	if (r != 0) {
-		printk(KERN_ERR DRV_MODULE_NAME
-			"FEC PHY init failed.\n");
-		return r;
-	}
-
-	r = driver_register(&fs_enet_fec_driver);
-	if (r != 0)
-		goto err;
-#endif
-
-#ifdef CONFIG_FS_ENET_HAS_SCC
-	r = driver_register(&fs_enet_scc_driver);
-	if (r != 0)
-		goto err;
-#endif
-
-	return 0;
-err:
-	cleanup_immap();
-	return r;
-}
-
-static void __exit fs_cleanup(void)
-{
-	driver_unregister(&fs_enet_fec_driver);
-	driver_unregister(&fs_enet_fcc_driver);
-	driver_unregister(&fs_enet_scc_driver);
-	cleanup_immap();
-}
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void fs_enet_netpoll(struct net_device *dev)
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index e05389c..db46d2e 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -138,10 +138,6 @@ struct fs_enet_private {
 };
 
 /***************************************************************************/
-#ifndef CONFIG_PPC_CPM_NEW_BINDING
-int fs_enet_mdio_bb_init(void);
-int fs_enet_mdio_fec_init(void);
-#endif
 
 void fs_init_bds(struct net_device *dev);
 void fs_cleanup_bds(struct net_device *dev);
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index e363211..133125f 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -33,6 +33,7 @@
 #include <linux/fs.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
+#include <linux/of_device.h>
 
 #include <asm/immap_cpm2.h>
 #include <asm/mpc8260.h>
@@ -42,10 +43,6 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
-#include <asm/of_device.h>
-#endif
-
 #include "fs_enet.h"
 
 /*************************************************/
@@ -87,7 +84,6 @@ static inline int fcc_cr_cmd(struct fs_enet_private *fep, u32 op)
 
 static int do_pd_setup(struct fs_enet_private *fep)
 {
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 	struct of_device *ofdev = to_of_device(fep->dev);
 	struct fs_platform_info *fpi = fep->fpi;
 	int ret = -EINVAL;
@@ -125,44 +121,6 @@ out_fccp:
 	iounmap(fep->fcc.fccp);
 out:
 	return ret;
-#else
-	struct platform_device *pdev = to_platform_device(fep->dev);
-	struct resource *r;
-
-	/* Fill out IRQ field */
-	fep->interrupt = platform_get_irq(pdev, 0);
-	if (fep->interrupt < 0)
-		return -EINVAL;
-
-	/* Attach the memory for the FCC Parameter RAM */
-	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "fcc_pram");
-	fep->fcc.ep = ioremap(r->start, r->end - r->start + 1);
-	if (fep->fcc.ep == NULL)
-		return -EINVAL;
-
-	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "fcc_regs");
-	fep->fcc.fccp = ioremap(r->start, r->end - r->start + 1);
-	if (fep->fcc.fccp == NULL)
-		return -EINVAL;
-
-	if (fep->fpi->fcc_regs_c) {
-		fep->fcc.fcccp = (void __iomem *)fep->fpi->fcc_regs_c;
-	} else {
-		r = platform_get_resource_byname(pdev, IORESOURCE_MEM,
-				"fcc_regs_c");
-		fep->fcc.fcccp = ioremap(r->start,
-				r->end - r->start + 1);
-	}
-
-	if (fep->fcc.fcccp == NULL)
-		return -EINVAL;
-
-	fep->fcc.mem = (void __iomem *)fep->fpi->mem_offset;
-	if (fep->fcc.mem == NULL)
-		return -EINVAL;
-
-	return 0;
-#endif
 }
 
 #define FCC_NAPI_RX_EVENT_MSK	(FCC_ENET_RXF | FCC_ENET_RXB)
@@ -173,17 +131,6 @@ out:
 static int setup_data(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-#ifndef CONFIG_PPC_CPM_NEW_BINDING
-	struct fs_platform_info *fpi = fep->fpi;
-
-	fpi->cp_command = (fpi->cp_page << 26) |
-	                  (fpi->cp_block << 21) |
-	                  (12 << 6);
-
-	fep->fcc.idx = fs_get_fcc_index(fpi->fs_no);
-	if ((unsigned int)fep->fcc.idx >= 3)	/* max 3 FCCs */
-		return -EINVAL;
-#endif
 
 	if (do_pd_setup(fep) != 0)
 		return -EINVAL;
@@ -304,9 +251,6 @@ static void restart(struct net_device *dev)
 	fcc_enet_t __iomem *ep = fep->fcc.ep;
 	dma_addr_t rx_bd_base_phys, tx_bd_base_phys;
 	u16 paddrh, paddrm, paddrl;
-#ifndef CONFIG_PPC_CPM_NEW_BINDING
-	u16 mem_addr;
-#endif
 	const unsigned char *mac;
 	int i;
 
@@ -338,19 +282,10 @@ static void restart(struct net_device *dev)
 	 * this area.
 	 */
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 	W16(ep, fen_genfcc.fcc_riptr, fpi->dpram_offset);
 	W16(ep, fen_genfcc.fcc_tiptr, fpi->dpram_offset + 32);
 
 	W16(ep, fen_padptr, fpi->dpram_offset + 64);
-#else
-	mem_addr = (u32) fep->fcc.mem;	/* de-fixup dpram offset */
-
-	W16(ep, fen_genfcc.fcc_riptr, (mem_addr & 0xffff));
-	W16(ep, fen_genfcc.fcc_tiptr, ((mem_addr + 32) & 0xffff));
-
-	W16(ep, fen_padptr, mem_addr + 64);
-#endif
 
 	/* fill with special symbol...  */
 	memset_io(fep->fcc.mem + fpi->dpram_offset + 64, 0x88, 32);
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 8a311d1..0a7d1c5 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -32,6 +32,7 @@
 #include <linux/bitops.h>
 #include <linux/fs.h>
 #include <linux/platform_device.h>
+#include <linux/of_device.h>
 
 #include <asm/irq.h>
 #include <asm/uaccess.h>
@@ -43,10 +44,6 @@
 #include <asm/cpm1.h>
 #endif
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
-#include <asm/of_device.h>
-#endif
-
 #include "fs_enet.h"
 #include "fec.h"
 
@@ -99,7 +96,6 @@ static int whack_reset(fec_t __iomem *fecp)
 
 static int do_pd_setup(struct fs_enet_private *fep)
 {
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 	struct of_device *ofdev = to_of_device(fep->dev);
 
 	fep->interrupt = of_irq_to_resource(ofdev->node, 0, NULL);
@@ -111,23 +107,6 @@ static int do_pd_setup(struct fs_enet_private *fep)
 		return -EINVAL;
 
 	return 0;
-#else
-	struct platform_device *pdev = to_platform_device(fep->dev);
-	struct resource	*r;
-
-	/* Fill out IRQ field */
-	fep->interrupt = platform_get_irq_byname(pdev,"interrupt");
-	if (fep->interrupt < 0)
-		return -EINVAL;
-
-	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
-	fep->fec.fecp = ioremap(r->start, r->end - r->start + 1);
-
-	if(fep->fec.fecp == NULL)
-		return -EINVAL;
-
-	return 0;
-#endif
 }
 
 #define FEC_NAPI_RX_EVENT_MSK	(FEC_ENET_RXF | FEC_ENET_RXB)
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index d7ca319..029b3c7 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -32,6 +32,7 @@
 #include <linux/bitops.h>
 #include <linux/fs.h>
 #include <linux/platform_device.h>
+#include <linux/of_platform.h>
 
 #include <asm/irq.h>
 #include <asm/uaccess.h>
@@ -43,10 +44,6 @@
 #include <asm/cpm1.h>
 #endif
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
-#include <asm/of_platform.h>
-#endif
-
 #include "fs_enet.h"
 
 /*************************************************/
@@ -99,7 +96,6 @@ static inline int scc_cr_cmd(struct fs_enet_private *fep, u32 op)
 
 static int do_pd_setup(struct fs_enet_private *fep)
 {
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 	struct of_device *ofdev = to_of_device(fep->dev);
 
 	fep->interrupt = of_irq_to_resource(ofdev->node, 0, NULL);
@@ -115,27 +111,6 @@ static int do_pd_setup(struct fs_enet_private *fep)
 		iounmap(fep->scc.sccp);
 		return -EINVAL;
 	}
-#else
-	struct platform_device *pdev = to_platform_device(fep->dev);
-	struct resource *r;
-
-	/* Fill out IRQ field */
-	fep->interrupt = platform_get_irq_byname(pdev, "interrupt");
-	if (fep->interrupt < 0)
-		return -EINVAL;
-
-	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
-	fep->scc.sccp = ioremap(r->start, r->end - r->start + 1);
-
-	if (fep->scc.sccp == NULL)
-		return -EINVAL;
-
-	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "pram");
-	fep->scc.ep = ioremap(r->start, r->end - r->start + 1);
-
-	if (fep->scc.ep == NULL)
-		return -EINVAL;
-#endif
 
 	return 0;
 }
@@ -149,16 +124,6 @@ static int setup_data(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
-#ifndef CONFIG_PPC_CPM_NEW_BINDING
-	struct fs_platform_info *fpi = fep->fpi;
-
-	fep->scc.idx = fs_get_scc_index(fpi->fs_no);
-	if ((unsigned int)fep->fcc.idx >= 4) /* max 4 SCCs */
-		return -EINVAL;
-
-	fpi->cp_command = fep->fcc.idx << 6;
-#endif
-
 	do_pd_setup(fep);
 
 	fep->scc.hthi = 0;
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 1620030..be4b72f 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -22,10 +22,7 @@
 #include <linux/mii.h>
 #include <linux/platform_device.h>
 #include <linux/mdio-bitbang.h>
-
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 #include <linux/of_platform.h>
-#endif
 
 #include "fs_enet.h"
 
@@ -110,7 +107,6 @@ static struct mdiobb_ops bb_ops = {
 	.get_mdio_data = mdio_read,
 };
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
                                          struct device_node *np)
 {
@@ -271,106 +267,3 @@ static void fs_enet_mdio_bb_exit(void)
 
 module_init(fs_enet_mdio_bb_init);
 module_exit(fs_enet_mdio_bb_exit);
-#else
-static int __devinit fs_mii_bitbang_init(struct bb_info *bitbang,
-                                         struct fs_mii_bb_platform_info *fmpi)
-{
-	bitbang->dir = (u32 __iomem *)fmpi->mdio_dir.offset;
-	bitbang->dat = (u32 __iomem *)fmpi->mdio_dat.offset;
-	bitbang->mdio_msk = 1U << (31 - fmpi->mdio_dat.bit);
-	bitbang->mdc_msk = 1U << (31 - fmpi->mdc_dat.bit);
-
-	return 0;
-}
-
-static int __devinit fs_enet_mdio_probe(struct device *dev)
-{
-	struct platform_device *pdev = to_platform_device(dev);
-	struct fs_mii_bb_platform_info *pdata;
-	struct mii_bus *new_bus;
-	struct bb_info *bitbang;
-	int err = 0;
-
-	if (NULL == dev)
-		return -EINVAL;
-
-	bitbang = kzalloc(sizeof(struct bb_info), GFP_KERNEL);
-
-	if (NULL == bitbang)
-		return -ENOMEM;
-
-	bitbang->ctrl.ops = &bb_ops;
-
-	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
-
-	if (NULL == new_bus)
-		return -ENOMEM;
-
-	new_bus->name = "BB MII Bus",
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
-
-	new_bus->phy_mask = ~0x9;
-	pdata = (struct fs_mii_bb_platform_info *)pdev->dev.platform_data;
-
-	if (NULL == pdata) {
-		printk(KERN_ERR "gfar mdio %d: Missing platform data!\n", pdev->id);
-		return -ENODEV;
-	}
-
-	/*set up workspace*/
-	fs_mii_bitbang_init(bitbang, pdata);
-
-	new_bus->priv = bitbang;
-
-	new_bus->irq = pdata->irq;
-
-	new_bus->dev = dev;
-	dev_set_drvdata(dev, new_bus);
-
-	err = mdiobus_register(new_bus);
-
-	if (0 != err) {
-		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
-				new_bus->name);
-		goto bus_register_fail;
-	}
-
-	return 0;
-
-bus_register_fail:
-	free_mdio_bitbang(new_bus);
-	kfree(bitbang);
-
-	return err;
-}
-
-static int fs_enet_mdio_remove(struct device *dev)
-{
-	struct mii_bus *bus = dev_get_drvdata(dev);
-
-	mdiobus_unregister(bus);
-
-	dev_set_drvdata(dev, NULL);
-
-	free_mdio_bitbang(bus);
-
-	return 0;
-}
-
-static struct device_driver fs_enet_bb_mdio_driver = {
-	.name = "fsl-bb-mdio",
-	.bus = &platform_bus_type,
-	.probe = fs_enet_mdio_probe,
-	.remove = fs_enet_mdio_remove,
-};
-
-int fs_enet_mdio_bb_init(void)
-{
-	return driver_register(&fs_enet_bb_mdio_driver);
-}
-
-void fs_enet_mdio_bb_exit(void)
-{
-	driver_unregister(&fs_enet_bb_mdio_driver);
-}
-#endif
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index f0014cf..695f74c 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -31,15 +31,12 @@
 #include <linux/ethtool.h>
 #include <linux/bitops.h>
 #include <linux/platform_device.h>
+#include <linux/of_platform.h>
 
 #include <asm/pgtable.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
-#include <asm/of_platform.h>
-#endif
-
 #include "fs_enet.h"
 #include "fec.h"
 
@@ -51,52 +48,6 @@
 
 #define FEC_MII_LOOPS	10000
 
-#ifndef CONFIG_PPC_CPM_NEW_BINDING
-static int match_has_phy (struct device *dev, void* data)
-{
-	struct platform_device* pdev = container_of(dev, struct platform_device, dev);
-	struct fs_platform_info* fpi;
-	if(strcmp(pdev->name, (char*)data))
-	{
-	    return 0;
-	}
-
-	fpi = pdev->dev.platform_data;
-	if((fpi)&&(fpi->has_phy))
-		return 1;
-	return 0;
-}
-
-static int fs_mii_fec_init(struct fec_info* fec, struct fs_mii_fec_platform_info *fmpi)
-{
-	struct resource *r;
-	fec_t __iomem *fecp;
-	char* name = "fsl-cpm-fec";
-
-	/* we need fec in order to be useful */
-	struct platform_device *fec_pdev =
-		container_of(bus_find_device(&platform_bus_type, NULL, name, match_has_phy),
-				struct platform_device, dev);
-
-	if(fec_pdev == NULL) {
-		printk(KERN_ERR"Unable to find PHY for %s", name);
-		return -ENODEV;
-	}
-
-	r = platform_get_resource_byname(fec_pdev, IORESOURCE_MEM, "regs");
-
-	fec->fecp = fecp = ioremap(r->start,sizeof(fec_t));
-	fec->mii_speed = fmpi->mii_speed;
-
-	setbits32(&fecp->fec_r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
-	setbits32(&fecp->fec_ecntrl, FEC_ECNTRL_PINMUX | FEC_ECNTRL_ETHER_EN);
-	out_be32(&fecp->fec_ievent, FEC_ENET_MII);
-	out_be32(&fecp->fec_mii_speed, fec->mii_speed);
-
-	return 0;
-}
-#endif
-
 static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 {
 	struct fec_info* fec = bus->priv;
@@ -151,7 +102,6 @@ static int fs_enet_fec_mii_reset(struct mii_bus *bus)
 	return 0;
 }
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
 {
 	const u32 *data;
@@ -286,95 +236,3 @@ static void fs_enet_mdio_fec_exit(void)
 
 module_init(fs_enet_mdio_fec_init);
 module_exit(fs_enet_mdio_fec_exit);
-#else
-static int __devinit fs_enet_fec_mdio_probe(struct device *dev)
-{
-	struct platform_device *pdev = to_platform_device(dev);
-	struct fs_mii_fec_platform_info *pdata;
-	struct mii_bus *new_bus;
-	struct fec_info *fec;
-	int err = 0;
-	if (NULL == dev)
-		return -EINVAL;
-	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
-
-	if (NULL == new_bus)
-		return -ENOMEM;
-
-	fec = kzalloc(sizeof(struct fec_info), GFP_KERNEL);
-
-	if (NULL == fec)
-		return -ENOMEM;
-
-	new_bus->name = "FEC MII Bus",
-	new_bus->read = &fs_enet_fec_mii_read,
-	new_bus->write = &fs_enet_fec_mii_write,
-	new_bus->reset = &fs_enet_fec_mii_reset,
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
-
-	pdata = (struct fs_mii_fec_platform_info *)pdev->dev.platform_data;
-
-	if (NULL == pdata) {
-		printk(KERN_ERR "fs_enet FEC mdio %d: Missing platform data!\n", pdev->id);
-		return -ENODEV;
-	}
-
-	/*set up workspace*/
-
-	fs_mii_fec_init(fec, pdata);
-	new_bus->priv = fec;
-
-	new_bus->irq = pdata->irq;
-
-	new_bus->dev = dev;
-	dev_set_drvdata(dev, new_bus);
-
-	err = mdiobus_register(new_bus);
-
-	if (0 != err) {
-		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
-				new_bus->name);
-		goto bus_register_fail;
-	}
-
-	return 0;
-
-bus_register_fail:
-	kfree(new_bus);
-
-	return err;
-}
-
-
-static int fs_enet_fec_mdio_remove(struct device *dev)
-{
-	struct mii_bus *bus = dev_get_drvdata(dev);
-
-	mdiobus_unregister(bus);
-
-	dev_set_drvdata(dev, NULL);
-	kfree(bus->priv);
-
-	bus->priv = NULL;
-	kfree(bus);
-
-	return 0;
-}
-
-static struct device_driver fs_enet_fec_mdio_driver = {
-	.name = "fsl-cpm-fec-mdio",
-	.bus = &platform_bus_type,
-	.probe = fs_enet_fec_mdio_probe,
-	.remove = fs_enet_fec_mdio_remove,
-};
-
-int fs_enet_mdio_fec_init(void)
-{
-	return driver_register(&fs_enet_fec_mdio_driver);
-}
-
-void fs_enet_mdio_fec_exit(void)
-{
-	driver_unregister(&fs_enet_fec_mdio_driver);
-}
-#endif
diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
index 9bc045b..0ba21ee 100644
--- a/include/linux/fs_enet_pd.h
+++ b/include/linux/fs_enet_pd.h
@@ -135,11 +135,7 @@ struct fs_platform_info {
 	u32 device_flags;
 
 	int phy_addr;		/* the phy address (-1 no phy) */
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
 	char bus_id[16];
-#else
-	const char*	bus_id;
-#endif
 	int phy_irq;		/* the phy irq (if it exists)  */
 
 	const struct fs_mii_bus_info *bus_info;
-- 
1.5.5.1
