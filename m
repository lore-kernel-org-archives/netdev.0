From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: rewrite recvmsg to use skb_copy_datagram_iovec
Date: Mon, 13 Oct 2003 23:43:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310140343.h9E3hAkT005566@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1136  -> 1.1137 
#	net/atm/mpoa_caches.c	1.1     -> 1.2    
#	include/linux/atmdev.h	1.9     -> 1.10   
#	       net/atm/pvc.c	1.5     -> 1.6    
#	      net/atm/clip.c	1.10    -> 1.11   
#	       net/atm/lec.c	1.18    -> 1.19   
#	       net/atm/svc.c	1.5     -> 1.6    
#	    net/atm/common.h	1.5     -> 1.6    
#	 net/atm/signaling.c	1.5     -> 1.6    
#	    net/atm/common.c	1.21    -> 1.22   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/29	chas@relax.cmf.nrl.navy.mil	1.1137
# [ATM]: rewrite recvmsg to use skb_copy_datagram_iovec
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Mon Oct 13 18:41:06 2003
+++ b/include/linux/atmdev.h	Mon Oct 13 18:41:06 2003
@@ -461,7 +461,7 @@
 int atm_find_ci(struct atm_vcc *vcc,short *vpi,int *vci);
 int atm_pcr_goal(struct atm_trafprm *tp);
 
-void atm_async_release_vcc(struct atm_vcc *vcc,int reply);
+void vcc_release_async(struct atm_vcc *vcc, int reply);
 
 #endif /* __KERNEL__ */
 
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Mon Oct 13 18:41:06 2003
+++ b/net/atm/clip.c	Mon Oct 13 18:41:06 2003
@@ -144,8 +144,8 @@
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
--- a/net/atm/common.c	Mon Oct 13 18:41:06 2003
+++ b/net/atm/common.c	Mon Oct 13 18:41:06 2003
@@ -261,15 +261,16 @@
 }
 
 
-void atm_async_release_vcc(struct atm_vcc *vcc,int reply)
+void vcc_release_async(struct atm_vcc *vcc, int reply)
 {
-	set_bit(ATM_VF_CLOSE,&vcc->flags);
+	set_bit(ATM_VF_CLOSE, &vcc->flags);
 	vcc->reply = reply;
+	vcc->sk->err = -reply;
 	wake_up(&vcc->sleep);
 }
 
 
-EXPORT_SYMBOL(atm_async_release_vcc);
+EXPORT_SYMBOL(vcc_release_async);
 
 
 static int adjust_tp(struct atm_trafprm *tp,unsigned char aal)
@@ -437,63 +438,49 @@
 }
 
 
-int atm_recvmsg(struct socket *sock,struct msghdr *m,int total_len,
-    int flags,struct scm_cookie *scm)
+int vcc_recvmsg(struct socket *sock, struct msghdr *msg,
+		int size, int flags, struct scm_cookie *scm)
 {
-	DECLARE_WAITQUEUE(wait,current);
-	struct atm_vcc *vcc;
-	struct sk_buff *skb;
-	int eff_len,error;
-	void *buff;
-	int size;
-
-	if (sock->state != SS_CONNECTED) return -ENOTCONN;
-	if (flags & ~MSG_DONTWAIT) return -EOPNOTSUPP;
-	if (m->msg_iovlen != 1) return -ENOSYS; /* fix this later @@@ */
-	buff = m->msg_iov->iov_base;
-	size = m->msg_iov->iov_len;
-	vcc = ATM_SD(sock);
-	add_wait_queue(&vcc->sleep,&wait);
-	set_current_state(TASK_INTERRUPTIBLE);
-	error = 1; /* <= 0 is error */
-	while (!(skb = skb_dequeue(&vcc->sk->receive_queue))) {
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
+ 	struct sock *sk = sock->sk;
+  	struct atm_vcc *vcc;
+  	struct sk_buff *skb;
+ 	int copied, error = -EINVAL;
+ 
+ 	if (sock->state != SS_CONNECTED)
+ 		return -ENOTCONN;
+ 	if (flags & ~MSG_DONTWAIT)		/* only handle MSG_DONTWAIT */
+ 		return -EOPNOTSUPP;
+  	vcc = ATM_SD(sock);
+ 	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
+ 	    test_bit(ATM_VF_CLOSE,&vcc->flags))
+ 		return vcc->reply;
+ 	if (!test_bit(ATM_VF_READY, &vcc->flags))
+ 		return 0;
+ 
+ 	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &error);
+ 	if (!skb)
+ 		return error;
+ 
+ 	copied = skb->len; 
+ 	if (copied > size) {
+ 		copied = size; 
+ 		msg->msg_flags |= MSG_TRUNC;
+ 	}
+ 
+	error = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (error)
+		 return error;
+	sock_recv_timestamp(msg, sk, skb);
 	if (vcc->dev->ops->feedback)
