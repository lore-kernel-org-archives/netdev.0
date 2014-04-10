From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 2/2] drivers: net: cpsw: enable interrupts after napi enable and clearing previous interrupts
Date: Thu, 10 Apr 2014 14:23:24 +0530
Message-ID: <1397120004-13195-3-git-send-email-mugunthanvnm@ti.com>
References: <1397120004-13195-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:36181 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934802AbaDJIxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 04:53:34 -0400
In-Reply-To: <1397120004-13195-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the Ethernet interface is put down and up with heavy Ethernet
traffic, then there is prossibility of an interrupt waiting in irq
controller to be processed, so when the interface is brought up again
just after enable interrupt, it goes to ISR due to the previous
unhandled interrutp and in ISR napi is not scheduled as the napi
is not enabled in ndo_open which results in disabled interrupt for
CPSW and no packets are received in cpsw. So this patch moves enabling
of interupts after napi_enable and clearing CPDMA interrupts.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 4e3d197..36aa109 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1252,6 +1252,12 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_set_coalesce(ndev, &coal);
 	}
 
+	napi_enable(&priv->napi);
+	cpdma_ctlr_start(priv->dma);
+	cpsw_intr_enable(priv);
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
+
 	prim_cpsw = cpsw_get_slave_priv(priv, 0);
 	if (prim_cpsw->irq_enabled == false) {
 		if ((priv == prim_cpsw) || !netif_running(prim_cpsw->ndev)) {
@@ -1260,12 +1266,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		}
 	}
 
-	napi_enable(&priv->napi);
-	cpdma_ctlr_start(priv->dma);
-	cpsw_intr_enable(priv);
-	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
-	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
-
 	if (priv->data.dual_emac)
 		priv->slaves[priv->emac_port].open_stat = true;
 	return 0;
-- 
1.9.2.459.g68773ac
