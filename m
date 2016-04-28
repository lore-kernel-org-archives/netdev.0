From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH net v3 5/5] drivers: net: cpsw: use of_phy_connect() in fixed-link case
Date: Wed, 27 Apr 2016 21:45:45 -0400
Message-ID: <1461807945-4665-1-git-send-email-drivshin.allworx@gmail.com>
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

If a fixed-link DT subnode is used, the phy_device was looked up so
that a PHY ID string could be constructed and passed to phy_connect().
This is not necessary, as the device_node can be passed directly to
of_phy_connect() instead. This reuses the same codepath as if the
phy-handle DT property was used.

Signed-off-by: David Rivshin <drivshin@allworx.com>
Tested-by: Nicolas Chauvet <kwizart@gmail.com>
Tested-by: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>
Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>
---

Changes since v2 [1]:
- Added Tested-by from Andrew Goodbody [3]
- Added Reviewed-by from Mugunthan V N [4]
- Added Reviewed-by from Grygorii Strashko [5]

Changes since v1 [2]:
- Rebased (trivial conflict, e5a03bfd modified the deleted snprintf)
- Added Tested-by from Nicolas Chauvet

[1] http://patchwork.ozlabs.org/patch/613276/
[2] http://patchwork.ozlabs.org/patch/560327/
[3] https://lkml.org/lkml/2016/4/22/537
[4] https://lkml.org/lkml/2016/4/22/63
[5] https://lkml.org/lkml/2016/4/22/529


 drivers/net/ethernet/ti/cpsw.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 712bc6d..e2fcdf1 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2044,30 +2044,21 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 							"phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if (slave_data->phy_node) {
 			dev_dbg(&pdev->dev,
 				"slave[%d] using phy-handle=\"%s\"\n",
 				i, slave_data->phy_node->full_name);
 		} else if (of_phy_is_fixed_link(slave_node)) {
-			struct device_node *phy_node;
-			struct phy_device *phy_dev;
-
 			/* In the case of a fixed PHY, the DT node associated
 			 * to the PHY is the Ethernet MAC DT node.
 			 */
 			ret = of_phy_register_fixed_link(slave_node);
 			if (ret)
 				return ret;
-			phy_node = of_node_get(slave_node);
-			phy_dev = of_phy_find_device(phy_node);
-			if (!phy_dev)
-				return -ENODEV;
-			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-				 PHY_ID_FMT, phy_dev->mdio.bus->id,
-				 phy_dev->mdio.addr);
+			slave_data->phy_node = of_node_get(slave_node);
 		} else if (parp) {
 			u32 phyid;
 			struct device_node *mdio_node;
 			struct platform_device *mdio;
 
 			if (lenp != (sizeof(__be32) * 2)) {
 				dev_err(&pdev->dev, "Invalid slave[%d] phy_id property\n", i);
-- 
2.5.5
