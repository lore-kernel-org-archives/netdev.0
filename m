From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH net-next 1/5] irda: Remove BKL instances from af_irda.c
Date: Mon, 11 Oct 2010 02:24:58 +0200
Message-ID: <5b40964eadea40509d353318d2c82e8b7bf5e8a5.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43216 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543Ab0JKAZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Oct 2010 20:25:36 -0400
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
In-Reply-To: <cover.1286756123.git.sameo@linux.intel.com>
References: <cover.1286756123.git.sameo@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the times, lock_kernel() was pointless or could simply be replaced
by lock_sock().

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/af_irda.c |  370 +++++++++++++++++++++++++++------------------------
 1 files changed, 196 insertions(+), 174 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index bf36351..7f09798 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -715,14 +715,11 @@ static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct sockaddr_irda saddr;
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
-	int err;
 
-	lock_kernel();
 	memset(&saddr, 0, sizeof(saddr));
 	if (peer) {
-		err  = -ENOTCONN;
 		if (sk->sk_state != TCP_ESTABLISHED)
-			goto out;
+			return -ENOTCONN;
 
 		saddr.sir_family = AF_IRDA;
 		saddr.sir_lsap_sel = self->dtsap_sel;
@@ -739,10 +736,8 @@ static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
 	/* uaddr_len come to us uninitialised */
 	*uaddr_len = sizeof (struct sockaddr_irda);
 	memcpy(uaddr, &saddr, *uaddr_len);
-	err = 0;
-out:
-	unlock_kernel();
-	return err;
+
+	return 0;
 }
 
 /*
@@ -758,7 +753,8 @@ static int irda_listen(struct socket *sock, int backlog)
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
-	lock_kernel();
+	lock_sock(sk);
+
 	if ((sk->sk_type != SOCK_STREAM) && (sk->sk_type != SOCK_SEQPACKET) &&
 	    (sk->sk_type != SOCK_DGRAM))
 		goto out;
@@ -770,7 +766,7 @@ static int irda_listen(struct socket *sock, int backlog)
 		err = 0;
 	}
 out:
-	unlock_kernel();
+	release_sock(sk);
 
 	return err;
 }
@@ -793,7 +789,7 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr_len != sizeof(struct sockaddr_irda))
 		return -EINVAL;
 
-	lock_kernel();
+	lock_sock(sk);
 #ifdef CONFIG_IRDA_ULTRA
 	/* Special care for Ultra sockets */
 	if ((sk->sk_type == SOCK_DGRAM) &&
@@ -836,7 +832,7 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	err = 0;
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err;
 }
 
@@ -856,12 +852,13 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
-	lock_kernel();
 	err = irda_create(sock_net(sk), newsock, sk->sk_protocol, 0);
 	if (err)
-		goto out;
+		return err;
 
 	err = -EINVAL;
+
+	lock_sock(sk);
 	if (sock->state != SS_UNCONNECTED)
 		goto out;
 
@@ -947,7 +944,7 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	irda_connect_response(new);
 	err = 0;
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err;
 }
 
@@ -981,7 +978,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 
 	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
-	lock_kernel();
+	lock_sock(sk);
 	/* Don't allow connect for Ultra sockets */
 	err = -ESOCKTNOSUPPORT;
 	if ((sk->sk_type == SOCK_DGRAM) && (sk->sk_protocol == IRDAPROTO_ULTRA))
@@ -1072,6 +1069,8 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
 		sock->state = SS_UNCONNECTED;
+		if (sk->sk_prot->disconnect(sk, flags))
+			sock->state = SS_DISCONNECTING;
 		err = sock_error(sk);
 		if (!err)
 			err = -ECONNRESET;
@@ -1084,7 +1083,7 @@ static int irda_connect(struct socket *sock, struct sockaddr *uaddr,
 	self->saddr = irttp_get_saddr(self->tsap);
 	err = 0;
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err;
 }
 
@@ -1231,7 +1230,6 @@ static int irda_release(struct socket *sock)
 	if (sk == NULL)
 		return 0;
 
-	lock_kernel();
 	lock_sock(sk);
 	sk->sk_state       = TCP_CLOSE;
 	sk->sk_shutdown   |= SEND_SHUTDOWN;
