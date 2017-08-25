From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 1/2] drivers: net: xgene: Correct probe sequence handling
Date: Fri, 25 Aug 2017 15:23:29 -0700
Message-ID: <1503699810-12803-2-git-send-email-isubramanian@apm.com>
References: <1503699810-12803-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, dnelson@redhat.com,
        qnguyen@apm.com, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:38282 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933777AbdHYWXs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 18:23:48 -0400
Received: by mail-pg0-f50.google.com with SMTP id b8so5663368pgn.5
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 15:23:48 -0700 (PDT)
In-Reply-To: <1503699810-12803-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

The phy is connected at early stage of probe but not properly
disconnected if error occurs.  This patch fixes the issue.

Also changing the return type of xgene_enet_check_phy_handle(),
since this function always returns success.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 27 ++++++++++++------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 1d307f2..6e253d9 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1661,21 +1661,21 @@ static int xgene_enet_get_irqs(struct xgene_enet_pdata *pdata)
 	return 0;
 }
 
-static int xgene_enet_check_phy_handle(struct xgene_enet_pdata *pdata)
+static void xgene_enet_check_phy_handle(struct xgene_enet_pdata *pdata)
 {
 	int ret;
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII)
-		return 0;
+		return;
 
 	if (!IS_ENABLED(CONFIG_MDIO_XGENE))
-		return 0;
+		return;
 
 	ret = xgene_enet_phy_connect(pdata->ndev);
 	if (!ret)
 		pdata->mdio_driver = true;
 
-	return 0;
+	return;
 }
 
 static void xgene_enet_gpiod_get(struct xgene_enet_pdata *pdata)
@@ -1779,10 +1779,6 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	if (ret)
 		return ret;
 
-	ret = xgene_enet_check_phy_handle(pdata);
-	if (ret)
-		return ret;
-
 	xgene_enet_gpiod_get(pdata);
 
 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
@@ -2097,9 +2093,11 @@ static int xgene_enet_probe(struct platform_device *pdev)
 		goto err;
 	}
 
+	xgene_enet_check_phy_handle(pdata);
+
 	ret = xgene_enet_init_hw(pdata);
 	if (ret)
-		goto err;
+		goto err2;
 
 	link_state = pdata->mac_ops->link_state;
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
@@ -2117,29 +2115,30 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	spin_lock_init(&pdata->stats_lock);
 	ret = xgene_extd_stats_init(pdata);
 	if (ret)
-		goto err2;
+		goto err1;
 
 	xgene_enet_napi_add(pdata);
 	ret = register_netdev(ndev);
 	if (ret) {
 		netdev_err(ndev, "Failed to register netdev\n");
-		goto err2;
+		goto err1;
 	}
 
 	return 0;
 
-err2:
+err1:
 	/*
 	 * If necessary, free_netdev() will call netif_napi_del() and undo
 	 * the effects of xgene_enet_napi_add()'s calls to netif_napi_add().
 	 */
 
+	xgene_enet_delete_desc_rings(pdata);
+
+err2:
 	if (pdata->mdio_driver)
 		xgene_enet_phy_disconnect(pdata);
 	else if (phy_interface_mode_is_rgmii(pdata->phy_mode))
 		xgene_enet_mdio_remove(pdata);
-err1:
-	xgene_enet_delete_desc_rings(pdata);
 err:
 	free_netdev(ndev);
 	return ret;
-- 
2.7.4
