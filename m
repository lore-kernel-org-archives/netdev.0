From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/5] net/irda: push BKL into proto_ops
Date: Thu,  5 Nov 2009 15:37:28 +0100
Message-ID: <1257431850-20874-4-git-send-email-arnd@arndb.de>
References: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>, John Kacur <jkacur@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:62012 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757566AbZKEOiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 09:38:05 -0500
In-Reply-To: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The irda driver uses the BKL implicitly in its protocol
operations. Replace the wrapped proto_ops with explicit
lock_kernel() calls makes the usage more obvious and
shrinks the size of the object code.

The calls t lock_kernel() should eventually all be replaced
by other serialization methods, which requires finding out

The calls t lock_kernel() should eventually all be replaced
by other serialization methods, which requires finding out
which data actually needs protection.

Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/irda/af_irda.c |  331 +++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 224 insertions(+), 107 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index dd35641..7f84866 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -714,11 +714,14 @@ static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct sockaddr_irda saddr;
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
+	int err;
 
+	lock_kernel();
 	memset(&saddr, 0, sizeof(saddr));
 	if (peer) {
+		err  = -ENOTCONN;
 		if (sk->sk_state != TCP_ESTABLISHED)
-			return -ENOTCONN;
+			goto out;
 
 		saddr.sir_family = AF_IRDA;
 		saddr.sir_lsap_sel = self->dtsap_sel;
@@ -735,8 +738,10 @@ static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
 	/* uaddr_len come to us uninitialised */
 	*uaddr_len = sizeof (struct sockaddr_irda);
 	memcpy(uaddr, &saddr, *uaddr_len);
-
-	return 0;
+	err = 0;
+out:
+	unlock_kernel();
+	return err;
 }
 
 /*
@@ -748,21 +753,25 @@ static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
 static int irda_listen(struct socket *sock, int backlog)
 {
 	struct sock *sk = sock->sk;
+	int err = -EOPNOTSUPP;
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
+	lock_kernel();
 	if ((sk->sk_type != SOCK_STREAM) && (sk->sk_type != SOCK_SEQPACKET) &&
 	    (sk->sk_type != SOCK_DGRAM))
-		return -EOPNOTSUPP;
+		goto out;
 
 	if (sk->sk_state != TCP_LISTEN) {
 		sk->sk_max_ack_backlog = backlog;
 		sk->sk_state           = TCP_LISTEN;
 
-		return 0;
+		err = 0;
 	}
+out:
+	unlock_kernel();
 
-	return -EOPNOTSUPP;
+	return err;
 }
 
 /*
@@ -783,36 +792,40 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr_len != sizeof(struct sockaddr_irda))
 		return -EINVAL;
 
+	lock_kernel();
 #ifdef CONFIG_IRDA_ULTRA
 	/* Special care for Ultra sockets */
 	if ((sk->sk_type == SOCK_DGRAM) &&
 	    (sk->sk_protocol == IRDAPROTO_ULTRA)) {
 		self->pid = addr->sir_lsap_sel;
+		err = -EOPNOTSUPP;
 		if (self->pid & 0x80) {
 			IRDA_DEBUG(0, "%s(), extension in PID not supp!\n", __func__);
-			return -EOPNOTSUPP;
+			goto out;
 		}
 		err = irda_open_lsap(self, self->pid);
 		if (err < 0)
-			return err;
+			goto out;
 
 		/* Pretend we are connected */
 		sock->state = SS_CONNECTED;
 		sk->sk_state   = TCP_ESTABLISHED;
+		err = 0;
 
-		return 0;
+		goto out;
 	}
 #endif /* CONFIG_IRDA_ULTRA */
 
 	self->ias_obj = irias_new_object(addr->sir_name, jiffies);
+	err = -ENOMEM;
 	if (self->ias_obj == NULL)
