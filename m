From: James Morris <jmorris@redhat.com>
Subject: [RFC] SO_PEERSEC - security credentials for Unix stream sockets
Date: Wed, 10 Dec 2003 11:33:53 -0500 (EST)
Sender: linux-security-module-bounces@wirex.com
Message-ID: <Xine.LNX.4.44.0312101110010.27922-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, linux-security-module@wirex.com,
	Stephen Smalley <sds@epoch.ncsc.mil>, netdev@oss.sgi.com
Return-path: <linux-security-module-bounces@wirex.com>
To: "David S. Miller" <davem@redhat.com>
List-Unsubscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=unsubscribe>
List-Archive: <http://mail.immunix.com/pipermail/linux-security-module>
List-Post: <mailto:linux-security-module@mail.wirex.com>
List-Help: <mailto:linux-security-module-request@mail.wirex.com?subject=help>
List-Subscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=subscribe>
Errors-To: linux-security-module-bounces@wirex.com
List-Id: netdev.vger.kernel.org

Below is a patch against 2.6.0-test11 which implements a new socket option
SO_PEERSEC (defined for i386 only at this stage).

The purpose of this option is to allow an application to obtain the 
security credentials of a Unix stream socket peer.  It is analogous to 
SO_PEERCRED (which provides authentication using standard Unix credentials 
of pid, uid and gid), and extends this concept to other security models. 
The getsockopt call is exposed via LSM, so that security modules can 
define their own handlers for SO_PEERSEC.

An SELinux specific handler and demonstration userspace utilities are 
available at:
http://people.redhat.com/jmorris/selinux/peersec/

This functionality is required to support SELinux DBUS and Security
Enhanced X, and should be generally useful to security-aware applications
which need to authenticate other applications.

Three new LSM hooks have been implemented:

- socket_getpeersec() is the getsockopt interface.

- sk_alloc_security() and sk_free_security() facilitate the use of an
  sk_security field, which is used to store the security credentials of 
  the Unix peer.  We can't use an existing security field for this (e.g. 
  inode), as we need the security credentials of the server's child 
  socket.  This follows the same general scheme used for managing existing 
  Unix peer credentials.

Comments?


- James
-- 
James Morris
<jmorris@redhat.com>


diff -urN -X dontdiff linux-2.6.0-test11.orig/include/asm-i386/socket.h linux-2.6.0-test11.w2/include/asm-i386/socket.h
--- linux-2.6.0-test11.orig/include/asm-i386/socket.h	2003-09-27 20:50:09.000000000 -0400
+++ linux-2.6.0-test11.w2/include/asm-i386/socket.h	2003-12-10 09:55:39.371902424 -0500
@@ -45,6 +45,8 @@
 
 #define SO_ACCEPTCONN		30
 
+#define SO_PEERSEC		31
+
 /* Nasty libc5 fixup - bletch */
 #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
 /* Socket types. */
diff -urN -X dontdiff linux-2.6.0-test11.orig/include/linux/security.h linux-2.6.0-test11.w2/include/linux/security.h
--- linux-2.6.0-test11.orig/include/linux/security.h	2003-10-15 08:53:19.000000000 -0400
+++ linux-2.6.0-test11.w2/include/linux/security.h	2003-12-10 09:55:39.375901816 -0500
@@ -757,6 +757,19 @@
  *	incoming sk_buff @skb has been associated with a particular socket, @sk.
  *	@sk contains the sock (not socket) associated with the incoming sk_buff.
  *	@skb contains the incoming network data.
+ * @socket_getpeersec:
+ *	This hook allows the security module to provide peer socket security
+ *	state to userspace via getsockopt SO_GETPEERSEC.
+ *	@sock is the local socket.
+ *	@optval userspace memory where the security state is to be copied.
+ *	@len is the maximum length to copy to userspace.
+ *	Return 0 if all is well, otherwise, typical getsockopt return
+ *	values.
+ * @sk_alloc_security:
+ *      Allocate and attach a security structure to the sk->sk_security field,
+ *      which is used to copy security attributes between local stream sockets.
+ * @sk_free_security:
+ *	Deallocate security structure.
  *
  * Security hooks affecting all System V IPC operations.
  *
@@ -1183,6 +1196,9 @@
 	int (*socket_setsockopt) (struct socket * sock, int level, int optname);
 	int (*socket_shutdown) (struct socket * sock, int how);
 	int (*socket_sock_rcv_skb) (struct sock * sk, struct sk_buff * skb);
