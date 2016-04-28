From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH net v3 3/5] drivers: net: cpsw: don't ignore phy-mode if phy-handle is used
Date: Wed, 27 Apr 2016 21:38:26 -0400
Message-ID: <1461807506-4498-1-git-send-email-drivshin.allworx@gmail.com>
References: <1461805808-4102-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Nicolas Chauvet <kwizart@gmail.com>
To: netdev@vger.kernel.org, linux-omap@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461805808-4102-1-git-send-email-drivshin.allworx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Rivshin <drivshin@allworx.com>

The phy-mode emac property was only being processed in the phy_id
or fixed-link cases. However if phy-handle was specified instead,
an error message would complain about the lack of phy_id or
fixed-link, and then jump past the of_get_phy_mode(). This would
result in the PHY mode defaulting to MII, regardless of what the
devicetree specified.

Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
Signed-off-by: David Rivshin <drivshin@allworx.com>
Tested-by: Nicolas Chauvet <kwizart@gmail.com>
Tested-by: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>
---
I would suggest this for -stable. It should apply cleanly as far back
as 4.4.

Changes since v2 [1]:
- split from previous patch 2
- Added Tested-by from Andrew Goodbody [3]
- Added Reviewed-by from Mugunthan V N [4]
- rewrote commit log to focus on the functional bug fixed, rather
  than the bogus error message

Changes since v1 [2]:
- Rebased (no conflicts)
- Added Tested-by from Nicolas Chauvet
- Added Acked-by from Rob Herring for the binding change

[1] http://patchwork.ozlabs.org/patch/613260/
[2] http://patchwork.ozlabs.org/patch/560324/
[3] https://lkml.org/lkml/2016/4/22/537
[4] https://lkml.org/lkml/2016/4/22/63


 drivers/net/ethernet/ti/cpsw.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5903448..712bc6d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2039,15 +2039,19 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		/* This is no slave child node, continue */
 		if (strcmp(slave_node->name, "slave"))
 			continue;
 
 		slave_data->phy_node = of_parse_phandle(slave_node,
 							"phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
-		if (of_phy_is_fixed_link(slave_node)) {
+		if (slave_data->phy_node) {
+			dev_dbg(&pdev->dev,
+				"slave[%d] using phy-handle=\"%s\"\n",
+				i, slave_data->phy_node->full_name);
+		} else if (of_phy_is_fixed_link(slave_node)) {
 			struct device_node *phy_node;
 			struct phy_device *phy_dev;
 
 			/* In the case of a fixed PHY, the DT node associated
 			 * to the PHY is the Ethernet MAC DT node.
 			 */
 			ret = of_phy_register_fixed_link(slave_node);
@@ -2076,15 +2080,17 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			if (!mdio) {
 				dev_err(&pdev->dev, "Missing mdio platform device\n");
 				return -EINVAL;
 			}
 			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
 				 PHY_ID_FMT, mdio->name, phyid);
 		} else {
-			dev_err(&pdev->dev, "No slave[%d] phy_id or fixed-link property\n", i);
+			dev_err(&pdev->dev,
+				"No slave[%d] phy_id, phy-handle, or fixed-link property\n",
+				i);
 			goto no_phy_slave;
 		}
 		slave_data->phy_if = of_get_phy_mode(slave_node);
 		if (slave_data->phy_if < 0) {
 			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
 				i);
 			return slave_data->phy_if;
-- 
2.5.5
