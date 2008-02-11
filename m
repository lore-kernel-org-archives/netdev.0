From: James Chapman <jchapman@katalix.com>
Subject: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 11 Feb 2008 09:22:20 GMT
Message-ID: <200802110922.m1B9MKQ4003674@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:44484 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044AbYBKJW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 04:22:27 -0500
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <jchapman@katalix.com>)
	id 1JOUDx-0004pk-7y
	for netdev@vger.kernel.org; Mon, 11 Feb 2008 02:41:13 -0600
Received: from quickie.katalix.com (localhost.localdomain [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id m1B9MMME003675
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 09:22:22 GMT
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id m1B9MKQ4003674
	for netdev@vger.kernel.org; Mon, 11 Feb 2008 09:22:20 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix locking issues in the pppol2tp driver which can cause a kernel
crash on SMP boxes when hundreds of L2TP sessions are created/deleted
simultaneously (ISP environment). The driver was violating read_lock()
and write_lock() scheduling rules so we now consistently use the _irq
variants of the lock functions.

Signed-off-by: James Chapman <jchapman@katalix.com>

--
This patch has been verified by the ISP that discovered the problem.

If the patch is accepted, it should be pushed to the stable 2.6.23 and
2.6.24 trees.

Index: linux-2.6.24/drivers/net/pppol2tp.c
===================================================================
--- linux-2.6.24.orig/drivers/net/pppol2tp.c
+++ linux-2.6.24/drivers/net/pppol2tp.c
@@ -301,15 +301,16 @@ pppol2tp_session_find(struct pppol2tp_tu
 		pppol2tp_session_id_hash(tunnel, session_id);
 	struct pppol2tp_session *session;
 	struct hlist_node *walk;
+	unsigned long flags;
 
-	read_lock(&tunnel->hlist_lock);
+	read_lock_irqsave(&tunnel->hlist_lock, flags);
 	hlist_for_each_entry(session, walk, session_list, hlist) {
 		if (session->tunnel_addr.s_session == session_id) {
-			read_unlock(&tunnel->hlist_lock);
+			read_unlock_irqrestore(&tunnel->hlist_lock, flags);
 			return session;
 		}
 	}
-	read_unlock(&tunnel->hlist_lock);
+	read_unlock_irqrestore(&tunnel->hlist_lock, flags);
 
 	return NULL;
 }
@@ -319,15 +320,16 @@ pppol2tp_session_find(struct pppol2tp_tu
 static struct pppol2tp_tunnel *pppol2tp_tunnel_find(u16 tunnel_id)
 {
 	struct pppol2tp_tunnel *tunnel = NULL;
+	unsigned long flags;
 
-	read_lock(&pppol2tp_tunnel_list_lock);
+	read_lock_irqsave(&pppol2tp_tunnel_list_lock, flags);
 	list_for_each_entry(tunnel, &pppol2tp_tunnel_list, list) {
 		if (tunnel->stats.tunnel_id == tunnel_id) {
-			read_unlock(&pppol2tp_tunnel_list_lock);
+			read_unlock_irqrestore(&pppol2tp_tunnel_list_lock, flags);
 			return tunnel;
 		}
 	}
-	read_unlock(&pppol2tp_tunnel_list_lock);
+	read_unlock_irqrestore(&pppol2tp_tunnel_list_lock, flags);
 
 	return NULL;
 }
@@ -1099,6 +1101,7 @@ static void pppol2tp_tunnel_closeall(str
 	struct hlist_node *tmp;
 	struct pppol2tp_session *session;
 	struct sock *sk;
+	unsigned long flags;
 
 	if (tunnel == NULL)
 		BUG();
@@ -1106,7 +1109,7 @@ static void pppol2tp_tunnel_closeall(str
 	PRINTK(tunnel->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
 	       "%s: closing all sessions...\n", tunnel->name);
 
-	write_lock(&tunnel->hlist_lock);
+	write_lock_irqsave(&tunnel->hlist_lock, flags);
 	for (hash = 0; hash < PPPOL2TP_HASH_SIZE; hash++) {
 again:
 		hlist_for_each_safe(walk, tmp, &tunnel->session_hlist[hash]) {
@@ -1126,7 +1129,7 @@ again:
 			 * disappear as we're jumping between locks.
 			 */
 			sock_hold(sk);
-			write_unlock(&tunnel->hlist_lock);
+			write_unlock_irqrestore(&tunnel->hlist_lock, flags);
 			lock_sock(sk);
 
 			if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
@@ -1148,11 +1151,11 @@ again:
 			 * list so we are guaranteed to make forward
 			 * progress.
 			 */
-			write_lock(&tunnel->hlist_lock);
+			write_lock_irqsave(&tunnel->hlist_lock, flags);
 			goto again;
 		}
 	}
-	write_unlock(&tunnel->hlist_lock);
+	write_unlock_irqrestore(&tunnel->hlist_lock, flags);
 }
 
 /* Really kill the tunnel.
@@ -1160,10 +1163,12 @@ again:
  */
 static void pppol2tp_tunnel_free(struct pppol2tp_tunnel *tunnel)
 {
+	unsigned long flags;
+
 	/* Remove from socket list */
-	write_lock(&pppol2tp_tunnel_list_lock);
+	write_lock_irqsave(&pppol2tp_tunnel_list_lock, flags);
 	list_del_init(&tunnel->list);
-	write_unlock(&pppol2tp_tunnel_list_lock);
+	write_unlock_irqrestore(&pppol2tp_tunnel_list_lock, flags);
 
 	atomic_dec(&pppol2tp_tunnel_count);
 	kfree(tunnel);
@@ -1212,6 +1217,7 @@ end:
 static void pppol2tp_session_destruct(struct sock *sk)
 {
 	struct pppol2tp_session *session = NULL;
+	unsigned long flags;
 
 	if (sk->sk_user_data != NULL) {
 		struct pppol2tp_tunnel *tunnel;
@@ -1239,9 +1245,9 @@ static void pppol2tp_session_destruct(st
 				/* Delete the session socket from the
 				 * hash
 				 */
-				write_lock(&tunnel->hlist_lock);
+				write_lock_irqsave(&tunnel->hlist_lock, flags);
 				hlist_del_init(&session->hlist);
-				write_unlock(&tunnel->hlist_lock);
+				write_unlock_irqrestore(&tunnel->hlist_lock, flags);
 
 				atomic_dec(&pppol2tp_session_count);
 			}
@@ -1312,6 +1318,7 @@ static struct sock *pppol2tp_prepare_tun
 	struct sock *sk;
 	struct pppol2tp_tunnel *tunnel;
 	struct sock *ret = NULL;
+	unsigned long flags;
 
 	/* Get the tunnel UDP socket from the fd, which was opened by
 	 * the userspace L2TP daemon.
@@ -1386,9 +1393,9 @@ static struct sock *pppol2tp_prepare_tun
 
 	/* Add tunnel to our list */
 	INIT_LIST_HEAD(&tunnel->list);
-	write_lock(&pppol2tp_tunnel_list_lock);
+	write_lock_irqsave(&pppol2tp_tunnel_list_lock, flags);
 	list_add(&tunnel->list, &pppol2tp_tunnel_list);
-	write_unlock(&pppol2tp_tunnel_list_lock);
+	write_unlock_irqrestore(&pppol2tp_tunnel_list_lock, flags);
 	atomic_inc(&pppol2tp_tunnel_count);
 
 	/* Bump the reference count. The tunnel context is deleted
@@ -1462,6 +1469,7 @@ static int pppol2tp_connect(struct socke
 	struct pppol2tp_tunnel *tunnel;
 	struct dst_entry *dst;
 	int error = 0;
+	unsigned long irqflags;
 
 	lock_sock(sk);
 
@@ -1593,11 +1601,11 @@ static int pppol2tp_connect(struct socke
 	sk->sk_user_data = session;
 
 	/* Add session to the tunnel's hash list */
-	write_lock(&tunnel->hlist_lock);
+	write_lock_irqsave(&tunnel->hlist_lock, irqflags);
 	hlist_add_head(&session->hlist,
 		       pppol2tp_session_id_hash(tunnel,
 						session->tunnel_addr.s_session));
-	write_unlock(&tunnel->hlist_lock);
+	write_unlock_irqrestore(&tunnel->hlist_lock, irqflags);
 
 	atomic_inc(&pppol2tp_session_count);
 
@@ -2198,8 +2206,9 @@ static struct pppol2tp_session *next_ses
 	int found = 0;
 	int next = 0;
 	int i;
+	unsigned long flags;
 
-	read_lock(&tunnel->hlist_lock);
+	read_lock_irqsave(&tunnel->hlist_lock, flags);
 	for (i = 0; i < PPPOL2TP_HASH_SIZE; i++) {
 		hlist_for_each_entry(session, walk, &tunnel->session_hlist[i], hlist) {
 			if (curr == NULL) {
@@ -2217,7 +2226,7 @@ static struct pppol2tp_session *next_ses
 		}
 	}
 out:
-	read_unlock(&tunnel->hlist_lock);
+	read_unlock_irqrestore(&tunnel->hlist_lock, flags);
 	if (!found)
 		session = NULL;
 
@@ -2227,14 +2236,15 @@ out:
 static struct pppol2tp_tunnel *next_tunnel(struct pppol2tp_tunnel *curr)
 {
 	struct pppol2tp_tunnel *tunnel = NULL;
+	unsigned long flags;
 
-	read_lock(&pppol2tp_tunnel_list_lock);
+	read_lock_irqsave(&pppol2tp_tunnel_list_lock, flags);
 	if (list_is_last(&curr->list, &pppol2tp_tunnel_list)) {
 		goto out;
 	}
 	tunnel = list_entry(curr->list.next, struct pppol2tp_tunnel, list);
 out:
-	read_unlock(&pppol2tp_tunnel_list_lock);
+	read_unlock_irqrestore(&pppol2tp_tunnel_list_lock, flags);
 
 	return tunnel;
 }
