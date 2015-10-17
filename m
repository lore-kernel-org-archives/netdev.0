From: Heiko Schocher <hs@denx.de>
Subject: [PATCH v2 1/2] drivers: net: cpsw: add phy-handle parsing
Date: Sat, 17 Oct 2015 06:04:35 +0200
Message-ID: <1445054676-21523-2-git-send-email-hs__42022.4278969274$1445054821$gmane$org@denx.de>
References: <1445054676-21523-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs@denx.de>, Felipe Balbi <balbi@ti.com>,
	"David S. Miller" <"davem@davemloft.net>, netdev"@vger.kernel.org>,
	Tony Lindgren <tony@atomide.com>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Richard Cochran <richardcochran@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:55576 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbbJQEEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 00:04:55 -0400
In-Reply-To: <1445054676-21523-1-git-send-email-hs@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add the ability to parse "phy-handle". This
is needed for phys, which have a DT node, and
need to parse DT properties.

Signed-off-by: Heiko Schocher <hs@denx.de>
---

Changes in v2: None

 Documentation/devicetree/bindings/net/cpsw.txt |  1 +
 drivers/net/ethernet/ti/cpsw.c                 | 15 +++++++++++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index a9df21a..a2cae4e 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -39,6 +39,7 @@ Required properties:
 Optional properties:
 - dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
 - mac-address		: See ethernet.txt file in the same directory
+- phy-handle		: See ethernet.txt file in the same directory
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8fc90f1..874fb29 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -30,6 +30,7 @@
 #include <linux/delay.h>
 #include <linux/pm_runtime.h>
 #include <linux/of.h>
+#include <linux/of_mdio.h>
 #include <linux/of_net.h>
 #include <linux/of_device.h>
 #include <linux/if_vlan.h>
@@ -365,6 +366,7 @@ struct cpsw_priv {
 	spinlock_t			lock;
 	struct platform_device		*pdev;
 	struct net_device		*ndev;
+	struct device_node		*phy_node;
 	struct napi_struct		napi_rx;
 	struct napi_struct		napi_tx;
 	struct device			*dev;
@@ -1145,7 +1147,11 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
-	slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
+	if (priv->phy_node)
+		slave->phy = of_phy_connect(priv->ndev, priv->phy_node,
+				 &cpsw_adjust_link, 0, slave->data->phy_if);
+	else
+		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
 				 &cpsw_adjust_link, slave->data->phy_if);
 	if (IS_ERR(slave->phy)) {
 		dev_err(priv->dev, "phy %s not found on slave %d\n",
@@ -1934,11 +1940,12 @@ static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
 	slave->port_vlan = data->dual_emac_res_vlan;
 }
 
-static int cpsw_probe_dt(struct cpsw_platform_data *data,
+static int cpsw_probe_dt(struct cpsw_priv *priv,
 			 struct platform_device *pdev)
 {
 	struct device_node *node = pdev->dev.of_node;
 	struct device_node *slave_node;
+	struct cpsw_platform_data *data = &priv->data;
 	int i = 0, ret;
 	u32 prop;
 
@@ -2029,6 +2036,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		if (strcmp(slave_node->name, "slave"))
 			continue;
 
+		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if ((parp == NULL) || (lenp != (sizeof(void *) * 2))) {
 			dev_err(&pdev->dev, "Missing slave[%d] phy_id property\n", i);
@@ -2044,7 +2052,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		}
 		snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
 			 PHY_ID_FMT, mdio->name, phyid);
-
 		slave_data->phy_if = of_get_phy_mode(slave_node);
 		if (slave_data->phy_if < 0) {
 			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
@@ -2240,7 +2247,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(&pdev->dev);
 
-	if (cpsw_probe_dt(&priv->data, pdev)) {
+	if (cpsw_probe_dt(priv, pdev)) {
 		dev_err(&pdev->dev, "cpsw: platform data missing\n");
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
-- 
2.1.0
