From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 6/9] fs_enet: Be an of_platform device when
	CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Mon, 1 Oct 2007 14:20:54 -0500
Message-ID: <20071001192054.GE28429@loki.buserror.net>
References: <20071001192017.GA28410@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:52611 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbXJATVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 15:21:24 -0400
Content-Disposition: inline
In-Reply-To: <20071001192017.GA28410@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The existing OF glue code was crufty and broken.  Rather than fix it, it
will be removed, and the ethernet driver now talks to the device tree
directly.

The old, non-CONFIG_PPC_CPM_NEW_BINDING code can go away once CPM
platforms are dropped from arch/ppc (which will hopefully be soon), and
existing arch/powerpc boards that I wasn't able to test on for this
patchset get converted (which should be even sooner).

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/fs_enet/Kconfig        |    1 +
 drivers/net/fs_enet/fs_enet-main.c |  258 ++++++++++++++++++++++++++++++++---
 drivers/net/fs_enet/fs_enet.h      |   55 +-------
 drivers/net/fs_enet/mac-fcc.c      |   89 +++++++++----
 drivers/net/fs_enet/mac-fec.c      |   19 +++-
 drivers/net/fs_enet/mac-scc.c      |   53 +++++--
 drivers/net/fs_enet/mii-bitbang.c  |  269 +++++++++++++++++++++++++++---------
 drivers/net/fs_enet/mii-fec.c      |  143 +++++++++++++++++++-
 include/linux/fs_enet_pd.h         |    5 +
 9 files changed, 714 insertions(+), 178 deletions(-)

diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfig
index e27ee21..2765e49 100644
--- a/drivers/net/fs_enet/Kconfig
+++ b/drivers/net/fs_enet/Kconfig
@@ -11,6 +11,7 @@ config FS_ENET_HAS_SCC
 config FS_ENET_HAS_FCC
 	bool "Chip has an FCC usable for ethernet"
 	depends on FS_ENET && CPM2
+	select MDIO_BITBANG
 	default y
 
 config FS_ENET_HAS_FEC
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 7a02986..a2dee7d 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -42,12 +42,18 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+#include <asm/of_platform.h>
+#endif
+
 #include "fs_enet.h"
 
 /*************************************************/
 
+#ifndef CONFIG_PPC_CPM_NEW_BINDING
 static char version[] __devinitdata =
     DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")" "\n";
+#endif
 
 MODULE_AUTHOR("Pantelis Antoniou <panto@intracom.gr>");
 MODULE_DESCRIPTION("Freescale Ethernet Driver");
@@ -948,6 +954,7 @@ static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 extern int fs_mii_connect(struct net_device *dev);
 extern void fs_mii_disconnect(struct net_device *dev);
 
+#ifndef CONFIG_PPC_CPM_NEW_BINDING
 static struct net_device *fs_init_instance(struct device *dev,
 		struct fs_platform_info *fpi)
 {
@@ -1129,6 +1136,7 @@ static int fs_cleanup_instance(struct net_device *ndev)
 
 	return 0;
 }
+#endif
 
 /**************************************************************************************/
 