@@ -1250,7 +1248,6 @@ static int irda_release(struct socket *sock)
 	/* Destroy networking socket if we are the last reference on it,
 	 * i.e. if(sk->sk_refcnt == 0) -> sk_free(sk) */
 	sock_put(sk);
-	unlock_kernel();
 
 	/* Notes on socket locking and deallocation... - Jean II
 	 * In theory we should put pairs of sock_hold() / sock_put() to
@@ -1298,7 +1295,6 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
 
-	lock_kernel();
 	/* Note : socket.c set MSG_EOR on SEQPACKET sockets */
 	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_EOR | MSG_CMSG_COMPAT |
 			       MSG_NOSIGNAL)) {
@@ -1306,6 +1302,8 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 	}
 
+	lock_sock(sk);
+
 	if (sk->sk_shutdown & SEND_SHUTDOWN)
 		goto out_err;
 
@@ -1361,14 +1359,14 @@ static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
 		goto out_err;
 	}
 
-	unlock_kernel();
+	release_sock(sk);
 	/* Tell client how much data we actually sent */
 	return len;
 
 out_err:
 	err = sk_stream_error(sk, msg->msg_flags, err);
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err;
 
 }
@@ -1390,14 +1388,10 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
-	lock_kernel();
-	if ((err = sock_error(sk)) < 0)
-		goto out;
-
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &err);
 	if (!skb)
-		goto out;
+		return err;
 
 	skb_reset_transport_header(skb);
 	copied = skb->len;
@@ -1425,12 +1419,8 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 			irttp_flow_request(self->tsap, FLOW_START);
 		}
 	}
-	unlock_kernel();
-	return copied;
 
-out:
-	unlock_kernel();
-	return err;
+	return copied;
 }
 
 /*
@@ -1448,17 +1438,15 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 
 	IRDA_DEBUG(3, "%s()\n", __func__);
 
-	lock_kernel();
 	if ((err = sock_error(sk)) < 0)
-		goto out;
+		return err;
 
-	err = -EINVAL;
 	if (sock->flags & __SO_ACCEPTCON)
-		goto out;
+		return -EINVAL;
 
 	err =-EOPNOTSUPP;
 	if (flags & MSG_OOB)
-		goto out;
+		return -EOPNOTSUPP;
 
 	err = 0;
 	target = sock_rcvlowat(sk, flags & MSG_WAITALL, size);
@@ -1500,7 +1488,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 			finish_wait(sk_sleep(sk), &wait);
 
 			if (err)
-				goto out;
+				return err;
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
 				break;
 
@@ -1553,9 +1541,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 		}
 	}
 
-out:
-	unlock_kernel();
-	return err ? : copied;
+	return copied;
 }
 
 /*
@@ -1573,13 +1559,12 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 
-	lock_kernel();
-
 	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
 
-	err = -EINVAL;
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
-		goto out;
+		return -EINVAL;
+
+	lock_sock(sk);
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
 		send_sig(SIGPIPE, current, 0);
@@ -1630,10 +1615,12 @@ static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
 		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
 		goto out;
 	}
-	unlock_kernel();
+
+	release_sock(sk);
 	return len;
+
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err;
 }
 
@@ -1656,10 +1643,11 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 
 	IRDA_DEBUG(4, "%s(), len=%zd\n", __func__, len);
 
-	lock_kernel();
 	err = -EINVAL;
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_CMSG_COMPAT))
-		goto out;
+		return -EINVAL;
+
+	lock_sock(sk);
 
 	err = -EPIPE;
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
@@ -1732,7 +1720,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 	if (err)
 		IRDA_DEBUG(0, "%s(), err=%d\n", __func__, err);
 out:
-	unlock_kernel();
+	release_sock(sk);
 	return err ? : len;
 }
 #endif /* CONFIG_IRDA_ULTRA */
@@ -1747,7 +1735,7 @@ static int irda_shutdown(struct socket *sock, int how)
 
 	IRDA_DEBUG(1, "%s(%p)\n", __func__, self);
 
-	lock_kernel();
+	lock_sock(sk);
 
 	sk->sk_state       = TCP_CLOSE;
 	sk->sk_shutdown   |= SEND_SHUTDOWN;
