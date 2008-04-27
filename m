From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 6/6] sis190: account for Tx errors
Date: Sun, 27 Apr 2008 19:06:04 +0200
Message-ID: <20080427170604.GG26953@electric-eye.fr.zoreil.com>
References: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32787 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755318AbYD0RZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 13:25:47 -0400
Content-Disposition: inline
In-Reply-To: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the collision counter as well.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |   38 +++++++++++++++++++++++++++++++++++---
 1 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 20f4829..abc63b0 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -212,6 +212,12 @@ enum _DescStatusBit {
 	THOL2		= 0x20000000,
 	THOL1		= 0x10000000,
 	THOL0		= 0x00000000,
+
+	WND		= 0x00080000,
+	TABRT		= 0x00040000,
+	FIFO		= 0x00020000,
+	LINK		= 0x00010000,
+	ColCountMask	= 0x0000ffff,
 	/* RxDesc.status */
 	IPON		= 0x20000000,
 	TCPON		= 0x10000000,
@@ -653,9 +659,31 @@ static void sis190_unmap_tx_skb(struct pci_dev *pdev, struct sk_buff *skb,
 	memset(desc, 0x00, sizeof(*desc));
 }
 
+static inline int sis190_tx_pkt_err(u32 status, struct net_device_stats *stats)
+{
+#define TxErrMask	(WND | TABRT | FIFO | LINK)
+
+	if (!unlikely(status & TxErrMask))
+		return 0;
+
+	if (status & WND)
+		stats->tx_window_errors++;
+	if (status & TABRT)
+		stats->tx_aborted_errors++;
+	if (status & FIFO)
+		stats->tx_fifo_errors++;
+	if (status & LINK)
+		stats->tx_carrier_errors++;
+
+	stats->tx_errors++;
+
+	return -1;
+}
+
 static void sis190_tx_interrupt(struct net_device *dev,
 				struct sis190_private *tp, void __iomem *ioaddr)
 {
+	struct net_device_stats *stats = &dev->stats;
 	u32 pending, dirty_tx = tp->dirty_tx;
 	/*
 	 * It would not be needed if queueing was allowed to be enabled
@@ -670,15 +698,19 @@ static void sis190_tx_interrupt(struct net_device *dev,
 	for (; pending; pending--, dirty_tx++) {
 		unsigned int entry = dirty_tx % NUM_TX_DESC;
 		struct TxDesc *txd = tp->TxDescRing + entry;
+		u32 status = le32_to_cpu(txd->status);
 		struct sk_buff *skb;
 
-		if (le32_to_cpu(txd->status) & OWNbit)
+		if (status & OWNbit)
 			break;
 
 		skb = tp->Tx_skbuff[entry];
 
-		dev->stats.tx_packets++;
-		dev->stats.tx_bytes += skb->len;
+		if (likely(sis190_tx_pkt_err(status, stats) == 0)) {
+			stats->tx_packets++;
+			stats->tx_bytes += skb->len;
+			stats->collisions += ((status & ColCountMask) - 1);
+		}
 
 		sis190_unmap_tx_skb(tp->pci_dev, skb, txd);
 		tp->Tx_skbuff[entry] = NULL;
-- 
1.5.3.3

