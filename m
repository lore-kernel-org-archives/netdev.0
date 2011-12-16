From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 6/6] tg3: use netif_tx_start_queue instead of wake_queue when no reschedule needed
Date: Fri, 16 Dec 2011 10:19:49 -0800
Message-ID: <3fe5a24a5d5a371b64e1e200057e56d5be930cb6.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Cc: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Robin Getz <rgetz@blackfin.uclinux.org>,
	Matt Mackall <mpm@selenic.com>, Ying Cai <ycai@google.com>,
	David Decotigny <decot@googlers.com>
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:54317 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760361Ab1LPSZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:25:42 -0500
Received: by eaad1 with SMTP id d1so96861eaa.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 10:25:40 -0800 (PST)
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Cai <ycai@google.com>

This commit replaces netif_tx_wake_queue() with netif_tx_start_queue()
when __netif_schedule() is not needed. It also adds code to deal with
race condition between netif_tx_start_queue() and netif_tx_stop_queue().



Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e3f221d..311e073 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6860,9 +6860,10 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 {
 	struct sk_buff *segs, *nskb;
 	u32 frag_cnt_est = skb_shinfo(skb)->gso_segs * 3;
+	struct tg3_napi *tnapi = &tp->napi[0];
 
 	/* Estimate the number of fragments in the worst case */
-	if (unlikely(tg3_tx_avail(&tp->napi[0]) <= frag_cnt_est)) {
+	if (unlikely(tg3_tx_avail(tnapi) <= frag_cnt_est)) {
 		netif_stop_queue(tp->dev);
 
 		/* netif_tx_stop_queue() must be done before checking
@@ -6871,10 +6872,10 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 		 * netif_tx_queue_stopped().
 		 */
 		smp_mb();
-		if (tg3_tx_avail(&tp->napi[0]) <= frag_cnt_est)
+		if (tg3_tx_avail(tnapi) <= TG3_TX_WAKEUP_THRESH(tnapi))
 			return NETDEV_TX_BUSY;
 
-		netif_wake_queue(tp->dev);
+		netif_start_queue(tp->dev);
 	}
 
 	segs = skb_gso_segment(skb, tp->dev->features & ~NETIF_F_TSO);
@@ -6926,14 +6927,14 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * interrupt context.
 	 */
 	if (unlikely(budget <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_tx_queue_stopped(txq)) {
-			netif_tx_stop_queue(txq);
+		/* This is a hard error, log it. */
+		netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
 
-			/* This is a hard error, log it. */
-			netdev_err(dev,
-				   "BUG! Tx Ring full when queue awake!\n");
-		}
-		return NETDEV_TX_BUSY;
+		netif_tx_stop_queue(txq);
+		smp_mb();
+		if (tg3_tx_avail(tnapi) <= TG3_TX_WAKEUP_THRESH(tnapi))
+			return NETDEV_TX_BUSY;
+		netif_tx_start_queue(txq);
 	}
 
 	entry = tnapi->tx_prod;
@@ -7100,7 +7101,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		smp_mb();
 		if (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi))
-			netif_tx_wake_queue(txq);
+			netif_tx_start_queue(txq);
 	}
 
 	mmiowb();
-- 
1.7.3.1
