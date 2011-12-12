From: igorm@etf.rs
Subject: [PATCH net-next] r8169: Support for byte queue limits
Date: Mon, 12 Dec 2011 05:00:34 -0800
Message-ID: <1323694834-2844-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:53574 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565Ab1LLNA6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 08:00:58 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Igor Maravic <igorm@etf.rs>

Changes to r8169 to use byte queue limits.

Signed-off-by: Igor Maravic <igorm@etf.rs>
Signed-off-by: Igor Maravi=C4=87 <igorm@etf.rs>
---
 drivers/net/ethernet/realtek/r8169.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 36b2a4b..bfdb5fd 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5326,6 +5326,7 @@ static void rtl8169_tx_clear(struct rtl8169_priva=
te *tp)
 {
 	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
 	tp->cur_tx =3D tp->dirty_tx =3D 0;
+	netdev_reset_queue(tp->dev);
 }
=20
 static void rtl8169_schedule_work(struct net_device *dev, work_func_t =
task)
@@ -5460,6 +5461,8 @@ static int rtl8169_xmit_frags(struct rtl8169_priv=
ate *tp, struct sk_buff *skb,
 		txd->opts1 |=3D cpu_to_le32(LastFrag);
 	}
=20
+	netdev_sent_queue(tp->dev, skb->len);
+
 	return cur_frag;
=20
 err_out:
@@ -5624,6 +5627,8 @@ static void rtl8169_tx_interrupt(struct net_devic=
e *dev,
 				 void __iomem *ioaddr)
 {
 	unsigned int dirty_tx, tx_left;
+	unsigned int bytes_compl =3D 0;
+	int tx_compl =3D 0;
=20
 	dirty_tx =3D tp->dirty_tx;
 	smp_rmb();
@@ -5642,14 +5647,18 @@ static void rtl8169_tx_interrupt(struct net_dev=
ice *dev,
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes +=3D tx_skb->skb->len;
+			tx_compl++;
+			bytes_compl +=3D tx_skb->skb->len;
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb =3D NULL;
 		}
 		dirty_tx++;
 		tx_left--;
 	}
+	dev->stats.tx_packets +=3D tx_compl;
+	dev->stats.tx_bytes +=3D bytes_compl;
+
+	netdev_completed_queue(dev, tx_compl, bytes_compl);
=20
 	if (tp->dirty_tx !=3D dirty_tx) {
 		tp->dirty_tx =3D dirty_tx;
--=20
1.7.5.4
