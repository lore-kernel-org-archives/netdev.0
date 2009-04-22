From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 6/8] [PATCH] af_iucv: Provide new socket type SOCK_SEQPACKET
Date: Wed, 22 Apr 2009 11:26:25 +0200
Message-ID: <20090422093430.459769000@linux.vnet.ibm.com>
References: <20090422092619.451973000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:44839 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755830AbZDVJfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 05:35:19 -0400
Content-Disposition: inline; filename=610-af_iucv-seqpacket-socket.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

This patch provides the socket type SOCK_SEQPACKET in addition to
SOCK_STREAM.

AF_IUCV sockets of type SOCK_SEQPACKET supports an 1:1 mapping of
socket read or write operations to complete IUCV messages.
Socket data or IUCV message data is not fragmented as this is the
case for SOCK_STREAM sockets.

The intention is to help application developers who write
applications or device drivers using native IUCV interfaces
(Linux kernel or z/VM IUCV interfaces).

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |   73 ++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 56 insertions(+), 17 deletions(-)

Index: net-next-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-next-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-next-2.6-uschi/net/iucv/af_iucv.c
@@ -289,11 +289,22 @@ static int iucv_sock_create(struct net *
 {
 	struct sock *sk;
 
-	if (sock->type != SOCK_STREAM)
-		return -ESOCKTNOSUPPORT;
+	if (protocol && protocol != PF_IUCV)
+		return -EPROTONOSUPPORT;
 
 	sock->state = SS_UNCONNECTED;
-	sock->ops = &iucv_sock_ops;
+
+	switch (sock->type) {
+	case SOCK_STREAM:
+		sock->ops = &iucv_sock_ops;
+		break;
+	case SOCK_SEQPACKET:
+		/* currently, proto ops can handle both sk types */
+		sock->ops = &iucv_sock_ops;
+		break;
+	default:
+		return -ESOCKTNOSUPPORT;
+	}
 
 	sk = iucv_sock_alloc(sock, protocol, GFP_KERNEL);
 	if (!sk)
@@ -504,11 +515,9 @@ static int iucv_sock_connect(struct sock
 	if (sk->sk_state != IUCV_OPEN && sk->sk_state != IUCV_BOUND)
 		return -EBADFD;
 
-	if (sk->sk_type != SOCK_STREAM)
+	if (sk->sk_type != SOCK_STREAM && sk->sk_type != SOCK_SEQPACKET)
 		return -EINVAL;
 
-	iucv = iucv_sk(sk);
-
 	if (sk->sk_state == IUCV_OPEN) {
 		err = iucv_sock_autobind(sk);
 		if (unlikely(err))
@@ -585,7 +594,10 @@ static int iucv_sock_listen(struct socke
 	lock_sock(sk);
 
 	err = -EINVAL;
-	if (sk->sk_state != IUCV_BOUND || sock->type != SOCK_STREAM)
+	if (sk->sk_state != IUCV_BOUND)
+		goto done;
+
+	if (sock->type != SOCK_STREAM && sock->type != SOCK_SEQPACKET)
 		goto done;
 
 	sk->sk_max_ack_backlog = backlog;
@@ -720,6 +732,10 @@ static int iucv_sock_sendmsg(struct kioc
 	if (msg->msg_flags & MSG_OOB)
 		return -EOPNOTSUPP;
 
+	/* SOCK_SEQPACKET: we do not support segmented records */
+	if (sk->sk_type == SOCK_SEQPACKET && !(msg->msg_flags & MSG_EOR))
+		return -EOPNOTSUPP;
+
 	lock_sock(sk);
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
@@ -770,6 +786,10 @@ static int iucv_sock_sendmsg(struct kioc
 			}
 		}
 
+		/* allocate one skb for each iucv message:
+		 * this is fine for SOCK_SEQPACKET (unless we want to support
+		 * segmented records using the MSG_EOR flag), but
+		 * for SOCK_STREAM we might want to improve it in future */
 		if (!(skb = sock_alloc_send_skb(sk, len,
 						msg->msg_flags & MSG_DONTWAIT,
 						&err)))
@@ -897,7 +917,11 @@ static void iucv_process_message(struct 
 			kfree_skb(skb);
 			return;
 		}
-		if (skb->truesize >= sk->sk_rcvbuf / 4) {
+		/* we need to fragment iucv messages for SOCK_STREAM only;
+		 * for SOCK_SEQPACKET, it is only relevant if we support
+		 * record segmentation using MSG_EOR (see also recvmsg()) */
+		if (sk->sk_type == SOCK_STREAM &&
+		    skb->truesize >= sk->sk_rcvbuf / 4) {
 			rc = iucv_fragment_skb(sk, skb, len);
 			kfree_skb(skb);
 			skb = NULL;
@@ -941,7 +965,8 @@ static int iucv_sock_recvmsg(struct kioc
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv = iucv_sk(sk);
-	int target, copied = 0;
+	int target;
+	unsigned int copied, rlen;
 	struct sk_buff *skb, *rskb, *cskb;
 	int err = 0;
 
@@ -963,7 +988,8 @@ static int iucv_sock_recvmsg(struct kioc
 		return err;
 	}
 
-	copied = min_t(unsigned int, skb->len, len);
+	rlen   = skb->len;		/* real length of skb */
+	copied = min_t(unsigned int, rlen, len);
 
 	cskb = skb;
 	if (memcpy_toiovec(msg->msg_iov, cskb->data, copied)) {
@@ -973,7 +999,13 @@ static int iucv_sock_recvmsg(struct kioc
 		goto done;
 	}
 
-	len -= copied;
+	/* SOCK_SEQPACKET: set MSG_TRUNC if recv buf size is too small */
+	if (sk->sk_type == SOCK_SEQPACKET) {
+		if (copied < rlen)
+			msg->msg_flags |= MSG_TRUNC;
+		/* each iucv message contains a complete record */
+		msg->msg_flags |= MSG_EOR;
+	}
 
 	/* create control message to store iucv msg target class:
 	 * get the trgcls from the control buffer of the skb due to
@@ -988,11 +1020,14 @@ static int iucv_sock_recvmsg(struct kioc
 
 	/* Mark read part of skb as used */
 	if (!(flags & MSG_PEEK)) {
-		skb_pull(skb, copied);
 
-		if (skb->len) {
-			skb_queue_head(&sk->sk_receive_queue, skb);
-			goto done;
+		/* SOCK_STREAM: re-queue skb if it contains unreceived data */
+		if (sk->sk_type == SOCK_STREAM) {
+			skb_pull(skb, copied);
+			if (skb->len) {
+				skb_queue_head(&sk->sk_receive_queue, skb);
+				goto done;
+			}
 		}
 
 		kfree_skb(skb);
@@ -1019,7 +1054,11 @@ static int iucv_sock_recvmsg(struct kioc
 		skb_queue_head(&sk->sk_receive_queue, skb);
 
 done:
-	return err ? : copied;
+	/* SOCK_SEQPACKET: return real length if MSG_TRUNC is set */
+	if (sk->sk_type == SOCK_SEQPACKET && (flags & MSG_TRUNC))
+		copied = rlen;
+
+	return copied;
 }
 
 static inline unsigned int iucv_accept_poll(struct sock *parent)
@@ -1281,7 +1320,7 @@ static int iucv_callback_connreq(struct 
 	}
 
 	/* Create the new socket */
-	nsk = iucv_sock_alloc(NULL, SOCK_STREAM, GFP_ATOMIC);
+	nsk = iucv_sock_alloc(NULL, sk->sk_type, GFP_ATOMIC);
 	if (!nsk) {
 		err = iucv_path_sever(path, user_data);
 		iucv_path_free(path);

