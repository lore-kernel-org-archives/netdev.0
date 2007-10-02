From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [9/11] pasemi_mac: clear out old errors on interface open
Date: Tue, 2 Oct 2007 16:27:39 -0500
Message-ID: <20071002212739.GJ2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46739 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755889AbXJBVXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:23:36 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: clear out old errors on interface open

Clear out any pending errors when an interface is brought up. Since the bits
are sticky, they might be from interface shutdown time after firmware has
used it, etc.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -903,16 +903,27 @@ static int pasemi_mac_open(struct net_de
 
 	/* enable rx if */
 	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
-			   PAS_DMA_RXINT_RCMDSTA_EN);
+			   PAS_DMA_RXINT_RCMDSTA_EN |
+			   PAS_DMA_RXINT_RCMDSTA_DROPS_M |
+			   PAS_DMA_RXINT_RCMDSTA_BP |
+			   PAS_DMA_RXINT_RCMDSTA_OO |
+			   PAS_DMA_RXINT_RCMDSTA_BT);
 
 	/* enable rx channel */
 	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
 			   PAS_DMA_RXCHAN_CCMDSTA_EN |
-			   PAS_DMA_RXCHAN_CCMDSTA_DU);
+			   PAS_DMA_RXCHAN_CCMDSTA_DU |
+			   PAS_DMA_RXCHAN_CCMDSTA_OD |
+			   PAS_DMA_RXCHAN_CCMDSTA_FD |
+			   PAS_DMA_RXCHAN_CCMDSTA_DT);
 
 	/* enable tx channel */
 	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
-			   PAS_DMA_TXCHAN_TCMDSTA_EN);
+			   PAS_DMA_TXCHAN_TCMDSTA_EN |
+			   PAS_DMA_TXCHAN_TCMDSTA_SZ |
+			   PAS_DMA_TXCHAN_TCMDSTA_DB |
+			   PAS_DMA_TXCHAN_TCMDSTA_DE |
+			   PAS_DMA_TXCHAN_TCMDSTA_DA);
 
 	pasemi_mac_replenish_rx_ring(dev, RX_RING_SIZE);
 
@@ -987,7 +998,7 @@ out_rx_resources:
 static int pasemi_mac_close(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
-	unsigned int stat;
+	unsigned int sta;
 	int retries;
 
 	if (mac->phydev) {
@@ -998,6 +1009,26 @@ static int pasemi_mac_close(struct net_d
 	netif_stop_queue(dev);
 	napi_disable(&mac->napi);
 
+	sta = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+	if (sta & (PAS_DMA_RXINT_RCMDSTA_BP |
+		      PAS_DMA_RXINT_RCMDSTA_OO |
+		      PAS_DMA_RXINT_RCMDSTA_BT))
+		printk(KERN_DEBUG "pasemi_mac: rcmdsta error: 0x%08x\n", sta);
+
+	sta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
+	if (sta & (PAS_DMA_RXCHAN_CCMDSTA_DU |
+		     PAS_DMA_RXCHAN_CCMDSTA_OD |
+		     PAS_DMA_RXCHAN_CCMDSTA_FD |
+		     PAS_DMA_RXCHAN_CCMDSTA_DT))
+		printk(KERN_DEBUG "pasemi_mac: ccmdsta error: 0x%08x\n", sta);
+
+	sta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
+	if (sta & (PAS_DMA_TXCHAN_TCMDSTA_SZ |
+		      PAS_DMA_TXCHAN_TCMDSTA_DB |
+		      PAS_DMA_TXCHAN_TCMDSTA_DE |
+		      PAS_DMA_TXCHAN_TCMDSTA_DA))
+		printk(KERN_DEBUG "pasemi_mac: tcmdsta error: 0x%08x\n", sta);
+
 	/* Clean out any pending buffers */
 	pasemi_mac_clean_tx(mac);
 	pasemi_mac_clean_rx(mac, RX_RING_SIZE);
@@ -1008,33 +1039,33 @@ static int pasemi_mac_close(struct net_d
 	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), PAS_DMA_RXCHAN_CCMDSTA_ST);
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		stat = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
-		if (!(stat & PAS_DMA_TXCHAN_TCMDSTA_ACT))
+		sta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
+		if (!(sta & PAS_DMA_TXCHAN_TCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT)
+	if (sta & PAS_DMA_TXCHAN_TCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel\n");
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		stat = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
-		if (!(stat & PAS_DMA_RXCHAN_CCMDSTA_ACT))
+		sta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
+		if (!(sta & PAS_DMA_RXCHAN_CCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT)
+	if (sta & PAS_DMA_RXCHAN_CCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx channel\n");
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		stat = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
-		if (!(stat & PAS_DMA_RXINT_RCMDSTA_ACT))
+		sta = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+		if (!(sta & PAS_DMA_RXINT_RCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (stat & PAS_DMA_RXINT_RCMDSTA_ACT)
+	if (sta & PAS_DMA_RXINT_RCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx interface\n");
 
 	/* Then, disable the channel. This must be done separately from
Index: k.org/drivers/net/pasemi_mac.h
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.h
+++ k.org/drivers/net/pasemi_mac.h
@@ -241,6 +241,10 @@ enum {
 #define    PAS_DMA_TXCHAN_TCMDSTA_EN	0x00000001	/* Enabled */
 #define    PAS_DMA_TXCHAN_TCMDSTA_ST	0x00000002	/* Stop interface */
 #define    PAS_DMA_TXCHAN_TCMDSTA_ACT	0x00010000	/* Active */
+#define    PAS_DMA_TXCHAN_TCMDSTA_SZ	0x00000800
+#define    PAS_DMA_TXCHAN_TCMDSTA_DB	0x00000400
+#define    PAS_DMA_TXCHAN_TCMDSTA_DE	0x00000200
+#define    PAS_DMA_TXCHAN_TCMDSTA_DA	0x00000100
 #define PAS_DMA_TXCHAN_CFG(c)     (0x304+(c)*_PAS_DMA_TXCHAN_STRIDE)
 #define    PAS_DMA_TXCHAN_CFG_TY_IFACE	0x00000000	/* Type = interface */
 #define    PAS_DMA_TXCHAN_CFG_TATTR_M	0x0000003c
@@ -283,6 +287,9 @@ enum {
 #define    PAS_DMA_RXCHAN_CCMDSTA_ST	0x00000002	/* Stop interface */
 #define    PAS_DMA_RXCHAN_CCMDSTA_ACT	0x00010000	/* Active */
 #define    PAS_DMA_RXCHAN_CCMDSTA_DU	0x00020000
+#define    PAS_DMA_RXCHAN_CCMDSTA_OD	0x00002000
+#define    PAS_DMA_RXCHAN_CCMDSTA_FD	0x00001000
+#define    PAS_DMA_RXCHAN_CCMDSTA_DT	0x00000800
 #define PAS_DMA_RXCHAN_CFG(c)     (0x804+(c)*_PAS_DMA_RXCHAN_STRIDE)
 #define    PAS_DMA_RXCHAN_CFG_HBU_M	0x00000380
 #define    PAS_DMA_RXCHAN_CFG_HBU_S	7
