From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] r8169: add support for Byte Queue Limits
Date: Mon, 29 Sep 2014 22:56:49 +0200
Message-ID: <1412024209-25468-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60892 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751335AbaI2U4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:56:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tested on RTL8168d/8111d.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/realtek/r8169.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 1d81238..73c6ad1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4712,6 +4712,8 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
 	RTL_W8(ChipCmd, CmdReset);
 
 	rtl_udelay_loop_wait_low(tp, &rtl_chipcmd_cond, 100, 100);
+
+	netdev_reset_queue(tp->dev);
 }
 
 static void rtl_request_uncached_firmware(struct rtl8169_private *tp)
@@ -6592,6 +6594,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	txd->opts2 = cpu_to_le32(opts[1]);
 
+	netdev_sent_queue(dev, skb->len);
+
 	skb_tx_timestamp(skb);
 
 	wmb();
@@ -6691,6 +6695,7 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
 	unsigned int dirty_tx, tx_left;
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
@@ -6709,10 +6714,8 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			u64_stats_update_begin(&tp->tx_stats.syncp);
-			tp->tx_stats.packets++;
-			tp->tx_stats.bytes += tx_skb->skb->len;
-			u64_stats_update_end(&tp->tx_stats.syncp);
+			pkts_compl++;
+			bytes_compl += tx_skb->skb->len;
 			dev_kfree_skb_any(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
@@ -6721,6 +6724,13 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 	}
 
 	if (tp->dirty_tx != dirty_tx) {
+		netdev_completed_queue(tp->dev, pkts_compl, bytes_compl);
+
+		u64_stats_update_begin(&tp->tx_stats.syncp);
+		tp->tx_stats.packets += pkts_compl;
+		tp->tx_stats.bytes += bytes_compl;
+		u64_stats_update_end(&tp->tx_stats.syncp);
+
 		tp->dirty_tx = dirty_tx;
 		/* Sync with rtl8169_start_xmit:
 		 * - publish dirty_tx ring index (write barrier)
-- 
1.8.1.5
