From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM][4/6] eliminate SOCKOPS_WRAPPED
Date: Mon, 13 Oct 2003 23:46:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310140346.h9E3k4kT005607@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.4 --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1142  -> 1.1143 
#	       net/atm/pvc.c	1.7     -> 1.8    
#	       net/atm/svc.c	1.8     -> 1.9    
#	    net/atm/common.h	1.7     -> 1.8    
#	 net/atm/signaling.c	1.7     -> 1.8    
#	    net/atm/common.c	1.24    -> 1.25   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/13	chas@relax.cmf.nrl.navy.mil	1.1143
# [ATM]: eliminate SOCKOPS_WRAPPED
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Oct 13 18:41:25 2003
+++ b/net/atm/common.c	Mon Oct 13 18:41:25 2003
@@ -469,35 +469,57 @@
   
   
 
-int atm_sendmsg(struct socket *sock,struct msghdr *m,int total_len,
-    struct scm_cookie *scm)
+int vcc_sendmsg(struct socket *sock, struct msghdr *m, int total_len,
+		struct scm_cookie *scm)
 {
+ 	struct sock *sk = sock->sk;
 	DECLARE_WAITQUEUE(wait,current);
-	struct atm_vcc *vcc;
-	struct sk_buff *skb;
-	int eff,error;
-	const void *buff;
-	int size;
+  	struct atm_vcc *vcc;
+  	struct sk_buff *skb;
+  	int eff,error;
+  	const void *buff;
+  	int size;
 
-	if (sock->state != SS_CONNECTED) return -ENOTCONN;
-	if (m->msg_name) return -EISCONN;
-	if (m->msg_iovlen != 1) return -ENOSYS; /* fix this later @@@ */
-	buff = m->msg_iov->iov_base;
-	size = m->msg_iov->iov_len;
-	vcc = ATM_SD(sock);
-	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-	    test_bit(ATM_VF_CLOSE,&vcc->flags))
-		return vcc->reply;
-	if (!test_bit(ATM_VF_READY,&vcc->flags)) return -EPIPE;
-	if (!size) return 0;
-	if (size < 0 || size > vcc->qos.txtp.max_sdu) return -EMSGSIZE;
-	/* verify_area is done by net/socket.c */
-	eff = (size+3) & ~3; /* align to word boundary */
-	add_wait_queue(&vcc->sleep,&wait);
+ 	lock_sock(sk);
+ 	if (sock->state != SS_CONNECTED) {
+ 		error = -ENOTCONN;
+ 		goto out;
+ 	}
+ 	if (m->msg_name) {
+ 		error = -EISCONN;
+ 		goto out;
+ 	}
+ 	if (m->msg_iovlen != 1) {
+ 		error = -ENOSYS; /* fix this later @@@ */
+ 		goto out;
+ 	}
+  	buff = m->msg_iov->iov_base;
+  	size = m->msg_iov->iov_len;
+  	vcc = ATM_SD(sock);
+ 	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
+ 	    test_bit(ATM_VF_CLOSE, &vcc->flags)) {
+ 		error = vcc->reply;
+ 		goto out;
+ 	}
+ 	if (!test_bit(ATM_VF_READY, &vcc->flags)) {
+ 		error = -EPIPE;
+ 		goto out;
+ 	}
+ 	if (!size) {
+ 		error = 0;
+ 		goto out;
+ 	}
+ 	if (size < 0 || size > vcc->qos.txtp.max_sdu) {
+ 		error = -EMSGSIZE;
+ 		goto out;
+ 	}
+  	/* verify_area is done by net/socket.c */
+  	eff = (size+3) & ~3; /* align to word boundary */
+ 	add_wait_queue(&vcc->sleep,&wait);
 	set_current_state(TASK_INTERRUPTIBLE);
