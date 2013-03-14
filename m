From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/4 v2] mv643xx_eth: convert to use the Marvell Orion MDIO driver
Date: Thu, 14 Mar 2013 19:08:35 +0100
Message-ID: <1363284515-9865-5-git-send-email-florian@openwrt.org>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
 <1363284515-9865-1-git-send-email-florian@openwrt.org>
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Florian Fainelli <florian@openwrt.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:39245 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932979Ab3CNSMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 14:12:14 -0400
In-Reply-To: <1363284515-9865-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the Marvell MV643XX ethernet driver to use the
Marvell Orion MDIO driver. As a result, PowerPC and ARM platforms
registering the Marvell MV643XX ethernet driver are also updated to
register a Marvell Orion MDIO driver. This driver voluntarily overlaps
with the Marvell Ethernet shared registers because it will use a subset
of this shared register (shared_base + 0x4 - shared_base + 0x84). The
Ethernet driver is also updated to look up for a PHY device using the
Orion MDIO bus driver.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
Changes since v1:
- removed one too many mdio bus registration for Orion5x/Kirkwood

 arch/arm/plat-orion/common.c               |   97 +++++++++++----
 arch/powerpc/platforms/chrp/pegasos_eth.c  |   20 +++
 arch/powerpc/sysdev/mv64x60_dev.c          |   14 ++-
 drivers/net/ethernet/marvell/Kconfig       |    1 +
 drivers/net/ethernet/marvell/mv643xx_eth.c |  186 ++--------------------------
 include/linux/mv643xx_eth.h                |    1 -
 6 files changed, 117 insertions(+), 202 deletions(-)

diff --git a/arch/arm/plat-orion/common.c b/arch/arm/plat-orion/common.c
index 2d4b641..dc4345e 100644
--- a/arch/arm/plat-orion/common.c
+++ b/arch/arm/plat-orion/common.c
@@ -238,6 +238,7 @@ static __init void ge_complete(
 	struct mv643xx_eth_shared_platform_data *orion_ge_shared_data,
 	struct resource *orion_ge_resource, unsigned long irq,
 	struct platform_device *orion_ge_shared,
+	struct platform_device *orion_ge_mvmdio,
 	struct mv643xx_eth_platform_data *eth_data,
 	struct platform_device *orion_ge)
 {
@@ -247,6 +248,8 @@ static __init void ge_complete(
 	orion_ge->dev.platform_data = eth_data;
 
 	platform_device_register(orion_ge_shared);
+	if (orion_ge_mvmdio)
+		platform_device_register(orion_ge_mvmdio);
 	platform_device_register(orion_ge);
 }
 
@@ -258,8 +261,6 @@ struct mv643xx_eth_shared_platform_data orion_ge00_shared_data;
 static struct resource orion_ge00_shared_resources[] = {
 	{
 		.name	= "ge00 base",
-	}, {
-		.name	= "ge00 err irq",
 	},
 };
 
@@ -271,6 +272,19 @@ static struct platform_device orion_ge00_shared = {
 	},
 };
 
+static struct resource orion_ge00_mvmdio_resources[] = {
+	{
+		.name	= "ge00 mvmdio base",
+	}, {
+		.name	= "ge00 mvmdio irr irq",
+	},
+};
+
+static struct platform_device orion_ge00_mvmdio = {
+	.name		= "orion-mdio",
+	.id		= 0,
+};
+
 static struct resource orion_ge00_resources[] = {
 	{
 		.name	= "ge00 irq",
@@ -295,26 +309,25 @@ void __init orion_ge00_init(struct mv643xx_eth_platform_data *eth_data,
 			    unsigned int tx_csum_limit)
 {
 	fill_resources(&orion_ge00_shared, orion_ge00_shared_resources,
-		       mapbase + 0x2000, SZ_16K - 1, irq_err);
+		       mapbase + 0x2000, SZ_16K - 1, NO_IRQ);
+	fill_resources(&orion_ge00_mvmdio, orion_ge00_mvmdio_resources,
+			mapbase + 0x2004, 0x84 - 1, irq_err);
 	orion_ge00_shared_data.tx_csum_limit = tx_csum_limit;
 	ge_complete(&orion_ge00_shared_data,
 		    orion_ge00_resources, irq, &orion_ge00_shared,
+		    &orion_ge00_mvmdio,
 		    eth_data, &orion_ge00);
 }
 
 /*****************************************************************************
  * GE01
  ****************************************************************************/
-struct mv643xx_eth_shared_platform_data orion_ge01_shared_data = {
-	.shared_smi	= &orion_ge00_shared,
-};
+struct mv643xx_eth_shared_platform_data orion_ge01_shared_data;
 
 static struct resource orion_ge01_shared_resources[] = {
 	{
 		.name	= "ge01 base",
-	}, {
-		.name	= "ge01 err irq",
-	},
+	}
 };
 
 static struct platform_device orion_ge01_shared = {
@@ -325,6 +338,19 @@ static struct platform_device orion_ge01_shared = {
 	},
 };
 
