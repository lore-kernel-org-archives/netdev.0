From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: point to multipoint signalling (from ekinzie@cmf.nrl.navy.mil)
Date: Mon, 18 Oct 2004 17:21:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410182121.i9ILLfxC022524@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this patch adds the kernel support necessary for point to
multipoint signalling.  please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/08 13:31:46-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: point to multipoint signalling (from ekinzie@cmf.nrl.navy.mil)
# 
# net/atm/svc.c
#   2004/10/08 13:31:29-04:00 chas@relax.cmf.nrl.navy.mil +123 -19
#   [ATM]: point to multipoint signalling (from ekinzie@cmf.nrl.navy.mil)
# 
# net/atm/signaling.c
#   2004/10/08 13:31:29-04:00 chas@relax.cmf.nrl.navy.mil +11 -0
#   [ATM]: point to multipoint signalling (from ekinzie@cmf.nrl.navy.mil)
# 
# include/linux/atmsvc.h
#   2004/10/08 13:31:29-04:00 chas@relax.cmf.nrl.navy.mil +4 -3
#   [ATM]: point to multipoint signalling (from ekinzie@cmf.nrl.navy.mil)
# 
# include/linux/atmdev.h
#   2004/10/08 13:31:29-04:00 chas@relax.cmf.nrl.navy.mil +4 -0
#   [ATM]: point to multipoint signalling (from ekinzie@cmf.nrl.navy.mil)
# 
# include/linux/atm.h
#   2004/10/08 13:31:29-04:00 chas@relax.cmf.nrl.navy.mil +3 -0
#   [ATM]: point to multipoint signalling (from ekinzie@cmf.nrl.navy.mil)
# 
diff -Nru a/include/linux/atm.h b/include/linux/atm.h
--- a/include/linux/atm.h	2004-10-18 16:14:11 -04:00
+++ b/include/linux/atm.h	2004-10-18 16:14:11 -04:00
@@ -78,6 +78,9 @@
 			    /* Service Access Point */
 #define SO_ATMPVC	__SO_ENCODE(SOL_ATM,4,struct sockaddr_atmpvc)
 			    /* "PVC" address (also for SVCs); get only */
+#define SO_MULTIPOINT	__SO_ENCODE(SOL_ATM, 5, int)
+			    /* make this vc a p2mp */
+
 
 /*
  * Note @@@: since the socket layers don't really distinguish the control and
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	2004-10-18 16:14:11 -04:00
+++ b/include/linux/atmdev.h	2004-10-18 16:14:11 -04:00
@@ -95,6 +95,10 @@
 					/* set backend handler */
 #define ATM_NEWBACKENDIF _IOW('a',ATMIOC_SPECIAL+3,atm_backend_t)
 					/* use backend to make new if */
+#define ATM_ADDPARTY  	_IOW('a', ATMIOC_SPECIAL+4,struct atm_iobuf)
+ 					/* add party to p2mp call */
+#define ATM_DROPPARTY 	_IOW('a', ATMIOC_SPECIAL+5,int)
+					/* drop party from p2mp call */
 
 /*
  * These are backend handkers that can be set via the ATM_SETBACKEND call
diff -Nru a/include/linux/atmsvc.h b/include/linux/atmsvc.h
--- a/include/linux/atmsvc.h	2004-10-18 16:14:11 -04:00
+++ b/include/linux/atmsvc.h	2004-10-18 16:14:11 -04:00
@@ -14,9 +14,10 @@
 #define ATMSIGD_CTRL _IO('a',ATMIOC_SPECIAL)
 				/* become ATM signaling demon control socket */
 