-		return -ENOMEM;
+		goto out;
 
 	err = irda_open_tsap(self, addr->sir_lsap_sel, addr->sir_name);
 	if (err < 0) {
 		kfree(self->ias_obj->name);
 		kfree(self->ias_obj);
-		return err;
+		goto out;
 	}
 
 	/*  Register with LM-IAS */
@@ -820,7 +833,10 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 				 self->stsap_sel, IAS_KERNEL_ATTR);
 	irias_insert_object(self->ias_obj);
 
-	return 0;
+	err = 0;
+out:
+	unlock_kernel();
+	return err;
 }
 
 /*
@@ -839,22 +855,26 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
+	lock_kernel();
 	err = irda_create(sock_net(sk), newsock, sk->sk_protocol);
 	if (err)
-		return err;
+		goto out;;
 
+	err = -EINVAL;
 	if (sock->state != SS_UNCONNECTED)
-		return -EINVAL;
+		goto out;
 
 	if ((sk = sock->sk) == NULL)
-		return -EINVAL;
+		goto out;
 
+	err = -EOPNOTSUPP;
 	if ((sk->sk_type != SOCK_STREAM) && (sk->sk_type != SOCK_SEQPACKET) &&
 	    (sk->sk_type != SOCK_DGRAM))
-		return -EOPNOTSUPP;
+		goto out;
 
+	err = -EINVAL;
 	if (sk->sk_state != TCP_LISTEN)
-		return -EINVAL;
+		goto out;
 
 	/*
 	 *	The read queue this time is holding sockets ready to use
@@ -875,18 +895,20 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 			break;
 
 		/* Non blocking operation */
+		err = -EWOULDBLOCK;
 		if (flags & O_NONBLOCK)
-			return -EWOULDBLOCK;
+			goto out;
 
 		err = wait_event_interruptible(*(sk->sk_sleep),
 					skb_peek(&sk->sk_receive_queue));
 		if (err)
-			return err;
+			goto out;
 	}
 
 	newsk = newsock->sk;
+	err = -EIO;
 	if (newsk == NULL)
-		return -EIO;
+		goto out;
 
 	newsk->sk_state = TCP_ESTABLISHED;
 
@@ -894,10 +916,11 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 
 	/* Now attach up the new socket */
 	new->tsap = irttp_dup(self->tsap, new);
+	err = -EPERM; /* value does not seem to make sense. -arnd */
 	if (!new->tsap) {
 		IRDA_DEBUG(0, "%s(), dup failed!\n", __func__);
 		kfree_skb(skb);
-		return -1;
+		goto out;
 	}
 
 	new->stsap_sel = new->tsap->stsap_sel;
@@ -921,8 +944,10 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	newsock->state = SS_CONNECTED;
 
 	irda_connect_response(new);
-
-	return 0;
+	err = 0;
+out:
+	unlock_kernel();
+	return err;
 }
 
 /*
@@ -955,28 +980,34 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 
 	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
+	lock_kernel();
 	/* Don't allow connect for Ultra sockets */
+	err = -ESOCKTNOSUPPORT;
 	if ((sk->sk_type == SOCK_DGRAM) && (sk->sk_protocol == IRDAPROTO_ULTRA))
-		return -ESOCKTNOSUPPORT;
+		goto out;
 
 	if (sk->sk_state == TCP_ESTABLISHED && sock->state == SS_CONNECTING) {
 		sock->state = SS_CONNECTED;
-		return 0;   /* Connect completed during a ERESTARTSYS event */
+		err = 0;
+		goto out;   /* Connect completed during a ERESTARTSYS event */
 	}
 
 	if (sk->sk_state == TCP_CLOSE && sock->state == SS_CONNECTING) {
 		sock->state = SS_UNCONNECTED;
-		return -ECONNREFUSED;
+		err = -ECONNREFUSED;
+		goto out;
 	}
 
+	err = -EISCONN;      /* No reconnect on a seqpacket socket */
 	if (sk->sk_state == TCP_ESTABLISHED)
