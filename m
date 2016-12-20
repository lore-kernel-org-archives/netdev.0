From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 01/10] net: netcp: ethss: add support of subsystem register region regmap
Date: Tue, 20 Dec 2016 17:09:44 -0500
Message-ID: <1482271793-7671-2-git-send-email-m-karicheri2@ti.com>
References: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <grygorii.strashko@ti.com>, <mugunthanvnm@ti.com>,
        <linux-kernel@vger.kernel.org>, <arnd@arndb.de>,
        <davem@davemloft.net>, <devicetree@vger.kernel.org>,
        <mark.rutland@arm.com>, <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2@ti.com>

10gbe phy driver needs to access the 10gbe subsystem control
register during phy initialization. To facilitate the shared
access of the subsystem register region between the 10gbe Ethernet
driver and the phy driver, this patch adds support of the
subsystem register region defined by a syscon node in the dts.

Although there is no shared access to the gbe subsystem register
region, using syscon for that is for the sake of consistency.

This change is backward compatible with previously released gbe
devicetree bindings.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 .../devicetree/bindings/net/keystone-netcp.txt     |  16 ++-
 drivers/net/ethernet/ti/netcp_ethss.c              | 140 +++++++++++++++++----
 2 files changed, 127 insertions(+), 29 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
index 04ba1dc..0854a73 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -72,20 +72,24 @@ Required properties:
 		"ti,netcp-gbe-2" for 1GbE N NetCP 1.5 (N=2)
 		"ti,netcp-xgbe" for 10 GbE
 
+- syscon-subsys:	phandle to syscon node of the switch
+			subsystem registers.
+
 - reg:		register location and the size for the following register
 		regions in the specified order.
 		- switch subsystem registers
+		- sgmii module registers
 		- sgmii port3/4 module registers (only for NetCP 1.4)
 		- switch module registers
 		- serdes registers (only for 10G)
 
 		NetCP 1.4 ethss, here is the order
-			index #0 - switch subsystem registers
+			index #0 - sgmii module registers
 			index #1 - sgmii port3/4 module registers
 			index #2 - switch module registers
 
 		NetCP 1.5 ethss 9 port, 5 port and 2 port
-			index #0 - switch subsystem registers
+			index #0 - sgmii module registers
 			index #1 - switch module registers
 			index #2 - serdes registers
 
@@ -145,6 +149,11 @@ Optional properties:
 
 Example binding:
 
