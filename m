From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: stmmac: Fixed the condition of extend_desc for jumbo frame
Date: Thu, 08 Aug 2013 15:30:26 +0900
Message-ID: <004701ce9400$c4ba2f10$4e2e8d30$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ks_c_5601-1987
Content-Transfer-Encoding: 7bit
Cc: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>,
	=?ks_c_5601-1987?B?J7HosbnB+Cc=?= <kgene.kim@samsung.com>,
	davem@davemloft.net, cpgs@samsung.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:12125 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771Ab3HHGa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 02:30:29 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MR700LO08QP9D50@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 08 Aug 2013 15:30:27 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixed the condition of extend_desc for jumbo frame. 
There is no check routine for extend_desc in the stmmac_jumbo_frm function.
Even though extend_desc is set if dma_tx is used instead of dma_etx.
It causes kernel panic.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index c9d942a..1ef9d8a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -33,10 +33,15 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 	struct stmmac_priv *priv = (struct stmmac_priv *)p;
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int entry = priv->cur_tx % txsize;
-	struct dma_desc *desc = priv->dma_tx + entry;
+	struct dma_desc *desc;
 	unsigned int nopaged_len = skb_headlen(skb);
 	unsigned int bmax, len;
 
+	if (priv->extend_desc)
+		desc = (struct dma_desc *)(priv->dma_etx + entry);
+	else
+		desc = priv->dma_tx + entry;
+
 	if (priv->plat->enh_desc)
 		bmax = BUF_SIZE_8KiB;
 	else
@@ -54,7 +59,11 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 						STMMAC_RING_MODE);
 		wmb();
 		entry = (++priv->cur_tx) % txsize;
-		desc = priv->dma_tx + entry;
+
+		if (priv->extend_desc)
+			desc = (struct dma_desc *)(priv->dma_etx + entry);
+		else
+			desc = priv->dma_tx + entry;
 
 		desc->des2 = dma_map_single(priv->device, skb->data + bmax,
 					    len, DMA_TO_DEVICE);
-- 
1.7.10.4
