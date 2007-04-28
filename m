From: olof@lixom.net (Olof Johansson)
Subject: [PATCH v3] [1/10] pasemi_mac: A couple of minor bugfixes.
Date: Sat, 28 Apr 2007 15:36:40 -0500
Message-ID: <20070428203640.GB4331@lixom.net>
References: <20070428203624.GA4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:38598 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145AbXD1UgE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:36:04 -0400
Content-Disposition: inline
In-Reply-To: <20070428203624.GA4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bugfixes:

* Move the wake_queue logic from tx_intr to clean_tx
* Always do wake_queue even if queue wasn't full before clean since
  it's safe to do
* Fix polarity in checks in pasemi_mac_close

Signed-off-by: Olof Johansson <olof@lixom.net>


Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -476,6 +476,8 @@ static int pasemi_mac_clean_tx(struct pa
 	mac->tx->next_to_clean += count;
 	spin_unlock_irqrestore(&mac->tx->lock, flags);
 
+	netif_wake_queue(mac->netdev);
+
 	return count;
 }
 
@@ -510,9 +512,6 @@ static irqreturn_t pasemi_mac_tx_intr(in
 	struct net_device *dev = data;
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int reg;
-	int was_full;
-
-	was_full = mac->tx->next_to_clean - mac->tx->next_to_use == TX_RING_SIZE;
 
 	if (!(*mac->tx_status & PAS_STATUS_INT))
 		return IRQ_NONE;
@@ -526,9 +525,6 @@ static irqreturn_t pasemi_mac_tx_intr(in
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
 			       reg);
 
-	if (was_full)
-		netif_wake_queue(dev);
-
 	return IRQ_HANDLED;
 }
 
@@ -660,40 +656,37 @@ static int pasemi_mac_close(struct net_d
 		pci_read_config_dword(mac->dma_pdev,
 				      PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
 				      &stat);
-		if (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT)
+		if (!(stat & PAS_DMA_TXCHAN_TCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (!(stat & PAS_DMA_TXCHAN_TCMDSTA_ACT)) {
+	if (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel\n");
-	}
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
 		pci_read_config_dword(mac->dma_pdev,
 				      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
 				      &stat);
-		if (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT)
+		if (!(stat & PAS_DMA_RXCHAN_CCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (!(stat & PAS_DMA_RXCHAN_CCMDSTA_ACT)) {
+	if (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx channel\n");
-	}
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
 		pci_read_config_dword(mac->dma_pdev,
 				      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
 				      &stat);
-		if (stat & PAS_DMA_RXINT_RCMDSTA_ACT)
+		if (!(stat & PAS_DMA_RXINT_RCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (!(stat & PAS_DMA_RXINT_RCMDSTA_ACT)) {
+	if (stat & PAS_DMA_RXINT_RCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx interface\n");
-	}
 
 	/* Then, disable the channel. This must be done separately from
 	 * stopping, since you can't disable when active.
