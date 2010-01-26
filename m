From: Joe Perches <joe@perches.com>
Subject: [PATCH 19/21] net/atm/svc.c: checkpatch cleanups
Date: Tue, 26 Jan 2010 13:40:18 -0800
Message-ID: <70ac058f585f48edb12804e8849af32cba568b01.1264541550.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1484 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753995Ab0AZVkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:25 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert #include <asm... to #include <linux...
Spacing cleanups
Mostly 80 column wrapped
Move trailing statements to new lines
switch/case cleanups

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/svc.c |  249 +++++++++++++++++++++++++++++----------------------------
 1 files changed, 125 insertions(+), 124 deletions(-)

diff --git a/net/atm/svc.c b/net/atm/svc.c
index 251ddbc..3ba9a45 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -19,14 +19,15 @@
 #include <linux/atmdev.h>
 #include <linux/bitops.h>
 #include <net/sock.h>		/* for sock_no_* */
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 #include "resources.h"
 #include "common.h"		/* common for PVCs and SVCs */
 #include "signaling.h"
 #include "addr.h"
 
-static int svc_create(struct net *net, struct socket *sock, int protocol, int kern);
+static int svc_create(struct net *net, struct socket *sock, int protocol,
+		      int kern);
 
 /*
  * Note: since all this is still nicely synchronized with the signaling demon,
@@ -35,25 +36,25 @@ static int svc_create(struct net *net, struct socket *sock, int protocol, int ke
  */
 
 
-static int svc_shutdown(struct socket *sock,int how)
+static int svc_shutdown(struct socket *sock, int how)
 {
 	return 0;
 }
 