-		return -EISCONN;      /* No reconnect on a seqpacket socket */
+		goto out;
 
 	sk->sk_state   = TCP_CLOSE;
 	sock->state = SS_UNCONNECTED;
 
+	err = -EINVAL;
 	if (addr_len != sizeof(struct sockaddr_irda))
-		return -EINVAL;
+		goto out;
 
 	/* Check if user supplied any destination device address */
 	if ((!addr->sir_addr) || (addr->sir_addr == DEV_ADDR_ANY)) {
@@ -984,7 +1015,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 		err = irda_discover_daddr_and_lsap_sel(self, addr->sir_name);
 		if (err) {
 			IRDA_DEBUG(0, "%s(), auto-connect failed!\n", __func__);
-			return err;
+			goto out;
 		}
 	} else {
 		/* Use the one provided by the user */
@@ -1000,7 +1031,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 			err = irda_find_lsap_sel(self, addr->sir_name);
 			if (err) {
 				IRDA_DEBUG(0, "%s(), connect failed!\n", __func__);
-				return err;
+				goto out;
 			}
 		} else {
 			/* Directly connect to the remote LSAP
@@ -1025,29 +1056,35 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 				    self->max_sdu_size_rx, NULL);
 	if (err) {
 		IRDA_DEBUG(0, "%s(), connect failed!\n", __func__);
-		return err;
+		goto out;
 	}
 
 	/* Now the loop */
+	err = -EINPROGRESS;
 	if (sk->sk_state != TCP_ESTABLISHED && (flags & O_NONBLOCK))
-		return -EINPROGRESS;
+		goto out;
 
+	err = -ERESTARTSYS;
 	if (wait_event_interruptible(*(sk->sk_sleep),
 				     (sk->sk_state != TCP_SYN_SENT)))
-		return -ERESTARTSYS;
+		goto out;
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
 		sock->state = SS_UNCONNECTED;
 		err = sock_error(sk);
-		return err? err : -ECONNRESET;
+		if (!err)
+			err = -ECONNRESET;
+		goto out;
 	}
 
 	sock->state = SS_CONNECTED;
 
 	/* At this point, IrLMP has assigned our source address */
 	self->saddr = irttp_get_saddr(self->tsap);
-
-	return 0;
+	err = 0;
+out:
+	unlock_kernel();
+	return err;
 }
 
 static struct proto irda_proto = {
@@ -1192,6 +1229,7 @@ static int irda_release(struct socket *sock)
 	if (sk == NULL)
 		return 0;
 
+	lock_kernel();
 	lock_sock(sk);
 	sk->sk_state       = TCP_CLOSE;
 	sk->sk_shutdown   |= SEND_SHUTDOWN;
@@ -1210,6 +1248,7 @@ static int irda_release(struct socket *sock)
 	/* Destroy networking socket if we are the last reference on it,
 	 * i.e. if(sk->sk_refcnt == 0) -> sk_free(sk) */
 	sock_put(sk);
+	unlock_kernel();
 
 	/* Notes on socket locking and deallocation... - Jean II
 	 * In theory we should put pairs of sock_hold() / sock_put() to
@@ -1257,28 +1296,37 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
 
+	lock_kernel();
 	/* Note : socket.c set MSG_EOR on SEQPACKET sockets */
 	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_EOR | MSG_CMSG_COMPAT |
-			       MSG_NOSIGNAL))
-		return -EINVAL;
+			       MSG_NOSIGNAL)) {
+		err = -EINVAL;
+		goto out;
+	}
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN)
 		goto out_err;
 