-	error = 0;
-	while (!(skb = alloc_tx(vcc,eff))) {
-		if (m->msg_flags & MSG_DONTWAIT) {
+  	error = 0;
+  	while (!(skb = alloc_tx(vcc,eff))) {
+  		if (m->msg_flags & MSG_DONTWAIT) {
 			error = -EAGAIN;
 			break;
 		}
@@ -519,16 +541,21 @@
 	}
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&vcc->sleep,&wait);
-	if (error) return error;
+	if (error)
+		goto out;
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 	if (copy_from_user(skb_put(skb,size),buff,size)) {
 		kfree_skb(skb);
-		return -EFAULT;
+		error = -EFAULT;
+		goto out;
 	}
 	if (eff != size) memset(skb->data+size,0,eff-size);
 	error = vcc->dev->ops->send(vcc,skb);
-	return error ? error : size;
+	error = error ? error : size;
+out:
+	release_sock(sk);
+	return error;
 }
 
 
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Oct 13 18:41:25 2003
+++ b/net/atm/common.h	Mon Oct 13 18:41:25 2003
@@ -15,8 +15,8 @@
 int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
 int vcc_recvmsg(struct socket *sock, struct msghdr *msg,
 		int size, int flags, struct scm_cookie *scm);
-int atm_sendmsg(struct socket *sock,struct msghdr *m,int total_len,
-  struct scm_cookie *scm);
+int vcc_sendmsg(struct socket *sock, struct msghdr *m, int total_len,
+		struct scm_cookie *scm);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int atm_setsockopt(struct socket *sock,int level,int optname,char *optval,
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Mon Oct 13 18:41:25 2003
+++ b/net/atm/pvc.c	Mon Oct 13 18:41:25 2003
@@ -32,20 +32,29 @@
 static int pvc_bind(struct socket *sock,struct sockaddr *sockaddr,
     int sockaddr_len)
 {
+	struct sock *sk = sock->sk;
 	struct sockaddr_atmpvc *addr;
 	struct atm_vcc *vcc;
+	int error;
 
 	if (sockaddr_len != sizeof(struct sockaddr_atmpvc)) return -EINVAL;
 	addr = (struct sockaddr_atmpvc *) sockaddr;
 	if (addr->sap_family != AF_ATMPVC) return -EAFNOSUPPORT;
+	lock_sock(sk);
 	vcc = ATM_SD(sock);
-	if (!test_bit(ATM_VF_HASQOS,&vcc->flags)) return -EBADFD;
+	if (!test_bit(ATM_VF_HASQOS, &vcc->flags)) {
+		error = -EBADFD;
+		goto out;
+	}
 	if (test_bit(ATM_VF_PARTIAL,&vcc->flags)) {
 		if (vcc->vpi != ATM_VPI_UNSPEC) addr->sap_addr.vpi = vcc->vpi;
 		if (vcc->vci != ATM_VCI_UNSPEC) addr->sap_addr.vci = vcc->vci;
 	}
-	return vcc_connect(sock, addr->sap_addr.itf, addr->sap_addr.vpi,
+	error = vcc_connect(sock, addr->sap_addr.itf, addr->sap_addr.vpi,
 			   addr->sap_addr.vci);
+out:
+	release_sock(sk);
+	return error;
 }
 
 
@@ -55,6 +64,31 @@
 	return pvc_bind(sock,sockaddr,sockaddr_len);
 }
 
+static int pvc_setsockopt(struct socket *sock, int level, int optname,
+			  char *optval, int optlen)
+{
+	struct sock *sk = sock->sk;
+	int error;
+
+	lock_sock(sk);
+	error = atm_setsockopt(sock, level, optname, optval, optlen);
+	release_sock(sk);
+	return error;
+}
+
+
+static int pvc_getsockopt(struct socket *sock, int level, int optname,
+		          char *optval, int *optlen)
+{
+	struct sock *sk = sock->sk;
+	int error;
+
+	lock_sock(sk);
+	error = atm_getsockopt(sock, level, optname, optval, optlen);
+	release_sock(sk);
+	return error;
+}
+
 
 static int pvc_getname(struct socket *sock,struct sockaddr *sockaddr,
     int *sockaddr_len,int peer)
@@ -73,7 +107,7 @@
 }
 
 
