From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 2/2] [PATCH] af_iucv: Return -EAGAIN if iucv msg limit is exceeded
Date: Thu, 18 Jun 2009 09:54:48 +0200
Message-ID: <20090618075522.233912000@linux.vnet.ibm.com>
References: <20090618075446.890351000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:38371 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbZFRHzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:55:21 -0400
Content-Disposition: inline; filename=602-af_iucv-msg-limit.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

If the iucv message limit for a communication path is exceeded,
sendmsg() returns -EAGAIN instead of -EPIPE.
The calling application can then handle this error situtation,
e.g. to try again after waiting some time.

For blocking sockets, sendmsg() waits up to the socket timeout
before returning -EAGAIN. For the new wait condition, a macro
has been introduced and the iucv_sock_wait_state() has been
refactored to this macro.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    2 
 net/iucv/af_iucv.c         |  144 ++++++++++++++++++++++++++++++++-------------
 2 files changed, 103 insertions(+), 43 deletions(-)

Index: linux-2.6-uschi/include/net/iucv/af_iucv.h
===================================================================
--- linux-2.6-uschi.orig/include/net/iucv/af_iucv.h
+++ linux-2.6-uschi/include/net/iucv/af_iucv.h
@@ -94,8 +94,6 @@ unsigned int iucv_sock_poll(struct file 
 			    poll_table *wait);
 void iucv_sock_link(struct iucv_sock_list *l, struct sock *s);
 void iucv_sock_unlink(struct iucv_sock_list *l, struct sock *s);
-int  iucv_sock_wait_state(struct sock *sk, int state, int state2,
-			  unsigned long timeo);
 int  iucv_sock_wait_cnt(struct sock *sk, unsigned long timeo);
 void iucv_accept_enqueue(struct sock *parent, struct sock *sk);
 void iucv_accept_unlink(struct sock *sk);
Index: linux-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- linux-2.6-uschi.orig/net/iucv/af_iucv.c
+++ linux-2.6-uschi/net/iucv/af_iucv.c
@@ -54,6 +54,38 @@ static const u8 iprm_shutdown[8] =
 #define CB_TRGCLS(skb)	((skb)->cb + CB_TAG_LEN) /* iucv msg target class */
 #define CB_TRGCLS_LEN	(TRGCLS_SIZE)
 
+#define __iucv_sock_wait(sk, condition, timeo, ret)			\
+do {									\
+	DEFINE_WAIT(__wait);						\
+	long __timeo = timeo;						\
+	ret = 0;							\
+	while (!(condition)) {						\
+		prepare_to_wait(sk->sk_sleep, &__wait, TASK_INTERRUPTIBLE); \
+		if (!__timeo) {						\
+			ret = -EAGAIN;					\
+			break;						\
+		}							\
+		if (signal_pending(current)) {				\
+			ret = sock_intr_errno(__timeo);			\
+			break;						\
+		}							\
+		release_sock(sk);					\
+		__timeo = schedule_timeout(__timeo);			\
+		lock_sock(sk);						\
+		ret = sock_error(sk);					\
+		if (ret)						\
+			break;						\
+	}								\
+	finish_wait(sk->sk_sleep, &__wait);				\
+} while (0)
+
+#define iucv_sock_wait(sk, condition, timeo)				\
+({									\
+	int __ret = 0;							\
+	if (!(condition))						\
+		__iucv_sock_wait(sk, condition, timeo, __ret);		\
+	__ret;								\
+})
 
 static void iucv_sock_kill(struct sock *sk);
 static void iucv_sock_close(struct sock *sk);
@@ -238,6 +270,48 @@ static inline size_t iucv_msg_length(str
 	return msg->length;
 }
 
