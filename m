From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM][2/3] assorted changes for atm
Date: Tue, 17 Jun 2003 08:40:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306171240.h5HCe5S1021440@locutus.cmf.nrl.navy.mil>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[atm]: rewrite recvmsg

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1399  -> 1.1400 
#	       net/atm/pvc.c	1.9     -> 1.10   
#	       net/atm/lec.c	1.25    -> 1.26   
#	       net/atm/svc.c	1.11    -> 1.12   
#	    net/atm/common.h	1.5     -> 1.6    
#	net/atm/mpoa_caches.c	1.1     -> 1.2    
#	 net/atm/signaling.c	1.9     -> 1.10   
#	include/linux/atmdev.h	1.14    -> 1.15   
#	      net/atm/clip.c	1.13    -> 1.14   
#	    net/atm/common.c	1.28    -> 1.29   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/16	chas@relax.cmf.nrl.navy.mil	1.1400
# rewrite recvmsg and rename atm_async_release_vcc
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Tue Jun 17 08:12:46 2003
+++ b/include/linux/atmdev.h	Tue Jun 17 08:12:46 2003
@@ -452,7 +452,7 @@
 int atm_find_ci(struct atm_vcc *vcc,short *vpi,int *vci);
 int atm_pcr_goal(struct atm_trafprm *tp);
 
-void atm_async_release_vcc(struct atm_vcc *vcc,int reply);
+void vcc_release_async(struct atm_vcc *vcc, int reply);
 
 #endif /* __KERNEL__ */
 
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Tue Jun 17 08:12:46 2003
+++ b/net/atm/clip.c	Tue Jun 17 08:12:46 2003
@@ -140,8 +140,8 @@
 					DPRINTK("releasing vcc %p->%p of "
 					    "entry %p\n",clip_vcc,clip_vcc->vcc,
 					    entry);
-					atm_async_release_vcc(clip_vcc->vcc,
-					    -ETIMEDOUT);
+					vcc_release_async(clip_vcc->vcc,
+							  -ETIMEDOUT);
 				}
 			if (entry->vccs ||
 			    time_before(jiffies, entry->expires)) {
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Tue Jun 17 08:12:46 2003
+++ b/net/atm/common.c	Tue Jun 17 08:12:46 2003
@@ -239,15 +239,16 @@
 }
 
 
-void atm_async_release_vcc(struct atm_vcc *vcc,int reply)
+void vcc_release_async(struct atm_vcc *vcc, int reply)
 {
-	set_bit(ATM_VF_CLOSE,&vcc->flags);
+	set_bit(ATM_VF_CLOSE, &vcc->flags);
 	vcc->reply = reply;
+	vcc->sk->sk_err = -reply;
 	wake_up(&vcc->sleep);
 }
 
 
-EXPORT_SYMBOL(atm_async_release_vcc);
+EXPORT_SYMBOL(vcc_release_async);
 
 
 static int adjust_tp(struct atm_trafprm *tp,unsigned char aal)
@@ -414,62 +415,46 @@
 }
 
 
