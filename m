From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] r8169: remove unneeded dirty_rx index
Date: Wed, 16 Jan 2013 09:01:24 +0200
Message-ID: <1358319684-32364-1-git-send-email-timo.teras@iki.fi>
References: <20130115225316.GA924@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:58159 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab3APHBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 02:01:30 -0500
Received: by mail-ea0-f176.google.com with SMTP id a13so74476eaa.21
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 23:01:29 -0800 (PST)
In-Reply-To: <20130115225316.GA924@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 6f0333b ("r8169: use 50% less ram for RX ring") the rx
ring buffers are always copied making dirty_rx useless.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 drivers/net/ethernet/realtek/r8169.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 89184f3..97fdbb1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -83,7 +83,7 @@ static const int multicast_filter_limit =3D 32;
 #define R8169_REGS_SIZE		256
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
-#define NUM_RX_DESC	256	/* Number of Rx descriptor registers */
+#define NUM_RX_DESC	256U	/* Number of Rx descriptor registers */
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
=20
@@ -727,7 +727,6 @@ struct rtl8169_private {
 	u16 mac_version;
 	u32 cur_rx; /* Index into the Rx descriptor buffer of next Rx pkt. */
 	u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
-	u32 dirty_rx;
 	u32 dirty_tx;
 	struct rtl8169_stats rx_stats;
 	struct rtl8169_stats tx_stats;
@@ -4177,7 +4176,7 @@ static void rtl_init_rxcfg(struct rtl8169_private=
 *tp)
=20
 static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
 {
-	tp->dirty_tx =3D tp->dirty_rx =3D tp->cur_tx =3D tp->cur_rx =3D 0;
+	tp->dirty_tx =3D tp->cur_tx =3D tp->cur_rx =3D 0;
 }
=20
 static void rtl_hw_jumbo_enable(struct rtl8169_private *tp)
@@ -5920,7 +5919,7 @@ static void rtl8169_pcierr_interrupt(struct net_d=
evice *dev)
 		PCI_STATUS_REC_TARGET_ABORT | PCI_STATUS_SIG_TARGET_ABORT));
=20
 	/* The infamous DAC f*ckup only happens at boot time */
-	if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
+	if ((tp->cp_cmd & PCIDAC) && !tp->cur_rx) {
 		void __iomem *ioaddr =3D tp->mmio_addr;
=20
 		netif_info(tp, intr, dev, "disabling PCI DAC\n");
@@ -6035,10 +6034,8 @@ static int rtl_rx(struct net_device *dev, struct=
 rtl8169_private *tp, u32 budget
 	unsigned int count;
=20
 	cur_rx =3D tp->cur_rx;
-	rx_left =3D NUM_RX_DESC + tp->dirty_rx - cur_rx;
-	rx_left =3D min(rx_left, budget);
=20
-	for (; rx_left > 0; rx_left--, cur_rx++) {
+	for (rx_left =3D min(budget, NUM_RX_DESC); rx_left > 0; rx_left--, cu=
r_rx++) {
 		unsigned int entry =3D cur_rx % NUM_RX_DESC;
 		struct RxDesc *desc =3D tp->RxDescArray + entry;
 		u32 status;
@@ -6123,8 +6120,6 @@ process_pkt:
 	count =3D cur_rx - tp->cur_rx;
 	tp->cur_rx =3D cur_rx;
=20
-	tp->dirty_rx +=3D count;
-
 	return count;
 }
=20
--=20
1.8.1
