From: igorm@etf.rs
Subject: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri,  2 Dec 2011 14:09:59 +0100
Message-ID: <1322831399-23505-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:40687 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755332Ab1LBNKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 08:10:12 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Changes to r8169 to use byte queue limits.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 drivers/net/ethernet/realtek/r8169.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e5a6d8e..7ea428c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3773,6 +3773,7 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
 {
 	tp->dirty_tx = tp->dirty_rx = tp->cur_tx = tp->cur_rx = 0;
+	netdev_reset_queue(tp->dev);
 }
 
 static void rtl_hw_jumbo_enable(struct rtl8169_private *tp)
@@ -5458,6 +5459,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		tp->tx_skb[entry].skb = skb;
 		txd->opts1 |= cpu_to_le32(LastFrag);
 	}
+	netdev_sent_queue(tp->dev, skb->len);
 
 	return cur_frag;
 
@@ -5623,6 +5625,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 				 void __iomem *ioaddr)
 {
 	unsigned int dirty_tx, tx_left;
+	unsigned int bytes_compl = 0;
+	int tx_compl = 0;
 
 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
@@ -5641,8 +5645,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += tx_skb->skb->len;
+			bytes_compl += tx_skb->skb->len;
+			tx_compl++;
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
@@ -5650,6 +5654,10 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		tx_left--;
 	}
 
+	dev->stats.tx_packets += tx_compl;
+	dev->stats.tx_bytes += bytes_compl;
+	netdev_completed_queue(dev, tx_compl, bytes_compl);
+
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		smp_wmb();
-- 
1.7.5.4