-int atm_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		int total_len, int flags)
+int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
+		int size, int flags)
 {
-	DECLARE_WAITQUEUE(wait,current);
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
 	struct sk_buff *skb;
-	int eff_len,error;
-	void *buff;
-	int size;
-
-	if (sock->state != SS_CONNECTED) return -ENOTCONN;
-	if (flags & ~MSG_DONTWAIT) return -EOPNOTSUPP;
-	if (m->msg_iovlen != 1) return -ENOSYS; /* fix this later @@@ */
-	buff = m->msg_iov->iov_base;
-	size = m->msg_iov->iov_len;
+	int copied, error = -EINVAL;
+
+	if (sock->state != SS_CONNECTED)
+		return -ENOTCONN;
+	if (flags & ~MSG_DONTWAIT)		/* only handle MSG_DONTWAIT */
+		return -EOPNOTSUPP;
 	vcc = ATM_SD(sock);
-	add_wait_queue(&vcc->sleep,&wait);
-	set_current_state(TASK_INTERRUPTIBLE);
-	error = 1; /* <= 0 is error */
-	while (!(skb = skb_dequeue(&vcc->sk->sk_receive_queue))) {
-		if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-		    test_bit(ATM_VF_CLOSE,&vcc->flags)) {
-			error = vcc->reply;
-			break;
-		}
-		if (!test_bit(ATM_VF_READY,&vcc->flags)) {
-			error = 0;
-			break;
-		}
-		if (flags & MSG_DONTWAIT) {
-			error = -EAGAIN;
-			break;
-		}
-		schedule();
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (signal_pending(current)) {
-			error = -ERESTARTSYS;
-			break;
-		}
-	}
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&vcc->sleep,&wait);
-	if (error <= 0) return error;
-	sock_recv_timestamp(m, vcc->sk, skb);
-	eff_len = skb->len > size ? size : skb->len;
-	if (skb->len > size) /* Not fit ?  Report it... */
-		m->msg_flags |= MSG_TRUNC;
-	if (vcc->dev->ops->feedback)
-		vcc->dev->ops->feedback(vcc,skb,(unsigned long) skb->data,
-		    (unsigned long) buff,eff_len);
-	DPRINTK("RcvM %d -= %d\n", atomic_read(&vcc->sk->sk_rmem_alloc),
-		skb->truesize);
-	atm_return(vcc,skb->truesize);
-	error = copy_to_user(buff,skb->data,eff_len) ? -EFAULT : 0;
-	kfree_skb(skb);
-	return error ? error : eff_len;
+	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
+	    test_bit(ATM_VF_CLOSE,&vcc->flags))
+		return vcc->reply;
+	if (!test_bit(ATM_VF_READY, &vcc->flags))
+		return 0;
+
+	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &error);
+	if (!skb)
+		return error;
+
+	copied = skb->len; 
+	if (copied > size) {
+		copied = size; 
+		msg->msg_flags |= MSG_TRUNC;
+	}
+
+        error = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+        if (error)
+                return error;
+        sock_recv_timestamp(msg, sk, skb);
+        if (vcc->dev->ops->feedback)
+                vcc->dev->ops->feedback(vcc, skb, (unsigned long) skb->data,
+                    (unsigned long) msg->msg_iov->iov_base, copied);
+        DPRINTK("RcvM %d -= %d\n", atomic_read(&vcc->sk->rmem_alloc), skb->truesize);
+        atm_return(vcc, skb->truesize);
+        skb_free_datagram(sk, skb);
+        return copied;
 }
 
 
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Tue Jun 17 08:12:45 2003
+++ b/net/atm/common.h	Tue Jun 17 08:12:45 2003
@@ -13,8 +13,8 @@
 int atm_create(struct socket *sock,int protocol,int family);
 int atm_release(struct socket *sock);
 int atm_connect(struct socket *sock,int itf,short vpi,int vci);
-int atm_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		int total_len, int flags);
+int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
+		int size, int flags);
 int atm_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		int total_len);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Tue Jun 17 08:12:45 2003
+++ b/net/atm/lec.c	Tue Jun 17 08:12:45 2003
@@ -1079,7 +1079,7 @@
 		clear_bit(ATM_VF_READY,&entry->vcc->flags);
                 entry->vcc->push(entry->vcc, NULL);
 #endif
-		atm_async_release_vcc(entry->vcc, -EPIPE);
+		vcc_release_async(entry->vcc, -EPIPE);
                 entry->vcc = NULL;
         }
         if (entry->recv_vcc) {
@@ -1089,7 +1089,7 @@
 		clear_bit(ATM_VF_READY,&entry->recv_vcc->flags);
                 entry->recv_vcc->push(entry->recv_vcc, NULL);
 #endif
-		atm_async_release_vcc(entry->recv_vcc, -EPIPE);
+		vcc_release_async(entry->recv_vcc, -EPIPE);
                 entry->recv_vcc = NULL;
         }        
 }
diff -Nru a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
--- a/net/atm/mpoa_caches.c	Tue Jun 17 08:12:45 2003
+++ b/net/atm/mpoa_caches.c	Tue Jun 17 08:12:46 2003
@@ -212,7 +212,7 @@
 			client->eg_ops->put(eg_entry);
 			return;
 		}
-		atm_async_release_vcc(vcc, -EPIPE);
+		vcc_release_async(vcc, -EPIPE);
 	}
 
 	return;
@@ -447,7 +447,7 @@
 			client->in_ops->put(in_entry);
 			return;
 		}
-		atm_async_release_vcc(vcc, -EPIPE);
+		vcc_release_async(vcc, -EPIPE);
 	}
 
 	return;
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Tue Jun 17 08:12:45 2003
+++ b/net/atm/pvc.c	Tue Jun 17 08:12:45 2003
@@ -88,7 +88,7 @@
 	.setsockopt =	atm_setsockopt,
 	.getsockopt =	atm_getsockopt,
 	.sendmsg =	atm_sendmsg,
-	.recvmsg =	atm_recvmsg,
+	.recvmsg =	vcc_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Tue Jun 17 08:12:46 2003
+++ b/net/atm/signaling.c	Tue Jun 17 08:12:46 2003
@@ -124,6 +124,7 @@
 			clear_bit(ATM_VF_REGIS,&vcc->flags);
 			clear_bit(ATM_VF_READY,&vcc->flags);
 			vcc->reply = msg->reply;
