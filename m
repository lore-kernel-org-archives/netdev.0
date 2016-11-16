From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 7/7] net: ethernet: ti: cpsw: fix fixed-link phy probe deferral
Date: Wed, 16 Nov 2016 15:35:16 +0100
Message-ID: <1479306916-27673-8-git-send-email-johan@kernel.org>
References: <1479306916-27673-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306916-27673-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to propagate errors from of_phy_register_fixed_link() which
can fail with -EPROBE_DEFER.

Fixes: 1f71e8c96fc6 ("drivers: net: cpsw: Add support for fixed-link
PHY")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 411be060fee6..cf8f1afa46bf 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2375,8 +2375,11 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			 * to the PHY is the Ethernet MAC DT node.
 			 */
 			ret = of_phy_register_fixed_link(slave_node);
-			if (ret)
+			if (ret) {
+				if (ret != -EPROBE_DEFER)
+					dev_err(&pdev->dev, "failed to register fixed-link phy: %d\n", ret);
 				return ret;
+			}
 			slave_data->phy_node = of_node_get(slave_node);
 		} else if (parp) {
 			u32 phyid;
@@ -2628,11 +2631,10 @@ static int cpsw_probe(struct platform_device *pdev)
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(&pdev->dev);
 
-	if (cpsw_probe_dt(&cpsw->data, pdev)) {
-		dev_err(&pdev->dev, "cpsw: platform data missing\n");
-		ret = -ENODEV;
+	ret = cpsw_probe_dt(&cpsw->data, pdev);
+	if (ret)
 		goto clean_dt_ret;
-	}
+
 	data = &cpsw->data;
 	cpsw->rx_ch_num = 1;
 	cpsw->tx_ch_num = 1;
-- 
2.7.3