-enum atmsvc_msg_type { as_catch_null,as_bind,as_connect,as_accept,as_reject,
-  as_listen,as_okay,as_error,as_indicate,as_close,as_itf_notify,
-  as_modify,as_identify,as_terminate };
+enum atmsvc_msg_type { as_catch_null, as_bind, as_connect, as_accept, as_reject,
+		       as_listen, as_okay, as_error, as_indicate, as_close,
+		       as_itf_notify, as_modify, as_identify, as_terminate,
+		       as_addparty, as_dropparty };
 
 struct atmsvc_msg {
 	enum atmsvc_msg_type type;
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	2004-10-18 16:14:11 -04:00
+++ b/net/atm/signaling.c	2004-10-18 16:14:11 -04:00
@@ -152,6 +152,11 @@
 		case as_modify:
 			modify_qos(vcc,msg);
 			break;
+		case as_addparty:
+		case as_dropparty:
+			vcc->sk->sk_err_soft = msg->reply;	/* < 0 failure, otherwise ep_ref */
+			clear_bit(ATM_VF_WAITING, &vcc->flags);
+			break;
 		default:
 			printk(KERN_ALERT "sigd_send: bad message type %d\n",
 			    (int) msg->type);
@@ -169,6 +174,7 @@
 {
 	struct sk_buff *skb;
 	struct atmsvc_msg *msg;
+	static unsigned session = 0;
 
 	DPRINTK("sigd_enq %d (0x%p)\n",(int) type,vcc);
 	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg),GFP_KERNEL)))
@@ -184,6 +190,11 @@
 	if (svc) msg->svc = *svc;
 	if (vcc) msg->local = vcc->local;
 	if (pvc) msg->pvc = *pvc;
+	if (vcc) {
+		if (type == as_connect && test_bit(ATM_VF_SESSION, &vcc->flags))
+			msg->session = ++session;
+			/* every new pmp connect gets the next session number */
+	}
 	sigd_put_skb(skb);
 	if (vcc) set_bit(ATM_VF_REGIS,&vcc->flags);
 }
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	2004-10-18 16:14:11 -04:00
+++ b/net/atm/svc.c	2004-10-18 16:14:11 -04:00
@@ -194,10 +194,6 @@
 		}
 		break;
 	case SS_UNCONNECTED:
-		if (test_bit(ATM_VF_SESSION, &vcc->flags)) {
-			error = -EINVAL;
-			goto out;
-		}
 		addr = (struct sockaddr_atmsvc *) sockaddr;
 		if (addr->sas_family != AF_ATMSVC) {
 			error = -EAFNOSUPPORT;
@@ -458,24 +454,48 @@
 }
 
 