+			vcc->sk->sk_err = -msg->reply;
 			break;
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
@@ -145,6 +146,7 @@
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
 			clear_bit(ATM_VF_READY,&vcc->flags);
 			vcc->reply = msg->reply;
+			vcc->sk->sk_err = -msg->reply;
 			break;
 		case as_modify:
 			modify_qos(vcc,msg);
@@ -202,6 +204,7 @@
 		    !test_bit(ATM_VF_META,&vcc->flags)) {
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
 			vcc->reply = -EUNATCH;
+			vcc->sk->sk_err = EUNATCH;
 			wake_up(&vcc->sleep);
 		}
 		vcc = vcc->next;
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Tue Jun 17 08:12:45 2003
+++ b/net/atm/svc.c	Tue Jun 17 08:12:45 2003
@@ -408,7 +408,7 @@
 	.setsockopt =	svc_setsockopt,
 	.getsockopt =	svc_getsockopt,
 	.sendmsg =	atm_sendmsg,
-	.recvmsg =	atm_recvmsg,
+	.recvmsg =	vcc_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };



[atm]: remove SOCKOPS_WRAPPED; use prepare_to_wait()/finish_wait()

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1400  -> 1.1401 
#	       net/atm/pvc.c	1.10    -> 1.11   
#	       net/atm/svc.c	1.12    -> 1.13   
#	    net/atm/common.h	1.6     -> 1.7    
#	 net/atm/signaling.c	1.10    -> 1.11   
#	    net/atm/common.c	1.29    -> 1.30   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/17	chas@relax.cmf.nrl.navy.mil	1.1401
# remove SOCKOPS_WRAPPED; use prepare_to_wait()
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Tue Jun 17 08:13:05 2003
+++ b/net/atm/common.c	Tue Jun 17 08:13:05 2003
@@ -458,32 +458,53 @@
 }
 
 
-int atm_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		int total_len)
 {
-	DECLARE_WAITQUEUE(wait,current);
+	struct sock *sk = sock->sk;
+	DEFINE_WAIT(wait);
 	struct atm_vcc *vcc;
 	struct sk_buff *skb;
 	int eff,error;
 	const void *buff;
 	int size;
 
-	if (sock->state != SS_CONNECTED) return -ENOTCONN;
-	if (m->msg_name) return -EISCONN;
-	if (m->msg_iovlen != 1) return -ENOSYS; /* fix this later @@@ */
+	lock_sock(sk);
+	if (sock->state != SS_CONNECTED) {
+		error = -ENOTCONN;
+		goto out;
+	}
+	if (m->msg_name) {
+		error = -EISCONN;
+		goto out;
+	}
+	if (m->msg_iovlen != 1) {
+		error = -ENOSYS; /* fix this later @@@ */
+		goto out;
+	}
 	buff = m->msg_iov->iov_base;
 	size = m->msg_iov->iov_len;
 	vcc = ATM_SD(sock);
-	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-	    test_bit(ATM_VF_CLOSE,&vcc->flags))
-		return vcc->reply;
-	if (!test_bit(ATM_VF_READY,&vcc->flags)) return -EPIPE;
-	if (!size) return 0;
-	if (size < 0 || size > vcc->qos.txtp.max_sdu) return -EMSGSIZE;
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
+	    test_bit(ATM_VF_CLOSE, &vcc->flags)) {
+		error = vcc->reply;
+		goto out;
+	}
+	if (!test_bit(ATM_VF_READY, &vcc->flags)) {
+		error = -EPIPE;
+		goto out;
+	}
+	if (!size) {
+		error = 0;
+		goto out;
+	}
+	if (size < 0 || size > vcc->qos.txtp.max_sdu) {
+		error = -EMSGSIZE;
+		goto out;
+	}
 	/* verify_area is done by net/socket.c */
 	eff = (size+3) & ~3; /* align to word boundary */
-	add_wait_queue(&vcc->sleep,&wait);
-	set_current_state(TASK_INTERRUPTIBLE);
+	prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
 	error = 0;
 	while (!(skb = alloc_tx(vcc,eff))) {
 		if (m->msg_flags & MSG_DONTWAIT) {
@@ -491,7 +512,6 @@
 			break;
 		}
 		schedule();
-		set_current_state(TASK_INTERRUPTIBLE);
 		if (signal_pending(current)) {
 			error = -ERESTARTSYS;
 			break;
@@ -505,19 +525,24 @@
 			error = -EPIPE;
 			break;
 		}
+		prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
 	}
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&vcc->sleep,&wait);
-	if (error) return error;
+	finish_wait(&vcc->sleep, &wait);
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
--- a/net/atm/common.h	Tue Jun 17 08:13:05 2003
+++ b/net/atm/common.h	Tue Jun 17 08:13:05 2003
@@ -15,7 +15,7 @@
 int atm_connect(struct socket *sock,int itf,short vpi,int vci);
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		int size, int flags);
-int atm_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		int total_len);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Tue Jun 17 08:13:05 2003
+++ b/net/atm/pvc.c	Tue Jun 17 08:13:05 2003
@@ -31,20 +31,29 @@
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
-	return atm_connect(sock,addr->sap_addr.itf,addr->sap_addr.vpi,
-	    addr->sap_addr.vci);
+	error = atm_connect(sock, addr->sap_addr.itf, addr->sap_addr.vpi,
+			    addr->sap_addr.vci);
+out:
+	release_sock(sk);
+	return error;
 }
 
 
