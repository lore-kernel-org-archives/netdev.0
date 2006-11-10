From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] spidernet: fix transmit routine.
Date: Fri, 10 Nov 2006 10:50:38 -0800
Message-ID: <20061110105038.200a74d0@freekitty>
References: <1163181046.4422.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>, Work <jklewis@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19644 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946806AbWKJTA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 14:00:27 -0500
To: jim@jklewis.com
In-Reply-To: <1163181046.4422.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Try this patch instead (I don't have the hardware to even build).


Fix spider_net transmit routine:
 1. use skb_padto properly
 2. don't return -ENOMEM. Only valid returns from device transmit
    routine are NETDEV_TX_OK, BUSY, LOCKED

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/spider_net.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 418138d..cd7f13c 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -644,22 +644,18 @@ spider_net_prepare_tx_descr(struct spide
 	struct spider_net_descr *descr;
 	dma_addr_t buf;
 	unsigned long flags;
-	int length;
 
-	length = skb->len;
-	if (length < ETH_ZLEN) {
-		if (skb_pad(skb, ETH_ZLEN-length))
-			return 0;
-		length = ETH_ZLEN;
-	}
+	if (skb_padto(skb, ETH_ZLEN))
+		return NETDEV_TX_OK;
 
-	buf = pci_map_single(card->pdev, skb->data, length, PCI_DMA_TODEVICE);
+	buf = pci_map_single(card->pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(buf)) {
 		if (netif_msg_tx_err(card) && net_ratelimit())
 			pr_err("could not iommu-map packet (%p, %i). "
-				  "Dropping packet\n", skb->data, length);
+				  "Dropping packet\n", skb->data, skb->len);
 		card->spider_stats.tx_iommu_map_error++;
-		return -ENOMEM;
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
 
 	spin_lock_irqsave(&card->tx_chain.lock, flags);
@@ -667,7 +663,7 @@ spider_net_prepare_tx_descr(struct spide
 	card->tx_chain.head = descr->next;
 
 	descr->buf_addr = buf;
-	descr->buf_size = length;
+	descr->buf_size = skb->len;
 	descr->next_descr_addr = 0;
 	descr->skb = skb;
 	descr->data_status = 0;
@@ -690,7 +686,7 @@ spider_net_prepare_tx_descr(struct spide
 	descr->prev->next_descr_addr = descr->bus_addr;
 
 	card->netdev->trans_start = jiffies; /* set netdev watchdog timer */
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int
-- 
1.4.1

