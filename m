From: ralf@linux-mips.org
Subject: [PATCH 2/3] Socket locking is a great invention.
Date: Sun, 11 Mar 2007 22:53:21 +0000
Message-ID: <20070311225739.773941668@denk.linux-mips.net>
References: <20070311225319.673076841@denk.linux-mips.net>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:24800 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022222AbXCKXSt (ORCPT <rfc822;netdev@vger.kernel.org>
	+ 1 other); Sun, 11 Mar 2007 23:18:49 +0000
Content-Disposition: inline; filename=rose-lock_sock.patch
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Especially if you actually try to do it ;-)

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/rose/af_rose.c |   78 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 50 insertions(+), 28 deletions(-)

Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c
+++ linux-net/net/rose/af_rose.c
@@ -700,23 +700,7 @@ static int rose_connect(struct socket *s
 	unsigned char cause, diagnostic;
 	struct net_device *dev;
 	ax25_uid_assoc *user;
-	int n;
-
-	if (sk->sk_state == TCP_ESTABLISHED && sock->state == SS_CONNECTING) {
-		sock->state = SS_CONNECTED;
-		return 0;	/* Connect completed during a ERESTARTSYS event */
-	}
-
-	if (sk->sk_state == TCP_CLOSE && sock->state == SS_CONNECTING) {
-		sock->state = SS_UNCONNECTED;
-		return -ECONNREFUSED;
-	}
-
-	if (sk->sk_state == TCP_ESTABLISHED)
-		return -EISCONN;	/* No reconnect on a seqpacket socket */
-
-	sk->sk_state   = TCP_CLOSE;
-	sock->state = SS_UNCONNECTED;
+	int n, err = 0;
 
 	if (addr_len != sizeof(struct sockaddr_rose) && addr_len != sizeof(struct full_sockaddr_rose))
 		return -EINVAL;
@@ -734,24 +718,53 @@ static int rose_connect(struct socket *s
 	if ((rose->source_ndigis + addr->srose_ndigis) > ROSE_MAX_DIGIS)
 		return -EINVAL;
 
+	lock_sock(sk);
+
+	if (sk->sk_state == TCP_ESTABLISHED && sock->state == SS_CONNECTING) {
+		/* Connect completed during a ERESTARTSYS event */
+		sock->state = SS_CONNECTED;
+		goto out_release;
+	}
+
+	if (sk->sk_state == TCP_CLOSE && sock->state == SS_CONNECTING) {
+		sock->state = SS_UNCONNECTED;
+		err = -ECONNREFUSED;
+		goto out_release;
+	}
+
+	if (sk->sk_state == TCP_ESTABLISHED) {
+		/* No reconnect on a seqpacket socket */
+		err = -EISCONN;
+		goto out_release;
+	}
+
+	sk->sk_state   = TCP_CLOSE;
+	sock->state = SS_UNCONNECTED;
+
 	rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause,
 					 &diagnostic);
 	if (!rose->neighbour)
 		return -ENETUNREACH;
 
 	rose->lci = rose_new_lci(rose->neighbour);
-	if (!rose->lci)
-		return -ENETUNREACH;
+	if (!rose->lci) {
+		err = -ENETUNREACH;
+		goto out_release;
+	}
 
 	if (sock_flag(sk, SOCK_ZAPPED)) {	/* Must bind first - autobinding in this may or may not work */
 		sock_reset_flag(sk, SOCK_ZAPPED);
 
-		if ((dev = rose_dev_first()) == NULL)
-			return -ENETUNREACH;
+		if ((dev = rose_dev_first()) == NULL) {
+			err = -ENETUNREACH;
+			goto out_release;
+		}
 
 		user = ax25_findbyuid(current->euid);
-		if (!user)
-			return -EINVAL;
+		if (!user) {
+			err = -EINVAL;
+			goto out_release;
+		}
 
 		memcpy(&rose->source_addr, dev->dev_addr, ROSE_ADDR_LEN);
 		rose->source_call = user->call;
@@ -789,8 +802,10 @@ rose_try_next_neigh:
 	rose_start_t1timer(sk);
 
 	/* Now the loop */
-	if (sk->sk_state != TCP_ESTABLISHED && (flags & O_NONBLOCK))
-		return -EINPROGRESS;
+	if (sk->sk_state != TCP_ESTABLISHED && (flags & O_NONBLOCK)) {
+		err = -EINPROGRESS;
+		goto out_release;
+	}
 
 	/*
 	 * A Connect Ack with Choke or timeout or failed routing will go to
@@ -805,8 +820,10 @@ rose_try_next_neigh:
 			set_current_state(TASK_INTERRUPTIBLE);
 			if (sk->sk_state != TCP_SYN_SENT)
 				break;
+			release_sock(sk);
 			if (!signal_pending(tsk)) {
 				schedule();
+				lock_sock(sk);
 				continue;
 			}
 			current->state = TASK_RUNNING;
@@ -822,14 +839,19 @@ rose_try_next_neigh:
 		rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause, &diagnostic);
 		if (rose->neighbour)
 			goto rose_try_next_neigh;
-	/* No more neighbour */
+
+		/* No more neighbours */
 		sock->state = SS_UNCONNECTED;
-		return sock_error(sk);	/* Always set at this point */
+		err = sock_error(sk);	/* Always set at this point */
+		goto out_release;
 	}
 
 	sock->state = SS_CONNECTED;
 
-	return 0;
+out_release:
+	release_sock(sk);
+
+	return err;
 }
 
 static int rose_accept(struct socket *sock, struct socket *newsock, int flags)

-- 

