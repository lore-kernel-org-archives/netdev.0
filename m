From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: systemport: fix DMA allocation/freeing sizes
Date: Fri, 31 Oct 2014 15:51:34 -0700
Message-ID: <1414795895-31612-2-git-send-email-f.fainelli@gmail.com>
References: <1414795895-31612-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:37954 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757131AbaJaWwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 18:52:32 -0400
Received: by mail-pa0-f54.google.com with SMTP id rd3so8523066pab.41
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 15:52:31 -0700 (PDT)
In-Reply-To: <1414795895-31612-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not be allocating a single byte of DMA coherent memory, but
instead a full-sized struct dma_desc (8 bytes).

Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 3a6778a667f4..c81bf74685c0 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1110,7 +1110,8 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 	/* We just need one DMA descriptor which is DMA-able, since writing to
 	 * the port will allocate a new descriptor in its internal linked-list
 	 */
-	p = dma_zalloc_coherent(kdev, 1, &ring->desc_dma, GFP_KERNEL);
+	p = dma_zalloc_coherent(kdev, sizeof(struct dma_desc), &ring->desc_dma,
+				GFP_KERNEL);
 	if (!p) {
 		netif_err(priv, hw, priv->netdev, "DMA alloc failed\n");
 		return -ENOMEM;
@@ -1183,7 +1184,8 @@ static void bcm_sysport_fini_tx_ring(struct bcm_sysport_priv *priv,
 	ring->cbs = NULL;
 
 	if (ring->desc_dma) {
-		dma_free_coherent(kdev, 1, ring->desc_cpu, ring->desc_dma);
+		dma_free_coherent(kdev, sizeof(struct dma_desc),
+				  ring->desc_cpu, ring->desc_dma);
 		ring->desc_dma = 0;
 	}
 	ring->size = 0;
-- 
1.9.1
