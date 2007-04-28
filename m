From: olof@lixom.net (Olof Johansson)
Subject: [PATCH v3] [3/10] pasemi_mac: Abstract and fix up interrupt restart routines
Date: Sat, 28 Apr 2007 15:37:02 -0500
Message-ID: <20070428203702.GD4331@lixom.net>
References: <20070428203624.GA4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:38621 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145AbXD1UgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:36:25 -0400
Content-Disposition: inline
In-Reply-To: <20070428203624.GA4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Abstract out (and fix up) the interrupt restart routines, making
sure we start out in a consistent state.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -362,6 +362,42 @@ static void pasemi_mac_replenish_rx_ring
 	mac->rx->next_to_fill += count;
 }
 
+static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
+{
+	unsigned int reg, stat;
+	/* Re-enable packet count interrupts: finally
+	 * ack the packet count interrupt we got in rx_intr.
+	 */
+
+	pci_read_config_dword(mac->iob_pdev,
+			      PAS_IOB_DMA_RXCH_STAT(mac->dma_rxch),
+			      &stat);
+
+	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(stat & PAS_IOB_DMA_RXCH_STAT_CNTDEL_M)
+		| PAS_IOB_DMA_RXCH_RESET_PINTC;
+
+	pci_write_config_dword(mac->iob_pdev,
+			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch),
+			       reg);
+}
+
+static void pasemi_mac_restart_tx_intr(struct pasemi_mac *mac)
+{
+	unsigned int reg, stat;
+
+	/* Re-enable packet count interrupts */
+	pci_read_config_dword(mac->iob_pdev,
+			      PAS_IOB_DMA_TXCH_STAT(mac->dma_txch), &stat);
+
+	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(stat & PAS_IOB_DMA_TXCH_STAT_CNTDEL_M)
+		| PAS_IOB_DMA_TXCH_RESET_PINTC;
+
+	pci_write_config_dword(mac->iob_pdev,
+			       PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
+}
+
+
+
 static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 {
 	unsigned int i;
@@ -559,6 +595,10 @@ static int pasemi_mac_open(struct net_de
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
 			       PAS_IOB_DMA_RXCH_CFG_CNTTH(30));
 
+	/* Clear out any residual packet count state from firmware */
+	pasemi_mac_restart_rx_intr(mac);
+	pasemi_mac_restart_tx_intr(mac);
+
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
 			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
 
@@ -835,9 +875,7 @@ static int pasemi_mac_poll(struct net_de
 		/* all done, no more packets present */
 		netif_rx_complete(dev);
 
-		/* re-enable receive interrupts */
-		pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-				       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
+		pasemi_mac_restart_rx_intr(mac);
 		return 0;
 	} else {
 		/* used up our quantum, so reschedule */