-	if (sk->sk_state != TCP_ESTABLISHED)
-		return -ENOTCONN;
+	if (sk->sk_state != TCP_ESTABLISHED) {
+		err = -ENOTCONN;
+		goto out;
+	}
 
 	self = irda_sk(sk);
 
 	/* Check if IrTTP is wants us to slow down */
 
 	if (wait_event_interruptible(*(sk->sk_sleep),
-	    (self->tx_flow != FLOW_STOP  ||  sk->sk_state != TCP_ESTABLISHED)))
-		return -ERESTARTSYS;
+	    (self->tx_flow != FLOW_STOP  ||  sk->sk_state != TCP_ESTABLISHED))) {
+		err = -ERESTARTSYS;
+		goto out;
+	}
 
 	/* Check if we are still connected */
-	if (sk->sk_state != TCP_ESTABLISHED)
-		return -ENOTCONN;
+	if (sk->sk_state != TCP_ESTABLISHED) {
+		err = -ENOTCONN;
+		goto out;
+	}
 
 	/* Check that we don't send out too big frames */
 	if (len > self->max_data_size) {
@@ -1310,11 +1358,16 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
 		goto out_err;
 	}
+
+	unlock_kernel();
 	/* Tell client how much data we actually sent */
 	return len;
 
- out_err:
-	return sk_stream_error(sk, msg->msg_flags, err);
+out_err:
+	err = sk_stream_error(sk, msg->msg_flags, err);
+out:
+	unlock_kernel();
+	return err;
 
 }
 
@@ -1335,13 +1388,14 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
+	lock_kernel();
 	if ((err = sock_error(sk)) < 0)
-		return err;
+		goto out;
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &err);
 	if (!skb)
-		return err;
+		goto out;
 
 	skb_reset_transport_header(skb);
 	copied = skb->len;
@@ -1369,8 +1423,12 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 			irttp_flow_request(self->tsap, FLOW_START);
 		}
 	}
-
+	unlock_kernel();
 	return copied;
+
+out:
+	unlock_kernel();
+	return err;
 }
 
 /*
@@ -1388,15 +1446,19 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 
 	IRDA_DEBUG(3, "%s()\n", __func__);
 
+	lock_kernel();
 	if ((err = sock_error(sk)) < 0)
-		return err;
+		goto out;
 
+	err = -EINVAL;
 	if (sock->flags & __SO_ACCEPTCON)
-		return(-EINVAL);
+		goto out;
 
+	err =-EOPNOTSUPP;
 	if (flags & MSG_OOB)
-		return -EOPNOTSUPP;
+		goto out;
 
+	err = 0;
 	target = sock_rcvlowat(sk, flags & MSG_WAITALL, size);
 	timeo = sock_rcvtimeo(sk, noblock);
 
@@ -1408,7 +1470,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 
 		if (skb == NULL) {
 			DEFINE_WAIT(wait);
-			int ret = 0;
+			err = 0;
 
 			if (copied >= target)
 				break;
@@ -1418,25 +1480,25 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 			/*
 			 *	POSIX 1003.1g mandates this order.
 			 */
-			ret = sock_error(sk);
-			if (ret)
+			err = sock_error(sk);
+			if (err)
 				;
 			else if (sk->sk_shutdown & RCV_SHUTDOWN)
 				;
 			else if (noblock)
-				ret = -EAGAIN;
+				err = -EAGAIN;
 			else if (signal_pending(current))
-				ret = sock_intr_errno(timeo);
+				err = sock_intr_errno(timeo);
 			else if (sk->sk_state != TCP_ESTABLISHED)
-				ret = -ENOTCONN;
+				err = -ENOTCONN;
 			else if (skb_peek(&sk->sk_receive_queue) == NULL)
 				/* Wait process until data arrives */
 				schedule();
 
 			finish_wait(sk->sk_sleep, &wait);
 
-			if (ret)
-				return ret;
+			if (err)
+				goto out;
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
 				break;
 
@@ -1489,7 +1551,9 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 		}
 	}
 
