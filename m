From: igorm@etf.rs
Subject: [PATCH net-next] r8169: Support for byte queue limits
Date: Mon, 19 Dec 2011 10:27:58 +0100
Message-ID: <1324286878-3950-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: davem@davemloft.net, nic_swsd@realtek.com, romieu@fr.zoreil.com,
	therbert@google.com, eric.dumazet@gmail.com,
	Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:50132 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539Ab1LSJ2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Dec 2011 04:28:03 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Changes to r8169 to use byte queue limits.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 drivers/net/ethernet/realtek/r8169.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 36b2a4b..bfdb5fd 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5326,6 +5326,7 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 {
 	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
 	tp->cur_tx = tp->dirty_tx = 0;
+	netdev_reset_queue(tp->dev);
 }
 
 static void rtl8169_schedule_work(struct net_device *dev, work_func_t task)
@@ -5460,6 +5461,8 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		txd->opts1 |= cpu_to_le32(LastFrag);
 	}
 
+	netdev_sent_queue(tp->dev, skb->len);
+
 	return cur_frag;
 
 err_out:
@@ -5624,6 +5627,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 				 void __iomem *ioaddr)
 {
 	unsigned int dirty_tx, tx_left;
+	unsigned int bytes_compl = 0;
+	int tx_compl = 0;
 
 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
@@ -5642,14 +5647,18 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += tx_skb->skb->len;
+			tx_compl++;
+			bytes_compl += tx_skb->skb->len;
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
 		dirty_tx++;
 		tx_left--;
 	}
+	dev->stats.tx_packets += tx_compl;
+	dev->stats.tx_bytes += bytes_compl;
+
+	netdev_completed_queue(dev, tx_compl, bytes_compl);
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-- 
1.7.5.4
