From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH V5 3/7] cpsw: simplify the setup of the register pointers
Date: Thu, 15 Nov 2012 00:37:56 +0530
Message-ID: <1352920080-6179-4-git-send-email-mugunthanvnm@ti.com>
References: <1352920080-6179-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1352920080-6179-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>

Instead of having a host of different register offsets in the device tree,
this patch simplifies the CPSW code by letting the driver set the proper
register offsets automatically, based on the CPSW version.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |   42 +----
 drivers/net/ethernet/ti/cpsw.c                 |  242 ++++++++++--------------
 include/linux/platform_data/cpsw.h             |   21 +--
 3 files changed, 108 insertions(+), 197 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 2214607..6ddd028 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -9,15 +9,7 @@ Required properties:
 			  number
 - interrupt-parent	: The parent interrupt controller
 - cpdma_channels 	: Specifies number of channels in CPDMA
-- host_port_no		: Specifies host port shift
-- cpdma_reg_ofs		: Specifies CPDMA submodule register offset
-- cpdma_sram_ofs	: Specifies CPDMA SRAM offset
-- ale_reg_ofs		: Specifies ALE submodule register offset
 - ale_entries		: Specifies No of entries ALE can hold
-- host_port_reg_ofs	: Specifies host port register offset
-- hw_stats_reg_ofs	: Specifies hardware statistics register offset
-- cpts_reg_ofs		: Specifies the offset of the CPTS registers
-- bd_ram_ofs		: Specifies internal desciptor RAM offset
 - bd_ram_size		: Specifies internal descriptor RAM size
 - rx_descs		: Specifies number of Rx descriptors
 - mac_control		: Specifies Default MAC control register content
@@ -26,8 +18,6 @@ Required properties:
 - cpts_active_slave	: Specifies the slave to use for time stamping
 - cpts_clock_mult	: Numerator to convert input clock ticks into nanoseconds
 - cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
-- slave_reg_ofs		: Specifies slave register offset
-- sliver_reg_ofs	: Specifies slave sliver register offset
 - phy_id		: Specifies slave phy id
 - mac-address		: Specifies slave MAC address
 
@@ -49,15 +39,7 @@ Examples:
 		interrupts = <55 0x4>;
 		interrupt-parent = <&intc>;
 		cpdma_channels = <8>;
-		host_port_no = <0>;
-		cpdma_reg_ofs = <0x800>;
-		cpdma_sram_ofs = <0xa00>;
-		ale_reg_ofs = <0xd00>;
 		ale_entries = <1024>;
-		host_port_reg_ofs = <0x108>;
-		hw_stats_reg_ofs = <0x900>;
-		cpts_reg_ofs = <0xc00>;
-		bd_ram_ofs = <0x2000>;
 		bd_ram_size = <0x2000>;
 		no_bd_ram = <0>;
 		rx_descs = <64>;
