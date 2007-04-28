From: olof@lixom.net (Olof Johansson)
Subject: [PATCH v3] [4/10] pasemi_mac: Timer and interrupt fixes
Date: Sat, 28 Apr 2007 15:37:16 -0500
Message-ID: <20070428203716.GE4331@lixom.net>
References: <20070428203624.GA4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:50918 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbXD1Ugj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:36:39 -0400
Content-Disposition: inline
In-Reply-To: <20070428203624.GA4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timer and interrupt fixes:

* Be pickier with what kind of interrupts are acked to avoid the device to
  get out of sync with the driver state
* Set RX count threshhold to 1 (for NAPI interrupted mode), TX count
  threshold to 32.
* Set timer thresholds to current max (~16ms).


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -526,18 +526,28 @@ static irqreturn_t pasemi_mac_rx_intr(in
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int reg;
 
-	if (!(*mac->rx_status & PAS_STATUS_INT))
+	if (!(*mac->rx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
-	netif_rx_schedule(dev);
-	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0));
+	if (*mac->rx_status & PAS_STATUS_ERROR)
+		printk("rx_status reported error\n");
+
+	/* Don't reset packet count so it won't fire again but clear
+	 * all others.
+	 */
+
+	pci_read_config_dword(mac->dma_pdev, PAS_DMA_RXINT_RCMDSTA(mac->dma_if), &reg);
 
-	reg = PAS_IOB_DMA_RXCH_RESET_PINTC | PAS_IOB_DMA_RXCH_RESET_SINTC |
-	      PAS_IOB_DMA_RXCH_RESET_DINTC;
+	reg = 0;
+	if (*mac->rx_status & PAS_STATUS_SOFT)
+		reg |= PAS_IOB_DMA_RXCH_RESET_SINTC;
+	if (*mac->rx_status & PAS_STATUS_ERROR)
+		reg |= PAS_IOB_DMA_RXCH_RESET_DINTC;
 	if (*mac->rx_status & PAS_STATUS_TIMER)
 		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
 
+	netif_rx_schedule(dev);
+
 	pci_write_config_dword(mac->iob_pdev,
 			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
 
@@ -551,14 +561,17 @@ static irqreturn_t pasemi_mac_tx_intr(in
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int reg;
 
-	if (!(*mac->tx_status & PAS_STATUS_INT))
+	if (!(*mac->tx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
 	pasemi_mac_clean_tx(mac);
 
-	reg = PAS_IOB_DMA_TXCH_RESET_PINTC | PAS_IOB_DMA_TXCH_RESET_SINTC;
-	if (*mac->tx_status & PAS_STATUS_TIMER)
-		reg |= PAS_IOB_DMA_TXCH_RESET_TINTC;
+	reg = PAS_IOB_DMA_TXCH_RESET_PINTC;
+
+	if (*mac->tx_status & PAS_STATUS_SOFT)
+		reg |= PAS_IOB_DMA_TXCH_RESET_SINTC;
+	if (*mac->tx_status & PAS_STATUS_ERROR)
+		reg |= PAS_IOB_DMA_TXCH_RESET_DINTC;
 
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
 			       reg);
@@ -593,14 +606,18 @@ static int pasemi_mac_open(struct net_de
 	flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
 
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
-			       PAS_IOB_DMA_RXCH_CFG_CNTTH(30));
+			       PAS_IOB_DMA_RXCH_CFG_CNTTH(1));
+
+	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_CFG(mac->dma_txch),
+			       PAS_IOB_DMA_TXCH_CFG_CNTTH(32));
 
 	/* Clear out any residual packet count state from firmware */
 	pasemi_mac_restart_rx_intr(mac);
 	pasemi_mac_restart_tx_intr(mac);
 
+	/* 0xffffff is max value, about 16ms */
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
+			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
 
 	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
 
Index: netdev-2.6/drivers/net/pasemi_mac.h
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.h
+++ netdev-2.6/drivers/net/pasemi_mac.h
@@ -299,6 +299,7 @@ enum {
 #define    PAS_STATUS_DCNT_S		16
 #define    PAS_STATUS_BPCNT_M		0x0000ffff00000000ull
 #define    PAS_STATUS_BPCNT_S		32
+#define    PAS_STATUS_CAUSE_M		0xf000000000000000ull
 #define    PAS_STATUS_TIMER		0x1000000000000000ull
 #define    PAS_STATUS_ERROR		0x2000000000000000ull
 #define    PAS_STATUS_SOFT		0x4000000000000000ull