-	return copied;
+out:
+	unlock_kernel();
+	return err ? : copied;
 }
 
 /*
@@ -1507,18 +1571,23 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 
+	lock_kernel();
+
 	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
 
+	err = -EINVAL;
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
-		return -EINVAL;
+		goto out;
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
 		send_sig(SIGPIPE, current, 0);
-		return -EPIPE;
+		err = -EPIPE;
+		goto out;
 	}
 
+	err = -ENOTCONN;
 	if (sk->sk_state != TCP_ESTABLISHED)
-		return -ENOTCONN;
+		goto out;
 
 	self = irda_sk(sk);
 
@@ -1535,8 +1604,9 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 
 	skb = sock_alloc_send_skb(sk, len + self->max_header_size,
 				  msg->msg_flags & MSG_DONTWAIT, &err);
+	err = -ENOBUFS;
 	if (!skb)
-		return -ENOBUFS;
+		goto out;
 
 	skb_reserve(skb, self->max_header_size);
 	skb_reset_transport_header(skb);
@@ -1546,7 +1616,7 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
 	if (err) {
 		kfree_skb(skb);
-		return err;
+		goto out;
 	}
 
 	/*
@@ -1556,9 +1626,13 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	err = irttp_udata_request(self->tsap, skb);
 	if (err) {
 		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
-		return err;
+		goto out;
 	}
+	unlock_kernel();
 	return len;
+out:
+	unlock_kernel();
+	return err;
 }
 
 /*
@@ -1580,12 +1654,15 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 
 	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
 
+	lock_kernel();
+	err = -EINVAL;
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
-		return -EINVAL;
+		goto out;
 
+	err = -EPIPE;
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
 		send_sig(SIGPIPE, current, 0);
-		return -EPIPE;
+		goto out;
 	}
 
 	self = irda_sk(sk);
@@ -1593,16 +1670,18 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	/* Check if an address was specified with sendto. Jean II */
 	if (msg->msg_name) {
 		struct sockaddr_irda *addr = (struct sockaddr_irda *) msg->msg_name;
+		err = -EINVAL;
 		/* Check address, extract pid. Jean II */
 		if (msg->msg_namelen < sizeof(*addr))
-			return -EINVAL;
+			goto out;
 		if (addr->sir_family != AF_IRDA)
-			return -EINVAL;
+			goto out;
 
 		pid = addr->sir_lsap_sel;
 		if (pid & 0x80) {
 			IRDA_DEBUG(0, "%s(), extension in PID not supp!\n", __func__);
-			return -EOPNOTSUPP;
+			err = -EOPNOTSUPP;
+			goto out;
 		}
 	} else {
 		/* Check that the socket is properly bound to an Ultra
@@ -1611,7 +1690,8 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 		    (sk->sk_state != TCP_ESTABLISHED)) {
 			IRDA_DEBUG(0, "%s(), socket not bound to Ultra PID.\n",
 				   __func__);
-			return -ENOTCONN;
+			err = -ENOTCONN;
+			goto out;
 		}
 		/* Use PID from socket */
 		bound = 1;
@@ -1630,8 +1710,9 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 
 	skb = sock_alloc_send_skb(sk, len + self->max_header_size,
 				  msg->msg_flags & MSG_DONTWAIT, &err);
+	err = -ENOBUFS;
 	if (!skb)
-		return -ENOBUFS;
+		goto out;
 
 	skb_reserve(skb, self->max_header_size);
 	skb_reset_transport_header(skb);
@@ -1641,16 +1722,16 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
 	if (err) {
 		kfree_skb(skb);
-		return err;
+		goto out;
 	}
 
 	err = irlmp_connless_data_request((bound ? self->lsap : NULL),
 					  skb, pid);
-	if (err) {
+	if (err)
 		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
-		return err;
-	}
-	return len;
+out:
+	unlock_kernel();
+	return err ? : len;
 }
 #endif /* CONFIG_IRDA_ULTRA */
 
@@ -1664,6 +1745,8 @@ static int irda_shutdown(struct socket *sock, int how)
 
 	IRDA_DEBUG(1, "%s(%p)\n", __func__, self);
 
