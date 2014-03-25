From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 46/54] via-rhine: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:32 -0700
Message-ID: <1395727540-12148-46-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34627 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbaCYGLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:32 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in rhine_start_tx which
can be called in hard irq and other contexts.  Packets are only freed
in rhine_start_tx if they are dropped.

Replace dev_kfree_skb with dev_consume_skb_any in rhine_tx that can be
called in hard irq and other contexts.  rhine_tx handles successfully
transmitted packets.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/via/via-rhine.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 9d93fa120578..ce2e4d14ab31 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1676,7 +1676,7 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 		/* Must use alignment buffer. */
 		if (skb->len > PKT_BUF_SZ) {
 			/* packet too long, drop it */
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			rp->tx_skbuff[entry] = NULL;
 			dev->stats.tx_dropped++;
 			return NETDEV_TX_OK;
@@ -1696,7 +1696,7 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 			pci_map_single(rp->pdev, skb->data, skb->len,
 				       PCI_DMA_TODEVICE);
 		if (dma_mapping_error(&rp->pdev->dev, rp->tx_skbuff_dma[entry])) {
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			rp->tx_skbuff_dma[entry] = 0;
 			dev->stats.tx_dropped++;
 			return NETDEV_TX_OK;
@@ -1834,7 +1834,7 @@ static void rhine_tx(struct net_device *dev)
 					 rp->tx_skbuff[entry]->len,
 					 PCI_DMA_TODEVICE);
 		}
-		dev_kfree_skb(rp->tx_skbuff[entry]);
+		dev_consume_skb_any(rp->tx_skbuff[entry]);
 		rp->tx_skbuff[entry] = NULL;
 		entry = (++rp->dirty_tx) % TX_RING_SIZE;
 	}
-- 
1.7.10.4
