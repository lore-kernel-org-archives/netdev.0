From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH net v3 2/5] drivers: net: cpsw: fix segfault in case of bad phy-handle
Date: Wed, 27 Apr 2016 21:32:31 -0400
Message-ID: <1461807151-4416-1-git-send-email-drivshin.allworx@gmail.com>
References: <1461805808-4102-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Nicolas Chauvet <kwizart@gmail.com>
To: netdev@vger.kernel.org, linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34469 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbcD1Bcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 21:32:43 -0400
In-Reply-To: <1461805808-4102-1-git-send-email-drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rivshin <drivshin@allworx.com>

If an emac node has a phy-handle property that points to something
which is not a phy, then a segmentation fault will occur when the
interface is brought up. This is because while phy_connect() will
return ERR_PTR() on failure, of_phy_connect() will return NULL.
The common error check uses IS_ERR(), and so missed when
of_phy_connect() fails. The NULL pointer is then dereferenced.

Also, the common error message referenced slave->data->phy_id,
which would be empty in the case of phy-handle. Instead, use the
name of the device_node as a useful identifier. And in the phy_id
case add the error code for completeness.

Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
Signed-off-by: David Rivshin <drivshin@allworx.com>
---
I would suggest this for -stable. It should apply cleanly as far back
as 4.5, although there is a trivial conflict in 4.4. I can produce a
separate patch against linux-4.4.y if preferred.

Changes since v2:
- new patch, although fixing part of previous patch 2 [1]

Changes since v1 [2]:
- Rebased (no conflicts)
- Added Tested-by from Nicolas Chauvet
- Added Acked-by from Rob Herring for the binding change

[1] http://patchwork.ozlabs.org/patch/613260/
[2] http://patchwork.ozlabs.org/patch/560324/


 drivers/net/ethernet/ti/cpsw.c | 37 +++++++++++++++++++++++--------------
 1 file changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ce0b0ca..5903448 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1143,33 +1143,42 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 
 	if (priv->data.dual_emac)
 		cpsw_add_dual_emac_def_ale_entries(priv, slave, slave_port);
 	else
 		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
-	if (slave->data->phy_node)
+	if (slave->data->phy_node) {
 		slave->phy = of_phy_connect(priv->ndev, slave->data->phy_node,
 				 &cpsw_adjust_link, 0, slave->data->phy_if);
-	else
+		if (!slave->phy) {
+			dev_err(priv->dev, "phy \"%s\" not found on slave %d\n",
+				slave->data->phy_node->full_name,
+				slave->slave_num);
+			return;
+		}
+	} else {
 		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
 				 &cpsw_adjust_link, slave->data->phy_if);
-	if (IS_ERR(slave->phy)) {
-		dev_err(priv->dev, "phy %s not found on slave %d\n",
-			slave->data->phy_id, slave->slave_num);
-		slave->phy = NULL;
-	} else {
-		phy_attached_info(slave->phy);
-
-		phy_start(slave->phy);
-
-		/* Configure GMII_SEL register */
-		cpsw_phy_sel(&priv->pdev->dev, slave->phy->interface,
-			     slave->slave_num);
+		if (IS_ERR(slave->phy)) {
+			dev_err(priv->dev,
+				"phy \"%s\" not found on slave %d, err %ld\n",
+				slave->data->phy_id, slave->slave_num,
+				PTR_ERR(slave->phy));
+			slave->phy = NULL;
+			return;
+		}
 	}
+
+	phy_attached_info(slave->phy);
+
+	phy_start(slave->phy);
+
+	/* Configure GMII_SEL register */
+	cpsw_phy_sel(&priv->pdev->dev, slave->phy->interface, slave->slave_num);
 }
 
 static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 {
 	const int vlan = priv->data.default_vlan;
 	const int port = priv->host_port;
 	u32 reg;
-- 
2.5.5
