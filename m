From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/4] mv643xx_eth: get rid of static variables, allow multiple instances
Date: Wed, 19 Mar 2008 08:49:15 +0100
Message-ID: <20080319074915.GB5010@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47617 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765774AbYCSUR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:17:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move mv643xx_eth's static state (ethernet register block base address
and MII management interface spinlock) into a struct hanging off the
shared platform device.  This is necessary to support chips that
contain multiple mv643xx_eth silicon blocks.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.25-rc6/arch/powerpc/platforms/chrp/pegasos_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/arch/powerpc/platforms/chrp/pegasos_eth.c
+++ linux-2.6.25-rc6/arch/powerpc/platforms/chrp/pegasos_eth.c
@@ -58,7 +58,9 @@ static struct resource mv643xx_eth0_reso
 
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.shared		= &mv643xx_eth_shared_device,
 	.port_number	= 0,
+
 	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH0,
 	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
@@ -88,7 +90,9 @@ static struct resource mv643xx_eth1_reso
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.shared		= &mv643xx_eth_shared_device,
 	.port_number	= 1,
+
 	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH1,
 	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
Index: linux-2.6.25-rc6/arch/powerpc/sysdev/mv64x60_dev.c
===================================================================
--- linux-2.6.25-rc6.orig/arch/powerpc/sysdev/mv64x60_dev.c
+++ linux-2.6.25-rc6/arch/powerpc/sysdev/mv64x60_dev.c
@@ -203,51 +203,79 @@ error:
 }
 
 /*
+ * Bump up the following definition if someone develops a
+ * PowerPC platform that uses multiple mv64x60_eth blocks.
+ * Note that each block can support up to 3 ports.
+ */
+#define MV64X60_ETH_MAX_SHARED_DEVS 1
+
+/*
  * Create mv64x60_eth platform devices
  */
-static int __init eth_register_shared_pdev(struct device_node *np)
+static struct platform_device * __init eth_register_shared_pdev(struct device_node *np)
 {
+	struct pdev_map {
+		resource_size_t start;
+		struct platform_device *pdev;
+	};
+	static struct pdev_map pdev_map[MV64X60_ETH_MAX_SHARED_DEVS];
 	struct platform_device *pdev;
 	struct resource r[1];
 	int err;
-
-	np = of_get_parent(np);
-	if (!np)
-		return -ENODEV;
+	int i;
 
 	err = of_address_to_resource(np, 0, &r[0]);
-	of_node_put(np);
 	if (err)
-		return err;
+		return ERR_PTR(err);
+
+	for (i = 0; i < ARRAY_SIZE(pdev_map); i++) {
+		if (!pdev_map[i].pdev)
+			break;
+		if (pdev_map[i].start == r->start)
+			return pdev_map[i].pdev;	/* already registered */
+	}
+	if (i >= ARRAY_SIZE(pdev_map))
+		return ERR_PTR(-ENODEV);		/* no more room */
 
 	pdev = platform_device_register_simple(MV643XX_ETH_SHARED_NAME, 0,
 					       r, 1);
-	if (IS_ERR(pdev))
-		return PTR_ERR(pdev);
+	if (!IS_ERR(pdev)) {
+		pdev_map[i].start = r->start;
+		pdev_map[i].pdev = pdev;
+	}
 
-	return 0;
+	return pdev;
 }
 
 static int __init mv64x60_eth_device_setup(struct device_node *np, int id)
 {
+	static struct platform_device *shared_pdev;
 	struct resource r[1];
 	struct mv643xx_eth_platform_data pdata;
 	struct platform_device *pdev;
+	struct device_node *shared_np;
 	struct device_node *phy;
 	const u8 *mac_addr;
 	const int *prop;
 	const phandle *ph;
 	int err;
 
-	/* only register the shared platform device the first time through */
-	if (id == 0 && (err = eth_register_shared_pdev(np)))
-		return err;
+	shared_np = of_get_parent(np);
+	if (!shared_np)
+		return -ENODEV;
+
+	shared_pdev = eth_register_shared_pdev(shared_np);
+	of_node_put(shared_np);
+	if (IS_ERR(shared_pdev))
+		return PTR_ERR(shared_pdev);
 
 	memset(r, 0, sizeof(r));
 	of_irq_to_resource(np, 0, &r[0]);
 
 	memset(&pdata, 0, sizeof(pdata));
 
+	pdata.shared = shared_pdev;
+
 	prop = of_get_property(np, "block-index", NULL);
 	if (!prop)
 		return -ENODEV;
Index: linux-2.6.25-rc6/arch/ppc/syslib/mv64x60.c
===================================================================
--- linux-2.6.25-rc6.orig/arch/ppc/syslib/mv64x60.c
+++ linux-2.6.25-rc6/arch/ppc/syslib/mv64x60.c
@@ -341,6 +341,7 @@ static struct resource mv64x60_eth0_reso
 };
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.shared		= &mv64x60_eth_shared_device;
 	.port_number	= 0,
 };
 
@@ -366,6 +367,7 @@ static struct resource mv64x60_eth1_reso
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.shared		= &mv64x60_eth_shared_device;
 	.port_number	= 1,
 };
 
@@ -391,6 +393,7 @@ static struct resource mv64x60_eth2_reso
 };
 
 static struct mv643xx_eth_platform_data eth2_pd = {
+	.shared		= &mv64x60_eth_shared_device;
 	.port_number	= 2,
 };
 
Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -507,7 +507,15 @@ struct mv643xx_mib_counters {
 	u32 late_collision;
 };
 
