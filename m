From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 21/30] solos: Clean up handling of card->tx_mask a little
Date: Tue, 17 Mar 2009 21:29:31 +0000
Message-ID: <1237325371.27681.350.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37669 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758154AbZCQV3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:42 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqx-0001vx-2V
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:39 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   53 ++++++++++++++++++++++++----------------------
 1 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 5e228a3..e7691b3 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -140,7 +140,7 @@ module_param(fpga_upgrade, int, 0444);
 
 static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 		       struct atm_vcc *vcc);
-static int fpga_tx(struct solos_card *);
+static uint32_t fpga_tx(struct solos_card *);
 static irqreturn_t solos_irq(int irq, void *dev_id);
 static struct atm_vcc* find_vcc(struct atm_dev *dev, short vpi, int vci);
 static int list_vccs(int vci);
@@ -438,8 +438,6 @@ static int send_command(struct solos_card *card, int dev, const char *buf, size_
 	struct sk_buff *skb;
 	struct pkt_hdr *header;
 
-//	dev_dbg(&card->dev->dev, "size: %d\n", size);
-
 	if (size > (BUF_SIZE - sizeof(*header))) {
 		dev_dbg(&card->dev->dev, "Command is too big.  Dropping request\n");
 		return 0;
@@ -574,9 +572,9 @@ static irqreturn_t solos_irq(int irq, void *dev_id)
 	struct solos_card *card = dev_id;
 	int handled = 1;
 
-	//ACK IRQ
 	iowrite32(0, card->config_regs + IRQ_CLEAR);
 
+	/* If we're up and running, just kick the tasklet to process TX/RX */
 	if (card->atmdev[0])
 		tasklet_schedule(&card->tlet);
 	else
@@ -588,16 +586,16 @@ static irqreturn_t solos_irq(int irq, void *dev_id)
 void solos_bh(unsigned long card_arg)
 {
 	struct solos_card *card = (void *)card_arg;
-	int port;
 	uint32_t card_flags;
 	uint32_t rx_done = 0;
+	int port;
 
-	card_flags = ioread32(card->config_regs + FLAGS_ADDR);
-
-	/* The TX bits are set if the channel is busy; clear if not. We want to
-	   invoke fpga_tx() unless _all_ the bits for active channels are set */
-	if ((card_flags & card->tx_mask) != card->tx_mask)
-		fpga_tx(card);
+	/*
+	 * Since fpga_tx() is going to need to read the flags under its lock,
+	 * it can return them to us so that we don't have to hit PCI MMIO
+	 * again for the same information
+	 */
+	card_flags = fpga_tx(card);
 
 	for (port = 0; port < card->nr_ports; port++) {
 		if (card_flags & (0x10 << port)) {
@@ -892,9 +890,8 @@ static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 	spin_lock_irqsave(&card->tx_queue_lock, flags);
 	old_len = skb_queue_len(&card->tx_queue[port]);
 	skb_queue_tail(&card->tx_queue[port], skb);
-	if (!old_len) {
+	if (!old_len)
 		card->tx_mask |= (1 << port);
-	}
 	spin_unlock_irqrestore(&card->tx_queue_lock, flags);
 
 	/* Theoretically we could just schedule the tasklet here, but
@@ -903,9 +900,9 @@ static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 		fpga_tx(card);
 }
 
-static int fpga_tx(struct solos_card *card)
+static uint32_t fpga_tx(struct solos_card *card)
 {
-	uint32_t tx_pending;
+	uint32_t tx_pending, card_flags;
 	uint32_t tx_started = 0;
 	struct sk_buff *skb;
 	struct atm_vcc *vcc;
@@ -913,19 +910,24 @@ static int fpga_tx(struct solos_card *card)
 	unsigned long flags;
 
 	spin_lock_irqsave(&card->tx_lock, flags);
-
-	tx_pending = ioread32(card->config_regs + FLAGS_ADDR) & card->tx_mask;
-
-	dev_vdbg(&card->dev->dev, "TX Flags are %X\n", tx_pending);
-
-	for (port = 0; port < card->nr_ports; port++) {
-		if (card->atmdev[port] && !(tx_pending & (1 << port))) {
+	
+	card_flags = ioread32(card->config_regs + FLAGS_ADDR);
+	/*
+	 * The queue lock is required for _writing_ to tx_mask, but we're
+	 * OK to read it here without locking. The only potential update
+	 * that we could race with is in fpga_queue() where it sets a bit
+	 * for a new port... but it's going to call this function again if
+	 * it's doing that, anyway.
+	 */
+	tx_pending = card->tx_mask & ~card_flags;
+
+	for (port = 0; tx_pending; tx_pending >>= 1, port++) {
+		if (tx_pending & 1) {
 			struct sk_buff *oldskb = card->tx_skb[port];
-
 			if (oldskb)
 				pci_unmap_single(card->dev, SKB_CB(oldskb)->dma_addr,
 						 oldskb->len, PCI_DMA_TODEVICE);
-			
+
 			spin_lock(&card->tx_queue_lock);
 			skb = skb_dequeue(&card->tx_queue[port]);
 			if (!skb)
@@ -966,8 +968,9 @@ static int fpga_tx(struct solos_card *card)
 	if (tx_started)
 		iowrite32(tx_started, card->config_regs + FLAGS_ADDR);
 
+ out:
 	spin_unlock_irqrestore(&card->tx_lock, flags);
-	return 0;
+	return card_flags;
 }
 
 static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
-- 
1.6.0.6


