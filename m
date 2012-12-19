From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 4/4] solos-pci: ensure all TX packets are aligned to 4 bytes
Date: Wed, 19 Dec 2012 21:01:21 +0000
Message-ID: <1355950881-31550-4-git-send-email-dwmw2@infradead.org>
References: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
Cc: David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:53383 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab2LSVBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 16:01:37 -0500
In-Reply-To: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <David.Woodhouse@intel.com>

The FPGA can't handled unaligned DMA (yet). So copy into an aligned buffer,
if skb->data isn't suitably aligned.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c | 27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index aa4f35d..d70abe7 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -128,9 +128,11 @@ struct solos_card {
 	struct sk_buff_head cli_queue[4];
 	struct sk_buff *tx_skb[4];
 	struct sk_buff *rx_skb[4];
+	unsigned char *dma_bounce;
 	wait_queue_head_t param_wq;
 	wait_queue_head_t fw_wq;
 	int using_dma;
+	int dma_alignment;
 	int fpga_version;
 	int buffer_size;
 	int atmel_flash;
@@ -1083,7 +1085,12 @@ static uint32_t fpga_tx(struct solos_card *card)
 				tx_started |= 1 << port;
 				oldskb = skb; /* We're done with this skb already */
 			} else if (skb && card->using_dma) {
-				SKB_CB(skb)->dma_addr = pci_map_single(card->dev, skb->data,
+				unsigned char *data = skb->data;
+				if ((unsigned long)data & card->dma_alignment) {
+					data = card->dma_bounce + (BUF_SIZE * port);
+					memcpy(data, skb->data, skb->len);
+				}
+				SKB_CB(skb)->dma_addr = pci_map_single(card->dev, data,
 								       skb->len, PCI_DMA_TODEVICE);
 				card->tx_skb[port] = skb;
 				iowrite32(SKB_CB(skb)->dma_addr,
@@ -1261,18 +1268,27 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	else
 		card->atmel_flash = 0;
 
+	data32 = ioread32(card->config_regs + PORTS);
+	card->nr_ports = (data32 & 0x000000FF);
+
 	if (card->fpga_version >= DMA_SUPPORTED) {
 		pci_set_master(dev);
 		card->using_dma = 1;
+		if (1) { /* All known FPGA versions so far */
+			card->dma_alignment = 3;
+			card->dma_bounce = kmalloc(card->nr_ports * BUF_SIZE, GFP_KERNEL);
+			if (!card->dma_bounce) {
+				dev_warn(&card->dev->dev, "Failed to allocate DMA bounce buffers\n");
+				/* Fallback to MMIO doesn't work */
+				goto out_unmap_both;
+			}
+		}
 	} else {
 		card->using_dma = 0;
 		/* Set RX empty flag for all ports */
 		iowrite32(0xF0, card->config_regs + FLAGS_ADDR);
 	}
 
-	data32 = ioread32(card->config_regs + PORTS);
-	card->nr_ports = (data32 & 0x000000FF);
-
 	pci_set_drvdata(dev, card);
 
 	tasklet_init(&card->tlet, solos_bh, (unsigned long)card);
@@ -1319,6 +1335,7 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	tasklet_kill(&card->tlet);
 	
  out_unmap_both:
+	kfree(card->dma_bounce);
 	pci_set_drvdata(dev, NULL);
 	pci_iounmap(dev, card->buffers);
  out_unmap_config:
@@ -1429,6 +1446,8 @@ static void fpga_remove(struct pci_dev *dev)
 	free_irq(dev->irq, card);
 	tasklet_kill(&card->tlet);
 
+	kfree(card->dma_bounce);
+
 	/* Release device from reset */
 	iowrite32(0, card->config_regs + FPGA_MODE);
 	(void)ioread32(card->config_regs + FPGA_MODE); 
-- 
1.8.0.1
