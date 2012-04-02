From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH v2 3/8] net: Add device tree support to LPC32xx
Date: Mon,  2 Apr 2012 20:33:02 +0200
Message-ID: <1333391587-26290-4-git-send-email-stigge@antcom.de>
References: <1333391587-26290-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roland Stigge <stigge@antcom.de>
To: arm@kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-i2c@vger.kernel.org, linux-kernel@vger.kernel.org,
 w.sang@pengutronix.de, srinivas.bakki@nxp.com, kevin.wells@nxp.com,
 gregkh@linuxfoundation.org, netdev@vger.kernel.org,
 rtc-linux@googlegroups.com, a.zummo@towertech.it,
 linux-watchdog@vger.kernel.org, wim@iguana.be, jonsmirl@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1333391587-26290-1-git-send-email-stigge@antcom.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch adds device tree support for lpc_eth.c.

The runtime option for MII/RMII is solved via the "phy-mode" property, SRAM
("IRAM") usage for DMA can be chosen via "use-iram".

Signed-off-by: Roland Stigge <stigge@antcom.de>

---

 Applies to v3.4-rc1

 Documentation/devicetree/bindings/net/lpc-eth.txt |   24 ++++++
 drivers/net/ethernet/nxp/lpc_eth.c                |   77 +++++++++++++---------
 2 files changed, 70 insertions(+), 31 deletions(-)

--- /dev/null
+++ linux-2.6/Documentation/devicetree/bindings/net/lpc-eth.txt
@@ -0,0 +1,24 @@
+* NXP LPC32xx SoC Ethernet Controller
+
+Required properties:
+- compatible: Should be "nxp,lpc-eth"
+- reg: Address and length of the register set for the device
+- interrupts: Should contain ethernet controller interrupt
+
+Optional properties:
+- phy-mode: String, operation mode of the PHY interface.
+  Supported values are: "mii" (default), "rmii"
+- use-iram: Use LPC32xx internal SRAM (IRAM) for DMA buffering
+- local-mac-address : 6 bytes, mac address
+
+Example:
+
+	mac: ethernet@31060000 {
+		compatible = "nxp,lpc-eth";
+		reg = <0x31060000 0x1000>;
+		interrupt-parent = <&mic>;
+		interrupts = <29 0>;
+
+		phy-mode = "rmii";
+		use-iram;
+	};
--- linux-2.6.orig/drivers/net/ethernet/nxp/lpc_eth.c
+++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
@@ -340,27 +340,15 @@
  */
 #define LPC_POWERDOWN_MACAHB			(1 << 31)
 
-/* Upon the upcoming introduction of device tree usage in LPC32xx,
- * lpc_phy_interface_mode() and use_iram_for_net() will be extended with a
- * device parameter for access to device tree information at runtime, instead
- * of defining the values at compile time
- */
-static inline phy_interface_t lpc_phy_interface_mode(void)
+static phy_interface_t lpc_phy_interface_mode(struct device *dev)
 {
-#ifdef CONFIG_ARCH_LPC32XX_MII_SUPPORT
+	if (dev && dev->of_node) {
+		const char *mode = of_get_property(dev->of_node,
+						   "phy-mode", NULL);
+		if (mode && !strcmp(mode, "rmii"))
+			return PHY_INTERFACE_MODE_RMII;
+	}
 	return PHY_INTERFACE_MODE_MII;
-#else
-	return PHY_INTERFACE_MODE_RMII;
-#endif
-}
-
-static inline int use_iram_for_net(void)
-{
-#ifdef CONFIG_ARCH_LPC32XX_IRAM_FOR_NET
-	return 1;
-#else
-	return 0;
-#endif
 }
 
 /* Receive Status information word */
@@ -450,6 +438,7 @@ struct netdata_local {
 	int			speed;
 	int			duplex;
 	struct napi_struct	napi;
+	bool			use_iram;
 };
 
 /*
@@ -664,7 +653,7 @@ static void __lpc_eth_init(struct netdat
 	       LPC_ENET_CLRT(pldat->net_base));
 	writel(LPC_IPGR_LOAD_PART2(0x12), LPC_ENET_IPGR(pldat->net_base));
 
-	if (lpc_phy_interface_mode() == PHY_INTERFACE_MODE_MII)
+	if (lpc_phy_interface_mode(&pldat->pdev->dev) == PHY_INTERFACE_MODE_MII)
 		writel(LPC_COMMAND_PASSRUNTFRAME,
 		       LPC_ENET_COMMAND(pldat->net_base));
 	else {
@@ -804,12 +793,13 @@ static int lpc_mii_probe(struct net_devi
 	}
 
 	/* Attach to the PHY */
