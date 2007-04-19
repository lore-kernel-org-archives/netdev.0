From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 2/3] [AF_IUCV/IUCV]: Implementation of a skb backlog queue
Date: Thu, 19 Apr 2007 11:12:14 +0200
Message-ID: <20070419091214.GD14586@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:65131 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993214AbXDSJKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 05:10:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jennifer Hunt <jenhunt@us.ibm.com>

With the inital implementation we missed to implement a skb backlog
queue . The result is that socket receive processing tossed packets.
Since AF_IUCV connections are working synchronously it leads to 
connection hangs. Problems with read, close and select also
occured. 
Using a skb backlog queue is fixing all of these problems .

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    2
 net/iucv/af_iucv.c         |  160 ++++++++++++++++++++++++++++++++++++---------
 2 files changed, 133 insertions(+), 29 deletions(-)

diff --git a/include/net/iucv/af_iucv.h b/include/net/iucv/af_iucv.h
index 04d1abb..f9bd11b 100644
--- a/include/net/iucv/af_iucv.h
+++ b/include/net/iucv/af_iucv.h
@@ -28,6 +28,7 @@ enum {
 	IUCV_LISTEN,
 	IUCV_SEVERED,
 	IUCV_DISCONN,
+	IUCV_CLOSING,
 	IUCV_CLOSED
 };
 
@@ -62,6 +63,7 @@ struct iucv_sock {
 	struct sock		*parent;
 	struct iucv_path	*path;
 	struct sk_buff_head	send_skb_q;
+	struct sk_buff_head	backlog_skb_q;
 	unsigned int		send_tag;
 };
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index acc9421..0c2e4a8 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -147,6 +147,7 @@ static void iucv_sock_close(struct sock *sk)
 	unsigned char user_data[16];
 	struct iucv_sock *iucv = iucv_sk(sk);
 	int err;
+	unsigned long timeo;
 
 	iucv_sock_clear_timer(sk);
 	lock_sock(sk);
@@ -159,6 +160,21 @@ static void iucv_sock_close(struct sock *sk)
 	case IUCV_CONNECTED:
 	case IUCV_DISCONN:
 		err = 0;
+
+		sk->sk_state = IUCV_CLOSING;
+		sk->sk_state_change(sk);
+
+		if(!skb_queue_empty(&iucv->send_skb_q)) {
+			if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
+				timeo = sk->sk_lingertime;
+			else
+				timeo = IUCV_DISCONN_TIMEOUT;
+			err = iucv_sock_wait_state(sk, IUCV_CLOSED, 0, timeo);
+		}
+
+		sk->sk_state = IUCV_CLOSED;
+		sk->sk_state_change(sk);
+
 		if (iucv->path) {
 			low_nmcpy(user_data, iucv->src_name);
 			high_nmcpy(user_data, iucv->dst_name);
@@ -168,12 +184,11 @@ static void iucv_sock_close(struct sock *sk)
 			iucv->path = NULL;
 		}
 
-		sk->sk_state = IUCV_CLOSED;
-		sk->sk_state_change(sk);
 		sk->sk_err = ECONNRESET;
 		sk->sk_state_change(sk);
 
 		skb_queue_purge(&iucv->send_skb_q);
+		skb_queue_purge(&iucv->backlog_skb_q);
 
 		sock_set_flag(sk, SOCK_ZAPPED);
 		break;
@@ -204,6 +219,7 @@ static struct sock *iucv_sock_alloc(struct socket *sock, int proto, gfp_t prio)
 	sock_init_data(sock, sk);
 	INIT_LIST_HEAD(&iucv_sk(sk)->accept_q);
 	skb_queue_head_init(&iucv_sk(sk)->send_skb_q);
+	skb_queue_head_init(&iucv_sk(sk)->backlog_skb_q);
 	iucv_sk(sk)->send_tag = 0;
 
 	sk->sk_destruct = iucv_sock_destruct;
