From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [rfc] sk_write_space() for atm
Date: Tue, 24 Jun 2003 13:33:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306241735.h5OHZCsG004098@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

i am thinking about the following for the atm protocol.
the writable for atm has always been when you have enough
space to send the next pdu.  i suppose this should be 
preserved to be completely compat, but it might not be the
best choice.  poll is interesting also.  it seems to me
that vcc->reply should be atleast copied, since it could
change during the poll function (or so i imagine).  its
probably a better idea to just change WAITING to be a bit
inside vcc->flags and remove vcc->error in favor of sk->sk_err.

===== net/atm/common.c 1.41 vs edited =====
--- 1.41/net/atm/common.c	Mon Jun 23 10:57:01 2003
+++ edited/net/atm/common.c	Tue Jun 24 11:58:16 2003
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
@@ -617,29 +641,39 @@
 }
 
 
-unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait)
+unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
+	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
+	volatile int reply;
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
+	reply = vcc->reply;
+
+	/* exceptional events */
+	if (sk->sk_err || (reply && reply != WAITING))
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
+	if (sock->state == SS_CONNECTING && reply == WAITING)
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
+++ edited/net/atm/common.h	Mon Jun 23 11:04:38 2003
@@ -17,7 +17,7 @@
 		int size, int flags);
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		int total_len);
-unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
+unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int vcc_setsockopt(struct socket *sock, int level, int optname, char *optval,
 		   int optlen);
===== net/atm/pvc.c 1.17 vs edited =====
--- 1.17/net/atm/pvc.c	Fri Jun 20 17:33:02 2003
+++ edited/net/atm/pvc.c	Mon Jun 23 11:05:07 2003
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
+++ edited/net/atm/raw.c	Mon Jun 23 11:06:57 2003
@@ -40,7 +40,7 @@
 		skb->truesize);
 	atomic_sub(skb->truesize, &vcc->sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
-	wake_up(vcc->sk->sk_sleep);
+	vcc->sk->sk_write_space(vcc->sk);
 }
 
 
===== net/atm/svc.c 1.21 vs edited =====
--- 1.21/net/atm/svc.c	Mon Jun 23 10:45:54 2003
+++ edited/net/atm/svc.c	Mon Jun 23 11:05:17 2003
@@ -519,7 +519,7 @@
 	.socketpair =	sock_no_socketpair,
 	.accept =	svc_accept,
 	.getname =	svc_getname,
-	.poll =		atm_poll,
+	.poll =		vcc_poll,
 	.ioctl =	vcc_ioctl,
 	.listen =	svc_listen,
 	.shutdown =	svc_shutdown,