@@ -1769,7 +1757,7 @@ static int irda_shutdown(struct socket *sock, int how)
 	self->daddr = DEV_ADDR_ANY;	/* Until we get re-connected */
 	self->saddr = 0x0;		/* so IrLMP assign us any link */
 
-	unlock_kernel();
+	release_sock(sk);
 
 	return 0;
 }
@@ -1786,7 +1774,6 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
-	lock_kernel();
 	poll_wait(file, sk_sleep(sk), wait);
 	mask = 0;
 
@@ -1834,20 +1821,8 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 	default:
 		break;
 	}
-	unlock_kernel();
-	return mask;
-}
 
-static unsigned int irda_datagram_poll(struct file *file, struct socket *sock,
-			   poll_table *wait)
-{
-	int err;
-
-	lock_kernel();
-	err = datagram_poll(file, sock, wait);
-	unlock_kernel();
-
-	return err;
+	return mask;
 }
 
 /*
@@ -1860,7 +1835,6 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 	IRDA_DEBUG(4, "%s(), cmd=%#x\n", __func__, cmd);
 
-	lock_kernel();
 	err = -EINVAL;
 	switch (cmd) {
 	case TIOCOUTQ: {
@@ -1903,7 +1877,6 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		IRDA_DEBUG(1, "%s(), doing device ioctl!\n", __func__);
 		err = -ENOIOCTLCMD;
 	}
-	unlock_kernel();
 
 	return err;
 }
@@ -1927,7 +1900,7 @@ static int irda_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned lon
  *    Set some options for the socket
  *
  */
-static int __irda_setsockopt(struct socket *sock, int level, int optname,
+static int irda_setsockopt(struct socket *sock, int level, int optname,
 			   char __user *optval, unsigned int optlen)
 {
 	struct sock *sk = sock->sk;
@@ -1935,13 +1908,15 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 	struct irda_ias_set    *ias_opt;
 	struct ias_object      *ias_obj;
 	struct ias_attrib *	ias_attr;	/* Attribute in IAS object */
-	int opt, free_ias = 0;
+	int opt, free_ias = 0, err = 0;
 
 	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
 
 	if (level != SOL_IRLMP)
 		return -ENOPROTOOPT;
 
+	lock_sock(sk);
+
 	switch (optname) {
 	case IRLMP_IAS_SET:
 		/* The user want to add an attribute to an existing IAS object
@@ -1951,17 +1926,22 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 		 * create the right attribute...
 		 */
 
-		if (optlen != sizeof(struct irda_ias_set))
-			return -EINVAL;
+		if (optlen != sizeof(struct irda_ias_set)) {
+			err = -EINVAL;
+			goto out;
+		}
 
 		ias_opt = kmalloc(sizeof(struct irda_ias_set), GFP_ATOMIC);
-		if (ias_opt == NULL)
-			return -ENOMEM;
+		if (ias_opt == NULL) {
+			err = -ENOMEM;
+			goto out;
+		}
 
 		/* Copy query to the driver. */
 		if (copy_from_user(ias_opt, optval, optlen)) {
 			kfree(ias_opt);
-			return -EFAULT;
+			err = -EFAULT;
+			goto out;
 		}
 
 		/* Find the object we target.
@@ -1971,7 +1951,8 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 		if(ias_opt->irda_class_name[0] == '\0') {
 			if(self->ias_obj == NULL) {
 				kfree(ias_opt);
-				return -EINVAL;
+				err = -EINVAL;
+				goto out;
 			}
 			ias_obj = self->ias_obj;
 		} else
@@ -1983,7 +1964,8 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 		if((!capable(CAP_NET_ADMIN)) &&
 		   ((ias_obj == NULL) || (ias_obj != self->ias_obj))) {
 			kfree(ias_opt);
-			return -EPERM;
+			err = -EPERM;
+			goto out;
 		}
 
 		/* If the object doesn't exist, create it */
@@ -1993,7 +1975,8 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 						   jiffies);
 			if (ias_obj == NULL) {
 				kfree(ias_opt);
-				return -ENOMEM;
+				err = -ENOMEM;
+				goto out;
 			}
 			free_ias = 1;
 		}
@@ -2005,7 +1988,8 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 				kfree(ias_obj->name);
 				kfree(ias_obj);
 			}
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 
 		/* Look at the type */
