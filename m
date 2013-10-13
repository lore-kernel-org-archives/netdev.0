From: Markus Pargmann <mpa@pengutronix.de>
Subject: [PATCH] net/ethernet: cpsw: Bugfix interrupts before enabling napi
Date: Sun, 13 Oct 2013 21:17:01 +0200
Message-ID: <1381691821-25498-1-git-send-email-mpa@pengutronix.de>
Cc: Florian Fainelli <florian@openwrt.org>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Peter Korsgaard <peter@korsgaard.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Markus Pargmann <mpa@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36600 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884Ab3JMTSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 15:18:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If interrupts happen before napi_enable was called, the driver will not
work as expected. Network transmissions are impossible in this state.
This bug can be reproduced easily by restarting the network interface in
a loop. After some time any network transmissions on the network
interface will fail.

This patch fixes the bug by enabling napi before enabling the network
interface interrupts.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 804846e..fccd9d4 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1169,9 +1169,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		}
 	}
 
+	napi_enable(&priv->napi);
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
-	napi_enable(&priv->napi);
 	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
 	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
 
-- 
1.8.4.rc3