@@ -1137,35 +1145,250 @@ void *fs_enet_immap = NULL;
 
 static int setup_immap(void)
 {
-	phys_addr_t paddr = 0;
-	unsigned long size = 0;
-
 #ifdef CONFIG_CPM1
-	paddr = IMAP_ADDR;
-	size = 0x10000;	/* map 64K */
-#endif
-
-#ifdef CONFIG_CPM2
-	paddr = CPM_MAP_ADDR;
-	size = 0x40000;	/* map 256 K */
+	fs_enet_immap = ioremap(IMAP_ADDR, 0x4000);
+	WARN_ON(!fs_enet_immap);
+#elif defined(CONFIG_CPM2)
+	fs_enet_immap = cpm2_immr;
 #endif
-	fs_enet_immap = ioremap(paddr, size);
-	if (fs_enet_immap == NULL)
-		return -EBADF;	/* XXX ahem; maybe just BUG_ON? */
 
 	return 0;
 }
 
 static void cleanup_immap(void)
 {
-	if (fs_enet_immap != NULL) {
-		iounmap(fs_enet_immap);
-		fs_enet_immap = NULL;
-	}
+#if defined(CONFIG_CPM1)
+	iounmap(fs_enet_immap);
+#endif
 }
 
 /**************************************************************************************/
 
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+static int __devinit find_phy(struct device_node *np,
+                              struct fs_platform_info *fpi)
+{
+	struct device_node *phynode, *mdionode;
+	struct resource res;
+	int ret = 0, len;
+
+	const u32 *data = of_get_property(np, "phy-handle", &len);
+	if (!data || len != 4)
+		return -EINVAL;
+
+	phynode = of_find_node_by_phandle(*data);
+	if (!phynode)
+		return -EINVAL;
+
+	mdionode = of_get_parent(phynode);
+	if (!phynode)
+		goto out_put_phy;
+
+	ret = of_address_to_resource(mdionode, 0, &res);
+	if (ret)
+		goto out_put_mdio;
+
+	data = of_get_property(phynode, "reg", &len);
+	if (!data || len != 4)
+		goto out_put_mdio;
+
+	snprintf(fpi->bus_id, 16, PHY_ID_FMT, res.start, *data);
+
+out_put_mdio:
+	of_node_put(mdionode);
+out_put_phy:
+	of_node_put(phynode);
+	return ret;
+}
+
+#ifdef CONFIG_FS_ENET_HAS_FEC
+#define IS_FEC(match) ((match)->data == &fs_fec_ops)
+#else
+#define IS_FEC(match) 0
+#endif
+
+static int __devinit fs_enet_probe(struct of_device *ofdev,
+                                   const struct of_device_id *match)
+{
+	struct net_device *ndev;
+	struct fs_enet_private *fep;
+	struct fs_platform_info *fpi;
+	const u32 *data;
+	const u8 *mac_addr;
+	int privsize, len, ret = -ENODEV;
+
+	fpi = kzalloc(sizeof(*fpi), GFP_KERNEL);
+	if (!fpi)
+		return -ENOMEM;
+
+	if (!IS_FEC(match)) {
+		data = of_get_property(ofdev->node, "fsl,cpm-command", &len);
+		if (!data || len != 4)
+			goto out_free_fpi;
+
+		fpi->cp_command = *data;
+	}
+
+	fpi->rx_ring = 32;
+	fpi->tx_ring = 32;
+	fpi->rx_copybreak = 240;
+	fpi->use_napi = 0;
+	fpi->napi_weight = 17;
+
+	ret = find_phy(ofdev->node, fpi);
+	if (ret)
+		goto out_free_fpi;
+
+	privsize = sizeof(*fep) +
+	           sizeof(struct sk_buff **) *
+	           (fpi->rx_ring + fpi->tx_ring);
+
+	ndev = alloc_etherdev(privsize);
+	if (!ndev) {
+		ret = -ENOMEM;
+		goto out_free_fpi;
+	}
+
+	SET_MODULE_OWNER(ndev);
+	dev_set_drvdata(&ofdev->dev, ndev);
+
+	fep = netdev_priv(ndev);
+	fep->dev = &ofdev->dev;
+	fep->fpi = fpi;
+	fep->ops = match->data;
+
+	ret = fep->ops->setup_data(ndev);
+	if (ret)
+		goto out_free_dev;
+
+	fep->rx_skbuff = (struct sk_buff **)&fep[1];
+	fep->tx_skbuff = fep->rx_skbuff + fpi->rx_ring;
+
+	spin_lock_init(&fep->lock);
+	spin_lock_init(&fep->tx_lock);
+
+	mac_addr = of_get_mac_address(ofdev->node);
+	if (mac_addr)
+		memcpy(ndev->dev_addr, mac_addr, 6);
+
+	ret = fep->ops->allocate_bd(ndev);
+	if (ret)
+		goto out_cleanup_data;
+
+	fep->rx_bd_base = fep->ring_base;
+	fep->tx_bd_base = fep->rx_bd_base + fpi->rx_ring;
+
+	fep->tx_ring = fpi->tx_ring;
+	fep->rx_ring = fpi->rx_ring;
+
+	ndev->open = fs_enet_open;
+	ndev->hard_start_xmit = fs_enet_start_xmit;
+	ndev->tx_timeout = fs_timeout;
+	ndev->watchdog_timeo = 2 * HZ;
+	ndev->stop = fs_enet_close;
+	ndev->get_stats = fs_enet_get_stats;
+	ndev->set_multicast_list = fs_set_multicast_list;
+	if (fpi->use_napi) {
+		ndev->poll = fs_enet_rx_napi;
+		ndev->weight = fpi->napi_weight;
+	}
+	ndev->ethtool_ops = &fs_ethtool_ops;
+	ndev->do_ioctl = fs_ioctl;
+
+	init_timer(&fep->phy_timer_list);
+
+	netif_carrier_off(ndev);
+
+	ret = register_netdev(ndev);
+	if (ret)
+		goto out_free_bd;
+
+	printk(KERN_INFO "%s: fs_enet: %02x:%02x:%02x:%02x:%02x:%02x\n",
+	       ndev->name,
+	       ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
+	       ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);
+
+	return 0;
+
+out_free_bd:
+	fep->ops->free_bd(ndev);
+out_cleanup_data:
+	fep->ops->cleanup_data(ndev);
+out_free_dev:
+	free_netdev(ndev);
+	dev_set_drvdata(&ofdev->dev, NULL);
+out_free_fpi:
+	kfree(fpi);
+	return ret;
+}
+
+static int fs_enet_remove(struct of_device *ofdev)
+{
+	struct net_device *ndev = dev_get_drvdata(&ofdev->dev);
+	struct fs_enet_private *fep = netdev_priv(ndev);
+
+	unregister_netdev(ndev);
+
+	fep->ops->free_bd(ndev);
+	fep->ops->cleanup_data(ndev);
+	dev_set_drvdata(fep->dev, NULL);
+
+	free_netdev(ndev);
+	return 0;
+}
+
+static struct of_device_id fs_enet_match[] = {
+#ifdef CONFIG_FS_ENET_HAS_SCC
+	{
+		.compatible = "fsl,cpm1-scc-enet",
+		.data = (void *)&fs_scc_ops,
+	},
+#endif
+#ifdef CONFIG_FS_ENET_HAS_FCC
+	{
+		.compatible = "fsl,cpm2-fcc-enet",
+		.data = (void *)&fs_fcc_ops,
+	},
+#endif
+#ifdef CONFIG_FS_ENET_HAS_FEC
+	{
+		.compatible = "fsl,pq1-fec-enet",
+		.data = (void *)&fs_fec_ops,
+	},
+#endif
+	{}
+};
+
+static struct of_platform_driver fs_enet_driver = {
+	.name	= "fs_enet",
+	.match_table = fs_enet_match,
+	.probe = fs_enet_probe,
+	.remove = fs_enet_remove,
+};
+
+static int __init fs_init(void)
+{
+	int r = setup_immap();
+	if (r != 0)
+		return r;
+
+	r = of_register_platform_driver(&fs_enet_driver);
+	if (r != 0)
+		goto out;
+
+	return 0;
+
+out:
+	cleanup_immap();
+	return r;
+}
+
+static void __exit fs_cleanup(void)
+{
+	of_unregister_platform_driver(&fs_enet_driver);
+	cleanup_immap();
+}
+#else
 static int __devinit fs_enet_probe(struct device *dev)
 {
 	struct net_device *ndev;
@@ -1279,6 +1502,7 @@ static void __exit fs_cleanup(void)
 	driver_unregister(&fs_enet_scc_driver);
 	cleanup_immap();
 }
