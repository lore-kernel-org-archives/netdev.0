From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 2/2][PPPOL2TP]: Fix SMP issues in skb reorder queue handling
Date: Wed, 5 Mar 2008 23:20:39 GMT
Message-ID: <200803052320.m25NKdVP003905@quickie.katalix.com>
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:46296 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756935AbYCEXUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 18:20:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When walking a session's packet reorder queue, use
skb_queue_walk_safe() since the list could be modified inside the
loop.

Rearrange the unlinking skbs from the reorder queue such that it
is done while the queue lock is held in pppol2tp_recv_dequeue() when
walking the skb list.

Signed-off-by: James Chapman <jchapman@katalix.com>

--
A version of this patch was suggested by Jarek Poplawski.

Index: linux-2.6.24.3/drivers/net/pppol2tp.c
===================================================================
--- linux-2.6.24.3.orig/drivers/net/pppol2tp.c
+++ linux-2.6.24.3/drivers/net/pppol2tp.c
@@ -342,10 +342,11 @@ static struct pppol2tp_tunnel *pppol2tp_
 static void pppol2tp_recv_queue_skb(struct pppol2tp_session *session, struct sk_buff *skb)
 {
 	struct sk_buff *skbp;
+	struct sk_buff *tmp;
 	u16 ns = PPPOL2TP_SKB_CB(skb)->ns;
 
 	spin_lock_bh(&session->reorder_q.lock);
-	skb_queue_walk(&session->reorder_q, skbp) {
+	skb_queue_walk_safe(&session->reorder_q, skbp, tmp) {
 		if (PPPOL2TP_SKB_CB(skbp)->ns > ns) {
 			__skb_insert(skb, skbp->prev, skbp, &session->reorder_q);
 			PRINTK(session->debug, PPPOL2TP_MSG_SEQ, KERN_DEBUG,
@@ -371,10 +372,9 @@ static void pppol2tp_recv_dequeue_skb(st
 	int length = PPPOL2TP_SKB_CB(skb)->length;
 	struct sock *session_sock = NULL;
 
-	/* We're about to requeue the skb, so unlink it and return resources
+	/* We're about to requeue the skb, so return resources
 	 * to its current owner (a socket receive buffer).
 	 */
-	skb_unlink(skb, &session->reorder_q);
 	skb_orphan(skb);
 
 	tunnel->stats.rx_packets++;
@@ -469,6 +469,11 @@ static void pppol2tp_recv_dequeue(struct
 				goto out;
 			}
 		}
+		__skb_unlink(skb, &session->reorder_q);
+
+		/* Process the skb. We release the queue lock while we
+		 * do so to let other contexts process the queue.
+		 */
 		spin_unlock_bh(&session->reorder_q.lock);
 		pppol2tp_recv_dequeue_skb(session, skb);
 		spin_lock_bh(&session->reorder_q.lock);
