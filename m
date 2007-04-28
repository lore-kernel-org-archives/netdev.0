From: olof@lixom.net (Olof Johansson)
Subject: [RESEND] [PATCH v2] [1/5] pasemi_mac: minor bugfixes
Date: Sat, 28 Apr 2007 00:50:23 -0500
Message-ID: <20070428055023.GB22074@lixom.net>
References: <20070428054952.GA22074@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:33056 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161139AbXD1Ftw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 01:49:52 -0400
Content-Disposition: inline
In-Reply-To: <20070428054952.GA22074@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ethernet bugfixes:

* Move the was_full/wake_queue logic from tx_intr to clean_tx
* Fix polarity in checks in pasemi_mac_close


Signed-off-by: Olof Johansson <olof@lixom.net>


Index: linux-2.6/drivers/net/pasemi_mac.c
===================================================================
--- linux-2.6.orig/drivers/net/pasemi_mac.c
+++ linux-2.6/drivers/net/pasemi_mac.c
@@ -451,9 +451,12 @@ static int pasemi_mac_clean_tx(struct pa
 	struct pas_dma_xct_descr *dp;
 	int start, count;
 	int flags;
+	int was_full;
 
 	spin_lock_irqsave(&mac->tx->lock, flags);
 
+	was_full = mac->tx->next_to_clean - mac->tx->next_to_use == TX_RING_SIZE;
+
 	start = mac->tx->next_to_clean;
 	count = 0;
 
@@ -478,6 +481,9 @@ static int pasemi_mac_clean_tx(struct pa
 	mac->tx->next_to_clean += count;
 	spin_unlock_irqrestore(&mac->tx->lock, flags);
 
+	if (was_full)
+		netif_wake_queue(mac->netdev);
+
 	return count;
 }
 
@@ -512,9 +518,6 @@ static irqreturn_t pasemi_mac_tx_intr(in
 	struct net_device *dev = data;
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int reg;
-	int was_full;
-
-	was_full = mac->tx->next_to_clean - mac->tx->next_to_use == TX_RING_SIZE;
 
 	if (!(*mac->tx_status & PAS_STATUS_INT))
 		return IRQ_NONE;
@@ -528,9 +531,6 @@ static irqreturn_t pasemi_mac_tx_intr(in
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
 			       reg);
 
-	if (was_full)
-		netif_wake_queue(dev);
-
 	return IRQ_HANDLED;
 }
 
@@ -662,40 +665,37 @@ static int pasemi_mac_close(struct net_d
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
