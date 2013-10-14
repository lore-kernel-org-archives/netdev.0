From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH 02/07] r8169: Support for byte queue limits
Date: Mon, 14 Oct 2013 20:26:18 +0200
Message-ID: <1381775183-24866-3-git-send-email-milky-kernel@mcmilk.de>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Igor Maravic <igorm@etf.rs>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:35469 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756963Ab3JNSfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 14:35:52 -0400
In-Reply-To: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to r8169 to use byte queue limits.

This driver got BQL disabled, cause there were some issues in the old byte
queue limit code itself which resulted in errors.

Here is the old thread for the revert of commit 036daf..7a0060:
http://thread.gmane.org/gmane.linux.network/238202

The rtl8169_private tx_stats struct is not touched by this patch now.

I have tested this patch on a small server in home use and it's working with
no problems for about two weeks now. (kernel 3.10.10 and fq_codel enabled)

Original-Patch-By: Igor Maravic <igorm@etf.rs>
Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/realtek/r8169.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3397cee..9cefacc 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5841,6 +5841,7 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 {
 	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
 	tp->cur_tx = tp->dirty_tx = 0;
+	netdev_reset_queue(tp->dev);
 }
 
 static void rtl_reset_work(struct rtl8169_private *tp)
@@ -6017,6 +6018,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	txd->opts2 = cpu_to_le32(opts[1]);
 
 	skb_tx_timestamp(skb);
+	netdev_sent_queue(dev, skb->len);
 
 	wmb();
 
@@ -6116,6 +6118,7 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
 	unsigned int dirty_tx, tx_left;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
@@ -6138,6 +6141,9 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 			tp->tx_stats.packets++;
 			tp->tx_stats.bytes += tx_skb->skb->len;
 			u64_stats_update_end(&tp->tx_stats.syncp);
+
+			bytes_compl += tx_skb->skb->len;
+			pkts_compl++;
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
@@ -6155,6 +6161,7 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		 * ring status.
 		 */
 		smp_mb();
+		netdev_completed_queue(dev, pkts_compl, bytes_compl);
 		if (netif_queue_stopped(dev) &&
 		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
-- 
1.8.4
