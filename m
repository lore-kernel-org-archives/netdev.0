From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [1/11] pasemi_mac: basic error checking
Date: Tue, 2 Oct 2007 16:24:51 -0500
Message-ID: <20071002212450.GB2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46620 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755090AbXJBVUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:20:47 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: basic error checking

Add some rudimentary error checking to pasemi_mac.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -445,6 +445,38 @@ static void pasemi_mac_restart_tx_intr(s
 }
 
 
+static inline void pasemi_mac_rx_error(struct pasemi_mac *mac, u64 macrx)
+{
+	unsigned int rcmdsta, ccmdsta;
+
+	if (!netif_msg_rx_err(mac))
+		return;
+
+	rcmdsta = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+	ccmdsta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
+
+	printk(KERN_ERR "pasemi_mac: rx error. macrx %016lx, rx status %lx\n",
+		macrx, *mac->rx_status);
+
+	printk(KERN_ERR "pasemi_mac: rcmdsta %08x ccmdsta %08x\n",
+		rcmdsta, ccmdsta);
+}
+
+static inline void pasemi_mac_tx_error(struct pasemi_mac *mac, u64 mactx)
+{
+	unsigned int cmdsta;
+
+	if (!netif_msg_tx_err(mac))
+		return;
+
+	cmdsta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
+
+	printk(KERN_ERR "pasemi_mac: tx error. mactx 0x%016lx, "\
+		"tx status 0x%016lx\n", mactx, *mac->tx_status);
+
+	printk(KERN_ERR "pasemi_mac: tcmdsta 0x%08x\n", cmdsta);
+}
+
 static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 {
 	unsigned int n;
@@ -468,10 +500,13 @@ static int pasemi_mac_clean_rx(struct pa
 		prefetchw(dp);
 		macrx = dp->macrx;
 
+		if ((macrx & XCT_MACRX_E) ||
+		    (*mac->rx_status & PAS_STATUS_ERROR))
+			pasemi_mac_rx_error(mac, macrx);
+
 		if (!(macrx & XCT_MACRX_O))
 			break;
 
-
 		info = NULL;
 
 		/* We have to scan for our skb since there's no way
@@ -563,6 +598,10 @@ restart:
 	for (i = start; i < limit; i++) {
 		dp = &TX_DESC(mac, i);
 
+		if ((dp->mactx & XCT_MACTX_E) ||
+		    (*mac->tx_status & PAS_STATUS_ERROR))
+			pasemi_mac_tx_error(mac, dp->mactx);
+
 		if (unlikely(dp->mactx & XCT_MACTX_O))
 			/* Not yet transmitted */
 			break;
@@ -607,9 +646,6 @@ static irqreturn_t pasemi_mac_rx_intr(in
 	if (!(*mac->rx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
-	if (*mac->rx_status & PAS_STATUS_ERROR)
-		printk("rx_status reported error\n");
-
 	/* Don't reset packet count so it won't fire again but clear
 	 * all others.
 	 */
@@ -1230,7 +1266,7 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 		dev_err(&mac->pdev->dev, "register_netdev failed with error %d\n",
 			err);
 		goto out;
-	} else
+	} else if netif_msg_probe(mac)
 		printk(KERN_INFO "%s: PA Semi %s: intf %d, txch %d, rxch %d, "
 		       "hw addr %s\n",
 		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