@@ -510,7 +526,7 @@ static int iucv_sock_accept(struct socket *sock, struct socket *newsock,
 	long timeo;
 	int err = 0;
 
-	lock_sock(sk);
+	lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
 
 	if (sk->sk_state != IUCV_LISTEN) {
 		err = -EBADFD;
@@ -530,7 +546,7 @@ static int iucv_sock_accept(struct socket *sock, struct socket *newsock,
 
 		release_sock(sk);
 		timeo = schedule_timeout(timeo);
-		lock_sock(sk);
+		lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
 
 		if (sk->sk_state != IUCV_LISTEN) {
 			err = -EBADFD;
@@ -606,7 +622,7 @@ static int iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 		if(!(skb = sock_alloc_send_skb(sk, len,
 				       msg->msg_flags & MSG_DONTWAIT,
 				       &err)))
-			return err;
+			goto out;
 
 		if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)){
 			err = -EFAULT;
@@ -647,10 +663,16 @@ static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
+	struct iucv_sock *iucv = iucv_sk(sk);
 	int target, copied = 0;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *rskb, *cskb;
 	int err = 0;
 
+	if ((sk->sk_state == IUCV_DISCONN || sk->sk_state == IUCV_SEVERED) &&
+		skb_queue_empty(&iucv->backlog_skb_q) &&
+		skb_queue_empty(&sk->sk_receive_queue))
+		return 0;
+
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
 
@@ -665,10 +687,12 @@ static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	copied = min_t(unsigned int, skb->len, len);
 
-	if (memcpy_toiovec(msg->msg_iov, skb->data, copied)) {
+	cskb = skb;
+	if (memcpy_toiovec(msg->msg_iov, cskb->data, copied)) {
 		skb_queue_head(&sk->sk_receive_queue, skb);
 		if (copied == 0)
 			return -EFAULT;
+		goto done;
 	}
 
 	len -= copied;
@@ -683,6 +707,18 @@ static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 		}
 
 		kfree_skb(skb);
+
+		/* Queue backlog skbs */
+		rskb = skb_dequeue(&iucv_sk(sk)->backlog_skb_q);
+		while(rskb) {
+			if (sock_queue_rcv_skb(sk, rskb)) {
+				skb_queue_head(&iucv_sk(sk)->backlog_skb_q,
+						rskb);
+				break;
+			} else {
+				rskb = skb_dequeue(&iucv_sk(sk)->backlog_skb_q);
+			}
+		}
 	} else
 		skb_queue_head(&sk->sk_receive_queue, skb);
 
@@ -732,6 +768,9 @@ unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
 	if (sk->sk_state == IUCV_CLOSED)
 		mask |= POLLHUP;
 
+	if (sk->sk_state == IUCV_DISCONN || sk->sk_state == IUCV_SEVERED)
+		mask |= POLLIN;
+
 	if (sock_writeable(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
@@ -817,13 +856,6 @@ static int iucv_sock_release(struct socket *sock)
 		iucv_sk(sk)->path = NULL;
 	}
 
-	if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime){
-		lock_sock(sk);
-		err = iucv_sock_wait_state(sk, IUCV_CLOSED, 0,
-					   sk->sk_lingertime);
-		release_sock(sk);
-	}
-
 	sock_orphan(sk);
 	iucv_sock_kill(sk);
 	return err;
@@ -927,18 +959,52 @@ static void iucv_callback_connack(struct iucv_path *path, u8 ipuser[16])
 	sk->sk_state_change(sk);
 }
 
+static int iucv_fragment_skb(struct sock *sk, struct sk_buff *skb, int len,
+			     struct sk_buff_head fragmented_skb_q)
+{
+	int dataleft, size, copied = 0;
+	struct sk_buff *nskb;
+
+	dataleft = len;
+	while(dataleft) {
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
+		nskb->h.raw = nskb->data;
+		nskb->nh.raw = nskb->data;
+		nskb->len = size;
+
+		skb_queue_tail(fragmented_skb_q, nskb);
+	}
+
+	return 0;
+}
 static void iucv_callback_rx(struct iucv_path *path, struct iucv_message *msg)
 {
 	struct sock *sk = path->private;
-	struct sk_buff *skb;
+	struct iucv_sock *iucv = iucv_sk(sk);
+	struct sk_buff *skb, *fskb;
+	struct sk_buff_head fragmented_skb_q;
 	int rc;
 
+	skb_queue_head_init(&fragmented_skb_q);
+
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		return;
 
 	skb = alloc_skb(msg->length, GFP_ATOMIC | GFP_DMA);
 	if (!skb) {
-		iucv_message_reject(path, msg);
+		iucv_path_sever(path, NULL);
 		return;
 	}
 
@@ -953,13 +1019,39 @@ static void iucv_callback_rx(struct iucv_path *path, struct iucv_message *msg)
 			return;
 		}
 
-		skb->h.raw = skb->data;
-		skb->nh.raw = skb->data;
-		skb->len = msg->length;
+		if (skb->truesize >= sk->sk_rcvbuf / 4) {
+			rc = iucv_fragment_skb(sk, skb, msg->length,
+					       &fragmented_skb_q);
+			kfree_skb(skb);
+			skb = NULL;
+			if (rc) {
+				iucv_path_sever(path, NULL);
+				return;
+			}
+		} else {
+			skb->h.raw = skb->data;
+			skb->nh.raw = skb->data;
+			skb->len = msg->length;
+		}
 	}
 
