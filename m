From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 1/2][PPPOL2TP]: Make locking calls softirq-safe
Date: Wed, 5 Mar 2008 23:20:37 GMT
Message-ID: <200803052320.m25NKbr7003898@quickie.katalix.com>
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:46286 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756145AbYCEXUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 18:20:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix locking issues in the pppol2tp driver which can cause a kernel
crash on SMP boxes. There were two problems:-

1. The driver was violating read_lock() and write_lock() scheduling
   rules because it wasn't using softirq-safe locks in softirq
   contexts. So we now consistently use the _bh variants of the lock
   functions.

2. The driver was calling sk_dst_get() in pppol2tp_xmit() which was
   taking sk_dst_lock in softirq context. We now call __sk_dst_get().

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.24.3/drivers/net/pppol2tp.c
===================================================================
--- linux-2.6.24.3.orig/drivers/net/pppol2tp.c
+++ linux-2.6.24.3/drivers/net/pppol2tp.c
@@ -302,14 +302,14 @@ pppol2tp_session_find(struct pppol2tp_tu
 	struct pppol2tp_session *session;
 	struct hlist_node *walk;
 
-	read_lock(&tunnel->hlist_lock);
+	read_lock_bh(&tunnel->hlist_lock);
 	hlist_for_each_entry(session, walk, session_list, hlist) {
 		if (session->tunnel_addr.s_session == session_id) {
-			read_unlock(&tunnel->hlist_lock);
+			read_unlock_bh(&tunnel->hlist_lock);
 			return session;
 		}
 	}
-	read_unlock(&tunnel->hlist_lock);
+	read_unlock_bh(&tunnel->hlist_lock);
 
 	return NULL;
 }
@@ -320,14 +320,14 @@ static struct pppol2tp_tunnel *pppol2tp_
 {
 	struct pppol2tp_tunnel *tunnel = NULL;
 
-	read_lock(&pppol2tp_tunnel_list_lock);
+	read_lock_bh(&pppol2tp_tunnel_list_lock);
 	list_for_each_entry(tunnel, &pppol2tp_tunnel_list, list) {
 		if (tunnel->stats.tunnel_id == tunnel_id) {
-			read_unlock(&pppol2tp_tunnel_list_lock);
+			read_unlock_bh(&pppol2tp_tunnel_list_lock);
 			return tunnel;
 		}
 	}
-	read_unlock(&pppol2tp_tunnel_list_lock);
+	read_unlock_bh(&pppol2tp_tunnel_list_lock);
 
 	return NULL;
 }
