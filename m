From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [rfc] sk_write_space() for atm
Date: Tue, 24 Jun 2003 20:30:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306250032.h5P0WJsG010081@ginger.cmf.nrl.navy.mil>
References: <20030624.163517.15237390.davem@redhat.com>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Tue, 24 Jun 2003 16:35:17 PDT."
             <20030624.163517.15237390.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030624.163517.15237390.davem@redhat.com>,"David S. Miller" writes:
>You can achieve what you want with 'reply' via:
>	reply = vcc->reply;
>	barrier();

ah.

>This doesn't guarentee anything, if you want to test multiple
>pieces of state and make a decision based upon a snapshot of
>them you must do some more serious locking (such as lock_sock())
>in the poll function.

yeah, i figured the next step up was lock but i would rather
just avoid that.  the confusion seems to be that vcc->reply is
used to hold the socket return code and indicate the waiting
state.  since this isnt compat with sk->sk_err (the likely
replacment for vcc->reply) i just went ahead and made a 
flag bit ATM_VF_WAITING and changed vcc->reply to sk->sk_err.
its not quite complete, a couple places (recvmsg/sendmsg)
should just return EPIPE instead of sk_err and the occurances
of error = -sk->sk_err should be error = sock_errno(sk) 
(or so i think).  comments?

===== drivers/atm/atmtcp.c 1.12 vs edited =====
--- 1.12/drivers/atm/atmtcp.c	Mon Jun 23 10:45:54 2003
+++ edited/drivers/atm/atmtcp.c	Tue Jun 24 15:01:21 2003
@@ -90,7 +90,7 @@
 	vcc->vpi = msg->addr.sap_addr.vpi;
 	vcc->vci = msg->addr.sap_addr.vci;
 	vcc->qos = msg->qos;
-	vcc->reply = msg->result;
+	vcc->sk->sk_err = -msg->result;
 	switch (msg->type) {
 	    case ATMTCP_CTRL_OPEN:
 		change_bit(ATM_VF_READY,&vcc->flags);
@@ -134,7 +134,7 @@
 	clear_bit(ATM_VF_READY,&vcc->flags); /* just in case ... */
 	error = atmtcp_send_control(vcc,ATMTCP_CTRL_OPEN,&msg,ATM_VF_READY);
 	if (error) return error;
-	return vcc->reply;
+	return -vcc->sk->sk_err;
 }
 
 
===== include/linux/atmdev.h 1.21 vs edited =====
--- 1.21/include/linux/atmdev.h	Mon Jun 23 10:45:54 2003
+++ edited/include/linux/atmdev.h	Tue Jun 24 20:25:39 2003
@@ -252,6 +252,7 @@
 	ATM_VF_SESSION,		/* VCC is p2mp session control descriptor */
 	ATM_VF_HASSAP,		/* SAP has been set */
 	ATM_VF_CLOSE,		/* asynchronous close - treat like VF_RELEASED*/
+	ATM_VF_WAITING,		/* waiting for reply from sigd */
 };
 
 
@@ -296,7 +297,6 @@
 	short		itf;		/* interface number */
 	struct sockaddr_atmsvc local;
 	struct sockaddr_atmsvc remote;
-	int		reply;		/* also used by ATMTCP */
 	/* Multipoint part ------------------------------------------------- */
 	struct atm_vcc	*session;	/* session VCC descriptor */
 	/* Other stuff ----------------------------------------------------- */
===== net/atm/common.c 1.41 vs edited =====
--- 1.41/net/atm/common.c	Mon Jun 23 10:57:01 2003
+++ edited/net/atm/common.c	Tue Jun 24 20:25:39 2003
@@ -243,6 +243,29 @@
 		wake_up(sk->sk_sleep);
 	read_unlock(&sk->sk_callback_lock);
 }