@@ -67,16 +49,12 @@ Examples:
 		cpts_clock_mult = <0x80000000>;
 		cpts_clock_shift = <29>;
 		cpsw_emac0: slave@0 {
-			slave_reg_ofs = <0x200>;
-			sliver_reg_ofs = <0xd80>;
-			phy_id = "davinci_mdio.16:00";
+			phy_id = <&davinci_mdio>, <0>;
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
 		cpsw_emac1: slave@1 {
-			slave_reg_ofs = <0x300>;
-			sliver_reg_ofs = <0xdc0>;
-			phy_id = "davinci_mdio.16:01";
+			phy_id = <&davinci_mdio>, <1>;
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
@@ -87,15 +65,7 @@ Examples:
 		compatible = "ti,cpsw";
 		ti,hwmods = "cpgmac0";
 		cpdma_channels = <8>;
-		host_port_no = <0>;
-		cpdma_reg_ofs = <0x800>;
-		cpdma_sram_ofs = <0xa00>;
-		ale_reg_ofs = <0xd00>;
 		ale_entries = <1024>;
-		host_port_reg_ofs = <0x108>;
-		hw_stats_reg_ofs = <0x900>;
-		cpts_reg_ofs = <0xc00>;
-		bd_ram_ofs = <0x2000>;
 		bd_ram_size = <0x2000>;
 		no_bd_ram = <0>;
 		rx_descs = <64>;
@@ -105,16 +75,12 @@ Examples:
 		cpts_clock_mult = <0x80000000>;
 		cpts_clock_shift = <29>;
 		cpsw_emac0: slave@0 {
-			slave_reg_ofs = <0x200>;
-			sliver_reg_ofs = <0xd80>;
-			phy_id = "davinci_mdio.16:00";
+			phy_id = <&davinci_mdio>, <0>;
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
 		cpsw_emac1: slave@1 {
-			slave_reg_ofs = <0x300>;
-			sliver_reg_ofs = <0xdc0>;
-			phy_id = "davinci_mdio.16:01";
+			phy_id = <&davinci_mdio>, <1>;
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 7007aba..0da9c75 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -80,6 +80,29 @@ do {								\
 
 #define CPSW_VERSION_1		0x19010a
 #define CPSW_VERSION_2		0x19010c
+
+#define HOST_PORT_NUM		0
+#define SLIVER_SIZE		0x40
+
+#define CPSW1_HOST_PORT_OFFSET	0x028
+#define CPSW1_SLAVE_OFFSET	0x050
+#define CPSW1_SLAVE_SIZE	0x040
+#define CPSW1_CPDMA_OFFSET	0x100
+#define CPSW1_STATERAM_OFFSET	0x200
+#define CPSW1_CPTS_OFFSET	0x500
+#define CPSW1_ALE_OFFSET	0x600
+#define CPSW1_SLIVER_OFFSET	0x700
+
+#define CPSW2_HOST_PORT_OFFSET	0x108
+#define CPSW2_SLAVE_OFFSET	0x200
+#define CPSW2_SLAVE_SIZE	0x100
+#define CPSW2_CPDMA_OFFSET	0x800
+#define CPSW2_STATERAM_OFFSET	0xa00
+#define CPSW2_CPTS_OFFSET	0xc00
+#define CPSW2_ALE_OFFSET	0xd00
+#define CPSW2_SLIVER_OFFSET	0xd80
+#define CPSW2_BD_OFFSET		0x2000
+
 #define CPDMA_RXTHRESH		0x0c0
 #define CPDMA_RXFREE		0x0e0
 #define CPDMA_TXHDP		0x00
@@ -87,21 +110,6 @@ do {								\
 #define CPDMA_TXCP		0x40
 #define CPDMA_RXCP		0x60
 
-#define cpsw_dma_regs(base, offset)		\
-	(void __iomem *)((base) + (offset))
-#define cpsw_dma_rxthresh(base, offset)		\
-	(void __iomem *)((base) + (offset) + CPDMA_RXTHRESH)
-#define cpsw_dma_rxfree(base, offset)		\
-	(void __iomem *)((base) + (offset) + CPDMA_RXFREE)
-#define cpsw_dma_txhdp(base, offset)		\
-	(void __iomem *)((base) + (offset) + CPDMA_TXHDP)
-#define cpsw_dma_rxhdp(base, offset)		\
-	(void __iomem *)((base) + (offset) + CPDMA_RXHDP)
-#define cpsw_dma_txcp(base, offset)		\
-	(void __iomem *)((base) + (offset) + CPDMA_TXCP)
-#define cpsw_dma_rxcp(base, offset)		\
-	(void __iomem *)((base) + (offset) + CPDMA_RXCP)
-
 #define CPSW_POLL_WEIGHT	64
 #define CPSW_MIN_PACKET_SIZE	60
 #define CPSW_MAX_PACKET_SIZE	(1500 + 14 + 4 + 4)
@@ -629,8 +637,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 
 	pm_runtime_get_sync(&priv->pdev->dev);
 
-	reg = __raw_readl(&priv->regs->id_ver);
-	priv->version = reg;
+	reg = priv->version;
 
 	dev_info(priv->dev, "initializing cpsw version %d.%d (%d)\n",
 		 CPSW_MAJOR_VERSION(reg), CPSW_MINOR_VERSION(reg),
@@ -995,15 +1002,16 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_ts_info	= cpsw_get_ts_info,
 };
 
-static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv)
+static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
+			    u32 slave_reg_ofs, u32 sliver_reg_ofs)
 {
 	void __iomem		*regs = priv->regs;
 	int			slave_num = slave->slave_num;
 	struct cpsw_slave_data	*data = priv->data.slave_data + slave_num;
 
 	slave->data	= data;
-	slave->regs	= regs + data->slave_reg_ofs;
-	slave->sliver	= regs + data->sliver_reg_ofs;
+	slave->regs	= regs + slave_reg_ofs;
+	slave->sliver	= regs + sliver_reg_ofs;
 }
 
 static int cpsw_probe_dt(struct cpsw_platform_data *data,
@@ -1051,8 +1059,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		return -EINVAL;
 	}
 
-	data->no_bd_ram = of_property_read_bool(node, "no_bd_ram");
-
 	if (of_property_read_u32(node, "cpdma_channels", &prop)) {
 		pr_err("Missing cpdma_channels property in the DT.\n");
 		ret = -EINVAL;
@@ -1060,34 +1066,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->channels = prop;
 
-	if (of_property_read_u32(node, "host_port_no", &prop)) {
-		pr_err("Missing host_port_no property in the DT.\n");
-		ret = -EINVAL;
-		goto error_ret;
-	}
-	data->host_port_num = prop;
-
-	if (of_property_read_u32(node, "cpdma_reg_ofs", &prop)) {
-		pr_err("Missing cpdma_reg_ofs property in the DT.\n");
-		ret = -EINVAL;
-		goto error_ret;
-	}
-	data->cpdma_reg_ofs = prop;
-
-	if (of_property_read_u32(node, "cpdma_sram_ofs", &prop)) {
-		pr_err("Missing cpdma_sram_ofs property in the DT.\n");
-		ret = -EINVAL;
-		goto error_ret;
-	}
-	data->cpdma_sram_ofs = prop;
-
-	if (of_property_read_u32(node, "ale_reg_ofs", &prop)) {
-		pr_err("Missing ale_reg_ofs property in the DT.\n");
-		ret = -EINVAL;
-		goto error_ret;
-	}
-	data->ale_reg_ofs = prop;
-
 	if (of_property_read_u32(node, "ale_entries", &prop)) {
 		pr_err("Missing ale_entries property in the DT.\n");
 		ret = -EINVAL;
@@ -1095,34 +1073,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->ale_entries = prop;
 
-	if (of_property_read_u32(node, "host_port_reg_ofs", &prop)) {
-		pr_err("Missing host_port_reg_ofs property in the DT.\n");
-		ret = -EINVAL;
-		goto error_ret;
-	}
-	data->host_port_reg_ofs = prop;
-
-	if (of_property_read_u32(node, "hw_stats_reg_ofs", &prop)) {
-		pr_err("Missing hw_stats_reg_ofs property in the DT.\n");
-		ret = -EINVAL;
-		goto error_ret;
-	}
-	data->hw_stats_reg_ofs = prop;
-
-	if (of_property_read_u32(node, "cpts_reg_ofs", &prop)) {
-		pr_err("Missing cpts_reg_ofs property in the DT.\n");
-		ret = -EINVAL;
-		goto error_ret;
-	}
-	data->cpts_reg_ofs = prop;
-
-	if (of_property_read_u32(node, "bd_ram_ofs", &prop)) {
-		pr_err("Missing bd_ram_ofs property in the DT.\n");
-		ret = -EINVAL;
-		goto error_ret;
-	}
-	data->bd_ram_ofs = prop;
-
 	if (of_property_read_u32(node, "bd_ram_size", &prop)) {
 		pr_err("Missing bd_ram_size property in the DT.\n");
 		ret = -EINVAL;
@@ -1144,33 +1094,34 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->mac_control = prop;
 
+	/*
+	 * Populate all the child nodes here...
+	 */
+	ret = of_platform_populate(node, NULL, NULL, &pdev->dev);
+	/* We do not want to force this, as in some cases may not have child */
+	if (ret)
+		pr_warn("Doesn't have any child node\n");
+
 	for_each_node_by_name(slave_node, "slave") {
 		struct cpsw_slave_data *slave_data = data->slave_data + i;
-		const char *phy_id = NULL;
 		const void *mac_addr = NULL;
-
-		if (of_property_read_string(slave_node, "phy_id", &phy_id)) {
+		u32 phyid;
+		int lenp;
+		const __be32 *parp;
+		struct device_node *mdio_node;
+		struct platform_device *mdio;
+
+		parp = of_get_property(slave_node, "phy_id", &lenp);
+		if ((parp == NULL) && (lenp != (sizeof(void *) * 2))) {
 			pr_err("Missing slave[%d] phy_id property\n", i);
 			ret = -EINVAL;
 			goto error_ret;
 		}
-		slave_data->phy_id = phy_id;
-
-		if (of_property_read_u32(slave_node, "slave_reg_ofs", &prop)) {
-			pr_err("Missing slave[%d] slave_reg_ofs property\n", i);
-			ret = -EINVAL;
-			goto error_ret;
-		}
-		slave_data->slave_reg_ofs = prop;
-
-		if (of_property_read_u32(slave_node, "sliver_reg_ofs",
-					 &prop)) {
-			pr_err("Missing slave[%d] sliver_reg_ofs property\n",
-				i);
-			ret = -EINVAL;
-			goto error_ret;
-		}
-		slave_data->sliver_reg_ofs = prop;
+		mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
+		phyid = be32_to_cpup(parp+1);
+		mdio = of_find_device_by_node(mdio_node);
+		snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
+			 PHY_ID_FMT, mdio->name, phyid);
 
 		mac_addr = of_get_mac_address(slave_node);
 		if (mac_addr)
@@ -1179,14 +1130,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		i++;
 	}
 
-	/*
-	 * Populate all the child nodes here...
-	 */
-	ret = of_platform_populate(node, NULL, NULL, &pdev->dev);
-	/* We do not want to force this, as in some cases may not have child */
-	if (ret)
-		pr_warn("Doesn't have any child node\n");
-
 	return 0;
 
 error_ret:
@@ -1201,8 +1144,9 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	struct cpsw_priv		*priv;
 	struct cpdma_params		dma_params;
 	struct cpsw_ale_params		ale_params;
-	void __iomem			*regs;
+	void __iomem			*ss_regs, *wr_regs;
 	struct resource			*res;
+	u32 slave_offset, sliver_offset, slave_size;
 	int ret = 0, i, k = 0;
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
@@ -1270,15 +1214,14 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 		ret = -ENXIO;
 		goto clean_clk_ret;
 	}
-	regs = ioremap(priv->cpsw_res->start, resource_size(priv->cpsw_res));
-	if (!regs) {
+	ss_regs = ioremap(priv->cpsw_res->start, resource_size(priv->cpsw_res));
+	if (!ss_regs) {
 		dev_err(priv->dev, "unable to map i/o region\n");
 		goto clean_cpsw_iores_ret;
 	}
-	priv->regs = regs;
-	priv->host_port = data->host_port_num;
-	priv->host_port_regs = regs + data->host_port_reg_ofs;
-	priv->cpts.reg = regs + data->cpts_reg_ofs;
+	priv->regs = ss_regs;
+	priv->version = __raw_readl(&priv->regs->id_ver);
+	priv->host_port = HOST_PORT_NUM;
 
 	priv->cpsw_wr_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	if (!priv->cpsw_wr_res) {
@@ -1292,32 +1235,59 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 		ret = -ENXIO;
 		goto clean_iomap_ret;
 	}
-	regs = ioremap(priv->cpsw_wr_res->start,
+	wr_regs = ioremap(priv->cpsw_wr_res->start,
 				resource_size(priv->cpsw_wr_res));
-	if (!regs) {
+	if (!wr_regs) {
 		dev_err(priv->dev, "unable to map i/o region\n");
 		goto clean_cpsw_wr_iores_ret;
 	}
-	priv->wr_regs = regs;
-
-	for_each_slave(priv, cpsw_slave_init, priv);
+	priv->wr_regs = wr_regs;
 
 	memset(&dma_params, 0, sizeof(dma_params));
+	memset(&ale_params, 0, sizeof(ale_params));
+
+	switch (priv->version) {
+	case CPSW_VERSION_1:
+		priv->host_port_regs = ss_regs + CPSW1_HOST_PORT_OFFSET;
+		priv->cpts.reg       = ss_regs + CPSW1_CPTS_OFFSET;
+		dma_params.dmaregs   = ss_regs + CPSW1_CPDMA_OFFSET;
+		dma_params.txhdp     = ss_regs + CPSW1_STATERAM_OFFSET;
+		ale_params.ale_regs  = ss_regs + CPSW1_ALE_OFFSET;
+		slave_offset         = CPSW1_SLAVE_OFFSET;
+		slave_size           = CPSW1_SLAVE_SIZE;
+		sliver_offset        = CPSW1_SLIVER_OFFSET;
+		dma_params.desc_mem_phys = 0;
+		break;
+	case CPSW_VERSION_2:
+		priv->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
+		priv->cpts.reg       = ss_regs + CPSW2_CPTS_OFFSET;
+		dma_params.dmaregs   = ss_regs + CPSW2_CPDMA_OFFSET;
+		dma_params.txhdp     = ss_regs + CPSW2_STATERAM_OFFSET;
+		ale_params.ale_regs  = ss_regs + CPSW2_ALE_OFFSET;
+		slave_offset         = CPSW2_SLAVE_OFFSET;
+		slave_size           = CPSW2_SLAVE_SIZE;
+		sliver_offset        = CPSW2_SLIVER_OFFSET;
+		dma_params.desc_mem_phys =
+			(u32 __force) priv->cpsw_res->start + CPSW2_BD_OFFSET;
+		break;
+	default:
+		dev_err(priv->dev, "unknown version 0x%08x\n", priv->version);
+		ret = -ENODEV;
+		goto clean_cpsw_wr_iores_ret;
+	}
+	for (i = 0; i < priv->data.slaves; i++) {
+		struct cpsw_slave *slave = &priv->slaves[i];
+		cpsw_slave_init(slave, priv, slave_offset, sliver_offset);
+		slave_offset  += slave_size;
+		sliver_offset += SLIVER_SIZE;
+	}
+
 	dma_params.dev		= &pdev->dev;
-	dma_params.dmaregs	= cpsw_dma_regs((u32)priv->regs,
-						data->cpdma_reg_ofs);
-	dma_params.rxthresh	= cpsw_dma_rxthresh((u32)priv->regs,
-						    data->cpdma_reg_ofs);
-	dma_params.rxfree	= cpsw_dma_rxfree((u32)priv->regs,
-						  data->cpdma_reg_ofs);
-	dma_params.txhdp	= cpsw_dma_txhdp((u32)priv->regs,
-						 data->cpdma_sram_ofs);
-	dma_params.rxhdp	= cpsw_dma_rxhdp((u32)priv->regs,
-						 data->cpdma_sram_ofs);
-	dma_params.txcp		= cpsw_dma_txcp((u32)priv->regs,
-						data->cpdma_sram_ofs);
-	dma_params.rxcp		= cpsw_dma_rxcp((u32)priv->regs,
-						data->cpdma_sram_ofs);
+	dma_params.rxthresh	= dma_params.dmaregs + CPDMA_RXTHRESH;
+	dma_params.rxfree	= dma_params.dmaregs + CPDMA_RXFREE;
+	dma_params.rxhdp	= dma_params.txhdp + CPDMA_RXHDP;
+	dma_params.txcp		= dma_params.txhdp + CPDMA_TXCP;
+	dma_params.rxcp		= dma_params.txhdp + CPDMA_RXCP;
 
 	dma_params.num_chan		= data->channels;
 	dma_params.has_soft_reset	= true;
@@ -1325,10 +1295,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	dma_params.desc_mem_size	= data->bd_ram_size;
 	dma_params.desc_align		= 16;
 	dma_params.has_ext_regs		= true;
-	dma_params.desc_mem_phys        = data->no_bd_ram ? 0 :
-			(u32 __force)priv->cpsw_res->start + data->bd_ram_ofs;
-	dma_params.desc_hw_addr         = data->hw_ram_addr ?
-			data->hw_ram_addr : dma_params.desc_mem_phys ;
+	dma_params.desc_hw_addr         = dma_params.desc_mem_phys;
 
 	priv->dma = cpdma_ctlr_create(&dma_params);
 	if (!priv->dma) {
@@ -1348,10 +1315,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 		goto clean_dma_ret;
 	}
 
-	memset(&ale_params, 0, sizeof(ale_params));
 	ale_params.dev			= &ndev->dev;
-	ale_params.ale_regs		= (void *)((u32)priv->regs) +
-						((u32)data->ale_reg_ofs);
 	ale_params.ale_ageout		= ale_ageout;
 	ale_params.ale_entries		= data->ale_entries;
 	ale_params.ale_ports		= data->slaves;
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index b5c16c3..24368a2 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -18,9 +18,7 @@
 #include <linux/if_ether.h>
 
 struct cpsw_slave_data {
-	u32		slave_reg_ofs;
-	u32		sliver_reg_ofs;
-	const char	*phy_id;
+	char		phy_id[MII_BUS_ID_SIZE];
 	int		phy_if;
 	u8		mac_addr[ETH_ALEN];
 };
@@ -28,31 +26,14 @@ struct cpsw_slave_data {
 struct cpsw_platform_data {
 	u32	ss_reg_ofs;	/* Subsystem control register offset */
 	u32	channels;	/* number of cpdma channels (symmetric) */
-	u32	cpdma_reg_ofs;	/* cpdma register offset */
-	u32	cpdma_sram_ofs;	/* cpdma sram offset */
-
 	u32	slaves;		/* number of slave cpgmac ports */
 	struct cpsw_slave_data	*slave_data;
 	u32	cpts_active_slave; /* time stamping slave */
 	u32	cpts_clock_mult;  /* convert input clock ticks to nanoseconds */
 	u32	cpts_clock_shift; /* convert input clock ticks to nanoseconds */
-
-	u32	ale_reg_ofs;	/* address lookup engine reg offset */
 	u32	ale_entries;	/* ale table size */
-
-	u32	host_port_reg_ofs; /* cpsw cpdma host port registers */
-	u32     host_port_num; /* The port number for the host port */
-
-	u32	hw_stats_reg_ofs;  /* cpsw hardware statistics counters */
-	u32	cpts_reg_ofs;      /* cpts registers */
-
-	u32	bd_ram_ofs;   /* embedded buffer descriptor RAM offset*/
 	u32	bd_ram_size;  /*buffer descriptor ram size */
-	u32	hw_ram_addr; /*if the HW address for BD RAM is different */
-	bool	no_bd_ram; /* no embedded BD ram*/
-
 	u32	rx_descs;	/* Number of Rx Descriptios */
-
 	u32	mac_control;	/* Mac control register */
 };
 
-- 
1.7.0.4