-static int svc_setsockopt(struct socket *sock,int level,int optname,
-    char __user *optval,int optlen)
+static int svc_setsockopt(struct socket *sock, int level, int optname,
+			  char __user *optval, int optlen)
 {
 	struct sock *sk = sock->sk;
-	struct atm_vcc *vcc;
-	int error = 0;
+	struct atm_vcc *vcc = ATM_SD(sock);
+	int value, error = 0;
 
-	if (!__SO_LEVEL_MATCH(optname, level) || optname != SO_ATMSAP ||
-	    optlen != sizeof(struct atm_sap)) {
-		error = vcc_setsockopt(sock, level, optname, optval, optlen);
-		goto out;
-	}
-	vcc = ATM_SD(sock);
-	if (copy_from_user(&vcc->sap, optval, optlen)) {
-		error = -EFAULT;
-		goto out;
+	lock_sock(sk);
+	switch (optname) {
+		case SO_ATMSAP:
+			if (level != SOL_ATM || optlen != sizeof(struct atm_sap)) {
+				error = -EINVAL;
+				goto out;
+			}
+			if (copy_from_user(&vcc->sap, optval, optlen)) {
+				error = -EFAULT;
+				goto out;
+			}
+			set_bit(ATM_VF_HASSAP, &vcc->flags);
+			break;
+ 		case SO_MULTIPOINT:
+			if (level != SOL_ATM || optlen != sizeof(int)) {
+				error = -EINVAL;
+				goto out;
+			}
+ 			if (get_user(value, (int *) optval)) {
+ 				error = -EFAULT;
+				goto out;
+			}
+			if (value == 1) {
+				set_bit(ATM_VF_SESSION, &vcc->flags);
+			} else if (value == 0) {
+				clear_bit(ATM_VF_SESSION, &vcc->flags);
+			} else {
+				error = -EINVAL;
+			}
+  			break;
+		default:
+			error = vcc_setsockopt(sock, level, optname,
+					       optval, optlen);
 	}
-	set_bit(ATM_VF_HASSAP, &vcc->flags);
+
 out:
 	release_sock(sk);
 	return error;
@@ -511,6 +531,90 @@
 }
 
 
+static int svc_addparty(struct socket *sock, struct sockaddr *sockaddr,
+			int sockaddr_len, int flags)
+{
+	DEFINE_WAIT(wait);
+	struct atm_vcc *vcc = ATM_SD(sock);
+	int error;
+
+	lock_sock(vcc->sk);
+	set_bit(ATM_VF_WAITING, &vcc->flags);
+	prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	sigd_enq(vcc, as_addparty, NULL, NULL,
+	         (struct sockaddr_atmsvc *) sockaddr);
+	if (flags & O_NONBLOCK) {
+		finish_wait(vcc->sk->sk_sleep, &wait);
+		error = -EINPROGRESS;
+		goto out;
+	}
+	DPRINTK("svc_addparty added wait queue\n");
+	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
+		schedule();
+		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	}
+	finish_wait(vcc->sk->sk_sleep, &wait);
+	error = xchg(&vcc->sk->sk_err_soft, 0);
+out:
+	release_sock(vcc->sk);
+	return error;
+}
+
+
+static int svc_dropparty(struct socket *sock, int ep_ref)
+{
+	DEFINE_WAIT(wait);
+	struct atm_vcc *vcc = ATM_SD(sock);
+	int error;
+
+	lock_sock(vcc->sk);
+	set_bit(ATM_VF_WAITING, &vcc->flags);
+	prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	sigd_enq2(vcc, as_dropparty, NULL, NULL, NULL, NULL, ep_ref);
+	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
+		schedule();
+		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	}
+	finish_wait(vcc->sk->sk_sleep, &wait);
+	if (!sigd) {
+		error = -EUNATCH;
+		goto out;
+	}
+	error = xchg(&vcc->sk->sk_err_soft, 0);
+out:
+	release_sock(vcc->sk);
+	return error;
+}
+
+
+static int svc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+ 	int error, ep_ref;
+ 	struct sockaddr_atmsvc sa;
+	struct atm_vcc *vcc = ATM_SD(sock);
+  
+	switch (cmd) {
+ 		case ATM_ADDPARTY:
+ 			if (!test_bit(ATM_VF_SESSION, &vcc->flags))
+ 				return -EINVAL;
+ 			if (copy_from_user(&sa, (void *) arg, sizeof(sa)))
+				return -EFAULT;
+ 			error = svc_addparty(sock, (struct sockaddr *) &sa, sizeof(sa), 0);
+ 			break;
+ 		case ATM_DROPPARTY:
+ 			if (!test_bit(ATM_VF_SESSION, &vcc->flags))
+ 				return -EINVAL;
+ 			if (copy_from_user(&ep_ref, (void *) arg, sizeof(int)))
+				return -EFAULT;
+ 			error = svc_dropparty(sock, ep_ref);
+ 			break;
+  		default:
+			error = vcc_ioctl(sock, cmd, arg);
+	}
+
+	return error;
+}
+
 static struct proto_ops svc_proto_ops = {
 	.family =	PF_ATMSVC,
 	.owner =	THIS_MODULE,
@@ -522,7 +626,7 @@
 	.accept =	svc_accept,
 	.getname =	svc_getname,
 	.poll =		vcc_poll,
-	.ioctl =	vcc_ioctl,
+	.ioctl =	svc_ioctl,
 	.listen =	svc_listen,
 	.shutdown =	svc_shutdown,
 	.setsockopt =	svc_setsockopt,
