From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Mon, 1 Feb 2010 10:20:18 -0800
Message-ID: <20100201102018.7b597992@nehalam>
References: <20100128223447.GC3109@del.dom.local>
	<4B621316.8070308@majjas.com>
	<20100128225621.GD3109@del.dom.local>
	<4B6216B9.1010802@majjas.com>
	<20100128153643.0fca3c51@nehalam>
	<4B645EF4.4050701@majjas.com>
	<20100131003449.GA11935@del.dom.local>
	<4B650D53.2010607@majjas.com>
	<4B65D0F9.2020602@majjas.com>
	<4B65FD12.7090101@majjas.com>
	<20100131221835.GA3317@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Breuer <mbreuer@majjas.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100131221835.GA3317@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the fact that re->flags is always zero without causing
other confusion.

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
