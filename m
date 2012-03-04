From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next] r8169: add byte queue limit support.
Date: Mon, 5 Mar 2012 00:28:18 +0100
Message-ID: <20120304232818.GA32324@electric-eye.fr.zoreil.com>
References: <20120304093727.GA5115@Spy32> <1330875881.2730.15.camel@edumazet-laptop> <20120304232453.GA32314@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Junchang Wang <junchangwang@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Igor Maravic <igorm@etf.rs>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53307 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754718Ab2CDX26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 18:28:58 -0500
Content-Disposition: inline
In-Reply-To: <20120304232453.GA32314@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Btw the stuff below and the 64bits stats overlap. Both could
go together.

From: Igor Maravic <igorm@etf.rs>
Date: Mon, 5 Mar 2012 00:01:25 +0100
Subject: [PATCH 2/2] r8169: add byte queue limit support.

Nothing fancy:
- sent bytes count is notified in the start_xmit path right before
  updating the owner bit in the hardware Tx descriptor (E. Dumazet)
- avoid useless tp->dev dereferencing in start_xmit (E. Dumazet)

Use of netdev_reset_queue is favored over proper accounting in
rtl8169_tx_clear_range since the latter would need more work for the
same result (nb: said accounting degenerates to nothing in xmit_frags).

Signed-off-by: Igor Maravic <igorm@etf.rs>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index a4d7674..515a7ed 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5399,6 +5399,7 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 {
 	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
 	tp->cur_tx = tp->dirty_tx = 0;
+	netdev_reset_queue(tp->dev);
 }
 
 static void rtl_reset_work(struct rtl8169_private *tp)
@@ -5553,6 +5554,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	txd->opts2 = cpu_to_le32(opts[1]);
 
+	netdev_sent_queue(dev, skb->len);
+
 	wmb();
 
 	/* Anti gcc 2.95.3 bugware (sic) */
@@ -5647,9 +5650,16 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
+struct rtl_txc {
+	int packets;
+	int bytes;
+};
+
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
+	struct rtl8169_stats *tx_stats = &tp->tx_stats;
 	unsigned int dirty_tx, tx_left;
+	struct rtl_txc txc = { 0, 0 };
 
 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
@@ -5668,17 +5678,24 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			u64_stats_update_begin(&tp->tx_stats.syncp);
-			tp->tx_stats.packets++;
-			tp->tx_stats.bytes += tx_skb->skb->len;
-			u64_stats_update_end(&tp->tx_stats.syncp);
-			dev_kfree_skb(tx_skb->skb);
+			struct sk_buff *skb = tx_skb->skb;
+
+			txc.packets++;
+			txc.bytes += skb->len;
+			dev_kfree_skb(skb);
 			tx_skb->skb = NULL;
 		}
 		dirty_tx++;
 		tx_left--;
 	}
 
+	u64_stats_update_begin(&tx_stats->syncp);
+	tx_stats->packets += txc.packets;
+	tx_stats->bytes += txc.bytes;
+	u64_stats_update_end(&tx_stats->syncp);
+
+	netdev_completed_queue(dev, txc.packets, txc.bytes);
+
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		/* Sync with rtl8169_start_xmit:
-- 
1.7.7.6
