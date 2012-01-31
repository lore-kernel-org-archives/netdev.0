From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/5] r8169: fix early queue wake-up.
Date: Tue, 31 Jan 2012 14:55:00 +0100
Message-ID: <20120131135459.GA18167@electric-eye.fr.zoreil.com>
References: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52417 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab2AaOGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 09:06:23 -0500
Content-Disposition: inline
In-Reply-To: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With infinite gratitude to Eric Dumazet for allowing me to identify
the error.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d039d39..859554a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5559,7 +5559,18 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	mmiowb();
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
+		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
+		 * not miss a ring update when it notices a stopped queue.
+		 */
+		smp_wmb();
 		netif_stop_queue(dev);
+		/* Sync with rtl_tx:
+		 * - publish queue status and cur_tx ring index (write barrier)
+		 * - refresh dirty_tx ring index (read barrier).
+		 * May the current thread have a pessimistic view of the ring
+		 * status and forget to wake up queue, a racing rtl_tx thread
+		 * can't.
+		 */
 		smp_mb();
 		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
 			netif_wake_queue(dev);
@@ -5659,6 +5670,13 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
+		/* Sync with rtl8169_start_xmit:
+		 * - publish dirty_tx ring index (write barrier)
+		 * - refresh cur_tx ring index and queue status (read barrier)
+		 * May the current thread miss the stopped queue condition,
+		 * a racing xmit thread can only have a right view of the
+		 * ring status.
+		 */
 		smp_mb();
 		if (netif_queue_stopped(dev) &&
 		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
-- 
1.7.6.5
