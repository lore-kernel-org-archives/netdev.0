From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v6 4/5] net: ethernet: cpsw: add support for hardware interface mode config
Date: Fri, 23 Aug 2013 21:32:09 +0200
Message-ID: <1377286330-29663-5-git-send-email-zonque@gmail.com>
References: <1377286330-29663-1-git-send-email-zonque@gmail.com>
Cc: bcousson@baylibre.com, nsekhar@ti.com,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, mugunthanvnm@ti.com, vaibhav.bedia@ti.com,
	d-gerlach@ti.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:48888 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755794Ab3HWTcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 15:32:23 -0400
In-Reply-To: <1377286330-29663-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cpsw currently lacks code to properly set up the hardware interface
mode on AM33xx. Other platforms might be equally affected.

Usually, the bootloader will configure the control module register, so
probably that's why such support wasn't needed in the past. In suspend
mode though, this register is modified, and so it needs reprogramming
after resume.

This patch adds code that makes use of the previously added and optional
support for passing the control mode register, and configures the
correct register bits when the slave is opened.

The AM33xx also has a bit for each slave to configure the RMII reference
clock direction. Setting it is now supported by a per-slave DT property.

This code path introducted by this patch is currently exclusive for
am33xx.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |  2 +
 drivers/net/ethernet/ti/cpsw.c                 | 58 ++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw.h                 |  8 ++++
 3 files changed, 68 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index b717458..0895a51 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -34,6 +34,8 @@ Required properties:
 - phy_id		: Specifies slave phy id
 - phy-mode		: The interface between the SoC and the PHY (a string
 			  that of_get_phy_mode() can understand)
+- ti,rmii-clock-ext	: If present, the driver will configure the RMII
+			  interface to external clock usage
 - mac-address		: Specifies slave MAC address
 
 Optional properties:
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8d023ab..6b47e78 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -980,6 +980,60 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
 		priv->host_port, ALE_VLAN, slave->port_vlan);
 }
 
+static void cpsw_set_phy_interface_mode(struct cpsw_slave *slave,
+					struct cpsw_priv *priv)
+{
+	u32 reg;
+	u32 mask;
+	u32 mode = 0;
+
+	switch (priv->data.hw_type) {
+	case CPSW_TYPE_AM33XX:
+		if (IS_ERR_OR_NULL(priv->gmii_sel_reg))
+			break;
+
+		reg = readl(priv->gmii_sel_reg);
+
+		if (slave->phy) {
+			switch (slave->phy->interface) {
+			case PHY_INTERFACE_MODE_MII:
+			default:
+				mode = AM33XX_GMII_SEL_MODE_MII;
+				break;
+			case PHY_INTERFACE_MODE_RMII:
+				mode = AM33XX_GMII_SEL_MODE_RMII;
+				break;
+			case PHY_INTERFACE_MODE_RGMII:
+			case PHY_INTERFACE_MODE_RGMII_ID:
+			case PHY_INTERFACE_MODE_RGMII_RXID:
+			case PHY_INTERFACE_MODE_RGMII_TXID:
+				mode = AM33XX_GMII_SEL_MODE_RGMII;
+				break;
+			};
+		}
+
+		mask = 0x3 << (slave->slave_num * 2) |
+		       BIT(slave->slave_num + 6);
+		mode <<= slave->slave_num * 2;
+
+		if (slave->data->rmii_clock_external) {
+			if (slave->slave_num == 0)
+				mode |= AM33XX_GMII_SEL_RMII1_IO_CLK_EN;
+			else
+				mode |= AM33XX_GMII_SEL_RMII2_IO_CLK_EN;
+		}
+
+		reg &= ~mask;
+		reg |= mode;
+
+		writel(reg, priv->gmii_sel_reg);
+		break;
+
+	default:
+		break;
+	}
+}
+
 static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 {
 	char name[32];
@@ -1028,6 +1082,8 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 			 slave->phy->phy_id);
 		phy_start(slave->phy);
 	}
+
+	cpsw_set_phy_interface_mode(slave, priv);
 }
 
 static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
@@ -1823,6 +1879,8 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
 
 		slave_data->phy_if = of_get_phy_mode(slave_node);
+		if (of_find_property(slave_node, "ti,rmii-clock-ext", NULL))
+			slave_data->rmii_clock_external = true;
 
 		if (data->dual_emac) {
 			if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
index 96c374a..3a6cb16 100644
--- a/drivers/net/ethernet/ti/cpsw.h
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -19,6 +19,7 @@
 struct cpsw_slave_data {
 	char		phy_id[MII_BUS_ID_SIZE];
 	int		phy_if;
+	bool		rmii_clock_external;
 	u8		mac_addr[ETH_ALEN];
 	u16		dual_emac_res_vlan;	/* Reserved VLAN for DualEMAC */
 };
@@ -40,4 +41,11 @@ struct cpsw_platform_data {
 	u32	hw_type;	/* hardware type as specified in 'compatible' */
 };
 
+/* SoC specific definitions for the CONTROL port */
+#define AM33XX_GMII_SEL_MODE_MII	0
+#define AM33XX_GMII_SEL_MODE_RMII	1
+#define AM33XX_GMII_SEL_MODE_RGMII	2
+
+#define AM33XX_GMII_SEL_RMII2_IO_CLK_EN	BIT(7)
+#define AM33XX_GMII_SEL_RMII1_IO_CLK_EN	BIT(6)
 #endif /* __CPSW_H__ */
-- 
1.8.3.1
