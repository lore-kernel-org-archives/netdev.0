From: Michal Bachraty <michal.bachraty@streamunlimited.com>
Subject: [PATCH] cpsw: Add support to read cpu MAC address
Date: Fri, 11 Jan 2013 16:15:02 +0100
Message-ID: <1357917302-32550-1-git-send-email-michal.bachraty@streamunlimited.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michal Bachraty <michal.bachraty@streamunlimited.com>,
 linux-doc@vger.kernel.org, netdev@vger.kernel.org,
 devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: grant.likely@secretlab.ca, rob.herring@calxeda.com, rob@landley.net,
 linux@arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

Signed-off-by: Michal Bachraty <michal.bachraty@streamunlimited.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |   10 +-
 arch/arm/boot/dts/am33xx.dtsi                  |    5 +-
 drivers/net/ethernet/ti/cpsw.c                 |  121 +++++++++++++++++++++---
 include/linux/platform_data/cpsw.h             |    8 ++
 4 files changed, 128 insertions(+), 16 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index dcaabe9..432122c 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -4,7 +4,7 @@ TI SoC Ethernet Switch Controller Device Tree Bindings
 Required properties:
 - compatible		: Should be "ti,cpsw"
 - reg			: physical base address and size of the cpsw
-			  registers map
+			  registers map and mac-address cpu config registers
 - interrupts		: property with a value describing the interrupt
 			  number
 - interrupt-parent	: The parent interrupt controller
@@ -25,17 +25,23 @@ Required properties:
 - slave_reg_ofs		: Specifies slave register offset
 - sliver_reg_ofs	: Specifies slave sliver register offset
 - phy_id		: Specifies slave phy id
-- mac-address		: Specifies slave MAC address
 
 Optional properties:
 - ti,hwmods		: Must be "cpgmac0"
 - no_bd_ram		: Must be 0 or 1
+- mac-address-source 	: Specifies source of MAC address ("user-defined-mac",
+			  "cpu-id0-mac", "cpu-id01-mac", "random-mac"). If not
+			  specified, "cpu-id0-mac" is selected
+- mac-address		: Specifies slave MAC address for "user-defined-mac"
+			  property value. When MAC address is not correct,
+			  "cpu-id01-mac" is selected
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
 Future plan is to migrate hwmod data base contents into device tree
 blob so that, all the required data will be used from device tree dts
 file.
+As default, MAC address is set from CPU (MAC_ID0 register)
 
 Examples:
 
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 47fb059..f4845a3 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -307,7 +307,8 @@
 			slaves = <1>;
 			reg = <0x4a100000 0x800
 				0x4a101200 0x100
-				0x4a101000 0x100>;
+				0x4a101000 0x100
+				0x44e10630 0x0C>;
 			#address-cells = <1>;
 			#size-cells = <1>;
 			interrupt-parent = <&intc>;