+
+static inline int vcc_writable(struct sock *sk)
+{
+	struct atm_vcc *vcc = atm_sk(sk);
+
+	return (vcc->qos.txtp.max_sdu +
+	        atomic_read(&sk->sk_wmem_alloc)) <= sk->sk_sndbuf;
+}
+
+static void vcc_write_space(struct sock *sk)
+{       
+	read_lock(&sk->sk_callback_lock);
+
+	if (vcc_writable(sk)) {
+		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+			wake_up_interruptible(sk->sk_sleep);
+
+		sk_wake_async(sk, 2, POLL_OUT);
+	}
+
+	read_unlock(&sk->sk_callback_lock);
+}
+
  
 int vcc_create(struct socket *sock, int protocol, int family)
 {
@@ -257,6 +280,7 @@
 		return -ENOMEM;
 	sock_init_data(sock, sk);
 	sk->sk_state_change = vcc_def_wakeup;
+	sk->sk_write_space = vcc_write_space;
 
 	vcc = atm_sk(sk) = kmalloc(sizeof(*vcc), GFP_KERNEL);
 	if (!vcc) {
@@ -326,8 +350,8 @@
 void vcc_release_async(struct atm_vcc *vcc, int reply)
 {
 	set_bit(ATM_VF_CLOSE, &vcc->flags);
-	vcc->reply = reply;
 	vcc->sk->sk_err = -reply;
+	clear_bit(ATM_VF_WAITING, &vcc->flags);
 	vcc->sk->sk_state_change(vcc->sk);
 }
 
@@ -501,7 +525,7 @@
 	vcc = ATM_SD(sock);
 	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
 	    test_bit(ATM_VF_CLOSE,&vcc->flags))
-		return vcc->reply;
+		return -sk->sk_err;
 	if (!test_bit(ATM_VF_READY, &vcc->flags))
 		return 0;
 
@@ -558,7 +582,7 @@
 	vcc = ATM_SD(sock);
 	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
 	    test_bit(ATM_VF_CLOSE, &vcc->flags)) {
-		error = vcc->reply;
+		error = -sk->sk_err;
 		goto out;
 	}
 	if (!test_bit(ATM_VF_READY, &vcc->flags)) {
@@ -589,7 +613,7 @@
 		}
 		if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
 		    test_bit(ATM_VF_CLOSE,&vcc->flags)) {
-			error = vcc->reply;
+			error = -sk->sk_err;
 			break;
 		}
 		if (!test_bit(ATM_VF_READY,&vcc->flags)) {
@@ -617,29 +641,38 @@
 }
 
 
-unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait)
+unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
 	unsigned int mask;
 
-	vcc = ATM_SD(sock);
-	poll_wait(file, vcc->sk->sk_sleep, wait);
+	poll_wait(file, sk->sk_sleep, wait);
 	mask = 0;
-	if (skb_peek(&vcc->sk->sk_receive_queue))
-		mask |= POLLIN | POLLRDNORM;
-	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-	    test_bit(ATM_VF_CLOSE,&vcc->flags))
+
+	vcc = ATM_SD(sock);
+
+	/* exceptional events */
+	if (sk->sk_err)
+		mask = POLLERR;
+
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
+	    test_bit(ATM_VF_CLOSE, &vcc->flags))
 		mask |= POLLHUP;
-	if (sock->state != SS_CONNECTING) {
-		if (vcc->qos.txtp.traffic_class != ATM_NONE &&
-		    vcc->qos.txtp.max_sdu +
-		    atomic_read(&vcc->sk->sk_wmem_alloc) <= vcc->sk->sk_sndbuf)
-			mask |= POLLOUT | POLLWRNORM;
-	}
-	else if (vcc->reply != WAITING) {
-			mask |= POLLOUT | POLLWRNORM;
-			if (vcc->reply) mask |= POLLERR;
-		}
+
+	/* readable? */
+	if (!skb_queue_empty(&sk->sk_receive_queue))
+		mask |= POLLIN | POLLRDNORM;
+
+	/* writable? */
+	if (sock->state == SS_CONNECTING &&
+	    test_bit(ATM_VF_WAITING, &vcc->flags))
+		return mask;
+
+	if (vcc->qos.txtp.traffic_class != ATM_NONE &&
+	    vcc_writable(vcc->sk))
+		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+
 	return mask;
 }
 
===== net/atm/common.h 1.15 vs edited =====
--- 1.15/net/atm/common.h	Mon Jun 23 10:51:10 2003
+++ edited/net/atm/common.h	Tue Jun 24 20:25:03 2003
@@ -17,7 +17,7 @@
 		int size, int flags);
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		int total_len);
-unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
+unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int vcc_setsockopt(struct socket *sock, int level, int optname, char *optval,
 		   int optlen);
===== net/atm/proc.c 1.21 vs edited =====
--- 1.21/net/atm/proc.c	Fri Jun 20 17:33:01 2003
+++ edited/net/atm/proc.c	Tue Jun 24 20:25:41 2003
@@ -224,7 +224,7 @@
 			here += sprintf(here, "%3d", vcc->sk->sk_family);
 	}
 	here += sprintf(here," %04lx  %5d %7d/%7d %7d/%7d\n",vcc->flags,
-	    vcc->reply,
+	    vcc->sk->sk_err,
 	    atomic_read(&vcc->sk->sk_wmem_alloc), vcc->sk->sk_sndbuf,
 	    atomic_read(&vcc->sk->sk_rmem_alloc), vcc->sk->sk_rcvbuf);
 }
