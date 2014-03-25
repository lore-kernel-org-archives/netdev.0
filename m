From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 14/54] xgmac: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:00 -0700
Message-ID: <1395727540-12148-14-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58531 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbaCYGLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:37 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in xgmac_tx_complete
that can be called in hard irq and other contexts.

Replace dev_kfree_skb with dev_kfree_skb_any in xgmac_xmit that can
be called in hard irq and other contexts.

dev_consume_skb_any is used in xgamc_tx_complete as skbs that reach
there have been successfully transmitted, dev_kfree_skby_any is used
in xgmac_xmit as skbs that are freed there are being dropped.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index d2a183c3a6ce..521dfea44b83 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -897,7 +897,7 @@ static void xgmac_tx_complete(struct xgmac_priv *priv)
 		/* Check tx error on the last segment */
 		if (desc_get_tx_ls(p)) {
 			desc_get_tx_status(priv, p);
-			dev_kfree_skb(skb);
+			dev_consume_skb_any(skb);
 		}
 
 		priv->tx_skbuff[entry] = NULL;
@@ -1105,7 +1105,7 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	len = skb_headlen(skb);
 	paddr = dma_map_single(priv->device, skb->data, len, DMA_TO_DEVICE);
 	if (dma_mapping_error(priv->device, paddr)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 	priv->tx_skbuff[entry] = skb;
@@ -1169,7 +1169,7 @@ dma_err:
 	desc = first;
 	dma_unmap_single(priv->device, desc_get_buf_addr(desc),
 			 desc_get_buf_len(desc), DMA_TO_DEVICE);
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.10.4