-static struct proto_ops SOCKOPS_WRAPPED(pvc_proto_ops) = {
+static struct proto_ops pvc_proto_ops = {
 	.family =	PF_ATMPVC,
 
 	.release =	atm_release,
@@ -86,17 +120,13 @@
 	.ioctl =	vcc_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	pvc_shutdown,
-	.setsockopt =	atm_setsockopt,
-	.getsockopt =	atm_getsockopt,
-	.sendmsg =	atm_sendmsg,
+	.setsockopt =	pvc_setsockopt,
+	.getsockopt =	pvc_getsockopt,
+	.sendmsg =	vcc_sendmsg,
 	.recvmsg =	vcc_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
-
-
-#include <linux/smp_lock.h>
-SOCKOPS_WRAP(pvc_proto, PF_ATMPVC);
 
 
 static int pvc_create(struct socket *sock,int protocol)
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Oct 13 18:41:25 2003
+++ b/net/atm/signaling.c	Mon Oct 13 18:41:25 2003
@@ -129,9 +129,10 @@
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
 			DPRINTK("as_indicate!!!\n");
+			lock_sock(vcc->sk);
 			if (vcc->sk->ack_backlog == vcc->sk->max_ack_backlog) {
 				sigd_enq(0,as_reject,vcc,NULL,NULL);
-				return 0;
+				goto as_indicate_complete;
 			}
 			vcc->sk->ack_backlog++;
 			skb_queue_tail(&vcc->sk->receive_queue,skb);
@@ -140,6 +141,8 @@
 				    &vcc->sleep);
 				vcc->callback(vcc);
 			}
+as_indicate_complete:
+			release_sock(vcc->sk);
 			return 0;
 		case as_close:
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Oct 13 18:41:25 2003
+++ b/net/atm/svc.c	Mon Oct 13 18:41:25 2003
@@ -109,20 +109,39 @@
     int sockaddr_len)
 {
 	DECLARE_WAITQUEUE(wait,current);
+	struct sock *sk = sock->sk;
 	struct sockaddr_atmsvc *addr;
 	struct atm_vcc *vcc;
+	int error;
 
-	if (sockaddr_len != sizeof(struct sockaddr_atmsvc)) return -EINVAL;
-	if (sock->state == SS_CONNECTED) return -EISCONN;
-	if (sock->state != SS_UNCONNECTED) return -EINVAL;
+	if (sockaddr_len != sizeof(struct sockaddr_atmsvc))
+		return -EINVAL;
+	lock_sock(sk);
+	if (sock->state == SS_CONNECTED) {
+		error = -EISCONN;
+		goto out;
+	}
+	if (sock->state != SS_UNCONNECTED) {
+		error = -EINVAL;
+		goto out;
+	}
 	vcc = ATM_SD(sock);
-	if (test_bit(ATM_VF_SESSION,&vcc->flags)) return -EINVAL;
+	if (test_bit(ATM_VF_SESSION, &vcc->flags)) {
+		error = -EINVAL;
+		goto out;
+	}
 	addr = (struct sockaddr_atmsvc *) sockaddr;
-	if (addr->sas_family != AF_ATMSVC) return -EAFNOSUPPORT;
+	if (addr->sas_family != AF_ATMSVC) {
+		error = -EAFNOSUPPORT;
+		goto out;
+	}
 	clear_bit(ATM_VF_BOUND,&vcc->flags);
 	    /* failing rebind will kill old binding */
 	/* @@@ check memory (de)allocation on rebind */
-	if (!test_bit(ATM_VF_HASQOS,&vcc->flags)) return -EBADFD;
+	if (!test_bit(ATM_VF_HASQOS,&vcc->flags)) {
+		error = -EBADFD;
+		goto out;
+	}
 	vcc->local = *addr;
 	vcc->reply = WAITING;
 	add_wait_queue(&vcc->sleep,&wait);
@@ -133,9 +152,16 @@
 	}
 	remove_wait_queue(&vcc->sleep,&wait);
 	clear_bit(ATM_VF_REGIS,&vcc->flags); /* doesn't count */