@@ -54,6 +63,31 @@
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
@@ -72,7 +106,7 @@
 }
 
 
-static struct proto_ops SOCKOPS_WRAPPED(pvc_proto_ops) = {
+static struct proto_ops pvc_proto_ops = {
 	.family =	PF_ATMPVC,
 
 	.release =	atm_release,
@@ -85,17 +119,13 @@
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
--- a/net/atm/signaling.c	Tue Jun 17 08:13:05 2003
+++ b/net/atm/signaling.c	Tue Jun 17 08:13:05 2003
@@ -129,10 +129,11 @@
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
 			DPRINTK("as_indicate!!!\n");
+			lock_sock(vcc->sk);
 			if (vcc->sk->sk_ack_backlog ==
 			    vcc->sk->sk_max_ack_backlog) {
 				sigd_enq(0,as_reject,vcc,NULL,NULL);
-				return 0;
+				goto as_indicate_complete;
 			}
 			vcc->sk->sk_ack_backlog++;
 			skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
@@ -141,6 +142,8 @@
 				    &vcc->sleep);
 				vcc->callback(vcc);
 			}
+as_indicate_complete:
+			release_sock(vcc->sk);
 			return 0;
 		case as_close:
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Tue Jun 17 08:13:05 2003
+++ b/net/atm/svc.c	Tue Jun 17 08:13:05 2003
@@ -59,18 +59,18 @@
 
 static void svc_disconnect(struct atm_vcc *vcc)
 {
-	DECLARE_WAITQUEUE(wait,current);
+	DEFINE_WAIT(wait);
 	struct sk_buff *skb;
 
 	DPRINTK("svc_disconnect %p\n",vcc);
 	if (test_bit(ATM_VF_REGIS,&vcc->flags)) {
-		add_wait_queue(&vcc->sleep,&wait);
+		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(vcc,as_close,NULL,NULL,NULL);
 		while (!test_bit(ATM_VF_RELEASED,&vcc->flags) && sigd) {
-			set_current_state(TASK_UNINTERRUPTIBLE);
 			schedule();
+			prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
 		}
-		remove_wait_queue(&vcc->sleep,&wait);
+		finish_wait(&vcc->sleep, &wait);
 	}
 	/* beware - socket is still in use by atmsigd until the last
 	   as_indicate has been answered */
@@ -107,80 +107,138 @@
 static int svc_bind(struct socket *sock,struct sockaddr *sockaddr,
     int sockaddr_len)
 {
-	DECLARE_WAITQUEUE(wait,current);
+	DEFINE_WAIT(wait);
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
-	add_wait_queue(&vcc->sleep,&wait);
+	prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_bind,NULL,NULL,&vcc->local);
 	while (vcc->reply == WAITING && sigd) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule();
+		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
-	remove_wait_queue(&vcc->sleep,&wait);
+	finish_wait(&vcc->sleep, &wait);
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
 
 
 static int svc_connect(struct socket *sock,struct sockaddr *sockaddr,
     int sockaddr_len,int flags)
 {
-	DECLARE_WAITQUEUE(wait,current);
+	DEFINE_WAIT(wait);
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
-		add_wait_queue(&vcc->sleep,&wait);
+		prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
 		sigd_enq(vcc,as_connect,NULL,NULL,&vcc->remote);
 		if (flags & O_NONBLOCK) {
-			remove_wait_queue(&vcc->sleep,&wait);
+			finish_wait(&vcc->sleep, &wait);
 			sock->state = SS_CONNECTING;
-			return -EINPROGRESS;
+			error = -EINPROGRESS;
+			goto out;
 		}
 		error = 0;
 		while (vcc->reply == WAITING && sigd) {
-			set_current_state(TASK_INTERRUPTIBLE);
 			schedule();
-			if (!signal_pending(current)) continue;
+			if (!signal_pending(current)) {
+				prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+				continue;
+			}
 			DPRINTK("*ABORT*\n");
 			/*
 			 * This is tricky:
@@ -196,13 +254,13 @@
 			 */
 			sigd_enq(vcc,as_close,NULL,NULL,NULL);
 			while (vcc->reply == WAITING && sigd) {
-				set_current_state(TASK_UNINTERRUPTIBLE);
+				prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
 				schedule();
 			}
 			if (!vcc->reply)
 				while (!test_bit(ATM_VF_RELEASED,&vcc->flags)
 				    && sigd) {
-					set_current_state(TASK_UNINTERRUPTIBLE);
+					prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
 					schedule();
 				}
 			clear_bit(ATM_VF_REGIS,&vcc->flags);
@@ -212,10 +270,17 @@
 			error = -EINTR;
 			break;
 		}
-		remove_wait_queue(&vcc->sleep,&wait);
-		if (error) return error;
-		if (!sigd) return -EUNATCH;
-		if (vcc->reply) return vcc->reply;
+		finish_wait(&vcc->sleep, &wait);
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
@@ -231,53 +296,70 @@
 	if (!(error = atm_connect(sock,vcc->itf,vcc->vpi,vcc->vci)))
 		sock->state = SS_CONNECTED;
 	else (void) svc_disconnect(vcc);
+out:
+	release_sock(sk);
 	return error;
 }
 
 
 static int svc_listen(struct socket *sock,int backlog)
 {
-	DECLARE_WAITQUEUE(wait,current);
+	DEFINE_WAIT(wait);
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
-	add_wait_queue(&vcc->sleep,&wait);
+	prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_listen,NULL,NULL,&vcc->local);
 	while (vcc->reply == WAITING && sigd) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule();
+		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+	}
+	finish_wait(&vcc->sleep, &wait);
+	if (!sigd) {
+		error = -EUNATCH;
+		goto out;
 	}