-
 static void svc_disconnect(struct atm_vcc *vcc)
 {
 	DEFINE_WAIT(wait);
 	struct sk_buff *skb;
 	struct sock *sk = sk_atm(vcc);
 
-	pr_debug("%p\n",vcc);
-	if (test_bit(ATM_VF_REGIS,&vcc->flags)) {
+	pr_debug("%p\n", vcc);
+	if (test_bit(ATM_VF_REGIS, &vcc->flags)) {
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
-		sigd_enq(vcc,as_close,NULL,NULL,NULL);
-		while (!test_bit(ATM_VF_RELEASED,&vcc->flags) && sigd) {
+		sigd_enq(vcc, as_close, NULL, NULL, NULL);
+		while (!test_bit(ATM_VF_RELEASED, &vcc->flags) && sigd) {
 			schedule();
-			prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+			prepare_to_wait(sk->sk_sleep, &wait,
+					TASK_UNINTERRUPTIBLE);
 		}
 		finish_wait(sk->sk_sleep, &wait);
 	}
@@ -62,35 +63,35 @@ static void svc_disconnect(struct atm_vcc *vcc)
 	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
 		atm_return(vcc, skb->truesize);
 		pr_debug("LISTEN REL\n");
-		sigd_enq2(NULL,as_reject,vcc,NULL,NULL,&vcc->qos,0);
+		sigd_enq2(NULL, as_reject, vcc, NULL, NULL, &vcc->qos, 0);
 		dev_kfree_skb(skb);
 	}
 	clear_bit(ATM_VF_REGIS, &vcc->flags);
 	/* ... may retry later */
 }
 
-
 static int svc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
 
-	if (sk)  {
+	if (sk) {
 		vcc = ATM_SD(sock);
 		pr_debug("%p\n", vcc);
 		clear_bit(ATM_VF_READY, &vcc->flags);
-		/* VCC pointer is used as a reference, so we must not free it
-		   (thereby subjecting it to re-use) before all pending connections
-		   are closed */
+		/*
+		 * VCC pointer is used as a reference,
+		 * so we must not free it (thereby subjecting it to re-use)
+		 * before all pending connections are closed
+		 */
 		svc_disconnect(vcc);
 		vcc_release(sock);
 	}
 	return 0;
 }
 
-
-static int svc_bind(struct socket *sock,struct sockaddr *sockaddr,
-    int sockaddr_len)
+static int svc_bind(struct socket *sock, struct sockaddr *sockaddr,
+		    int sockaddr_len)
 {
 	DEFINE_WAIT(wait);
 	struct sock *sk = sock->sk;
@@ -115,38 +116,37 @@ static int svc_bind(struct socket *sock,struct sockaddr *sockaddr,
 		error = -EAFNOSUPPORT;
 		goto out;
 	}
-	clear_bit(ATM_VF_BOUND,&vcc->flags);
+	clear_bit(ATM_VF_BOUND, &vcc->flags);
 	    /* failing rebind will kill old binding */
 	/* @@@ check memory (de)allocation on rebind */
-	if (!test_bit(ATM_VF_HASQOS,&vcc->flags)) {
+	if (!test_bit(ATM_VF_HASQOS, &vcc->flags)) {
 		error = -EBADFD;
 		goto out;
 	}
 	vcc->local = *addr;
 	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
-	sigd_enq(vcc,as_bind,NULL,NULL,&vcc->local);
+	sigd_enq(vcc, as_bind, NULL, NULL, &vcc->local);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
 	finish_wait(sk->sk_sleep, &wait);
-	clear_bit(ATM_VF_REGIS,&vcc->flags); /* doesn't count */
+	clear_bit(ATM_VF_REGIS, &vcc->flags); /* doesn't count */
 	if (!sigd) {
 		error = -EUNATCH;
 		goto out;
 	}
 	if (!sk->sk_err)
-		set_bit(ATM_VF_BOUND,&vcc->flags);
+		set_bit(ATM_VF_BOUND, &vcc->flags);
 	error = -sk->sk_err;
 out:
 	release_sock(sk);
 	return error;
 }
 
-
-static int svc_connect(struct socket *sock,struct sockaddr *sockaddr,
-    int sockaddr_len,int flags)
+static int svc_connect(struct socket *sock, struct sockaddr *sockaddr,
+		       int sockaddr_len, int flags)
 {
 	DEFINE_WAIT(wait);
 	struct sock *sk = sock->sk;
@@ -154,7 +154,7 @@ static int svc_connect(struct socket *sock,struct sockaddr *sockaddr,
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
-	pr_debug("%p\n",vcc);
+	pr_debug("%p\n", vcc);
 	lock_sock(sk);
 	if (sockaddr_len != sizeof(struct sockaddr_atmsvc)) {
 		error = -EINVAL;
@@ -202,7 +202,7 @@ static int svc_connect(struct socket *sock,struct sockaddr *sockaddr,
 		vcc->remote = *addr;
 		set_bit(ATM_VF_WAITING, &vcc->flags);
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
-		sigd_enq(vcc,as_connect,NULL,NULL,&vcc->remote);
+		sigd_enq(vcc, as_connect, NULL, NULL, &vcc->remote);
 		if (flags & O_NONBLOCK) {
 			finish_wait(sk->sk_sleep, &wait);
 			sock->state = SS_CONNECTING;
@@ -213,7 +213,8 @@ static int svc_connect(struct socket *sock,struct sockaddr *sockaddr,
 		while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 			schedule();
 			if (!signal_pending(current)) {
-				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+				prepare_to_wait(sk->sk_sleep, &wait,
+						TASK_INTERRUPTIBLE);
 				continue;
 			}
 			pr_debug("*ABORT*\n");
@@ -229,20 +230,22 @@ static int svc_connect(struct socket *sock,struct sockaddr *sockaddr,
 			 *   Kernel <--okay---- Demon
 			 *   Kernel <--close--- Demon
 			 */
-			sigd_enq(vcc,as_close,NULL,NULL,NULL);
+			sigd_enq(vcc, as_close, NULL, NULL, NULL);
 			while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
-				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+				prepare_to_wait(sk->sk_sleep, &wait,
+						TASK_INTERRUPTIBLE);
 				schedule();
 			}
 			if (!sk->sk_err)
-				while (!test_bit(ATM_VF_RELEASED,&vcc->flags)
-				    && sigd) {
-					prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+				while (!test_bit(ATM_VF_RELEASED, &vcc->flags) &&
+				       sigd) {
+					prepare_to_wait(sk->sk_sleep, &wait,
+							TASK_INTERRUPTIBLE);
 					schedule();
 				}
-			clear_bit(ATM_VF_REGIS,&vcc->flags);
-			clear_bit(ATM_VF_RELEASED,&vcc->flags);
-			clear_bit(ATM_VF_CLOSE,&vcc->flags);
+			clear_bit(ATM_VF_REGIS, &vcc->flags);
+			clear_bit(ATM_VF_RELEASED, &vcc->flags);
+			clear_bit(ATM_VF_CLOSE, &vcc->flags);
 			    /* we're gone now but may connect later */
 			error = -EINTR;
 			break;
@@ -270,17 +273,17 @@ static int svc_connect(struct socket *sock,struct sockaddr *sockaddr,
 /*
  * #endif
  */
-	if (!(error = vcc_connect(sock, vcc->itf, vcc->vpi, vcc->vci)))
+	error = vcc_connect(sock, vcc->itf, vcc->vpi, vcc->vci);
+	if (!error)
 		sock->state = SS_CONNECTED;
 	else
-		(void) svc_disconnect(vcc);
+		(void)svc_disconnect(vcc);
 out:
 	release_sock(sk);
 	return error;
 }
 
-
-static int svc_listen(struct socket *sock,int backlog)
+static int svc_listen(struct socket *sock, int backlog)
 {
 	DEFINE_WAIT(wait);
 	struct sock *sk = sock->sk;
@@ -290,17 +293,17 @@ static int svc_listen(struct socket *sock,int backlog)
 	pr_debug("%p\n", vcc);
 	lock_sock(sk);
 	/* let server handle listen on unbound sockets */
-	if (test_bit(ATM_VF_SESSION,&vcc->flags)) {
+	if (test_bit(ATM_VF_SESSION, &vcc->flags)) {
 		error = -EINVAL;
 		goto out;
 	}
 	if (test_bit(ATM_VF_LISTEN, &vcc->flags)) {
 		error = -EADDRINUSE;
 		goto out;
-        }
+	}
 	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
-	sigd_enq(vcc,as_listen,NULL,NULL,&vcc->local);
+	sigd_enq(vcc, as_listen, NULL, NULL, &vcc->local);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
@@ -310,7 +313,7 @@ static int svc_listen(struct socket *sock,int backlog)
 		error = -EUNATCH;
 		goto out;
 	}
-	set_bit(ATM_VF_LISTEN,&vcc->flags);
+	set_bit(ATM_VF_LISTEN, &vcc->flags);
 	vcc_insert_socket(sk);
 	sk->sk_max_ack_backlog = backlog > 0 ? backlog : ATM_BACKLOG_DEFAULT;
 	error = -sk->sk_err;
@@ -319,8 +322,7 @@ out:
 	return error;
 }
 
-
-static int svc_accept(struct socket *sock,struct socket *newsock,int flags)
+static int svc_accept(struct socket *sock, struct socket *newsock, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
@@ -344,8 +346,9 @@ static int svc_accept(struct socket *sock,struct socket *newsock,int flags)
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		while (!(skb = skb_dequeue(&sk->sk_receive_queue)) &&
 		       sigd) {
-			if (test_bit(ATM_VF_RELEASED,&old_vcc->flags)) break;
-			if (test_bit(ATM_VF_CLOSE,&old_vcc->flags)) {
+			if (test_bit(ATM_VF_RELEASED, &old_vcc->flags))
+				break;
+			if (test_bit(ATM_VF_CLOSE, &old_vcc->flags)) {
 				error = -sk->sk_err;
 				break;
 			}
@@ -360,7 +363,8 @@ static int svc_accept(struct socket *sock,struct socket *newsock,int flags)
 				error = -ERESTARTSYS;
 				break;
 			}
-			prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+			prepare_to_wait(sk->sk_sleep, &wait,
+					TASK_INTERRUPTIBLE);
 		}
 		finish_wait(sk->sk_sleep, &wait);
 		if (error)
@@ -369,31 +373,34 @@ static int svc_accept(struct socket *sock,struct socket *newsock,int flags)
 			error = -EUNATCH;
 			goto out;
 		}
-		msg = (struct atmsvc_msg *) skb->data;
+		msg = (struct atmsvc_msg *)skb->data;
 		new_vcc->qos = msg->qos;
-		set_bit(ATM_VF_HASQOS,&new_vcc->flags);
+		set_bit(ATM_VF_HASQOS, &new_vcc->flags);
 		new_vcc->remote = msg->svc;
 		new_vcc->local = msg->local;
 		new_vcc->sap = msg->sap;
 		error = vcc_connect(newsock, msg->pvc.sap_addr.itf,
-				    msg->pvc.sap_addr.vpi, msg->pvc.sap_addr.vci);
+				    msg->pvc.sap_addr.vpi,
+				    msg->pvc.sap_addr.vci);
 		dev_kfree_skb(skb);
 		sk->sk_ack_backlog--;
 		if (error) {
-			sigd_enq2(NULL,as_reject,old_vcc,NULL,NULL,
-			    &old_vcc->qos,error);
+			sigd_enq2(NULL, as_reject, old_vcc, NULL, NULL,
+				  &old_vcc->qos, error);
 			error = error == -EAGAIN ? -EBUSY : error;
 			goto out;
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
 		set_bit(ATM_VF_WAITING, &new_vcc->flags);
-		prepare_to_wait(sk_atm(new_vcc)->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
-		sigd_enq(new_vcc,as_accept,old_vcc,NULL,NULL);
+		prepare_to_wait(sk_atm(new_vcc)->sk_sleep, &wait,
+				TASK_UNINTERRUPTIBLE);
+		sigd_enq(new_vcc, as_accept, old_vcc, NULL, NULL);
 		while (test_bit(ATM_VF_WAITING, &new_vcc->flags) && sigd) {
 			release_sock(sk);
 			schedule();
 			lock_sock(sk);
-			prepare_to_wait(sk_atm(new_vcc)->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+			prepare_to_wait(sk_atm(new_vcc)->sk_sleep, &wait,
+					TASK_UNINTERRUPTIBLE);
 		}
 		finish_wait(sk_atm(new_vcc)->sk_sleep, &wait);
 		if (!sigd) {
@@ -413,39 +420,37 @@ out:
 	return error;
 }
 
-
-static int svc_getname(struct socket *sock,struct sockaddr *sockaddr,
-    int *sockaddr_len,int peer)
+static int svc_getname(struct socket *sock, struct sockaddr *sockaddr,
+		       int *sockaddr_len, int peer)
 {
 	struct sockaddr_atmsvc *addr;
 
 	*sockaddr_len = sizeof(struct sockaddr_atmsvc);
 	addr = (struct sockaddr_atmsvc *) sockaddr;
-	memcpy(addr,peer ? &ATM_SD(sock)->remote : &ATM_SD(sock)->local,
-	    sizeof(struct sockaddr_atmsvc));
+	memcpy(addr, peer ? &ATM_SD(sock)->remote : &ATM_SD(sock)->local,
+	       sizeof(struct sockaddr_atmsvc));
 	return 0;
 }
 
-
-int svc_change_qos(struct atm_vcc *vcc,struct atm_qos *qos)
+int svc_change_qos(struct atm_vcc *vcc, struct atm_qos *qos)
 {
 	struct sock *sk = sk_atm(vcc);
 	DEFINE_WAIT(wait);
 
 	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
-	sigd_enq2(vcc,as_modify,NULL,NULL,&vcc->local,qos,0);
+	sigd_enq2(vcc, as_modify, NULL, NULL, &vcc->local, qos, 0);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) &&
 	       !test_bit(ATM_VF_RELEASED, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
 	finish_wait(sk->sk_sleep, &wait);
-	if (!sigd) return -EUNATCH;
+	if (!sigd)
+		return -EUNATCH;
 	return -sk->sk_err;
 }
 
-
 static int svc_setsockopt(struct socket *sock, int level, int optname,
 			  char __user *optval, unsigned int optlen)
 {
@@ -455,37 +460,35 @@ static int svc_setsockopt(struct socket *sock, int level, int optname,
 
 	lock_sock(sk);
 	switch (optname) {
-		case SO_ATMSAP:
-			if (level != SOL_ATM || optlen != sizeof(struct atm_sap)) {
-				error = -EINVAL;
-				goto out;
-			}
-			if (copy_from_user(&vcc->sap, optval, optlen)) {
-				error = -EFAULT;
-				goto out;
-			}
-			set_bit(ATM_VF_HASSAP, &vcc->flags);
-			break;
-		case SO_MULTIPOINT:
-			if (level != SOL_ATM || optlen != sizeof(int)) {
-				error = -EINVAL;
-				goto out;
-			}
-			if (get_user(value, (int __user *) optval)) {
-				error = -EFAULT;
-				goto out;
-			}
-			if (value == 1) {
-				set_bit(ATM_VF_SESSION, &vcc->flags);
-			} else if (value == 0) {
-				clear_bit(ATM_VF_SESSION, &vcc->flags);
-			} else {
-				error = -EINVAL;
-			}
-			break;
-		default:
-			error = vcc_setsockopt(sock, level, optname,
-					       optval, optlen);
+	case SO_ATMSAP:
+		if (level != SOL_ATM || optlen != sizeof(struct atm_sap)) {
+			error = -EINVAL;
+			goto out;
+		}
+		if (copy_from_user(&vcc->sap, optval, optlen)) {
+			error = -EFAULT;
+			goto out;
+		}
+		set_bit(ATM_VF_HASSAP, &vcc->flags);
+		break;
+	case SO_MULTIPOINT:
+		if (level != SOL_ATM || optlen != sizeof(int)) {
+			error = -EINVAL;
+			goto out;
+		}
+		if (get_user(value, (int __user *)optval)) {
+			error = -EFAULT;
+			goto out;
+		}
+		if (value == 1)
+			set_bit(ATM_VF_SESSION, &vcc->flags);
+		else if (value == 0)
+			clear_bit(ATM_VF_SESSION, &vcc->flags);
+		else
+			error = -EINVAL;
+		break;
+	default:
+		error = vcc_setsockopt(sock, level, optname, optval, optlen);
 	}
 
 out:
@@ -493,9 +496,8 @@ out:
 	return error;
 }
 
-
-static int svc_getsockopt(struct socket *sock,int level,int optname,
-    char __user *optval,int __user *optlen)
+static int svc_getsockopt(struct socket *sock, int level, int optname,
+			  char __user *optval, int __user *optlen)
 {
 	struct sock *sk = sock->sk;
 	int error = 0, len;
@@ -522,7 +524,6 @@ out:
 	return error;
 }
 
-
 static int svc_addparty(struct socket *sock, struct sockaddr *sockaddr,
 			int sockaddr_len, int flags)
 {
@@ -553,7 +554,6 @@ out:
 	return error;
 }
 
-
 static int svc_dropparty(struct socket *sock, int ep_ref)
 {
 	DEFINE_WAIT(wait);
@@ -580,7 +580,6 @@ out:
 	return error;
 }
 
-
 static int svc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	int error, ep_ref;
@@ -588,29 +587,31 @@ static int svc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	struct atm_vcc *vcc = ATM_SD(sock);
 
 	switch (cmd) {
-		case ATM_ADDPARTY:
-			if (!test_bit(ATM_VF_SESSION, &vcc->flags))
-				return -EINVAL;
-			if (copy_from_user(&sa, (void __user *) arg, sizeof(sa)))
-				return -EFAULT;
-			error = svc_addparty(sock, (struct sockaddr *) &sa, sizeof(sa), 0);
-			break;
-		case ATM_DROPPARTY:
-			if (!test_bit(ATM_VF_SESSION, &vcc->flags))
-				return -EINVAL;
-			if (copy_from_user(&ep_ref, (void __user *) arg, sizeof(int)))
-				return -EFAULT;
-			error = svc_dropparty(sock, ep_ref);
-			break;
-		default:
-			error = vcc_ioctl(sock, cmd, arg);
+	case ATM_ADDPARTY:
+		if (!test_bit(ATM_VF_SESSION, &vcc->flags))
+			return -EINVAL;
+		if (copy_from_user(&sa, (void __user *) arg, sizeof(sa)))
+			return -EFAULT;
+		error = svc_addparty(sock, (struct sockaddr *)&sa, sizeof(sa),
+				     0);
+		break;
+	case ATM_DROPPARTY:
+		if (!test_bit(ATM_VF_SESSION, &vcc->flags))
+			return -EINVAL;
+		if (copy_from_user(&ep_ref, (void __user *) arg, sizeof(int)))
+			return -EFAULT;
+		error = svc_dropparty(sock, ep_ref);
+		break;
+	default:
+		error = vcc_ioctl(sock, cmd, arg);
 	}
 
 	return error;
 }
 
 #ifdef CONFIG_COMPAT
-static int svc_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+static int svc_compat_ioctl(struct socket *sock, unsigned int cmd,
+			    unsigned long arg)
 {
 	/* The definition of ATM_ADDPARTY uses the size of struct atm_iobuf.
 	   But actually it takes a struct sockaddr_atmsvc, which doesn't need
@@ -661,13 +662,13 @@ static int svc_create(struct net *net, struct socket *sock, int protocol,
 
 	sock->ops = &svc_proto_ops;
 	error = vcc_create(net, sock, protocol, AF_ATMSVC);
-	if (error) return error;
+	if (error)
+		return error;
 	ATM_SD(sock)->local.sas_family = AF_ATMSVC;
 	ATM_SD(sock)->remote.sas_family = AF_ATMSVC;
 	return 0;
 }
 
-
 static const struct net_proto_family svc_family_ops = {
 	.family = PF_ATMSVC,
 	.create = svc_create,
-- 
1.6.6.rc0.57.gad7a