-	if (!sigd) return -EUNATCH;
-        if (!vcc->reply) set_bit(ATM_VF_BOUND,&vcc->flags);
-	return vcc->reply;
+	if (!sigd) {
+		error = -EUNATCH;
+		goto out;
+	}
+        if (!vcc->reply)
+		set_bit(ATM_VF_BOUND,&vcc->flags);
+	error = vcc->reply;
+out:
+	release_sock(sk);
+	return error;
 }
 
 
@@ -143,31 +169,60 @@
     int sockaddr_len,int flags)
 {
 	DECLARE_WAITQUEUE(wait,current);
+	struct sock *sk = sock->sk;
 	struct sockaddr_atmsvc *addr;
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
 	DPRINTK("svc_connect %p\n",vcc);
-	if (sockaddr_len != sizeof(struct sockaddr_atmsvc)) return -EINVAL;
-	if (sock->state == SS_CONNECTED) return -EISCONN;
-	if (sock->state == SS_CONNECTING) {
-		if (vcc->reply == WAITING) return -EALREADY;
-		sock->state = SS_UNCONNECTED;
-		if (vcc->reply) return vcc->reply;
+	lock_sock(sk);
+	if (sockaddr_len != sizeof(struct sockaddr_atmsvc)) {
+		error = -EINVAL;
+		goto out;
 	}
-	else {
-		int error;
 
-		if (sock->state != SS_UNCONNECTED) return -EINVAL;
-		if (test_bit(ATM_VF_SESSION,&vcc->flags)) return -EINVAL;
+	switch (sock->state) {
+	default:
+		error = -EINVAL;
+		goto out;
+	case SS_CONNECTED:
+		error = -EISCONN;
+		goto out;
+	case SS_CONNECTING:
+		if (vcc->reply == WAITING) {
+			error = -EALREADY;
+			goto out;
+		}
+		sock->state = SS_UNCONNECTED;
+		if (vcc->reply) {
+			error = vcc->reply;
+			goto out;
+		}
+		break;
+	case SS_UNCONNECTED:
+		if (test_bit(ATM_VF_SESSION, &vcc->flags)) {
+			error = -EINVAL;
+			goto out;
+		}
 		addr = (struct sockaddr_atmsvc *) sockaddr;
-		if (addr->sas_family != AF_ATMSVC) return -EAFNOSUPPORT;
-		if (!test_bit(ATM_VF_HASQOS,&vcc->flags)) return -EBADFD;
+		if (addr->sas_family != AF_ATMSVC) {
+			error = -EAFNOSUPPORT;
+			goto out;
+		}
+		if (!test_bit(ATM_VF_HASQOS, &vcc->flags)) {
+			error = -EBADFD;
+			goto out;
+		}
 		if (vcc->qos.txtp.traffic_class == ATM_ANYCLASS ||
-		    vcc->qos.rxtp.traffic_class == ATM_ANYCLASS)
-			return -EINVAL;
+		    vcc->qos.rxtp.traffic_class == ATM_ANYCLASS) {
+			error = -EINVAL;
+			goto out;
+		}
 		if (!vcc->qos.txtp.traffic_class &&
-		    !vcc->qos.rxtp.traffic_class) return -EINVAL;
+		    !vcc->qos.rxtp.traffic_class) {
+			error = -EINVAL;
+			goto out;
+		}
 		vcc->remote = *addr;
 		vcc->reply = WAITING;
 		add_wait_queue(&vcc->sleep,&wait);
@@ -175,7 +230,8 @@
 		if (flags & O_NONBLOCK) {
 			remove_wait_queue(&vcc->sleep,&wait);
 			sock->state = SS_CONNECTING;
-			return -EINPROGRESS;
+			error = -EINPROGRESS;
+			goto out;
 		}
 		error = 0;
 		while (vcc->reply == WAITING && sigd) {
@@ -214,9 +270,16 @@
 			break;
 		}
 		remove_wait_queue(&vcc->sleep,&wait);
-		if (error) return error;
-		if (!sigd) return -EUNATCH;
-		if (vcc->reply) return vcc->reply;
+		if (error)
+			goto out;
+		if (!sigd) {
+			error = -EUNATCH;
+			goto out;
+		}
+		if (vcc->reply) {
+			error = vcc->reply;
+			goto out;
+		}
 	}
 /*
  * Not supported yet
@@ -232,6 +295,8 @@
 	if (!(error = vcc_connect(sock, vcc->itf, vcc->vpi, vcc->vci)))
 		sock->state = SS_CONNECTED;
 	else (void) svc_disconnect(vcc);
+out:
+	release_sock(sk);
 	return error;
 }
 
@@ -239,11 +304,17 @@
 static int svc_listen(struct socket *sock,int backlog)
 {
 	DECLARE_WAITQUEUE(wait,current);
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc = ATM_SD(sock);
+	int error;
 
 	DPRINTK("svc_listen %p\n",vcc);
+	lock_sock(sk);
 	/* let server handle listen on unbound sockets */
-	if (test_bit(ATM_VF_SESSION,&vcc->flags)) return -EINVAL;
+	if (test_bit(ATM_VF_SESSION,&vcc->flags)) {
+		error = -EINVAL;
+		goto out;
+	}
 	vcc->reply = WAITING;
 	add_wait_queue(&vcc->sleep,&wait);
 	sigd_enq(vcc,as_listen,NULL,NULL,&vcc->local);
@@ -252,24 +323,33 @@
 		schedule();
 	}
 	remove_wait_queue(&vcc->sleep,&wait);