+struct mv643xx_shared_private {
+	void __iomem *eth_base;
+
+	/* used to protect SMI_REG, which is shared across ports */
+	spinlock_t phy_lock;
+};
+
 struct mv643xx_private {
+	struct mv643xx_shared_private *shared;
 	int port_num;			/* User Ethernet port number	*/
 
 	u32 rx_sram_addr;		/* Base address of rx sram area */
@@ -614,19 +622,14 @@ static const struct ethtool_ops mv643xx_
 static char mv643xx_driver_name[] = "mv643xx_eth";
 static char mv643xx_driver_version[] = "1.0";
 
-static void __iomem *mv643xx_eth_base;
-
-/* used to protect SMI_REG, which is shared across ports */
-static DEFINE_SPINLOCK(mv643xx_eth_phy_lock);
-
 static inline u32 rdl(struct mv643xx_private *mp, int offset)
 {
-	return readl(mv643xx_eth_base + offset);
+	return readl(mp->shared->eth_base + offset);
 }
 
 static inline void wrl(struct mv643xx_private *mp, int offset, u32 data)
 {
-	writel(data, mv643xx_eth_base + offset);
+	writel(data, mp->shared->eth_base + offset);
 }
 
 /*
@@ -1827,6 +1830,11 @@ static int mv643xx_eth_probe(struct plat
 		return -ENODEV;
 	}
 
+	if (pd->shared == NULL) {
+		printk(KERN_ERR "No mv643xx_eth_platform_data->shared\n");
+		return -ENODEV;
+	}
+
 	dev = alloc_etherdev(sizeof(struct mv643xx_private));
 	if (!dev)
 		return -ENOMEM;
@@ -1877,6 +1885,7 @@ static int mv643xx_eth_probe(struct plat
 
 	spin_lock_init(&mp->lock);
 
+	mp->shared = platform_get_drvdata(pd->shared);
 	port_num = mp->port_num = pd->port_number;
 
 	/* set default config values */
@@ -1986,27 +1995,46 @@ static int mv643xx_eth_remove(struct pla
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
 	static int mv643xx_version_printed = 0;
+	struct mv643xx_shared_private *msp;
 	struct resource *res;
+	int ret;
 
 	if (!mv643xx_version_printed++)
 		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
 
+	ret = -EINVAL;
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (res == NULL)
-		return -ENODEV;
+		goto out;
 
-	mv643xx_eth_base = ioremap(res->start, res->end - res->start + 1);
-	if (mv643xx_eth_base == NULL)
-		return -ENOMEM;
+	ret = -ENOMEM;
+	msp = kmalloc(sizeof(*msp), GFP_KERNEL);
+	if (msp == NULL)
+		goto out;
+	memset(msp, 0, sizeof(*msp));
+
+	msp->eth_base = ioremap(res->start, res->end - res->start + 1);
+	if (msp->eth_base == NULL)
+		goto out_free;
+
+	spin_lock_init(&msp->phy_lock);
+
+	platform_set_drvdata(pdev, msp);
 
 	return 0;
 
+out_free:
+	kfree(msp);
+out:
+	return ret;
 }
 
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
-	iounmap(mv643xx_eth_base);
-	mv643xx_eth_base = NULL;
+	struct mv643xx_shared_private *msp = platform_get_drvdata(pdev);
+
+	iounmap(msp->eth_base);
+	kfree(msp);
 
 	return 0;
 }
@@ -2908,7 +2936,7 @@ static void eth_port_read_smi_reg(struct
 	int i;
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
+	spin_lock_irqsave(&mp->shared->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
 	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
@@ -2933,7 +2961,7 @@ static void eth_port_read_smi_reg(struct
 
 	*value = rdl(mp, SMI_REG) & 0xffff;
 out:
-	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
+	spin_unlock_irqrestore(&mp->shared->phy_lock, flags);
 }
 
 /*
@@ -2966,7 +2994,7 @@ static void eth_port_write_smi_reg(struc
 	phy_addr = ethernet_phy_get(mp);
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
+	spin_lock_irqsave(&mp->shared->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
 	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
@@ -2980,7 +3008,7 @@ static void eth_port_write_smi_reg(struc
 	wrl(mp, SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
 				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
 out:
-	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
+	spin_unlock_irqrestore(&mp->shared->phy_lock, flags);
 }
 
 /*
Index: linux-2.6.25-rc6/include/linux/mv643xx_eth.h
===================================================================
--- linux-2.6.25-rc6.orig/include/linux/mv643xx_eth.h
+++ linux-2.6.25-rc6/include/linux/mv643xx_eth.h
@@ -1,6 +1,7 @@
 /*
  * MV-643XX ethernet platform device data definition file.
  */
+
 #ifndef __LINUX_MV643XX_ETH_H
 #define __LINUX_MV643XX_ETH_H
 
@@ -13,7 +14,9 @@
 #define MV643XX_ETH_BASE_ADDR_ENABLE_REG	0x2290
 
 struct mv643xx_eth_platform_data {
+	struct platform_device	*shared;
 	int		port_number;
+
 	u16		force_phy_addr;	/* force override if phy_addr == 0 */
 	u16		phy_addr;
 

----
