From: Andy Fleming <afleming@freescale.com>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Thu, 23 Dec 2004 15:00:13 -0600
Message-ID: <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: multipart/mixed; boundary=Apple-Mail-2-974361640
Cc: Kumar Gala <kumar.gala@freescale.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Apple-Mail-2-974361640
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed

It has been suggested that I split the patch into 2 parts: gianfar 
specific stuff, and PHY specific stuff.

Here is the result:


--Apple-Mail-2-974361640
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="gfar_12232004.patch"
Content-Disposition: attachment;
	filename=gfar_12232004.patch

diff -Nru a/arch/ppc/platforms/85xx/Makefile b/arch/ppc/platforms/85xx/Makefile
--- a/arch/ppc/platforms/85xx/Makefile	2004-12-23 12:39:15 -06:00
+++ b/arch/ppc/platforms/85xx/Makefile	2004-12-23 12:39:15 -06:00
@@ -1,6 +1,7 @@
 #
 # Makefile for the PowerPC 85xx linux kernel.
 #
+obj-$(CONFIG_85xx)		+= mpc85xx.o
 
 obj-$(CONFIG_MPC8540_ADS)	+= mpc85xx_ads_common.o mpc8540_ads.o
 obj-$(CONFIG_MPC8555_CDS)	+= mpc85xx_cds_common.o
diff -Nru a/arch/ppc/platforms/85xx/mpc8540.c b/arch/ppc/platforms/85xx/mpc8540.c
--- a/arch/ppc/platforms/85xx/mpc8540.c	2004-12-23 12:39:16 -06:00
+++ b/arch/ppc/platforms/85xx/mpc8540.c	2004-12-23 12:39:16 -06:00
@@ -22,7 +22,7 @@
 extern struct ocp_gfar_data mpc85xx_tsec1_def;
 extern struct ocp_gfar_data mpc85xx_tsec2_def;
 extern struct ocp_gfar_data mpc85xx_fec_def;
-extern struct ocp_mpc_i2c_data mpc85xx_i2c1_def;
+extern struct ocp_mpc_fs_data mpc85xx_i2c1_def;
 
 /* We use offsets for paddr since we do not know at compile time
  * what CCSRBAR is, platform code should fix this up in
diff -Nru a/arch/ppc/platforms/85xx/mpc8540_ads.c b/arch/ppc/platforms/85xx/mpc8540_ads.c
--- a/arch/ppc/platforms/85xx/mpc8540_ads.c	2004-12-23 12:39:15 -06:00
+++ b/arch/ppc/platforms/85xx/mpc8540_ads.c	2004-12-23 12:39:15 -06:00
@@ -32,6 +32,7 @@
 #include <linux/serial_core.h>
 #include <linux/initrd.h>
 #include <linux/module.h>
+#include <linux/fsl_devices.h>
 
 #include <asm/system.h>
 #include <asm/pgtable.h>
@@ -48,50 +49,24 @@
 #include <asm/irq.h>
 #include <asm/immap_85xx.h>
 #include <asm/kgdb.h>
-#include <asm/ocp.h>
 #include <mm/mmu_decl.h>
+#include <asm/ocp.h>
 
 #include <syslib/ppc85xx_common.h>
 #include <syslib/ppc85xx_setup.h>
 
 struct ocp_gfar_data mpc85xx_tsec1_def = {
-	.interruptTransmit = MPC85xx_IRQ_TSEC1_TX,
-	.interruptError = MPC85xx_IRQ_TSEC1_ERROR,
-	.interruptReceive = MPC85xx_IRQ_TSEC1_RX,
-	.interruptPHY = MPC85xx_IRQ_EXT5,
-	.flags = (GFAR_HAS_GIGABIT | GFAR_HAS_MULTI_INTR
-			| GFAR_HAS_RMON
-			| GFAR_HAS_PHY_INTR | GFAR_HAS_COALESCE),
-	.phyid = 0,
-	.phyregidx = 0,
 };
-
 struct ocp_gfar_data mpc85xx_tsec2_def = {
-	.interruptTransmit = MPC85xx_IRQ_TSEC2_TX,
-	.interruptError = MPC85xx_IRQ_TSEC2_ERROR,
-	.interruptReceive = MPC85xx_IRQ_TSEC2_RX,
-	.interruptPHY = MPC85xx_IRQ_EXT5,
-	.flags = (GFAR_HAS_GIGABIT | GFAR_HAS_MULTI_INTR
-			| GFAR_HAS_RMON
-			| GFAR_HAS_PHY_INTR | GFAR_HAS_COALESCE),
-	.phyid = 1,
-	.phyregidx = 0,
 };
-
 struct ocp_gfar_data mpc85xx_fec_def = {
-	.interruptTransmit = MPC85xx_IRQ_FEC,
-	.interruptError = MPC85xx_IRQ_FEC,
-	.interruptReceive = MPC85xx_IRQ_FEC,
-	.interruptPHY = MPC85xx_IRQ_EXT5,
-	.flags = 0,
-	.phyid = 3,
-	.phyregidx = 0,
 };
-
 struct ocp_fs_i2c_data mpc85xx_i2c1_def = {
 	.flags = FS_I2C_SEPARATE_DFSRR,
 };
 
+extern void * get_platform_data(enum fsl_devices dev);
+
 /* ************************************************************************
  *
  * Setup the architecture
@@ -100,10 +75,10 @@
 static void __init
 mpc8540ads_setup_arch(void)
 {
-	struct ocp_def *def;
-	struct ocp_gfar_data *einfo;
 	bd_t *binfo = (bd_t *) __res;
 	unsigned int freq;
+	struct gianfar_platform_data *pdata;
+	struct gianfar_mdio_data *mdata;
 
 	/* get the core frequency */
 	freq = binfo->bi_intfreq;
@@ -130,23 +105,26 @@
 	invalidate_tlbcam_entry(NUM_TLBCAMS - 1);
 #endif
 
-	def = ocp_get_one_device(OCP_VENDOR_FREESCALE, OCP_FUNC_GFAR, 0);
-	if (def) {
-		einfo = (struct ocp_gfar_data *) def->additions;
-		memcpy(einfo->mac_addr, binfo->bi_enetaddr, 6);
-	}
-
-	def = ocp_get_one_device(OCP_VENDOR_FREESCALE, OCP_FUNC_GFAR, 1);
-	if (def) {
-		einfo = (struct ocp_gfar_data *) def->additions;
-		memcpy(einfo->mac_addr, binfo->bi_enet1addr, 6);
-	}
-
-	def = ocp_get_one_device(OCP_VENDOR_FREESCALE, OCP_FUNC_GFAR, 2);
-	if (def) {
-		einfo = (struct ocp_gfar_data *) def->additions;
-		memcpy(einfo->mac_addr, binfo->bi_enet2addr, 6);
-	}
+	/* setup the board related information for the enet controllers */
+	pdata = (struct gianfar_platform_data *) get_platform_data(MPC85xx_TSEC1);
+	pdata->bus_id = "phy0:0";
+	memcpy(pdata->mac_addr, binfo->bi_enetaddr, 6);
+
+	mdata = (struct gianfar_mdio_data *) get_platform_data(MPC85xx_MDIO);
+	mdata->paddr += binfo->bi_immr_base;
+	memset(&mdata->irq, -1, sizeof(mdata->irq));
+	mdata->irq[0] = MPC85xx_IRQ_EXT5;
+	mdata->irq[1] = MPC85xx_IRQ_EXT5;
+	mdata->irq[2] = MPC85xx_IRQ_EXT5;
+	mdata->irq[3] = MPC85xx_IRQ_EXT5;
+
+	pdata = (struct gianfar_platform_data *) get_platform_data(MPC85xx_TSEC2);
+	pdata->bus_id = "phy0:1";
+	memcpy(pdata->mac_addr, binfo->bi_enet1addr, 6);
+
+	pdata = (struct gianfar_platform_data *) get_platform_data(MPC85xx_FEC);
+	pdata->bus_id = "phy0:3";
+	memcpy(pdata->mac_addr, binfo->bi_enet2addr, 6);
 
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (initrd_start)
@@ -158,8 +136,6 @@
 #else
 		ROOT_DEV = Root_HDA1;
 #endif
-
-	ocp_for_each_device(mpc85xx_update_paddr_ocp, &(binfo->bi_immr_base));
 }
 
 /* ************************************************************************ */
diff -Nru a/arch/ppc/platforms/85xx/mpc8560_ads.c b/arch/ppc/platforms/85xx/mpc8560_ads.c
--- a/arch/ppc/platforms/85xx/mpc8560_ads.c	2004-12-23 12:39:16 -06:00
+++ b/arch/ppc/platforms/85xx/mpc8560_ads.c	2004-12-23 12:39:16 -06:00
@@ -48,7 +48,6 @@
 #include <asm/irq.h>
 #include <asm/immap_85xx.h>
 #include <asm/kgdb.h>
-#include <asm/ocp.h>
 #include <asm/cpm2.h>
 #include <mm/mmu_decl.h>
 
@@ -59,33 +58,15 @@
 extern void cpm2_reset(void);
 
 struct ocp_gfar_data mpc85xx_tsec1_def = {
-        .interruptTransmit = MPC85xx_IRQ_TSEC1_TX,
-        .interruptError = MPC85xx_IRQ_TSEC1_ERROR,
-        .interruptReceive = MPC85xx_IRQ_TSEC1_RX,
-        .interruptPHY = MPC85xx_IRQ_EXT5,
-        .flags = (GFAR_HAS_GIGABIT | GFAR_HAS_MULTI_INTR
-			| GFAR_HAS_RMON | GFAR_HAS_COALESCE
-                        | GFAR_HAS_PHY_INTR),
-        .phyid = 0,
-        .phyregidx = 0,
 };
-
 struct ocp_gfar_data mpc85xx_tsec2_def = {
-        .interruptTransmit = MPC85xx_IRQ_TSEC2_TX,
-        .interruptError = MPC85xx_IRQ_TSEC2_ERROR,
-        .interruptReceive = MPC85xx_IRQ_TSEC2_RX,
-        .interruptPHY = MPC85xx_IRQ_EXT5,
-        .flags = (GFAR_HAS_GIGABIT | GFAR_HAS_MULTI_INTR
-			| GFAR_HAS_RMON | GFAR_HAS_COALESCE
-                        | GFAR_HAS_PHY_INTR),
-        .phyid = 1,
-        .phyregidx = 0,
 };
-
 struct ocp_fs_i2c_data mpc85xx_i2c1_def = {
 	.flags = FS_I2C_SEPARATE_DFSRR,
 };
 
+extern void * get_platform_data(enum fsl_devices dev);
+
 /* ************************************************************************
  *
  * Setup the architecture
@@ -95,10 +76,10 @@
 static void __init
 mpc8560ads_setup_arch(void)
 {
-	struct ocp_def *def;
-	struct ocp_gfar_data *einfo;
 	bd_t *binfo = (bd_t *) __res;
 	unsigned int freq;
+	struct gianfar_platform_data *pdata;
+	struct gianfar_mdio_data *mdata;
 
 	cpm2_reset();
 
@@ -117,17 +98,22 @@
 	mpc85xx_setup_hose();
 #endif
 
-	def = ocp_get_one_device(OCP_VENDOR_FREESCALE, OCP_FUNC_GFAR, 0);
-	if (def) {
-		einfo = (struct ocp_gfar_data *) def->additions;
-		memcpy(einfo->mac_addr, binfo->bi_enetaddr, 6);
-	}
-
-	def = ocp_get_one_device(OCP_VENDOR_FREESCALE, OCP_FUNC_GFAR, 1);
-	if (def) {
-		einfo = (struct ocp_gfar_data *) def->additions;
-		memcpy(einfo->mac_addr, binfo->bi_enet1addr, 6);
-	}
+	/* setup the board related information for the enet controllers */
+	pdata = (struct gianfar_platform_data *) get_platform_data(MPC85xx_TSEC1);
+	pdata->bus_id = "phy0:0";
+	memcpy(pdata->mac_addr, binfo->bi_enetaddr, 6);
+
+	mdata = (struct gianfar_mdio_data *) get_platform_data(MPC85xx_MDIO);
+	mdata->paddr += binfo->bi_immr_base;
+	memset(&mdata->irq, -1, sizeof(mdata->irq));
+	mdata->irq[0] = MPC85xx_IRQ_EXT5;
+	mdata->irq[1] = MPC85xx_IRQ_EXT5;
+	mdata->irq[2] = MPC85xx_IRQ_EXT5;
+	mdata->irq[3] = MPC85xx_IRQ_EXT5;
+
+	pdata = (struct gianfar_platform_data *) get_platform_data(MPC85xx_TSEC2);
+	pdata->bus_id = "phy0:1";
+	memcpy(pdata->mac_addr, binfo->bi_enet1addr, 6);
 
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (initrd_start)
@@ -139,8 +125,6 @@
 #else
 		ROOT_DEV = Root_HDA1;
 #endif
-
-	ocp_for_each_device(mpc85xx_update_paddr_ocp, &(binfo->bi_immr_base));
 }
 
 static irqreturn_t cpm2_cascade(int irq, void *dev_id, struct pt_regs *regs)
diff -Nru a/drivers/base/platform.c b/drivers/base/platform.c
--- a/drivers/base/platform.c	2004-12-23 12:39:15 -06:00
+++ b/drivers/base/platform.c	2004-12-23 12:39:15 -06:00
@@ -58,6 +58,42 @@
 }
 
 /**
+ *	platform_get_resource_byname - get a resource for a device by name
+ *	@dev: platform device
+ *	@type: resource type
+ *	@name: resource name
+ */
+struct resource *
+platform_get_resource_byname(struct platform_device *dev, unsigned int type,
+		      char * name)
+{
+	int i;
+
+	for (i = 0; i < dev->num_resources; i++) {
+		struct resource *r = &dev->resource[i];
+
+		if ((r->flags & (IORESOURCE_IO|IORESOURCE_MEM|
+				 IORESOURCE_IRQ|IORESOURCE_DMA))
+		    == type)
+			if (!strcmp(r->name, name))
+				return r;
+	}
+	return NULL;
+}
+
+/**
+ *	platform_get_irq - get an IRQ for a device
+ *	@dev: platform device
+ *	@name: IRQ name
+ */
+int platform_get_irq_byname(struct platform_device *dev, char * name)
+{
+	struct resource *r = platform_get_resource_byname(dev, IORESOURCE_IRQ, name);
+
+	return r ? r->start : 0;
+}
+
+/**
  *	platform_add_devices - add a numbers of platform devices
  *	@devs: array of platform devices to add
  *	@num: number of platform devices in array
@@ -103,7 +139,8 @@
 	for (i = 0; i < pdev->num_resources; i++) {
 		struct resource *p, *r = &pdev->resource[i];
 
-		r->name = pdev->dev.bus_id;
+		if (r->name == NULL)
+			r->name = pdev->dev.bus_id;
 
 		p = NULL;
 		if (r->flags & IORESOURCE_MEM)
@@ -308,3 +345,5 @@
 EXPORT_SYMBOL_GPL(platform_device_unregister);
 EXPORT_SYMBOL_GPL(platform_get_irq);
 EXPORT_SYMBOL_GPL(platform_get_resource);
+EXPORT_SYMBOL_GPL(platform_get_irq_byname);
+EXPORT_SYMBOL_GPL(platform_get_resource_byname);
diff -Nru a/drivers/net/gianfar.c b/drivers/net/gianfar.c
--- a/drivers/net/gianfar.c	2004-12-23 12:39:15 -06:00
+++ b/drivers/net/gianfar.c	2004-12-23 12:39:15 -06:00
@@ -1,4 +1,4 @@
-/* 
+/*
  * drivers/net/gianfar.c
  *
  * Gianfar Ethernet Driver
@@ -24,27 +24,22 @@
  *  Theory of operation
  *  This driver is designed for the Triple-speed Ethernet
  *  controllers on the Freescale 8540/8560 integrated processors,
- *  as well as the Fast Ethernet Controller on the 8540.  
- *  
- *  The driver is initialized through OCP.  Structures which
- *  define the configuration needed by the board are defined in a
- *  board structure in arch/ppc/platforms (though I do not
+ *  as well as the Fast Ethernet Controller on the 8540.
+ *
+ *  The driver is initialized through platform_device.  Structures
+ *  which define the configuration needed by the board are defined
+ *  in a board structure in arch/ppc/platforms (though I do not
  *  discount the possibility that other architectures could one
- *  day be supported.  One assumption the driver currently makes
- *  is that the PHY is configured in such a way to advertise all
- *  capabilities.  This is a sensible default, and on certain
- *  PHYs, changing this default encounters substantial errata
- *  issues.  Future versions may remove this requirement, but for
- *  now, it is best for the firmware to ensure this is the case.
+ *  day be supported.
  *
  *  The Gianfar Ethernet Controller uses a ring of buffer
  *  descriptors.  The beginning is indicated by a register
- *  pointing to the physical address of the start of the ring. 
- *  The end is determined by a "wrap" bit being set in the 
+ *  pointing to the physical address of the start of the ring.
+ *  The end is determined by a "wrap" bit being set in the
  *  last descriptor of the ring.
  *
  *  When a packet is received, the RXF bit in the
- *  IEVENT register is set, triggering an interrupt when the 
+ *  IEVENT register is set, triggering an interrupt when the
  *  corresponding bit in the IMASK register is also set (if
  *  interrupt coalescing is active, then the interrupt may not
  *  happen immediately, but will wait until either a set number
@@ -52,7 +47,7 @@
  *  interrupt handler will signal there is work to be done, and
  *  exit.  Without NAPI, the packet(s) will be handled
  *  immediately.  Both methods will start at the last known empty
- *  descriptor, and process every subsequent descriptor until there 
+ *  descriptor, and process every subsequent descriptor until there
  *  are none left with data (NAPI will stop after a set number of
  *  packets to give time to other tasks, but will eventually
  *  process all the packets).  The data arrives inside a
@@ -76,6 +71,7 @@
 #include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/errno.h>
+#include <linux/unistd.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/init.h>
@@ -85,6 +81,7 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
+#include <linux/device.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -93,9 +90,11 @@
 #include <linux/version.h>
 #include <linux/dma-mapping.h>
 #include <linux/crc32.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
 
 #include "gianfar.h"
-#include "gianfar_phy.h"
+#include "gianfar_mii.h"
 
 #define TX_TIMEOUT      (1*HZ)
 #define SKB_ALLOC_TIMEOUT 1000000
@@ -109,9 +108,8 @@
 #endif
 
 const char gfar_driver_name[] = "Gianfar Ethernet";
-const char gfar_driver_version[] = "1.1";
+const char gfar_driver_version[] = "1.2";
 
-int startup_gfar(struct net_device *dev);
 static int gfar_enet_open(struct net_device *dev);
 static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void gfar_timeout(struct net_device *dev);
@@ -122,17 +120,13 @@
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id, struct pt_regs *regs);
 static irqreturn_t gfar_transmit(int irq, void *dev_id, struct pt_regs *regs);
-irqreturn_t gfar_receive(int irq, void *dev_id, struct pt_regs *regs);
 static irqreturn_t gfar_interrupt(int irq, void *dev_id, struct pt_regs *regs);
-static irqreturn_t phy_interrupt(int irq, void *dev_id, struct pt_regs *regs);
-static void gfar_phy_change(void *data);
-static void gfar_phy_timer(unsigned long data);
-static void adjust_link(struct net_device *dev);
+static void adjust_link(struct device *dev);
 static void init_registers(struct net_device *dev);
 static int init_phy(struct net_device *dev);
-static int gfar_probe(struct ocp_device *ocpdev);
-static void gfar_remove(struct ocp_device *ocpdev);
-void free_skb_resources(struct gfar_private *priv);
+static int gfar_probe(struct device *device);
+static int gfar_remove(struct device *device);
+static void free_skb_resources(struct gfar_private *priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
 #ifdef CONFIG_GFAR_NAPI
@@ -140,57 +134,38 @@
 #endif
 static int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
-static void gfar_phy_startup_timer(unsigned long data);
-
-extern struct ethtool_ops gfar_ethtool_ops;
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
 MODULE_LICENSE("GPL");
 
-/* Called by the ocp code to initialize device data structures
- * required for bringing up the device
- * returns 0 on success */
-static int gfar_probe(struct ocp_device *ocpdev)
+/* Set up the ethernet device structure, private data,
+ * and anything else we need before we start */
+static int gfar_probe(struct device *device)
 {
 	u32 tempval;
-	struct ocp_device *mdiodev;
 	struct net_device *dev = NULL;
 	struct gfar_private *priv = NULL;
-	struct ocp_gfar_data *einfo;
+	struct platform_device *pdev = to_platform_device(device);
+	struct gianfar_platform_data *einfo;
+	struct resource *r;
 	int idx;
 	int err = 0;
 	int dev_ethtool_ops = 0;
 
-	einfo = (struct ocp_gfar_data *) ocpdev->def->additions;
+	einfo = (struct gianfar_platform_data *) pdev->dev.platform_data;
 
 	if (einfo == NULL) {
 		printk(KERN_ERR "gfar %d: Missing additional data!\n",
-		       ocpdev->def->index);
+		       pdev->id);
 
 		return -ENODEV;
 	}
 