+/**
+ * iucv_sock_in_state() - check for specific states
+ * @sk:		sock structure
+ * @state:	first iucv sk state
+ * @state:	second iucv sk state
+ *
+ * Returns true if the socket in either in the first or second state.
+ */
+static int iucv_sock_in_state(struct sock *sk, int state, int state2)
+{
+	return (sk->sk_state == state || sk->sk_state == state2);
+}
+
+/**
+ * iucv_below_msglim() - function to check if messages can be sent
+ * @sk:		sock structure
+ *
+ * Returns true if the send queue length is lower than the message limit.
+ * Always returns true if the socket is not connected (no iucv path for
+ * checking the message limit).
+ */
+static inline int iucv_below_msglim(struct sock *sk)
+{
+	struct iucv_sock *iucv = iucv_sk(sk);
+
+	if (sk->sk_state != IUCV_CONNECTED)
+		return 1;
+	return (skb_queue_len(&iucv->send_skb_q) < iucv->path->msglim);
+}
+
+/**
+ * iucv_sock_wake_msglim() - Wake up thread waiting on msg limit
+ */
+static void iucv_sock_wake_msglim(struct sock *sk)
+{
+	read_lock(&sk->sk_callback_lock);
+	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		wake_up_interruptible_all(sk->sk_sleep);
+	sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
+	read_unlock(&sk->sk_callback_lock);
+}
+
 /* Timers */
 static void iucv_sock_timeout(unsigned long arg)
 {
@@ -329,7 +403,9 @@ static void iucv_sock_close(struct sock 
 				timeo = sk->sk_lingertime;
 			else
 				timeo = IUCV_DISCONN_TIMEOUT;
-			err = iucv_sock_wait_state(sk, IUCV_CLOSED, 0, timeo);
+			err = iucv_sock_wait(sk,
+					iucv_sock_in_state(sk, IUCV_CLOSED, 0),
+					timeo);
 		}
 
 	case IUCV_CLOSING:   /* fall through */
@@ -510,39 +586,6 @@ struct sock *iucv_accept_dequeue(struct 
 	return NULL;
 }
 
-int iucv_sock_wait_state(struct sock *sk, int state, int state2,
-			 unsigned long timeo)
-{
-	DECLARE_WAITQUEUE(wait, current);
-	int err = 0;
-
-	add_wait_queue(sk->sk_sleep, &wait);
-	while (sk->sk_state != state && sk->sk_state != state2) {
-		set_current_state(TASK_INTERRUPTIBLE);
-
-		if (!timeo) {
-			err = -EAGAIN;
-			break;
-		}
-
-		if (signal_pending(current)) {
-			err = sock_intr_errno(timeo);
-			break;
-		}
-
-		release_sock(sk);
-		timeo = schedule_timeout(timeo);
-		lock_sock(sk);
-
-		err = sock_error(sk);
-		if (err)
-			break;
-	}
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
-	return err;
-}
-
 /* Bind an unbound socket */
 static int iucv_sock_bind(struct socket *sock, struct sockaddr *addr,
 			  int addr_len)
@@ -687,8 +730,9 @@ static int iucv_sock_connect(struct sock
 	}
 
 	if (sk->sk_state != IUCV_CONNECTED) {
-		err = iucv_sock_wait_state(sk, IUCV_CONNECTED, IUCV_DISCONN,
-				sock_sndtimeo(sk, flags & O_NONBLOCK));
+		err = iucv_sock_wait(sk, iucv_sock_in_state(sk, IUCV_CONNECTED,
+							    IUCV_DISCONN),
+				     sock_sndtimeo(sk, flags & O_NONBLOCK));
 	}
 
 	if (sk->sk_state == IUCV_DISCONN) {
@@ -842,9 +886,11 @@ static int iucv_sock_sendmsg(struct kioc
 	struct iucv_message txmsg;
 	struct cmsghdr *cmsg;
 	int cmsg_done;
+	long timeo;
 	char user_id[9];
 	char appl_id[9];
 	int err;
+	int noblock = msg->msg_flags & MSG_DONTWAIT;
 
 	err = sock_error(sk);
 	if (err)
@@ -916,8 +962,7 @@ static int iucv_sock_sendmsg(struct kioc
 	 * this is fine for SOCK_SEQPACKET (unless we want to support
 	 * segmented records using the MSG_EOR flag), but
 	 * for SOCK_STREAM we might want to improve it in future */
-	skb = sock_alloc_send_skb(sk, len, msg->msg_flags & MSG_DONTWAIT,
-				  &err);
+	skb = sock_alloc_send_skb(sk, len, noblock, &err);
 	if (!skb)
 		goto out;
 	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
@@ -925,6 +970,18 @@ static int iucv_sock_sendmsg(struct kioc
 		goto fail;
 	}
 
+	/* wait if outstanding messages for iucv path has reached */
+	timeo = sock_sndtimeo(sk, noblock);
+	err = iucv_sock_wait(sk, iucv_below_msglim(sk), timeo);
+	if (err)
+		goto fail;
+
+	/* return -ECONNRESET if the socket is no longer connected */
+	if (sk->sk_state != IUCV_CONNECTED) {
+		err = -ECONNRESET;
+		goto fail;
+	}
+
 	/* increment and save iucv message tag for msg_completion cbk */
 	txmsg.tag = iucv->send_tag++;
 	memcpy(CB_TAG(skb), &txmsg.tag, CB_TAG_LEN);
@@ -961,9 +1018,10 @@ static int iucv_sock_sendmsg(struct kioc
 			pr_err("Application %s on z/VM guest %s"
 				" exceeds message limit\n",
 				appl_id, user_id);
-		}
+			err = -EAGAIN;
+		} else
+			err = -EPIPE;
 		skb_unlink(skb, &iucv->send_skb_q);
-		err = -EPIPE;
 		goto fail;
 	}
 
@@ -1580,7 +1638,11 @@ static void iucv_callback_txdone(struct 
 
 		spin_unlock_irqrestore(&list->lock, flags);
 
-		kfree_skb(this);
+		if (this) {
+			kfree_skb(this);
+			/* wake up any process waiting for sending */
+			iucv_sock_wake_msglim(sk);
+		}
 	}
 	BUG_ON(!this);
 