+#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void fs_enet_netpoll(struct net_device *dev)
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index 85571e4..5a5c9d1 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -24,19 +24,6 @@ struct fec_info {
 #include <asm/cpm2.h>
 #endif
 
-/* This is used to operate with pins.
-  Note that the actual port size may
-    be different; cpm(s) handle it OK  */
-struct bb_info {
-	u8 mdio_dat_msk;
-	u8 mdio_dir_msk;
-	u8 *mdio_dir;
-	u8 *mdio_dat;
-	u8 mdc_msk;
-	u8 *mdc_dat;
-	int delay;
-};
-
 /* hw driver ops */
 struct fs_ops {
 	int (*setup_data)(struct net_device *dev);
@@ -85,48 +72,12 @@ struct phy_info {
 #define ENET_RX_ALIGN  16
 #define ENET_RX_FRSIZE L1_CACHE_ALIGN(PKT_MAXBUF_SIZE + ENET_RX_ALIGN - 1)
 
-struct fs_enet_mii_bus {
-	struct list_head list;
-	spinlock_t mii_lock;
-	const struct fs_mii_bus_info *bus_info;
-	int refs;
-	u32 usage_map;
-
-	int (*mii_read)(struct fs_enet_mii_bus *bus,
-			int phy_id, int location);
-
-	void (*mii_write)(struct fs_enet_mii_bus *bus,
-			int phy_id, int location, int value);
-
-	union {
-		struct {
-			unsigned int mii_speed;
-			void *fecp;
-		} fec;
-
-		struct {
-			/* note that the actual port size may */
-			/* be different; cpm(s) handle it OK  */
-			u8 mdio_msk;
-			u8 *mdio_dir;
-			u8 *mdio_dat;
-			u8 mdc_msk;
-			u8 *mdc_dir;
-			u8 *mdc_dat;
-		} bitbang;
-
-		struct {
-			u16 lpa;
-		} fixed;
-	};
-};
-
 struct fs_enet_private {
 	struct napi_struct napi;
 	struct device *dev;	/* pointer back to the device (must be initialized first) */
 	spinlock_t lock;	/* during all ops except TX pckt processing */
 	spinlock_t tx_lock;	/* during fs_start_xmit and fs_tx         */
-	const struct fs_platform_info *fpi;
+	struct fs_platform_info *fpi;
 	const struct fs_ops *ops;
 	int rx_ring, tx_ring;
 	dma_addr_t ring_mem_addr;
@@ -145,7 +96,6 @@ struct fs_enet_private {
 	u32 msg_enable;
 	struct mii_if_info mii_if;
 	unsigned int last_mii_status;
-	struct fs_enet_mii_bus *mii_bus;
 	int interrupt;
 
 	struct phy_device *phydev;
@@ -187,9 +137,10 @@ struct fs_enet_private {
 };
 
 /***************************************************************************/
+#ifndef CONFIG_PPC_CPM_NEW_BINDING
 int fs_enet_mdio_bb_init(void);
-int fs_mii_fixed_init(struct fs_enet_mii_bus *bus);
 int fs_enet_mdio_fec_init(void);
+#endif
 
 void fs_init_bds(struct net_device *dev);
 void fs_cleanup_bds(struct net_device *dev);
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index e990f72..6094cbf 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -42,6 +42,10 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+#include <asm/of_device.h>
+#endif
+
 #include "fs_enet.h"
 
 /*************************************************/
@@ -74,33 +78,64 @@
 
 #define MAX_CR_CMD_LOOPS	10000
 
-static inline int fcc_cr_cmd(struct fs_enet_private *fep, u32 mcn, u32 op)
+static inline int fcc_cr_cmd(struct fs_enet_private *fep, u32 op)
 {
 	const struct fs_platform_info *fpi = fep->fpi;
 	cpm2_map_t *immap = fs_enet_immap;
 	cpm_cpm2_t *cpmp = &immap->im_cpm;
-	u32 v;
 	int i;
 
-	/* Currently I don't know what feature call will look like. But
-	   I guess there'd be something like do_cpm_cmd() which will require page & sblock */
-	v = mk_cr_cmd(fpi->cp_page, fpi->cp_block, mcn, op);
-	W32(cpmp, cp_cpcr, v | CPM_CR_FLG);
+	W32(cpmp, cp_cpcr, fpi->cp_command | op | CPM_CR_FLG);
 	for (i = 0; i < MAX_CR_CMD_LOOPS; i++)
 		if ((R32(cpmp, cp_cpcr) & CPM_CR_FLG) == 0)
-			break;
-
-	if (i >= MAX_CR_CMD_LOOPS) {
-		printk(KERN_ERR "%s(): Not able to issue CPM command\n",
-		       __FUNCTION__);
-		return 1;
-	}
+			return 0;
 
-	return 0;
+	printk(KERN_ERR "%s(): Not able to issue CPM command\n",
+	       __FUNCTION__);
+	return 1;
 }
 
 static int do_pd_setup(struct fs_enet_private *fep)
 {
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+	struct of_device *ofdev = to_of_device(fep->dev);
+	struct fs_platform_info *fpi = fep->fpi;
+	int ret = -EINVAL;
+
+	fep->interrupt = of_irq_to_resource(ofdev->node, 0, NULL);
+	if (fep->interrupt == NO_IRQ)
+		goto out;
+
+	fep->fcc.fccp = of_iomap(ofdev->node, 0);
+	if (!fep->fcc.fccp)
+		goto out;
+
+	fep->fcc.ep = of_iomap(ofdev->node, 1);
+	if (!fep->fcc.ep)
+		goto out_fccp;
+
+	fep->fcc.fcccp = of_iomap(ofdev->node, 2);
+	if (!fep->fcc.fcccp)
+		goto out_ep;
+
+	fep->fcc.mem = (void *)cpm_dpalloc(128, 8);
+	fpi->dpram_offset = (u32)cpm2_immr;
+	if (IS_ERR_VALUE(fpi->dpram_offset)) {
+		ret = fpi->dpram_offset;
+		goto out_fcccp;
+	}
+
+	return 0;
+
+out_fcccp:
+	iounmap(fep->fcc.fcccp);
+out_ep:
+	iounmap(fep->fcc.ep);
+out_fccp:
+	iounmap(fep->fcc.fccp);
+out:
+	return ret;
+#else
 	struct platform_device *pdev = to_platform_device(fep->dev);
 	struct resource *r;
 
@@ -138,6 +173,7 @@ static int do_pd_setup(struct fs_enet_private *fep)
 		return -EINVAL;
 
 	return 0;
+#endif
 }
 
 #define FCC_NAPI_RX_EVENT_MSK	(FCC_ENET_RXF | FCC_ENET_RXB)
@@ -148,11 +184,17 @@ static int do_pd_setup(struct fs_enet_private *fep)
 static int setup_data(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	const struct fs_platform_info *fpi = fep->fpi;
+#ifndef CONFIG_PPC_CPM_NEW_BINDING
+	struct fs_platform_info *fpi = fep->fpi;
+
+	fpi->cp_command = (fpi->cp_page << 26) |
+	                  (fpi->cp_block << 21) |
+	                  (12 << 6);
 
 	fep->fcc.idx = fs_get_fcc_index(fpi->fs_no);
 	if ((unsigned int)fep->fcc.idx >= 3)	/* max 3 FCCs */
 		return -EINVAL;
+#endif
 
 	if (do_pd_setup(fep) != 0)
 		return -EINVAL;
@@ -226,7 +268,7 @@ static void set_multicast_one(struct net_device *dev, const u8 *mac)
 	W16(ep, fen_taddrh, taddrh);
 	W16(ep, fen_taddrm, taddrm);
 	W16(ep, fen_taddrl, taddrl);
-	fcc_cr_cmd(fep, 0x0C, CPM_CR_SET_GADDR);
+	fcc_cr_cmd(fep, CPM_CR_SET_GADDR);
 }
 
 static void set_multicast_finish(struct net_device *dev)
@@ -281,7 +323,7 @@ static void restart(struct net_device *dev)
 
 	/* clear everything (slow & steady does it) */
 	for (i = 0; i < sizeof(*ep); i++)
-		out_8((char *)ep + i, 0);
+		out_8((u8 __iomem *)ep + i, 0);
 
 	/* get physical address */
 	rx_bd_base_phys = fep->ring_mem_addr;
@@ -397,7 +439,7 @@ static void restart(struct net_device *dev)
 			S8(fcccp, fcc_gfemr, 0x20);
 	}
 
-	fcc_cr_cmd(fep, 0x0c, CPM_CR_INIT_TRX);
+	fcc_cr_cmd(fep, CPM_CR_INIT_TRX);
 
 	/* clear events */
 	W16(fccp, fcc_fcce, 0xffff);
@@ -515,23 +557,22 @@ int get_regs(struct net_device *dev, void *p, int *sizep)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
-	if (*sizep < sizeof(fcc_t) + sizeof(fcc_c_t) + sizeof(fcc_enet_t))
+	if (*sizep < sizeof(fcc_t) + sizeof(fcc_enet_t) + 1)
 		return -EINVAL;
 
 	memcpy_fromio(p, fep->fcc.fccp, sizeof(fcc_t));
 	p = (char *)p + sizeof(fcc_t);
 
-	memcpy_fromio(p, fep->fcc.fcccp, sizeof(fcc_c_t));
-	p = (char *)p + sizeof(fcc_c_t);
-
 	memcpy_fromio(p, fep->fcc.ep, sizeof(fcc_enet_t));
+	p = (char *)p + sizeof(fcc_enet_t);
 
+	memcpy_fromio(p, fep->fcc.fcccp, 1);
 	return 0;
 }
 
 int get_regs_len(struct net_device *dev)
 {
-	return sizeof(fcc_t) + sizeof(fcc_c_t) + sizeof(fcc_enet_t);
+	return sizeof(fcc_t) + sizeof(fcc_enet_t) + 1;
 }
 
 /* Some transmit errors cause the transmitter to shut
@@ -551,7 +592,7 @@ void tx_restart(struct net_device *dev)
 	udelay(10);
 	S32(fccp, fcc_gfmr, FCC_GFMR_ENT);
 
-	fcc_cr_cmd(fep, 0x0C, CPM_CR_RESTART_TX);
+	fcc_cr_cmd(fep, CPM_CR_RESTART_TX);
 }
 
 /*************************************************************************/
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index cbdc17b..924d661 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -43,6 +43,10 @@
 #include <asm/commproc.h>
 #endif
 
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+#include <asm/of_device.h>
+#endif
+
 #include "fs_enet.h"
 #include "fec.h"
 
@@ -95,6 +99,19 @@ static int whack_reset(fec_t * fecp)
 
 static int do_pd_setup(struct fs_enet_private *fep)
 {
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+	struct of_device *ofdev = to_of_device(fep->dev);
+
+	fep->interrupt = of_irq_to_resource(ofdev->node, 0, NULL);
+	if (fep->interrupt == NO_IRQ)
+		return -EINVAL;
+
+	fep->fec.fecp = of_iomap(ofdev->node, 0);
+	if (!fep->fcc.fccp)
+		return -EINVAL;
+
+	return 0;
+#else
 	struct platform_device *pdev = to_platform_device(fep->dev);
 	struct resource	*r;
 
@@ -110,7 +127,7 @@ static int do_pd_setup(struct fs_enet_private *fep)
 		return -EINVAL;
 
 	return 0;
-
+#endif
 }
 
 #define FEC_NAPI_RX_EVENT_MSK	(FEC_ENET_RXF | FEC_ENET_RXB)
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 6f32674..add9e32 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -43,6 +43,10 @@
 #include <asm/commproc.h>
 #endif
 
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+#include <asm/of_platform.h>
+#endif
+
 #include "fs_enet.h"
 
 /*************************************************/
@@ -89,27 +93,38 @@
 
 static inline int scc_cr_cmd(struct fs_enet_private *fep, u32 op)
 {
-	cpm8xx_t *cpmp = &((immap_t *)fs_enet_immap)->im_cpm;
-	u32 v, ch;
-	int i = 0;
+	const struct fs_platform_info *fpi = fep->fpi;
+	int i;
 
-	ch = fep->scc.idx << 2;
-	v = mk_cr_cmd(ch, op);
-	W16(cpmp, cp_cpcr, v | CPM_CR_FLG);
+	W16(cpmp, cp_cpcr, fpi->cp_command | CPM_CR_FLG | (op << 8));
 	for (i = 0; i < MAX_CR_CMD_LOOPS; i++)
 		if ((R16(cpmp, cp_cpcr) & CPM_CR_FLG) == 0)
-			break;
+			return 0;
 
-	if (i >= MAX_CR_CMD_LOOPS) {
-		printk(KERN_ERR "%s(): Not able to issue CPM command\n",
-			__FUNCTION__);
-		return 1;
-	}
-	return 0;
+	printk(KERN_ERR "%s(): Not able to issue CPM command\n",
+		__FUNCTION__);
+	return 1;
 }
 
 static int do_pd_setup(struct fs_enet_private *fep)
 {
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+	struct of_device *ofdev = to_of_device(fep->dev);
+
+	fep->interrupt = of_irq_to_resource(ofdev->node, 0, NULL);
+	if (fep->interrupt == NO_IRQ)
+		return -EINVAL;
+
+	fep->scc.sccp = of_iomap(ofdev->node, 0);
+	if (!fep->scc.sccp)
+		return -EINVAL;
+
+	fep->scc.ep = of_iomap(ofdev->node, 1);
+	if (!fep->scc.ep) {
+		iounmap(fep->scc.sccp);
+		return -EINVAL;
+	}
+#else
 	struct platform_device *pdev = to_platform_device(fep->dev);
 	struct resource *r;
 
@@ -129,6 +144,7 @@ static int do_pd_setup(struct fs_enet_private *fep)
 
 	if (fep->scc.ep == NULL)
 		return -EINVAL;
+#endif
 
 	return 0;
 }
@@ -141,12 +157,17 @@ static int do_pd_setup(struct fs_enet_private *fep)
 static int setup_data(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	const struct fs_platform_info *fpi = fep->fpi;
+
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+	struct fs_platform_info *fpi = fep->fpi;
 
 	fep->scc.idx = fs_get_scc_index(fpi->fs_no);
-	if ((unsigned int)fep->fcc.idx > 4)	/* max 4 SCCs */
+	if ((unsigned int)fep->fcc.idx >= 4) /* max 4 SCCs */
 		return -EINVAL;
 
+	fpi->cp_command = fep->fcc.idx << 6;
+#endif
+
 	do_pd_setup(fep);
 
 	fep->scc.hthi = 0;
@@ -154,7 +175,7 @@ static int setup_data(struct net_device *dev)
 
 	fep->ev_napi_rx = SCC_NAPI_RX_EVENT_MSK;
 	fep->ev_rx = SCC_RX_EVENT;
-	fep->ev_tx = SCC_TX_EVENT;
+	fep->ev_tx = SCC_TX_EVENT | SCCE_ENET_TXE;
 	fep->ev_err = SCC_ERR_EVENT_MSK;
 
 	return 0;
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 422f828..7cf132f 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -13,11 +13,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/ptrace.h>
-#include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
@@ -25,86 +20,77 @@
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/bitops.h>
 #include <linux/platform_device.h>
 
-#include <asm/pgtable.h>
-#include <asm/irq.h>
-#include <asm/uaccess.h>
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+#include <linux/of_platform.h>
+#endif
 
 #include "fs_enet.h"
 
-static int bitbang_prep_bit(u8 **datp, u8 *mskp,
-		struct fs_mii_bit *mii_bit)
-{
-	void *dat;
-	int adv;
-	u8 msk;
-
-	dat = (void*) mii_bit->offset;
-
-	adv = mii_bit->bit >> 3;
-	dat = (char *)dat + adv;
-
-	msk = 1 << (7 - (mii_bit->bit & 7));
-
-	*datp = dat;
-	*mskp = msk;
-
-	return 0;
-}
+struct bb_info {
+	__be32 __iomem *dir;
+	__be32 __iomem *dat;
+	u32 mdio_msk;
+	u32 mdc_msk;
+	int delay;
+};
 
-static inline void bb_set(u8 *p, u8 m)
+/* FIXME: If any other users of GPIO crop up, then these will have to
+ * have some sort of global synchronization to avoid races with other
+ * pins on the same port.  The ideal solution would probably be to
+ * bind the ports to a GPIO driver, and have this be a client of it.
+ */
+static inline void bb_set(u32 __iomem *p, u32 m)
 {
-	out_8(p, in_8(p) | m);
+	out_be32(p, in_be32(p) | m);
 }
 
-static inline void bb_clr(u8 *p, u8 m)
+static inline void bb_clr(u32 __iomem *p, u32 m)
 {
-	out_8(p, in_8(p) & ~m);
+	out_be32(p, in_be32(p) & ~m);
 }
 
-static inline int bb_read(u8 *p, u8 m)
+static inline int bb_read(u32 __iomem *p, u32 m)
 {
-	return (in_8(p) & m) != 0;
+	return (in_be32(p) & m) != 0;
 }
 
 static inline void mdio_active(struct bb_info *bitbang)
 {
-	bb_set(bitbang->mdio_dir, bitbang->mdio_dir_msk);
+	bb_set(bitbang->dir, bitbang->mdio_msk);
 }
 
-static inline void mdio_tristate(struct bb_info *bitbang )
+static inline void mdio_tristate(struct bb_info *bitbang)
 {
-	bb_clr(bitbang->mdio_dir, bitbang->mdio_dir_msk);
+	bb_clr(bitbang->dir, bitbang->mdio_msk);
 }
 
-static inline int mdio_read(struct bb_info *bitbang )
+static inline int mdio_read(struct bb_info *bitbang)
 {
-	return bb_read(bitbang->mdio_dat, bitbang->mdio_dat_msk);
+	return bb_read(bitbang->dat, bitbang->mdio_msk);
 }
 
-static inline void mdio(struct bb_info *bitbang , int what)
+static inline void mdio(struct bb_info *bitbang, int what)
 {
 	if (what)
-		bb_set(bitbang->mdio_dat, bitbang->mdio_dat_msk);
+		bb_set(bitbang->dat, bitbang->mdio_msk);
 	else
-		bb_clr(bitbang->mdio_dat, bitbang->mdio_dat_msk);
+		bb_clr(bitbang->dat, bitbang->mdio_msk);
 }
 
-static inline void mdc(struct bb_info *bitbang , int what)
+static inline void mdc(struct bb_info *bitbang, int what)
 {
 	if (what)
-		bb_set(bitbang->mdc_dat, bitbang->mdc_msk);
+		bb_set(bitbang->dat, bitbang->mdc_msk);
 	else
-		bb_clr(bitbang->mdc_dat, bitbang->mdc_msk);
+		bb_clr(bitbang->dat, bitbang->mdc_msk);
 }
 
-static inline void mii_delay(struct bb_info *bitbang )
+static inline void mii_delay(struct bb_info *bitbang)
 {
 	udelay(bitbang->delay);
 }
@@ -280,29 +266,178 @@ static int fs_enet_mii_bb_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static int fs_mii_bitbang_init(struct bb_info *bitbang, struct fs_mii_bb_platform_info* fmpi)
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
+                                         struct device_node *np)
 {
-	int r;
+	struct resource res;
+	const u32 *data;
+	int mdio_pin, mdc_pin, len;
+	struct bb_info *bitbang = bus->priv;
 
-	bitbang->delay = fmpi->delay;
+	int ret = of_address_to_resource(np, 0, &res);
+	if (ret)
+		return ret;
+
+	if (res.end - res.start < 13)
+		return -ENODEV;
+
+	/* This should really encode the pin number as well, but all
+	 * we get is an int, and the odds of multiple bitbang mdio buses
+	 * is low enough that it's not worth going too crazy.
+	 */
+	bus->id = res.start;
+
+	data = of_get_property(np, "fsl,mdio-pin", &len);
+	if (!data || len != 4)
+		return -ENODEV;
+	mdio_pin = *data;
+
+	data = of_get_property(np, "fsl,mdc-pin", &len);
+	if (!data || len != 4)
+		return -ENODEV;
+	mdc_pin = *data;
+
+	bitbang->dir = ioremap(res.start, res.end - res.start + 1);
+	if (!bitbang->dir)
+		return -ENOMEM;
+
+	bitbang->dat = bitbang->dir + 4;
+	bitbang->mdio_msk = 1 << (31 - mdio_pin);
+	bitbang->mdc_msk = 1 << (31 - mdc_pin);
+	bitbang->delay = 1; /* 1 us between operations */
 
-	r = bitbang_prep_bit(&bitbang->mdio_dir,
-			 &bitbang->mdio_dir_msk,
-			 &fmpi->mdio_dir);
-	if (r != 0)
-		return r;
-
-	r = bitbang_prep_bit(&bitbang->mdio_dat,
-			 &bitbang->mdio_dat_msk,
-			 &fmpi->mdio_dat);
-	if (r != 0)
-		return r;
-
-	r = bitbang_prep_bit(&bitbang->mdc_dat,
-			 &bitbang->mdc_msk,
-			 &fmpi->mdc_dat);
-	if (r != 0)
-		return r;
+	return 0;
+}
+
+static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
+{
+	const u32 *data;
+	int len, id, irq;
+
+	data = of_get_property(np, "reg", &len);
+	if (!data || len != 4)
+		return;
+
+	id = *data;
+	bus->phy_mask &= ~(1 << id);
+
+	irq = of_irq_to_resource(np, 0, NULL);
+	if (irq != NO_IRQ)
+		bus->irq[id] = irq;
+}
+
+static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
+                                        const struct of_device_id *match)
+{
+	struct device_node *np = NULL;
+	struct mii_bus *new_bus;
+	struct bb_info *bitbang;
+	int ret = -ENOMEM;
+	int i;
+
+	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+	if (!new_bus)
+		goto out;
+
+	bitbang = kzalloc(sizeof(struct bb_info), GFP_KERNEL);
+	if (!bitbang)
+		goto out_free_bus;
+
+	new_bus->priv = bitbang;
+	new_bus->name = "CPM2 Bitbanged MII",
+	new_bus->read = &fs_enet_mii_bb_read,
+	new_bus->write = &fs_enet_mii_bb_write,
+	new_bus->reset = &fs_enet_mii_bb_reset,
+
+	ret = fs_mii_bitbang_init(new_bus, ofdev->node);
+	if (ret)
+		goto out_free_bitbang;
+
+	new_bus->phy_mask = ~0;
+	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!new_bus->irq)
+		goto out_unmap_regs;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		new_bus->irq[i] = -1;
+
+	while ((np = of_get_next_child(ofdev->node, np)))
+		if (!strcmp(np->type, "ethernet-phy"))
+			add_phy(new_bus, np);
+
+	new_bus->dev = &ofdev->dev;
+	dev_set_drvdata(&ofdev->dev, new_bus);
+
+	ret = mdiobus_register(new_bus);
+	if (ret)
+		goto out_free_irqs;
+
+	return 0;
+
+out_free_irqs:
+	dev_set_drvdata(&ofdev->dev, NULL);
+	kfree(new_bus->irq);
+out_unmap_regs:
+	iounmap(bitbang->dir);
+out_free_bitbang:
+	kfree(bitbang);
+out_free_bus:
+	kfree(new_bus);
+out:
+	return ret;
+}
+
+static int fs_enet_mdio_remove(struct of_device *ofdev)
+{
+	struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
+	struct bb_info *bitbang = bus->priv;
+
+	mdiobus_unregister(bus);
+	dev_set_drvdata(&ofdev->dev, NULL);
+	kfree(bus->irq);
+	iounmap(bitbang->dir);
+	kfree(bitbang);
+	kfree(bus);
+
+	return 0;
+}
+
+static struct of_device_id fs_enet_mdio_bb_match[] = {
+	{
+		.compatible = "fsl,cpm2-mdio-bitbang",
+	},
+	{},
+};
+
+static struct of_platform_driver fs_enet_bb_mdio_driver = {
+	.name = "fsl-bb-mdio",
+	.match_table = fs_enet_mdio_bb_match,
+	.probe = fs_enet_mdio_probe,
+	.remove = fs_enet_mdio_remove,
+};
+
+int fs_enet_mdio_bb_init(void)
+{
+	return of_register_platform_driver(&fs_enet_bb_mdio_driver);
+}
+
+void fs_enet_mdio_bb_exit(void)
+{
+	of_unregister_platform_driver(&fs_enet_bb_mdio_driver);
+}
+
+module_init(fs_enet_mdio_bb_init);
+module_exit(fs_enet_mdio_bb_exit);
+#else
+static int __devinit fs_mii_bitbang_init(struct bb_info *bitbang,
+                                         struct fs_mii_bb_platform_info *fmpi)
+{
+	bitbang->dir = (u32 __iomem *)fmpi->mdio_dir.offset;
+	bitbang->dat = (u32 __iomem *)fmpi->mdio_dat.offset;
+	bitbang->mdio_msk = 1U << (31 - fmpi->mdio_dat.bit);
+	bitbang->mdc_msk = 1U << (31 - fmpi->mdc_dat.bit);
+	bitbang->delay = fmpi->delay;
 
 	return 0;
 }
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 53db696..f91c38d 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -36,6 +36,10 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+#include <asm/of_platform.h>
+#endif
+
 #include "fs_enet.h"
 #include "fec.h"
 
@@ -47,6 +51,7 @@
 
 #define FEC_MII_LOOPS	10000
 
+#ifndef CONFIG_PPC_CPM_NEW_BINDING
 static int match_has_phy (struct device *dev, void* data)
 {
 	struct platform_device* pdev = container_of(dev, struct platform_device, dev);
@@ -90,6 +95,7 @@ static int fs_mii_fec_init(struct fec_info* fec, struct fs_mii_fec_platform_info
 
 	return 0;
 }
+#endif
 
 static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 {
@@ -145,6 +151,141 @@ static int fs_enet_fec_mii_reset(struct mii_bus *bus)
 	return 0;
 }
 
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
+{
+	const u32 *data;
+	int len, id, irq;
+
+	data = of_get_property(np, "reg", &len);
+	if (!data || len != 4)
+		return;
+
+	id = *data;
+	bus->phy_mask &= ~(1 << id);
+
+	irq = of_irq_to_resource(np, 0, NULL);
+	if (irq != NO_IRQ)
+		bus->irq[id] = irq;
+}
+
+static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
+                                        const struct of_device_id *match)
+{
+	struct device_node *np = NULL;
+	struct resource res;
+	struct mii_bus *new_bus;
+	struct fec_info *fec;
+	int ret = -ENOMEM, i;
+
+	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+	if (!new_bus)
+		goto out;
+
+	fec = kzalloc(sizeof(struct fec_info), GFP_KERNEL);
+	if (!fec)
+		goto out_mii;
+
+	new_bus->priv = fec;
+	new_bus->name = "FEC MII Bus";
+	new_bus->read = &fs_enet_fec_mii_read;
+	new_bus->write = &fs_enet_fec_mii_write;
+	new_bus->reset = &fs_enet_fec_mii_reset;
+
+	ret = of_address_to_resource(ofdev->node, 0, &res);
+	if (ret)
+		return ret;
+
+	new_bus->id = res.start;
+
+	fec->fecp = ioremap(res.start, res.end - res.start + 1);
+	if (!fec->fecp)
+		goto out_fec;
+
+	fec->mii_speed = ((ppc_proc_freq + 4999999) / 5000000) << 1;
+
+	setbits32(&fec->fecp->fec_r_cntrl, FEC_RCNTRL_MII_MODE);
+	setbits32(&fec->fecp->fec_ecntrl, FEC_ECNTRL_PINMUX |
+	                                  FEC_ECNTRL_ETHER_EN);
+	out_be32(&fec->fecp->fec_ievent, FEC_ENET_MII);
+	out_be32(&fec->fecp->fec_mii_speed, fec->mii_speed);
+
+	new_bus->phy_mask = ~0;
+	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!new_bus->irq)
+		goto out_unmap_regs;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		new_bus->irq[i] = -1;
+
+	while ((np = of_get_next_child(ofdev->node, np)))
+		if (!strcmp(np->type, "ethernet-phy"))
+			add_phy(new_bus, np);
+
+	new_bus->dev = &ofdev->dev;
+	dev_set_drvdata(&ofdev->dev, new_bus);
+
+	ret = mdiobus_register(new_bus);
+	if (ret)
+		goto out_free_irqs;
+
+	return 0;
+
+out_free_irqs:
+	dev_set_drvdata(&ofdev->dev, NULL);
+	kfree(new_bus->irq);
+out_unmap_regs:
+	iounmap(fec->fecp);
+out_fec:
+	kfree(fec);
+out_mii:
+	kfree(new_bus);
+out:
+	return ret;
+}
+
+static int fs_enet_mdio_remove(struct of_device *ofdev)
+{
+	struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
+	struct fec_info *fec = bus->priv;
+
+	mdiobus_unregister(bus);
+	dev_set_drvdata(&ofdev->dev, NULL);
+	kfree(bus->irq);
+	iounmap(fec->fecp);
+	kfree(fec);
+	kfree(bus);
+
+	return 0;
+}
+
+static struct of_device_id fs_enet_mdio_fec_match[] = {
+	{
+		.compatible = "fsl,pq1-fec-mdio",
+	},
+	{},
+};
+
+static struct of_platform_driver fs_enet_fec_mdio_driver = {
+	.name = "fsl-fec-mdio",
+	.match_table = fs_enet_mdio_fec_match,
+	.probe = fs_enet_mdio_probe,
+	.remove = fs_enet_mdio_remove,
+};
+
+static int fs_enet_mdio_fec_init(void)
+{
+	return of_register_platform_driver(&fs_enet_fec_mdio_driver);
+}
+
+static void fs_enet_mdio_fec_exit(void)
+{
+	of_unregister_platform_driver(&fs_enet_fec_mdio_driver);
+}
+
+module_init(fs_enet_mdio_fec_init);
+module_exit(fs_enet_mdio_fec_exit);
+#else
 static int __devinit fs_enet_fec_mdio_probe(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
@@ -235,4 +376,4 @@ void fs_enet_mdio_fec_exit(void)
 {
 	driver_unregister(&fs_enet_fec_mdio_driver);
 }
-
+#endif
diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
index 815c6f9..9bc045b 100644
--- a/include/linux/fs_enet_pd.h
+++ b/include/linux/fs_enet_pd.h
@@ -120,6 +120,7 @@ struct fs_platform_info {
 
 	u32 cp_page;		/* CPM page */
 	u32 cp_block;		/* CPM sblock */
+	u32 cp_command;		/* CPM page/sblock/mcn */
 
 	u32 clk_trx;		/* some stuff for pins & mux configuration*/
 	u32 clk_rx;
@@ -134,7 +135,11 @@ struct fs_platform_info {
 	u32 device_flags;
 
 	int phy_addr;		/* the phy address (-1 no phy) */
+#ifdef CONFIG_PPC_CPM_NEW_BINDING
+	char bus_id[16];
+#else
 	const char*	bus_id;
+#endif
 	int phy_irq;		/* the phy irq (if it exists)  */
 
 	const struct fs_mii_bus_info *bus_info;
-- 
1.5.3.2