-		vcc->dev->ops->feedback(vcc,skb,(unsigned long) skb->data,
-		    (unsigned long) buff,eff_len);
-	DPRINTK("RcvM %d -= %d\n",atomic_read(&vcc->sk->rmem_alloc),skb->truesize);
-	atm_return(vcc,skb->truesize);
-	error = copy_to_user(buff,skb->data,eff_len) ? -EFAULT : 0;
-	kfree_skb(skb);
-	return error ? error : eff_len;
+		vcc->dev->ops->feedback(vcc, skb, (unsigned long) skb->data,
+					(unsigned long) msg->msg_iov->iov_base, copied);
+	DPRINTK("RcvM %d -= %d\n", atomic_read(&vcc->sk->rmem_alloc), skb->truesize);
+	atm_return(vcc, skb->truesize);
+	skb_free_datagram(sk, skb);
+	return copied;
 }
-
+  
+  
 
 int atm_sendmsg(struct socket *sock,struct msghdr *m,int total_len,
     struct scm_cookie *scm)
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Oct 13 18:41:06 2003
+++ b/net/atm/common.h	Mon Oct 13 18:41:06 2003
@@ -13,8 +13,8 @@
 int atm_create(struct socket *sock,int protocol,int family);
 int atm_release(struct socket *sock);
 int atm_connect(struct socket *sock,int itf,short vpi,int vci);
-int atm_recvmsg(struct socket *sock,struct msghdr *m,int total_len,
-    int flags,struct scm_cookie *scm);
+int vcc_recvmsg(struct socket *sock, struct msghdr *msg,
+		int size, int flags, struct scm_cookie *scm);
 int atm_sendmsg(struct socket *sock,struct msghdr *m,int total_len,
   struct scm_cookie *scm);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Mon Oct 13 18:41:06 2003
+++ b/net/atm/lec.c	Mon Oct 13 18:41:06 2003
@@ -1092,7 +1092,7 @@
 		clear_bit(ATM_VF_READY,&entry->vcc->flags);
                 entry->vcc->push(entry->vcc, NULL);
 #endif
-		atm_async_release_vcc(entry->vcc, -EPIPE);
+		vcc_release_async(entry->vcc, -EPIPE);
                 entry->vcc = NULL;
         }
         if (entry->recv_vcc) {
@@ -1102,7 +1102,7 @@
 		clear_bit(ATM_VF_READY,&entry->recv_vcc->flags);
                 entry->recv_vcc->push(entry->recv_vcc, NULL);
 #endif
-		atm_async_release_vcc(entry->recv_vcc, -EPIPE);
+		vcc_release_async(entry->recv_vcc, -EPIPE);
                 entry->recv_vcc = NULL;
         }        
 }
diff -Nru a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
--- a/net/atm/mpoa_caches.c	Mon Oct 13 18:41:06 2003
+++ b/net/atm/mpoa_caches.c	Mon Oct 13 18:41:06 2003
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
--- a/net/atm/pvc.c	Mon Oct 13 18:41:06 2003
+++ b/net/atm/pvc.c	Mon Oct 13 18:41:06 2003
@@ -89,7 +89,7 @@
 	.setsockopt =	atm_setsockopt,
 	.getsockopt =	atm_getsockopt,
 	.sendmsg =	atm_sendmsg,
-	.recvmsg =	atm_recvmsg,
+	.recvmsg =	vcc_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Oct 13 18:41:06 2003
+++ b/net/atm/signaling.c	Mon Oct 13 18:41:06 2003
@@ -124,6 +124,7 @@
 			clear_bit(ATM_VF_REGIS,&vcc->flags);
 			clear_bit(ATM_VF_READY,&vcc->flags);
 			vcc->reply = msg->reply;
+			vcc->sk->err = -msg->reply;
 			break;
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
@@ -144,6 +145,7 @@
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
 			clear_bit(ATM_VF_READY,&vcc->flags);
 			vcc->reply = msg->reply;
+			vcc->sk->err = -msg->reply;
 			break;
 		case as_modify:
 			modify_qos(vcc,msg);
@@ -201,6 +203,7 @@
 		    !test_bit(ATM_VF_META,&vcc->flags)) {
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
 			vcc->reply = -EUNATCH;
+			vcc->sk->err = EUNATCH;
 			wake_up(&vcc->sleep);
 		}
 		vcc = vcc->next;
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Oct 13 18:41:06 2003
+++ b/net/atm/svc.c	Mon Oct 13 18:41:06 2003
@@ -407,7 +407,7 @@
 	.setsockopt =	svc_setsockopt,
 	.getsockopt =	svc_getsockopt,
 	.sendmsg =	atm_sendmsg,
-	.recvmsg =	atm_recvmsg,
+	.recvmsg =	vcc_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