-	remove_wait_queue(&vcc->sleep,&wait);
-	if (!sigd) return -EUNATCH;
 	set_bit(ATM_VF_LISTEN,&vcc->flags);
 	vcc->sk->sk_max_ack_backlog = backlog > 0 ? backlog :
 						    ATM_BACKLOG_DEFAULT;
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
 
 	DPRINTK("svc_accept %p -> %p\n",old_vcc,new_vcc);
 	while (1) {
-		DECLARE_WAITQUEUE(wait,current);
+		DEFINE_WAIT(wait);
 
-		add_wait_queue(&old_vcc->sleep,&wait);
+		prepare_to_wait(&old_vcc->sleep, &wait, TASK_INTERRUPTIBLE);
 		while (!(skb = skb_dequeue(&old_vcc->sk->sk_receive_queue)) &&
 		       sigd) {
 			if (test_bit(ATM_VF_RELEASED,&old_vcc->flags)) break;
@@ -289,16 +371,22 @@
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
+			prepare_to_wait(&old_vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+		}
+		finish_wait(&old_vcc->sleep, &wait);
+		if (error)
+			goto out;
+		if (!skb) {
+			error = -EUNATCH;
+			goto out;
 		}
-		remove_wait_queue(&old_vcc->sleep,&wait);
-		if (error) return error;
-		if (!skb) return -EUNATCH;
 		msg = (struct atmsvc_msg *) skb->data;
 		new_vcc->qos = msg->qos;
 		set_bit(ATM_VF_HASQOS,&new_vcc->flags);
@@ -312,23 +400,34 @@
 		if (error) {
 			sigd_enq2(NULL,as_reject,old_vcc,NULL,NULL,
 			    &old_vcc->qos,error);
-			return error == -EAGAIN ? -EBUSY : error;
+			error = error == -EAGAIN ? -EBUSY : error;
+			goto out;
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
 		new_vcc->reply = WAITING;
-		add_wait_queue(&new_vcc->sleep,&wait);
+		prepare_to_wait(&new_vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(new_vcc,as_accept,old_vcc,NULL,NULL);
 		while (new_vcc->reply == WAITING && sigd) {
-			set_current_state(TASK_UNINTERRUPTIBLE);
+			release_sock(sk);
 			schedule();
+			lock_sock(sk);
+			prepare_to_wait(&new_vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		}
+		finish_wait(&new_vcc->sleep, &wait);
+		if (!sigd) {
+			error = -EUNATCH;
+			goto out;
 		}
-		remove_wait_queue(&new_vcc->sleep,&wait);
-		if (!sigd) return -EUNATCH;
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
 
 
@@ -347,17 +446,17 @@
 
 int svc_change_qos(struct atm_vcc *vcc,struct atm_qos *qos)
 {
-	DECLARE_WAITQUEUE(wait,current);
+	DEFINE_WAIT(wait);
 
 	vcc->reply = WAITING;
-	add_wait_queue(&vcc->sleep,&wait);
+	prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq2(vcc,as_modify,NULL,NULL,&vcc->local,qos,0);
 	while (vcc->reply == WAITING && !test_bit(ATM_VF_RELEASED,&vcc->flags)
 	    && sigd) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule();
+		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
-	remove_wait_queue(&vcc->sleep,&wait);
+	finish_wait(&vcc->sleep, &wait);
 	if (!sigd) return -EUNATCH;
 	return vcc->reply;
 }
@@ -366,33 +465,57 @@
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
@@ -407,15 +530,12 @@
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




[atm]: getsockopt/setsockopt cleanup

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1401  -> 1.1402 
#	       net/atm/pvc.c	1.11    -> 1.12   
#	       net/atm/svc.c	1.13    -> 1.14   
#	    net/atm/common.h	1.7     -> 1.8    
#	    net/atm/common.c	1.30    -> 1.31   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/17	chas@relax.cmf.nrl.navy.mil	1.1402
# setsockopt/getsockopt cleanup
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Tue Jun 17 08:20:17 2003
+++ b/net/atm/common.c	Tue Jun 17 08:20:17 2003
@@ -890,14 +890,16 @@
 	return check_tp(&qos->rxtp);
 }
 
-
-static int atm_do_setsockopt(struct socket *sock,int level,int optname,
-    void *optval,int optlen)
+int vcc_setsockopt(struct socket *sock, int level, int optname,
+		   char *optval, int optlen)
 {
 	struct atm_vcc *vcc;
 	unsigned long value;
 	int error;
 
+	if (__SO_LEVEL_MATCH(optname, level) && optlen != __SO_SIZE(optname))
+		return -EINVAL;
+
 	vcc = ATM_SD(sock);
 	switch (optname) {
 		case SO_ATMQOS:
@@ -931,10 +933,16 @@
 }
 
 
-static int atm_do_getsockopt(struct socket *sock,int level,int optname,
-    void *optval,int optlen)
+int vcc_getsockopt(struct socket *sock, int level, int optname,
+		   char *optval, int *optlen)
 {
 	struct atm_vcc *vcc;
+	int len;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+	if (__SO_LEVEL_MATCH(optname, level) && len != __SO_SIZE(optname))
+		return -EINVAL;
 
 	vcc = ATM_SD(sock);
 	switch (optname) {
@@ -965,28 +973,7 @@
 			break;
 	}
 	if (!vcc->dev || !vcc->dev->ops->getsockopt) return -EINVAL;
-	return vcc->dev->ops->getsockopt(vcc,level,optname,optval,optlen);
-}
-
-
-int atm_setsockopt(struct socket *sock,int level,int optname,char *optval,
-    int optlen)
-{
-	if (__SO_LEVEL_MATCH(optname, level) && optlen != __SO_SIZE(optname))
-		return -EINVAL;
-	return atm_do_setsockopt(sock,level,optname,optval,optlen);
-}
-
-
-int atm_getsockopt(struct socket *sock,int level,int optname,
-    char *optval,int *optlen)
-{
-	int len;
-
-	if (get_user(len,optlen)) return -EFAULT;
-	if (__SO_LEVEL_MATCH(optname, level) && len != __SO_SIZE(optname))
-		return -EINVAL;
-	return atm_do_getsockopt(sock,level,optname,optval,len);
+	return vcc->dev->ops->getsockopt(vcc, level, optname, optval, len);
 }
 
 
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Tue Jun 17 08:20:17 2003
+++ b/net/atm/common.h	Tue Jun 17 08:20:17 2003
@@ -19,10 +19,10 @@
 		int total_len);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
-int atm_setsockopt(struct socket *sock,int level,int optname,char *optval,
-    int optlen);
-int atm_getsockopt(struct socket *sock,int level,int optname,char *optval,
-    int *optlen);
+int vcc_setsockopt(struct socket *sock, int level, int optname, char *optval,
+		   int optlen);
+int vcc_getsockopt(struct socket *sock, int level, int optname, char *optval,
+		   int *optlen);
 
 int atm_connect_vcc(struct atm_vcc *vcc,int itf,short vpi,int vci);
 void atm_release_vcc_sk(struct sock *sk,int free_sk);
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Tue Jun 17 08:20:16 2003
+++ b/net/atm/pvc.c	Tue Jun 17 08:20:16 2003
@@ -70,7 +70,7 @@
 	int error;
 
 	lock_sock(sk);
-	error = atm_setsockopt(sock, level, optname, optval, optlen);
+	error = vcc_setsockopt(sock, level, optname, optval, optlen);
 	release_sock(sk);
 	return error;
 }
@@ -83,7 +83,7 @@
 	int error;
 
 	lock_sock(sk);
-	error = atm_getsockopt(sock, level, optname, optval, optlen);
+	error = vcc_getsockopt(sock, level, optname, optval, optlen);
 	release_sock(sk);
 	return error;
 }
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Tue Jun 17 08:20:17 2003
+++ b/net/atm/svc.c	Tue Jun 17 08:20:17 2003
@@ -471,7 +471,7 @@
 
 	if (!__SO_LEVEL_MATCH(optname, level) || optname != SO_ATMSAP ||
 	    optlen != sizeof(struct atm_sap)) {
-		error = atm_setsockopt(sock, level, optname, optval, optlen);
+		error = vcc_setsockopt(sock, level, optname, optval, optlen);
 		goto out;
 	}
 	vcc = ATM_SD(sock);
@@ -494,7 +494,7 @@
 
 	lock_sock(sk);
 	if (!__SO_LEVEL_MATCH(optname, level) || optname != SO_ATMSAP) {
-		error = atm_getsockopt(sock, level, optname, optval, optlen);
+		error = vcc_getsockopt(sock, level, optname, optval, optlen);
 		goto out;
 	}
 	if (get_user(len, optlen)) {




[atm]: connect cleanup

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1402  -> 1.1403 
#	       net/atm/pvc.c	1.12    -> 1.13   
#	       net/atm/svc.c	1.14    -> 1.15   
#	    net/atm/common.h	1.8     -> 1.9    
#	    net/atm/common.c	1.31    -> 1.32   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/17	chas@relax.cmf.nrl.navy.mil	1.1403
# connect cleanup
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Tue Jun 17 08:20:36 2003
+++ b/net/atm/common.c	Tue Jun 17 08:20:36 2003
@@ -277,8 +277,8 @@
 }
 
 
-static int atm_do_connect_dev(struct atm_vcc *vcc,struct atm_dev *dev,int vpi,
-    int vci)
+static int __vcc_connect(struct atm_vcc *vcc, struct atm_dev *dev, int vpi,
+			 int vci)
 {
 	int error;
 
@@ -335,29 +335,26 @@
 }
 
 
-static int atm_do_connect(struct atm_vcc *vcc,int itf,int vpi,int vci)
+int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 {
 	struct atm_dev *dev;
-	int return_val;
-
-	dev = atm_dev_lookup(itf);
-	if (!dev)
-		return_val =  -ENODEV;
-	else {
-		return_val = atm_do_connect_dev(vcc,dev,vpi,vci);
-		if (return_val) atm_dev_release(dev);
-	}
-
-	return return_val;
-}
+	struct atm_vcc *vcc = ATM_SD(sock);
+	int error;
 
+	DPRINTK("vcc_connect (vpi %d, vci %d)\n",vpi,vci);
+	if (sock->state == SS_CONNECTED)
+		return -EISCONN;
+	if (sock->state != SS_UNCONNECTED)
+		return -EINVAL;
+	if (!(vpi || vci))
+		return -EINVAL;
 
-int atm_connect_vcc(struct atm_vcc *vcc,int itf,short vpi,int vci)
-{
 	if (vpi != ATM_VPI_UNSPEC && vci != ATM_VCI_UNSPEC)
 		clear_bit(ATM_VF_PARTIAL,&vcc->flags);
-	else if (test_bit(ATM_VF_PARTIAL,&vcc->flags)) return -EINVAL;
-	DPRINTK("atm_connect (TX: cl %d,bw %d-%d,sdu %d; "
+	else
+		if (test_bit(ATM_VF_PARTIAL,&vcc->flags))
+			return -EINVAL;
+	DPRINTK("vcc_connect (TX: cl %d,bw %d-%d,sdu %d; "
 	    "RX: cl %d,bw %d-%d,sdu %d,AAL %s%d)\n",
 	    vcc->qos.txtp.traffic_class,vcc->qos.txtp.min_pcr,
 	    vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu,
@@ -365,50 +362,39 @@
 	    vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu,
 	    vcc->qos.aal == ATM_AAL5 ? "" : vcc->qos.aal == ATM_AAL0 ? "" :
 	    " ??? code ",vcc->qos.aal == ATM_AAL0 ? 0 : vcc->qos.aal);
-	if (!test_bit(ATM_VF_HASQOS,&vcc->flags)) return -EBADFD;
+	if (!test_bit(ATM_VF_HASQOS, &vcc->flags))
+		return -EBADFD;
 	if (vcc->qos.txtp.traffic_class == ATM_ANYCLASS ||
 	    vcc->qos.rxtp.traffic_class == ATM_ANYCLASS)
 		return -EINVAL;
 	if (itf != ATM_ITF_ANY) {
-		int error;
-
-		error = atm_do_connect(vcc,itf,vpi,vci);
-		if (error) return error;
-	}
-	else {
-		struct atm_dev *dev = NULL;
+		dev = atm_dev_lookup(itf);
+		error = __vcc_connect(vcc, dev, vpi, vci);
+		if (error) {
+			atm_dev_release(dev);
+			return error;
+		}
+	} else {
 		struct list_head *p, *next;
 
+		dev = NULL;
 		spin_lock(&atm_dev_lock);
 		list_for_each_safe(p, next, &atm_devs) {
 			dev = list_entry(p, struct atm_dev, dev_list);
 			atm_dev_hold(dev);
 			spin_unlock(&atm_dev_lock);
-			if (!atm_do_connect_dev(vcc,dev,vpi,vci))
+			if (!__vcc_connect(vcc, dev, vpi, vci))
 				break;
 			atm_dev_release(dev);
 			dev = NULL;
 			spin_lock(&atm_dev_lock);
 		}
 		spin_unlock(&atm_dev_lock);
-		if (!dev) return -ENODEV;
+		if (!dev)
+			return -ENODEV;
 	}
 	if (vpi == ATM_VPI_UNSPEC || vci == ATM_VCI_UNSPEC)
 		set_bit(ATM_VF_PARTIAL,&vcc->flags);
-	return 0;
-}
-
-
-int atm_connect(struct socket *sock,int itf,short vpi,int vci)
-{
-	int error;
-
-	DPRINTK("atm_connect (vpi %d, vci %d)\n",vpi,vci);
-	if (sock->state == SS_CONNECTED) return -EISCONN;
-	if (sock->state != SS_UNCONNECTED) return -EINVAL;
-	if (!(vpi || vci)) return -EINVAL;
-	error = atm_connect_vcc(ATM_SD(sock),itf,vpi,vci);
-	if (error) return error;
 	if (test_bit(ATM_VF_READY,&ATM_SD(sock)->flags))
 		sock->state = SS_CONNECTED;
 	return 0;
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Tue Jun 17 08:20:36 2003
+++ b/net/atm/common.h	Tue Jun 17 08:20:36 2003
@@ -12,7 +12,7 @@
 
 int atm_create(struct socket *sock,int protocol,int family);
 int atm_release(struct socket *sock);
-int atm_connect(struct socket *sock,int itf,short vpi,int vci);
+int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		int size, int flags);
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
@@ -24,7 +24,6 @@
 int vcc_getsockopt(struct socket *sock, int level, int optname, char *optval,
 		   int *optlen);
 
-int atm_connect_vcc(struct atm_vcc *vcc,int itf,short vpi,int vci);
 void atm_release_vcc_sk(struct sock *sk,int free_sk);
 void atm_shutdown_dev(struct atm_dev *dev);
 
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Tue Jun 17 08:20:36 2003
+++ b/net/atm/pvc.c	Tue Jun 17 08:20:36 2003
@@ -49,7 +49,7 @@
 		if (vcc->vpi != ATM_VPI_UNSPEC) addr->sap_addr.vpi = vcc->vpi;
 		if (vcc->vci != ATM_VCI_UNSPEC) addr->sap_addr.vci = vcc->vci;
 	}
-	error = atm_connect(sock, addr->sap_addr.itf, addr->sap_addr.vpi,
+	error = vcc_connect(sock, addr->sap_addr.itf, addr->sap_addr.vpi,
 			    addr->sap_addr.vci);
 out:
 	release_sock(sk);
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Tue Jun 17 08:20:36 2003
+++ b/net/atm/svc.c	Tue Jun 17 08:20:36 2003
@@ -293,7 +293,7 @@
 /*
  * #endif
  */
-	if (!(error = atm_connect(sock,vcc->itf,vcc->vpi,vcc->vci)))
+	if (!(error = vcc_connect(sock, vcc->itf, vcc->vpi, vcc->vci)))
 		sock->state = SS_CONNECTED;
 	else (void) svc_disconnect(vcc);
 out:
@@ -393,8 +393,8 @@
 		new_vcc->remote = msg->svc;
 		new_vcc->local = msg->local;
 		new_vcc->sap = msg->sap;
-		error = atm_connect(newsock,msg->pvc.sap_addr.itf,
-		    msg->pvc.sap_addr.vpi,msg->pvc.sap_addr.vci);
+		error = vcc_connect(newsock, msg->pvc.sap_addr.itf,
+				    msg->pvc.sap_addr.vpi, msg->pvc.sap_addr.vci);
 		dev_kfree_skb(skb);
 		old_vcc->sk->sk_ack_backlog--;
 		if (error) {
