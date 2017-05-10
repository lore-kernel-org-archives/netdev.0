From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 12/12] drivers: net: xgene: Fix redundant prefetch buffer cleanup
Date: Wed, 10 May 2017 13:45:10 -0700
Message-ID: <1494449110-23785-13-git-send-email-isubramanian@apm.com>
References: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33061 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932073AbdEJUmf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 16:42:35 -0400
Received: by mail-io0-f173.google.com with SMTP id p24so9506299ioi.0
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:42:35 -0700 (PDT)
In-Reply-To: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefetch buffer cleanup code was called twice, causing EDAC to
report errors during reboot.

[ 1130.972475] xgene-edac 78800000.edac: IOB bridge agent (BA) transaction
error
[ 1130.979584] xgene-edac 78800000.edac: IOB BA write response error
[ 1130.985648] xgene-edac 78800000.edac: IOB BA write access at 0x00.00000000
()
[ 1130.993612] xgene-edac 78800000.edac: IOB BA requestor ID 0x00002400
[ 1131.000242] xgene-edac 78800000.edac: IOB bridge agent (BA) transaction
error
...

This patch fixes the errors by,

- removing the redundant prefetch buffer cleanup from port_ops->shutdown()
- moving port_ops->shutdown() after delete_rings()

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 21 ---------------------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 20 --------------------
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 20 --------------------
 4 files changed, 1 insertion(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 3235d0c..6ac27c7 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -763,27 +763,6 @@ static void xgene_enet_clear(struct xgene_enet_pdata *pdata,
 static void xgene_gport_shutdown(struct xgene_enet_pdata *pdata)
 {
 	struct device *dev = &pdata->pdev->dev;
-	struct xgene_enet_desc_ring *ring;
-	u32 pb;
-	int i;
-
-	pb = 0;
-	for (i = 0; i < pdata->rxq_cnt; i++) {
-		ring = pdata->rx_ring[i]->buf_pool;
-		pb |= BIT(xgene_enet_get_fpsel(ring->id));
-		ring = pdata->rx_ring[i]->page_pool;
-		if (ring)
-			pb |= BIT(xgene_enet_get_fpsel(ring->id));
-
-	}
-	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIFPRESET_ADDR, pb);
-
-	pb = 0;
-	for (i = 0; i < pdata->txq_cnt; i++) {
-		ring = pdata->tx_ring[i];
-		pb |= BIT(xgene_enet_ring_bufnum(ring->id));
-	}
-	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQRESET_ADDR, pb);
 
 	if (dev->of_node) {
 		if (!IS_ERR(pdata->clk))
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 01e389d..21cd4ef 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -2159,8 +2159,8 @@ static int xgene_enet_remove(struct platform_device *pdev)
 		xgene_enet_mdio_remove(pdata);
 
 	unregister_netdev(ndev);
-	pdata->port_ops->shutdown(pdata);
 	xgene_enet_delete_desc_rings(pdata);
+	pdata->port_ops->shutdown(pdata);
 	free_netdev(ndev);
 
 	return 0;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index 31df8f3..b1a83fd 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -534,26 +534,6 @@ static void xgene_enet_clear(struct xgene_enet_pdata *pdata,
 static void xgene_enet_shutdown(struct xgene_enet_pdata *p)
 {
 	struct device *dev = &p->pdev->dev;
-	struct xgene_enet_desc_ring *ring;
-	u32 pb;
-	int i;
-
-	pb = 0;
-	for (i = 0; i < p->rxq_cnt; i++) {
-		ring = p->rx_ring[i]->buf_pool;
-		pb |= BIT(xgene_enet_get_fpsel(ring->id));
-		ring = p->rx_ring[i]->page_pool;
-		if (ring)
-			pb |= BIT(xgene_enet_get_fpsel(ring->id));
-	}
-	xgene_enet_wr_ring_if(p, ENET_CFGSSQMIFPRESET_ADDR, pb);
-
-	pb = 0;
-	for (i = 0; i < p->txq_cnt; i++) {
-		ring = p->tx_ring[i];
-		pb |= BIT(xgene_enet_ring_bufnum(ring->id));
-	}
-	xgene_enet_wr_ring_if(p, ENET_CFGSSQMIWQRESET_ADDR, pb);
 
 	if (dev->of_node) {
 		if (!IS_ERR(p->clk))
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index eab6f1c..b7d75d0 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -446,26 +446,6 @@ static void xgene_enet_xgcle_bypass(struct xgene_enet_pdata *pdata,
 static void xgene_enet_shutdown(struct xgene_enet_pdata *pdata)
 {
 	struct device *dev = &pdata->pdev->dev;
-	struct xgene_enet_desc_ring *ring;
-	u32 pb;
-	int i;
-
-	pb = 0;
-	for (i = 0; i < pdata->rxq_cnt; i++) {
-		ring = pdata->rx_ring[i]->buf_pool;
-		pb |= BIT(xgene_enet_get_fpsel(ring->id));
-		ring = pdata->rx_ring[i]->page_pool;
-		if (ring)
-			pb |= BIT(xgene_enet_get_fpsel(ring->id));
-	}
-	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIFPRESET_ADDR, pb);
-
-	pb = 0;
-	for (i = 0; i < pdata->txq_cnt; i++) {
-		ring = pdata->tx_ring[i];
-		pb |= BIT(xgene_enet_ring_bufnum(ring->id));
-	}
-	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQRESET_ADDR, pb);
 
 	if (dev->of_node) {
 		if (!IS_ERR(pdata->clk))
-- 
1.9.1