===== net/atm/pvc.c 1.17 vs edited =====
--- 1.17/net/atm/pvc.c	Fri Jun 20 17:33:02 2003
+++ edited/net/atm/pvc.c	Tue Jun 24 20:25:04 2003
@@ -111,7 +111,7 @@
 	.socketpair =	sock_no_socketpair,
 	.accept =	sock_no_accept,
 	.getname =	pvc_getname,
-	.poll =		atm_poll,
+	.poll =		vcc_poll,
 	.ioctl =	vcc_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	pvc_shutdown,
===== net/atm/raw.c 1.6 vs edited =====
--- 1.6/net/atm/raw.c	Mon Jun 23 10:57:02 2003
+++ edited/net/atm/raw.c	Tue Jun 24 20:25:05 2003
@@ -40,7 +40,7 @@
 		skb->truesize);
 	atomic_sub(skb->truesize, &vcc->sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
-	wake_up(vcc->sk->sk_sleep);
+	vcc->sk->sk_write_space(vcc->sk);
 }
 
 
===== net/atm/signaling.c 1.19 vs edited =====
--- 1.19/net/atm/signaling.c	Mon Jun 23 10:57:02 2003
+++ edited/net/atm/signaling.c	Tue Jun 24 20:25:42 2003
@@ -105,7 +105,8 @@
 	vcc = *(struct atm_vcc **) &msg->vcc;
 	switch (msg->type) {
 		case as_okay:
-			vcc->reply = msg->reply;
+			vcc->sk->sk_err = -msg->reply;
+			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			if (!*vcc->local.sas_addr.prv &&
 			    !*vcc->local.sas_addr.pub) {
 				vcc->local.sas_family = AF_ATMSVC;
@@ -125,8 +126,8 @@
 		case as_error:
 			clear_bit(ATM_VF_REGIS,&vcc->flags);
 			clear_bit(ATM_VF_READY,&vcc->flags);
-			vcc->reply = msg->reply;
 			vcc->sk->sk_err = -msg->reply;
+			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			break;
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
@@ -147,8 +148,8 @@
 		case as_close:
 			set_bit(ATM_VF_RELEASED,&vcc->flags);
 			clear_bit(ATM_VF_READY,&vcc->flags);
-			vcc->reply = msg->reply;
 			vcc->sk->sk_err = -msg->reply;
+			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			break;
 		case as_modify:
 			modify_qos(vcc,msg);
@@ -204,8 +205,8 @@
 	if (vcc->sk->sk_family == PF_ATMSVC &&
 	    !test_bit(ATM_VF_META,&vcc->flags)) {
 		set_bit(ATM_VF_RELEASED,&vcc->flags);
-		vcc->reply = -EUNATCH;
 		vcc->sk->sk_err = EUNATCH;
+		clear_bit(ATM_VF_WAITING, &vcc->flags);
 		vcc->sk->sk_state_change(vcc->sk);
 	}
 }
===== net/atm/signaling.h 1.1 vs edited =====
--- 1.1/net/atm/signaling.h	Tue Feb  5 12:40:00 2002
+++ edited/net/atm/signaling.h	Tue Jun 24 14:24:41 2003
@@ -11,9 +11,6 @@
 #include <linux/atmsvc.h>
 
 
-#define WAITING 1 /* for reply: 0: no error, < 0: error, ... */
-
-
 extern struct atm_vcc *sigd; /* needed in svc_release */
 
 
===== net/atm/svc.c 1.21 vs edited =====
--- 1.21/net/atm/svc.c	Mon Jun 23 10:45:54 2003
+++ edited/net/atm/svc.c	Tue Jun 24 20:25:46 2003
@@ -137,10 +137,10 @@
 		goto out;
 	}
 	vcc->local = *addr;
-	vcc->reply = WAITING;
+	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_bind,NULL,NULL,&vcc->local);
-	while (vcc->reply == WAITING && sigd) {
+	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
@@ -150,9 +150,9 @@
 		error = -EUNATCH;
 		goto out;
 	}
-        if (!vcc->reply)
+        if (!sk->sk_err)
 		set_bit(ATM_VF_BOUND,&vcc->flags);
-	error = vcc->reply;
+	error = -sk->sk_err;
 out:
 	release_sock(sk);
 	return error;
@@ -183,13 +183,13 @@
 		error = -EISCONN;
 		goto out;
 	case SS_CONNECTING:
-		if (vcc->reply == WAITING) {
+		if (test_bit(ATM_VF_WAITING, &vcc->flags)) {
 			error = -EALREADY;
 			goto out;
 		}
 		sock->state = SS_UNCONNECTED;
-		if (vcc->reply) {
-			error = vcc->reply;
+		if (sk->sk_err) {
+			error = -sk->sk_err;
 			goto out;
 		}
 		break;
@@ -218,7 +218,7 @@
 			goto out;
 		}
 		vcc->remote = *addr;
-		vcc->reply = WAITING;
+		set_bit(ATM_VF_WAITING, &vcc->flags);
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		sigd_enq(vcc,as_connect,NULL,NULL,&vcc->remote);
 		if (flags & O_NONBLOCK) {
@@ -228,7 +228,7 @@
 			goto out;
 		}
 		error = 0;
-		while (vcc->reply == WAITING && sigd) {
+		while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 			schedule();
 			if (!signal_pending(current)) {
 				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
@@ -248,11 +248,11 @@
 			 *   Kernel <--close--- Demon
 			 */
 			sigd_enq(vcc,as_close,NULL,NULL,NULL);
-			while (vcc->reply == WAITING && sigd) {
+			while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 				schedule();
 			}
-			if (!vcc->reply)
+			if (!sk->sk_err)
 				while (!test_bit(ATM_VF_RELEASED,&vcc->flags)
 				    && sigd) {
 					prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
@@ -272,8 +272,8 @@
 			error = -EUNATCH;
 			goto out;
 		}
-		if (vcc->reply) {
-			error = vcc->reply;
+		if (sk->sk_err) {
+			error = -sk->sk_err;
 			goto out;
 		}
 	}
@@ -311,10 +311,10 @@
 		error = -EINVAL;
 		goto out;
 	}
-	vcc->reply = WAITING;
+	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_listen,NULL,NULL,&vcc->local);
-	while (vcc->reply == WAITING && sigd) {
+	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
@@ -326,7 +326,7 @@
 	set_bit(ATM_VF_LISTEN,&vcc->flags);
 	vcc->sk->sk_max_ack_backlog = backlog > 0 ? backlog :
 						    ATM_BACKLOG_DEFAULT;
-	error = vcc->reply;
+	error = -sk->sk_err;
 out:
 	release_sock(sk);
 	return error;
@@ -359,7 +359,7 @@
 		       sigd) {
 			if (test_bit(ATM_VF_RELEASED,&old_vcc->flags)) break;
 			if (test_bit(ATM_VF_CLOSE,&old_vcc->flags)) {
-				error = old_vcc->reply;
+				error = -sk->sk_err;
 				break;
 			}
 			if (flags & O_NONBLOCK) {
@@ -399,10 +399,10 @@
 			goto out;
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
-		new_vcc->reply = WAITING;
+		set_bit(ATM_VF_WAITING, &new_vcc->flags);
 		prepare_to_wait(new_vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(new_vcc,as_accept,old_vcc,NULL,NULL);
-		while (new_vcc->reply == WAITING && sigd) {
+		while (test_bit(ATM_VF_WAITING, &new_vcc->flags) && sigd) {
 			release_sock(sk);
 			schedule();
 			lock_sock(sk);
@@ -413,9 +413,10 @@
 			error = -EUNATCH;
 			goto out;
 		}
-		if (!new_vcc->reply) break;
-		if (new_vcc->reply != -ERESTARTSYS) {
-			error = new_vcc->reply;
+		if (!new_vcc->sk->sk_err)
+			break;
+		if (new_vcc->sk->sk_err != ERESTARTSYS) {
+			error = -new_vcc->sk->sk_err;
 			goto out;
 		}
 	}
@@ -443,17 +444,17 @@
 {
 	DEFINE_WAIT(wait);
 
-	vcc->reply = WAITING;
+	set_bit(ATM_VF_WAITING, &vcc->flags);
 	prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq2(vcc,as_modify,NULL,NULL,&vcc->local,qos,0);
-	while (vcc->reply == WAITING && !test_bit(ATM_VF_RELEASED,&vcc->flags)
-	    && sigd) {
+	while (test_bit(ATM_VF_WAITING, &vcc->flags) &&
+	       !test_bit(ATM_VF_RELEASED, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
 	finish_wait(vcc->sk->sk_sleep, &wait);
 	if (!sigd) return -EUNATCH;
-	return vcc->reply;
+	return -vcc->sk->sk_err;
 }
 
 
@@ -519,7 +520,7 @@
 	.socketpair =	sock_no_socketpair,
 	.accept =	svc_accept,
 	.getname =	svc_getname,
-	.poll =		atm_poll,
+	.poll =		vcc_poll,
 	.ioctl =	vcc_ioctl,
 	.listen =	svc_listen,
 	.shutdown =	svc_shutdown,
