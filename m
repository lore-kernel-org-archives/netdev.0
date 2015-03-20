From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 2/5] net: netcp: use separate reg region for individual ethss modules
Date: Fri, 20 Mar 2015 16:11:22 -0400
Message-ID: <1426882285-4873-3-git-send-email-m-karicheri2@ti.com>
References: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>,
	WingMan Kwok <w-kwok2@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Christoph Jaeger <cj@linux.com>,
	Lokesh Vutla <lokeshvutla@ti.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:60085 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265AbbCTUL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 16:11:57 -0400
In-Reply-To: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethss has multiple modules within the sub system
 - switch sub system
 - sgmii
 - mdio
 - switch module

NetCP driver re-uses existing davinci mdio driver. It requires to
have its own register region to map the reg space. So restructure
the code to use separate reg region for the individual modules it
manages. Use range property to define register space of NetCP and
use reg property to define individual reg spaces. So MDIO will have
its own reg space to map. This is a pre-requisite to enable MDIO
driver for NetCP.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Mugunthan V N <mugunthanvnm@ti.com>
CC: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
CC: Grygorii Strashko <grygorii.strashko@ti.com>
CC: Christoph Jaeger <cj@linux.com>
CC: Lokesh Vutla <lokeshvutla@ti.com>
CC: Markus Pargmann <mpa@pengutronix.de>
CC: Kumar Gala <galak@codeaurora.org>
CC: Ian Campbell <ijc+devicetree@hellion.org.uk>
CC: Mark Rutland <mark.rutland@arm.com>
CC: Pawel Moll <pawel.moll@arm.com>
CC: Rob Herring <robh+dt@kernel.org>
---
 .../devicetree/bindings/net/keystone-netcp.txt     |   16 +--
 drivers/net/ethernet/ti/netcp_ethss.c              |  130 ++++++++++++++------
 2 files changed, 102 insertions(+), 44 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
index f9c0771..8368abd 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -49,6 +49,7 @@ Required properties:
 - compatible:	Should be "ti,netcp-1.0"
 - clocks:	phandle to the reference clocks for the subsystem.
 - dma-id:	Navigator packet dma instance id.
+- ranges:	address range of NetCP (includes, Ethernet SS, PA and SA)
 
 Optional properties:
 - reg:		register location and the size for the following register
@@ -66,8 +67,10 @@ Required properties:
 - label:	Must be "netcp-gbe" for 1Gb & "netcp-xgbe" for 10Gb.
 - reg:		register location and the size for the following register
 		regions in the specified order.
-		- subsystem registers
-		- serdes registers
+		- switch subsystem registers
+		- sgmii port3/4 module registers (only for NetCP 1.4)
+		- switch module registers
+		- serdes registers (only for 10G)
 - tx-channel:	the navigator packet dma channel name for tx.
 - tx-queue:	the navigator queue number associated with the tx dma channel.
 - interfaces:	specification for each of the switch port to be registered as a
@@ -120,14 +123,13 @@ Optional properties:
 
 Example binding:
 