+	lock_kernel();
+
 	sk->sk_state       = TCP_CLOSE;
 	sk->sk_shutdown   |= SEND_SHUTDOWN;
 	sk->sk_state_change(sk);
@@ -1684,6 +1767,8 @@ static int irda_shutdown(struct socket *sock, int how)
 	self->daddr = DEV_ADDR_ANY;	/* Until we get re-connected */
 	self->saddr = 0x0;		/* so IrLMP assign us any link */
 
+	unlock_kernel();
+
 	return 0;
 }
 
@@ -1699,6 +1784,7 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
+	lock_kernel();
 	poll_wait(file, sk->sk_sleep, wait);
 	mask = 0;
 
@@ -1746,18 +1832,34 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 	default:
 		break;
 	}
+	unlock_kernel();
 	return mask;
 }
 
+static unsigned int irda_datagram_poll(struct file *file, struct socket *sock,
+			   poll_table *wait)
+{
+	int err;
+
+	lock_kernel();
+	err = datagram_poll(file, sock, wait);
+	unlock_kernel();
+
+	return err;
+}
+
 /*
  * Function irda_ioctl (sock, cmd, arg)
  */
 static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
+	int err;
 
 	IRDA_DEBUG(4, "%s(), cmd=%#x\n", __func__, cmd);
 
+	lock_kernel();
+	err = -EINVAL;
 	switch (cmd) {
 	case TIOCOUTQ: {
 		long amount;
@@ -1765,9 +1867,8 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 		if (amount < 0)
 			amount = 0;
-		if (put_user(amount, (unsigned int __user *)arg))
-			return -EFAULT;
-		return 0;
+		err = put_user(amount, (unsigned int __user *)arg);
+		break;
 	}
 
 	case TIOCINQ: {
@@ -1776,15 +1877,14 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		/* These two are safe on a single CPU system as only user tasks fiddle here */
 		if ((skb = skb_peek(&sk->sk_receive_queue)) != NULL)
 			amount = skb->len;
-		if (put_user(amount, (unsigned int __user *)arg))
-			return -EFAULT;
-		return 0;
+		err = put_user(amount, (unsigned int __user *)arg);
+		break;
 	}
 
 	case SIOCGSTAMP:
 		if (sk != NULL)
-			return sock_get_timestamp(sk, (struct timeval __user *)arg);
-		return -EINVAL;
+			err = sock_get_timestamp(sk, (struct timeval __user *)arg);
+		break;
 
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
@@ -1796,14 +1896,14 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case SIOCSIFNETMASK:
 	case SIOCGIFMETRIC:
 	case SIOCSIFMETRIC:
-		return -EINVAL;
+		break;
 	default:
 		IRDA_DEBUG(1, "%s(), doing device ioctl!\n", __func__);
-		return -ENOIOCTLCMD;
+		err = -ENOIOCTLCMD;
 	}
+	unlock_kernel();
 
-	/*NOTREACHED*/
-	return 0;
+	return err;
 }
 
 #ifdef CONFIG_COMPAT
@@ -1825,7 +1925,7 @@ static int irda_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned lon
  *    Set some options for the socket
  *
  */