-	/* get a pointer to the register memory which can
-	 * configure the PHYs.  If it's different from this set,
-	 * get the device which has those regs */
-	if ((einfo->phyregidx >= 0) && 
-			(einfo->phyregidx != ocpdev->def->index)) {
-		mdiodev = ocp_find_device(OCP_ANY_ID,
-					  OCP_FUNC_GFAR, einfo->phyregidx);
-
-		/* If the device which holds the MDIO regs isn't
-		 * up, wait for it to come up */
-		if (mdiodev == NULL)
-			return -EAGAIN;
-	} else {
-		mdiodev = ocpdev;
-	}
-
 	/* Create an ethernet device instance */
 	dev = alloc_etherdev(sizeof (*priv));
 
-	if (dev == NULL)
+	if (NULL == dev)
 		return -ENOMEM;
 
 	priv = netdev_priv(dev);
@@ -198,27 +173,28 @@
 	/* Set the info in the priv to the current info */
 	priv->einfo = einfo;
 
+	/* fill out IRQ fields */
+	if (einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
+		priv->interruptTransmit = platform_get_irq_byname(pdev, "tx");
+		priv->interruptReceive = platform_get_irq_byname(pdev, "rx");
+		priv->interruptError = platform_get_irq_byname(pdev, "error");
+	} else {
+		priv->interruptTransmit = platform_get_irq(pdev, 0);
+	}
+
 	/* get a pointer to the register memory */
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	priv->regs = (struct gfar *)
-		ioremap(ocpdev->def->paddr, sizeof (struct gfar));
+		ioremap(r->start, sizeof (struct gfar));
 
 	if (priv->regs == NULL) {
 		err = -ENOMEM;
 		goto regs_fail;
 	}
 
-	/* Set the PHY base address */
-	priv->phyregs = (struct gfar *)
-	    ioremap(mdiodev->def->paddr, sizeof (struct gfar));
-
-	if (priv->phyregs == NULL) {
-		err = -ENOMEM;
-		goto phy_regs_fail;
-	}
-
 	spin_lock_init(&priv->lock);
 
-	ocp_set_drvdata(ocpdev, dev);
+	dev_set_drvdata(device, dev);
 
 	/* Stop the DMA engine now, in case it was running before */
 	/* (The firmware could have used it, and left it running). */
@@ -255,7 +231,7 @@
 	dev->base_addr = (unsigned long) (priv->regs);
 
 	SET_MODULE_OWNER(dev);
-	SET_NETDEV_DEV(dev, &ocpdev->dev);
+	SET_NETDEV_DEV(dev, device);
 
 	/* Fill in the dev structure */
 	dev->open = gfar_enet_open;
@@ -274,10 +250,10 @@
 
 	/* Index into the array of possible ethtool
 	 * ops to catch all 4 possibilities */
-	if((priv->einfo->flags & GFAR_HAS_RMON) == 0)
+	if((priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_RMON) == 0)
 		dev_ethtool_ops += 1;
 
-	if((priv->einfo->flags & GFAR_HAS_COALESCE) == 0)
+	if((priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE) == 0)
 		dev_ethtool_ops += 2;
 
 	dev->ethtool_ops = gfar_op_array[dev_ethtool_ops];
@@ -324,119 +300,59 @@
 	return 0;
 
 register_fail:
-	iounmap((void *) priv->phyregs);
-phy_regs_fail:
 	iounmap((void *) priv->regs);
 regs_fail:
 	free_netdev(dev);
-	return -ENOMEM;
+	return err;
 }
 
-static void gfar_remove(struct ocp_device *ocpdev)
+static int gfar_remove(struct device *device)
 {
-	struct net_device *dev = ocp_get_drvdata(ocpdev);
+	struct net_device *dev = dev_get_drvdata(device);
 	struct gfar_private *priv = netdev_priv(dev);
 
-	ocp_set_drvdata(ocpdev, NULL);
+	dev_set_drvdata(device, NULL);
 
 	iounmap((void *) priv->regs);
-	iounmap((void *) priv->phyregs);
 	free_netdev(dev);
+
+	return 0;
 }
 
-/* Configure the PHY for dev.
- * returns 0 if success.  -1 if failure
+
+/* Initializes driver PHY state, and attaches to the PHY.
+ * Returns 0 on success, errno on failure to attach.
  */
 static int init_phy(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct phy_info *curphy;
-	unsigned int timeout = PHY_INIT_TIMEOUT;
-	struct gfar *phyregs = priv->phyregs;
-	struct gfar_mii_info *mii_info;
-	int err;
+	uint gigabit_support =
+		priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
+		SUPPORTED_1000baseT_Full : 0;
+	struct phy_device *phydev;
 
 	priv->oldlink = 0;
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	mii_info = kmalloc(sizeof(struct gfar_mii_info),
-			GFP_KERNEL);
-
-	if(NULL == mii_info) {
-		printk(KERN_ERR "%s: Could not allocate mii_info\n", 
-				dev->name);
-		return -ENOMEM;
-	}
-
-	mii_info->speed = SPEED_1000;
-	mii_info->duplex = DUPLEX_FULL;
-	mii_info->pause = 0;
-	mii_info->link = 1;
-
-	mii_info->advertising = (ADVERTISED_10baseT_Half |
-			ADVERTISED_10baseT_Full |
-			ADVERTISED_100baseT_Half |
-			ADVERTISED_100baseT_Full |
-			ADVERTISED_1000baseT_Full);
-	mii_info->autoneg = 1;
-
-	mii_info->mii_id = priv->einfo->phyid;
-
-	mii_info->dev = dev;
-
-	mii_info->mdio_read = &read_phy_reg;
-	mii_info->mdio_write = &write_phy_reg;
-
-	priv->mii_info = mii_info;
-
-	/* Reset the management interface */
-	gfar_write(&phyregs->miimcfg, MIIMCFG_RESET);
+	phydev = phy_connect(dev->class_dev.dev, priv->einfo->bus_id,
+			&adjust_link);
 
-	/* Setup the MII Mgmt clock speed */
-	gfar_write(&phyregs->miimcfg, MIIMCFG_INIT_VALUE);
-
-	/* Wait until the bus is free */
-	while ((gfar_read(&phyregs->miimind) & MIIMIND_BUSY) &&
-			timeout--)
-		cpu_relax();
-
-	if(timeout <= 0) {
-		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
-				dev->name);
-		err = -1;
-		goto bus_fail;
-	}
-
-	/* get info for this PHY */
-	curphy = get_phy_info(priv->mii_info);
-
-	if (curphy == NULL) {
-		printk(KERN_ERR "%s: No PHY found\n", dev->name);
-		err = -1;
-		goto no_phy;
+	if(NULL == phydev) {
+		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		return errno;
 	}
 
-	mii_info->phyinfo = curphy;
+	/* Remove any features not supported by the controller */
+	phydev->supported &= (GFAR_SUPPORTED | gigabit_support);
+	phydev->advertising = phydev->supported;
 
-	/* Run the commands which initialize the PHY */
-	if(curphy->init) {
-		err = curphy->init(priv->mii_info);
-
-		if (err) 
-			goto phy_init_fail;
-	}
+	priv->phydev = phydev;
 
 	return 0;
-
-phy_init_fail:
-no_phy:
-bus_fail:
-	kfree(mii_info);
-
-	return err;
 }
 
+
 static void init_registers(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -470,7 +386,7 @@
 	gfar_write(&priv->regs->rctrl, 0x00000000);
 
 	/* Zero out the rmon mib registers if it has them */
-	if (priv->einfo->flags & GFAR_HAS_RMON) {
+	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
 		memset((void *) &(priv->regs->rmon), 0,
 		       sizeof (struct rmon_mib));
 
@@ -506,13 +422,11 @@
 	unsigned long flags;
 	u32 tempval;
 
+	phy_stop(priv->phydev);
+
 	/* Lock it down */
 	spin_lock_irqsave(&priv->lock, flags);
 
-	/* Tell the kernel the link is down */
-	priv->mii_info->link = 0;
-	adjust_link(dev);
-
 	/* Mask all interrupts */
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
@@ -536,30 +450,15 @@
 	tempval &= ~(MACCFG1_RX_EN | MACCFG1_TX_EN);
 	gfar_write(&regs->maccfg1, tempval);
 
-	if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
-		/* Clear any pending interrupts */
-		mii_clear_phy_interrupt(priv->mii_info);
-
-		/* Disable PHY Interrupts */
-		mii_configure_phy_interrupt(priv->mii_info, 
-				MII_INTERRUPT_DISABLED);
-	}
-
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	/* Free the IRQs */
-	if (priv->einfo->flags & GFAR_HAS_MULTI_INTR) {
-		free_irq(priv->einfo->interruptError, dev);
-		free_irq(priv->einfo->interruptTransmit, dev);
-		free_irq(priv->einfo->interruptReceive, dev);
+	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
+ 		free_irq(priv->interruptError, dev);
+ 		free_irq(priv->interruptTransmit, dev);
+ 		free_irq(priv->interruptReceive, dev);
 	} else {
-		free_irq(priv->einfo->interruptTransmit, dev);
-	}
-
-	if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
-		free_irq(priv->einfo->interruptPHY, dev);
-	} else {
-		del_timer_sync(&priv->phy_info_timer);
+ 		free_irq(priv->interruptTransmit, dev);
 	}
 
 	free_skb_resources(priv);
@@ -573,7 +472,7 @@
 
 /* If there are any tx skbs or rx skbs still around, free them.
  * Then free tx_skbuff and rx_skbuff */
