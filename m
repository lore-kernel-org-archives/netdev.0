From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 28/30] solos: Reset device on unload, free pending skbs
Date: Tue, 17 Mar 2009 21:29:36 +0000
Message-ID: <1237325376.27681.358.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37676 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758551AbZCQV3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:51 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgr6-0001wN-PE
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:48 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   30 +++++++++++++++++++++++++++++-
 1 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index eef920a..1ff7304 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1206,10 +1206,28 @@ static void atm_remove(struct solos_card *card)
 
 	for (i = 0; i < card->nr_ports; i++) {
 		if (card->atmdev[i]) {
+			struct sk_buff *skb;
+
 			dev_info(&card->dev->dev, "Unregistering ATM device %d\n", card->atmdev[i]->number);
 
 			sysfs_remove_group(&card->atmdev[i]->class_dev.kobj, &solos_attr_group);
 			atm_dev_deregister(card->atmdev[i]);
+
+			skb = card->rx_skb[i];
+			if (skb) {
+				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr,
+						 RX_DMA_SIZE, PCI_DMA_FROMDEVICE);
+				dev_kfree_skb(skb);
+			}
+			skb = card->tx_skb[i];
+			if (skb) {
+				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr,
+						 skb->len, PCI_DMA_TODEVICE);
+				dev_kfree_skb(skb);
+			}
+			while ((skb = skb_dequeue(&card->tx_queue[i])))
+				dev_kfree_skb(skb);
+ 
 		}
 	}
 }
@@ -1217,13 +1235,23 @@ static void atm_remove(struct solos_card *card)
 static void fpga_remove(struct pci_dev *dev)
 {
 	struct solos_card *card = pci_get_drvdata(dev);
+	
+	/* Disable IRQs */
+	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
+
+	/* Reset FPGA */
+	iowrite32(1, card->config_regs + FPGA_MODE);
+	(void)ioread32(card->config_regs + FPGA_MODE); 
 
 	atm_remove(card);
 
-	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
 	free_irq(dev->irq, card);
 	tasklet_kill(&card->tlet);
 
+	/* Release device from reset */
+	iowrite32(0, card->config_regs + FPGA_MODE);
+	(void)ioread32(card->config_regs + FPGA_MODE); 
+
 	pci_iounmap(dev, card->buffers);
 	pci_iounmap(dev, card->config_regs);
 
-- 
1.6.0.6