+	int (*socket_getpeersec) (struct socket *sock, char __user *optval, unsigned len);
+	int (*sk_alloc_security) (struct sock *sk, int family, int priority);
+	void (*sk_free_security) (struct sock *sk);
 #endif	/* CONFIG_SECURITY_NETWORK */
 };
 
@@ -2564,6 +2580,22 @@
 {
 	return security_ops->socket_sock_rcv_skb (sk, skb);
 }
+
+static inline int security_socket_getpeersec(struct socket *sock,
+                                             char __user *optval, unsigned len)
+{
+	return security_ops->socket_getpeersec(sock, optval, len);
+}
+
+static inline int security_sk_alloc_security(struct sock *sk, int family, int priority)
+{
+	return security_ops->sk_alloc_security(sk, family, priority);
+}
+
+static inline void security_sk_free_security(struct sock *sk)
+{
+	return security_ops->sk_free_security(sk);
+}
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct socket * sock,
 					       struct socket * other, 
@@ -2664,6 +2696,21 @@
 {
 	return 0;
 }
+
+static inline int security_socket_getpeersec(struct socket *sock,
+                                             char __user *optval, unsigned optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline int security_sk_alloc_security(struct sock *sk, int family, int priority)
+{
+	return 0;
+}
+
+static inline void security_sk_free_security(struct sock *sk)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #endif /* ! __LINUX_SECURITY_H */
diff -urN -X dontdiff linux-2.6.0-test11.orig/include/net/sock.h linux-2.6.0-test11.w2/include/net/sock.h
--- linux-2.6.0-test11.orig/include/net/sock.h	2003-12-01 15:27:07.000000000 -0500
+++ linux-2.6.0-test11.w2/include/net/sock.h	2003-12-10 09:55:39.376901664 -0500
@@ -246,6 +246,9 @@
 	struct socket		*sk_socket;
 	void			*sk_user_data;
 	struct module		*sk_owner;
+#ifdef CONFIG_SECURITY_NETWORK
+	void			*sk_security;
+#endif
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
diff -urN -X dontdiff linux-2.6.0-test11.orig/net/core/sock.c linux-2.6.0-test11.w2/net/core/sock.c
--- linux-2.6.0-test11.orig/net/core/sock.c	2003-12-01 15:27:04.000000000 -0500
+++ linux-2.6.0-test11.w2/net/core/sock.c	2003-12-10 09:55:39.378901360 -0500
@@ -564,6 +564,9 @@
 			v.val = sk->sk_state == TCP_LISTEN;
 			break;
 
+		case SO_PEERSEC:
+			return security_socket_getpeersec(sock, optval, len);
+
 		default:
 			return(-ENOPROTOOPT);
 	}
@@ -606,6 +609,11 @@
 			sock_lock_init(sk);
 		}
 		sk->sk_slab = slab;
+		
+		if (security_sk_alloc_security(sk, family, priority)) {
+			kmem_cache_free(sk->sk_slab, sk);
+			sk = NULL;
+		}
 	}
 	return sk;
 }
@@ -628,6 +636,7 @@
 		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
 		       __FUNCTION__, atomic_read(&sk->sk_omem_alloc));
 
+	security_sk_free_security(sk);
 	kmem_cache_free(sk->sk_slab, sk);
 	module_put(owner);
 }
diff -urN -X dontdiff linux-2.6.0-test11.orig/security/dummy.c linux-2.6.0-test11.w2/security/dummy.c
--- linux-2.6.0-test11.orig/security/dummy.c	2003-10-15 08:53:19.000000000 -0400
+++ linux-2.6.0-test11.w2/security/dummy.c	2003-12-10 09:55:39.379901208 -0500
@@ -793,6 +793,21 @@
 {
 	return 0;
 }
+
+static int dummy_socket_getpeersec(struct socket *sock,
+                                   char __user *optval, unsigned optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline int dummy_sk_alloc_security (struct sock *sk, int family, int priority)
+{
+	return 0;
+}
+
+static inline void dummy_sk_free_security (struct sock *sk)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 static int dummy_register_security (const char *name, struct security_operations *ops)
@@ -969,6 +984,9 @@
 	set_to_dummy_if_null(ops, socket_getsockopt);
 	set_to_dummy_if_null(ops, socket_shutdown);
 	set_to_dummy_if_null(ops, socket_sock_rcv_skb);
+	set_to_dummy_if_null(ops, socket_getpeersec);
+	set_to_dummy_if_null(ops, sk_alloc_security);
+	set_to_dummy_if_null(ops, sk_free_security);
 #endif	/* CONFIG_SECURITY_NETWORK */
 }
 