-	if (!sigd) return -EUNATCH;
+	if (!sigd) {
+		error = -EUNATCH;
+		goto out;
+	}
 	set_bit(ATM_VF_LISTEN,&vcc->flags);
 	vcc->sk->max_ack_backlog = backlog > 0 ? backlog : ATM_BACKLOG_DEFAULT;
-	return vcc->reply;
+	error = vcc->reply;
+out:
+	release_sock(sk);
+	return error;
 }
 
 
 static int svc_accept(struct socket *sock,struct socket *newsock,int flags)
 {
+	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
 	struct atmsvc_msg *msg;
 	struct atm_vcc *old_vcc = ATM_SD(sock);
 	struct atm_vcc *new_vcc;
 	int error;
 
+	lock_sock(sk);
+
 	error = svc_create(newsock,0);
 	if (error)
-		return error;
+		goto out;
 
 	new_vcc = ATM_SD(newsock);
 
@@ -288,16 +368,21 @@
 				error = -EAGAIN;
 				break;
 			}
-			set_current_state(TASK_INTERRUPTIBLE);
+			release_sock(sk);
 			schedule();
+			lock_sock(sk);
 			if (signal_pending(current)) {
 				error = -ERESTARTSYS;
 				break;
 			}
 		}
 		remove_wait_queue(&old_vcc->sleep,&wait);
-		if (error) return error;
-		if (!skb) return -EUNATCH;
+		if (error)
+			goto out;
+		if (!skb) {
+			error = -EUNATCH;
+			goto out;
+		}
 		msg = (struct atmsvc_msg *) skb->data;
 		new_vcc->qos = msg->qos;
 		set_bit(ATM_VF_HASQOS,&new_vcc->flags);
