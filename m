From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: af_unix hooks for 2.5.42 (6/7)
Date: Wed, 16 Oct 2002 00:40:35 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210160030090.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN -X dontdiff linux-2.5.42.w0/include/linux/security.h linux-2.5.42.w1/include/linux/security.h
--- linux-2.5.42.w0/include/linux/security.h	Tue Oct 15 21:10:02 2002
+++ linux-2.5.42.w1/include/linux/security.h	Tue Oct 15 21:10:26 2002
@@ -850,6 +850,29 @@
  *	@skb contains the sk_buff structure for the netlink message.
  *	Return 0 if permission is granted.
  *
+ * @unix_stream_connect:
+ *	Check permissions before establishing a Unix domain stream connection
+ *	between @sock and @other.
+ *	@sock contains the socket structure.
+ *	@other contains the peer socket structure.
+ *	Return 0 if permission is granted.
+ * @unix_may_send:
+ *	Check permissions before connecting or sending datagrams from @sock to
+ *	@other.
+ *	@sock contains the socket structure.
+ *	@sock contains the peer socket structure.
+ *	Return 0 if permission is granted.
+ *
+ * The @unix_stream_connect and @unix_may_send hooks were necessary because
+ * Linux provides an alternative to the conventional file name space for Unix
+ * domain sockets.  Whereas binding and connecting to sockets in the file name
+ * space is mediated by the typical file permissions (and caught by the mknod
+ * and permission hooks in inode_security_ops), binding and connecting to
+ * sockets in the abstract name space is completely unmediated.  Sufficient
+ * control of Unix domain sockets in the abstract name space isn't possible
+ * using only the socket layer hooks, since we need to know the actual target
+ * socket, which is not looked up until we are inside the af_unix code.
+ *
  * @ptrace:
  *	Check permission before allowing the @parent process to trace the
  *	@child process.
@@ -1111,6 +1134,10 @@
 	int (*netlink_send) (struct sk_buff * skb);
 	int (*netlink_recv) (struct sk_buff * skb);
 
+	int (*unix_stream_connect) (struct socket * sock,
+				    struct socket * other, struct sock * newsk);
+	int (*unix_may_send) (struct socket * sock, struct socket * other);
+
 	int (*ipc_permission) (struct kern_ipc_perm * ipcp, short flag);
 
 	int (*msg_queue_alloc_security) (struct msg_queue * msq);
diff -urN -X dontdiff linux-2.5.42.w0/net/unix/af_unix.c linux-2.5.42.w1/net/unix/af_unix.c
--- linux-2.5.42.w0/net/unix/af_unix.c	Wed Aug 28 13:24:30 2002
+++ linux-2.5.42.w1/net/unix/af_unix.c	Tue Oct 15 21:10:26 2002
@@ -111,6 +111,7 @@
 #include <linux/smp_lock.h>
 #include <linux/rtnetlink.h>
 #include <net/checksum.h>
+#include <linux/security.h>
 
 int sysctl_unix_max_dgram_qlen = 10;
 
@@ -812,6 +813,11 @@
 		err = -EPERM;
 		if (!unix_may_send(sk, other))
 			goto out_unlock;
+
+		err = security_ops->unix_may_send(sk->socket, other->socket);
+		if (err)
+			goto out_unlock;
+
 	} else {
 		/*
 		 *	1003.1g breaking connected state with AF_UNSPEC
@@ -977,6 +983,12 @@
 		goto restart;
 	}
 
+	err = security_ops->unix_stream_connect(sock, other->socket, newsk);
+	if (err) {
+		unix_state_wunlock(sk);
+		goto out_unlock;
+	}
+
 	/* The way is open! Fastly set all the necessary fields... */
 
 	sock_hold(sk);
@@ -1274,6 +1286,10 @@
 	if (other->shutdown&RCV_SHUTDOWN)
 		goto out_unlock;
 
+	err = security_ops->unix_may_send(sk->socket, other->socket);
+	if (err)
+		goto out_unlock;
+
 	if (unix_peer(other) != sk &&
 	    skb_queue_len(&other->receive_queue) > other->max_ack_backlog) {
 		if (!timeo) {
diff -urN -X dontdiff linux-2.5.42.w0/security/capability.c linux-2.5.42.w1/security/capability.c
--- linux-2.5.42.w0/security/capability.c	Tue Oct 15 21:10:02 2002
+++ linux-2.5.42.w1/security/capability.c	Tue Oct 15 21:10:26 2002
@@ -885,6 +885,18 @@
 	return 0;
 }
 
+static int cap_socket_unix_stream_connect (struct socket *sock,
+					   struct socket *other,
+					   struct sock *newsk)
+{
+	return 0;
+}
+
+static int cap_socket_unix_may_send (struct socket *sock, struct socket *other)
+{
+	return 0;
+}
+
 static int cap_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -1022,6 +1034,9 @@
 	.netlink_send =			cap_netlink_send,
 	.netlink_recv =			cap_netlink_recv,
 
+	.unix_stream_connect =		cap_socket_unix_stream_connect,
+	.unix_may_send =		cap_socket_unix_may_send,
+
 	.ipc_permission =		cap_ipc_permission,
 
 	.msg_queue_alloc_security =	cap_msg_queue_alloc_security,
diff -urN -X dontdiff linux-2.5.42.w0/security/dummy.c linux-2.5.42.w1/security/dummy.c
--- linux-2.5.42.w0/security/dummy.c	Tue Oct 15 21:10:02 2002
+++ linux-2.5.42.w1/security/dummy.c	Tue Oct 15 21:10:26 2002
@@ -705,6 +705,19 @@
 	return 0;
 }
 
+static int dummy_socket_unix_stream_connect (struct socket *sock,
+					     struct socket *other,
+					     struct sock *newsk)
+{
+	return 0;
+}
+
+static int dummy_socket_unix_may_send (struct socket *sock,
+				       struct socket *other)
+{
+	return 0;
+}
+
 static int dummy_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -842,6 +855,9 @@
 	.netlink_send =			dummy_netlink_send,
 	.netlink_recv =			dummy_netlink_recv,
 
+	.unix_stream_connect =		dummy_socket_unix_stream_connect,
+	.unix_may_send =		dummy_socket_unix_may_send,
+
 	.ipc_permission =		dummy_ipc_permission,
 	
 	.msg_queue_alloc_security =	dummy_msg_queue_alloc_security,