-void free_skb_resources(struct gfar_private *priv)
+static void free_skb_resources(struct gfar_private *priv)
 {
 	struct rxbd8 *rxbdp;
 	struct txbd8 *txbdp;
@@ -638,7 +537,7 @@
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
 	/* Allocate memory for the buffer descriptors */
-	vaddr = (unsigned long) dma_alloc_coherent(NULL, 
+	vaddr = (unsigned long) dma_alloc_coherent(NULL,
 			sizeof (struct txbd8) * priv->tx_ring_size +
 			sizeof (struct rxbd8) * priv->rx_ring_size,
 			&addr, GFP_KERNEL);
@@ -727,54 +626,48 @@
 
 	/* If the device has multiple interrupts, register for
 	 * them.  Otherwise, only register for the one */
-	if (priv->einfo->flags & GFAR_HAS_MULTI_INTR) {
-		/* Install our interrupt handlers for Error, 
+	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
+		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive */
-		if (request_irq(priv->einfo->interruptError, gfar_error,
+		if (request_irq(priv->interruptError, gfar_error,
 				0, "enet_error", dev) < 0) {
 			printk(KERN_ERR "%s: Can't get IRQ %d\n",
-			       dev->name, priv->einfo->interruptError);
+			       dev->name, priv->interruptError);
 
 			err = -1;
 			goto err_irq_fail;
 		}
 
-		if (request_irq(priv->einfo->interruptTransmit, gfar_transmit,
+		if (request_irq(priv->interruptTransmit, gfar_transmit,
 				0, "enet_tx", dev) < 0) {
 			printk(KERN_ERR "%s: Can't get IRQ %d\n",
-			       dev->name, priv->einfo->interruptTransmit);
+			       dev->name, priv->interruptTransmit);
 
 			err = -1;
 
 			goto tx_irq_fail;
 		}
 
-		if (request_irq(priv->einfo->interruptReceive, gfar_receive,
+		if (request_irq(priv->interruptReceive, gfar_receive,
 				0, "enet_rx", dev) < 0) {
 			printk(KERN_ERR "%s: Can't get IRQ %d (receive0)\n",
-			       dev->name, priv->einfo->interruptReceive);
+			       dev->name, priv->interruptReceive);
 
 			err = -1;
 			goto rx_irq_fail;
 		}
 	} else {
-		if (request_irq(priv->einfo->interruptTransmit, gfar_interrupt,
+		if (request_irq(priv->interruptTransmit, gfar_interrupt,
 				0, "gfar_interrupt", dev) < 0) {
 			printk(KERN_ERR "%s: Can't get IRQ %d\n",
-			       dev->name, priv->einfo->interruptError);
+			       dev->name, priv->interruptError);
 
 			err = -1;
 			goto err_irq_fail;
 		}
 	}
 
-	/* Set up the PHY change work queue */
-	INIT_WORK(&priv->tq, gfar_phy_change, dev);
-
-	init_timer(&priv->phy_info_timer);
-	priv->phy_info_timer.function = &gfar_phy_startup_timer;
-	priv->phy_info_timer.data = (unsigned long) priv->mii_info;
-	mod_timer(&priv->phy_info_timer, jiffies + HZ);
+	phy_start(priv->phydev);
 
 	/* Configure the coalescing support */
 	if (priv->txcoalescing)
@@ -815,9 +708,9 @@
 	return 0;
 
 rx_irq_fail:
-	free_irq(priv->einfo->interruptTransmit, dev);
+	free_irq(priv->interruptTransmit, dev);
 tx_irq_fail:
-	free_irq(priv->einfo->interruptError, dev);
+	free_irq(priv->interruptError, dev);
 err_irq_fail:
 rx_skb_fail:
 	free_skb_resources(priv);
@@ -828,11 +721,6 @@
 			priv->tx_bd_base,
 			gfar_read(&regs->tbase));
 
-	if (priv->mii_info->phyinfo->close)
-		priv->mii_info->phyinfo->close(priv->mii_info);
-
-	kfree(priv->mii_info);
-
 	return err;
 }
 
@@ -880,7 +768,7 @@
 
 	/* Set buffer length and pointer */
 	txbdp->length = skb->len;
-	txbdp->bufPtr = dma_map_single(NULL, skb->data, 
+	txbdp->bufPtr = dma_map_single(NULL, skb->data,
 			skb->len, DMA_TO_DEVICE);
 
 	/* Save the skb pointer so we can free it later */
@@ -932,11 +820,9 @@
 	struct gfar_private *priv = netdev_priv(dev);
 	stop_gfar(dev);
 
-	/* Shutdown the PHY */
-	if (priv->mii_info->phyinfo->close)
-		priv->mii_info->phyinfo->close(priv->mii_info);
-
-	kfree(priv->mii_info);
+	/* Disconnect from the PHY */
+	phy_disconnect(priv->phydev);
+	priv->phydev = NULL;
 
 	netif_stop_queue(dev);
 
@@ -1122,7 +1008,7 @@
 	skb->dev = dev;
 
 	bdp->bufPtr = dma_map_single(NULL, skb->data,
-			priv->rx_buffer_size + RXBUF_ALIGNMENT, 
+			priv->rx_buffer_size + RXBUF_ALIGNMENT,
 			DMA_FROM_DEVICE);
 
 	bdp->length = 0;
@@ -1252,7 +1138,7 @@
 }
 
 /* gfar_clean_rx_ring() -- Processes each frame in the rx ring
- *   until the budget/quota has been reached. Returns the number 
+ *   until the budget/quota has been reached. Returns the number
  *   of frames handled
  */
 static int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
@@ -1452,164 +1338,44 @@
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t phy_interrupt(int irq, void *dev_id, struct pt_regs *regs)
-{
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct gfar_private *priv = netdev_priv(dev);
-
-	/* Clear the interrupt */
-	mii_clear_phy_interrupt(priv->mii_info);
-
-	/* Disable PHY interrupts */
-	mii_configure_phy_interrupt(priv->mii_info,
-			MII_INTERRUPT_DISABLED);
-
-	/* Schedule the phy change */
-	schedule_work(&priv->tq);
-
-	return IRQ_HANDLED;
-}
-
-/* Scheduled by the phy_interrupt/timer to handle PHY changes */
-static void gfar_phy_change(void *data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	struct gfar_private *priv = netdev_priv(dev);
-	int result = 0;
-
-	/* Delay to give the PHY a chance to change the
-	 * register state */
-	msleep(1);
-
-	/* Update the link, speed, duplex */
-	result = priv->mii_info->phyinfo->read_status(priv->mii_info);
-
-	/* Adjust the known status as long as the link
-	 * isn't still coming up */
-	if((0 == result) || (priv->mii_info->link == 0))
-		adjust_link(dev);
-
-	/* Reenable interrupts, if needed */
-	if (priv->einfo->flags & GFAR_HAS_PHY_INTR)
-		mii_configure_phy_interrupt(priv->mii_info,
-				MII_INTERRUPT_ENABLED);
-}
-
-/* Called every so often on systems that don't interrupt
- * the core for PHY changes */
-static void gfar_phy_timer(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	struct gfar_private *priv = netdev_priv(dev);
-
-	schedule_work(&priv->tq);
-
-	mod_timer(&priv->phy_info_timer, jiffies +
-			GFAR_PHY_CHANGE_TIME * HZ);
-}
-
-/* Keep trying aneg for some time
- * If, after GFAR_AN_TIMEOUT seconds, it has not
- * finished, we switch to forced.
- * Either way, once the process has completed, we either
- * request the interrupt, or switch the timer over to 
- * using gfar_phy_timer to check status */
-static void gfar_phy_startup_timer(unsigned long data)
-{
-	int result;
-	static int secondary = GFAR_AN_TIMEOUT;
-	struct gfar_mii_info *mii_info = (struct gfar_mii_info *)data;
-	struct gfar_private *priv = netdev_priv(mii_info->dev);
-
-	/* Configure the Auto-negotiation */
-	result = mii_info->phyinfo->config_aneg(mii_info);
-
-	/* If autonegotiation failed to start, and
-	 * we haven't timed out, reset the timer, and return */
-	if (result && secondary--) {
-		mod_timer(&priv->phy_info_timer, jiffies + HZ);
-		return;
-	} else if (result) {
-		/* Couldn't start autonegotiation.
-		 * Try switching to forced */
-		mii_info->autoneg = 0;
-		result = mii_info->phyinfo->config_aneg(mii_info);
-
-		/* Forcing failed!  Give up */
-		if(result) {
-			printk(KERN_ERR "%s: Forcing failed!\n",
-					mii_info->dev->name);
-			return;
-		}
-	}
-
-	/* Kill the timer so it can be restarted */
-	del_timer_sync(&priv->phy_info_timer);
-
-	/* Grab the PHY interrupt, if necessary/possible */
-	if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
-		if (request_irq(priv->einfo->interruptPHY, 
-					phy_interrupt,
-					SA_SHIRQ, 
-					"phy_interrupt", 
-					mii_info->dev) < 0) {
-			printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
-					mii_info->dev->name,
-					priv->einfo->interruptPHY);
-		} else {
-			mii_configure_phy_interrupt(priv->mii_info, 
-					MII_INTERRUPT_ENABLED);
-			return;
-		}
-	}
-
-	/* Start the timer again, this time in order to
-	 * handle a change in status */
-	init_timer(&priv->phy_info_timer);
-	priv->phy_info_timer.function = &gfar_phy_timer;
-	priv->phy_info_timer.data = (unsigned long) mii_info->dev;
-	mod_timer(&priv->phy_info_timer, jiffies +
-			GFAR_PHY_CHANGE_TIME * HZ);
-}
-
 /* Called every time the controller might need to be made
  * aware of new link state.  The PHY code conveys this
- * information through variables in the priv structure, and this
+ * information through variables in the phydev structure, and this
  * function converts those variables into the appropriate
  * register values, and can bring down the device if needed.
  */
-static void adjust_link(struct net_device *dev)
+static void adjust_link(struct device *d)
 {
+	struct net_device *dev = dev_get_drvdata(d);
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar *regs = priv->regs;
 	u32 tempval;
-	struct gfar_mii_info *mii_info = priv->mii_info;
+	unsigned long flags;
+	struct phy_device *phydev = priv->phydev;
+	int new_state = 0;
 
-	if (mii_info->link) {
+	spin_lock_irqsave(&priv->lock, flags);
+	if (phydev->link) {
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
-		if (mii_info->duplex != priv->oldduplex) {
-			if (!(mii_info->duplex)) {
+		if (phydev->duplex != priv->oldduplex) {
+			new_state = 1;
+			if (!(phydev->duplex)) {
 				tempval = gfar_read(&regs->maccfg2);
 				tempval &= ~(MACCFG2_FULL_DUPLEX);
 				gfar_write(&regs->maccfg2, tempval);
-
-				printk(KERN_INFO "%s: Half Duplex\n",
-				       dev->name);
 			} else {
 				tempval = gfar_read(&regs->maccfg2);
 				tempval |= MACCFG2_FULL_DUPLEX;
 				gfar_write(&regs->maccfg2, tempval);
-
-				printk(KERN_INFO "%s: Full Duplex\n",
-				       dev->name);
 			}
 
-			priv->oldduplex = mii_info->duplex;
+			priv->oldduplex = phydev->duplex;
 		}
 
-		if (mii_info->speed != priv->oldspeed) {
-			switch (mii_info->speed) {
+		if (phydev->speed != priv->oldspeed) {
+			new_state = 1;
+			switch (phydev->speed) {
 			case 1000:
 				tempval = gfar_read(&regs->maccfg2);
 				tempval =
@@ -1626,31 +1392,41 @@
 			default:
 				printk(KERN_WARNING
 				       "%s: Ack!  Speed (%d) is not 10/100/1000!\n",
-				       dev->name, mii_info->speed);
+				       dev->name, phydev->speed);
 				break;
 			}
 
-			printk(KERN_INFO "%s: Speed %dBT\n", dev->name,
-			       mii_info->speed);
-
-			priv->oldspeed = mii_info->speed;
+			priv->oldspeed = phydev->speed;
 		}
 
 		if (!priv->oldlink) {
-			printk(KERN_INFO "%s: Link is up\n", dev->name);
+			new_state = 1;
 			priv->oldlink = 1;
 			netif_carrier_on(dev);
 			netif_schedule(dev);
 		}
 	} else {
 		if (priv->oldlink) {
-			printk(KERN_INFO "%s: Link is down\n", dev->name);
+			new_state = 1;
 			priv->oldlink = 0;
 			priv->oldspeed = 0;
 			priv->oldduplex = -1;
 			netif_carrier_off(dev);
 		}
 	}
+
+	if (new_state) {
+		pr_info("%s: Link is %s", dev->name,
+				phydev->link ? "Up" : "Down");
+		if (phydev->link)
+			printk(" - %d/%s", phydev->speed,
+				DUPLEX_FULL == phydev->duplex ?
+				"Full" : "Half");
+
+		printk("\n");
+	}
+
+	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 
@@ -1829,35 +1605,32 @@
 }
 
 /* Structure for a device driver */
-static struct ocp_device_id gfar_ids[] = {
-	{.vendor = OCP_ANY_ID,.function = OCP_FUNC_GFAR},
-	{.vendor = OCP_VENDOR_INVALID}
-};
-
-static struct ocp_driver gfar_driver = {
-	.name = "gianfar",
-	.id_table = gfar_ids,
-
+static struct device_driver gfar_driver = {
+	.name = "fsl-gianfar",
+	.bus = &platform_bus_type,
 	.probe = gfar_probe,
 	.remove = gfar_remove,
 };
 
 static int __init gfar_init(void)
 {
-	int rc;
+	int err = gfar_mdio_init();
 
-	rc = ocp_register_driver(&gfar_driver);
-	if (rc != 0) {
-		ocp_unregister_driver(&gfar_driver);
-		return -ENODEV;
-	}
+	if (err)
+		return err;
 
-	return 0;
+	err = driver_register(&gfar_driver);
+
+	if (err)
+		gfar_mdio_exit();
+	
+	return err;
 }
 
 static void __exit gfar_exit(void)
 {
-	ocp_unregister_driver(&gfar_driver);
+	driver_unregister(&gfar_driver);
+	gfar_mdio_exit();
 }
 
 module_init(gfar_init);
diff -Nru a/drivers/net/gianfar.h b/drivers/net/gianfar.h
--- a/drivers/net/gianfar.h	2004-12-23 12:39:16 -06:00
+++ b/drivers/net/gianfar.h	2004-12-23 12:39:16 -06:00
@@ -17,7 +17,6 @@
  *
  *  Still left to do:
  *      -Add support for module parameters
- *	-Add support for ethtool -s
  *	-Add patch for ethtool phys id
  */
 #ifndef __GIANFAR_H
@@ -37,6 +36,8 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -47,8 +48,8 @@
 #include <linux/workqueue.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
-#include <asm/ocp.h>
-#include "gianfar_phy.h"
+#include <linux/fsl_devices.h>
+#include "gianfar_mii.h"
 
 /* The maximum number of packets to be handled in one call of gfar_poll */
 #define GFAR_DEV_WEIGHT 64
@@ -67,7 +68,7 @@
 #define PHY_INIT_TIMEOUT 100000
 #define GFAR_PHY_CHANGE_TIME 2
 
-#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.1, "
+#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.2, "
 #define DRV_NAME "gfar-enet"
 extern const char gfar_driver_name[];
 extern const char gfar_driver_version[];
@@ -422,12 +423,7 @@
 	u32	hafdup;			/* 0x.50c - Half Duplex Register */
 	u32	maxfrm;			/* 0x.510 - Maximum Frame Length Register */
 	u8	res18[12];
-	u32	miimcfg;		/* 0x.520 - MII Management Configuration Register */
-	u32	miimcom;		/* 0x.524 - MII Management Command Register */
-	u32	miimadd;		/* 0x.528 - MII Management Address Register */
-	u32	miimcon;		/* 0x.52c - MII Management Control Register */
-	u32	miimstat;		/* 0x.530 - MII Management Status Register */
-	u32	miimind;		/* 0x.534 - MII Management Indicator Register */
+	u8	gfar_mii_regs[24];	/* See gianfar_phy.h */
 	u8	res19[4];
 	u32	ifstat;			/* 0x.53c - Interface Status Register */
 	u32	macstnaddr1;		/* 0x.540 - Station Address Part 1 Register */
@@ -496,9 +492,6 @@
 	struct txbd8 *cur_tx;	        /* Next free ring entry */
 	struct txbd8 *dirty_tx;		/* The Ring entry to be freed. */
 	struct gfar *regs;	/* Pointer to the GFAR memory mapped Registers */
-	struct gfar *phyregs;
-	struct work_struct tq;
-	struct timer_list phy_info_timer;
 	struct net_device_stats stats; /* linux network statistics */
 	struct gfar_extra_stats extra_stats;
 	spinlock_t lock;
@@ -510,9 +503,13 @@
 	unsigned int rxclean;
 
 	/* Info structure initialized by board setup code */
-	struct ocp_gfar_data *einfo;
+	unsigned int interruptTransmit;
+	unsigned int interruptReceive;
+	unsigned int interruptError;
+	struct gianfar_platform_data *einfo;
 
-	struct gfar_mii_info *mii_info;
+	struct phy_device *phydev;
+	struct mii_bus *mii_bus;
 	int oldspeed;
 	int oldduplex;
 	int oldlink;
@@ -531,5 +528,9 @@
 }
 
 extern struct ethtool_ops *gfar_op_array[];
+
+extern irqreturn_t gfar_receive(int irq, void *dev_id, struct pt_regs *regs);
+extern int startup_gfar(struct net_device *dev);
+extern void stop_gfar(struct net_device *dev);
 
 #endif /* __GIANFAR_H */
diff -Nru a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
--- a/drivers/net/gianfar_ethtool.c	2004-12-23 12:39:16 -06:00
+++ b/drivers/net/gianfar_ethtool.c	2004-12-23 12:39:16 -06:00
@@ -39,15 +39,13 @@
 #include <asm/types.h>
 #include <asm/uaccess.h>
 #include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
 
 #include "gianfar.h"
 
 #define is_power_of_2(x)        ((x) != 0 && (((x) & ((x) - 1)) == 0))
 
-extern int startup_gfar(struct net_device *dev);
-extern void stop_gfar(struct net_device *dev);
-extern void gfar_receive(int irq, void *dev_id, struct pt_regs *regs);
-
 void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
 		     u64 * buf);
 void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf);
@@ -181,32 +179,72 @@
 	drvinfo->eedump_len = 0;
 }
 
+
+static int gfar_ssettings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+
+	if (NULL == phydev)
+		return -ENODEV;
+
+	/* We make sure that we don't pass unsupported
+	 * values in to the PHY */
+	cmd->advertising &= phydev->supported;
+
+	/* Verify the settings we care about. */
+	if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
+		return -EINVAL;
+
+	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
+		return -EINVAL;
+
+	if (cmd->autoneg == AUTONEG_DISABLE
+			&& ((cmd->speed != SPEED_1000
+					&& cmd->speed != SPEED_100
+					&& cmd->speed != SPEED_10)
+				|| (cmd->duplex != DUPLEX_HALF 
+					&& cmd->duplex != DUPLEX_FULL)))
+		return -EINVAL;
+
+	phydev->autoneg = cmd->autoneg;
+
+	phydev->speed = cmd->speed;
+
+	phydev->advertising = cmd->advertising;
+
+	if (AUTONEG_ENABLE == cmd->autoneg)
+		phydev->advertising |= ADVERTISED_Autoneg;
+	else
+		phydev->advertising &= ~ADVERTISED_Autoneg;
+
+	phydev->duplex = cmd->duplex;
+
+	/* Restart the PHY */
+	phy_start_aneg(phydev);
+
+	return 0;
+}
+
 /* Return the current settings in the ethtool_cmd structure */
 int gfar_gsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	uint gigabit_support = 
-		priv->einfo->flags & GFAR_HAS_GIGABIT ? SUPPORTED_1000baseT_Full : 0;
-	uint gigabit_advert = 
-		priv->einfo->flags & GFAR_HAS_GIGABIT ? ADVERTISED_1000baseT_Full: 0;
-
-	cmd->supported = (SUPPORTED_10baseT_Half
-			  | SUPPORTED_100baseT_Half
-			  | SUPPORTED_100baseT_Full
-			  | gigabit_support | SUPPORTED_Autoneg);
-
-	/* For now, we always advertise everything */
-	cmd->advertising = (ADVERTISED_10baseT_Half
-			    | ADVERTISED_100baseT_Half
-			    | ADVERTISED_100baseT_Full
-			    | gigabit_advert | ADVERTISED_Autoneg);
+	struct phy_device *phydev = priv->phydev;
+
+	if (NULL == phydev)
+		return -ENODEV;
+	
+	cmd->supported = phydev->supported;
 
-	cmd->speed = priv->mii_info->speed;
-	cmd->duplex = priv->mii_info->duplex;
+	cmd->advertising = phydev->advertising;
+
+	cmd->speed = phydev->speed;
+	cmd->duplex = phydev->duplex;
 	cmd->port = PORT_MII;
-	cmd->phy_address = priv->mii_info->mii_id;
+	cmd->phy_address = phydev->addr;
 	cmd->transceiver = XCVR_EXTERNAL;
-	cmd->autoneg = AUTONEG_ENABLE;
+	cmd->autoneg = phydev->autoneg;
 	cmd->maxtxpkt = priv->txcount;
 	cmd->maxrxpkt = priv->rxcount;
 
@@ -245,14 +283,14 @@
 	unsigned int count;
 
 	/* The timer is different, depending on the interface speed */
-	switch (priv->mii_info->speed) {
-	case 1000:
+	switch (priv->phydev->speed) {
+	case SPEED_1000:
 		count = GFAR_GBIT_TIME;
 		break;
-	case 100:
+	case SPEED_100:
 		count = GFAR_100_TIME;
 		break;
-	case 10:
+	case SPEED_10:
 	default:
 		count = GFAR_10_TIME;
 		break;
@@ -269,14 +307,14 @@
 	unsigned int count;
 
 	/* The timer is different, depending on the interface speed */
-	switch (priv->mii_info->speed) {
-	case 1000:
+	switch (priv->phydev->speed) {
+	case SPEED_1000:
 		count = GFAR_GBIT_TIME;
 		break;
-	case 100:
+	case SPEED_100:
 		count = GFAR_100_TIME;
 		break;
-	case 10:
+	case SPEED_10:
 	default:
 		count = GFAR_10_TIME;
 		break;
@@ -293,6 +331,9 @@
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
+	if (NULL == priv->phydev)
+		return -ENODEV;
+
 	cvals->rx_coalesce_usecs = gfar_ticks2usecs(priv, priv->rxtime);
 	cvals->rx_max_coalesced_frames = priv->rxcount;
 
@@ -346,6 +387,9 @@
 	else
 		priv->rxcoalescing = 1;
 
+	if (NULL == priv->phydev)
+		return -ENODEV;
+
 	priv->rxtime = gfar_usecs2ticks(priv, cvals->rx_coalesce_usecs);
 	priv->rxcount = cvals->rx_max_coalesced_frames;
 
@@ -462,6 +506,7 @@
 }
 
 struct ethtool_ops gfar_ethtool_ops = {
+	.set_settings = gfar_ssettings,
 	.get_settings = gfar_gsettings,
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
@@ -477,6 +522,7 @@
 };
 
 struct ethtool_ops gfar_normon_nocoalesce_ethtool_ops = {
+	.set_settings = gfar_ssettings,
 	.get_settings = gfar_gsettings,
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
@@ -490,6 +536,7 @@
 };
 
 struct ethtool_ops gfar_nocoalesce_ethtool_ops = {
+	.set_settings = gfar_ssettings,
 	.get_settings = gfar_gsettings,
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
@@ -503,6 +550,7 @@
 };
 
 struct ethtool_ops gfar_normon_ethtool_ops = {
+	.set_settings = gfar_ssettings,
 	.get_settings = gfar_gsettings,
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
diff -Nru a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/gianfar_mii.c	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,212 @@
+/* 
+ * drivers/net/gianfar_mii.c
+ *
+ * Gianfar Ethernet Driver -- MIIM bus implementation
+ * Provides Bus interface for MIIM regs
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <asm/ocp.h>
+#include <linux/crc32.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+#include "gianfar.h"
+#include "gianfar_mii.h"
+
+extern void * get_platform_data(enum fsl_devices dev);
+
+/* Write value to the PHY at mii_id at register regnum,
+ * on the bus, waiting until the write is done before returning.
+ * All PHY configuration is done through the TSEC1 MIIM regs */
+void gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+{
+	struct gfar_mii *regs = bus->priv;
+
+	/* Set the PHY address and the register address we want to write */
+	gfar_write(&regs->miimadd, (mii_id << 8) | regnum);
+
+	/* Write out the value we want */
+	gfar_write(&regs->miimcon, value);
+
+	/* Wait for the transaction to finish */
+	while (gfar_read(&regs->miimind) & MIIMIND_BUSY)
+		cpu_relax();
+}
+
+/* Read the bus for PHY at addr mii_id, register regnum, and
+ * return the value.  Clears miimcom first.  All PHY
+ * configuration has to be done through the TSEC1 MIIM regs */
+u16 gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct gfar_mii *regs = bus->priv;
+	u16 value;
+
+	/* Set the PHY address and the register address we want to read */
+	gfar_write(&regs->miimadd, (mii_id << 8) | regnum);
+
+	/* Clear miimcom, and then initiate a read */
+	gfar_write(&regs->miimcom, 0);
+	gfar_write(&regs->miimcom, MII_READ_COMMAND);
+
+	/* Wait for the transaction to finish */
+	while (gfar_read(&regs->miimind) & (MIIMIND_NOTVALID | MIIMIND_BUSY))
+		cpu_relax();
+
+	/* Grab the value of the register from miimstat */
+	value = gfar_read(&regs->miimstat);
+
+	return value;
+}
+
+
+/* Reset the MIIM registers, and wait for the bus to free */
+int gfar_mdio_reset(struct mii_bus *bus)
+{
+	struct gfar_mii *regs = bus->priv;
+	unsigned int timeout = PHY_INIT_TIMEOUT;
+
+	spin_lock_bh(&bus->mdio_lock);
+
+	/* Reset the management interface */
+	gfar_write(&regs->miimcfg, MIIMCFG_RESET);
+
+	/* Setup the MII Mgmt clock speed */
+	gfar_write(&regs->miimcfg, MIIMCFG_INIT_VALUE);
+
+	/* Wait until the bus is free */
+	while ((gfar_read(&regs->miimind) & MIIMIND_BUSY) &&
+			timeout--)
+		cpu_relax();
+
+	spin_unlock_bh(&bus->mdio_lock);
+
+	if(timeout <= 0) {
+		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
+				bus->name);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+
+int gfar_mdio_probe(struct device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+	struct gianfar_mdio_data *pdata;
+	struct gfar_mii *regs;
+	struct mii_bus *new_bus;
+	int err = 0;
+
+	if (NULL == dev)
+		return -EINVAL;
+
+	new_bus = kmalloc(sizeof(struct mii_bus), GFP_KERNEL);
+
+	if (NULL == new_bus)
+		return -ENOMEM;
+
+	new_bus->name = "Gianfar MII Bus",
+	new_bus->read = &gfar_mdio_read,
+	new_bus->write = &gfar_mdio_write,
+	new_bus->reset = &gfar_mdio_reset,
+	new_bus->id = pdev->id;
+
+	pdata = get_platform_data(MPC85xx_MDIO);
+
+	/* Set the PHY base address */
+	regs = (struct gfar_mii *) ioremap(pdata->paddr, 
+			sizeof (struct gfar_mii));
+
+	if (NULL == regs) {
+		err = -ENOMEM;
+		goto reg_map_fail;
+	}
+
+	new_bus->priv = regs;
+
+	new_bus->irq = pdata->irq;
+
+	new_bus->dev = dev;
+	dev_set_drvdata(dev, new_bus);
+
+	err = register_mdiobus(new_bus);
+
+	if (0 != err) {
+		printk (KERN_ERR "%s: Cannot register as MDIO bus\n", 
+				new_bus->name);
+		goto bus_register_fail;
+	}
+
+	return 0;
+
+bus_register_fail:
+	iounmap((void *) regs);
+reg_map_fail:
+	kfree(new_bus);
+
+	return err;
+}
+
+
+int gfar_mdio_remove(struct device *dev)
+{
+	struct mii_bus *bus = dev_get_drvdata(dev);
+
+	dev_set_drvdata(dev, NULL);
+
+	iounmap((void *) (&bus->priv));
+	bus->priv = NULL;
+	kfree(bus);
+
+	return 0;
+}
+
+static struct device_driver gianfar_mdio_driver = {
+	.name = "fsl-gianfar_mdio",
+	.bus = &platform_bus_type,
+	.probe = gfar_mdio_probe,
+	.remove = gfar_mdio_remove,
+};
+
+int __init gfar_mdio_init(void)
+{
+	return driver_register(&gianfar_mdio_driver);
+}
+
+void __exit gfar_mdio_exit(void)
+{
+	driver_unregister(&gianfar_mdio_driver);
+}
diff -Nru a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/gianfar_mii.h	2004-12-23 12:39:15 -06:00
@@ -0,0 +1,45 @@
+/* 
+ * drivers/net/gianfar_mii.h
+ *
+ * Gianfar Ethernet Driver -- MII Management Bus Implementation
+ * Driver for the MDIO bus controller in the Gianfar register space
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala (kumar.gala@freescale.com)
+ *
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#ifndef __GIANFAR_MII_H
+#define __GIANFAR_MII_H
+
+#define MIIMIND_BUSY            0x00000001
+#define MIIMIND_NOTVALID        0x00000004
+
+#define MII_READ_COMMAND       0x00000001
+
+#define GFAR_SUPPORTED (SUPPORTED_10baseT_Half \
+		| SUPPORTED_100baseT_Half \
+		| SUPPORTED_100baseT_Full \
+		| SUPPORTED_Autoneg \
+		| SUPPORTED_MII)
+
+struct gfar_mii {
+	u32	miimcfg;	/* 0x.520 - MII Management Config Register */
+	u32	miimcom;	/* 0x.524 - MII Management Command Register */
+	u32	miimadd;	/* 0x.528 - MII Management Address Register */
+	u32	miimcon;	/* 0x.52c - MII Management Control Register */
+	u32	miimstat;	/* 0x.530 - MII Management Status Register */
+	u32	miimind;	/* 0x.534 - MII Management Indicator Register */
+};
+
+u16 gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
+void gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
+int __init gfar_mdio_init(void);
+void __exit gfar_mdio_exit(void);
+#endif /* GIANFAR_PHY_H */
diff -Nru a/drivers/net/gianfar_phy.c b/drivers/net/gianfar_phy.c
--- a/drivers/net/gianfar_phy.c	2004-12-23 12:39:16 -06:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,661 +0,0 @@
-/* 
- * drivers/net/gianfar_phy.c
- *
- * Gianfar Ethernet Driver -- PHY handling
- * Driver for FEC on MPC8540 and TSEC on MPC8540/MPC8560
- * Based on 8260_io/fcc_enet.c
- *
- * Author: Andy Fleming
- * Maintainer: Kumar Gala (kumar.gala@freescale.com)
- *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-
-#include <linux/config.h>
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/slab.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/delay.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-#include <linux/mm.h>
-
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/uaccess.h>
-#include <linux/module.h>
-#include <linux/version.h>
-#include <linux/crc32.h>
-#include <linux/mii.h>
-
-#include "gianfar.h"
-#include "gianfar_phy.h"
-
-static void config_genmii_advert(struct gfar_mii_info *mii_info);
-static void genmii_setup_forced(struct gfar_mii_info *mii_info);
-static void genmii_restart_aneg(struct gfar_mii_info *mii_info);
-static int gbit_config_aneg(struct gfar_mii_info *mii_info);
-static int genmii_config_aneg(struct gfar_mii_info *mii_info);
-static int genmii_update_link(struct gfar_mii_info *mii_info);
-static int genmii_read_status(struct gfar_mii_info *mii_info);
-u16 phy_read(struct gfar_mii_info *mii_info, u16 regnum);
-void phy_write(struct gfar_mii_info *mii_info, u16 regnum, u16 val);
-
-/* Write value to the PHY for this device to the register at regnum, */
-/* waiting until the write is done before it returns.  All PHY */
-/* configuration has to be done through the TSEC1 MIIM regs */
-void write_phy_reg(struct net_device *dev, int mii_id, int regnum, int value)
-{
-	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar *regbase = priv->phyregs;
-
-	/* Set the PHY address and the register address we want to write */
-	gfar_write(&regbase->miimadd, (mii_id << 8) | regnum);
-
-	/* Write out the value we want */
-	gfar_write(&regbase->miimcon, value);
-
-	/* Wait for the transaction to finish */
-	while (gfar_read(&regbase->miimind) & MIIMIND_BUSY)
-		cpu_relax();
-}
-
-/* Reads from register regnum in the PHY for device dev, */
-/* returning the value.  Clears miimcom first.  All PHY */
-/* configuration has to be done through the TSEC1 MIIM regs */
-int read_phy_reg(struct net_device *dev, int mii_id, int regnum)
-{
-	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar *regbase = priv->phyregs;
-	u16 value;
-
-	/* Set the PHY address and the register address we want to read */
-	gfar_write(&regbase->miimadd, (mii_id << 8) | regnum);
-
-	/* Clear miimcom, and then initiate a read */
-	gfar_write(&regbase->miimcom, 0);
-	gfar_write(&regbase->miimcom, MII_READ_COMMAND);
-
-	/* Wait for the transaction to finish */
-	while (gfar_read(&regbase->miimind) & (MIIMIND_NOTVALID | MIIMIND_BUSY))
-		cpu_relax();
-
-	/* Grab the value of the register from miimstat */
-	value = gfar_read(&regbase->miimstat);
-
-	return value;
-}
-
-void mii_clear_phy_interrupt(struct gfar_mii_info *mii_info)
-{
-	if(mii_info->phyinfo->ack_interrupt)
-		mii_info->phyinfo->ack_interrupt(mii_info);
-}
-
-
-void mii_configure_phy_interrupt(struct gfar_mii_info *mii_info, u32 interrupts)
-{
-	mii_info->interrupts = interrupts;
-	if(mii_info->phyinfo->config_intr)
-		mii_info->phyinfo->config_intr(mii_info);
-}
-
-
-/* Writes MII_ADVERTISE with the appropriate values, after
- * sanitizing advertise to make sure only supported features
- * are advertised 
- */
-static void config_genmii_advert(struct gfar_mii_info *mii_info)
-{
-	u32 advertise;
-	u16 adv;
-
-	/* Only allow advertising what this PHY supports */
-	mii_info->advertising &= mii_info->phyinfo->features;
-	advertise = mii_info->advertising;
-
-	/* Setup standard advertisement */
-	adv = phy_read(mii_info, MII_ADVERTISE);
-	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
-	if (advertise & ADVERTISED_10baseT_Half)
-		adv |= ADVERTISE_10HALF;
-	if (advertise & ADVERTISED_10baseT_Full)
-		adv |= ADVERTISE_10FULL;
-	if (advertise & ADVERTISED_100baseT_Half)
-		adv |= ADVERTISE_100HALF;
-	if (advertise & ADVERTISED_100baseT_Full)
-		adv |= ADVERTISE_100FULL;
-	phy_write(mii_info, MII_ADVERTISE, adv);
-}
-
-static void genmii_setup_forced(struct gfar_mii_info *mii_info)
-{
-	u16 ctrl;
-	u32 features = mii_info->phyinfo->features;
-	
-	ctrl = phy_read(mii_info, MII_BMCR);
-
-	ctrl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_SPEED1000|BMCR_ANENABLE);
-	ctrl |= BMCR_RESET;
-
-	switch(mii_info->speed) {
-		case SPEED_1000:
-			if(features & (SUPPORTED_1000baseT_Half
-						| SUPPORTED_1000baseT_Full)) {
-				ctrl |= BMCR_SPEED1000;
-				break;
-			}
-			mii_info->speed = SPEED_100;
-		case SPEED_100:
-			if (features & (SUPPORTED_100baseT_Half
-						| SUPPORTED_100baseT_Full)) {
-				ctrl |= BMCR_SPEED100;
-				break;
-			}
-			mii_info->speed = SPEED_10;
-		case SPEED_10:
-			if (features & (SUPPORTED_10baseT_Half
-						| SUPPORTED_10baseT_Full))
-				break;
-		default: /* Unsupported speed! */
-			printk(KERN_ERR "%s: Bad speed!\n", 
-					mii_info->dev->name);
-			break;
-	}
-
-	phy_write(mii_info, MII_BMCR, ctrl);
-}
-
-
-/* Enable and Restart Autonegotiation */
-static void genmii_restart_aneg(struct gfar_mii_info *mii_info)
-{
-	u16 ctl;
-
-	ctl = phy_read(mii_info, MII_BMCR);
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
-	phy_write(mii_info, MII_BMCR, ctl);
-}
-
-
-static int gbit_config_aneg(struct gfar_mii_info *mii_info)
-{
-	u16 adv;
-	u32 advertise;
-
-	if(mii_info->autoneg) {
-		/* Configure the ADVERTISE register */
-		config_genmii_advert(mii_info);
-		advertise = mii_info->advertising;
-
-		adv = phy_read(mii_info, MII_1000BASETCONTROL);
-		adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
-				MII_1000BASETCONTROL_HALFDUPLEXCAP);
-		if (advertise & SUPPORTED_1000baseT_Half)
-			adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
-		if (advertise & SUPPORTED_1000baseT_Full)
-			adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
-		phy_write(mii_info, MII_1000BASETCONTROL, adv);
-
-		/* Start/Restart aneg */
-		genmii_restart_aneg(mii_info);
-	} else
-		genmii_setup_forced(mii_info);
-
-	return 0;
-}
-
-static int marvell_config_aneg(struct gfar_mii_info *mii_info)
-{
-	/* The Marvell PHY has an errata which requires
-	 * that certain registers get written in order
-	 * to restart autonegotiation */
-	phy_write(mii_info, MII_BMCR, BMCR_RESET);
-
-	phy_write(mii_info, 0x1d, 0x1f);
-	phy_write(mii_info, 0x1e, 0x200c);
-	phy_write(mii_info, 0x1d, 0x5);
-	phy_write(mii_info, 0x1e, 0);
-	phy_write(mii_info, 0x1e, 0x100);
-
-	gbit_config_aneg(mii_info);
-
-	return 0;
-}
-static int genmii_config_aneg(struct gfar_mii_info *mii_info)
-{
-	if (mii_info->autoneg) {
-		config_genmii_advert(mii_info);
-		genmii_restart_aneg(mii_info);
-	} else
-		genmii_setup_forced(mii_info);
-
-	return 0;
-}
-
-
-static int genmii_update_link(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-
-	/* Do a fake read */
-	phy_read(mii_info, MII_BMSR);
-
-	/* Read link and autonegotiation status */
-	status = phy_read(mii_info, MII_BMSR);
-	if ((status & BMSR_LSTATUS) == 0)
-		mii_info->link = 0;
-	else
-		mii_info->link = 1;
-
-	/* If we are autonegotiating, and not done, 
-	 * return an error */
-	if (mii_info->autoneg && !(status & BMSR_ANEGCOMPLETE))
-		return -EAGAIN;
-
-	return 0;
-}
-
-static int genmii_read_status(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	if (mii_info->autoneg) {
-		status = phy_read(mii_info, MII_LPA);
-
-		if (status & (LPA_10FULL | LPA_100FULL))
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-		if (status & (LPA_100FULL | LPA_100HALF))
-			mii_info->speed = SPEED_100;
-		else
-			mii_info->speed = SPEED_10;
-		mii_info->pause = 0;
-	}
-	/* On non-aneg, we assume what we put in BMCR is the speed,
-	 * though magic-aneg shouldn't prevent this case from occurring
-	 */
-
-	return 0;
-}
-static int marvell_read_status(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	/* If the link is up, read the speed and duplex */
-	/* If we aren't autonegotiating, assume speeds 
-	 * are as set */
-	if (mii_info->autoneg && mii_info->link) {
-		int speed;
-		status = phy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);
-
-#if 0
-		/* If speed and duplex aren't resolved,
-		 * return an error.  Isn't this handled
-		 * by checking aneg?
-		 */
-		if ((status & MII_M1011_PHY_SPEC_STATUS_RESOLVED) == 0)
-			return -EAGAIN;
-#endif
-
-		/* Get the duplexity */
-		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-
-		/* Get the speed */
-		speed = status & MII_M1011_PHY_SPEC_STATUS_SPD_MASK;
-		switch(speed) {
-			case MII_M1011_PHY_SPEC_STATUS_1000:
-				mii_info->speed = SPEED_1000;
-				break;
-			case MII_M1011_PHY_SPEC_STATUS_100:
-				mii_info->speed = SPEED_100;
-				break;
-			default:
-				mii_info->speed = SPEED_10;
-				break;
-		}
-		mii_info->pause = 0;
-	}
-
-	return 0;
-}
-
-
-static int cis820x_read_status(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	/* If the link is up, read the speed and duplex */
-	/* If we aren't autonegotiating, assume speeds 
-	 * are as set */
-	if (mii_info->autoneg && mii_info->link) {
-		int speed;
-
-		status = phy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
-		if (status & MII_CIS8201_AUXCONSTAT_DUPLEX)
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-
-		speed = status & MII_CIS8201_AUXCONSTAT_SPEED;
-
-		switch (speed) {
-		case MII_CIS8201_AUXCONSTAT_GBIT:
-			mii_info->speed = SPEED_1000;
-			break;
-		case MII_CIS8201_AUXCONSTAT_100:
-			mii_info->speed = SPEED_100;
-			break;
-		default:
-			mii_info->speed = SPEED_10;
-			break;
-		}
-	}
-
-	return 0;
-}
-
-static int marvell_ack_interrupt(struct gfar_mii_info *mii_info)
-{
-	/* Clear the interrupts by reading the reg */
-	phy_read(mii_info, MII_M1011_IEVENT);
-
-	return 0;
-}
-
-static int marvell_config_intr(struct gfar_mii_info *mii_info)
-{
-	if(mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
-	else
-		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
-
-	return 0;
-}
-
-static int cis820x_init(struct gfar_mii_info *mii_info)
-{
-	phy_write(mii_info, MII_CIS8201_AUX_CONSTAT, 
-			MII_CIS8201_AUXCONSTAT_INIT);
-	phy_write(mii_info, MII_CIS8201_EXT_CON1,
-			MII_CIS8201_EXTCON1_INIT);
-
-	return 0;
-}
-
-static int cis820x_ack_interrupt(struct gfar_mii_info *mii_info)
-{
-	phy_read(mii_info, MII_CIS8201_ISTAT);
-
-	return 0;
-}
-
-static int cis820x_config_intr(struct gfar_mii_info *mii_info)
-{
-	if(mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
-	else
-		phy_write(mii_info, MII_CIS8201_IMASK, 0);
-
-	return 0;
-}
-
-#define DM9161_DELAY 10
-
-static int dm9161_read_status(struct gfar_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	/* If the link is up, read the speed and duplex */
-	/* If we aren't autonegotiating, assume speeds 
-	 * are as set */
-	if (mii_info->autoneg && mii_info->link) {
-		status = phy_read(mii_info, MII_DM9161_SCSR);
-		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_100H))
-			mii_info->speed = SPEED_100;
-		else
-			mii_info->speed = SPEED_10;
-
-		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_10F))
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-	}
-
-	return 0;
-}
-
-
-static int dm9161_config_aneg(struct gfar_mii_info *mii_info)
-{
-	struct dm9161_private *priv = mii_info->priv;
-
-	if(0 == priv->resetdone)
-		return -EAGAIN;
-
-	return 0;
-}
-
-static void dm9161_timer(unsigned long data)
-{
-	struct gfar_mii_info *mii_info = (struct gfar_mii_info *)data;
-	struct dm9161_private *priv = mii_info->priv;
-	u16 status = phy_read(mii_info, MII_BMSR);
-
-	if (status & BMSR_ANEGCOMPLETE) {
-		priv->resetdone = 1;
-	} else
-		mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
-}
-
-static int dm9161_init(struct gfar_mii_info *mii_info)
-{
-	struct dm9161_private *priv;
-
-	/* Allocate the private data structure */
-	priv = kmalloc(sizeof(struct dm9161_private), GFP_KERNEL);
-
-	if (NULL == priv)
-		return -ENOMEM;
-
-	mii_info->priv = priv;
-
-	/* Reset is not done yet */
-	priv->resetdone = 0;
-
-	/* Isolate the PHY */
-	phy_write(mii_info, MII_BMCR, BMCR_ISOLATE);
-
-	/* Do not bypass the scrambler/descrambler */
-	phy_write(mii_info, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
-
-	/* Clear 10BTCSR to default */
-	phy_write(mii_info, MII_DM9161_10BTCSR, MII_DM9161_10BTCSR_INIT);
-
-	/* Reconnect the PHY, and enable Autonegotiation */
-	phy_write(mii_info, MII_BMCR, BMCR_ANENABLE);
-
-	/* Start a timer for DM9161_DELAY seconds to wait
-	 * for the PHY to be ready */
-	init_timer(&priv->timer);
-	priv->timer.function = &dm9161_timer;
-	priv->timer.data = (unsigned long) mii_info;
-	mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
-
-	return 0;
-}
-
-static void dm9161_close(struct gfar_mii_info *mii_info)
-{
-	struct dm9161_private *priv = mii_info->priv;
-
-	del_timer_sync(&priv->timer);
-	kfree(priv);
-}
-
-#if 0
-static int dm9161_ack_interrupt(struct gfar_mii_info *mii_info)
-{
-	phy_read(mii_info, MII_DM9161_INTR);
-
-	return 0;
-}
-#endif
-
-/* Cicada 820x */
-static struct phy_info phy_info_cis820x = {
-	0x000fc440,
-	"Cicada Cis8204",
-	0x000fffc0,
-	.features	= MII_GBIT_FEATURES,
-	.init		= &cis820x_init,
-	.config_aneg	= &gbit_config_aneg,
-	.read_status	= &cis820x_read_status,
-	.ack_interrupt	= &cis820x_ack_interrupt,
-	.config_intr	= &cis820x_config_intr,
-};
-
-static struct phy_info phy_info_dm9161 = {
-	.phy_id		= 0x0181b880,
-	.name		= "Davicom DM9161E",
-	.phy_id_mask	= 0x0ffffff0,
-	.init		= dm9161_init,
-	.config_aneg	= dm9161_config_aneg,
-	.read_status	= dm9161_read_status,
-	.close		= dm9161_close,
-};
-
-static struct phy_info phy_info_marvell = {
-	.phy_id		= 0x01410c00,
-	.phy_id_mask	= 0xffffff00,
-	.name		= "Marvell 88E1101",
-	.features	= MII_GBIT_FEATURES,
-	.config_aneg	= &marvell_config_aneg,
-	.read_status	= &marvell_read_status,
-	.ack_interrupt	= &marvell_ack_interrupt,
-	.config_intr	= &marvell_config_intr,
-};
-
-static struct phy_info phy_info_genmii= {
-	.phy_id		= 0x00000000,
-	.phy_id_mask	= 0x00000000,
-	.name		= "Generic MII",
-	.features	= MII_BASIC_FEATURES,
-	.config_aneg	= genmii_config_aneg,
-	.read_status	= genmii_read_status,
-};
-
-static struct phy_info *phy_info[] = {
-	&phy_info_cis820x,
-	&phy_info_marvell,
-	&phy_info_dm9161,
-	&phy_info_genmii,
-	NULL
-};
-
-u16 phy_read(struct gfar_mii_info *mii_info, u16 regnum)
-{
-	u16 retval;
-	unsigned long flags;
-
-	spin_lock_irqsave(&mii_info->mdio_lock, flags);
-	retval = mii_info->mdio_read(mii_info->dev, mii_info->mii_id, regnum);
-	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
-
-	return retval;
-}
-
-void phy_write(struct gfar_mii_info *mii_info, u16 regnum, u16 val)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&mii_info->mdio_lock, flags);
-	mii_info->mdio_write(mii_info->dev, 
-			mii_info->mii_id, 
-			regnum, val);
-	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
-}
-
-/* Use the PHY ID registers to determine what type of PHY is attached
- * to device dev.  return a struct phy_info structure describing that PHY
- */
-struct phy_info * get_phy_info(struct gfar_mii_info *mii_info)
-{
-	u16 phy_reg;
-	u32 phy_ID;
-	int i;
-	struct phy_info *theInfo = NULL;
-	struct net_device *dev = mii_info->dev;
-
-	/* Grab the bits from PHYIR1, and put them in the upper half */
-	phy_reg = phy_read(mii_info, MII_PHYSID1);
-	phy_ID = (phy_reg & 0xffff) << 16;
-
-	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = phy_read(mii_info, MII_PHYSID2);
-	phy_ID |= (phy_reg & 0xffff);
-
-	/* loop through all the known PHY types, and find one that */
-	/* matches the ID we read from the PHY. */
-	for (i = 0; phy_info[i]; i++)
-		if (phy_info[i]->phy_id == 
-				(phy_ID & phy_info[i]->phy_id_mask)) {
-			theInfo = phy_info[i];
-			break;
-		}
-
-	/* This shouldn't happen, as we have generic PHY support */
-	if (theInfo == NULL) {
-		printk("%s: PHY id %x is not supported!\n", dev->name, phy_ID);
-		return NULL;
-	} else {
-		printk("%s: PHY is %s (%x)\n", dev->name, theInfo->name,
-		       phy_ID);
-	}
-
-	return theInfo;
-}
diff -Nru a/drivers/net/gianfar_phy.h b/drivers/net/gianfar_phy.h
--- a/drivers/net/gianfar_phy.h	2004-12-23 12:39:15 -06:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,213 +0,0 @@
-/* 
- * drivers/net/gianfar_phy.h
- *
- * Gianfar Ethernet Driver -- PHY handling
- * Driver for FEC on MPC8540 and TSEC on MPC8540/MPC8560
- * Based on 8260_io/fcc_enet.c
- *
- * Author: Andy Fleming
- * Maintainer: Kumar Gala (kumar.gala@freescale.com)
- *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __GIANFAR_PHY_H
-#define __GIANFAR_PHY_H
-
-#define MII_end ((u32)-2)
-#define MII_read ((u32)-1)
-
-#define MIIMIND_BUSY            0x00000001
-#define MIIMIND_NOTVALID        0x00000004
-
-#define GFAR_AN_TIMEOUT         2000
-
-/* 1000BT control (Marvell & BCM54xx at least) */
-#define MII_1000BASETCONTROL			0x09
-#define MII_1000BASETCONTROL_FULLDUPLEXCAP	0x0200
-#define MII_1000BASETCONTROL_HALFDUPLEXCAP	0x0100
-
-/* Cicada Extended Control Register 1 */
-#define MII_CIS8201_EXT_CON1           0x17
-#define MII_CIS8201_EXTCON1_INIT       0x0000
-
-/* Cicada Interrupt Mask Register */
-#define MII_CIS8201_IMASK		0x19
-#define MII_CIS8201_IMASK_IEN		0x8000
-#define MII_CIS8201_IMASK_SPEED	0x4000
-#define MII_CIS8201_IMASK_LINK		0x2000
-#define MII_CIS8201_IMASK_DUPLEX	0x1000
-#define MII_CIS8201_IMASK_MASK		0xf000
-
-/* Cicada Interrupt Status Register */
-#define MII_CIS8201_ISTAT		0x1a
-#define MII_CIS8201_ISTAT_STATUS	0x8000
-#define MII_CIS8201_ISTAT_SPEED	0x4000
-#define MII_CIS8201_ISTAT_LINK		0x2000
-#define MII_CIS8201_ISTAT_DUPLEX	0x1000
-
-/* Cicada Auxiliary Control/Status Register */
-#define MII_CIS8201_AUX_CONSTAT        0x1c
-#define MII_CIS8201_AUXCONSTAT_INIT    0x0004
-#define MII_CIS8201_AUXCONSTAT_DUPLEX  0x0020
-#define MII_CIS8201_AUXCONSTAT_SPEED   0x0018
-#define MII_CIS8201_AUXCONSTAT_GBIT    0x0010
-#define MII_CIS8201_AUXCONSTAT_100     0x0008
-                                                                                
-/* 88E1011 PHY Status Register */
-#define MII_M1011_PHY_SPEC_STATUS		0x11
-#define MII_M1011_PHY_SPEC_STATUS_1000		0x8000
-#define MII_M1011_PHY_SPEC_STATUS_100		0x4000
-#define MII_M1011_PHY_SPEC_STATUS_SPD_MASK	0xc000
-#define MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX	0x2000
-#define MII_M1011_PHY_SPEC_STATUS_RESOLVED	0x0800
-#define MII_M1011_PHY_SPEC_STATUS_LINK		0x0400
-
-#define MII_M1011_IEVENT		0x13
-#define MII_M1011_IEVENT_CLEAR		0x0000
-
-#define MII_M1011_IMASK			0x12
-#define MII_M1011_IMASK_INIT		0x6400
-#define MII_M1011_IMASK_CLEAR		0x0000
-
-#define MII_DM9161_SCR		0x10
-#define MII_DM9161_SCR_INIT	0x0610
-
-/* DM9161 Specified Configuration and Status Register */
-#define MII_DM9161_SCSR	0x11
-#define MII_DM9161_SCSR_100F	0x8000
-#define MII_DM9161_SCSR_100H	0x4000
-#define MII_DM9161_SCSR_10F	0x2000
-#define MII_DM9161_SCSR_10H	0x1000
-
-/* DM9161 Interrupt Register */
-#define MII_DM9161_INTR	0x15
-#define MII_DM9161_INTR_PEND		0x8000
-#define MII_DM9161_INTR_DPLX_MASK	0x0800
-#define MII_DM9161_INTR_SPD_MASK	0x0400
-#define MII_DM9161_INTR_LINK_MASK	0x0200
-#define MII_DM9161_INTR_MASK		0x0100
-#define MII_DM9161_INTR_DPLX_CHANGE	0x0010
-#define MII_DM9161_INTR_SPD_CHANGE	0x0008
-#define MII_DM9161_INTR_LINK_CHANGE	0x0004
-#define MII_DM9161_INTR_INIT 		0x0000
-#define MII_DM9161_INTR_STOP	\
-(MII_DM9161_INTR_DPLX_MASK | MII_DM9161_INTR_SPD_MASK \
- | MII_DM9161_INTR_LINK_MASK | MII_DM9161_INTR_MASK)
-
-/* DM9161 10BT Configuration/Status */
-#define MII_DM9161_10BTCSR	0x12
-#define MII_DM9161_10BTCSR_INIT	0x7800
-
-#define MII_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
-				 SUPPORTED_10baseT_Full | \
-				 SUPPORTED_100baseT_Half | \
-				 SUPPORTED_100baseT_Full | \
-				 SUPPORTED_Autoneg | \
-				 SUPPORTED_TP | \
-				 SUPPORTED_MII)
-
-#define MII_GBIT_FEATURES	(MII_BASIC_FEATURES | \
-				 SUPPORTED_1000baseT_Half | \
-				 SUPPORTED_1000baseT_Full)
-
-#define MII_READ_COMMAND       0x00000001
-
-#define MII_INTERRUPT_DISABLED 0x0
-#define MII_INTERRUPT_ENABLED 0x1
-/* Taken from mii_if_info and sungem_phy.h */
-struct gfar_mii_info {
-	/* Information about the PHY type */
-	/* And management functions */
-	struct phy_info *phyinfo;
-
-	/* forced speed & duplex (no autoneg)
-	 * partner speed & duplex & pause (autoneg)
-	 */
-	int speed;
-	int duplex;
-	int pause;
-
-	/* The most recently read link state */
-	int link;
-
-	/* Enabled Interrupts */
-	u32 interrupts;
-
-	u32 advertising;
-	int autoneg;
-	int mii_id;
-
-	/* private data pointer */
-	/* For use by PHYs to maintain extra state */
-	void *priv;
-
-	/* Provided by host chip */
-	struct net_device *dev;
-
-	/* A lock to ensure that only one thing can read/write
-	 * the MDIO bus at a time */
-	spinlock_t mdio_lock;
-
-	/* Provided by ethernet driver */
-	int (*mdio_read) (struct net_device *dev, int mii_id, int reg);
-	void (*mdio_write) (struct net_device *dev, int mii_id, int reg, int val);
-};
-
-/* struct phy_info: a structure which defines attributes for a PHY
- *
- * id will contain a number which represents the PHY.  During
- * startup, the driver will poll the PHY to find out what its
- * UID--as defined by registers 2 and 3--is.  The 32-bit result
- * gotten from the PHY will be ANDed with phy_id_mask to
- * discard any bits which may change based on revision numbers
- * unimportant to functionality
- *
- * There are 6 commands which take a gfar_mii_info structure.
- * Each PHY must declare config_aneg, and read_status.
- */
-struct phy_info {
-	u32 phy_id;
-	char *name;
-	unsigned int phy_id_mask;
-	u32 features;
-
-	/* Called to initialize the PHY */
-	int (*init)(struct gfar_mii_info *mii_info);
-
-	/* Called to suspend the PHY for power */
-	int (*suspend)(struct gfar_mii_info *mii_info);
-
-	/* Reconfigures autonegotiation (or disables it) */
-	int (*config_aneg)(struct gfar_mii_info *mii_info);
-
-	/* Determines the negotiated speed and duplex */
-	int (*read_status)(struct gfar_mii_info *mii_info);
-
-	/* Clears any pending interrupts */
-	int (*ack_interrupt)(struct gfar_mii_info *mii_info);
-
-	/* Enables or disables interrupts */
-	int (*config_intr)(struct gfar_mii_info *mii_info);
-
-	/* Clears up any memory if needed */
-	void (*close)(struct gfar_mii_info *mii_info);
-};
-
-struct phy_info *get_phy_info(struct gfar_mii_info *mii_info);
-int read_phy_reg(struct net_device *dev, int mii_id, int regnum);
-void write_phy_reg(struct net_device *dev, int mii_id, int regnum, int value);
-void mii_clear_phy_interrupt(struct gfar_mii_info *mii_info);
-void mii_configure_phy_interrupt(struct gfar_mii_info *mii_info, u32 interrupts);
-
-struct dm9161_private {
-	struct timer_list timer;
-	int resetdone;
-};
-
-#endif /* GIANFAR_PHY_H */
diff -Nru a/include/asm-ppc/fsl_ocp.h b/include/asm-ppc/fsl_ocp.h
--- a/include/asm-ppc/fsl_ocp.h	2004-12-23 12:39:16 -06:00
+++ b/include/asm-ppc/fsl_ocp.h	2004-12-23 12:39:16 -06:00
@@ -17,6 +17,7 @@
 #ifndef __ASM_FS_OCP_H__
 #define __ASM_FS_OCP_H__
 