-	if (sock_queue_rcv_skb(sk, skb))
-		kfree_skb(skb);
+	/* Queue the fragmented skb */
+	fskb = skb_dequeue(&fragmented_skb_q);
+	while(fskb) {
+		if (!skb_queue_empty(&iucv->backlog_skb_q))
+			skb_queue_tail(&iucv->backlog_skb_q, fskb);
+		else if (sock_queue_rcv_skb(sk, fskb))
+			skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, fskb);
+		fskb = skb_dequeue(&fragmented_skb_q);
+	}
+
+	/* Queue the original skb if it exists (was not fragmented) */
+	if (skb) {
+		if (!skb_queue_empty(&iucv->backlog_skb_q))
+			skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, skb);
+		else if (sock_queue_rcv_skb(sk, skb))
+			skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, skb);
+	}
 }
 
 static void iucv_callback_txdone(struct iucv_path *path,
@@ -971,17 +1063,27 @@ static void iucv_callback_txdone(struct iucv_path *path,
 	struct sk_buff *list_skb = list->next;
 	unsigned long flags;
 
-	spin_lock_irqsave(&list->lock, flags);
+	if (list_skb) {
+		spin_lock_irqsave(&list->lock, flags);
+
+		do {
+			this = list_skb;
+			list_skb = list_skb->next;
+		} while (memcmp(&msg->tag, this->cb, 4) && list_skb);
+
+		spin_unlock_irqrestore(&list->lock, flags);
 
-	do {
-		this = list_skb;
-		list_skb = list_skb->next;
-	} while (memcmp(&msg->tag, this->cb, 4));
+		skb_unlink(this, &iucv_sk(sk)->send_skb_q);
+		kfree_skb(this);
+	}
 
-	spin_unlock_irqrestore(&list->lock, flags);
+	if (sk->sk_state == IUCV_CLOSING){
+		if (skb_queue_empty(&iucv_sk(sk)->send_skb_q)) {
+			sk->sk_state = IUCV_CLOSED;
+			sk->sk_state_change(sk);
+		}
+	}
 
-	skb_unlink(this, &iucv_sk(sk)->send_skb_q);
-	kfree_skb(this);
 }
 
 static void iucv_callback_connrej(struct iucv_path *path, u8 ipuser[16])
-- 
1.5.0.1

