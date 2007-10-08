From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/2] af_iucv: postpone receival of iucv-packets
Date: Mon, 08 Oct 2007 10:51:21 +0200
Message-ID: <20071008085507.141934000@linux.vnet.ibm.com>
References: <20071008085119.805528000@linux.vnet.ibm.com>
Cc: heicars2@linux.vnet.ibm.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:5400 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777AbXJHIzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 04:55:09 -0400
Content-Disposition: inline; filename=712-afiucv-throttle.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

AF_IUCV socket programs may waste Linux storage, because af_iucv
allocates an skb whenever posted by the receive callback routine and
receives the message immediately. 
Message receival is now postponed if data from previous callbacks has 
not yet been transferred to the receiving socket program. Instead a 
message handle is saved in a message queue as a reminder. Once 
messages could be given to the receiving socket program, there is 
an additional checking for entries in the message queue, followed
by skb allocation and message receival if applicable.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    7 +
 net/iucv/af_iucv.c         |  215 ++++++++++++++++++++++++++-------------------
 2 files changed, 134 insertions(+), 88 deletions(-)

Index: net-2.6.24-uschi/include/net/iucv/af_iucv.h
===================================================================
--- net-2.6.24-uschi.orig/include/net/iucv/af_iucv.h
+++ net-2.6.24-uschi/include/net/iucv/af_iucv.h
@@ -50,6 +50,12 @@ struct sockaddr_iucv {
 
 
 /* Common socket structures and functions */
+struct sock_msg_q {
+	struct iucv_path	*path;
+	struct iucv_message	msg;
+	struct list_head	list;
+	spinlock_t		lock;
+};
 
 #define iucv_sk(__sk) ((struct iucv_sock *) __sk)
 
@@ -65,6 +71,7 @@ struct iucv_sock {
 	struct iucv_path	*path;
 	struct sk_buff_head	send_skb_q;
 	struct sk_buff_head	backlog_skb_q;
+	struct sock_msg_q	message_q;
 	unsigned int		send_tag;
 };
 
Index: net-2.6.24-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6.24-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6.24-uschi/net/iucv/af_iucv.c
@@ -224,6 +224,8 @@ static struct sock *iucv_sock_alloc(stru
 	INIT_LIST_HEAD(&iucv_sk(sk)->accept_q);
 	spin_lock_init(&iucv_sk(sk)->accept_q_lock);
 	skb_queue_head_init(&iucv_sk(sk)->send_skb_q);
+	INIT_LIST_HEAD(&iucv_sk(sk)->message_q.list);
+	spin_lock_init(&iucv_sk(sk)->message_q.lock);
 	skb_queue_head_init(&iucv_sk(sk)->backlog_skb_q);
 	iucv_sk(sk)->send_tag = 0;
 
@@ -673,6 +675,90 @@ out:
 	return err;
 }
 
+static int iucv_fragment_skb(struct sock *sk, struct sk_buff *skb, int len)
+{
+	int dataleft, size, copied = 0;
+	struct sk_buff *nskb;
+
+	dataleft = len;
+	while (dataleft) {
+		if (dataleft >= sk->sk_rcvbuf / 4)
+			size = sk->sk_rcvbuf / 4;
+		else
+			size = dataleft;
+
+		nskb = alloc_skb(size, GFP_ATOMIC | GFP_DMA);
+		if (!nskb)
+			return -ENOMEM;
+
+		memcpy(nskb->data, skb->data + copied, size);
+		copied += size;
+		dataleft -= size;
+
+		skb_reset_transport_header(nskb);
+		skb_reset_network_header(nskb);
+		nskb->len = size;
+
+		skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, nskb);
+	}
+
+	return 0;
+}
+
+static void iucv_process_message(struct sock *sk, struct sk_buff *skb,
+				 struct iucv_path *path,
+				 struct iucv_message *msg)
+{
+	int rc;
+
+	if (msg->flags & IPRMDATA) {
+		skb->data = NULL;
+		skb->len = 0;
+	} else {
+		rc = iucv_message_receive(path, msg, 0, skb->data,
+					  msg->length, NULL);
+		if (rc) {
+			kfree_skb(skb);
+			return;
+		}
+		if (skb->truesize >= sk->sk_rcvbuf / 4) {
+			rc = iucv_fragment_skb(sk, skb, msg->length);
+			kfree_skb(skb);
+			skb = NULL;
+			if (rc) {
+				iucv_path_sever(path, NULL);
+				return;
+			}
+			skb = skb_dequeue(&iucv_sk(sk)->backlog_skb_q);
+		} else {
+			skb_reset_transport_header(skb);
+			skb_reset_network_header(skb);
+			skb->len = msg->length;
+		}
+	}
+
+	if (sock_queue_rcv_skb(sk, skb))
+		skb_queue_head(&iucv_sk(sk)->backlog_skb_q, skb);
+}
+
+static void iucv_process_message_q(struct sock *sk)
+{
+	struct iucv_sock *iucv = iucv_sk(sk);
+	struct sk_buff *skb;
+	struct sock_msg_q *p, *n;
+
+	list_for_each_entry_safe(p, n, &iucv->message_q.list, list) {
+		skb = alloc_skb(p->msg.length, GFP_ATOMIC | GFP_DMA);
+		if (!skb)
+			break;
+		iucv_process_message(sk, skb, p->path, &p->msg);
+		list_del(&p->list);
+		kfree(p);
+		if (!skb_queue_empty(&iucv->backlog_skb_q))
+			break;
+	}
+}
+
 static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 			     struct msghdr *msg, size_t len, int flags)
 {
@@ -684,8 +770,9 @@ static int iucv_sock_recvmsg(struct kioc
 	int err = 0;
 
 	if ((sk->sk_state == IUCV_DISCONN || sk->sk_state == IUCV_SEVERED) &&
-		skb_queue_empty(&iucv->backlog_skb_q) &&
-		skb_queue_empty(&sk->sk_receive_queue))
+	    skb_queue_empty(&iucv->backlog_skb_q) &&
+	    skb_queue_empty(&sk->sk_receive_queue) &&
+	    list_empty(&iucv->message_q.list))
 		return 0;
 
 	if (flags & (MSG_OOB))
@@ -724,16 +811,23 @@ static int iucv_sock_recvmsg(struct kioc
 		kfree_skb(skb);
 
 		/* Queue backlog skbs */
-		rskb = skb_dequeue(&iucv_sk(sk)->backlog_skb_q);
+		rskb = skb_dequeue(&iucv->backlog_skb_q);
 		while (rskb) {
 			if (sock_queue_rcv_skb(sk, rskb)) {
-				skb_queue_head(&iucv_sk(sk)->backlog_skb_q,
+				skb_queue_head(&iucv->backlog_skb_q,
 						rskb);
 				break;
 			} else {
-				rskb = skb_dequeue(&iucv_sk(sk)->backlog_skb_q);
+				rskb = skb_dequeue(&iucv->backlog_skb_q);
 			}
 		}
+		if (skb_queue_empty(&iucv->backlog_skb_q)) {
+			spin_lock_bh(&iucv->message_q.lock);
+			if (!list_empty(&iucv->message_q.list))
+				iucv_process_message_q(sk);
+			spin_unlock_bh(&iucv->message_q.lock);
+		}
+
 	} else
 		skb_queue_head(&sk->sk_receive_queue, skb);
 
@@ -975,99 +1069,44 @@ static void iucv_callback_connack(struct
 	sk->sk_state_change(sk);
 }
 
-static int iucv_fragment_skb(struct sock *sk, struct sk_buff *skb, int len,
-			     struct sk_buff_head *fragmented_skb_q)
-{
-	int dataleft, size, copied = 0;
-	struct sk_buff *nskb;
-
-	dataleft = len;
-	while (dataleft) {
-		if (dataleft >= sk->sk_rcvbuf / 4)
-			size = sk->sk_rcvbuf / 4;
-		else
-			size = dataleft;
-
-		nskb = alloc_skb(size, GFP_ATOMIC | GFP_DMA);
-		if (!nskb)
-			return -ENOMEM;
-
-		memcpy(nskb->data, skb->data + copied, size);
-		copied += size;
-		dataleft -= size;
-
-		skb_reset_transport_header(nskb);
-		skb_reset_network_header(nskb);
-		nskb->len = size;
-
-		skb_queue_tail(fragmented_skb_q, nskb);
-	}
-
-	return 0;
-}
-
 static void iucv_callback_rx(struct iucv_path *path, struct iucv_message *msg)
 {
 	struct sock *sk = path->private;
 	struct iucv_sock *iucv = iucv_sk(sk);
-	struct sk_buff *skb, *fskb;
-	struct sk_buff_head fragmented_skb_q;
-	int rc;
-
-	skb_queue_head_init(&fragmented_skb_q);
+	struct sk_buff *skb;
+	struct sock_msg_q *save_msg;
+	int len;
 
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		return;
 
-	skb = alloc_skb(msg->length, GFP_ATOMIC | GFP_DMA);
-	if (!skb) {
-		iucv_path_sever(path, NULL);
-		return;
-	}
+	if (!list_empty(&iucv->message_q.list) ||
+	    !skb_queue_empty(&iucv->backlog_skb_q))
+		goto save_message;
+
+	len = atomic_read(&sk->sk_rmem_alloc);
+	len += msg->length + sizeof(struct sk_buff);
+	if (len > sk->sk_rcvbuf)
+		goto save_message;
 
-	if (msg->flags & IPRMDATA) {
-		skb->data = NULL;
-		skb->len = 0;
-	} else {
-		rc = iucv_message_receive(path, msg, 0, skb->data,
-					  msg->length, NULL);
-		if (rc) {
-			kfree_skb(skb);
-			return;
-		}
-		if (skb->truesize >= sk->sk_rcvbuf / 4) {
-			rc = iucv_fragment_skb(sk, skb, msg->length,
-					       &fragmented_skb_q);
-			kfree_skb(skb);
-			skb = NULL;
-			if (rc) {
-				iucv_path_sever(path, NULL);
-				return;
-			}
-		} else {
-			skb_reset_transport_header(skb);
-			skb_reset_network_header(skb);
-			skb->len = msg->length;
-		}
-	}
-	/* Queue the fragmented skb */
-	fskb = skb_dequeue(&fragmented_skb_q);
-	while (fskb) {
-		if (!skb_queue_empty(&iucv->backlog_skb_q))
-			skb_queue_tail(&iucv->backlog_skb_q, fskb);
-		else if (sock_queue_rcv_skb(sk, fskb))
-			skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, fskb);
-		fskb = skb_dequeue(&fragmented_skb_q);
-	}
-
-	/* Queue the original skb if it exists (was not fragmented) */
-	if (skb) {
-		if (!skb_queue_empty(&iucv->backlog_skb_q))
-			skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, skb);
-		else if (sock_queue_rcv_skb(sk, skb))
-			skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, skb);
-	}
+	skb = alloc_skb(msg->length, GFP_ATOMIC | GFP_DMA);
+	if (!skb)
+		goto save_message;
 
+	spin_lock(&iucv->message_q.lock);
+	iucv_process_message(sk, skb, path, msg);
+	spin_unlock(&iucv->message_q.lock);
+
+	return;
+
+save_message:
+	save_msg = kzalloc(sizeof(struct sock_msg_q), GFP_ATOMIC | GFP_DMA);
+	save_msg->path = path;
+	save_msg->msg = *msg;
+
+	spin_lock(&iucv->message_q.lock);
+	list_add_tail(&save_msg->list, &iucv->message_q.list);
+	spin_unlock(&iucv->message_q.lock);
 }
 
 static void iucv_callback_txdone(struct iucv_path *path,

-- 