+#define GFAR_MII_OFFSET		0x520
 /* A table of information for supporting the Gianfar Ethernet Controller
  * This helps identify which enet controller we are dealing with,
  * and what type of enet controller it is
@@ -25,20 +26,18 @@
 	uint interruptTransmit;
 	uint interruptError;
 	uint interruptReceive;
-	uint interruptPHY;
 	uint flags;
-	uint phyid;
-	uint phyregidx;
+	char *bus_id;
 	unsigned char mac_addr[6];
 };
 
 /* Flags in the flags field */
-#define GFAR_HAS_COALESCE		0x20
-#define GFAR_HAS_RMON			0x10
-#define GFAR_HAS_MULTI_INTR		0x08
-#define GFAR_FIRM_SET_MACADDR		0x04
-#define GFAR_HAS_PHY_INTR		0x02	/* if not set use a timer */
-#define GFAR_HAS_GIGABIT		0x01
+#define GIANFAR_HAS_COALESCE		0x20
+#define GIANFAR_HAS_RMON		0x10
+#define GIANFAR_HAS_MULTI_INTR		0x08
+#define GIANFAR_FIRM_SET_MACADDR	0x04
+#define GIANFAR_HAS_PHY_INTR		0x02	/* if not set use a timer */
+#define GIANFAR_HAS_GIGABIT		0x01
 
 /* Data structure for I2C support.  Just contains a couple flags
  * to distinguish various I2C implementations*/
