From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 14/30] solos: First attempt at DMA support
Date: Tue, 17 Mar 2009 21:29:26 +0000
Message-ID: <1237325366.27681.343.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37662 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758178AbZCQV3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:32 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqn-0001vP-7a
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:29 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |  118 +++++++++++++++++++++++++++++++++++-----------
 1 files changed, 90 insertions(+), 28 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index b7d4af3..63c9ad0 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -55,6 +55,8 @@
 #define FLASH_BUSY	0x60
 #define FPGA_MODE	0x5C
 #define FLASH_MODE	0x58
+#define TX_DMA_ADDR(port)	(0x40 + (4 * (port)))
+#define RX_DMA_ADDR(port)	(0x30 + (4 * (port)))
 
 #define DATA_RAM_SIZE	32768
 #define BUF_SIZE	4096
@@ -78,6 +80,14 @@ struct pkt_hdr {
 	__le16 type;
 };
 
+struct solos_skb_cb {
+	struct atm_vcc *vcc;
+	uint32_t dma_addr;
+};
+
+
+#define SKB_CB(skb)		((struct solos_skb_cb *)skb->cb)
+
 #define PKT_DATA	0
 #define PKT_COMMAND	1
 #define PKT_POPEN	3
@@ -98,8 +108,11 @@ struct solos_card {
 	struct list_head param_queue;
 	struct sk_buff_head tx_queue[4];
 	struct sk_buff_head cli_queue[4];
+	struct sk_buff *tx_skb[4];
+	struct sk_buff *rx_skb[4];
 	wait_queue_head_t param_wq;
 	wait_queue_head_t fw_wq;
+	int using_dma;
 };
 

@@ -588,44 +601,64 @@ void solos_bh(unsigned long card_arg)
 
 	for (port = 0; port < card->nr_ports; port++) {
 		if (card_flags & (0x10 << port)) {
-			struct pkt_hdr header;
+			struct pkt_hdr _hdr, *header;
 			struct sk_buff *skb;
 			struct atm_vcc *vcc;
 			int size;
 
-			rx_done |= 0x10 << port;
+			if (card->using_dma) {
+				skb = card->rx_skb[port];
+				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr, skb->len,
+						 PCI_DMA_FROMDEVICE);
+
+				card->rx_skb[port] = alloc_skb(2048, GFP_ATOMIC);
+				if (card->rx_skb[port]) {
+					SKB_CB(card->rx_skb[port])->dma_addr =
+						pci_map_single(card->dev, skb->data, skb->len,
+							       PCI_DMA_FROMDEVICE);
+					iowrite32(SKB_CB(card->rx_skb[port])->dma_addr,
+						  card->config_regs + RX_DMA_ADDR(port));
+				}
+				header = (void *)skb->data;
+				size = le16_to_cpu(header->size);
+				skb_put(skb, size + sizeof(*header));
+				skb_pull(skb, sizeof(*header));
+			} else {
+				header = &_hdr;
 
-			memcpy_fromio(&header, RX_BUF(card, port), sizeof(header));
+				rx_done |= 0x10 << port;
 
-			size = le16_to_cpu(header.size);
+				memcpy_fromio(header, RX_BUF(card, port), sizeof(*header));
 
-			skb = alloc_skb(size + 1, GFP_ATOMIC);
-			if (!skb) {
-				if (net_ratelimit())
-					dev_warn(&card->dev->dev, "Failed to allocate sk_buff for RX\n");
-				continue;
-			}
+				size = le16_to_cpu(header->size);
 
-			memcpy_fromio(skb_put(skb, size),
-				      RX_BUF(card, port) + sizeof(header),
-				      size);
+				skb = alloc_skb(size + 1, GFP_ATOMIC);
+				if (!skb) {
+					if (net_ratelimit())
+						dev_warn(&card->dev->dev, "Failed to allocate sk_buff for RX\n");
+					continue;
+				}
 
+				memcpy_fromio(skb_put(skb, size),
+					      RX_BUF(card, port) + sizeof(*header),
+					      size);
+			}
 			if (atmdebug) {
 				dev_info(&card->dev->dev, "Received: device %d\n", port);
 				dev_info(&card->dev->dev, "size: %d VPI: %d VCI: %d\n",
-					 size, le16_to_cpu(header.vpi),
-					 le16_to_cpu(header.vci));
+					 size, le16_to_cpu(header->vpi),
+					 le16_to_cpu(header->vci));
 				print_buffer(skb);
 			}
 
