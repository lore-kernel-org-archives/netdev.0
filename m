From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: systemport: Free DMA coherent descriptors on errors
Date: Thu, 24 Aug 2017 16:01:13 -0700
Message-ID: <20170824230113.15283-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36070 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753411AbdHXXBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 19:01:20 -0400
Received: by mail-wr0-f193.google.com with SMTP id p8so500788wrf.3
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:01:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case bcm_sysport_init_tx_ring() is not able to allocate ring->cbs, we
would return with an error, and call bcm_sysport_fini_tx_ring() and it
would see that ring->cbs is NULL and do nothing. This would leak the
coherent DMA descriptor area, so we need to free it on error before
returning.

Reported-by: Eric Dumazet <edumazet@gmail.com>
Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index e6add99cc31c..c28fa5a8734c 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1346,6 +1346,8 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 
 	ring->cbs = kcalloc(size, sizeof(struct bcm_sysport_cb), GFP_KERNEL);
 	if (!ring->cbs) {
+		dma_free_coherent(kdev, sizeof(struct dma_desc),
+				  ring->desc_cpu, ring->desc_dma);
 		netif_err(priv, hw, priv->netdev, "CB allocation failed\n");
 		return -ENOMEM;
 	}
-- 
2.9.3
