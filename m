From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH 1/3] drivers: net: cpsw: fix parsing of phy-handle DT property in dual_emac config
Date: Tue, 22 Dec 2015 19:36:32 -0500
Message-ID: <1450830994-5450-2-git-send-email-drivshin.allworx@gmail.com>
References: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, David Miller <davem@davemloft.net>,
	Heiko Schocher <hs@denx.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33300 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932676AbbLWAid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 19:38:33 -0500
In-Reply-To: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rivshin <drivshin@allworx.com>

Commit 9e42f715264ff158478fa30eaed847f6e131366b ("drivers: net: cpsw: add
phy-handle parsing") saved the "phy-handle" phandle into a new cpsw_priv
field. However, phy connections are per-slave, so the phy_node field should
be in cpsw_slave_data rather than cpsw_priv.

This would go unnoticed in a single emac configuration. But in dual_emac
mode, the last "phy-handle" property parsed for either slave would be used
by both of them, causing them both to refer to the same phy_device.

Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
Signed-off-by: David Rivshin <drivshin@allworx.com>
---
You may want to consider this for 4.3-stable. It manages to apply
on top of v4.3.3 with 'git am -C1', or I can produce a separate
patch against v4.3.3 if preferred.

 drivers/net/ethernet/ti/cpsw.c | 13 ++++++-------
 drivers/net/ethernet/ti/cpsw.h |  1 +
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 3b489ca..8ad0ed8 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -363,15 +363,14 @@ static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
 	__raw_writel(val, slave->regs + offset);
 }
 
 struct cpsw_priv {
 	spinlock_t			lock;
 	struct platform_device		*pdev;
 	struct net_device		*ndev;
-	struct device_node		*phy_node;
 	struct napi_struct		napi_rx;
 	struct napi_struct		napi_tx;
 	struct device			*dev;
 	struct cpsw_platform_data	data;
 	struct cpsw_ss_regs __iomem	*regs;
 	struct cpsw_wr_regs __iomem	*wr_regs;
 	u8 __iomem			*hw_stats;
@@ -1144,16 +1143,16 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 
 	if (priv->data.dual_emac)
 		cpsw_add_dual_emac_def_ale_entries(priv, slave, slave_port);
 	else
 		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
-	if (priv->phy_node)
-		slave->phy = of_phy_connect(priv->ndev, priv->phy_node,
+	if (slave->data->phy_node)
+		slave->phy = of_phy_connect(priv->ndev, slave->data->phy_node,
 				 &cpsw_adjust_link, 0, slave->data->phy_if);
 	else
 		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
 				 &cpsw_adjust_link, slave->data->phy_if);
 	if (IS_ERR(slave->phy)) {
 		dev_err(priv->dev, "phy %s not found on slave %d\n",
 			slave->data->phy_id, slave->slave_num);
@@ -1936,20 +1935,19 @@ static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
 
 	slave->data	= data;
 	slave->regs	= regs + slave_reg_ofs;
 	slave->sliver	= regs + sliver_reg_ofs;
 	slave->port_vlan = data->dual_emac_res_vlan;
 }
 
-static int cpsw_probe_dt(struct cpsw_priv *priv,
+static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			 struct platform_device *pdev)
 {
 	struct device_node *node = pdev->dev.of_node;
 	struct device_node *slave_node;
-	struct cpsw_platform_data *data = &priv->data;
 	int i = 0, ret;
 	u32 prop;
 
 	if (!node)
 		return -EINVAL;
 
 	if (of_property_read_u32(node, "slaves", &prop)) {
@@ -2029,15 +2027,16 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 		int lenp;
 		const __be32 *parp;
 
 		/* This is no slave child node, continue */
 		if (strcmp(slave_node->name, "slave"))
 			continue;
 
-		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
+		slave_data->phy_node = of_parse_phandle(slave_node,
+							"phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if (of_phy_is_fixed_link(slave_node)) {
 			struct device_node *phy_node;
 			struct phy_device *phy_dev;
 
 			/* In the case of a fixed PHY, the DT node associated
 			 * to the PHY is the Ethernet MAC DT node.
@@ -2270,15 +2269,15 @@ static int cpsw_probe(struct platform_device *pdev)
 	 * This may be required here for child devices.
 	 */
 	pm_runtime_enable(&pdev->dev);
 
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(&pdev->dev);
 
-	if (cpsw_probe_dt(priv, pdev)) {
+	if (cpsw_probe_dt(&priv->data, pdev)) {
 		dev_err(&pdev->dev, "cpsw: platform data missing\n");
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
 	data = &priv->data;
 
 	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
index 442a703..e50afd1 100644
--- a/drivers/net/ethernet/ti/cpsw.h
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -14,14 +14,15 @@
 #ifndef __CPSW_H__
 #define __CPSW_H__
 
 #include <linux/if_ether.h>
 #include <linux/phy.h>
 
 struct cpsw_slave_data {
+	struct device_node *phy_node;
 	char		phy_id[MII_BUS_ID_SIZE];
 	int		phy_if;
 	u8		mac_addr[ETH_ALEN];
 	u16		dual_emac_res_vlan;	/* Reserved VLAN for DualEMAC */
 };
 
 struct cpsw_platform_data {
-- 
2.5.0
