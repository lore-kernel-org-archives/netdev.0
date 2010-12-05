From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 3/3 v2] ifb: use the lockless variants of skb_queue
Date: Sun,  5 Dec 2010 09:01:52 +0800
Message-ID: <1291510912-6979-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Jarek Poplawski <jarkao2@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:35744 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418Ab0LEBCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 20:02:35 -0500
Received: by pva4 with SMTP id 4so1646315pva.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 17:02:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rq and tq are both protected by tx queue lock, so we can simply use
the lockless variants of skb_queue.

skb_queue_splice_tail_init() is used instead of the open coded and slow
one.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ifb.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index d1e362a..9825f11 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -63,9 +63,7 @@ static void ri_tasklet(unsigned long dev)
 	txq = netdev_get_tx_queue(_dev, 0);
 	if ((skb = skb_peek(&dp->tq)) == NULL) {
 		if (__netif_tx_trylock(txq)) {
-			while ((skb = skb_dequeue(&dp->rq)) != NULL) {
-				skb_queue_tail(&dp->tq, skb);
-			}
+			skb_queue_splice_tail_init(&dp->rq, &dp->tq);
 			__netif_tx_unlock(txq);
 		} else {
 			/* reschedule */
@@ -161,7 +159,7 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	}
 
-	skb_queue_tail(&dp->rq, skb);
+	__skb_queue_tail(&dp->rq, skb);
 	if (!dp->tasklet_pending) {
 		dp->tasklet_pending = 1;
 		tasklet_schedule(&dp->ifb_tasklet);
@@ -176,8 +174,8 @@ static int ifb_close(struct net_device *dev)
 
 	tasklet_kill(&dp->ifb_tasklet);
 	netif_stop_queue(dev);
-	skb_queue_purge(&dp->rq);
-	skb_queue_purge(&dp->tq);
+	__skb_queue_purge(&dp->rq);
+	__skb_queue_purge(&dp->tq);
 	return 0;
 }
 
@@ -186,8 +184,8 @@ static int ifb_open(struct net_device *dev)
 	struct ifb_private *dp = netdev_priv(dev);
 
 	tasklet_init(&dp->ifb_tasklet, ri_tasklet, (unsigned long)dev);
-	skb_queue_head_init(&dp->rq);
-	skb_queue_head_init(&dp->tq);
+	__skb_queue_head_init(&dp->rq);
+	__skb_queue_head_init(&dp->tq);
 	netif_start_queue(dev);
 
 	return 0;