diff -Nru a/include/asm-ppc/mpc85xx.h b/include/asm-ppc/mpc85xx.h
--- a/include/asm-ppc/mpc85xx.h	2004-12-23 12:39:16 -06:00
+++ b/include/asm-ppc/mpc85xx.h	2004-12-23 12:39:16 -06:00
@@ -103,8 +103,18 @@
 #define MPC85xx_CPM_SIZE	(0x40000)
 #define MPC85xx_DMA_OFFSET	(0x21000)
 #define MPC85xx_DMA_SIZE	(0x01000)
+#define MPC85xx_DMA0_OFFSET	(0x21100)
+#define MPC85xx_DMA0_SIZE	(0x00080)
+#define MPC85xx_DMA1_OFFSET	(0x21180)
+#define MPC85xx_DMA1_SIZE	(0x00080)
+#define MPC85xx_DMA2_OFFSET	(0x21200)
+#define MPC85xx_DMA2_SIZE	(0x00080)
+#define MPC85xx_DMA3_OFFSET	(0x21280)
+#define MPC85xx_DMA3_SIZE	(0x00080)
 #define MPC85xx_ENET1_OFFSET	(0x24000)
 #define MPC85xx_ENET1_SIZE	(0x01000)
+#define MPC85xx_MIIM_OFFSET	(0x24520)
+#define MPC85xx_MIIM_SIZE	(0x00018)
 #define MPC85xx_ENET2_OFFSET	(0x25000)
 #define MPC85xx_ENET2_SIZE	(0x01000)
 #define MPC85xx_ENET3_OFFSET	(0x26000)
@@ -138,6 +148,18 @@
 #else
 #define CCSRBAR BOARD_CCSRBAR
 #endif
+
+enum fsl_devices {
+	MPC85xx_TSEC1,
+	MPC85xx_TSEC2,
+	MPC85xx_FEC,
+	MPC85xx_IIC1,
+	MPC85xx_DMA0,
+	MPC85xx_DMA1,
+	MPC85xx_DMA2,
+	MPC85xx_DMA3,
+	MPC85xx_MDIO,
+};
 
 #endif /* CONFIG_85xx */
 #endif /* __ASM_MPC85xx_H__ */
diff -Nru a/include/linux/device.h b/include/linux/device.h
--- a/include/linux/device.h	2004-12-23 12:39:16 -06:00
+++ b/include/linux/device.h	2004-12-23 12:39:16 -06:00
@@ -382,6 +382,8 @@
 
 extern struct resource *platform_get_resource(struct platform_device *, unsigned int, unsigned int);
 extern int platform_get_irq(struct platform_device *, unsigned int);
+extern struct resource *platform_get_resource_byname(struct platform_device *, unsigned int, char *);
+extern int platform_get_irq_byname(struct platform_device *, char *);
 extern int platform_add_devices(struct platform_device **, int);
 
 extern struct platform_device *platform_device_register_simple(char *, unsigned int, struct resource *, unsigned int);

--Apple-Mail-2-974361640
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="phy_12232004.patch"
Content-Disposition: attachment;
	filename=phy_12232004.patch

diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2004-12-23 12:39:16 -06:00
+++ b/drivers/net/Kconfig	2004-12-23 12:39:16 -06:00
@@ -155,6 +155,8 @@
 	source "drivers/net/arcnet/Kconfig"
 endif
 
+source "drivers/net/phy/Kconfig"
+
 #
 #	Ethernet
 #
@@ -188,14 +190,6 @@
 	  kernel: saying N will just cause the configurator to skip all
 	  the questions about Ethernet network cards. If unsure, say N.
 
-config MII
-	tristate "Generic Media Independent Interface device support"
-	depends on NET_ETHERNET
-	help
-	  Most ethernet controllers have MII transceiver either as an external
-	  or internal device.  It is safe to say Y or M here even if your
-	  ethernet card lack MII.
-
 source "drivers/net/arm/Kconfig"
 
 config MACE
@@ -2079,17 +2073,6 @@
 	  To compile this driver as a module, choose M here: the module
 	  will be called tg3.  This is recommended.
 
-config GIANFAR
-	tristate "Gianfar Ethernet"
-	depends on 85xx
-	help
-	  This driver supports the Gigabit TSEC on the MPC85xx 
-	  family of chips, and the FEC on the 8540
-
-config GFAR_NAPI
-	bool "NAPI Support"
-	depends on GIANFAR
-
 config MV643XX_ETH
 	tristate "MV-643XX Ethernet support"
 	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX
@@ -2117,6 +2100,18 @@
 	help
 	  This enables support for Port 2 of the Marvell MV643XX Gigabit
 	  Ethernet.
+
+config GIANFAR
+	tristate "Gianfar Ethernet"
+	depends on 85xx
+	depends on MII
+	help
+	  This driver supports the Gigabit TSEC on the MPC85xx 
+	  family of chips, and the FEC on the 8540
+
+config GFAR_NAPI
+	bool "NAPI Support"
+	depends on GIANFAR
 
 endmenu
 
diff -Nru a/drivers/net/Makefile b/drivers/net/Makefile
--- a/drivers/net/Makefile	2004-12-23 12:39:15 -06:00
+++ b/drivers/net/Makefile	2004-12-23 12:39:15 -06:00
@@ -12,7 +12,7 @@
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 
-gianfar_driver-objs := gianfar.o gianfar_ethtool.o gianfar_phy.o
+gianfar_driver-objs := gianfar.o gianfar_ethtool.o gianfar_mii.o
 
 #
 # link order important here
@@ -63,6 +63,7 @@
 #
 
 obj-$(CONFIG_MII) += mii.o
+obj-$(CONFIG_MII) += phy/
 
 obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_HAMACHI) += hamachi.o
