From: ralf@linux-mips.org
Subject: [PATCH 3/3] Convert to use modern wait queue API
Date: Sun, 11 Mar 2007 22:53:22 +0000
Message-ID: <20070311225739.867991584@denk.linux-mips.net>
References: <20070311225319.673076841@denk.linux-mips.net>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:53539 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964789AbXCKXSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2007 19:18:50 -0400
Received: from localhost.localdomain ([127.0.0.1]:25312 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022223AbXCKXSt (ORCPT <rfc822;netdev@vger.kernel.org>
	+ 1 other); Sun, 11 Mar 2007 23:18:49 +0000
Content-Disposition: inline; filename=ax25-waitqueue-fixes.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/ax25/af_ax25.c     |   77 +++++++++++++++++++---------------------
 net/netrom/af_netrom.c |   93 ++++++++++++++++++++++++-------------------------
 net/rose/af_rose.c     |   54 +++++++++++++---------------
 3 files changed, 109 insertions(+), 115 deletions(-)

Index: linux-net/net/ax25/af_ax25.c
===================================================================
--- linux-net.orig/net/ax25/af_ax25.c
+++ linux-net/net/ax25/af_ax25.c
@@ -1127,22 +1127,22 @@ static int __must_check ax25_connect(str
 		switch (sk->sk_state) {
 		case TCP_SYN_SENT: /* still trying */
 			err = -EINPROGRESS;
-			goto out;
+			goto out_release;
 
 		case TCP_ESTABLISHED: /* connection established */
 			sock->state = SS_CONNECTED;
-			goto out;
+			goto out_release;
 
 		case TCP_CLOSE: /* connection refused */
 			sock->state = SS_UNCONNECTED;
 			err = -ECONNREFUSED;
-			goto out;
+			goto out_release;
 		}
 	}
 
 	if (sk->sk_state == TCP_ESTABLISHED && sk->sk_type == SOCK_SEQPACKET) {
 		err = -EISCONN;	/* No reconnect on a seqpacket socket */
-		goto out;
+		goto out_release;
 	}
 
 	sk->sk_state   = TCP_CLOSE;
@@ -1159,12 +1159,12 @@ static int __must_check ax25_connect(str
 		/* Valid number of digipeaters ? */
 		if (fsa->fsa_ax25.sax25_ndigis < 1 || fsa->fsa_ax25.sax25_ndigis > AX25_MAX_DIGIS) {
 			err = -EINVAL;
-			goto out;
+			goto out_release;
 		}
 
 		if ((digi = kmalloc(sizeof(ax25_digi), GFP_KERNEL)) == NULL) {
 			err = -ENOBUFS;
-			goto out;
+			goto out_release;
 		}
 
 		digi->ndigi      = fsa->fsa_ax25.sax25_ndigis;
@@ -1194,7 +1194,7 @@ static int __must_check ax25_connect(str
 			current->comm);
 		if ((err = ax25_rt_autobind(ax25, &fsa->fsa_ax25.sax25_call)) < 0) {
 			kfree(digi);
-			goto out;
+			goto out_release;
 		}
 
 		ax25_fillin_cb(ax25, ax25->ax25_dev);
@@ -1203,7 +1203,7 @@ static int __must_check ax25_connect(str
 		if (ax25->ax25_dev == NULL) {
 			kfree(digi);
 			err = -EHOSTUNREACH;
-			goto out;
+			goto out_release;
 		}
 	}
 
@@ -1213,7 +1213,7 @@ static int __must_check ax25_connect(str
 		kfree(digi);
 		err = -EADDRINUSE;		/* Already such a connection */
 		ax25_cb_put(ax25t);
-		goto out;
+		goto out_release;
 	}
 
 	ax25->dest_addr = fsa->fsa_ax25.sax25_call;
@@ -1223,7 +1223,7 @@ static int __must_check ax25_connect(str
 	if (sk->sk_type != SOCK_SEQPACKET) {
 		sock->state = SS_CONNECTED;
 		sk->sk_state   = TCP_ESTABLISHED;
-		goto out;
+		goto out_release;
 	}
 
 	/* Move to connecting socket, ax.25 lapb WAIT_UA.. */
@@ -1255,55 +1255,53 @@ static int __must_check ax25_connect(str
 	/* Now the loop */
 	if (sk->sk_state != TCP_ESTABLISHED && (flags & O_NONBLOCK)) {
 		err = -EINPROGRESS;
-		goto out;
+		goto out_release;
 	}
 
 	if (sk->sk_state == TCP_SYN_SENT) {
-		struct task_struct *tsk = current;
-		DECLARE_WAITQUEUE(wait, tsk);
+		DEFINE_WAIT(wait);
 
-		add_wait_queue(sk->sk_sleep, &wait);
 		for (;;) {
+			prepare_to_wait(sk->sk_sleep, &wait,
+			                TASK_INTERRUPTIBLE);
 			if (sk->sk_state != TCP_SYN_SENT)
 				break;
-			set_current_state(TASK_INTERRUPTIBLE);
-			release_sock(sk);
-			if (!signal_pending(tsk)) {
+			if (!signal_pending(current)) {
+				release_sock(sk);
 				schedule();
 				lock_sock(sk);
 				continue;
 			}
-			current->state = TASK_RUNNING;
-			remove_wait_queue(sk->sk_sleep, &wait);
-			return -ERESTARTSYS;
+			err = -ERESTARTSYS;
+			break;
 		}
-		current->state = TASK_RUNNING;
-		remove_wait_queue(sk->sk_sleep, &wait);
+		finish_wait(sk->sk_sleep, &wait);
+
+		if (err)
+			goto out_release;
 	}
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
 		/* Not in ABM, not in WAIT_UA -> failed */
 		sock->state = SS_UNCONNECTED;
 		err = sock_error(sk);	/* Always set at this point */
-		goto out;
+		goto out_release;
 	}
 
 	sock->state = SS_CONNECTED;
 
-	err=0;
-out:
+	err = 0;
+out_release:
 	release_sock(sk);
 
 	return err;
 }
 
-
 static int ax25_accept(struct socket *sock, struct socket *newsock, int flags)
 {
-	struct task_struct *tsk = current;
-	DECLARE_WAITQUEUE(wait, tsk);
 	struct sk_buff *skb;
 	struct sock *newsk;
+	DEFINE_WAIT(wait);
 	struct sock *sk;
 	int err = 0;
 
@@ -1328,30 +1326,29 @@ static int ax25_accept(struct socket *so
 	 *	The read queue this time is holding sockets ready to use
 	 *	hooked into the SABM we saved
 	 */
-	add_wait_queue(sk->sk_sleep, &wait);
 	for (;;) {
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		skb = skb_dequeue(&sk->sk_receive_queue);
 		if (skb)
 			break;
 
-		release_sock(sk);
-		current->state = TASK_INTERRUPTIBLE;
 		if (flags & O_NONBLOCK) {
-			current->state = TASK_RUNNING;
-			remove_wait_queue(sk->sk_sleep, &wait);
-			return -EWOULDBLOCK;
+			err = -EWOULDBLOCK;
+			break;
 		}
-		if (!signal_pending(tsk)) {
+		if (!signal_pending(current)) {
+			release_sock(sk);
 			schedule();
 			lock_sock(sk);
 			continue;
 		}
-		current->state = TASK_RUNNING;
-		remove_wait_queue(sk->sk_sleep, &wait);
-		return -ERESTARTSYS;
+		err = -ERESTARTSYS;
+		break;
 	}
-	current->state = TASK_RUNNING;
-	remove_wait_queue(sk->sk_sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
+
+	if (err)
+		goto out;
 
 	newsk		 = skb->sk;
 	newsk->sk_socket = newsock;
Index: linux-net/net/netrom/af_netrom.c
===================================================================
--- linux-net.orig/net/netrom/af_netrom.c
+++ linux-net/net/netrom/af_netrom.c
@@ -625,42 +625,42 @@ static int nr_connect(struct socket *soc
 	ax25_address *source = NULL;
 	ax25_uid_assoc *user;
 	struct net_device *dev;
+	int err = 0;
 
 	lock_sock(sk);
 	if (sk->sk_state == TCP_ESTABLISHED && sock->state == SS_CONNECTING) {
 		sock->state = SS_CONNECTED;
-		release_sock(sk);
-		return 0;	/* Connect completed during a ERESTARTSYS event */
+		goto out_release;	/* Connect completed during a ERESTARTSYS event */
 	}
 
 	if (sk->sk_state == TCP_CLOSE && sock->state == SS_CONNECTING) {
 		sock->state = SS_UNCONNECTED;
-		release_sock(sk);
-		return -ECONNREFUSED;
+		err = -ECONNREFUSED;
+		goto out_release;
 	}
 
 	if (sk->sk_state == TCP_ESTABLISHED) {
-		release_sock(sk);
-		return -EISCONN;	/* No reconnect on a seqpacket socket */
+		err = -EISCONN;	/* No reconnect on a seqpacket socket */
+		goto out_release;
 	}
 
 	sk->sk_state   = TCP_CLOSE;
 	sock->state = SS_UNCONNECTED;
 
 	if (addr_len != sizeof(struct sockaddr_ax25) && addr_len != sizeof(struct full_sockaddr_ax25)) {
-		release_sock(sk);
-		return -EINVAL;
+		err = -EINVAL;
+		goto out_release;
 	}
 	if (addr->sax25_family != AF_NETROM) {
-		release_sock(sk);
-		return -EINVAL;
+		err = -EINVAL;
+		goto out_release;
 	}
 	if (sock_flag(sk, SOCK_ZAPPED)) {	/* Must bind first - autobinding in this may or may not work */
 		sock_reset_flag(sk, SOCK_ZAPPED);
 
 		if ((dev = nr_dev_first()) == NULL) {
-			release_sock(sk);
-			return -ENETUNREACH;
+			err = -ENETUNREACH;
+			goto out_release;
 		}
 		source = (ax25_address *)dev->dev_addr;
 
@@ -671,8 +671,8 @@ static int nr_connect(struct socket *soc
 		} else {
 			if (ax25_uid_policy && !capable(CAP_NET_ADMIN)) {
 				dev_put(dev);
-				release_sock(sk);
-				return -EPERM;
+				err = -EPERM;
+				goto out_release;
 			}
 			nr->user_addr   = *source;
 		}
@@ -707,8 +707,8 @@ static int nr_connect(struct socket *soc
 
 	/* Now the loop */
 	if (sk->sk_state != TCP_ESTABLISHED && (flags & O_NONBLOCK)) {
-		release_sock(sk);
-		return -EINPROGRESS;
+		err = -EINPROGRESS;
+		goto out_release;
 	}
 
 	/*
@@ -716,46 +716,46 @@ static int nr_connect(struct socket *soc
 	 * closed.
 	 */
 	if (sk->sk_state == TCP_SYN_SENT) {
-		struct task_struct *tsk = current;
-		DECLARE_WAITQUEUE(wait, tsk);
+		DEFINE_WAIT(wait);
 
-		add_wait_queue(sk->sk_sleep, &wait);
 		for (;;) {
-			set_current_state(TASK_INTERRUPTIBLE);
+			prepare_to_wait(sk->sk_sleep, &wait,
+			                TASK_INTERRUPTIBLE);
 			if (sk->sk_state != TCP_SYN_SENT)
 				break;
-			release_sock(sk);
-			if (!signal_pending(tsk)) {
+			if (!signal_pending(current)) {
+				release_sock(sk);
 				schedule();
 				lock_sock(sk);
 				continue;
 			}
-			current->state = TASK_RUNNING;
-			remove_wait_queue(sk->sk_sleep, &wait);
-			return -ERESTARTSYS;
+			err = -ERESTARTSYS;
+			break;
 		}
-		current->state = TASK_RUNNING;
-		remove_wait_queue(sk->sk_sleep, &wait);
+		finish_wait(sk->sk_sleep, &wait);
+		if (err)
+			goto out_release;
 	}
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
 		sock->state = SS_UNCONNECTED;
-		release_sock(sk);
-		return sock_error(sk);	/* Always set at this point */
+		err = sock_error(sk);	/* Always set at this point */
+		goto out_release;
 	}
 
 	sock->state = SS_CONNECTED;
+
+out_release:
 	release_sock(sk);
 
-	return 0;
+	return err;
 }
 
 static int nr_accept(struct socket *sock, struct socket *newsock, int flags)
 {
-	struct task_struct *tsk = current;
-	DECLARE_WAITQUEUE(wait, tsk);
 	struct sk_buff *skb;
 	struct sock *newsk;
+	DEFINE_WAIT(wait);
 	struct sock *sk;
 	int err = 0;
 
@@ -765,42 +765,40 @@ static int nr_accept(struct socket *sock
 	lock_sock(sk);
 	if (sk->sk_type != SOCK_SEQPACKET) {
 		err = -EOPNOTSUPP;
-		goto out;
+		goto out_release;
 	}
 
 	if (sk->sk_state != TCP_LISTEN) {
 		err = -EINVAL;
-		goto out;
+		goto out_release;
 	}
 
 	/*
 	 *	The write queue this time is holding sockets ready to use
 	 *	hooked into the SABM we saved
 	 */
-	add_wait_queue(sk->sk_sleep, &wait);
 	for (;;) {
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		skb = skb_dequeue(&sk->sk_receive_queue);
 		if (skb)
 			break;
 
-		current->state = TASK_INTERRUPTIBLE;
-		release_sock(sk);
 		if (flags & O_NONBLOCK) {
-			current->state = TASK_RUNNING;
-			remove_wait_queue(sk->sk_sleep, &wait);
-			return -EWOULDBLOCK;
+			err = -EWOULDBLOCK;
+			break;
 		}
-		if (!signal_pending(tsk)) {
+		if (!signal_pending(current)) {
+			release_sock(sk);
 			schedule();
 			lock_sock(sk);
 			continue;
 		}
-		current->state = TASK_RUNNING;
-		remove_wait_queue(sk->sk_sleep, &wait);
-		return -ERESTARTSYS;
+		err = -ERESTARTSYS;
+		break;
 	}
-	current->state = TASK_RUNNING;
-	remove_wait_queue(sk->sk_sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
+	if (err)
+		goto out_release;
 
 	newsk = skb->sk;
 	newsk->sk_socket = newsock;
@@ -811,8 +809,9 @@ static int nr_accept(struct socket *sock
 	sk_acceptq_removed(sk);
 	newsock->sk = newsk;
 
-out:
+out_release:
 	release_sock(sk);
+
 	return err;
 }
 
Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c
+++ linux-net/net/rose/af_rose.c
@@ -812,26 +812,26 @@ rose_try_next_neigh:
 	 * closed.
 	 */
 	if (sk->sk_state == TCP_SYN_SENT) {
-		struct task_struct *tsk = current;
-		DECLARE_WAITQUEUE(wait, tsk);
+		DEFINE_WAIT(wait);
 
-		add_wait_queue(sk->sk_sleep, &wait);
 		for (;;) {
-			set_current_state(TASK_INTERRUPTIBLE);
+			prepare_to_wait(sk->sk_sleep, &wait,
+			                TASK_INTERRUPTIBLE);
 			if (sk->sk_state != TCP_SYN_SENT)
 				break;
-			release_sock(sk);
-			if (!signal_pending(tsk)) {
+			if (!signal_pending(current)) {
+				release_sock(sk);
 				schedule();
 				lock_sock(sk);
 				continue;
 			}
-			current->state = TASK_RUNNING;
-			remove_wait_queue(sk->sk_sleep, &wait);
-			return -ERESTARTSYS;
+			err = -ERESTARTSYS;
+			break;
 		}
-		current->state = TASK_RUNNING;
-		remove_wait_queue(sk->sk_sleep, &wait);
+		finish_wait(sk->sk_sleep, &wait);
+
+		if (err)
+			goto out_release;
 	}
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
@@ -856,10 +856,9 @@ out_release:
 
 static int rose_accept(struct socket *sock, struct socket *newsock, int flags)
 {
-	struct task_struct *tsk = current;
-	DECLARE_WAITQUEUE(wait, tsk);
 	struct sk_buff *skb;
 	struct sock *newsk;
+	DEFINE_WAIT(wait);
 	struct sock *sk;
 	int err = 0;
 
@@ -869,42 +868,41 @@ static int rose_accept(struct socket *so
 	lock_sock(sk);
 	if (sk->sk_type != SOCK_SEQPACKET) {
 		err = -EOPNOTSUPP;
-		goto out;
+		goto out_release;
 	}
 
 	if (sk->sk_state != TCP_LISTEN) {
 		err = -EINVAL;
-		goto out;
+		goto out_release;
 	}
 
 	/*
 	 *	The write queue this time is holding sockets ready to use
 	 *	hooked into the SABM we saved
 	 */
-	add_wait_queue(sk->sk_sleep, &wait);
 	for (;;) {
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+
 		skb = skb_dequeue(&sk->sk_receive_queue);
 		if (skb)
 			break;
 
-		current->state = TASK_INTERRUPTIBLE;
-		release_sock(sk);
 		if (flags & O_NONBLOCK) {
-			current->state = TASK_RUNNING;
-			remove_wait_queue(sk->sk_sleep, &wait);
-			return -EWOULDBLOCK;
+			err = -EWOULDBLOCK;
+			break;
 		}
-		if (!signal_pending(tsk)) {
+		if (!signal_pending(current)) {
+			release_sock(sk);
 			schedule();
 			lock_sock(sk);
 			continue;
 		}
-		current->state = TASK_RUNNING;
-		remove_wait_queue(sk->sk_sleep, &wait);
-		return -ERESTARTSYS;
+		err = -ERESTARTSYS;
+		break;
 	}
-	current->state = TASK_RUNNING;
-	remove_wait_queue(sk->sk_sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
+	if (err)
+		goto out_release;
 
 	newsk = skb->sk;
 	newsk->sk_socket = newsock;
@@ -916,7 +914,7 @@ static int rose_accept(struct socket *so
 	sk->sk_ack_backlog--;
 	newsock->sk = newsk;
 
-out:
+out_release:
 	release_sock(sk);
 
 	return err;

-- 