+gbe_subsys: subsys@2090000 {
+	compatible = "syscon";
+	reg = <0x02090000 0x100>;
+};
+
 netcp: netcp@2000000 {
 	reg = <0x2620110 0x8>;
 	reg-names = "efuse";
@@ -163,7 +172,8 @@ netcp: netcp@2000000 {
 		ranges;
 		gbe@90000 {
 			label = "netcp-gbe";
-			reg = <0x90000 0x300>, <0x90400 0x400>, <0x90800 0x700>;
+			syscon-subsys = <&gbe_subsys>;
+			reg = <0x90100 0x200>, <0x90400 0x200>, <0x90800 0x700>;
 			/* enable-ale; */
 			tx-queue = <648>;
 			tx-channel = <8>;
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index c7e547e..473edda1 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -19,9 +19,11 @@
  */
 
 #include <linux/io.h>
+#include <linux/mfd/syscon.h>
 #include <linux/module.h>
 #include <linux/of_mdio.h>
 #include <linux/of_address.h>
+#include <linux/regmap.h>
 #include <linux/if_vlan.h>
 #include <linux/ptp_classify.h>
 #include <linux/net_tstamp.h>
@@ -43,7 +45,10 @@
 #define GBE_MODULE_NAME			"netcp-gbe"
 #define GBE_SS_VERSION_14		0x4ed21104
 
+/* for devicetree backward compatible only */
 #define GBE_SS_REG_INDEX		0
+
+#define GBE_SGMII_REG_INDEX		0
 #define GBE_SGMII34_REG_INDEX		1
 #define GBE_SM_REG_INDEX		2
 /* offset relative to base of GBE_SS_REG_INDEX */
@@ -71,9 +76,11 @@
 #define IS_SS_ID_NU(d) \
 	(GBE_IDENT((d)->ss_version) == GBE_SS_ID_NU)
 
-#define GBENU_SS_REG_INDEX		0
+#define GBENU_SGMII_REG_INDEX		0
 #define GBENU_SM_REG_INDEX		1
+/* offset relative to base of GBE_SS_REG_INDEX */
 #define GBENU_SGMII_MODULE_OFFSET	0x100
+/* offset relative to base of GBENU_SM_REG_INDEX */
 #define GBENU_HOST_PORT_OFFSET		0x1000
 #define GBENU_SLAVE_PORT_OFFSET		0x2000
 #define GBENU_EMAC_OFFSET		0x2330
@@ -82,13 +89,12 @@
 #define GBENU_ALE_OFFSET		0x1e000
 #define GBENU_HOST_PORT_NUM		0
 #define GBENU_NUM_ALE_ENTRIES		1024
-#define GBENU_SGMII_MODULE_SIZE		0x100
 
 /* 10G Ethernet SS defines */
 #define XGBE_MODULE_NAME		"netcp-xgbe"
 #define XGBE_SS_VERSION_10		0x4ee42100
 
-#define XGBE_SS_REG_INDEX		0
+#define XGBE_SGMII_REG_INDEX		0
 #define XGBE_SM_REG_INDEX		1
 #define XGBE_SERDES_REG_INDEX		2
 
@@ -173,6 +179,7 @@
 #define XGBE_SET_REG_OFS(p, rb, rn) p->rb##_ofs.rn = \
 		offsetof(struct xgbe##_##rb, rn)
 #define GBE_REG_ADDR(p, rb, rn) (p->rb + p->rb##_ofs.rn)
+#define GBE_REG_OFS(p, rb, rn) ((p)->rb##_ofs.rn)
 
 #define HOST_TX_PRI_MAP_DEFAULT			0x00000000
 
@@ -225,6 +232,7 @@
 /* The PTP event messages - Sync, Delay_Req, Pdelay_Req, and Pdelay_Resp. */
 #define EVENT_MSG_BITS (BIT(0) | BIT(1) | BIT(2) | BIT(3))
 #endif /* CONFIG_TI_CPTS */
+#define SGMII_MODULE_SIZE			0x100
 
 struct xgbe_ss_regs {
 	u32	id_ver;
@@ -716,7 +724,9 @@ struct gbe_priv {
 	u32				ss_version;
 	u32				stats_en_mask;
 
-	void __iomem			*ss_regs;
+	struct regmap			*ss_regmap;
+	struct regmap			*pcsr_regmap;
+	void __iomem                    *ss_regs;
 	void __iomem			*switch_regs;
 	void __iomem			*host_port_regs;
 	void __iomem			*ale_reg;
@@ -2192,7 +2202,7 @@ static void gbe_port_config(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 			    int max_rx_len)
 {
 	void __iomem *rx_maxlen_reg;
-	u32 xgmii_mode;
+	int ret;
 
 	if (max_rx_len > NETCP_MAX_FRAME_SIZE)
 		max_rx_len = NETCP_MAX_FRAME_SIZE;
@@ -2200,9 +2210,16 @@ static void gbe_port_config(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 	/* Enable correct MII mode at SS level */
 	if ((gbe_dev->ss_version == XGBE_SS_VERSION_10) &&
 	    (slave->link_interface >= XGMII_LINK_MAC_PHY)) {
-		xgmii_mode = readl(GBE_REG_ADDR(gbe_dev, ss_regs, control));
-		xgmii_mode |= (1 << slave->slave_num);
-		writel(xgmii_mode, GBE_REG_ADDR(gbe_dev, ss_regs, control));
+		ret = regmap_update_bits(gbe_dev->ss_regmap,
+					 GBE_REG_OFS(gbe_dev, ss_regs, control),
+					 1 << slave->slave_num,
+					 1 << slave->slave_num);
+
+		if (ret) {
+			dev_err(gbe_dev->dev,
+				"regmap update xgmii mode bit Failed\n");
+			return;
+		}
 	}
 
 	if (IS_SS_ID_MU(gbe_dev))
@@ -3127,35 +3144,46 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	void __iomem *regs;
 	int ret, i;
 
-	ret = of_address_to_resource(node, XGBE_SS_REG_INDEX, &res);
+	gbe_dev->ss_regmap = syscon_regmap_lookup_by_phandle(node,
+							     "syscon-subsys");
+
+	if (IS_ERR(gbe_dev->ss_regmap)) {
+		dev_err(gbe_dev->dev,
+			"subsys regmap lookup failed: %ld\n",
+			PTR_ERR(gbe_dev->ss_regmap));
+		return PTR_ERR(gbe_dev->ss_regmap);
+	}
+
+	ret = of_address_to_resource(node, XGBE_SM_REG_INDEX, &res);
 	if (ret) {
 		dev_err(gbe_dev->dev,
-			"Can't xlate xgbe of node(%s) ss address at %d\n",
-			node->name, XGBE_SS_REG_INDEX);
+			"Can't xlate xgbe of node(%s) sm address at %d\n",
+			node->name, XGBE_SM_REG_INDEX);
 		return ret;
 	}
 
 	regs = devm_ioremap_resource(gbe_dev->dev, &res);
 	if (IS_ERR(regs)) {
-		dev_err(gbe_dev->dev, "Failed to map xgbe ss register base\n");
+		dev_err(gbe_dev->dev, "Failed to map xgbe sm register base\n");
 		return PTR_ERR(regs);
 	}
-	gbe_dev->ss_regs = regs;
+	gbe_dev->switch_regs = regs;
 
-	ret = of_address_to_resource(node, XGBE_SM_REG_INDEX, &res);
+	ret = of_address_to_resource(node, XGBE_SGMII_REG_INDEX, &res);
 	if (ret) {
 		dev_err(gbe_dev->dev,
-			"Can't xlate xgbe of node(%s) sm address at %d\n",
-			node->name, XGBE_SM_REG_INDEX);
+			"Can't xlate xgbe of node(%s) sgmii address at %d\n",
+			node->name, XGBE_SGMII_REG_INDEX);
 		return ret;
 	}
 
 	regs = devm_ioremap_resource(gbe_dev->dev, &res);
 	if (IS_ERR(regs)) {
-		dev_err(gbe_dev->dev, "Failed to map xgbe sm register base\n");
+		dev_err(gbe_dev->dev,
+			"Failed to map xgbe sgmii register base\n");
 		return PTR_ERR(regs);
 	}
-	gbe_dev->switch_regs = regs;
+	gbe_dev->sgmii_port_regs = regs;
 
 	ret = of_address_to_resource(node, XGBE_SERDES_REG_INDEX, &res);
 	if (ret) {
@@ -3171,6 +3199,8 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 		return PTR_ERR(regs);
 	}
 	gbe_dev->xgbe_serdes_regs = regs;
+	gbe_dev->sgmii_port34_regs = gbe_dev->sgmii_port_regs +
+				     (2 * SGMII_MODULE_SIZE);
 
 	gbe_dev->num_stats_mods = gbe_dev->max_num_ports;
 	gbe_dev->et_stats = xgbe10_et_stats;
@@ -3195,9 +3225,9 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	}
 
 	gbe_dev->ss_version = XGBE_SS_VERSION_10;
-	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs +
-					XGBE10_SGMII_MODULE_OFFSET;
-	gbe_dev->host_port_regs = gbe_dev->ss_regs + XGBE10_HOST_PORT_OFFSET;
+
+	gbe_dev->host_port_regs = gbe_dev->switch_regs +
+					XGBE10_HOST_PORT_OFFSET;
 
 	for (i = 0; i < gbe_dev->max_num_ports; i++)
 		gbe_dev->hw_stats_regs[i] = gbe_dev->switch_regs +
@@ -3228,8 +3258,8 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	return 0;
 }
 
-static int get_gbe_resource_version(struct gbe_priv *gbe_dev,
-				    struct device_node *node)
+static int get_gbe_resource_version_ss_regs(struct gbe_priv *gbe_dev,
+					    struct device_node *node)
 {
 	struct resource res;
 	void __iomem *regs;
@@ -3248,8 +3278,27 @@ static int get_gbe_resource_version(struct gbe_priv *gbe_dev,
 		dev_err(gbe_dev->dev, "Failed to map gbe register base\n");
 		return PTR_ERR(regs);
 	}
+
 	gbe_dev->ss_regs = regs;
 	gbe_dev->ss_version = readl(gbe_dev->ss_regs);
+	gbe_dev->ss_regmap = NULL;
+	return 0;
+}
+
+static int get_gbe_resource_version(struct gbe_priv *gbe_dev,
+				    struct device_node *node)
+{
+	gbe_dev->ss_regmap = syscon_regmap_lookup_by_phandle(node,
+							     "syscon-subsys");
+	if (IS_ERR(gbe_dev->ss_regmap)) {
+		dev_dbg(gbe_dev->dev,
+			"subsys regmap lookup failed: %ld. try reg property\n",
+			PTR_ERR(gbe_dev->ss_regmap));
+		return get_gbe_resource_version_ss_regs(gbe_dev, node);
+	}
+
+	regmap_read(gbe_dev->ss_regmap, 0, &gbe_dev->ss_version);
+	gbe_dev->ss_regs = NULL;
 	return 0;
 }
 
@@ -3260,6 +3309,27 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 	void __iomem *regs;
 	int i, ret;
 
+	if (gbe_dev->ss_regs) {
+		gbe_dev->sgmii_port_regs = gbe_dev->ss_regs +
+					   GBE13_SGMII_MODULE_OFFSET;
+	} else {
+		ret = of_address_to_resource(node, GBE_SGMII_REG_INDEX, &res);
+		if (ret) {
+			dev_err(gbe_dev->dev,
+				"Can't translate of gbe node(%s) address at index %d\n",
+				node->name, GBE_SGMII_REG_INDEX);
+			return ret;
+		}
+
+		regs = devm_ioremap_resource(gbe_dev->dev, &res);
+		if (IS_ERR(regs)) {
+			dev_err(gbe_dev->dev,
+				"Failed to map gbe sgmii port register base\n");
+			return PTR_ERR(regs);
+		}
+		gbe_dev->sgmii_port_regs = regs;
+	}
+
 	ret = of_address_to_resource(node, GBE_SGMII34_REG_INDEX, &res);
 	if (ret) {
 		dev_err(gbe_dev->dev,
@@ -3314,7 +3384,6 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 		return -ENOMEM;
 	}
 
-	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs + GBE13_SGMII_MODULE_OFFSET;
 	gbe_dev->host_port_regs = gbe_dev->switch_regs + GBE13_HOST_PORT_OFFSET;
 
 	/* K2HK has only 2 hw stats modules visible at a time, so
@@ -3402,14 +3471,33 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 	}
 	gbe_dev->switch_regs = regs;
 
-	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs + GBENU_SGMII_MODULE_OFFSET;
+	if (gbe_dev->ss_regs) {
+		gbe_dev->sgmii_port_regs = gbe_dev->ss_regs +
+					   GBENU_SGMII_MODULE_OFFSET;
+	} else {
+		ret = of_address_to_resource(node, GBENU_SGMII_REG_INDEX, &res);
+		if (ret) {
+			dev_err(gbe_dev->dev,
+				"Can't translate of gbenu node(%s) addr at index %d\n",
+				node->name, GBENU_SGMII_REG_INDEX);
+			return ret;
+		}
+
+		regs = devm_ioremap_resource(gbe_dev->dev, &res);
+		if (IS_ERR(regs)) {
+			dev_err(gbe_dev->dev,
+				"Failed to map gbenu sgmii port register base\n");
+			return PTR_ERR(regs);
+		}
+		gbe_dev->sgmii_port_regs = regs;
+	}
 
 	/* Although sgmii modules are mem mapped to one contiguous
 	 * region on GBENU devices, setting sgmii_port34_regs allows
 	 * consistent code when accessing sgmii api
 	 */
 	gbe_dev->sgmii_port34_regs = gbe_dev->sgmii_port_regs +
-				     (2 * GBENU_SGMII_MODULE_SIZE);
+				     (2 * SGMII_MODULE_SIZE);
 
 	gbe_dev->host_port_regs = gbe_dev->switch_regs + GBENU_HOST_PORT_OFFSET;
 
-- 
1.9.1
