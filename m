From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: bcmgenet: call bcmgenet_dma_teardown in bcmgenet_fini_dma
Date: Thu, 18 Sep 2014 17:48:17 -0700
Message-ID: <1411087697-19306-3-git-send-email-f.fainelli@gmail.com>
References: <1411087697-19306-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:44814 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaISAsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 20:48:35 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so2689101pad.31
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 17:48:34 -0700 (PDT)
In-Reply-To: <1411087697-19306-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not be manipulaging the DMA_CTRL registers directly by writing
0 to them to disable DMA. This is an operation that needs to be timed to
make sure the DMA engines have been properly stopped since their state
machine stops on a packet boundary, not immediately.

Make sure that tha bcmgenet_fini_dma() calls bcmgenet_dma_teardown() to
ensure a proper DMA engine state.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 11a96437862d..5d9eac37993d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1749,8 +1749,7 @@ static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 	int i;
 
 	/* disable DMA */
-	bcmgenet_rdma_writel(priv, 0, DMA_CTRL);
-	bcmgenet_tdma_writel(priv, 0, DMA_CTRL);
+	bcmgenet_dma_teardown(priv);
 
 	for (i = 0; i < priv->num_tx_bds; i++) {
 		if (priv->tx_cbs[i].skb != NULL) {
-- 
1.9.1
