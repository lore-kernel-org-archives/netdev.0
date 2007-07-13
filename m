From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 3/3] s390: af_iucv: add lock when updating accept_q
Date: Fri, 13 Jul 2007 10:50:56 +0200
Message-ID: <20070713085246.022609000@linux.vnet.ibm.com>
References: <20070713085053.530802000@linux.vnet.ibm.com>
Cc: Frank Pavlic <fpavlic@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:56555 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761763AbXGMIws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 04:52:48 -0400
Content-Disposition: inline; filename=202-iucv-locking.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

The accept_queue of an af_iucv socket will be corrupted, if
adding and deleting of entries in this queue occurs at the
same time (connect request from one client, while accept call
is processed for another client).
Solution: add locking when updating accept_q

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Acked-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    1 +
 net/iucv/af_iucv.c         |   16 ++++++++++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

Index: net-2.6-uschi/include/net/iucv/af_iucv.h
===================================================================
--- net-2.6-uschi.orig/include/net/iucv/af_iucv.h
+++ net-2.6-uschi/include/net/iucv/af_iucv.h
@@ -60,6 +60,7 @@ struct iucv_sock {
 	char			dst_user_id[8];
 	char			dst_name[8];
 	struct list_head	accept_q;
+	spinlock_t		accept_q_lock;
 	struct sock		*parent;
 	struct iucv_path	*path;
 	struct sk_buff_head	send_skb_q;
Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -219,6 +219,7 @@ static struct sock *iucv_sock_alloc(stru
 
 	sock_init_data(sock, sk);
 	INIT_LIST_HEAD(&iucv_sk(sk)->accept_q);
+	spin_lock_init(&iucv_sk(sk)->accept_q_lock);
 	skb_queue_head_init(&iucv_sk(sk)->send_skb_q);
 	skb_queue_head_init(&iucv_sk(sk)->backlog_skb_q);
 	iucv_sk(sk)->send_tag = 0;
@@ -274,15 +275,25 @@ void iucv_sock_unlink(struct iucv_sock_l
 
 void iucv_accept_enqueue(struct sock *parent, struct sock *sk)
 {
+	unsigned long flags;
+	struct iucv_sock *par = iucv_sk(parent);
+
 	sock_hold(sk);
-	list_add_tail(&iucv_sk(sk)->accept_q, &iucv_sk(parent)->accept_q);
+	spin_lock_irqsave(&par->accept_q_lock, flags);
+	list_add_tail(&iucv_sk(sk)->accept_q, &par->accept_q);
+	spin_unlock_irqrestore(&par->accept_q_lock, flags);
 	iucv_sk(sk)->parent = parent;
 	parent->sk_ack_backlog++;
 }
 
 void iucv_accept_unlink(struct sock *sk)
 {
+	unsigned long flags;
+	struct iucv_sock *par = iucv_sk(iucv_sk(sk)->parent);
+
+	spin_lock_irqsave(&par->accept_q_lock, flags);
 	list_del_init(&iucv_sk(sk)->accept_q);
+	spin_unlock_irqrestore(&par->accept_q_lock, flags);
 	iucv_sk(sk)->parent->sk_ack_backlog--;
 	iucv_sk(sk)->parent = NULL;
 	sock_put(sk);
@@ -298,8 +309,8 @@ struct sock *iucv_accept_dequeue(struct 
 		lock_sock(sk);
 
 		if (sk->sk_state == IUCV_CLOSED) {
-			release_sock(sk);
 			iucv_accept_unlink(sk);
+			release_sock(sk);
 			continue;
 		}
 
@@ -879,6 +890,7 @@ static int iucv_callback_connreq(struct 
 	/* Find out if this path belongs to af_iucv. */
 	read_lock(&iucv_sk_list.lock);
 	iucv = NULL;
+	sk = NULL;
 	sk_for_each(sk, node, &iucv_sk_list.head)
 		if (sk->sk_state == IUCV_LISTEN &&
 		    !memcmp(&iucv_sk(sk)->src_name, src_name, 8)) {

-- 
