From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] r8169: fix unsigned int wraparound with TSO
Date: Wed, 9 May 2012 00:00:06 +0200
Message-ID: <20120508220006.GA22733@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: avillaci@fiec.espol.edu.ec, Thomas Pilarski <thomas.pi@arcor.de>,
	Julien Ducourthial <jducourt@free.fr>,
	Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58585 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754552Ab2EHWGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 18:06:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Ducourthial <jducourt@free.fr>

The r8169 may get stuck or show bad behaviour after activating TSO :
the net_device is not stopped when it has no more TX descriptors.
This problem comes from TX_BUFS_AVAIL which may reach -1 when all
transmit descriptors are in use. The patch simply tries to keep positive
values.

Tested with 8111d(onboard) on a D510MO, and with 8111e(onboard) on a
Zotac 890GXITX.

Signed-off-by: Julien Ducourthial <jducourt@free.fr>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---

 The patch applies to -stable as well.

 drivers/net/ethernet/realtek/r8169.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f545093..d1e3c51 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -61,8 +61,12 @@
 #define R8169_MSG_DEFAULT \
 	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN)
 
-#define TX_BUFFS_AVAIL(tp) \
-	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
+#define TX_SLOTS_AVAIL(tp) \
+	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx)
+
+/* A skbuff with nr_frags needs nr_frags+1 entries in the tx queue */
+#define TX_FRAGS_READY_FOR(tp,nr_frags) \
+	(TX_SLOTS_AVAIL(tp) >= (nr_frags + 1))
 
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
    The RTL chips use a 64 element hash table based on the Ethernet CRC. */
@@ -5115,7 +5119,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	u32 opts[2];
 	int frags;
 
-	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
+	if (unlikely(!TX_FRAGS_READY_FOR(tp, skb_shinfo(skb)->nr_frags))) {
 		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
 		goto err_stop_0;
 	}
@@ -5169,7 +5173,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	mmiowb();
 
-	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
+	if (!TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
 		 * not miss a ring update when it notices a stopped queue.
 		 */
@@ -5183,7 +5187,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 		 * can't.
 		 */
 		smp_mb();
-		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
+		if (TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS))
 			netif_wake_queue(dev);
 	}
 
@@ -5306,7 +5310,7 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		 */
 		smp_mb();
 		if (netif_queue_stopped(dev) &&
-		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
+		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
 		/*
-- 
1.7.7.6