@@ -2028,7 +2012,8 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 					kfree(ias_obj);
 				}
 
-				return -EINVAL;
+				err = -EINVAL;
+				goto out;
 			}
 			/* Add an octet sequence attribute */
 			irias_add_octseq_attrib(
@@ -2060,7 +2045,8 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 				kfree(ias_obj->name);
 				kfree(ias_obj);
 			}
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 		irias_insert_object(ias_obj);
 		kfree(ias_opt);
@@ -2071,17 +2057,22 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 		 * object is not owned by the kernel and delete it.
 		 */
 
-		if (optlen != sizeof(struct irda_ias_set))
-			return -EINVAL;
+		if (optlen != sizeof(struct irda_ias_set)) {
+			err = -EINVAL;
+			goto out;
+		}
 
 		ias_opt = kmalloc(sizeof(struct irda_ias_set), GFP_ATOMIC);
-		if (ias_opt == NULL)
-			return -ENOMEM;
+		if (ias_opt == NULL) {
+			err = -ENOMEM;
+			goto out;
+		}
 
 		/* Copy query to the driver. */
 		if (copy_from_user(ias_opt, optval, optlen)) {
 			kfree(ias_opt);
-			return -EFAULT;
+			err = -EFAULT;
+			goto out;
 		}
 
 		/* Find the object we target.
@@ -2094,7 +2085,8 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 			ias_obj = irias_find_object(ias_opt->irda_class_name);
 		if(ias_obj == (struct ias_object *) NULL) {
 			kfree(ias_opt);
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 
 		/* Only ROOT can mess with the global IAS database.
@@ -2103,7 +2095,8 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 		if((!capable(CAP_NET_ADMIN)) &&
 		   ((ias_obj == NULL) || (ias_obj != self->ias_obj))) {
 			kfree(ias_opt);
-			return -EPERM;
+			err = -EPERM;
+			goto out;
 		}
 
 		/* Find the attribute (in the object) we target */
@@ -2111,14 +2104,16 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 					     ias_opt->irda_attrib_name);
 		if(ias_attr == (struct ias_attrib *) NULL) {
 			kfree(ias_opt);
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 
 		/* Check is the user space own the object */
 		if(ias_attr->value->owner != IAS_USER_ATTR) {
 			IRDA_DEBUG(1, "%s(), attempting to delete a kernel attribute\n", __func__);
 			kfree(ias_opt);
-			return -EPERM;
+			err = -EPERM;
+			goto out;
 		}
 
 		/* Remove the attribute (and maybe the object) */
@@ -2126,11 +2121,15 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 		kfree(ias_opt);
 		break;
 	case IRLMP_MAX_SDU_SIZE:
-		if (optlen < sizeof(int))
-			return -EINVAL;
+		if (optlen < sizeof(int)) {
+			err = -EINVAL;
+			goto out;
+		}
 
-		if (get_user(opt, (int __user *)optval))
-			return -EFAULT;
+		if (get_user(opt, (int __user *)optval)) {
+			err = -EFAULT;
+			goto out;
+		}
 
 		/* Only possible for a seqpacket service (TTP with SAR) */
 		if (sk->sk_type != SOCK_SEQPACKET) {
@@ -2140,16 +2139,21 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 		} else {
 			IRDA_WARNING("%s: not allowed to set MAXSDUSIZE for this socket type!\n",
 				     __func__);
-			return -ENOPROTOOPT;
+			err = -ENOPROTOOPT;
+			goto out;
 		}
 		break;
 	case IRLMP_HINTS_SET:
-		if (optlen < sizeof(int))
-			return -EINVAL;
+		if (optlen < sizeof(int)) {
+			err = -EINVAL;
+			goto out;
+		}
 
 		/* The input is really a (__u8 hints[2]), easier as an int */
-		if (get_user(opt, (int __user *)optval))
-			return -EFAULT;
+		if (get_user(opt, (int __user *)optval)) {
+			err = -EFAULT;
+			goto out;
+		}
 
 		/* Unregister any old registration */
 		if (self->skey)
@@ -2163,12 +2167,16 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 		 * making a discovery (nodes which don't match any hint
 		 * bit in the mask are not reported).
 		 */
-		if (optlen < sizeof(int))
-			return -EINVAL;
+		if (optlen < sizeof(int)) {
+			err = -EINVAL;
+			goto out;
+		}
 
 		/* The input is really a (__u8 hints[2]), easier as an int */
-		if (get_user(opt, (int __user *)optval))
-			return -EFAULT;
+		if (get_user(opt, (int __user *)optval)) {
+			err = -EFAULT;
+			goto out;
+		}
 
 		/* Set the new hint mask */
 		self->mask.word = (__u16) opt;
@@ -2180,19 +2188,12 @@ static int __irda_setsockopt(struct socket *sock, int level, int optname,
 
 		break;
 	default:
-		return -ENOPROTOOPT;
+		err = -ENOPROTOOPT;
+		break;
 	}
-	return 0;
-}
 