@@ -344,7 +344,7 @@ static void pppol2tp_recv_queue_skb(stru
 	struct sk_buff *skbp;
 	u16 ns = PPPOL2TP_SKB_CB(skb)->ns;
 
-	spin_lock(&session->reorder_q.lock);
+	spin_lock_bh(&session->reorder_q.lock);
 	skb_queue_walk(&session->reorder_q, skbp) {
 		if (PPPOL2TP_SKB_CB(skbp)->ns > ns) {
 			__skb_insert(skb, skbp->prev, skbp, &session->reorder_q);
@@ -360,7 +360,7 @@ static void pppol2tp_recv_queue_skb(stru
 	__skb_queue_tail(&session->reorder_q, skb);
 
 out:
-	spin_unlock(&session->reorder_q.lock);
+	spin_unlock_bh(&session->reorder_q.lock);
 }
 
 /* Dequeue a single skb.
@@ -442,7 +442,7 @@ static void pppol2tp_recv_dequeue(struct
 	 * expect to send up next, dequeue it and any other
 	 * in-sequence packets behind it.
 	 */
-	spin_lock(&session->reorder_q.lock);
+	spin_lock_bh(&session->reorder_q.lock);
 	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
 		if (time_after(jiffies, PPPOL2TP_SKB_CB(skb)->expires)) {
 			session->stats.rx_seq_discards++;
@@ -469,13 +469,13 @@ static void pppol2tp_recv_dequeue(struct
 				goto out;
 			}
 		}
-		spin_unlock(&session->reorder_q.lock);
+		spin_unlock_bh(&session->reorder_q.lock);
 		pppol2tp_recv_dequeue_skb(session, skb);
-		spin_lock(&session->reorder_q.lock);
+		spin_lock_bh(&session->reorder_q.lock);
 	}
 
 out:
-	spin_unlock(&session->reorder_q.lock);
+	spin_unlock_bh(&session->reorder_q.lock);
 }
 
 /* Internal receive frame. Do the real work of receiving an L2TP data frame
@@ -1058,7 +1058,7 @@ static int pppol2tp_xmit(struct ppp_chan
 
 	/* Get routing info from the tunnel socket */
 	dst_release(skb->dst);
-	skb->dst = sk_dst_get(sk_tun);
+	skb->dst = dst_clone(__sk_dst_get(sk_tun));
 	skb_orphan(skb);
 	skb->sk = sk_tun;
 
@@ -1106,7 +1106,7 @@ static void pppol2tp_tunnel_closeall(str
 	PRINTK(tunnel->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
 	       "%s: closing all sessions...\n", tunnel->name);
 
-	write_lock(&tunnel->hlist_lock);
+	write_lock_bh(&tunnel->hlist_lock);
 	for (hash = 0; hash < PPPOL2TP_HASH_SIZE; hash++) {
 again:
 		hlist_for_each_safe(walk, tmp, &tunnel->session_hlist[hash]) {
@@ -1126,7 +1126,7 @@ again:
 			 * disappear as we're jumping between locks.
 			 */
 			sock_hold(sk);
-			write_unlock(&tunnel->hlist_lock);
+			write_unlock_bh(&tunnel->hlist_lock);
 			lock_sock(sk);
 
 			if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
@@ -1148,11 +1148,11 @@ again:
 			 * list so we are guaranteed to make forward
 			 * progress.
 			 */
-			write_lock(&tunnel->hlist_lock);
+			write_lock_bh(&tunnel->hlist_lock);
 			goto again;
 		}
 	}
-	write_unlock(&tunnel->hlist_lock);
+	write_unlock_bh(&tunnel->hlist_lock);
 }
 
 /* Really kill the tunnel.
@@ -1161,9 +1161,9 @@ again:
 static void pppol2tp_tunnel_free(struct pppol2tp_tunnel *tunnel)
 {
 	/* Remove from socket list */
-	write_lock(&pppol2tp_tunnel_list_lock);
+	write_lock_bh(&pppol2tp_tunnel_list_lock);
 	list_del_init(&tunnel->list);
-	write_unlock(&pppol2tp_tunnel_list_lock);
+	write_unlock_bh(&pppol2tp_tunnel_list_lock);
 
 	atomic_dec(&pppol2tp_tunnel_count);
 	kfree(tunnel);
@@ -1239,9 +1239,9 @@ static void pppol2tp_session_destruct(st
 				/* Delete the session socket from the
 				 * hash
 				 */
-				write_lock(&tunnel->hlist_lock);
+				write_lock_bh(&tunnel->hlist_lock);
 				hlist_del_init(&session->hlist);
-				write_unlock(&tunnel->hlist_lock);
+				write_unlock_bh(&tunnel->hlist_lock);
 
 				atomic_dec(&pppol2tp_session_count);
 			}
@@ -1386,9 +1386,9 @@ static struct sock *pppol2tp_prepare_tun
 
 	/* Add tunnel to our list */
 	INIT_LIST_HEAD(&tunnel->list);
-	write_lock(&pppol2tp_tunnel_list_lock);
+	write_lock_bh(&pppol2tp_tunnel_list_lock);
 	list_add(&tunnel->list, &pppol2tp_tunnel_list);
-	write_unlock(&pppol2tp_tunnel_list_lock);
+	write_unlock_bh(&pppol2tp_tunnel_list_lock);
 	atomic_inc(&pppol2tp_tunnel_count);
 
 	/* Bump the reference count. The tunnel context is deleted
@@ -1593,11 +1593,11 @@ static int pppol2tp_connect(struct socke
 	sk->sk_user_data = session;
 
 	/* Add session to the tunnel's hash list */
-	write_lock(&tunnel->hlist_lock);
+	write_lock_bh(&tunnel->hlist_lock);
 	hlist_add_head(&session->hlist,
 		       pppol2tp_session_id_hash(tunnel,
 						session->tunnel_addr.s_session));
-	write_unlock(&tunnel->hlist_lock);
+	write_unlock_bh(&tunnel->hlist_lock);
 
 	atomic_inc(&pppol2tp_session_count);
 
@@ -2199,7 +2199,7 @@ static struct pppol2tp_session *next_ses
 	int next = 0;
 	int i;
 
-	read_lock(&tunnel->hlist_lock);
+	read_lock_bh(&tunnel->hlist_lock);
 	for (i = 0; i < PPPOL2TP_HASH_SIZE; i++) {
 		hlist_for_each_entry(session, walk, &tunnel->session_hlist[i], hlist) {
 			if (curr == NULL) {
@@ -2217,7 +2217,7 @@ static struct pppol2tp_session *next_ses
 		}
 	}
 out:
-	read_unlock(&tunnel->hlist_lock);
+	read_unlock_bh(&tunnel->hlist_lock);
 	if (!found)
 		session = NULL;
 
@@ -2228,13 +2228,13 @@ static struct pppol2tp_tunnel *next_tunn
 {
 	struct pppol2tp_tunnel *tunnel = NULL;
 
-	read_lock(&pppol2tp_tunnel_list_lock);
+	read_lock_bh(&pppol2tp_tunnel_list_lock);
 	if (list_is_last(&curr->list, &pppol2tp_tunnel_list)) {
 		goto out;
 	}
 	tunnel = list_entry(curr->list.next, struct pppol2tp_tunnel, list);
 out:
-	read_unlock(&pppol2tp_tunnel_list_lock);
+	read_unlock_bh(&pppol2tp_tunnel_list_lock);
 
 	return tunnel;
 }