+static struct resource orion_ge01_mvmdio_resources[] = {
+	{
+		.name	= "ge01 mdio base",
+	}, {
+		.name	= "ge01 mdio err irq",
+	},
+};
+
+static struct platform_device orion_ge01_mvmdio = {
+	.name		= "orion-mdio",
+	.id		= 1,
+};
+
 static struct resource orion_ge01_resources[] = {
 	{
 		.name	= "ge01 irq",
@@ -349,26 +375,25 @@ void __init orion_ge01_init(struct mv643xx_eth_platform_data *eth_data,
 			    unsigned int tx_csum_limit)
 {
 	fill_resources(&orion_ge01_shared, orion_ge01_shared_resources,
-		       mapbase + 0x2000, SZ_16K - 1, irq_err);
+		       mapbase + 0x2000, SZ_16K - 1, NO_IRQ);
+	fill_resources(&orion_ge01_mvmdio, orion_ge01_mvmdio_resources,
+			mapbase + 0x2004, 0x84 - 1, irq_err);
 	orion_ge01_shared_data.tx_csum_limit = tx_csum_limit;
 	ge_complete(&orion_ge01_shared_data,
 		    orion_ge01_resources, irq, &orion_ge01_shared,
+		    NULL,
 		    eth_data, &orion_ge01);
 }
 
 /*****************************************************************************
  * GE10
  ****************************************************************************/
-struct mv643xx_eth_shared_platform_data orion_ge10_shared_data = {
-	.shared_smi	= &orion_ge00_shared,
-};
+struct mv643xx_eth_shared_platform_data orion_ge10_shared_data;
 
 static struct resource orion_ge10_shared_resources[] = {
 	{
 		.name	= "ge10 base",
-	}, {
-		.name	= "ge10 err irq",
-	},
+	}
 };
 
 static struct platform_device orion_ge10_shared = {
@@ -379,6 +404,19 @@ static struct platform_device orion_ge10_shared = {
 	},
 };
 