-			switch (le16_to_cpu(header.type)) {
+			switch (le16_to_cpu(header->type)) {
 			case PKT_DATA:
-				vcc = find_vcc(card->atmdev[port], le16_to_cpu(header.vpi),
-					       le16_to_cpu(header.vci));
+				vcc = find_vcc(card->atmdev[port], le16_to_cpu(header->vpi),
+					       le16_to_cpu(header->vci));
 				if (!vcc) {
 					if (net_ratelimit())
 						dev_warn(&card->dev->dev, "Received packet for unknown VCI.VPI %d.%d on port %d\n",
-							 le16_to_cpu(header.vci), le16_to_cpu(header.vpi),
+							 le16_to_cpu(header->vci), le16_to_cpu(header->vpi),
 							 port);
 					continue;
 				}
@@ -839,7 +872,7 @@ static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 {
 	int old_len;
 
-	*(void **)skb->cb = vcc;
+	SKB_CB(skb)->vcc = vcc;
 
 	spin_lock(&card->tx_queue_lock);
 	old_len = skb_queue_len(&card->tx_queue[port]);
@@ -881,17 +914,37 @@ static int fpga_tx(struct solos_card *card)
 					 port);
 				print_buffer(skb);
 			}
-			memcpy_toio(TX_BUF(card, port), skb->data, skb->len);
+			if (card->using_dma) {
+				if (card->tx_skb[port]) {
+					struct sk_buff *oldskb = card->tx_skb[port];
 
-			vcc = *(void **)skb->cb;
+					pci_unmap_single(card->dev, SKB_CB(oldskb)->dma_addr,
+							 oldskb->len, PCI_DMA_TODEVICE);
 
-			if (vcc) {
-				atomic_inc(&vcc->stats->tx);
-				solos_pop(vcc, skb);
-			} else
-				dev_kfree_skb_irq(skb);
+					vcc = SKB_CB(oldskb)->vcc;
 
-			tx_started |= 1 << port; //Set TX full flag
+					if (vcc) {
+						atomic_inc(&vcc->stats->tx);
+						solos_pop(vcc, oldskb);
+					} else
+						dev_kfree_skb_irq(oldskb);
+				}
+
+				SKB_CB(skb)->dma_addr = pci_map_single(card->dev, skb->data,
+							       skb->len, PCI_DMA_TODEVICE);
+				iowrite32(SKB_CB(skb)->dma_addr, card->config_regs + TX_DMA_ADDR(port));
+			} else {
+				memcpy_toio(TX_BUF(card, port), skb->data, skb->len);
+				tx_started |= 1 << port; //Set TX full flag
+
+				vcc = SKB_CB(skb)->vcc;
+
+				if (vcc) {
+					atomic_inc(&vcc->stats->tx);
+					solos_pop(vcc, skb);
+				} else
+					dev_kfree_skb_irq(skb);
+			}
 		}
 	}
 	if (tx_started)
@@ -999,6 +1052,12 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		goto out;
 	}
 
+	err = pci_set_dma_mask(dev, DMA_32BIT_MASK);
+	if (err) {
+		dev_warn(&dev->dev, "Failed to set 32-bit DMA mask\n");
+		goto out;
+	}
+
 	err = pci_request_regions(dev, "solos");
 	if (err) {
 		dev_warn(&dev->dev, "Failed to request regions\n");
@@ -1035,6 +1094,9 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	dev_info(&dev->dev, "Solos FPGA Version %d.%02d svn-%d\n",
 		 major_ver, minor_ver, fpga_ver);
 
+	if (fpga_ver > 27)
+		card->using_dma = 1;
+
 	card->nr_ports = 2; /* FIXME: Detect daughterboard */
 
 	pci_set_drvdata(dev, card);
-- 
1.6.0.6


