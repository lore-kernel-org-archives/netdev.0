From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: revert "add byte queue limit support".
Date: Mon, 23 Jul 2012 22:55:55 +0200
Message-ID: <20120723205555.GA4392@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	Alex =?utf-8?B?VmlsbGFjw61z?= Lasso <a_villacis@palosanto.com>,
	Josh Boyer <jwboyer@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34267 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab2GWVJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 17:09:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 036dafa28da1e2565a8529de2ae663c37b7a0060.

=46irst it appears in bisection, then reverting it solves the usual
netdev watchdog problem for different people. I don't have a proper
fix yet so get rid of it.

Bisected-and-reported-by: Alex Villac=C3=ADs Lasso <a_villacis@palosant=
o.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Josh Boyer <jwboyer@redhat.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---

 The original 036da... commit has been modified due to the newly introd=
uced
 skb_tx_timestamp in rtl8169_start_xmit. The herein included patch qual=
ifies
 for 3.4-stable as well.

 drivers/net/ethernet/realtek/r8169.c |   27 +++++---------------------=
-
 1 file changed, 5 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index d7a04e0..eb81da4 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5380,7 +5380,6 @@ static void rtl8169_tx_clear(struct rtl8169_priva=
te *tp)
 {
 	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
 	tp->cur_tx =3D tp->dirty_tx =3D 0;
-	netdev_reset_queue(tp->dev);
 }
=20
 static void rtl_reset_work(struct rtl8169_private *tp)
@@ -5535,8 +5534,6 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_b=
uff *skb,
=20
 	txd->opts2 =3D cpu_to_le32(opts[1]);
=20
-	netdev_sent_queue(dev, skb->len);
-
 	skb_tx_timestamp(skb);
=20
 	wmb();
@@ -5633,16 +5630,9 @@ static void rtl8169_pcierr_interrupt(struct net_=
device *dev)
 	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
=20
-struct rtl_txc {
-	int packets;
-	int bytes;
-};
-
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
-	struct rtl8169_stats *tx_stats =3D &tp->tx_stats;
 	unsigned int dirty_tx, tx_left;
-	struct rtl_txc txc =3D { 0, 0 };
=20
 	dirty_tx =3D tp->dirty_tx;
 	smp_rmb();
@@ -5661,24 +5651,17 @@ static void rtl_tx(struct net_device *dev, stru=
ct rtl8169_private *tp)
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			struct sk_buff *skb =3D tx_skb->skb;
-
-			txc.packets++;
-			txc.bytes +=3D skb->len;
-			dev_kfree_skb(skb);
+			u64_stats_update_begin(&tp->tx_stats.syncp);
+			tp->tx_stats.packets++;
+			tp->tx_stats.bytes +=3D tx_skb->skb->len;
+			u64_stats_update_end(&tp->tx_stats.syncp);
+			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb =3D NULL;
 		}
 		dirty_tx++;
 		tx_left--;
 	}
=20
-	u64_stats_update_begin(&tx_stats->syncp);
-	tx_stats->packets +=3D txc.packets;
-	tx_stats->bytes +=3D txc.bytes;
-	u64_stats_update_end(&tx_stats->syncp);
-
-	netdev_completed_queue(dev, txc.packets, txc.bytes);
-
 	if (tp->dirty_tx !=3D dirty_tx) {
 		tp->dirty_tx =3D dirty_tx;
 		/* Sync with rtl8169_start_xmit:
--=20
1.7.10.4