-static int irda_setsockopt(struct socket *sock, int level, int optname,
-			   char __user *optval, unsigned int optlen)
-{
-	int err;
-
-	lock_kernel();
-	err = __irda_setsockopt(sock, level, optname, optval, optlen);
-	unlock_kernel();
+out:
+	release_sock(sk);
 
 	return err;
 }
@@ -2249,7 +2250,7 @@ static int irda_extract_ias_value(struct irda_ias_set *ias_opt,
 /*
  * Function irda_getsockopt (sock, level, optname, optval, optlen)
  */
-static int __irda_getsockopt(struct socket *sock, int level, int optname,
+static int irda_getsockopt(struct socket *sock, int level, int optname,
 			   char __user *optval, int __user *optlen)
 {
 	struct sock *sk = sock->sk;
@@ -2262,7 +2263,7 @@ static int __irda_getsockopt(struct socket *sock, int level, int optname,
 	int daddr = DEV_ADDR_ANY;	/* Dest address for IAS queries */
 	int val = 0;
 	int len = 0;
-	int err;
+	int err = 0;
 	int offset, total;
 
 	IRDA_DEBUG(2, "%s(%p)\n", __func__, self);
@@ -2276,15 +2277,18 @@ static int __irda_getsockopt(struct socket *sock, int level, int optname,
 	if(len < 0)
 		return -EINVAL;
 
+	lock_sock(sk);
+
 	switch (optname) {
 	case IRLMP_ENUMDEVICES:
 		/* Ask lmp for the current discovery log */
 		discoveries = irlmp_get_discoveries(&list.len, self->mask.word,
 						    self->nslots);
 		/* Check if the we got some results */
-		if (discoveries == NULL)
-			return -EAGAIN;		/* Didn't find any devices */
-		err = 0;
+		if (discoveries == NULL) {
+			err = -EAGAIN;
+			goto out;		/* Didn't find any devices */
+		}
 
 		/* Write total list length back to client */
 		if (copy_to_user(optval, &list,
@@ -2297,8 +2301,7 @@ static int __irda_getsockopt(struct socket *sock, int level, int optname,
 			sizeof(struct irda_device_info);
 
 		/* Copy the list itself - watch for overflow */
-		if(list.len > 2048)
-		{
+		if (list.len > 2048) {
 			err = -EINVAL;
 			goto bed;
 		}
@@ -2314,17 +2317,20 @@ static int __irda_getsockopt(struct socket *sock, int level, int optname,
 bed:
 		/* Free up our buffer */
 		kfree(discoveries);
-		if (err)
-			return err;
 		break;
 	case IRLMP_MAX_SDU_SIZE:
 		val = self->max_data_size;
 		len = sizeof(int);
-		if (put_user(len, optlen))
-			return -EFAULT;
+		if (put_user(len, optlen)) {
+			err = -EFAULT;
+			goto out;
+		}
+
+		if (copy_to_user(optval, &val, len)) {
+			err = -EFAULT;
+			goto out;
+		}
 
-		if (copy_to_user(optval, &val, len))
-			return -EFAULT;
 		break;
 	case IRLMP_IAS_GET:
 		/* The user want an object from our local IAS database.
@@ -2332,17 +2338,22 @@ bed:
 		 * that we found */
 
 		/* Check that the user has allocated the right space for us */
-		if (len != sizeof(struct irda_ias_set))
-			return -EINVAL;
+		if (len != sizeof(struct irda_ias_set)) {
+			err = -EINVAL;
+			goto out;
+		}
 
 		ias_opt = kmalloc(sizeof(struct irda_ias_set), GFP_ATOMIC);
-		if (ias_opt == NULL)
-			return -ENOMEM;
+		if (ias_opt == NULL) {
+			err = -ENOMEM;
+			goto out;
+		}
 
 		/* Copy query to the driver. */
 		if (copy_from_user(ias_opt, optval, len)) {
 			kfree(ias_opt);
-			return -EFAULT;
+			err = -EFAULT;
+			goto out;
 		}
 
 		/* Find the object we target.
@@ -2355,7 +2366,8 @@ bed:
 			ias_obj = irias_find_object(ias_opt->irda_class_name);
 		if(ias_obj == (struct ias_object *) NULL) {
 			kfree(ias_opt);
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 
 		/* Find the attribute (in the object) we target */
@@ -2363,21 +2375,23 @@ bed:
 					     ias_opt->irda_attrib_name);
 		if(ias_attr == (struct ias_attrib *) NULL) {
 			kfree(ias_opt);
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 
 		/* Translate from internal to user structure */
 		err = irda_extract_ias_value(ias_opt, ias_attr->value);
 		if(err) {
 			kfree(ias_opt);
-			return err;
+			goto out;
 		}
 
 		/* Copy reply to the user */
 		if (copy_to_user(optval, ias_opt,
 				 sizeof(struct irda_ias_set))) {
 			kfree(ias_opt);
-			return -EFAULT;
+			err = -EFAULT;
+			goto out;
 		}
 		/* Note : don't need to put optlen, we checked it */
 		kfree(ias_opt);
@@ -2388,17 +2402,22 @@ bed:
 		 * then wait for the answer to come back. */
 
 		/* Check that the user has allocated the right space for us */
-		if (len != sizeof(struct irda_ias_set))
-			return -EINVAL;
+		if (len != sizeof(struct irda_ias_set)) {
+			err = -EINVAL;
+			goto out;
+		}
 
 		ias_opt = kmalloc(sizeof(struct irda_ias_set), GFP_ATOMIC);
-		if (ias_opt == NULL)
-			return -ENOMEM;
+		if (ias_opt == NULL) {
+			err = -ENOMEM;
+			goto out;
+		}
 
 		/* Copy query to the driver. */
 		if (copy_from_user(ias_opt, optval, len)) {
 			kfree(ias_opt);
-			return -EFAULT;
+			err = -EFAULT;
+			goto out;
 		}
 
 		/* At this point, there are two cases...
@@ -2419,7 +2438,8 @@ bed:
 			daddr = ias_opt->daddr;
 			if((!daddr) || (daddr == DEV_ADDR_ANY)) {
 				kfree(ias_opt);
-				return -EINVAL;
+				err = -EINVAL;
+				goto out;
 			}
 		}
 
@@ -2428,7 +2448,8 @@ bed:
 			IRDA_WARNING("%s: busy with a previous query\n",
 				     __func__);
 			kfree(ias_opt);
-			return -EBUSY;
+			err = -EBUSY;
+			goto out;
 		}
 
 		self->iriap = iriap_open(LSAP_ANY, IAS_CLIENT, self,
@@ -2436,7 +2457,8 @@ bed:
 
 		if (self->iriap == NULL) {
 			kfree(ias_opt);
-			return -ENOMEM;
+			err = -ENOMEM;
+			goto out;
 		}
 
 		/* Treat unexpected wakeup as disconnect */
@@ -2455,7 +2477,8 @@ bed:
 			 * we can free it regardless! */
 			kfree(ias_opt);
 			/* Treat signals as disconnect */
-			return -EHOSTUNREACH;
+			err = -EHOSTUNREACH;
+			goto out;
 		}
 
 		/* Check what happened */
@@ -2465,9 +2488,11 @@ bed:
 			/* Requested object/attribute doesn't exist */
 			if((self->errno == IAS_CLASS_UNKNOWN) ||
 			   (self->errno == IAS_ATTRIB_UNKNOWN))
-				return -EADDRNOTAVAIL;
+				err = -EADDRNOTAVAIL;
 			else
-				return -EHOSTUNREACH;
+				err = -EHOSTUNREACH;
+
+			goto out;
 		}
 
 		/* Translate from internal to user structure */
@@ -2476,14 +2501,15 @@ bed:
 			irias_delete_value(self->ias_result);
 		if (err) {
 			kfree(ias_opt);
-			return err;
+			goto out;
 		}
 
 		/* Copy reply to the user */
 		if (copy_to_user(optval, ias_opt,
 				 sizeof(struct irda_ias_set))) {
 			kfree(ias_opt);
-			return -EFAULT;
+			err = -EFAULT;
+			goto out;
 		}
 		/* Note : don't need to put optlen, we checked it */
 		kfree(ias_opt);
@@ -2504,11 +2530,15 @@ bed:
 		 */
 
 		/* Check that the user is passing us an int */
-		if (len != sizeof(int))
-			return -EINVAL;
+		if (len != sizeof(int)) {
+			err = -EINVAL;
+			goto out;
+		}
 		/* Get timeout in ms (max time we block the caller) */
-		if (get_user(val, (int __user *)optval))
-			return -EFAULT;
+		if (get_user(val, (int __user *)optval)) {
+			err = -EFAULT;
+			goto out;
+		}
 
 		/* Tell IrLMP we want to be notified */
 		irlmp_update_client(self->ckey, self->mask.word,
@@ -2520,8 +2550,6 @@ bed:
 
 		/* Wait until a node is discovered */
 		if (!self->cachedaddr) {
-			int ret = 0;
-
 			IRDA_DEBUG(1, "%s(), nothing discovered yet, going to sleep...\n", __func__);
 
 			/* Set watchdog timer to expire in <val> ms. */
@@ -2534,7 +2562,7 @@ bed:
 			/* Wait for IR-LMP to call us back */
 			__wait_event_interruptible(self->query_wait,
 			      (self->cachedaddr != 0 || self->errno == -ETIME),
-						   ret);
+						   err);
 
 			/* If watchdog is still activated, kill it! */
 			if(timer_pending(&(self->watchdog)))
@@ -2542,8 +2570,8 @@ bed:
 
 			IRDA_DEBUG(1, "%s(), ...waking up !\n", __func__);
 
-			if (ret != 0)
-				return ret;
+			if (err != 0)
+				goto out;
 		}
 		else
 			IRDA_DEBUG(1, "%s(), found immediately !\n",
@@ -2566,25 +2594,19 @@ bed:
 		 * If the user want more details, he should query
 		 * the whole discovery log and pick one device...
 		 */
-		if (put_user(daddr, (int __user *)optval))
-			return -EFAULT;
+		if (put_user(daddr, (int __user *)optval)) {
+			err = -EFAULT;
+			goto out;
+		}
 
 		break;
 	default:
-		return -ENOPROTOOPT;
+		err = -ENOPROTOOPT;
 	}
 
-	return 0;
-}
-
-static int irda_getsockopt(struct socket *sock, int level, int optname,
-			   char __user *optval, int __user *optlen)
-{
-	int err;
+out:
 
-	lock_kernel();
-	err = __irda_getsockopt(sock, level, optname, optval, optlen);
-	unlock_kernel();
+	release_sock(sk);
 
 	return err;
 }
@@ -2628,7 +2650,7 @@ static const struct proto_ops irda_seqpacket_ops = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	irda_accept,
 	.getname =	irda_getname,
-	.poll =		irda_datagram_poll,
+	.poll =		datagram_poll,
 	.ioctl =	irda_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl =	irda_compat_ioctl,
@@ -2652,7 +2674,7 @@ static const struct proto_ops irda_dgram_ops = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	irda_accept,
 	.getname =	irda_getname,
-	.poll =		irda_datagram_poll,
+	.poll =		datagram_poll,
 	.ioctl =	irda_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl =	irda_compat_ioctl,
@@ -2677,7 +2699,7 @@ static const struct proto_ops irda_ultra_ops = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	sock_no_accept,
 	.getname =	irda_getname,
-	.poll =		irda_datagram_poll,
+	.poll =		datagram_poll,
 	.ioctl =	irda_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl =	irda_compat_ioctl,
-- 
1.7.1

