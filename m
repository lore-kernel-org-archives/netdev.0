From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 16/30] solos: Tidy up tx_mask handling for ports which need
 TX
Date: Tue, 17 Mar 2009 21:29:28 +0000
Message-ID: <1237325368.27681.345.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37664 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757952AbZCQV3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:35 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqq-0001vi-4t
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:32 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index acba08d..bf59c40 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -100,6 +100,7 @@ struct solos_card {
 	void __iomem *config_regs;
 	void __iomem *buffers;
 	int nr_ports;
+	int tx_mask;
 	struct pci_dev *dev;
 	struct atm_dev *atmdev[4];
 	struct tasklet_struct tlet;
@@ -590,15 +591,13 @@ void solos_bh(unsigned long card_arg)
 	struct solos_card *card = (void *)card_arg;
 	int port;
 	uint32_t card_flags;
-	uint32_t tx_mask;
 	uint32_t rx_done = 0;
 
 	card_flags = ioread32(card->config_regs + FLAGS_ADDR);
 
 	/* The TX bits are set if the channel is busy; clear if not. We want to
 	   invoke fpga_tx() unless _all_ the bits for active channels are set */
-	tx_mask = (1 << card->nr_ports) - 1;
-	if ((card_flags & tx_mask) != tx_mask)
+	if ((card_flags & card->tx_mask) != card->tx_mask)
 		fpga_tx(card);
 
 	for (port = 0; port < card->nr_ports; port++) {
@@ -887,15 +886,20 @@ static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 		       struct atm_vcc *vcc)
 {
 	int old_len;
+	unsigned long flags;
 
 	SKB_CB(skb)->vcc = vcc;
 
-	spin_lock(&card->tx_queue_lock);
+	spin_lock_irqsave(&card->tx_queue_lock, flags);
 	old_len = skb_queue_len(&card->tx_queue[port]);
 	skb_queue_tail(&card->tx_queue[port], skb);
-	spin_unlock(&card->tx_queue_lock);
+	if (!old_len) {
+		card->tx_mask |= (1 << port);
+	}
+	spin_unlock_irqrestore(&card->tx_queue_lock, flags);
 
-	/* If TX might need to be started, do so */
+	/* Theoretically we could just schedule the tasklet here, but
+	   that introduces latency we don't want -- it's noticeable */
 	if (!old_len)
 		fpga_tx(card);
 }
@@ -911,7 +915,7 @@ static int fpga_tx(struct solos_card *card)
 
 	spin_lock_irqsave(&card->tx_lock, flags);
 
-	tx_pending = ioread32(card->config_regs + FLAGS_ADDR);
+	tx_pending = ioread32(card->config_regs + FLAGS_ADDR) & card->tx_mask;
 
 	dev_vdbg(&card->dev->dev, "TX Flags are %X\n", tx_pending);
 
@@ -925,6 +929,8 @@ static int fpga_tx(struct solos_card *card)
 			
 			spin_lock(&card->tx_queue_lock);
 			skb = skb_dequeue(&card->tx_queue[port]);
+			if (!skb)
+				card->tx_mask &= ~(1 << port);
 			spin_unlock(&card->tx_queue_lock);
 
 			if (skb && !card->using_dma) {
-- 
1.6.0.6