-netcp: netcp@2090000 {
+netcp: netcp@2000000 {
 	reg = <0x2620110 0x8>;
 	reg-names = "efuse";
 	compatible = "ti,netcp-1.0";
 	#address-cells = <1>;
 	#size-cells = <1>;
-	ranges;
-
+	ranges  = <0 0x2000000 0xfffff>;
 	clocks = <&papllclk>, <&clkcpgmac>, <&chipclk12>;
 	dma-coherent;
 	/* big-endian; */
@@ -137,9 +139,9 @@ netcp: netcp@2090000 {
 		#address-cells = <1>;
 		#size-cells = <1>;
 		ranges;
-		gbe@0x2090000 {
+		gbe@90000 {
 			label = "netcp-gbe";
-			reg = <0x2090000 0xf00>;
+			reg = <0x90000 0x300>, <0x90400 0x400>, <0x90800 0x700>;
 			/* enable-ale; */
 			tx-queue = <648>;
 			tx-channel = <8>;
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 2be90a5..42592b8 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -40,15 +40,18 @@
 #define GBE_MODULE_NAME			"netcp-gbe"
 #define GBE_SS_VERSION_14		0x4ed21104
 
+#define GBE_SS_REG_INDEX		0
+#define GBE_SGMII34_REG_INDEX		1
+#define GBE_SM_REG_INDEX		2
+/* offset relative to base of GBE_SS_REG_INDEX */
 #define GBE13_SGMII_MODULE_OFFSET	0x100
-#define GBE13_SGMII34_MODULE_OFFSET	0x400
-#define GBE13_SWITCH_MODULE_OFFSET	0x800
-#define GBE13_HOST_PORT_OFFSET		0x834
-#define GBE13_SLAVE_PORT_OFFSET		0x860
-#define GBE13_EMAC_OFFSET		0x900
-#define GBE13_SLAVE_PORT2_OFFSET	0xa00
-#define GBE13_HW_STATS_OFFSET		0xb00
-#define GBE13_ALE_OFFSET		0xe00
+/* offset relative to base of GBE_SM_REG_INDEX */
+#define GBE13_HOST_PORT_OFFSET		0x34
+#define GBE13_SLAVE_PORT_OFFSET		0x60
+#define GBE13_EMAC_OFFSET		0x100
+#define GBE13_SLAVE_PORT2_OFFSET	0x200
+#define GBE13_HW_STATS_OFFSET		0x300
+#define GBE13_ALE_OFFSET		0x600
 #define GBE13_HOST_PORT_NUM		0
 #define GBE13_NUM_SLAVES		4
 #define GBE13_NUM_ALE_PORTS		(GBE13_NUM_SLAVES + 1)
@@ -58,14 +61,18 @@
 #define XGBE_MODULE_NAME		"netcp-xgbe"
 #define XGBE_SS_VERSION_10		0x4ee42100
 
-#define XGBE_SERDES_REG_INDEX		1
+#define XGBE_SS_REG_INDEX		0
+#define XGBE_SM_REG_INDEX		1
+#define XGBE_SERDES_REG_INDEX		2
+
+/* offset relative to base of XGBE_SS_REG_INDEX */
 #define XGBE10_SGMII_MODULE_OFFSET	0x100
-#define XGBE10_SWITCH_MODULE_OFFSET	0x1000
-#define XGBE10_HOST_PORT_OFFSET		0x1034
-#define XGBE10_SLAVE_PORT_OFFSET	0x1064
-#define XGBE10_EMAC_OFFSET		0x1400
-#define XGBE10_ALE_OFFSET		0x1700
-#define XGBE10_HW_STATS_OFFSET		0x1800
+/* offset relative to base of XGBE_SM_REG_INDEX */
+#define XGBE10_HOST_PORT_OFFSET		0x34
+#define XGBE10_SLAVE_PORT_OFFSET	0x64
+#define XGBE10_EMAC_OFFSET		0x400
+#define XGBE10_ALE_OFFSET		0x700
+#define XGBE10_HW_STATS_OFFSET		0x800
 #define XGBE10_HOST_PORT_NUM		0
 #define XGBE10_NUM_SLAVES		2
 #define XGBE10_NUM_ALE_PORTS		(XGBE10_NUM_SLAVES + 1)
@@ -1579,9 +1586,9 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 	else if (gbe_dev->ss_version == XGBE_SS_VERSION_10)
 		emac_reg_ofs = XGBE10_EMAC_OFFSET;
 
-	slave->port_regs = gbe_dev->ss_regs + port_reg_ofs +
+	slave->port_regs = gbe_dev->switch_regs + port_reg_ofs +
 				(0x30 * port_reg_num);
-	slave->emac_regs = gbe_dev->ss_regs + emac_reg_ofs +
+	slave->emac_regs = gbe_dev->switch_regs + emac_reg_ofs +
 				(0x40 * slave->slave_num);
 
 	if (gbe_dev->ss_version == GBE_SS_VERSION_14) {
@@ -1732,22 +1739,39 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 
 	ret = of_address_to_resource(node, 0, &res);
 	if (ret) {
-		dev_err(gbe_dev->dev, "Can't translate of node(%s) address for xgbe subsystem regs\n",
-			node->name);
+		dev_err(gbe_dev->dev,
+			"Can't xlate xgbe of node(%s) ss address at %d\n",
+			node->name, XGBE_SS_REG_INDEX);
 		return ret;
 	}
 
 	regs = devm_ioremap_resource(gbe_dev->dev, &res);
 	if (IS_ERR(regs)) {
-		dev_err(gbe_dev->dev, "Failed to map xgbe register base\n");
+		dev_err(gbe_dev->dev, "Failed to map xgbe ss register base\n");
 		return PTR_ERR(regs);
 	}
 	gbe_dev->ss_regs = regs;
 
+	ret = of_address_to_resource(node, XGBE_SM_REG_INDEX, &res);
+	if (ret) {
+		dev_err(gbe_dev->dev,
+			"Can't xlate xgbe of node(%s) sm address at %d\n",
+			node->name, XGBE_SM_REG_INDEX);
+		return ret;
+	}
+
+	regs = devm_ioremap_resource(gbe_dev->dev, &res);
+	if (IS_ERR(regs)) {
+		dev_err(gbe_dev->dev, "Failed to map xgbe sm register base\n");
+		return PTR_ERR(regs);
+	}
+	gbe_dev->switch_regs = regs;
+
 	ret = of_address_to_resource(node, XGBE_SERDES_REG_INDEX, &res);
 	if (ret) {
-		dev_err(gbe_dev->dev, "Can't translate of node(%s) address for xgbe serdes regs\n",
-			node->name);
+		dev_err(gbe_dev->dev,
+			"Can't xlate xgbe serdes of node(%s) address at %d\n",
+			node->name, XGBE_SERDES_REG_INDEX);
 		return ret;
 	}
 
@@ -1770,11 +1794,10 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->ss_version = XGBE_SS_VERSION_10;
 	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs +
 					XGBE10_SGMII_MODULE_OFFSET;
-	gbe_dev->switch_regs = gbe_dev->ss_regs + XGBE10_SWITCH_MODULE_OFFSET;
 	gbe_dev->host_port_regs = gbe_dev->ss_regs + XGBE10_HOST_PORT_OFFSET;
 
 	for (i = 0; i < XGBE10_NUM_HW_STATS_MOD; i++)
-		gbe_dev->hw_stats_regs[i] = gbe_dev->ss_regs +
+		gbe_dev->hw_stats_regs[i] = gbe_dev->switch_regs +
 			XGBE10_HW_STATS_OFFSET + (GBE_HW_STATS_REG_MAP_SZ * i);
 
 	gbe_dev->ale_reg = gbe_dev->ss_regs + XGBE10_ALE_OFFSET;
@@ -1809,10 +1832,11 @@ static int get_gbe_resource_version(struct gbe_priv *gbe_dev,
 	void __iomem *regs;
 	int ret;
 
-	ret = of_address_to_resource(node, 0, &res);
+	ret = of_address_to_resource(node, GBE_SS_REG_INDEX, &res);
 	if (ret) {
-		dev_err(gbe_dev->dev, "Can't translate of node(%s) address\n",
-			node->name);
+		dev_err(gbe_dev->dev,
+			"Can't translate of node(%s) of gbe ss address at %d\n",
+			node->name, GBE_SS_REG_INDEX);
 		return ret;
 	}
 
@@ -1829,8 +1853,41 @@ static int get_gbe_resource_version(struct gbe_priv *gbe_dev,
 static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 				struct device_node *node)
 {
+	struct resource res;
 	void __iomem *regs;
-	int i;
+	int i, ret;
+
+	ret = of_address_to_resource(node, GBE_SGMII34_REG_INDEX, &res);
+	if (ret) {
+		dev_err(gbe_dev->dev,
+			"Can't translate of gbe node(%s) address at index %d\n",
+			node->name, GBE_SGMII34_REG_INDEX);
+		return ret;
+	}
+
+	regs = devm_ioremap_resource(gbe_dev->dev, &res);
+	if (IS_ERR(regs)) {
+		dev_err(gbe_dev->dev,
+			"Failed to map gbe sgmii port34 register base\n");
+		return PTR_ERR(regs);
+	}
+	gbe_dev->sgmii_port34_regs = regs;
+
+	ret = of_address_to_resource(node, GBE_SM_REG_INDEX, &res);
+	if (ret) {
+		dev_err(gbe_dev->dev,
+			"Can't translate of gbe node(%s) address at index %d\n",
+			node->name, GBE_SM_REG_INDEX);
+		return ret;
+	}
+
+	regs = devm_ioremap_resource(gbe_dev->dev, &res);
+	if (IS_ERR(regs)) {
+		dev_err(gbe_dev->dev,
+			"Failed to map gbe switch module register base\n");
+		return PTR_ERR(regs);
+	}
+	gbe_dev->switch_regs = regs;
 
 	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
 					  GBE13_NUM_HW_STAT_ENTRIES *
@@ -1841,17 +1898,16 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 		return -ENOMEM;
 	}
 
-	regs = gbe_dev->ss_regs;
-	gbe_dev->sgmii_port_regs = regs + GBE13_SGMII_MODULE_OFFSET;
-	gbe_dev->sgmii_port34_regs = regs + GBE13_SGMII34_MODULE_OFFSET;
-	gbe_dev->switch_regs = regs + GBE13_SWITCH_MODULE_OFFSET;
-	gbe_dev->host_port_regs = regs + GBE13_HOST_PORT_OFFSET;
+	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs + GBE13_SGMII_MODULE_OFFSET;
+	gbe_dev->host_port_regs = gbe_dev->switch_regs + GBE13_HOST_PORT_OFFSET;
 
-	for (i = 0; i < GBE13_NUM_HW_STATS_MOD; i++)
-		gbe_dev->hw_stats_regs[i] = regs + GBE13_HW_STATS_OFFSET +
-				(GBE_HW_STATS_REG_MAP_SZ * i);
+	for (i = 0; i < GBE13_NUM_HW_STATS_MOD; i++) {
+		gbe_dev->hw_stats_regs[i] =
+			gbe_dev->switch_regs + GBE13_HW_STATS_OFFSET +
+			(GBE_HW_STATS_REG_MAP_SZ * i);
+	}
 
-	gbe_dev->ale_reg = regs + GBE13_ALE_OFFSET;
+	gbe_dev->ale_reg = gbe_dev->switch_regs + GBE13_ALE_OFFSET;
 	gbe_dev->ale_ports = GBE13_NUM_ALE_PORTS;
 	gbe_dev->host_port = GBE13_HOST_PORT_NUM;
 	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
-- 
1.7.9.5