-static int irda_setsockopt(struct socket *sock, int level, int optname,
+static int __irda_setsockopt(struct socket *sock, int level, int optname,
 			   char __user *optval, unsigned int optlen)
 {
 	struct sock *sk = sock->sk;
@@ -2083,6 +2183,18 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 	return 0;
 }
 
+static int irda_setsockopt(struct socket *sock, int level, int optname,
+			   char __user *optval, unsigned int optlen)
+{
+	int err;
+
+	lock_kernel();
+	err = __irda_setsockopt(sock, level, optname, optval, optlen);
+	unlock_kernel();
+
+	return err;
+}
+
 /*
  * Function irda_extract_ias_value(ias_opt, ias_value)
  *
@@ -2135,7 +2247,7 @@ static int irda_extract_ias_value(struct irda_ias_set *ias_opt,
 /*
  * Function irda_getsockopt (sock, level, optname, optval, optlen)
  */
-static int irda_getsockopt(struct socket *sock, int level, int optname,
+static int __irda_getsockopt(struct socket *sock, int level, int optname,
 			   char __user *optval, int __user *optlen)
 {
 	struct sock *sk = sock->sk;
@@ -2463,13 +2575,25 @@ bed:
 	return 0;
 }
 
+static int irda_getsockopt(struct socket *sock, int level, int optname,
+			   char __user *optval, int __user *optlen)
+{
+	int err;
+
+	lock_kernel();
+	err = __irda_getsockopt(sock, level, optname, optval, optlen);
+	unlock_kernel();
+
+	return err;
+}
+
 static struct net_proto_family irda_family_ops = {
 	.family = PF_IRDA,
 	.create = irda_create,
 	.owner	= THIS_MODULE,
 };
 
-static const struct proto_ops SOCKOPS_WRAPPED(irda_stream_ops) = {
+static const struct proto_ops irda_stream_ops = {
 	.family =	PF_IRDA,
 	.owner =	THIS_MODULE,
 	.release =	irda_release,
@@ -2493,7 +2617,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_stream_ops) = {
 	.sendpage =	sock_no_sendpage,
 };
 
-static const struct proto_ops SOCKOPS_WRAPPED(irda_seqpacket_ops) = {
+static const struct proto_ops irda_seqpacket_ops = {
 	.family =	PF_IRDA,
 	.owner =	THIS_MODULE,
 	.release =	irda_release,
@@ -2502,7 +2626,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_seqpacket_ops) = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	irda_accept,
 	.getname =	irda_getname,
-	.poll =		datagram_poll,
+	.poll =		irda_datagram_poll,
 	.ioctl =	irda_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl =	irda_compat_ioctl,
@@ -2517,7 +2641,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_seqpacket_ops) = {
 	.sendpage =	sock_no_sendpage,
 };
 
-static const struct proto_ops SOCKOPS_WRAPPED(irda_dgram_ops) = {
+static const struct proto_ops irda_dgram_ops = {
 	.family =	PF_IRDA,
 	.owner =	THIS_MODULE,
 	.release =	irda_release,
@@ -2526,7 +2650,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_dgram_ops) = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	irda_accept,
 	.getname =	irda_getname,
-	.poll =		datagram_poll,
+	.poll =		irda_datagram_poll,
 	.ioctl =	irda_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl =	irda_compat_ioctl,
@@ -2542,7 +2666,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_dgram_ops) = {
 };
 
 #ifdef CONFIG_IRDA_ULTRA
-static const struct proto_ops SOCKOPS_WRAPPED(irda_ultra_ops) = {
+static const struct proto_ops irda_ultra_ops = {
 	.family =	PF_IRDA,
 	.owner =	THIS_MODULE,
 	.release =	irda_release,
@@ -2551,7 +2675,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_ultra_ops) = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	sock_no_accept,
 	.getname =	irda_getname,
-	.poll =		datagram_poll,
+	.poll =		irda_datagram_poll,
 	.ioctl =	irda_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl =	irda_compat_ioctl,
@@ -2567,13 +2691,6 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_ultra_ops) = {
 };
 #endif /* CONFIG_IRDA_ULTRA */
 
-SOCKOPS_WRAP(irda_stream, PF_IRDA);
-SOCKOPS_WRAP(irda_seqpacket, PF_IRDA);
-SOCKOPS_WRAP(irda_dgram, PF_IRDA);
-#ifdef CONFIG_IRDA_ULTRA
-SOCKOPS_WRAP(irda_ultra, PF_IRDA);
-#endif /* CONFIG_IRDA_ULTRA */
-
 /*
  * Function irsock_init (pro)
  *
-- 
1.6.3.3

