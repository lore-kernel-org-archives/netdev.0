From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] sky2: fix transmit DMA map leakage
Date: Mon, 1 Feb 2010 15:41:47 -0800
Message-ID: <20100201154147.5bb0b2c7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Michael Breuer <mbreuer@majjas.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48849 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918Ab0BAXqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 18:46:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The book keeping structure for transmit always had the flags value
cleared so transmit DMA maps were never released correctly.
Based on patch by Jarek Poplawski, problem observed by Michael Breuer.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--
This patch is against net-next but it should go to 2.6.33 and stable
as well.

--- a/drivers/net/sky2.c	2010-02-01 10:07:42.676296236 -0800
+++ b/drivers/net/sky2.c	2010-02-01 10:18:12.575044064 -0800
@@ -1025,11 +1025,8 @@ static void sky2_prefetch_init(struct sk
 static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2, u16 *slot)
 {
 	struct sky2_tx_le *le = sky2->tx_le + *slot;
-	struct tx_ring_info *re = sky2->tx_ring + *slot;
 
 	*slot = RING_NEXT(*slot, sky2->tx_ring_size);
-	re->flags = 0;
-	re->skb = NULL;
 	le->ctrl = 0;
 	return le;
 }
@@ -1622,8 +1619,7 @@ static unsigned tx_le_req(const struct s
 	return count;
 }
 
-static void sky2_tx_unmap(struct pci_dev *pdev,
-			  const struct tx_ring_info *re)
+static void sky2_tx_unmap(struct pci_dev *pdev, struct tx_ring_info *re)
 {
 	if (re->flags & TX_MAP_SINGLE)
 		pci_unmap_single(pdev, pci_unmap_addr(re, mapaddr),
@@ -1633,6 +1629,7 @@ static void sky2_tx_unmap(struct pci_dev
 		pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
 			       pci_unmap_len(re, maplen),
 			       PCI_DMA_TODEVICE);
+	re->flags = 0;
 }
 
 /*
@@ -1839,6 +1836,7 @@ static void sky2_tx_complete(struct sky2
 			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += skb->len;
 
+			re->skb = NULL;
 			dev_kfree_skb_any(skb);
 
 			sky2->tx_next = RING_NEXT(idx, sky2->tx_ring_size);
