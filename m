From: olof@lixom.net
Subject: [patch 2/4] pasemi_mac: Interrupt ack fixes
Date: Sat, 12 May 2007 14:57:32 -0500
Message-ID: <20070512195732.GC15137@lixom.net>
References: <20070512193929.193104000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46372 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756531AbXELTyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2007 15:54:49 -0400
Content-Disposition: inline; filename=pasemi_mac-intr-fixes
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the packet count resets at interrupt time, using the cacheable
packet count status to set number of processed/received packets.

The ack count is the cumulative number of packets processed, and not
incremental.


Signed-off-by: Olof Johansson <olof@lixom.net>


Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -384,17 +384,14 @@ static void pasemi_mac_replenish_rx_ring
 
 static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
 {
-	unsigned int reg, stat;
+	unsigned int reg, pcnt;
 	/* Re-enable packet count interrupts: finally
 	 * ack the packet count interrupt we got in rx_intr.
 	 */
 
-	pci_read_config_dword(mac->iob_pdev,
-			      PAS_IOB_DMA_RXCH_STAT(mac->dma_rxch),
-			      &stat);
+	pcnt = *mac->rx_status & PAS_STATUS_PCNT_M;
 
-	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(stat & PAS_IOB_DMA_RXCH_STAT_CNTDEL_M)
-		| PAS_IOB_DMA_RXCH_RESET_PINTC;
+	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_RXCH_RESET_PINTC;
 
 	pci_write_config_dword(mac->iob_pdev,
 			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch),
@@ -403,14 +400,12 @@ static void pasemi_mac_restart_rx_intr(s
 
 static void pasemi_mac_restart_tx_intr(struct pasemi_mac *mac)
 {
-	unsigned int reg, stat;
+	unsigned int reg, pcnt;
 
 	/* Re-enable packet count interrupts */
-	pci_read_config_dword(mac->iob_pdev,
-			      PAS_IOB_DMA_TXCH_STAT(mac->dma_txch), &stat);
+	pcnt = *mac->rx_status & PAS_STATUS_PCNT_M;
 
-	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(stat & PAS_IOB_DMA_TXCH_STAT_CNTDEL_M)
-		| PAS_IOB_DMA_TXCH_RESET_PINTC;
+	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
 
 	pci_write_config_dword(mac->iob_pdev,
 			       PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
@@ -591,21 +588,24 @@ static irqreturn_t pasemi_mac_tx_intr(in
 {
 	struct net_device *dev = data;
 	struct pasemi_mac *mac = netdev_priv(dev);
-	unsigned int reg;
+	unsigned int reg, pcnt;
 
 	if (!(*mac->tx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
 	pasemi_mac_clean_tx(mac);
 
-	reg = PAS_IOB_DMA_TXCH_RESET_PINTC;
+	pcnt = *mac->tx_status & PAS_STATUS_PCNT_M;
+
+	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
 
 	if (*mac->tx_status & PAS_STATUS_SOFT)
 		reg |= PAS_IOB_DMA_TXCH_RESET_SINTC;
 	if (*mac->tx_status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_TXCH_RESET_DINTC;
 
-	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
+	pci_write_config_dword(mac->iob_pdev,
+			       PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
 			       reg);
 
 	return IRQ_HANDLED;
@@ -974,6 +974,7 @@ static int pasemi_mac_start_tx(struct sk
 	if (txring->next_to_clean - txring->next_to_use == TX_RING_SIZE) {
 		spin_unlock_irqrestore(&txring->lock, flags);
 		pasemi_mac_clean_tx(mac);
+		pasemi_mac_restart_tx_intr(mac);
 		spin_lock_irqsave(&txring->lock, flags);
 
 		if (txring->next_to_clean - txring->next_to_use ==

--