@@ -311,7 +396,8 @@
 		if (error) {
 			sigd_enq2(NULL,as_reject,old_vcc,NULL,NULL,
 			    &old_vcc->qos,error);
-			return error == -EAGAIN ? -EBUSY : error;
+			error = error == -EAGAIN ? -EBUSY : error;
+			goto out;
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
 		new_vcc->reply = WAITING;
@@ -319,15 +405,25 @@
 		sigd_enq(new_vcc,as_accept,old_vcc,NULL,NULL);
 		while (new_vcc->reply == WAITING && sigd) {
 			set_current_state(TASK_UNINTERRUPTIBLE);
+			release_sock(sk);
 			schedule();
+			lock_sock(sk);
 		}
 		remove_wait_queue(&new_vcc->sleep,&wait);
-		if (!sigd) return -EUNATCH;
+		if (!sigd) {
+			error = -EUNATCH;
+			goto out;
+		}
 		if (!new_vcc->reply) break;
-		if (new_vcc->reply != -ERESTARTSYS) return new_vcc->reply;
+		if (new_vcc->reply != -ERESTARTSYS) {
+			error = new_vcc->reply;
+			goto out;
+		}
 	}
 	newsock->state = SS_CONNECTED;
-	return 0;
+out:
+	release_sock(sk);
+	return error;
 }
 
 
@@ -365,33 +461,57 @@
 static int svc_setsockopt(struct socket *sock,int level,int optname,
     char *optval,int optlen)
 {
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
+	int error = 0;
 
 	if (!__SO_LEVEL_MATCH(optname, level) || optname != SO_ATMSAP ||
-	    optlen != sizeof(struct atm_sap))
-		return atm_setsockopt(sock,level,optname,optval,optlen);
+	    optlen != sizeof(struct atm_sap)) {
+		error = atm_setsockopt(sock, level, optname, optval, optlen);
+		goto out;
+	}
 	vcc = ATM_SD(sock);
-	if (copy_from_user(&vcc->sap,optval,optlen)) return -EFAULT;
-	set_bit(ATM_VF_HASSAP,&vcc->flags);
-	return 0;
+	if (copy_from_user(&vcc->sap, optval, optlen)) {
+		error = -EFAULT;
+		goto out;
+	}
+	set_bit(ATM_VF_HASSAP, &vcc->flags);
+out:
+	release_sock(sk);
+	return error;
 }
 
 
 static int svc_getsockopt(struct socket *sock,int level,int optname,
     char *optval,int *optlen)
 {
-	int len;
+	struct sock *sk = sock->sk;
+	int error = 0, len;
 
-	if (!__SO_LEVEL_MATCH(optname, level) || optname != SO_ATMSAP)
-		return atm_getsockopt(sock,level,optname,optval,optlen);
-	if (get_user(len,optlen)) return -EFAULT;
-	if (len != sizeof(struct atm_sap)) return -EINVAL;
-	return copy_to_user(optval,&ATM_SD(sock)->sap,sizeof(struct atm_sap)) ?
-	    -EFAULT : 0;
+	lock_sock(sk);
+	if (!__SO_LEVEL_MATCH(optname, level) || optname != SO_ATMSAP) {
+		error = atm_getsockopt(sock, level, optname, optval, optlen);
+		goto out;
+	}
+	if (get_user(len, optlen)) {
+		error = -EFAULT;
+		goto out;
+	}
+	if (len != sizeof(struct atm_sap)) {
+		error = -EINVAL;
+		goto out;
+	}
+	if (copy_to_user(optval, &ATM_SD(sock)->sap, sizeof(struct atm_sap))) {
+		error = -EFAULT;
+		goto out;
+	}
+out:
+	release_sock(sk);
+	return error;
 }
 
 
-static struct proto_ops SOCKOPS_WRAPPED(svc_proto_ops) = {
+static struct proto_ops svc_proto_ops = {
 	.family =	PF_ATMSVC,
 
 	.release =	svc_release,
@@ -406,15 +526,12 @@
 	.shutdown =	svc_shutdown,
 	.setsockopt =	svc_setsockopt,
 	.getsockopt =	svc_getsockopt,
-	.sendmsg =	atm_sendmsg,
+	.sendmsg =	vcc_sendmsg,
 	.recvmsg =	vcc_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
 
-
-#include <linux/smp_lock.h>
-SOCKOPS_WRAP(svc_proto, PF_ATMSVC);
 
 static int svc_create(struct socket *sock,int protocol)
 {