@@ -317,7 +318,7 @@
 			cpsw_emac0: slave@0 {
 				slave_reg_ofs = <0x208>;
 				sliver_reg_ofs = <0xd80>;
-				mac-address = [ 00 00 00 00 00 00 ];
+				mac-address-source = "cpu-id0-mac";
 			};
 
 			davinci_mdio: mdio@4a101000 {
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index fb1a692..b777116 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -184,6 +184,13 @@ struct cpsw_sliver_regs {
 	u32	rx_pri_map;
 };
 
+struct config_regs {
+	u32	mac_id0_lo;
+	u32	mac_id0_hi;
+	u32	mac_id1_lo;
+	u32	mac_id1_hi;
+};
+
 struct cpsw_slave {
 	struct cpsw_slave_regs __iomem	*regs;
 	struct cpsw_sliver_regs __iomem	*sliver;
@@ -199,12 +206,14 @@ struct cpsw_priv {
 	struct net_device		*ndev;
 	struct resource			*cpsw_res;
 	struct resource			*cpsw_ss_res;
+	struct resource			*conf_res;
 	struct napi_struct		napi;
 	struct device			*dev;
 	struct cpsw_platform_data	data;
 	struct cpsw_regs __iomem	*regs;
 	struct cpsw_ss_regs __iomem	*ss_regs;
 	struct cpsw_host_regs __iomem	*host_port_regs;
+	struct config_regs __iomem	*conf_regs;
 	u32				msg_enable;
 	struct net_device_stats		stats;
 	int				rx_packet_max;
@@ -363,6 +372,20 @@ static void cpsw_set_slave_mac(struct cpsw_slave *slave,
 	__raw_writel(mac_lo(priv->mac_addr), &slave->regs->sa_lo);
 }
 
+static void cpsw_get_cpu_id0_mac(struct cpsw_priv *priv)
+{
+	*((u32 *)priv->mac_addr) = __raw_readl(&priv->conf_regs->mac_id0_hi);
+	*((u16 *)(priv->mac_addr + 4)) = __raw_readw(
+						&priv->conf_regs->mac_id0_lo);
+}
+
+static void cpsw_get_cpu_id1_mac(struct cpsw_priv *priv)
+{
+	*((u32 *)priv->mac_addr) = __raw_readl(&priv->conf_regs->mac_id1_hi);
+	*((u16 *)(priv->mac_addr + 4)) = __raw_readw(
+						&priv->conf_regs->mac_id1_lo);
+}
+
 static void _cpsw_adjust_link(struct cpsw_slave *slave,
 			      struct cpsw_priv *priv, bool *link)
 {
@@ -831,6 +854,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		struct cpsw_slave_data *slave_data = data->slave_data + i;
 		const char *phy_id = NULL;
 		const void *mac_addr = NULL;
+		const char *source_mac;
 
 		if (of_property_read_string(slave_node, "phy_id", &phy_id)) {
 			pr_err("Missing slave[%d] phy_id property\n", i);
@@ -855,9 +879,39 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		}
 		slave_data->sliver_reg_ofs = prop;
 
+		/* set default mac address to CPU_ID0_MAC */
+		slave_data->mac_addr_source = CPU_ID0_MAC;
+
 		mac_addr = of_get_mac_address(slave_node);
-		if (mac_addr)
-			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
+		if (mac_addr) {
+			if (is_valid_ether_addr(mac_addr)) {
+				slave_data->mac_addr_source = USER_DEFINED_MAC;
+				memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
+			} else {
+				pr_info("Bad user defined MACID.Using CPU "\
+					 "MACID0\n");
+			}
+		}
+
+		source_mac = of_get_property(slave_node, "mac-address-source",
+					     NULL);
+
+		if (source_mac) {
+			if (!strcmp(source_mac, "user-defined-mac"))
+				slave_data->mac_addr_source = USER_DEFINED_MAC;
+			else if (!strcmp(source_mac, "cpu-id0-mac"))
+				slave_data->mac_addr_source = CPU_ID0_MAC;
+			else if (!strcmp(source_mac, "cpu-id1-mac"))
+				slave_data->mac_addr_source = CPU_ID1_MAC;
+			else if (!strcmp(source_mac, "random-mac"))
+				slave_data->mac_addr_source = RANDOM_MAC;
+			else {
+				pr_err("Slave[%d] Bad mac-address-source"\
+				"proprerty value\n", i);
+				ret = -EINVAL;
+				goto error_ret;
+			}
+		}
 
 		i++;
 	}
@@ -915,16 +969,6 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	}
 	data = &priv->data;
 
-	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
-		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
-		pr_info("Detected MACID = %pM", priv->mac_addr);
-	} else {
-		eth_random_addr(priv->mac_addr);
-		pr_info("Random MACID = %pM", priv->mac_addr);
-	}
-
-	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
-
 	priv->slaves = kzalloc(sizeof(struct cpsw_slave) * data->slaves,
 			       GFP_KERNEL);
 	if (!priv->slaves) {
@@ -986,6 +1030,54 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	}
 	priv->ss_regs = regs;
 
+	/* configuration register registering*/
+	priv->conf_res = platform_get_resource(pdev, IORESOURCE_MEM, 3);
+	if (!priv->conf_res) {
+		dev_err(priv->dev, "error getting i/o resource\n");
+		ret = -ENOENT;
+		goto clean_clk_ret;
+	}
+
+	if (!request_mem_region(priv->conf_res->start,
+			resource_size(priv->conf_res), ndev->name)) {
+		dev_err(priv->dev, "failed request i/o region\n");
+		ret = -ENXIO;
+		goto clean_clk_ret;
+	}
+
+	regs = ioremap(priv->conf_res->start,
+				resource_size(priv->conf_res));
+	if (!regs) {
+		dev_err(priv->dev, "unable to map i/o region\n");
+		goto clean_configuration_iores_ret;
+	}
+	priv->conf_regs = regs;
+
+	switch (data->slave_data[0].mac_addr_source) {
+	case USER_DEFINED_MAC:
+			/* read MAC adddress from DT*/
+			memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
+			pr_info("User defined MACID = %pM", priv->mac_addr);
+			break;
+	case CPU_ID0_MAC:
+			/* read MAC adddress from CPU MACID0*/
+			cpsw_get_cpu_id0_mac(priv);
+			pr_info("CPU MACID0 = %pM\n", priv->mac_addr);
+		break;
+	case CPU_ID1_MAC:
+			/* read MAC adddress from CPU MACID1*/
+			cpsw_get_cpu_id1_mac(priv);
+			pr_info("CPU MACID1 = %pM\n", priv->mac_addr);
+		break;
+	case RANDOM_MAC:
+			/* random MAC*/
+			eth_random_addr(priv->mac_addr);
+			pr_info("Random MACID = %pM\n", priv->mac_addr);
+		break;
+	}
+
+	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
+
 	for_each_slave(priv, cpsw_slave_init, priv);
 
 	memset(&dma_params, 0, sizeof(dma_params));
@@ -1099,6 +1191,9 @@ clean_dma_ret:
 	cpdma_ctlr_destroy(priv->dma);
 clean_iomap_ret:
 	iounmap(priv->regs);
+clean_configuration_iores_ret:
+	release_mem_region(priv->conf_res->start,
+			   resource_size(priv->conf_res));
 clean_cpsw_ss_iores_ret:
 	release_mem_region(priv->cpsw_ss_res->start,
 			   resource_size(priv->cpsw_ss_res));
@@ -1133,6 +1228,8 @@ static int __devexit cpsw_remove(struct platform_device *pdev)
 			   resource_size(priv->cpsw_res));
 	release_mem_region(priv->cpsw_ss_res->start,
 			   resource_size(priv->cpsw_ss_res));
+	release_mem_region(priv->conf_res->start,
+			   resource_size(priv->conf_res));
 	pm_runtime_disable(&pdev->dev);
 	clk_put(priv->clk);
 	kfree(priv->slaves);
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index c4e23d0..ef064b0 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -17,12 +17,20 @@
 
 #include <linux/if_ether.h>
 
+enum mac_address_source {
+	USER_DEFINED_MAC = 0,
+	CPU_ID0_MAC,
+	CPU_ID1_MAC,
+	RANDOM_MAC,
+};
+
 struct cpsw_slave_data {
 	u32		slave_reg_ofs;
 	u32		sliver_reg_ofs;
 	const char	*phy_id;
 	int		phy_if;
 	u8		mac_addr[ETH_ALEN];
+	enum mac_address_source mac_addr_source;
 };
 
 struct cpsw_platform_data {
-- 
1.7.9.5
