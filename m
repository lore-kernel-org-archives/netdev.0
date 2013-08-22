From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 3/4] net: ethernet: cpsw: add support for hardware interface mode config
Date: Thu, 22 Aug 2013 13:37:27 +0200
Message-ID: <1377171448-27924-4-git-send-email-zonque@gmail.com>
References: <1377171448-27924-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:46152 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903Ab3HVLhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 07:37:38 -0400
In-Reply-To: <1377171448-27924-1-git-send-email-zonque@gmail.com>
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
correct register bits from _cpsw_adjust_link().

The AM33xx also has a bit for each slave to configure the RMII reference
clock direction. Setting it is now supported by a per-slave DT property.

This code path introducted by this patch is currently exclusive for
am33xx.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |  2 ++
 drivers/net/ethernet/ti/cpsw.c                 | 49 ++++++++++++++++++++++++++
 include/linux/platform_data/cpsw.h             |  1 +
 3 files changed, 52 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 4e5ca54..0ccf01f 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -33,6 +33,8 @@ Required properties:
 - phy_id		: Specifies slave phy id
 - phy-mode		: The interface between the SoC and the PHY (a string
 			  that of_get_phy_mode() can understand)
+- ti,rmii-clock-ext	: If present, the driver will configure the RMII
+			  interface to external clock usage
 - mac-address		: Specifies slave MAC address
 
 Optional properties:
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 4855d8e..d18ae43 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -138,6 +138,14 @@ do {								\
 #define CPSW_CMINTMAX_INTVL	(1000 / CPSW_CMINTMIN_CNT)
 #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
 
+#define AM33XX_GMII_SEL_MODE_MII	(0)
+#define AM33XX_GMII_SEL_MODE_RMII	(1)
+#define AM33XX_GMII_SEL_MODE_RGMII	(2)
+#define AM33XX_GMII_SEL_MODE_UNUSED	(3)
+
+#define AM33XX_GMII_SEL_RMII2_IO_CLK_EN	BIT(7)
+#define AM33XX_GMII_SEL_RMII1_IO_CLK_EN	BIT(6)
+
 #define cpsw_enable_irq(priv)	\
 	do {			\
 		u32 i;		\
@@ -728,6 +736,44 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 	u32			mac_control = 0;
 	u32			slave_port;
 
+	if (priv->gmii_sel_reg && of_machine_is_compatible("ti,am33xx")) {
+		u32 reg = __raw_readl(priv->gmii_sel_reg);
+		u32 mode = AM33XX_GMII_SEL_MODE_UNUSED;
+		u32 mask;
+
+		if (phy) {
+			switch (phy->interface) {
+			case PHY_INTERFACE_MODE_MII:
+				mode = AM33XX_GMII_SEL_MODE_MII;
+				break;
+			case PHY_INTERFACE_MODE_RMII:
+				mode = AM33XX_GMII_SEL_MODE_RMII;
+				break;
+			case PHY_INTERFACE_MODE_RGMII:
+				mode = AM33XX_GMII_SEL_MODE_RGMII;
+				break;
+			default:
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
+		__raw_writel(reg, priv->gmii_sel_reg);
+	}
+
 	if (!phy)
 		return;
 
@@ -1798,6 +1844,9 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
 
 		slave_data->phy_if = of_get_phy_mode(slave_node);
+		if (of_find_property(slave_node, "ti,rmii-clock-external",
+				     NULL))
+			slave_data->rmii_clock_external = true;
 
 		if (data->dual_emac) {
 			if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index bb3cd58..a29c48b 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -20,6 +20,7 @@
 struct cpsw_slave_data {
 	char		phy_id[MII_BUS_ID_SIZE];
 	int		phy_if;
+	bool		rmii_clock_external;
 	u8		mac_addr[ETH_ALEN];
 	u16		dual_emac_res_vlan;	/* Reserved VLAN for DualEMAC */
 
-- 
1.8.3.1
