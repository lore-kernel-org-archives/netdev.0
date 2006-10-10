From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 5/21]: powerpc/cell spidernet zlen min packet length
Date: Tue, 10 Oct 2006 16:01:00 -0500
Message-ID: <20061010210100.GB4381@austin.ibm.com>
References: <20061010204946.GW4381@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030374AbWJJVBF@vger.kernel.org>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20061010204946.GW4381@austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Polite device drivers pad short packets to 60 bytes, 
so that mean-spirited users don't accidentally DOS 
some other OS that can't handle short packets.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

Index: linux-2.6.18-mm2/drivers/net/spider_net.c
===================================================================
--- linux-2.6.18-mm2.orig/drivers/net/spider_net.c	2006-10-10 12:22:49.000000000 -0500
+++ linux-2.6.18-mm2/drivers/net/spider_net.c	2006-10-10 12:43:51.000000000 -0500
@@ -648,18 +648,26 @@ spider_net_prepare_tx_descr(struct spide
 {
 	struct spider_net_descr *descr = card->tx_chain.head;
 	dma_addr_t buf;
+	int length;
 
-	buf = pci_map_single(card->pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
+	length = skb->len;
+	if (length < ETH_ZLEN) {
+		if (skb_pad(skb, ETH_ZLEN-length))
+			return 0;
+		length = ETH_ZLEN;
+	}
+
+	buf = pci_map_single(card->pdev, skb->data, length, PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(buf)) {
 		if (netif_msg_tx_err(card) && net_ratelimit())
 			pr_err("could not iommu-map packet (%p, %i). "
-				  "Dropping packet\n", skb->data, skb->len);
+				  "Dropping packet\n", skb->data, length);
 		card->spider_stats.tx_iommu_map_error++;
 		return -ENOMEM;
 	}
 
 	descr->buf_addr = buf;
-	descr->buf_size = skb->len;
+	descr->buf_size = length;
 	descr->next_descr_addr = 0;
 	descr->skb = skb;
 	descr->data_status = 0;
@@ -693,6 +701,7 @@ spider_net_release_tx_descr(struct spide
 {
 	struct spider_net_descr *descr = card->tx_chain.tail;
 	struct sk_buff *skb;
+	unsigned int len;
 
 	card->tx_chain.tail = card->tx_chain.tail->next;
 	descr->dmac_cmd_status |= SPIDER_NET_DESCR_NOT_IN_USE;
@@ -701,7 +710,8 @@ spider_net_release_tx_descr(struct spide
 	skb = descr->skb;
 	if (!skb)
 		return;
-	pci_unmap_single(card->pdev, descr->buf_addr, skb->len,
+	len = skb->len < ETH_ZLEN ? ETH_ZLEN : skb->len;
+	pci_unmap_single(card->pdev, descr->buf_addr, len,
 			PCI_DMA_TODEVICE);
 	dev_kfree_skb_any(skb);
 }