diff -Nru a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/Kconfig	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,45 @@
+#
+# PHY Layer Configuration
+#
+
+menu "MII support"
+
+config MII
+	bool "Generic Media Independent Interface device support"
+	depends on NET_ETHERNET
+	help
+	  Most ethernet controllers have an MII transceiver either as an 
+	  external or internal device.  It is safe to say Y here even if 
+	  your ethernet card lacks MII. This code provides functions 
+	  for managing these devices, and infrastructure.
+
+comment "MII PHY device drivers"
+	depends on MII
+
+config MARVELL_PHY
+	bool "Drivers for Marvell PHYs"
+	---help---
+	  Currently has a driver for the 88E1011S
+	
+config DAVICOM_PHY
+	bool "Drivers for Davicom PHYs"
+	---help---
+	  Currently supports dm9161e and dm9131
+
+config QSEMI_PHY
+	bool "Drivers for Quality Semiconductor PHYs"
+	---help---
+	  Currently supports the qs6612
+
+config LXT_PHY
+	bool "Drivers for the Intel LXT PHYs"
+	---help---
+	  Currently supports the lxt970, lxt971
+
+config CICADA_PHY
+	bool "Drivers for the Cicada PHYs"
+	---help---
+	  Currently supports the cis8204
+
+endmenu
+
diff -Nru a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/Makefile	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,9 @@
+# Makefile for Linux PHY drivers
+
+obj-$(CONFIG_MII) += phy.o phy_device.o mdio_bus.o
+
+obj-$(CONFIG_MARVELL_PHY) += marvell.o
+obj-$(CONFIG_DAVICOM_PHY) += davicom.o
+obj-$(CONFIG_CICADA_PHY) += cicada.o
+obj-$(CONFIG_LXT_PHY) += lxt.o
+obj-$(CONFIG_QSEMI_PHY) += qsemi.o
diff -Nru a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/cicada.c	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,165 @@
+/*
+ * drivers/net/phy/cicada.c
+ *
+ * Driver for Cicada PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* Cicada Extended Control Register 1 */
+#define MII_CIS8201_EXT_CON1           0x17
+#define MII_CIS8201_EXTCON1_INIT       0x0000
+
+/* Cicada Interrupt Mask Register */
+#define MII_CIS8201_IMASK		0x19
+#define MII_CIS8201_IMASK_IEN		0x8000
+#define MII_CIS8201_IMASK_SPEED	0x4000
+#define MII_CIS8201_IMASK_LINK		0x2000
+#define MII_CIS8201_IMASK_DUPLEX	0x1000
+#define MII_CIS8201_IMASK_MASK		0xf000
+
+/* Cicada Interrupt Status Register */
+#define MII_CIS8201_ISTAT		0x1a
+#define MII_CIS8201_ISTAT_STATUS	0x8000
+#define MII_CIS8201_ISTAT_SPEED	0x4000
+#define MII_CIS8201_ISTAT_LINK		0x2000
+#define MII_CIS8201_ISTAT_DUPLEX	0x1000
+
+/* Cicada Auxiliary Control/Status Register */
+#define MII_CIS8201_AUX_CONSTAT        0x1c
+#define MII_CIS8201_AUXCONSTAT_INIT    0x0004
+#define MII_CIS8201_AUXCONSTAT_DUPLEX  0x0020
+#define MII_CIS8201_AUXCONSTAT_SPEED   0x0018
+#define MII_CIS8201_AUXCONSTAT_GBIT    0x0010
+#define MII_CIS8201_AUXCONSTAT_100     0x0008
+
+static int cis820x_read_status(struct phy_device *phydev)
+{
+	u16 status;
+	int err;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	/* If the link is up, read the speed and duplex */
+	/* If we aren't autonegotiating, assume speeds
+	 * are as set */
+	if (phydev->autoneg && phydev->link) {
+		int speed;
+
+		status = phy_read(phydev, MII_CIS8201_AUX_CONSTAT);
+		if (status & MII_CIS8201_AUXCONSTAT_DUPLEX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		speed = status & MII_CIS8201_AUXCONSTAT_SPEED;
+
+		switch (speed) {
+		case MII_CIS8201_AUXCONSTAT_GBIT:
+			phydev->speed = SPEED_1000;
+			break;
+		case MII_CIS8201_AUXCONSTAT_100:
+			phydev->speed = SPEED_100;
+			break;
+		default:
+			phydev->speed = SPEED_10;
+			break;
+		}
+	}
+
+	return 0;
+}
+
+static int cis820x_probe(struct phy_device *phydev)
+{
+	phy_write(phydev, MII_CIS8201_AUX_CONSTAT,
+			MII_CIS8201_AUXCONSTAT_INIT);
+	phy_write(phydev, MII_CIS8201_EXT_CON1,
+			MII_CIS8201_EXTCON1_INIT);
+
+	return 0;
+}
+
+static int cis820x_ack_interrupt(struct phy_device *phydev)
+{
+	phy_read(phydev, MII_CIS8201_ISTAT);
+
+	return 0;
+}
+
+static int cis820x_config_intr(struct phy_device *phydev)
+{
+	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		phy_write(phydev, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
+	else
+		phy_write(phydev, MII_CIS8201_IMASK, 0);
+
+	return 0;
+}
+
+/* Cicada 820x */
+static struct phy_driver cis8204_driver = {
+	0x000fc440,
+	"Cicada Cis8204",
+	0x000fffc0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.probe		= &cis820x_probe,
+	.config_aneg	= &gbit_config_aneg,
+	.read_status	= &cis820x_read_status,
+	.ack_interrupt	= &cis820x_ack_interrupt,
+	.config_intr	= &cis820x_config_intr,
+};
+
+int __init cis8204_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&cis8204_driver);
+
+	return retval;
+}
+
+static void __exit cis8204_exit(void)
+{
+	phy_driver_unregister(&cis8204_driver);
+}
+
+module_init(cis8204_init);
+module_exit(cis8204_exit);
diff -Nru a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/davicom.c	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,277 @@
+/*
+ * drivers/net/phy/davicom.c
+ *
+ * Driver for Davicom PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+#define MII_DM9161_SCR		0x10
+#define MII_DM9161_SCR_INIT	0x0610
+
+/* DM9161 Specified Configuration and Status Register */
+#define MII_DM9161_SCSR	0x11
+#define MII_DM9161_SCSR_100F	0x8000
+#define MII_DM9161_SCSR_100H	0x4000
+#define MII_DM9161_SCSR_10F	0x2000
+#define MII_DM9161_SCSR_10H	0x1000
+
+/* DM9161 Interrupt Register */
+#define MII_DM9161_INTR	0x15
+#define MII_DM9161_INTR_PEND		0x8000
+#define MII_DM9161_INTR_DPLX_MASK	0x0800
+#define MII_DM9161_INTR_SPD_MASK	0x0400
+#define MII_DM9161_INTR_LINK_MASK	0x0200
+#define MII_DM9161_INTR_MASK		0x0100
+#define MII_DM9161_INTR_DPLX_CHANGE	0x0010
+#define MII_DM9161_INTR_SPD_CHANGE	0x0008
+#define MII_DM9161_INTR_LINK_CHANGE	0x0004
+#define MII_DM9161_INTR_INIT 		0x0000
+#define MII_DM9161_INTR_STOP	\
+(MII_DM9161_INTR_DPLX_MASK | MII_DM9161_INTR_SPD_MASK \
+ | MII_DM9161_INTR_LINK_MASK | MII_DM9161_INTR_MASK)
+
+/* DM9161 10BT Configuration/Status */
+#define MII_DM9161_10BTCSR	0x12
+#define MII_DM9161_10BTCSR_INIT	0x7800
+
+struct dm9161_private {
+	struct timer_list timer;
+	int resetdone;
+};
+
+#define DM9161_DELAY 1
+int dm9161_config_intr(struct phy_device *phydev)
+{
+	u16 temp;
+
+	temp = phy_read(phydev, MII_DM9161_INTR);
+
+	if(PHY_INTERRUPT_ENABLED == phydev->interrupts )
+		temp &= ~(MII_DM9161_INTR_STOP);
+	else
+		temp |= MII_DM9161_INTR_STOP;
+
+	phy_write(phydev, MII_DM9161_INTR, temp);
+
+	return 0;
+}
+
+
+static int dm9161_read_status(struct phy_device *phydev)
+{
+	u16 status;
+	int err;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	/* If the link is up, read the speed and duplex */
+	/* If we aren't autonegotiating, assume speeds
+	 * are as set */
+	if (phydev->autoneg && phydev->link) {
+		status = phy_read(phydev, MII_DM9161_SCSR);
+		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_100H))
+			phydev->speed = SPEED_100;
+		else
+			phydev->speed = SPEED_10;
+
+		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_10F))
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+	}
+
+	return 0;
+}
+
+
+static void dm9161_timer(unsigned long data)
+{
+	struct phy_device *phydev = (struct phy_device *)data;
+	struct dm9161_private *priv = phydev->priv;
+	u16 status = phy_read(phydev, MII_BMSR);
+
+	spin_lock(&phydev->lock);
+	if (status & BMSR_ANEGCOMPLETE) {
+		if (PHY_PENDING == phydev->state)
+			phydev->state = PHY_UP;
+		else
+			phydev->state = PHY_READY;
+	} else
+		mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
+
+	spin_unlock(&phydev->lock);
+}
+
+
+static int dm9161_config_aneg(struct phy_device *phydev)
+{
+	/* Isolate the PHY */
+	phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
+
+	/* Configure the new settings */
+	genphy_config_advert(phydev);
+
+	/* Reconnect the PHY, and enable Autonegotiation */
+	phy_write(phydev, MII_BMCR, BMCR_ANENABLE);
+
+#if 0
+	/* Start a timer for DM9161_DELAY seconds to wait
+	 * for the PHY to be ready */
+	init_timer(&priv->timer);
+	priv->timer.function = &dm9161_timer;
+	priv->timer.data = (unsigned long) phydev;
+	mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
+#endif
+
+	return 0;
+}
+
+static int dm9161_probe(struct phy_device *phydev)
+{
+	struct dm9161_private *priv;
+
+	/* Allocate the private data structure */
+	priv = kmalloc(sizeof(struct dm9161_private), GFP_KERNEL);
+
+	if (NULL == priv)
+		return -ENOMEM;
+
+	phydev->priv = priv;
+
+	/* Reset is not done yet */
+	priv->resetdone = 0;
+
+	/* Isolate the PHY */
+	phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
+
+	/* Do not bypass the scrambler/descrambler */
+	phy_write(phydev, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
+
+	/* Clear 10BTCSR to default */
+	phy_write(phydev, MII_DM9161_10BTCSR, MII_DM9161_10BTCSR_INIT);
+
+	/* Reconnect the PHY, and enable Autonegotiation */
+	phy_write(phydev, MII_BMCR, BMCR_ANENABLE);
+
+	phydev->state = PHY_STARTING;
+
+	/* Start a timer for DM9161_DELAY seconds to wait
+	 * for the PHY to be ready */
+	init_timer(&priv->timer);
+	priv->timer.function = &dm9161_timer;
+	priv->timer.data = (unsigned long) phydev;
+	mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
+
+	printk(KERN_INFO "Bringing up a Davicom PHY, this could take"
+			" a while...\n");
+	return 0;
+}
+
+static void dm9161_remove(struct phy_device *phydev)
+{
+	struct dm9161_private *priv = phydev->priv;
+
+	del_timer_sync(&priv->timer);
+	kfree(priv);
+}
+
+static int dm9161_ack_interrupt(struct phy_device *phydev)
+{
+	phy_read(phydev, MII_DM9161_INTR);
+
+	return 0;
+}
+
+static struct phy_driver dm9161_driver = {
+	.phy_id		= 0x0181b880,
+	.name		= "Davicom DM9161E",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.probe		= dm9161_probe,
+	.config_aneg	= dm9161_config_aneg,
+	.read_status	= dm9161_read_status,
+	.remove		= dm9161_remove,
+};
+
+static struct phy_driver dm9131_driver = {
+	.phy_id		= 0x00181b80,
+	.name		= "Davicom DM9131",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= dm9161_read_status,
+	.ack_interrupt	= dm9161_ack_interrupt,
+	.config_intr	= dm9161_config_intr,
+};
+
+int __init dm9161_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&dm9161_driver);
+
+	return retval;
+}
+
+static void __exit dm9161_exit(void)
+{
+	phy_driver_unregister(&dm9161_driver);
+}
+
+module_init(dm9161_init);
+module_exit(dm9161_exit);
+
+int __init dm9131_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&dm9131_driver);
+
+	return retval;
+}
+
+static void __exit dm9131_exit(void)
+{
+	phy_driver_unregister(&dm9131_driver);
+}
+
+module_init(dm9131_init);
+module_exit(dm9131_exit);
diff -Nru a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/lxt.c	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,237 @@
+/*
+ * drivers/net/phy/lxt.c
+ *
+ * Driver for Intel LXT PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* The Level one LXT970 is used by many boards				     */
+
+#define MII_LXT970_MIRROR    16  /* Mirror register           */
+#define MII_LXT970_IER       17  /* Interrupt Enable Register */
+
+#define MII_LXT970_IER_IEN	0x0002
+
+#define MII_LXT970_ISR       18  /* Interrupt Status Register */
+
+#define MII_LXT970_CONFIG    19  /* Configuration Register    */
+#define MII_LXT970_CSR       20  /* Chip Status Register      */
+
+#define MII_LXT970_CSR_DUPLEX 0x1000
+#define MII_LXT970_CSR_SPEED 0x0800
+
+/* ------------------------------------------------------------------------- */
+/* The Level one LXT971 is used on some of my custom boards                  */
+
+/* register definitions for the 971 */
+
+#define MII_LXT971_PCR		16  /* Port Control Register     */
+
+#define MII_LXT971_SR2		17  /* Status Register 2         */
+#define MII_LXT971_SR2_DUPLEX	0x0200
+#define MII_LXT971_SR2_SPEED	0x4000
+
+#define MII_LXT971_IER		18  /* Interrupt Enable Register */
+#define MII_LXT971_IER_IEN	0x00f2
+
+#define MII_LXT971_ISR		19  /* Interrupt Status Register */
+
+#define MII_LXT971_LCR		20  /* LED Control Register      */
+
+#define MII_LXT971_TCR		30  /* Transmit Control Register */
+
+
+static int lxt970_read_status(struct phy_device *phydev)
+{
+	u16 status;
+	int err;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	/* If the link is up, read the speed and duplex */
+	/* If we aren't autonegotiating, assume speeds
+	 * are as set */
+	if (phydev->autoneg && phydev->link) {
+		status = phy_read(phydev, MII_LXT970_CSR);
+		if (status & MII_LXT970_CSR_DUPLEX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		if (status & MII_LXT970_CSR_SPEED)
+			phydev->speed = SPEED_100;
+		else
+			phydev->speed = SPEED_10;
+	}
+
+	return 0;
+}
+
+static int lxt970_ack_interrupt(struct phy_device *phydev)
+{
+	phy_read(phydev, MII_BMSR);
+	phy_read(phydev, MII_LXT970_ISR);
+
+	return 0;
+}
+
+static int lxt970_config_intr(struct phy_device *phydev)
+{
+	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		phy_write(phydev, MII_LXT970_IER, MII_LXT970_IER_IEN);
+	else
+		phy_write(phydev, MII_LXT970_IER, 0);
+
+	return 0;
+}
+
+static int lxt970_probe(struct phy_device *phydev)
+{
+	phy_write(phydev, MII_LXT970_CONFIG, 0);
+
+	return 0;
+}
+
+
+static int lxt971_read_status(struct phy_device *phydev)
+{
+	u16 status;
+	int err;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	/* If the link is up, read the speed and duplex */
+	/* If we aren't autonegotiating, assume speeds
+	 * are as set */
+	if (phydev->autoneg && phydev->link) {
+		status = phy_read(phydev, MII_LXT971_SR2);
+		if (status & MII_LXT971_SR2_DUPLEX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex= DUPLEX_HALF;
+
+		if (status & MII_LXT971_SR2_SPEED)
+			phydev->speed = SPEED_100;
+		else
+			phydev->speed = SPEED_10;
+	}
+
+	return 0;
+}
+
+static int lxt971_ack_interrupt(struct phy_device *phydev)
+{
+	phy_read(phydev, MII_LXT971_ISR);
+
+	return 0;
+}
+
+static int lxt971_config_intr(struct phy_device *phydev)
+{
+	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		phy_write(phydev, MII_LXT971_IER, MII_LXT971_IER_IEN);
+	else
+		phy_write(phydev, MII_LXT971_IER, 0);
+
+	return 0;
+}
+
+static struct phy_driver lxt970_driver = {
+	.phy_id		= 0x07810000,
+	.name		= "LXT970",
+	.phy_id_mask	= 0x0fffffff,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.probe		= lxt970_probe,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= lxt970_read_status,
+	.ack_interrupt	= lxt970_ack_interrupt,
+	.config_intr	= lxt970_config_intr,
+};
+
+static struct phy_driver lxt971_driver = {
+	.phy_id		= 0x0001378e,
+	.name		= "LXT971",
+	.phy_id_mask	= 0x0fffffff,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= lxt971_read_status,
+	.ack_interrupt	= lxt971_ack_interrupt,
+	.config_intr	= lxt971_config_intr,
+};
+
+int __init lxt970_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&lxt970_driver);
+
+	return retval;
+}
+
+static void __exit lxt970_exit(void)
+{
+	phy_driver_unregister(&lxt970_driver);
+}
+
+module_init(lxt970_init);
+module_exit(lxt970_exit);
+
+int __init lxt971_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&lxt971_driver);
+
+	return retval;
+}
+
+static void __exit lxt971_exit(void)
+{
+	phy_driver_unregister(&lxt971_driver);
+}
+
+module_init(lxt971_init);
+module_exit(lxt971_exit);
diff -Nru a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/marvell.c	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,173 @@
+/*
+ * drivers/net/phy/marvell.c
+ *
+ * Driver for Marvell PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* 88E1011 PHY Status Register */
+#define MII_M1011_PHY_SPEC_STATUS		0x11
+#define MII_M1011_PHY_SPEC_STATUS_1000		0x8000
+#define MII_M1011_PHY_SPEC_STATUS_100		0x4000
+#define MII_M1011_PHY_SPEC_STATUS_SPD_MASK	0xc000
+#define MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX	0x2000
+#define MII_M1011_PHY_SPEC_STATUS_RESOLVED	0x0800
+#define MII_M1011_PHY_SPEC_STATUS_LINK		0x0400
+
+#define MII_M1011_IEVENT		0x13
+#define MII_M1011_IEVENT_CLEAR		0x0000
+
+#define MII_M1011_IMASK			0x12
+#define MII_M1011_IMASK_INIT		0x6400
+#define MII_M1011_IMASK_CLEAR		0x0000
+
+static int marvell_read_status(struct phy_device *phydev)
+{
+	u16 status;
+	int err;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	/* If the link is up, read the speed and duplex */
+	/* If we aren't autonegotiating, assume speeds
+	 * are as set */
+	if (phydev->autoneg && phydev->link) {
+		int speed;
+		status = phy_read(phydev, MII_M1011_PHY_SPEC_STATUS);
+
+#if 0
+		/* If speed and duplex aren't resolved,
+		 * return an error.  Isn't this handled
+		 * by checking aneg?
+		 */
+		if ((status & MII_M1011_PHY_SPEC_STATUS_RESOLVED) == 0)
+			return -EAGAIN;
+#endif
+
+		/* Get the duplexity */
+		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		/* Get the speed */
+		speed = status & MII_M1011_PHY_SPEC_STATUS_SPD_MASK;
+		switch(speed) {
+			case MII_M1011_PHY_SPEC_STATUS_1000:
+				phydev->speed = SPEED_1000;
+				break;
+			case MII_M1011_PHY_SPEC_STATUS_100:
+				phydev->speed = SPEED_100;
+				break;
+			default:
+				phydev->speed = SPEED_10;
+				break;
+		}
+		phydev->pause = 0;
+	}
+
+	return 0;
+}
+
+static int marvell_ack_interrupt(struct phy_device *phydev)
+{
+	/* Clear the interrupts by reading the reg */
+	phy_read(phydev, MII_M1011_IEVENT);
+
+	return 0;
+}
+
+static int marvell_config_intr(struct phy_device *phydev)
+{
+	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		phy_write(phydev, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
+	else
+		phy_write(phydev, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
+
+	return 0;
+}
+
+static int marvell_config_aneg(struct phy_device *phydev)
+{
+	/* The Marvell PHY has an errata which requires
+	 * that certain registers get written in order
+	 * to restart autonegotiation */
+	phy_write(phydev, MII_BMCR, BMCR_RESET);
+
+	phy_write(phydev, 0x1d, 0x1f);
+	phy_write(phydev, 0x1e, 0x200c);
+	phy_write(phydev, 0x1d, 0x5);
+	phy_write(phydev, 0x1e, 0);
+	phy_write(phydev, 0x1e, 0x100);
+
+	gbit_config_aneg(phydev);
+
+	return 0;
+}
+
+
+static struct phy_driver m88e1101_driver = {
+	.phy_id		= 0x01410c00,
+	.phy_id_mask	= 0xffffff00,
+	.name		= "Marvell 88E1101",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= &marvell_config_aneg,
+	.read_status	= &marvell_read_status,
+	.ack_interrupt	= &marvell_ack_interrupt,
+	.config_intr	= &marvell_config_intr,
+};
+
+int __init marvell_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&m88e1101_driver);
+
+	return retval;
+}
+
+static void __exit marvell_exit(void)
+{
+	phy_driver_unregister(&m88e1101_driver);
+}
+
+module_init(marvell_init);
+module_exit(marvell_exit);
diff -Nru a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/mdio_bus.c	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,173 @@
+/*
+ * drivers/net/phy/mdio_bus.c
+ *
+ * MDIO Bus interface
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* register_mdiobus
+ * bus: The bus being registered
+ *
+ * description: Called by a bus driver to bring up all the PHYs
+ *   on the bus, and attach them to the bus
+ */
+int register_mdiobus(struct mii_bus *bus)
+{
+	int i;
+	int err = 0;
+
+	spin_lock_init(&bus->mdio_lock);
+
+	if (NULL == bus || NULL == bus->name ||
+			NULL == bus->read ||
+			NULL == bus->write)
+		return -EINVAL;
+
+	if (bus->reset)
+		bus->reset(bus);
+
+	for (i=0; i < PHY_MAX_ADDR; i++) {
+		struct phy_device *phydev;
+
+		phydev = get_phy_device(bus, i);
+
+		/* There's a PHY at this address
+		 * We need to set:
+		 * 1) IRQ
+		 * 2) bus_id
+		 * 3) parent
+		 * 4) bus
+		 * 5) mii_bus
+		 * And, we need to register it */
+		if (phydev) {
+			phydev->irq = bus->irq[i];
+
+			phydev->dev.parent = bus->dev;
+
+			phydev->dev.bus = &mdio_bus_type;
+
+			phydev->bus = bus;
+
+			sprintf(phydev->dev.bus_id, "phy%d:%d", bus->id, i);
+
+			err = device_register(&phydev->dev);
+
+			if (err)
+				printk("phy %d did not register (%d)\n",
+						i, err);
+
+			bus->phy_map[i] = phydev;
+		}
+	}
+
+	pr_info("%s: probed\n", bus->name);
+
+	return err;
+}
+EXPORT_SYMBOL(register_mdiobus);
+
+void unregister_mdiobus(struct mii_bus *bus)
+{
+	int i;
+
+	for (i=0; i < PHY_MAX_ADDR; i++)
+		if (bus->phy_map[i]) {
+			device_unregister(&bus->phy_map[i]->dev);
+			kfree(bus->phy_map[i]);
+		}
+
+}
+EXPORT_SYMBOL(unregister_mdiobus);
+
+/* mdio_bus_match
+ * dev: a PHY device
+ * drv: a PHY driver
+ *
+ * description: Given a PHY device, and a PHY driver, return 1 if
+ *   the driver supports the device.  Otherwise, return 0
+ */
+int mdio_bus_match(struct device *dev, struct device_driver *drv)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+	struct phy_driver *phydrv = to_phy_driver(drv);
+
+	return (phydrv->phy_id == (phydev->phy_id & phydrv->phy_id_mask));
+}
+
+/* Suspend and resume.  Copied from platform_suspend and
+ * platform_resume
+ */
+static int mdio_bus_suspend(struct device * dev, u32 state)
+{
+	int ret = 0;
+
+	if (dev->driver && dev->driver->suspend) {
+		ret = dev->driver->suspend(dev, state, SUSPEND_DISABLE);
+		if (ret == 0)
+			ret = dev->driver->suspend(dev, state, SUSPEND_SAVE_STATE);
+		if (ret == 0)
+			ret = dev->driver->suspend(dev, state, SUSPEND_POWER_DOWN);
+	}
+	return ret;
+}
+
+static int mdio_bus_resume(struct device * dev)
+{
+	int ret = 0;
+
+	if (dev->driver && dev->driver->resume) {
+		ret = dev->driver->resume(dev, RESUME_POWER_ON);
+		if (ret == 0)
+			ret = dev->driver->resume(dev, RESUME_RESTORE_STATE);
+		if (ret == 0)
+			ret = dev->driver->resume(dev, RESUME_ENABLE);
+	}
+	return ret;
+}
+
+struct bus_type mdio_bus_type = {
+	.name	= "mdio_bus",
+	.match	= mdio_bus_match,
+	.suspend= mdio_bus_suspend,
+	.resume	= mdio_bus_resume,
+};
+
+int __init mdio_bus_init(void)
+{
+	return bus_register(&mdio_bus_type);
+}
+
+subsys_initcall(mdio_bus_init);
diff -Nru a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/phy.c	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,512 @@
+/*
+ * drivers/net/phy/phy.c
+ *
+ * Framework for configuring and reading PHY devices
+ * Based on code in sungem_phy.c and gianfar_phy.c
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+u16 phy_read(struct phy_device *phydev, u16 regnum);
+void phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+
+/* Convenience functions for reading a given PHY register.
+ * This MUST NOT be called from interrupt context,
+ * because the bus read function may sleep
+ * or generally lock up. */
+u16 phy_read(struct phy_device *phydev, u16 regnum)
+{
+	u16 retval;
+	struct mii_bus *bus = phydev->bus;
+
+	spin_lock_bh(&bus->mdio_lock);
+	retval = bus->read(bus, phydev->addr, regnum);
+	spin_unlock_bh(&bus->mdio_lock);
+
+	return retval;
+}
+
+void phy_write(struct phy_device *phydev, u16 regnum, u16 val)
+{
+	struct mii_bus *bus = phydev->bus;
+
+	spin_lock_bh(&bus->mdio_lock);
+	bus->write(bus, phydev->addr, regnum, val);
+	spin_unlock_bh(&bus->mdio_lock);
+}
+
+
+void phy_clear_interrupt(struct phy_device *phydev)
+{
+	if (phydev->drv->ack_interrupt)
+		phydev->drv->ack_interrupt(phydev);
+}
+
+
+void phy_config_interrupt(struct phy_device *phydev,
+		u32 interrupts)
+{
+	phydev->interrupts = interrupts;
+	if (phydev->drv->config_intr)
+		phydev->drv->config_intr(phydev);
+}
+
+
+static inline void phy_read_status(struct phy_device *phydev)
+{
+	phydev->drv->read_status(phydev);
+}
+
+static inline int phy_aneg_done(struct phy_device *phydev)
+{
+	return (phy_read(phydev, MII_BMSR) & BMSR_ANEGCOMPLETE);
+}
+
+/* phy_start_aneg
+ * phydev: The PHY on which to initiate auto-negotiation
+ *
+ * description: Calls the PHY driver's config_aneg, and then
+ *   sets the PHY state to PHY_AN if auto-negotiation is enabled,
+ *   and to PHY_FORCING if auto-negotiation is disabled. Unless
+ *   the PHY is currently HALTED.
+ */
+void phy_start_aneg(struct phy_device *phydev)
+{
+	spin_lock(&phydev->lock);
+
+	if (AUTONEG_DISABLE == phydev->autoneg)
+		phy_sanitize_settings(phydev);
+
+	phydev->drv->config_aneg(phydev);
+
+	if (phydev->state != PHY_HALTED) {
+		if (AUTONEG_ENABLE == phydev->autoneg) {
+			phydev->state = PHY_AN;
+			phydev->link_timeout = PHY_AN_TIMEOUT;
+		} else {
+			phydev->state = PHY_FORCING;
+			phydev->link_timeout = PHY_FORCE_TIMEOUT;
+		}
+	}
+
+	spin_unlock(&phydev->lock);
+}
+
+
+/* phy_interrupt
+ * irq: Interrupt number
+ * phy_dat: PHY device which caused the interrupt (presumably)
+ * regs: --
+ *
+ * description: When a PHY interrupt occurs, the handler disables
+ * interrupts, and schedules a work task to clear the interrupt.
+ */
+static irqreturn_t phy_interrupt(int irq, void *phy_dat, struct pt_regs *regs)
+{
+	struct phy_device *phydev = phy_dat;
+
+	/* The MDIO bus is not allowed to be written in interrupt
+	 * context, so we need to disable the irq here.  A work
+	 * queue will write the PHY to disable and clear the
+	 * interrupt, and then reenable the irq line. */
+	disable_irq_nosync(irq);
+
+	schedule_work(&phydev->phy_queue);
+
+	return IRQ_HANDLED;
+}
+
+/* phy_start_interrupts
+ * phydev: The PHY whose interrupts are being enabled
+ *
+ * description: Request the interrupt for the given PHY.  If
+ *   this fails, then we set irq to -1 so that we do polling.
+ *   Otherwise, we enable the interrupts.
+ *   Returns 0 on success, -1 on error.
+ */
+int phy_start_interrupts(struct phy_device *phydev)
+{
+	if (request_irq(phydev->irq, phy_interrupt,
+				SA_SHIRQ,
+				"phy_interrupt",
+				phydev) < 0) {
+		printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
+				phydev->bus->name,
+				phydev->irq);
+		phydev->irq = -1;
+		return -1;
+	}
+
+	phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+
+	return 0;
+}
+
+/* Scheduled by the phy_interrupt/timer to handle PHY changes */
+void phy_change(void *data)
+{
+	struct phy_device *phydev = data;
+
+	/* Disable PHY interrupts */
+	phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
+
+	/* Clear the interrupt */
+	phy_clear_interrupt(phydev);
+
+	spin_lock(&phydev->lock);
+	if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
+		phydev->state = PHY_CHANGELINK;
+	spin_unlock(&phydev->lock);
+
+	enable_irq(phydev->irq);
+
+	/* Reenable interrupts, if needed */
+	phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+}
+
+/* Bring down the PHY link, and stop checking the status. */
+void phy_stop(struct phy_device *phydev)
+{
+	spin_lock(&phydev->lock);
+
+	if (PHY_HALTED == phydev->state) {
+		spin_unlock(&phydev->lock);
+		return;
+	}
+
+	if (phydev->irq != -1) {
+		/* Clear any pending interrupts */
+		phy_clear_interrupt(phydev);
+
+		/* Disable PHY Interrupts */
+		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
+	}
+
+	phydev->state = PHY_HALTED;
+
+	spin_unlock(&phydev->lock);
+}
+
+
+/* phy_start
+ * phydev: The PHY device being started
+ *
+ * description: Indicates the attached device's readiness to
+ *   handle PHY-related work.  Used during startup to start the
+ *   PHY, and after a call to phy_stop() to resume operation.
+ */
+void phy_start(struct phy_device *phydev)
+{
+	spin_lock(&phydev->lock);
+
+	switch (phydev->state) {
+		case PHY_STARTING:
+			phydev->state = PHY_PENDING;
+			break;
+		case PHY_READY:
+			phydev->state = PHY_UP;
+			break;
+		case PHY_HALTED:
+			phydev->state = PHY_RESUMING;
+		default:
+			break;
+	}
+	spin_unlock(&phydev->lock);
+}
+EXPORT_SYMBOL(phy_stop);
+EXPORT_SYMBOL(phy_start);
+
+/* A structure for mapping a particular speed and duplex
+ * combination to a particular SUPPORTED and ADVERTISED value */
+struct phy_setting {
+	int speed;
+	int duplex;
+	u32 setting;
+};
+
+/* A mapping of all SUPPORTED settings to speed/duplex */
+static struct phy_setting settings[] = {
+	{ .speed = 10000, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_10000baseT_Full,
+	},
+	{ .speed = SPEED_1000, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_1000baseT_Full,
+	},
+	{ .speed = SPEED_1000, .duplex = DUPLEX_HALF,
+		.setting = SUPPORTED_1000baseT_Half,
+	},
+	{ .speed = SPEED_100, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_100baseT_Full,
+	},
+	{ .speed = SPEED_100, .duplex = DUPLEX_HALF,
+		.setting = SUPPORTED_100baseT_Half,
+	},
+	{ .speed = SPEED_10, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_10baseT_Full,
+	},
+	{ .speed = SPEED_10, .duplex = DUPLEX_HALF,
+		.setting = SUPPORTED_10baseT_Half,
+	},
+};
+
+#define MAX_NUM_SETTINGS (sizeof(settings)/sizeof(struct phy_setting))
+
+/* phy_find_setting
+ * speed: desired speed of setting
+ * duplex: desired duplex of setting
+ *
+ * description: Searches the settings array for the setting which
+ *   matches the desired speed and duplex, and returns the index
+ *   of that setting.  Returns the index of the last setting if
+ *   none of the others match.
+ */
+static inline int phy_find_setting(int speed, int duplex)
+{
+	int idx = 0;
+
+	while (idx < MAX_NUM_SETTINGS &&
+			(settings[idx].speed != speed ||
+			settings[idx].duplex != duplex))
+		idx++;
+
+	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
+}
+
+/* phy_find_valid
+ * idx: The first index in settings[] to search
+ * features: A mask of the valid settings
+ *
+ * description: Returns the index of the first valid setting less
+ *   than or equal to the one pointed to by idx, as determined by
+ *   the mask in features.  Returns the index of the last setting
+ *   if nothing else matches.
+ */
+static inline int phy_find_valid(int idx, u32 features)
+{
+	while (idx < MAX_NUM_SETTINGS && !(settings[idx].setting & features))
+		idx++;
+
+	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
+}
+
+/* phy_sanitize_settings
+ * phydev: The PHY in question
+ *
+ * description: Make sure the PHY is set to supported speeds and
+ *   duplexes.  Drop down by one in this order:  1000/FULL,
+ *   1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF
+ */
+void phy_sanitize_settings(struct phy_device *phydev)
+{
+	u32 features = phydev->supported;
+	int idx;
+
+	/* Sanitize settings based on PHY capabilities */
+	if ((features & SUPPORTED_Autoneg) == 0)
+		phydev->autoneg = 0;
+
+	idx = phy_find_valid(phy_find_setting(phydev->speed, phydev->duplex),
+			features);
+
+	phydev->speed = settings[idx].speed;
+	phydev->duplex = settings[idx].duplex;
+}
+
+/* phy_force_reduction
+ * phydev: The PHY in question
+ *
+ * description: Reduces the speed/duplex settings by
+ *   one notch.  The order is so:
+ *   1000/FULL, 1000/HALF, 100/FULL, 100/HALF,
+ *   10/FULL, 10/HALF.  The function bottoms out at 10/HALF.
+ */
+void phy_force_reduction(struct phy_device *phydev)
+{
+	int idx;
+
+	idx = phy_find_setting(phydev->speed, phydev->duplex);
+	
+	idx++;
+
+	idx = phy_find_valid(idx, phydev->supported);
+
+	phydev->speed = settings[idx].speed;
+	phydev->duplex = settings[idx].duplex;
+
+	printk(KERN_INFO "Trying %d/%s\n", phydev->speed,
+			DUPLEX_FULL == phydev->duplex ? "FULL" : "HALF");
+}
+
+/* PHY timer which handles the state machine */
+void phy_timer(unsigned long data)
+{
+	struct phy_device *phydev = (struct phy_device *)data;
+	int needs_aneg = 0;
+
+	spin_lock(&phydev->lock);
+
+	if (phydev->adjust_state)
+		phydev->adjust_state(phydev->attached_dev);
+
+	switch(phydev->state) {
+		case PHY_DOWN:
+		case PHY_STARTING:
+		case PHY_READY:
+		case PHY_PENDING:
+			break;
+		case PHY_UP:
+			needs_aneg = 1;
+
+			phydev->link_timeout = PHY_AN_TIMEOUT;
+
+			if (phydev->irq != -1)
+				phy_start_interrupts(phydev);
+
+			break;
+		case PHY_AN:
+			/* Check if negotiation is done.  If so,
+			 * we change to either RUNNING, or NOLINK */
+			if (phy_aneg_done(phydev)) {
+				phy_read_status(phydev);
+
+				if (phydev->link)
+					phydev->state = PHY_RUNNING;
+				else
+					phydev->state = PHY_NOLINK;
+
+				phydev->adjust_link(phydev->attached_dev);
+				break;
+			}
+
+			/* The counter expired, so either we
+			 * switch to forced mode, or the
+			 * magic_aneg bit exists, and we try aneg
+			 * again */
+			if (0 == phydev->link_timeout--) {
+				if (!(phydev->drv->flags & PHY_HAS_MAGICANEG)) {
+					int idx;
+
+					/* We'll start from the
+					 * fastest speed, and work
+					 * our way down */
+					idx = phy_find_valid(0,
+							phydev->supported);
+
+					phydev->speed = settings[idx].speed;
+					phydev->duplex = settings[idx].duplex;
+					
+					phydev->autoneg = AUTONEG_DISABLE;
+					phydev->state = PHY_FORCING;
+					phydev->link_timeout =
+						PHY_FORCE_TIMEOUT;
+
+					pr_info("Trying %d/%s\n", phydev->speed,
+							DUPLEX_FULL ==
+							phydev->duplex ?
+							"FULL" : "HALF");
+				}
+
+				needs_aneg = 1;
+			}
+			break;
+		case PHY_NOLINK:
+			phy_read_status(phydev);
+
+			if (phydev->link) {
+				phydev->state = PHY_RUNNING;
+				phydev->adjust_link(phydev->attached_dev);
+			}
+			break;
+		case PHY_FORCING:
+			phy_read_status(phydev);
+
+			if (phydev->link) {
+				phydev->state = PHY_RUNNING;
+			} else {
+				if (0 == phydev->link_timeout--) {
+					phy_force_reduction(phydev);
+					needs_aneg = 1;
+				}
+			}
+
+			phydev->adjust_link(phydev->attached_dev);
+			break;
+		case PHY_RUNNING:
+			/* Only register a CHANGE if we aren't
+			 * using interrupts */
+			if (-1 == phydev->irq)
+				phydev->state = PHY_CHANGELINK;
+			break;
+		case PHY_CHANGELINK:
+			phy_read_status(phydev);
+
+			if (phydev->link)
+				phydev->state = PHY_RUNNING;
+			else {
+				phydev->state = PHY_NOLINK;
+			}
+
+			phydev->adjust_link(phydev->attached_dev);
+
+			if (-1 != phydev->irq)
+				phy_config_interrupt(phydev,
+						PHY_INTERRUPT_ENABLED);
+			break;
+		case PHY_HALTED:
+			if (phydev->link) {
+				phydev->link = 0;
+				phydev->adjust_link(phydev->attached_dev);
+			}
+			break;
+		case PHY_RESUMING:
+			if (AUTONEG_ENABLE == phydev->autoneg) {
+				if (phy_aneg_done(phydev)) {
+					phydev->state = PHY_RUNNING;
+				} else {
+					phydev->state = PHY_AN;
+					phydev->link_timeout = PHY_AN_TIMEOUT;
+				}
+			} else
+				phydev->state = PHY_RUNNING;
+			break;
+	}
+
+	spin_unlock(&phydev->lock);
+
+	if (needs_aneg)
+		phy_start_aneg(phydev);
+
+	mod_timer(&phydev->phy_timer, jiffies + PHY_STATE_TIME * HZ);
+}
diff -Nru a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/phy_device.c	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,598 @@
+/*
+ * drivers/net/phy/phy_device.c
+ *
+ * Framework for finding and configuring PHYs.
+ * Also contains generic PHY driver
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* get_phy_device
+ * bus: The bus the PHY is on
+ * addr: The address of the desired PHY device
+ *
+ * description: Reads the ID registers of the desired PHY,
+ *   then allocates and returns the phy_device which
+ *   represents it.
+ */
+struct phy_device * get_phy_device(struct mii_bus *bus, uint addr)
+{
+	u16 phy_reg;
+	u32 phy_id;
+	struct phy_device *dev = NULL;
+
+	/* Grab the bits from PHYIR1, and put them
+	 * in the upper half */
+	phy_reg = bus->read(bus, addr, MII_PHYSID1);
+	phy_id = (phy_reg & 0xffff) << 16;
+
+	/* Grab the bits from PHYIR2, and put them in the lower half */
+	phy_reg = bus->read(bus, addr, MII_PHYSID2);
+	phy_id |= (phy_reg & 0xffff);
+
+	/* If the phy_id is all Fs, there is no device there */
+	if (0xffffffff == phy_id)
+		return NULL;
+
+	/* Otherwise, we allocate the device, and initialize the
+	 * default values */
+	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
+
+	if (NULL == dev) {
+		errno = -ENOMEM;
+		return NULL;
+	}
+
+	memset(dev, 0, sizeof(*dev));
+
+	dev->speed = 0;
+	dev->duplex = -1;
+	dev->pause = 0;
+	dev->link = 1;
+
+	dev->autoneg = AUTONEG_ENABLE;
+
+	dev->addr = addr;
+	dev->phy_id = phy_id;
+	dev->bus = bus;
+
+	dev->state = PHY_DOWN;
+
+	spin_lock_init(&dev->lock);
+
+	INIT_WORK(&dev->phy_queue, phy_change, dev);
+
+	return dev;
+}
+
+/* phy_prepare_link:
+ * phydev: The PHY device whose link is being prepped
+ * adjust_link: The link change handler for the controller
+ *
+ * description: Tells the PHY infrastructure to handle the
+ *   gory details on monitoring link status (whether through
+ *   polling or an interrupt), and to call back to the
+ *   connected device driver when the link status changes.
+ *   If you want to monitor your own link state, don't call
+ *   this function */
+void phy_prepare_link(struct phy_device *phydev,
+		void (*handler)(struct device *))
+{
+	if (handler)
+		phydev->adjust_link = handler;
+	else
+		phydev->adjust_link = NULL;
+}
+
+/* phy_start_machine:
+ * phydev: The PHY device whose state machine is being started
+ * handler: The callback function for state change notifications.
+ *
+ * description: The PHY infrastructure can run a state machine
+ *   which tracks whether the PHY is starting up, negotiating,
+ *   etc.  This function starts the timer which tracks the state
+ *   of the PHY.  If you want to be notified when the state
+ *   changes, pass in the callback, otherwise, pass NULL.  If you
+ *   want to maintain your own state machine, do not call this
+ *   function. */
+void phy_start_machine(struct phy_device *phydev,
+		void (*handler)(struct device *))
+{
+	if (handler)
+		phydev->adjust_state = handler;
+	else
+		phydev->adjust_state = NULL;
+
+	init_timer(&phydev->phy_timer);
+	phydev->phy_timer.function = &phy_timer;
+	phydev->phy_timer.data = (unsigned long) phydev;
+	mod_timer(&phydev->phy_timer, jiffies + HZ);
+}
+
+/* phy_stop_machine
+ *
+ * description: Stops the state machine timer, sets the state to
+ *   UP (unless it wasn't up yet), and then frees the interrupt,
+ *   if it is in use. This function must be called BEFORE
+ *   phy_detach.
+ */
+void phy_stop_machine(struct phy_device *phydev)
+{
+	del_timer_sync(&phydev->phy_timer);
+
+	spin_lock(&phydev->lock);
+	if (phydev->state > PHY_UP)
+		phydev->state = PHY_UP;
+	spin_unlock(&phydev->lock);
+
+	if (phydev->irq != -1) {
+		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
+		phy_clear_interrupt(phydev);
+		free_irq(phydev->irq, phydev);
+	}
+
+	phydev->adjust_state = NULL;
+}
+
+/* phy_attach:
+ *   dev: The requesting device
+ *   phy_id: The name of the requested PHY device
+ *
+ *   description: Called by drivers to attach to a particular PHY
+ *     device. The phy_device is found, and properly hooked up
+ *     to the phy_driver.  If no driver is attached, then the
+ *     genphy_driver is used.  The phy_device is given a ptr to
+ *     the attaching device, and given a callback for link status
+ *     change.  The phy_device is returned to the attaching
+ *     driver.
+ */
+struct phy_device *phy_attach(struct device *dev, char *phy_id)
+{
+	struct phy_device *phydev = NULL;
+	struct bus_type *bus = &mdio_bus_type;
+	struct list_head *entry;
+
+	/* Search the list of PHY devices on the mdio bus for the
+	 * PHY with the requested name */
+	list_for_each(entry, &bus->devices.list)
+	{
+		struct device *d = container_of(entry, struct device, bus_list);
+
+		if (!strcmp(phy_id, d->bus_id)) {
+			phydev = to_phy_device(d);
+			break;
+		}
+	}
+
+	if (NULL == phydev) {
+		printk(KERN_ERR "%s not found\n", phy_id);
+		errno = -ENODEV;
+		return NULL;
+	}
+
+	/* Assume that if there is no driver, that it doesn't
+	 * exist, and we should use the genphy driver. */
+	if (NULL == phydev->dev.driver) {
+		down_write(&phydev->dev.bus->subsys.rwsem);
+		phydev->dev.driver = &genphy_driver.driver;
+
+		device_bind_driver(&phydev->dev);
+		up_write(&phydev->dev.bus->subsys.rwsem);
+	}
+
+	if (phydev->attached_dev) {
+		printk(KERN_ERR "%s: %s already attached\n",
+				dev->bus_id, phy_id);
+		errno = -EBUSY;
+		return NULL;
+	}
+
+	phydev->attached_dev = dev;
+
+	return phydev;
+}
+EXPORT_SYMBOL(phy_attach);
+
+/* phy_connect:
+ * dev: The requesting device
+ * phy_id: The name of the requested PHY device
+ * adjust_link: A callback function for handling link status
+ *   changes
+ *
+ * description: Convenience function for connecting ethernet (or
+ *   other) devices to PHY devices.  The default behavior is for
+ *   the PHY infrastructure to handle everything, and only notify
+ *   the connected driver when the link status changes.  If you
+ *   don't want, or can't use the provided functionality, you may
+ *   choose to call only the subset of functions which provide
+ *   the desired functionality.
+ */
+struct phy_device * phy_connect(struct device *dev, char *phy_id,
+		void (*handler)(struct device *))
+{
+	struct phy_device *phydev;
+
+	phydev = phy_attach(dev, phy_id);
+
+	if (NULL == phydev)
+		return phydev;
+
+	phy_prepare_link(phydev, handler);
+
+	phy_start_machine(phydev, NULL);
+
+	return phydev;
+}
+EXPORT_SYMBOL(phy_connect);
+
+void phy_disconnect(struct phy_device *phydev)
+{
+	phy_stop_machine(phydev);
+	
+	phydev->adjust_link = NULL;
+
+	phy_detach(phydev);
+}
+EXPORT_SYMBOL(phy_disconnect);
+
+void phy_detach(struct phy_device *phydev)
+{
+	phydev->attached_dev = NULL;
+
+	/* If the device had no specific driver before (i.e. - it
+	 * was using the generic driver), we unbind the device
+	 * from the generic driver so that there's a chance a
+	 * real driver could be loaded */
+	if (phydev->dev.driver == &genphy_driver.driver) {
+		down_write(&phydev->dev.bus->subsys.rwsem);
+		device_release_driver(&phydev->dev);
+		up_write(&phydev->dev.bus->subsys.rwsem);
+	}
+}
+EXPORT_SYMBOL(phy_detach);
+
+
+/* Generic PHY support and helper functions */
+
+/* genphy_config_advert
+ *
+ * description: Writes MII_ADVERTISE with the appropriate values,
+ *   after sanitizing the values to make sure we only advertise
+ *   what is supported
+ */
+void genphy_config_advert(struct phy_device *phydev)
+{
+	u32 advertise;
+	u16 adv;
+
+	/* Only allow advertising what
+	 * this PHY supports */
+	phydev->advertising &= phydev->supported;
+	advertise = phydev->advertising;
+
+	/* Setup standard advertisement */
+	adv = phy_read(phydev, MII_ADVERTISE);
+
+	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
+	if (advertise & ADVERTISED_10baseT_Half)
+		adv |= ADVERTISE_10HALF;
+	if (advertise & ADVERTISED_10baseT_Full)
+		adv |= ADVERTISE_10FULL;
+	if (advertise & ADVERTISED_100baseT_Half)
+		adv |= ADVERTISE_100HALF;
+	if (advertise & ADVERTISED_100baseT_Full)
+		adv |= ADVERTISE_100FULL;
+
+	phy_write(phydev, MII_ADVERTISE, adv);
+}
+
+
+/* genphy_setup_forced
+ *
+ * description: Configures MII_BMCR to force speed/duplex
+ *   to the values in phydev. Assumes that the values are valid.
+ *   Please see phy_sanitize_settings() */
+void genphy_setup_forced(struct phy_device *phydev)
+{
+	u16 ctrl = phy_read(phydev, MII_BMCR);
+
+	ctrl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_SPEED1000|BMCR_ANENABLE);
+	ctrl |= BMCR_RESET;
+
+	if (SPEED_1000 == phydev->speed)
+		ctrl |= BMCR_SPEED1000;
+	else if (SPEED_100 == phydev->speed)
+		ctrl |= BMCR_SPEED100;
+
+	if (DUPLEX_FULL == phydev->duplex)
+		ctrl |= BMCR_FULLDPLX;
+	
+	phy_write(phydev, MII_BMCR, ctrl);
+}
+
+
+/* Enable and Restart Autonegotiation */
+void genphy_restart_aneg(struct phy_device *phydev)
+{
+	u16 ctl;
+
+	ctl = phy_read(phydev, MII_BMCR);
+	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	phy_write(phydev, MII_BMCR, ctl);
+}
+
+
+/* gbit_config_aneg
+ *
+ * description: Does the same thing as genphy_config_advert()
+ *   (it even calls it), but also properly configures
+ *   MII_1000BASETCONTROL.  Should only be called for
+ *   gigabit-capable PHYs
+ */
+int gbit_config_aneg(struct phy_device *phydev)
+{
+	u16 adv;
+	u32 advertise;
+
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		/* Configure the ADVERTISE register */
+		genphy_config_advert(phydev);
+		advertise = phydev->advertising;
+
+		adv = phy_read(phydev, MII_1000BASETCONTROL);
+		adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
+				MII_1000BASETCONTROL_HALFDUPLEXCAP);
+		if (advertise & SUPPORTED_1000baseT_Half)
+			adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
+		if (advertise & SUPPORTED_1000baseT_Full)
+			adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
+		phy_write(phydev, MII_1000BASETCONTROL, adv);
+
+		/* Start/Restart aneg */
+		genphy_restart_aneg(phydev);
+	} else
+		genphy_setup_forced(phydev);
+
+	return 0;
+}
+
+
+/* genphy_config_aneg
+ *
+ * description: If auto-negotiation is enabled, we configure the
+ *   advertising, and then restart auto-negotiation.  If it is not
+ *   enabled, then we write the BMCR
+ */
+int genphy_config_aneg(struct phy_device *phydev)
+{
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		genphy_config_advert(phydev);
+		genphy_restart_aneg(phydev);
+	} else
+		genphy_setup_forced(phydev);
+
+	return 0;
+}
+
+
+/* genphy_update_link
+ *
+ * description: Update the value in phydev->link to reflect the
+ *   current link value.  In order to do this, we need to read
+ *   the status register twice, keeping the second value
+ */
+int genphy_update_link(struct phy_device *phydev)
+{
+	u16 status;
+
+	/* Do a fake read */
+	phy_read(phydev, MII_BMSR);
+
+	/* Read link and autonegotiation status */
+	status = phy_read(phydev, MII_BMSR);
+	if ((status & BMSR_LSTATUS) == 0)
+		phydev->link = 0;
+	else
+		phydev->link = 1;
+
+	return 0;
+}
+
+/* genphy_read_status
+ *
+ * description: Check the link, then figure out the current state
+ *   by comparing what we advertise with what the link partner
+ *   advertises.  This is a bit silly, since pretty much every
+ *   PHY has actual status fields to tell you what the result
+ *   was, but if you don't want to implement that, this should
+ *   work.
+ */
+int genphy_read_status(struct phy_device *phydev)
+{
+	u16 status;
+	int err;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		status = phy_read(phydev, MII_LPA);
+
+		status &= phy_read(phydev, MII_ADVERTISE);
+
+		/* If we can do 100, set it so */
+		if (status & (LPA_100FULL | LPA_100HALF))
+			phydev->speed = SPEED_100;
+		else
+			phydev->speed = SPEED_10;
+
+		/* If we have 100 full, it's full */
+		if (status & (LPA_100FULL))
+			phydev->duplex = DUPLEX_FULL;
+
+		/* It's also full if we have 10 full, but not 100 half */
+		else if ((status & (LPA_100HALF|LPA_10FULL)) == LPA_10FULL)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		phydev->pause = 0;
+	}
+	/* On non-aneg, we assume what we put in BMCR is the speed,
+	 * though magic-aneg shouldn't prevent this case from occurring
+	 */
+
+	return 0;
+}
+
+
+/* phy_probe
+ * dev: The device belonging to a PHY device
+ *
+ * description: Take care of setting up the phy_device structure,
+ *   set the state to READY (the driver's probe function should
+ *   set it to STARTING if needed).
+ */
+int phy_probe(struct device *dev)
+{
+	struct phy_device *phydev;
+	struct phy_driver *phydrv;
+	struct device_driver *drv;
+	int err = 0;
+
+	phydev = to_phy_device(dev);
+
+	/* Make sure the driver is held.
+	 * XXX -- Is this correct? */
+	drv = get_driver(phydev->dev.driver);
+	phydrv = to_phy_driver(drv);
+	phydev->drv = phydrv;
+
+	/* Disable the interrupt if the PHY doesn't support it */
+	if (!(phydrv->flags & PHY_HAS_INTERRUPT))
+		phydev->irq = -1;
+
+	/* Start out supporting everything. Eventually,
+	 * a controller will attach, and may modify one
+	 * or both of these values */
+	phydev->supported = phydrv->features;
+	phydev->advertising = phydrv->features;
+
+	spin_lock(&phydev->lock);
+
+	/* Set the state to READY by default */
+	phydev->state = PHY_READY;
+
+	if (phydev->drv->probe)
+		err = phydev->drv->probe(phydev);
+
+	spin_unlock(&phydev->lock);
+
+	return 0;
+}
+
+int phy_remove(struct device *dev)
+{
+	struct phy_device *phydev;
+
+	phydev = to_phy_device(dev);
+
+	spin_lock(&phydev->lock);
+	phydev->state = PHY_DOWN;
+	spin_unlock(&phydev->lock);
+
+	if (phydev->drv->remove)
+		phydev->drv->remove(phydev);
+
+	put_driver(phydev->dev.driver);
+	phydev->drv = NULL;
+
+	return 0;
+}
+
+int phy_driver_register(struct phy_driver *new_driver)
+{
+	int retval;
+
+	memset(&new_driver->driver, 0, sizeof(new_driver->driver));
+	new_driver->driver.name = new_driver->name;
+	new_driver->driver.bus = &mdio_bus_type;
+	new_driver->driver.probe = phy_probe;
+	new_driver->driver.remove = phy_remove;
+
+	retval = driver_register(&new_driver->driver);
+
+	if (!retval)
+		pr_info("%s: Registered new driver\n", new_driver->name);
+	else
+		printk(KERN_ERR "%s: Error %d in registering driver\n",
+				new_driver->name, retval);
+
+	return retval;
+}
+
+void phy_driver_unregister(struct phy_driver *drv)
+{
+	driver_unregister(&drv->driver);
+}
+
+struct phy_driver genphy_driver = {
+	.phy_id		= 0x00000000,
+	.phy_id_mask	= 0xffffffff,
+	.name		= "Generic PHY",
+	.features	= PHY_BASIC_FEATURES,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+};
+
+static int __init genphy_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&genphy_driver);
+
+	return retval;
+}
+
+static void __exit genphy_exit(void)
+{
+	phy_driver_unregister(&genphy_driver);
+}
+
+module_init(genphy_init);
+module_exit(genphy_exit);
diff -Nru a/drivers/net/phy/qsemi.c b/drivers/net/phy/qsemi.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/qsemi.c	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,183 @@
+/*
+ * drivers/net/phy/qsemi.c
+ *
+ * Driver for Quality Semiconductor PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* ------------------------------------------------------------------------- */
+/* The Quality Semiconductor QS6612 is used on the RPX CLLF                  */
+
+/* register definitions */
+
+#define MII_QS6612_MCR		17  /* Mode Control Register      */
+#define MII_QS6612_FTR		27  /* Factory Test Register      */
+#define MII_QS6612_MCO		28  /* Misc. Control Register     */
+#define MII_QS6612_ISR		29  /* Interrupt Source Register  */
+#define MII_QS6612_IMR		30  /* Interrupt Mask Register    */
+#define MII_QS6612_IMR_INIT	0x003a
+#define MII_QS6612_PCR		31  /* 100BaseTx PHY Control Reg. */
+
+#define QS6612_PCR_AN_COMPLETE	0x1000
+#define QS6612_PCR_RLBEN	0x0200
+#define QS6612_PCR_DCREN	0x0100
+#define QS6612_PCR_4B5BEN	0x0040
+#define QS6612_PCR_TX_ISOLATE	0x0020
+#define QS6612_PCR_OPMODE_MASK	0x001c
+#define QS6612_PCR_MLT3_DIS	0x0002
+#define QS6612_PCR_SCRM_DESCRM	0x0001
+
+enum qs6612_opmode {
+	still_an=0,
+	up10_half,
+	up100_half,
+	repeater,
+	reserved,
+	up10_full,
+	up100_full,
+	isolate_noaneg
+};
+
+static int qs6612_read_status(struct phy_device *phydev)
+{
+	u16 status;
+	int err;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	/* If the link is up, read the speed and duplex */
+	/* If we aren't autonegotiating, assume speeds
+	 * are as set */
+	if (phydev->autoneg && phydev->link) {
+		status = phy_read(phydev, MII_QS6612_PCR);
+		switch((status >> 2) & QS6612_PCR_OPMODE_MASK) {
+			case up10_half:
+				phydev->speed = SPEED_10;
+				phydev->duplex = DUPLEX_HALF;
+				break;
+			case up100_half:
+				phydev->speed = SPEED_100;
+				phydev->duplex = DUPLEX_HALF;
+				break;
+			case up10_full:
+				phydev->speed = SPEED_10;
+				phydev->duplex = DUPLEX_FULL;
+				break;
+			case up100_full:
+				phydev->speed = SPEED_100;
+				phydev->duplex = DUPLEX_FULL;
+				break;
+			default:
+				/* Do nothing in the other states */
+				break;
+		}
+	}
+
+	return 0;
+}
+
+int qs6612_probe(struct phy_device *phydev)
+{
+	/* The PHY powers up isolated on the RPX,
+	 * so send a command to allow operation.
+	 * XXX - My docs indicate this should be 0x0940
+	 * ...or something.  The current value sets three
+	 * reserved bits, bit 11, which specifies it should be
+	 * set to one, bit 10, which specifies it should be set
+	 * to 0, and bit 7, which doesn't specify.  However, my
+	 * docs are preliminary, and I will leave it like this
+	 * until someone more knowledgable corrects me or it.
+	 * -- Andy Fleming
+	 */
+	phy_write(phydev, MII_QS6612_PCR, 0x0dc0);
+
+	return 0;
+}
+
+int qs6612_ack_interrupt(struct phy_device *phydev)
+{
+	phy_read(phydev, MII_QS6612_ISR);
+	phy_read(phydev, MII_BMSR);
+	phy_read(phydev, MII_EXPANSION);
+
+	return 0;
+}
+
+int qs6612_config_intr(struct phy_device *phydev)
+{
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		phy_write(phydev, MII_QS6612_IMR,
+				MII_QS6612_IMR_INIT);
+	else
+		phy_write(phydev, MII_QS6612_IMR, 0);
+
+	return 0;
+
+}
+
+static struct phy_driver qs6612_driver = {
+	.phy_id		= 0x00181440,
+	.name		= "QS6612",
+	.phy_id_mask	= 0xfffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.probe		= qs6612_probe,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= qs6612_read_status,
+	.ack_interrupt	= qs6612_ack_interrupt,
+	.config_intr	= qs6612_config_intr,
+};
+
+int __init qs6612_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&qs6612_driver);
+
+	return retval;
+}
+
+static void __exit qs6612_exit(void)
+{
+	phy_driver_unregister(&qs6612_driver);
+}
+
+module_init(qs6612_init);
+module_exit(qs6612_exit);
diff -Nru a/include/linux/phy.h b/include/linux/phy.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/linux/phy.h	2004-12-23 12:39:16 -06:00
@@ -0,0 +1,355 @@
+/*
+ * include/linux/phy.h
+ *
+ * Framework and drivers for configuring and reading different PHYs
+ * Based on code in sungem_phy.c and gianfar_phy.c
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#ifndef __PHY_H
+#define __PHY_H
+
+#include <linux/spinlock.h>
+#include <linux/device.h>
+
+/* 1000BT control (Marvell & BCM54xx at least) */
+#define MII_1000BASETCONTROL			0x09
+#define MII_1000BASETCONTROL_FULLDUPLEXCAP	0x0200
+#define MII_1000BASETCONTROL_HALFDUPLEXCAP	0x0100
+
+#define PHY_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
+				 SUPPORTED_10baseT_Full | \
+				 SUPPORTED_100baseT_Half | \
+				 SUPPORTED_100baseT_Full | \
+				 SUPPORTED_Autoneg | \
+				 SUPPORTED_TP | \
+				 SUPPORTED_MII)
+
+#define PHY_GBIT_FEATURES	(PHY_BASIC_FEATURES | \
+				 SUPPORTED_1000baseT_Half | \
+				 SUPPORTED_1000baseT_Full)
+
+#define PHY_HAS_INTERRUPT	0x00000001
+#define PHY_HAS_MAGICANEG	0x00000002
+
+#define MII_BUS_MAX 4
+
+
+#define PHY_INIT_TIMEOUT 100000
+#define PHY_STATE_TIME		1
+#define PHY_FORCE_TIMEOUT	10
+#define PHY_AN_TIMEOUT		10
+
+#define PHY_MAX_ADDR 32
+
+/* The Bus class for PHYs.  Devices which provide access to
+ * PHYs should register using this structure */
+struct mii_bus {
+	const char *name;
+	int id;
+	void *priv;
+	u16 (*read)(struct mii_bus *bus, int phy_id, int regnum);
+	void (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
+	int (*reset)(struct mii_bus *bus);
+
+	/* A lock to ensure that only one thing can read/write
+	 * the MDIO bus at a time */
+	spinlock_t mdio_lock;
+
+	struct device *dev;
+
+	/* list of all PHYs on bus */
+	struct phy_device *phy_map[PHY_MAX_ADDR];
+
+	/* Pointer to an array of interrupts, each PHY's
+	 * interrupt at the index matching its address */
+	int *irq;
+};
+
+#define PHY_INTERRUPT_DISABLED 0x0
+#define PHY_INTERRUPT_ENABLED 0x80000000
+
+/* PHY state machine states:
+ *
+ * DOWN: PHY device and driver are not ready for anything.  probe
+ * should be called if and only if the PHY is in this state,
+ * given that the PHY device exists.
+ * - PHY driver probe function will, depending on the PHY, set
+ * the state to STARTING or READY
+ *
+ * STARTING:  PHY device is coming up, and the ethernet driver is
+ * not ready.  PHY drivers may set this in the probe function.
+ * If they do, they are responsible for making sure the state is
+ * eventually set to indicate whether the PHY is UP or READY,
+ * depending on the state when the PHY is done starting up.
+ * - PHY driver will set the state to READY
+ * - start will set the state to PENDING
+ *
+ * READY: PHY is ready to send and receive packets, but the
+ * controller is not.  By default, PHYs which do not implement
+ * probe will be set to this state by phy_probe().  If the PHY
+ * driver knows the PHY is ready, and the PHY state is STARTING,
+ * then it sets this STATE.
+ * - start will set the state to UP
+ *
+ * PENDING: PHY device is coming up, but the ethernet driver is
+ * ready.  phy_start will set this state if the PHY state is
+ * STARTING.
+ * - PHY driver will set the state to UP when the PHY is ready
+ *
+ * UP: The PHY and attached device are ready to do work.
+ * Interrupts should be started here.
+ * - timer moves to AN
+ *
+ * AN: The PHY is currently negotiating the link state.  Link is
+ * therefore down for now.  phy_timer will set this state when it
+ * detects the state is UP.  config_aneg will set this state
+ * whenever called with phydev->autoneg set to AUTONEG_ENABLE.
+ * - If autonegotiation finishes, but there's no link, it sets
+ *   the state to NOLINK.
+ * - If aneg finishes with link, it sets the state to RUNNING,
+ *   and calls adjust_link
+ * - If autonegotiation did not finish after an arbitrary amount
+ *   of time, autonegotiation should be tried again if the PHY
+ *   supports "magic" autonegotiation (back to AN)
+ * - If it didn't finish, and no magic_aneg, move to FORCING.
+ *
+ * NOLINK: PHY is up, but not currently plugged in.
+ * - If the timer notes that the link comes back, we move to RUNNING
+ * - config_aneg moves to AN
+ * - phy_stop moves to HALTED
+ *
+ * FORCING: PHY is being configured with forced settings
+ * - if link is up, move to RUNNING
+ * - If link is down, we drop to the next highest setting, and
+ *   retry (FORCING) after a timeout
+ * - phy_stop moves to HALTED
+ *
+ * RUNNING: PHY is currently up, running, and possibly sending
+ * and/or receiving packets
+ * - timer will set CHANGELINK if we're polling (this ensures the
+ *   link state is polled every other cycle of this state machine,
+ *   which makes it every other second)
+ * - irq will set CHANGELINK
+ * - config_aneg will set AN
+ * - phy_stop moves to HALTED
+ *
+ * CHANGELINK: PHY experienced a change in link state
+ * - timer moves to RUNNING if link
+ * - timer moves to NOLINK if the link is down
+ * - phy_stop moves to HALTED
+ *
+ * HALTED: PHY is up, but no polling or interrupts are done.
+* Brings the link down.
+* - phy_start moves to RESUMING
+*
+* RESUMING: PHY was halted, but now wants to run again.
+* - If we are forcing, or aneg is done, timer moves to RUNNING
+* - If aneg is not done, timer moves to AN
+* - phy_stop moves to HALTED
+*/
+enum phy_state {
+	PHY_DOWN=0,
+	PHY_STARTING,
+	PHY_READY,
+	PHY_PENDING,
+	PHY_UP,
+	PHY_AN,
+	PHY_RUNNING,
+	PHY_NOLINK,
+	PHY_FORCING,
+	PHY_CHANGELINK,
+	PHY_HALTED,
+	PHY_RESUMING
+};
+
+/* phy_device: An instance of a PHY
+ *
+ * drv: Pointer to the driver for this PHY instance
+ * bus: Pointer to the bus this PHY is on
+ * dev: driver model device structure for this PHY
+ * phy_id: UID for this device found during discovery
+ * state: state of the PHY for management purposes
+ * addr: Bus address of PHY
+ * link_timeout: The number of timer firings to wait before the
+ * giving up on the current attempt at acquiring a link
+ * irq: IRQ number of the PHY's interrupt (-1 if none)
+ * phy_timer: The timer for handling the state machine
+ * phy_queue: A work_queue for the interrupt
+ * attached_dev: The attached enet driver's device instance ptr
+ * adjust_link: Callback for the enet controller to respond to
+ * changes in the link state.
+ * adjust_state: Callback for the enet driver to respond to
+ * changes in the state machine.
+ *
+ * speed, duplex, pause, supported, advertising, and
+ * autoneg are used like in mii_if_info
+ *
+ * interrupts currently only supports enabled or disabled,
+ * but could be changed in the future to support enabling
+ * and disabling specific interrupts
+ *
+ * Contains some infrastructure for polling and interrupt
+ * handling, as well as handling shifts in PHY hardware state
+ */
+struct phy_device {
+	/* Information about the PHY type */
+	/* And management functions */
+	struct phy_driver *drv;
+
+	struct mii_bus *bus;
+
+	struct device dev;
+
+	u32 phy_id;
+
+	enum phy_state state;
+
+	/* Bus address of the PHY (0-32) */
+	int addr;
+
+	/* forced speed & duplex (no autoneg)
+	 * partner speed & duplex & pause (autoneg)
+	 */
+	int speed;
+	int duplex;
+	int pause;
+
+	/* The most recently read link state */
+	int link;
+
+	/* Enabled Interrupts */
+	u32 interrupts;
+
+	/* Union of PHY and Attached devices' supported modes */
+	/* See mii.h for more info */
+	u32 supported;
+	u32 advertising;
+
+	int autoneg;
+
+	int link_timeout;
+
+	/* Interrupt number for this PHY
+	 * -1 means no interrupt */
+	int irq;
+
+	/* private data pointer */
+	/* For use by PHYs to maintain extra state */
+	void *priv;
+
+	/* Interrupt and Polling infrastructure */
+	struct work_struct phy_queue;
+	struct timer_list phy_timer;
+
+	spinlock_t lock;
+
+	struct device *attached_dev;
+
+	void (*adjust_link)(struct device *dev);
+
+	void (*adjust_state)(struct device *dev);
+};
+#define to_phy_device(d) container_of(d, struct phy_device, dev)
+
+/* struct phy_driver: Driver structure for a particular PHY type
+ *
+ * phy_id: The result of reading the UID registers of this PHY
+ *   type, and ANDing them with the phy_id_mask.  This driver
+ *   only works for PHYs with IDs which match this field
+ * name: The friendly name of this PHY type
+ * phy_id_mask: Defines the important bits of the phy_id
+ * features: A list of features (speed, duplex, etc) supported
+ *   by this PHY
+ * flags: A bitfield defining certain other features this PHY
+ *   supports (like interrupts)
+ *
+ * The drivers must implement config_aneg and read_status.  All
+ * other functions are optional. Note that none of these
+ * functions should be called from interrupt time.  The goal is
+ * for the bus read/write functions to be able to block when the
+ * bus transaction is happening, and be freed up by an interrupt
+ * (The MPC85xx has this ability, though it is not currently
+ * supported in the driver).
+ */
+struct phy_driver {
+	u32 phy_id;
+	char *name;
+	unsigned int phy_id_mask;
+	u32 features;
+	u32 flags;
+
+	/* Called to initialize the PHY */
+	int (*probe)(struct phy_device *phydev);
+
+	/* PHY Power Management */
+	int (*suspend)(struct phy_device *phydev);
+	int (*resume)(struct phy_device *phydev);
+
+	/* Configures the advertisement and resets
+	 * autonegotiation if phydev->autoneg is on,
+	 * forces the speed to the current settings in phydev
+	 * if phydev->autoneg is off */
+	int (*config_aneg)(struct phy_device *phydev);
+
+	/* Determines the negotiated speed and duplex */
+	int (*read_status)(struct phy_device *phydev);
+
+	/* Clears any pending interrupts */
+	int (*ack_interrupt)(struct phy_device *phydev);
+
+	/* Enables or disables interrupts */
+	int (*config_intr)(struct phy_device *phydev);
+
+	/* Clears up any memory if needed */
+	void (*remove)(struct phy_device *phydev);
+
+	struct device_driver driver;
+};
+#define to_phy_driver(d) container_of(d, struct phy_driver, driver)
+
+u16 phy_read(struct phy_device *phydev, u16 regnum);
+void phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+struct phy_device* get_phy_device(struct mii_bus *bus, uint addr);
+void phy_clear_interrupt(struct phy_device *phydev);
+void phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
+struct phy_device * phy_attach(struct device *dev, char *phy_id);
+struct phy_device * phy_connect(struct device *dev, char *phy_id,
+		void (*handler)(struct device *));
+void phy_disconnect(struct phy_device *phydev);
+void phy_detach(struct phy_device *phydev);
+void phy_start(struct phy_device *phydev);
+void phy_stop(struct phy_device *phydev);
+void phy_start_aneg(struct phy_device *phydev);
+int register_mdiobus(struct mii_bus *bus);
+void phy_change(void *data);
+void phy_timer(unsigned long data);
+void phy_sanitize_settings(struct phy_device *phydev);
+
+void genphy_config_advert(struct phy_device *phydev);
+void genphy_setup_forced(struct phy_device *phydev);
+void genphy_restart_aneg(struct phy_device *phydev);
+int gbit_config_aneg(struct phy_device *phydev);
+int genphy_config_aneg(struct phy_device *phydev);
+int genphy_update_link(struct phy_device *phydev);
+int genphy_read_status(struct phy_device *phydev);
+void phy_driver_unregister(struct phy_driver *drv);
+int phy_driver_register(struct phy_driver *new_driver);
+void phy_prepare_link(struct phy_device *phydev,
+		void (*adjust_link)(struct device *));
+void phy_start_machine(struct phy_device *phydev,
+		void (*handler)(struct device *));
+void phy_stop_machine(struct phy_device *phydev);
+
+extern struct bus_type mdio_bus_type;
+extern struct phy_driver genphy_driver;
+#endif /* __PHY_H */

--Apple-Mail-2-974361640
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed



On Dec 23, 2004, at 13:01, Andy Fleming wrote:

> Adds a Phy Abstraction Layer which allows ethernet controllers to 
> manage their PHYs without knowing the details of how the particular 
> PHY device operates.  This code steals heavily from BenH's  sungem 
> driver, and got some stuff out of Jason McMullan's patch.
>
> Primary features of the code:
> * Allows drivers to only use what they want (to a degree).  If you 
> want to handle it all yourself, but use some of the data structures 
> and functions, that's ok.  If you want to handle your own interrupts, 
> that's fine.  However, it also allows you to minimize PHY management 
> code.  See the gianfar driver patches (included for reference).
> * Integrates with current ethtool/mii defined fields.
> * Uses the driver model to manage binding PHY drivers to PHY devices, 
> and MDIO bus drivers to MDIO bus devices.
> * Doesn't affect drivers which don't use it.
--Apple-Mail-2-974361640--
