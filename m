From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking update: af_unix hooks (4/5)
Date: Fri, 7 Feb 2003 02:21:02 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302070218060.2174-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0302070215300.2174-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@wirex.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0302070215300.2174-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/security.h |   56 +++++++++++++++++++++++++++++++++++++++++++++++
 net/unix/af_unix.c       |   16 +++++++++++++
 security/dummy.c         |   15 ++++++++++++
 3 files changed, 87 insertions(+)

diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Fri Feb  7 01:32:30 2003
+++ linux-2.5.59.w1/include/linux/security.h	Fri Feb  7 01:33:34 2003
@@ -588,6 +588,31 @@
  * 	is being reparented to the init task.
  *	@p contains the task_struct for the kernel thread.
  *
+ * Security hooks for Unix domain networking.
+ *
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
  * Security hooks for socket operations.
  *
  * @socket_create:
@@ -1059,6 +1084,10 @@
 	                            struct security_operations *ops);
 
 #ifdef CONFIG_SECURITY_NETWORK
+	int (*unix_stream_connect) (struct socket * sock,
+				    struct socket * other, struct sock * newsk);
+	int (*unix_may_send) (struct socket * sock, struct socket * other);
+
 	int (*socket_create) (int family, int type, int protocol);
 	void (*socket_post_create) (struct socket * sock, int family,
 				    int type, int protocol);
@@ -2236,6 +2265,20 @@
 #endif	/* CONFIG_SECURITY */
 
 #ifdef CONFIG_SECURITY_NETWORK
+static inline int security_unix_stream_connect(struct socket * sock,
+					       struct socket * other, 
+					       struct sock * newsk)
+{
+	return security_ops->unix_stream_connect(sock, other, newsk);
+}
+
+
+static inline int security_unix_may_send(struct socket * sock, 
+					 struct socket * other)
+{
+	return security_ops->unix_may_send(sock, other);
+}
+
 static inline int security_socket_create (int family, int type, int protocol)
 {
 	return security_ops->socket_create(family, type, protocol);
@@ -2326,6 +2369,19 @@
 	return security_ops->socket_sock_rcv_skb (sk, skb);
 }
 #else	/* CONFIG_SECURITY_NETWORK */
+static inline int security_unix_stream_connect(struct socket * sock,
+					       struct socket * other, 
+					       struct sock * newsk)
+{
+	return 0;
+}
+
+static inline int security_unix_may_send(struct socket * sock, 
+					 struct socket * other)
+{
+	return 0;
+}
+
 static inline int security_socket_create (int family, int type, int protocol)
 {
 	return 0;
diff -urN -X dontdiff linux-2.5.59.w0/net/unix/af_unix.c linux-2.5.59.w1/net/unix/af_unix.c
--- linux-2.5.59.w0/net/unix/af_unix.c	Sat Jan 11 10:47:20 2003
+++ linux-2.5.59.w1/net/unix/af_unix.c	Fri Feb  7 01:33:34 2003
@@ -115,6 +115,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/mount.h>
 #include <net/checksum.h>
+#include <linux/security.h>
 
 int sysctl_unix_max_dgram_qlen = 10;
 
@@ -816,6 +817,11 @@
 		err = -EPERM;
 		if (!unix_may_send(sk, other))
 			goto out_unlock;
+
+		err = security_unix_may_send(sk->socket, other->socket);
+		if (err)
+			goto out_unlock;
+
 	} else {
 		/*
 		 *	1003.1g breaking connected state with AF_UNSPEC
@@ -981,6 +987,12 @@
 		goto restart;
 	}
 
+	err = security_unix_stream_connect(sock, other->socket, newsk);
+	if (err) {
+		unix_state_wunlock(sk);
+		goto out_unlock;
+	}
+
 	/* The way is open! Fastly set all the necessary fields... */
 
 	sock_hold(sk);
@@ -1280,6 +1292,10 @@
 	if (other->shutdown&RCV_SHUTDOWN)
 		goto out_unlock;
 
+	err = security_unix_may_send(sk->socket, other->socket);
+	if (err)
+		goto out_unlock;
+
 	if (unix_peer(other) != sk &&
 	    skb_queue_len(&other->receive_queue) > other->max_ack_backlog) {
 		if (!timeo) {
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Fri Feb  7 01:32:30 2003
+++ linux-2.5.59.w1/security/dummy.c	Fri Feb  7 01:33:34 2003
@@ -598,6 +598,19 @@
 }
 
 #ifdef CONFIG_SECURITY_NETWORK
+static int dummy_unix_stream_connect (struct socket *sock,
+				      struct socket *other,
+				      struct sock *newsk)
+{
+	return 0;
+}
+
+static int dummy_unix_may_send (struct socket *sock,
+				struct socket *other)
+{
+	return 0;
+}
+
 static int dummy_socket_create (int family, int type, int protocol)
 {
 	return 0;
@@ -809,6 +822,8 @@
 	set_to_dummy_if_null(ops, register_security);
 	set_to_dummy_if_null(ops, unregister_security);
 #ifdef CONFIG_SECURITY_NETWORK
+	set_to_dummy_if_null(ops, unix_stream_connect);
+	set_to_dummy_if_null(ops, unix_may_send);
 	set_to_dummy_if_null(ops, socket_create);
 	set_to_dummy_if_null(ops, socket_post_create);
 	set_to_dummy_if_null(ops, socket_bind);
