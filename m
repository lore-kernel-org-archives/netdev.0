From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 14/14] spidernet: fix HW structures for 64 bit dma_addr_t
Date: Mon, 05 Dec 2005 22:52:34 -0500
Message-ID: <20051206040645.538783000@localhost>
References: <20051206035220.097737000@localhost>
Cc: linuxppc64-dev@ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arndb@de.ibm.com>, Jens.Osterkamp@de.ibm.com
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: paulus@samba.org
Content-Disposition: inline; filename=spidernet-dma_addr_t-fix-2.diff
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

The driver incorrectly used dma_addr_t to describe
HW structures and consequently broke when that type
was changed in 2.6.15-rc.

This changed spidernet to use u32 for 32 bit HW defined
structure elements.

From: Jens.Osterkamp@de.ibm.com
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arndb@de.ibm.com>

Index: linux-2.6.15-rc/drivers/net/spider_net.h
===================================================================
--- linux-2.6.15-rc.orig/drivers/net/spider_net.h
+++ linux-2.6.15-rc/drivers/net/spider_net.h
@@ -373,9 +373,9 @@ enum spider_net_descr_status {
 
 struct spider_net_descr {
 	/* as defined by the hardware */
-	dma_addr_t buf_addr;
+	u32 buf_addr;
 	u32 buf_size;
-	dma_addr_t next_descr_addr;
+	u32 next_descr_addr;
 	u32 dmac_cmd_status;
 	u32 result_size;
 	u32 valid_size;	/* all zeroes for tx */
Index: linux-2.6.15-rc/drivers/net/spider_net.c
===================================================================
--- linux-2.6.15-rc.orig/drivers/net/spider_net.c
+++ linux-2.6.15-rc/drivers/net/spider_net.c
@@ -480,6 +480,7 @@ static int
 spider_net_prepare_rx_descr(struct spider_net_card *card,
 			    struct spider_net_descr *descr)
 {
+	dma_addr_t buf;
 	int error = 0;
 	int offset;
 	int bufsize;
@@ -510,10 +511,11 @@ spider_net_prepare_rx_descr(struct spide
 	if (offset)
 		skb_reserve(descr->skb, SPIDER_NET_RXBUF_ALIGN - offset);
 	/* io-mmu-map the skb */
-	descr->buf_addr = pci_map_single(card->pdev, descr->skb->data,
+	buf = pci_map_single(card->pdev, descr->skb->data,
 					 SPIDER_NET_MAX_MTU,
 					 PCI_DMA_BIDIRECTIONAL);
-	if (descr->buf_addr == DMA_ERROR_CODE) {
+	descr->buf_addr = buf;
+	if (buf == DMA_ERROR_CODE) {
 		dev_kfree_skb_any(descr->skb);
 		if (netif_msg_rx_err(card))
 			pr_err("Could not iommu-map rx buffer\n");
@@ -914,15 +916,16 @@ spider_net_prepare_tx_descr(struct spide
 			    struct spider_net_descr *descr,
 			    struct sk_buff *skb)
 {
-	descr->buf_addr = pci_map_single(card->pdev, skb->data,
-					 skb->len, PCI_DMA_BIDIRECTIONAL);
-	if (descr->buf_addr == DMA_ERROR_CODE) {
+	dma_addr_t buf = pci_map_single(card->pdev, skb->data,
+					skb->len, PCI_DMA_BIDIRECTIONAL);
+	if (buf == DMA_ERROR_CODE) {
 		if (netif_msg_tx_err(card))
 			pr_err("could not iommu-map packet (%p, %i). "
 				  "Dropping packet\n", skb->data, skb->len);
 		return -ENOMEM;
 	}
 
+	descr->buf_addr = buf;
 	descr->buf_size = skb->len;
 	descr->skb = skb;
 	descr->data_status = 0;

--