-	if (lpc_phy_interface_mode() == PHY_INTERFACE_MODE_MII)
+	if (lpc_phy_interface_mode(&pldat->pdev->dev) == PHY_INTERFACE_MODE_MII)
 		netdev_info(ndev, "using MII interface\n");
 	else
 		netdev_info(ndev, "using RMII interface\n");
 	phydev = phy_connect(ndev, dev_name(&phydev->dev),
-		&lpc_handle_link_change, 0, lpc_phy_interface_mode());
+			     &lpc_handle_link_change, 0,
+			     lpc_phy_interface_mode(&pldat->pdev->dev));
 
 	if (IS_ERR(phydev)) {
 		netdev_err(ndev, "Could not attach to PHY\n");
@@ -843,7 +833,7 @@ static int lpc_mii_init(struct netdata_l
 	}
 
 	/* Setup MII mode */
-	if (lpc_phy_interface_mode() == PHY_INTERFACE_MODE_MII)
+	if (lpc_phy_interface_mode(&pldat->pdev->dev) == PHY_INTERFACE_MODE_MII)
 		writel(LPC_COMMAND_PASSRUNTFRAME,
 		       LPC_ENET_COMMAND(pldat->net_base));
 	else {
@@ -1315,18 +1305,26 @@ static const struct net_device_ops lpc_n
 static int lpc_eth_drv_probe(struct platform_device *pdev)
 {
 	struct resource *res;
-	struct resource *dma_res;
 	struct net_device *ndev;
 	struct netdata_local *pldat;
 	struct phy_device *phydev;
 	dma_addr_t dma_handle;
 	int irq, ret;
+	u32 tmp;
+
+	/* Setup network interface for RMII mode */
+	tmp = __raw_readl(LPC32XX_CLKPWR_MACCLK_CTRL);
+	tmp &= ~LPC32XX_CLKPWR_MACCTRL_PINS_MSK;
+	if (lpc_phy_interface_mode(&pdev->dev) == PHY_INTERFACE_MODE_MII)
+		tmp |= LPC32XX_CLKPWR_MACCTRL_USE_MII_PINS;
+	else
+		tmp |= LPC32XX_CLKPWR_MACCTRL_USE_RMII_PINS;
+	__raw_writel(tmp, LPC32XX_CLKPWR_MACCLK_CTRL);
 
 	/* Get platform resources */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	dma_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	irq = platform_get_irq(pdev, 0);
-	if ((!res) || (!dma_res) || (irq < 0) || (irq >= NR_IRQS)) {
+	if ((!res) || (irq < 0) || (irq >= NR_IRQS)) {
 		dev_err(&pdev->dev, "error getting resources.\n");
 		ret = -ENXIO;
 		goto err_exit;
@@ -1348,6 +1346,12 @@ static int lpc_eth_drv_probe(struct plat
 
 	spin_lock_init(&pldat->lock);
 
+	if (pdev->dev.of_node && of_get_property(pdev->dev.of_node,
+						 "use-iram", NULL))
+		pldat->use_iram = true;
+	else
+		pldat->use_iram = false;
+
 	/* Save resources */
 	ndev->irq = irq;
 
@@ -1389,17 +1393,19 @@ static int lpc_eth_drv_probe(struct plat
 		sizeof(struct txrx_desc_t) + sizeof(struct rx_status_t));
 	pldat->dma_buff_base_v = 0;
 
-	if (use_iram_for_net()) {
-		dma_handle = dma_res->start;
+	if (pldat->use_iram) {
+		dma_handle = LPC32XX_IRAM_BASE;
 		if (pldat->dma_buff_size <= lpc32xx_return_iram_size())
 			pldat->dma_buff_base_v =
-				io_p2v(dma_res->start);
+				io_p2v(LPC32XX_IRAM_BASE);
 		else
 			netdev_err(ndev,
 				"IRAM not big enough for net buffers, using SDRAM instead.\n");
 	}
 
 	if (pldat->dma_buff_base_v == 0) {
+		pldat->pdev->dev.coherent_dma_mask = 0xFFFFFFFF;
+		pldat->pdev->dev.dma_mask = &pldat->pdev->dev.coherent_dma_mask;
 		pldat->dma_buff_size = PAGE_ALIGN(pldat->dma_buff_size);
 
 		/* Allocate a chunk of memory for the DMA ethernet buffers
@@ -1488,7 +1494,7 @@ err_out_unregister_netdev:
 	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(ndev);
 err_out_dma_unmap:
-	if (!use_iram_for_net() ||
+	if (!pldat->use_iram ||
 	    pldat->dma_buff_size > lpc32xx_return_iram_size())
 		dma_free_coherent(&pldat->pdev->dev, pldat->dma_buff_size,
 				  pldat->dma_buff_base_v,
@@ -1515,7 +1521,7 @@ static int lpc_eth_drv_remove(struct pla
 	unregister_netdev(ndev);
 	platform_set_drvdata(pdev, NULL);
 
-	if (!use_iram_for_net() ||
+	if (!pldat->use_iram ||
 	    pldat->dma_buff_size > lpc32xx_return_iram_size())
 		dma_free_coherent(&pldat->pdev->dev, pldat->dma_buff_size,
 				  pldat->dma_buff_base_v,
@@ -1584,6 +1590,14 @@ static int lpc_eth_drv_resume(struct pla
 }
 #endif
 
+#ifdef CONFIG_OF
+static const struct of_device_id lpc_eth_match[] = {
+	{ .compatible = "nxp,lpc-eth" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, lpc_eth_match);
+#endif
+
 static struct platform_driver lpc_eth_driver = {
 	.probe		= lpc_eth_drv_probe,
 	.remove		= __devexit_p(lpc_eth_drv_remove),
@@ -1593,6 +1607,7 @@ static struct platform_driver lpc_eth_dr
 #endif
 	.driver		= {
 		.name	= MODNAME,
+		.of_match_table = of_match_ptr(lpc_eth_match),
 	},
 };
