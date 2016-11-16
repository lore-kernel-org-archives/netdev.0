From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 4/7] net: ethernet: ti: cpsw: fix of_node and phydev leaks
Date: Wed, 16 Nov 2016 15:35:13 +0100
Message-ID: <1479306916-27673-5-git-send-email-johan@kernel.org>
References: <1479306916-27673-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306916-27673-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop references taken and deregister devices registered
during probe on probe errors (including deferred probe) and driver
unbind.

Specifically, PHY of-node references were never released and fixed-link
PHY devices were never deregistered.

Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
Fixes: 1f71e8c96fc6 ("drivers: net: cpsw: Add support for fixed-link
PHY")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 4374ba05610b..4bd96732291c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2443,6 +2443,41 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 
 static void cpsw_remove_dt(struct platform_device *pdev)
 {
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
+	struct cpsw_platform_data *data = &cpsw->data;
+	struct device_node *node = pdev->dev.of_node;
+	struct device_node *slave_node;
+	int i = 0;
+
+	for_each_available_child_of_node(node, slave_node) {
+		struct cpsw_slave_data *slave_data = &data->slave_data[i];
+
+		if (strcmp(slave_node->name, "slave"))
+			continue;
+
+		if (of_phy_is_fixed_link(slave_node)) {
+			struct phy_device *phydev;
+
+			phydev = of_phy_find_device(slave_node);
+			if (phydev) {
+				fixed_phy_unregister(phydev);
+				/* Put references taken by
+				 * of_phy_find_device() and
+				 * of_phy_register_fixed_link().
+				 */
+				phy_device_free(phydev);
+				phy_device_free(phydev);
+			}
+		}
+
+		of_node_put(slave_data->phy_node);
+
+		i++;
+		if (i == data->slaves)
+			break;
+	}
+
 	of_platform_depopulate(&pdev->dev);
 }
 
-- 
2.7.3
