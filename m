From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Subject: [PATCH v2 1/1] Revert "Prevent NUll pointer dereference with two PHYs on cpsw"
Date: Wed, 20 Apr 2016 16:14:51 +0100
Message-ID: <1461165291-25043-2-git-send-email-andrew.goodbody@cambrionix.com>
References: <1461165291-25043-1-git-send-email-andrew.goodbody@cambrionix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <grygorii.strashko@ti.com>,
	<tony@atomide.com>, <davem@davemloft.net>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461165291-25043-1-git-send-email-andrew.goodbody@cambrionix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit cfe255600154f0072d4a8695590dbd194dfd1aeb

This can result in a "Unable to handle kernel paging request"
during boot. This was due to using an uninitialised struct member,
data->slaves.

Signed-off-by: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Tested-by: Tony Lindgren <tony@atomide.com>
---

v2 No code change, added signoff and collected tested-by

 drivers/net/ethernet/ti/cpsw.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 2cd67a5..54bcc38 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -349,7 +349,6 @@ struct cpsw_slave {
 	struct cpsw_slave_data		*data;
 	struct phy_device		*phy;
 	struct net_device		*ndev;
-	struct device_node		*phy_node;
 	u32				port_vlan;
 	u32				open_stat;
 };
@@ -368,6 +367,7 @@ struct cpsw_priv {
 	spinlock_t			lock;
 	struct platform_device		*pdev;
 	struct net_device		*ndev;
+	struct device_node		*phy_node;
 	struct napi_struct		napi_rx;
 	struct napi_struct		napi_tx;
 	struct device			*dev;
@@ -1142,8 +1142,8 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
-	if (slave->phy_node)
-		slave->phy = of_phy_connect(priv->ndev, slave->phy_node,
+	if (priv->phy_node)
+		slave->phy = of_phy_connect(priv->ndev, priv->phy_node,
 				 &cpsw_adjust_link, 0, slave->data->phy_if);
 	else
 		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
@@ -2025,8 +2025,7 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 		if (strcmp(slave_node->name, "slave"))
 			continue;
 
-		priv->slaves[i].phy_node =
-			of_parse_phandle(slave_node, "phy-handle", 0);
+		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if (of_phy_is_fixed_link(slave_node)) {
 			struct device_node *phy_node;
@@ -2267,22 +2266,12 @@ static int cpsw_probe(struct platform_device *pdev)
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(&pdev->dev);
 
-	data = &priv->data;
-	priv->slaves = devm_kzalloc(&pdev->dev,
-				    sizeof(struct cpsw_slave) * data->slaves,
-				    GFP_KERNEL);
-	if (!priv->slaves) {
-		ret = -ENOMEM;
-		goto clean_runtime_disable_ret;
-	}
-	for (i = 0; i < data->slaves; i++)
-		priv->slaves[i].slave_num = i;
-
 	if (cpsw_probe_dt(priv, pdev)) {
 		dev_err(&pdev->dev, "cpsw: platform data missing\n");
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
+	data = &priv->data;
 
 	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
 		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
@@ -2294,6 +2283,16 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
 
+	priv->slaves = devm_kzalloc(&pdev->dev,
+				    sizeof(struct cpsw_slave) * data->slaves,
+				    GFP_KERNEL);
+	if (!priv->slaves) {
+		ret = -ENOMEM;
+		goto clean_runtime_disable_ret;
+	}
+	for (i = 0; i < data->slaves; i++)
+		priv->slaves[i].slave_num = i;
+
 	priv->slaves[0].ndev = ndev;
 	priv->emac_port = 0;
 
-- 
2.5.0