+static struct resource orion_ge10_mvmdio_resources[] = {
+	{
+		.name	= "ge10 mvmdio base",
+	}, {
+		.name	= "ge10 mvmdio err irq",
+	},
+};
+
+static struct platform_device orion_ge10_mvmdio = {
+	.name		= "orion-mdio",
+	.id		= 1,
+};
+
 static struct resource orion_ge10_resources[] = {
 	{
 		.name	= "ge10 irq",
@@ -403,23 +441,22 @@ void __init orion_ge10_init(struct mv643xx_eth_platform_data *eth_data,
 {
 	fill_resources(&orion_ge10_shared, orion_ge10_shared_resources,
 		       mapbase + 0x2000, SZ_16K - 1, irq_err);
+	fill_resources(&orion_ge10_mvmdio, orion_ge10_mvmdio_resources,
+		       mapbase + 0x2004, 0x84 - 1, irq_err);
 	ge_complete(&orion_ge10_shared_data,
 		    orion_ge10_resources, irq, &orion_ge10_shared,
+		    &orion_ge10_mvmdio,
 		    eth_data, &orion_ge10);
 }
 
 /*****************************************************************************
  * GE11
  ****************************************************************************/
-struct mv643xx_eth_shared_platform_data orion_ge11_shared_data = {
-	.shared_smi	= &orion_ge00_shared,
-};
+struct mv643xx_eth_shared_platform_data orion_ge11_shared_data;
 
 static struct resource orion_ge11_shared_resources[] = {
 	{
 		.name	= "ge11 base",
-	}, {
-		.name	= "ge11 err irq",
 	},
 };
 
@@ -431,6 +468,19 @@ static struct platform_device orion_ge11_shared = {
 	},
 };
 
+static struct resource orion_ge11_mvmdio_resources[] = {
+	{
+		.name	= "ge11 mvmdio base",
+	}, {
+		.name	= "ge11 mvmdio err irq",
+	},
+};
+
+static struct platform_device orion_ge11_mvmdio = {
+	.name		= "orion-mdio",
+	.id		= 1,
+};
+
 static struct resource orion_ge11_resources[] = {
 	{
 		.name	= "ge11 irq",
@@ -454,9 +504,12 @@ void __init orion_ge11_init(struct mv643xx_eth_platform_data *eth_data,
 			    unsigned long irq_err)
 {
 	fill_resources(&orion_ge11_shared, orion_ge11_shared_resources,
-		       mapbase + 0x2000, SZ_16K - 1, irq_err);
+		       mapbase + 0x2000, SZ_16K - 1, NO_IRQ);
+	fill_resources(&orion_ge11_mvmdio, orion_ge11_mvmdio_resources,
+		       mapbase + 0x2004, 0x84 - 1, irq_err);
 	ge_complete(&orion_ge11_shared_data,
 		    orion_ge11_resources, irq, &orion_ge11_shared,
+		    NULL,
 		    eth_data, &orion_ge11);
 }
 
diff --git a/arch/powerpc/platforms/chrp/pegasos_eth.c b/arch/powerpc/platforms/chrp/pegasos_eth.c
index 039fc8e..a671508 100644
--- a/arch/powerpc/platforms/chrp/pegasos_eth.c
+++ b/arch/powerpc/platforms/chrp/pegasos_eth.c
@@ -47,6 +47,25 @@ static struct platform_device mv643xx_eth_shared_device = {
 	.resource	= mv643xx_eth_shared_resources,
 };
 
+/*
+ * The orion mdio driver only covers shared + 0x4 up to shared + 0x84 - 1
+ */
+static struct resource mv643xx_eth_mvmdio_resources[] = {
+	[0] = {
+		.name	= "ethernet mdio base",
+		.start	= 0xf1000000 + MV643XX_ETH_SHARED_REGS + 0x4,
+		.end	= 0xf1000000 + MV643XX_ETH_SHARED_REGS + 0x83,
+		.flags	= IORESOURCE_MEM,
+	},
+};
+
+static struct platform_device mv643xx_eth_mvmdio_device = {
+	.name		= "orion-mdio",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(mv643xx_eth_mvmdio_resources),
+	.resource	= mv643xx_eth_shared_resources,
+};
+
 static struct resource mv643xx_eth_port1_resources[] = {
 	[0] = {
 		.name	= "eth port1 irq",
@@ -82,6 +101,7 @@ static struct platform_device eth_port1_device = {
 
 static struct platform_device *mv643xx_eth_pd_devs[] __initdata = {
 	&mv643xx_eth_shared_device,
+	&mv643xx_eth_mvmdio_device,
 	&eth_port1_device,
 };
 
diff --git a/arch/powerpc/sysdev/mv64x60_dev.c b/arch/powerpc/sysdev/mv64x60_dev.c
index 0f6af41..630cea3 100644
--- a/arch/powerpc/sysdev/mv64x60_dev.c
+++ b/arch/powerpc/sysdev/mv64x60_dev.c
@@ -214,15 +214,25 @@ static struct platform_device * __init mv64x60_eth_register_shared_pdev(
 						struct device_node *np, int id)
 {
 	struct platform_device *pdev;
-	struct resource r[1];
+	struct resource r[2];
 	int err;
 
 	err = of_address_to_resource(np, 0, &r[0]);
 	if (err)
 		return ERR_PTR(err);
 
+	/* register an orion mdio bus driver */
+	r[1].start = r[0].start + 0x4;
+	r[1].end = r[0].start + 0x84 - 1;
+	r[1].flags = IORESOURCE_MEM;
+
+	pdev = platform_device_register_simple("orion-mdio", id, &r[1], 1);
+	if (!pdev)
+		return pdev;
+
 	pdev = platform_device_register_simple(MV643XX_ETH_SHARED_NAME, id,
-					       r, 1);
+					       &r[0], 1);
+
 	return pdev;
 }
 
diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index edfba93..df06061 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -23,6 +23,7 @@ config MV643XX_ETH
 	depends on (MV64X60 || PPC32 || PLAT_ORION) && INET
 	select INET_LRO
 	select PHYLIB
+	select MVMDIO
 	---help---
 	  This driver supports the gigabit ethernet MACs in the
 	  Marvell Discovery PPC/MIPS chipset family (MV643XX) and
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d1ecf4b..df04bee 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -69,14 +69,6 @@ static char mv643xx_eth_driver_version[] = "1.4";
  * Registers shared between all ports.
  */
 #define PHY_ADDR			0x0000
-#define SMI_REG				0x0004
-#define  SMI_BUSY			0x10000000
-#define  SMI_READ_VALID			0x08000000
-#define  SMI_OPCODE_READ		0x04000000
-#define  SMI_OPCODE_WRITE		0x00000000
-#define ERR_INT_CAUSE			0x0080
-#define  ERR_INT_SMI_DONE		0x00000010
-#define ERR_INT_MASK			0x0084
 #define WINDOW_BASE(w)			(0x0200 + ((w) << 3))
 #define WINDOW_SIZE(w)			(0x0204 + ((w) << 3))
 #define WINDOW_REMAP_HIGH(w)		(0x0280 + ((w) << 2))
@@ -266,25 +258,6 @@ struct mv643xx_eth_shared_private {
 	void __iomem *base;
 
 	/*
-	 * Points at the right SMI instance to use.
-	 */
-	struct mv643xx_eth_shared_private *smi;
-
-	/*
-	 * Provides access to local SMI interface.
-	 */
-	struct mii_bus *smi_bus;
-
-	/*
-	 * If we have access to the error interrupt pin (which is
-	 * somewhat misnamed as it not only reflects internal errors
-	 * but also reflects SMI completion), use that to wait for
-	 * SMI access completion instead of polling the SMI busy bit.
-	 */
-	int err_interrupt;
-	wait_queue_head_t smi_busy_wait;
-
-	/*
 	 * Per-port MBUS window access register value.
 	 */
 	u32 win_protect;
@@ -1122,97 +1095,6 @@ out_write:
 	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 }
 
-static irqreturn_t mv643xx_eth_err_irq(int irq, void *dev_id)
-{
-	struct mv643xx_eth_shared_private *msp = dev_id;
-
-	if (readl(msp->base + ERR_INT_CAUSE) & ERR_INT_SMI_DONE) {
-		writel(~ERR_INT_SMI_DONE, msp->base + ERR_INT_CAUSE);
-		wake_up(&msp->smi_busy_wait);
-		return IRQ_HANDLED;
-	}
-
-	return IRQ_NONE;
-}
-
-static int smi_is_done(struct mv643xx_eth_shared_private *msp)
-{
-	return !(readl(msp->base + SMI_REG) & SMI_BUSY);
-}
-
-static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
-{
-	if (msp->err_interrupt == NO_IRQ) {
-		int i;
-
-		for (i = 0; !smi_is_done(msp); i++) {
-			if (i == 10)
-				return -ETIMEDOUT;
-			msleep(10);
-		}
-
-		return 0;
-	}
-
-	if (!smi_is_done(msp)) {
-		wait_event_timeout(msp->smi_busy_wait, smi_is_done(msp),
-				   msecs_to_jiffies(100));
-		if (!smi_is_done(msp))
-			return -ETIMEDOUT;
-	}
-
-	return 0;
-}
-
-static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
-{
-	struct mv643xx_eth_shared_private *msp = bus->priv;
-	void __iomem *smi_reg = msp->base + SMI_REG;
-	int ret;
-
-	if (smi_wait_ready(msp)) {
-		pr_warn("SMI bus busy timeout\n");
-		return -ETIMEDOUT;
-	}
-
-	writel(SMI_OPCODE_READ | (reg << 21) | (addr << 16), smi_reg);
-
-	if (smi_wait_ready(msp)) {
-		pr_warn("SMI bus busy timeout\n");
-		return -ETIMEDOUT;
-	}
-
-	ret = readl(smi_reg);
-	if (!(ret & SMI_READ_VALID)) {
-		pr_warn("SMI bus read not valid\n");
-		return -ENODEV;
-	}
-
-	return ret & 0xffff;
-}
-
-static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
-{
-	struct mv643xx_eth_shared_private *msp = bus->priv;
-	void __iomem *smi_reg = msp->base + SMI_REG;
-
-	if (smi_wait_ready(msp)) {
-		pr_warn("SMI bus busy timeout\n");
-		return -ETIMEDOUT;
-	}
-
-	writel(SMI_OPCODE_WRITE | (reg << 21) |
-		(addr << 16) | (val & 0xffff), smi_reg);
-
-	if (smi_wait_ready(msp)) {
-		pr_warn("SMI bus busy timeout\n");
-		return -ETIMEDOUT;
-	}
-
-	return 0;
-}
-
-
 /* statistics ***************************************************************/
 static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *dev)
 {
@@ -2688,47 +2570,6 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 		goto out_free;
 
 	/*
-	 * Set up and register SMI bus.
-	 */
-	if (pd == NULL || pd->shared_smi == NULL) {
-		msp->smi_bus = mdiobus_alloc();
-		if (msp->smi_bus == NULL)
-			goto out_unmap;
-
-		msp->smi_bus->priv = msp;
-		msp->smi_bus->name = "mv643xx_eth smi";
-		msp->smi_bus->read = smi_bus_read;
-		msp->smi_bus->write = smi_bus_write,
-		snprintf(msp->smi_bus->id, MII_BUS_ID_SIZE, "%s-%d",
-			pdev->name, pdev->id);
-		msp->smi_bus->parent = &pdev->dev;
-		msp->smi_bus->phy_mask = 0xffffffff;
-		if (mdiobus_register(msp->smi_bus) < 0)
-			goto out_free_mii_bus;
-		msp->smi = msp;
-	} else {
-		msp->smi = platform_get_drvdata(pd->shared_smi);
-	}
-
-	msp->err_interrupt = NO_IRQ;
-	init_waitqueue_head(&msp->smi_busy_wait);
-
-	/*
-	 * Check whether the error interrupt is hooked up.
-	 */
-	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (res != NULL) {
-		int err;
-
-		err = request_irq(res->start, mv643xx_eth_err_irq,
-				  IRQF_SHARED, "mv643xx_eth", msp);
-		if (!err) {
-			writel(ERR_INT_SMI_DONE, msp->base + ERR_INT_MASK);
-			msp->err_interrupt = res->start;
-		}
-	}
-
-	/*
 	 * (Re-)program MBUS remapping windows if we are asked to.
 	 */
 	dram = mv_mbus_dram_info();
@@ -2743,10 +2584,6 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 
 	return 0;
 
-out_free_mii_bus:
-	mdiobus_free(msp->smi_bus);
-out_unmap:
-	iounmap(msp->base);
 out_free:
 	kfree(msp);
 out:
@@ -2756,14 +2593,7 @@ out:
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
 	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
-	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 
-	if (pd == NULL || pd->shared_smi == NULL) {
-		mdiobus_unregister(msp->smi_bus);
-		mdiobus_free(msp->smi_bus);
-	}
-	if (msp->err_interrupt != NO_IRQ)
-		free_irq(msp->err_interrupt, msp);
 	iounmap(msp->base);
 	kfree(msp);
 
@@ -2829,11 +2659,11 @@ static void set_params(struct mv643xx_eth_private *mp,
 static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
 				   int phy_addr)
 {
-	struct mii_bus *bus = mp->shared->smi->smi_bus;
 	struct phy_device *phydev;
 	int start;
 	int num;
 	int i;
+	char phy_id[MII_BUS_ID_SIZE + 3];
 
 	if (phy_addr == MV643XX_ETH_PHY_ADDR_DEFAULT) {
 		start = phy_addr_get(mp) & 0x1f;
@@ -2843,17 +2673,19 @@ static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
 		num = 1;
 	}
 
+	/* Attempt to connect to the PHY using orion-mdio */
 	phydev = NULL;
 	for (i = 0; i < num; i++) {
 		int addr = (start + i) & 0x1f;
 
-		if (bus->phy_map[addr] == NULL)
-			mdiobus_scan(bus, addr);
+		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
+				"orion-mdio-mii", addr);
 
-		if (phydev == NULL) {
-			phydev = bus->phy_map[addr];
-			if (phydev != NULL)
-				phy_addr_set(mp, addr);
+		phydev = phy_connect(mp->dev, phy_id, NULL,
+				PHY_INTERFACE_MODE_GMII);
+		if (!IS_ERR(phydev)) {
+			phy_addr_set(mp, addr);
+			break;
 		}
 	}
 
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 49258e0..141d395 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -19,7 +19,6 @@
 
 struct mv643xx_eth_shared_platform_data {
 	struct mbus_dram_target_info	*dram;
-	struct platform_device	*shared_smi;
 	/*
 	 * Max packet size for Tx IP/Layer 4 checksum, when set to 0, default
 	 * limit of 9KiB will be used.
-- 
1.7.10.4
