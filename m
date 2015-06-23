From: Suman Tripathi <stripathi@apm.com>
Subject: [PATCH net-next v0 4/4] drivers: net: xgene: Check for IS_ERR rather than NULL for clock.
Date: Tue, 23 Jun 2015 14:47:17 +0530
Message-ID: <1435051037-21753-5-git-send-email-stripathi@apm.com>
References: <1435051037-21753-1-git-send-email-stripathi@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, isubramanian@apm.com,
	Suman Tripathi <stripathi@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from denmail01-v4020.amcc.com ([192.195.68.30]:45524 "EHLO
	denmail01.amcc.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932273AbbFWJSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 05:18:44 -0400
In-Reply-To: <1435051037-21753-1-git-send-email-stripathi@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches fixes the code to check for IS_ERR rather
than NULL for clock interface.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Suman Tripathi <stripathi@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |  5 +++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 13 ++++++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 13 ++++++++-----
 4 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 8ff736d..a626c43 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -610,7 +610,7 @@ static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 	if (!xgene_ring_mgr_init(pdata))
 		return -ENODEV;

-	if (pdata->clk) {
+	if (!IS_ERR(pdata->clk)) {
 		clk_prepare_enable(pdata->clk);
 		clk_disable_unprepare(pdata->clk);
 		clk_prepare_enable(pdata->clk);
@@ -629,7 +629,8 @@ static int xgene_enet_reset(struct xgene_enet_pdata *pdata)

 static void xgene_gport_shutdown(struct xgene_enet_pdata *pdata)
 {
-	clk_disable_unprepare(pdata->clk);
+	if (!IS_ERR(pdata->clk))
+		clk_disable_unprepare(pdata->clk);
 }

 static int xgene_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index ed52d65..4e83d4c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1036,7 +1036,7 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk)) {
 		/* Firmware may have set up the clock already. */
-		pdata->clk = NULL;
+		dev_info(dev, "clocks have been setup already\n");
 	}

 	if (pdata->phy_mode != PHY_INTERFACE_MODE_XGMII)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index ff240b3..2e80c95 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -333,10 +333,12 @@ static int xgene_enet_reset(struct xgene_enet_pdata *p)
 {
 	if (!xgene_ring_mgr_init(p))
 		return -ENODEV;
-
-	clk_prepare_enable(p->clk);
-	clk_disable_unprepare(p->clk);
-	clk_prepare_enable(p->clk);
+
+	if (!IS_ERR(p->clk)) {
+		clk_prepare_enable(p->clk);
+		clk_disable_unprepare(p->clk);
+		clk_prepare_enable(p->clk);
+	}

 	xgene_enet_ecc_init(p);
 	xgene_enet_config_ring_if_assoc(p);
@@ -369,7 +371,8 @@ static void xgene_enet_cle_bypass(struct xgene_enet_pdata *p,

 static void xgene_enet_shutdown(struct xgene_enet_pdata *p)
 {
-	clk_disable_unprepare(p->clk);
+	if (!IS_ERR(p->clk))
+		clk_disable_unprepare(p->clk);
 }

 static void xgene_enet_link_state(struct work_struct *work)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 27ba2fe..a86cfe4 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -255,10 +255,12 @@ static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 {
 	if (!xgene_ring_mgr_init(pdata))
 		return -ENODEV;
-
-	clk_prepare_enable(pdata->clk);
-	clk_disable_unprepare(pdata->clk);
-	clk_prepare_enable(pdata->clk);
+
+	if (!IS_ERR(pdata->clk)) {
+		clk_prepare_enable(pdata->clk);
+		clk_disable_unprepare(pdata->clk);
+		clk_prepare_enable(pdata->clk);
+	}

 	xgene_enet_ecc_init(pdata);
 	xgene_enet_config_ring_if_assoc(pdata);
@@ -285,7 +287,8 @@ static void xgene_enet_xgcle_bypass(struct xgene_enet_pdata *pdata,

 static void xgene_enet_shutdown(struct xgene_enet_pdata *pdata)
 {
-	clk_disable_unprepare(pdata->clk);
+	if (!IS_ERR(pdata->clk))
+		clk_disable_unprepare(pdata->clk);
 }

 static void xgene_enet_link_state(struct work_struct *work)
--
1.8.2.1
