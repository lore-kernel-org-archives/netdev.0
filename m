From: James Morris <jmorris@redhat.com>
Subject: Re: [RFC] SO_PEERSEC - security credentials for Unix stream sockets
Date: Tue, 16 Dec 2003 14:43:27 -0500 (EST)
Sender: linux-security-module-bounces@wirex.com
Message-ID: <Xine.LNX.4.44.0312161439150.17565-100000@thoron.boston.redhat.com>
References: <1071582451.32407.12.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>,
	Chris Wright <chrisw@osdl.org>,
	lsm <linux-security-module@wirex.com>, netdev@oss.sgi.com,
	kuznet@ms2.inr.ac.ru
Return-path: <linux-security-module-bounces@wirex.com>
To: Stephen Smalley <sds@epoch.ncsc.mil>
In-Reply-To: <1071582451.32407.12.camel@moss-spartans.epoch.ncsc.mil>
List-Unsubscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=unsubscribe>
List-Archive: <http://mail.immunix.com/pipermail/linux-security-module>
List-Post: <mailto:linux-security-module@mail.wirex.com>
List-Help: <mailto:linux-security-module-request@mail.wirex.com?subject=help>
List-Subscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=subscribe>
Errors-To: linux-security-module-bounces@wirex.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Dec 2003, Stephen Smalley wrote:

> On Tue, 2003-12-16 at 08:19, James Morris wrote:
> > It's not reliable: the required buffer size could change between calls.  
> > Do you know of any examples of syscalls which do this?
> 
> getxattr(2).  From the man page:

Ok, I've changed the arguments in the LSM hook so that the security module
can allow probing of the data length if it wants (and the SELinux module
now does this).  Security modules are now fully responsible for copying
the getsockopt data length back to userspace.

Please see below.

- James
-- 
James Morris
<jmorris@redhat.com>

diff -urN -X dontdiff linux-2.6.0-test11.orig/include/asm-i386/socket.h linux-2.6.0-test11.w1/include/asm-i386/socket.h
--- linux-2.6.0-test11.orig/include/asm-i386/socket.h	2003-09-27 20:50:09.000000000 -0400
+++ linux-2.6.0-test11.w1/include/asm-i386/socket.h	2003-12-12 20:24:34.000000000 -0500
@@ -45,6 +45,8 @@
 
 #define SO_ACCEPTCONN		30
 
+#define SO_PEERSEC		31
+
 /* Nasty libc5 fixup - bletch */
 #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
 /* Socket types. */
diff -urN -X dontdiff linux-2.6.0-test11.orig/include/linux/security.h linux-2.6.0-test11.w1/include/linux/security.h
--- linux-2.6.0-test11.orig/include/linux/security.h	2003-10-15 08:53:19.000000000 -0400
+++ linux-2.6.0-test11.w1/include/linux/security.h	2003-12-16 11:42:42.000000000 -0500
@@ -757,6 +757,22 @@
  *	incoming sk_buff @skb has been associated with a particular socket, @sk.
  *	@sk contains the sock (not socket) associated with the incoming sk_buff.
  *	@skb contains the incoming network data.
+ * @socket_getpeersec:
+ *	This hook allows the security module to provide peer socket security
+ *	state to userspace via getsockopt SO_GETPEERSEC.
+ *	@sock is the local socket.
+ *	@optval userspace memory where the security state is to be copied.
+ *	@optlen userspace int where the module should copy the actual length
+ *	of the security state.
+ *	@len as input is the maximum length to copy to userspace provided
+ *	by the caller.
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
@@ -1183,6 +1199,9 @@
 	int (*socket_setsockopt) (struct socket * sock, int level, int optname);
 	int (*socket_shutdown) (struct socket * sock, int how);
 	int (*socket_sock_rcv_skb) (struct sock * sk, struct sk_buff * skb);
+	int (*socket_getpeersec) (struct socket *sock, char __user *optval, int __user *optlen, unsigned len);
+	int (*sk_alloc_security) (struct sock *sk, int family, int priority);
+	void (*sk_free_security) (struct sock *sk);
 #endif	/* CONFIG_SECURITY_NETWORK */
 };
 
@@ -2564,6 +2583,22 @@
 {
 	return security_ops->socket_sock_rcv_skb (sk, skb);
 }
+
+static inline int security_socket_getpeersec(struct socket *sock, char __user *optval,
+					     int __user *optlen, unsigned len)
+{
+	return security_ops->socket_getpeersec(sock, optval, optlen, len);
+}
+
+static inline int security_sk_alloc(struct sock *sk, int family, int priority)
+{
+	return security_ops->sk_alloc_security(sk, family, priority);
+}
+
+static inline void security_sk_free(struct sock *sk)
+{
+	return security_ops->sk_free_security(sk);
+}
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct socket * sock,
 					       struct socket * other, 
@@ -2664,6 +2699,21 @@
 {
 	return 0;
 }
+
+static inline int security_socket_getpeersec(struct socket *sock, char __user *optval,
+					     int __user *optlen, unsigned len)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline int security_sk_alloc(struct sock *sk, int family, int priority)
+{
+	return 0;
+}
+
+static inline void security_sk_free(struct sock *sk)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #endif /* ! __LINUX_SECURITY_H */
diff -urN -X dontdiff linux-2.6.0-test11.orig/include/net/sock.h linux-2.6.0-test11.w1/include/net/sock.h
--- linux-2.6.0-test11.orig/include/net/sock.h	2003-12-01 15:27:07.000000000 -0500
+++ linux-2.6.0-test11.w1/include/net/sock.h	2003-12-12 20:44:15.000000000 -0500
@@ -246,6 +246,7 @@
 	struct socket		*sk_socket;
 	void			*sk_user_data;
 	struct module		*sk_owner;
+	void			*sk_security;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
diff -urN -X dontdiff linux-2.6.0-test11.orig/net/core/sock.c linux-2.6.0-test11.w1/net/core/sock.c
--- linux-2.6.0-test11.orig/net/core/sock.c	2003-12-01 15:27:04.000000000 -0500
+++ linux-2.6.0-test11.w1/net/core/sock.c	2003-12-16 11:51:21.000000000 -0500
@@ -564,6 +564,9 @@
 			v.val = sk->sk_state == TCP_LISTEN;
 			break;
 
+		case SO_PEERSEC:
+			return security_socket_getpeersec(sock, optval, optlen, len);
+
 		default:
 			return(-ENOPROTOOPT);
 	}
@@ -606,6 +609,11 @@
 			sock_lock_init(sk);
 		}
 		sk->sk_slab = slab;
+		
+		if (security_sk_alloc(sk, family, priority)) {
+			kmem_cache_free(sk->sk_slab, sk);
+			sk = NULL;
+		}
 	}
 	return sk;
 }
@@ -628,6 +636,7 @@
 		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
 		       __FUNCTION__, atomic_read(&sk->sk_omem_alloc));
 
+	security_sk_free(sk);
 	kmem_cache_free(sk->sk_slab, sk);
 	module_put(owner);
 }
diff -urN -X dontdiff linux-2.6.0-test11.orig/security/dummy.c linux-2.6.0-test11.w1/security/dummy.c
--- linux-2.6.0-test11.orig/security/dummy.c	2003-10-15 08:53:19.000000000 -0400
+++ linux-2.6.0-test11.w1/security/dummy.c	2003-12-16 11:43:00.000000000 -0500
@@ -793,6 +793,21 @@
 {
 	return 0;
 }
+
+static int dummy_socket_getpeersec(struct socket *sock, char __user *optval,
+				   int __user *optlen, unsigned len)
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
 
diff -urN -X dontdiff linux-2.6.0-test11.orig/security/selinux/hooks.c linux-2.6.0-test11.w1/security/selinux/hooks.c
--- linux-2.6.0-test11.orig/security/selinux/hooks.c	2003-10-15 08:53:19.000000000 -0400
+++ linux-2.6.0-test11.w1/security/selinux/hooks.c	2003-12-16 11:40:16.000000000 -0500
@@ -242,6 +242,39 @@
 	kfree(sbsec);
 }
 
+#ifdef CONFIG_SECURITY_NETWORK
+static int sk_alloc_security(struct sock *sk, int family, int priority)
+{
+	struct sk_security_struct *ssec;
+
+	if (family != PF_UNIX)
+		return 0;
+
+	ssec = kmalloc(sizeof(*ssec), priority);
+	if (!ssec)
+		return -ENOMEM;
+
+	memset(ssec, 0, sizeof(*ssec));
+	ssec->magic = SELINUX_MAGIC;
+	ssec->sk = sk;
+	ssec->peer_sid = SECINITSID_UNLABELED;
+	sk->sk_security = ssec;
+
+	return 0;
+}
+
+static void sk_free_security(struct sock *sk)
+{
+	struct task_security_struct *ssec = sk->sk_security;
+
+	if (sk->sk_family != PF_UNIX || ssec->magic != SELINUX_MAGIC)
+		return;
+
+	sk->sk_security = NULL;
+	kfree(ssec);
+}
+#endif	/* CONFIG_SECURITY_NETWORK */
+
 /* The security server must be initialized before
    any labeling or access decisions can be provided. */
 extern int ss_initialized;
@@ -2576,6 +2609,7 @@
 					      struct socket *other,
 					      struct sock *newsk)
 {
+	struct sk_security_struct *ssec;
 	struct inode_security_struct *isec;
 	struct inode_security_struct *other_isec;
 	struct avc_audit_data ad;
@@ -2594,6 +2628,14 @@
 	if (err)
 		return err;
 
+	/* connecting socket */
+	ssec = sock->sk->sk_security;
+	ssec->peer_sid = other_isec->sid;
+	
+	/* server child socket */
+	ssec = newsk->sk_security;
+	ssec->peer_sid = isec->sid;
+	
 	return 0;
 }
 
@@ -2621,6 +2663,54 @@
 	return 0;
 }
 
+static int selinux_socket_getpeersec(struct socket *sock, char __user *optval,
+				     int __user *optlen, unsigned len)
+{
+	int err = 0;
+	char *scontext;
+	u32 scontext_len;
+	struct sk_security_struct *ssec;
+	struct inode_security_struct *isec;
+
+	isec = SOCK_INODE(sock)->i_security;
+	if (isec->sclass != SECCLASS_UNIX_STREAM_SOCKET) {
+		err = -ENOPROTOOPT;
+		goto out;
+	}
+
+	ssec = sock->sk->sk_security;
+	
+	err = security_sid_to_context(ssec->peer_sid, &scontext, &scontext_len);
+	if (err)
+		goto out;
+
+	if (scontext_len > len) {
+		err = -ERANGE;
+		goto out_len;
+	}
+
+	if (copy_to_user(optval, scontext, scontext_len))
+		err = -EFAULT;
+
+out_len:
+	if (put_user(scontext_len, optlen))
+		err = -EFAULT;
+
+	kfree(scontext);
+out:	
+	return err;
+}
+
+static int selinux_sk_alloc_security(struct sock *sk, int family, int priority)
+{
+	return sk_alloc_security(sk, family, priority);
+}
+
+static void selinux_sk_free_security(struct sock *sk)
+{
+	sk_free_security(sk);
+}
+
 #endif
 
 static int ipc_alloc_security(struct task_struct *task,
@@ -3356,6 +3446,9 @@
 	.socket_getsockopt =		selinux_socket_getsockopt,
 	.socket_setsockopt =		selinux_socket_setsockopt,
 	.socket_shutdown =		selinux_socket_shutdown,
+	.socket_getpeersec =		selinux_socket_getpeersec,
+	.sk_alloc_security =		selinux_sk_alloc_security,
+	.sk_free_security =		selinux_sk_free_security,
 #endif
 };
 
diff -urN -X dontdiff linux-2.6.0-test11.orig/security/selinux/include/objsec.h linux-2.6.0-test11.w1/security/selinux/include/objsec.h
--- linux-2.6.0-test11.orig/security/selinux/include/objsec.h	2003-09-27 20:50:18.000000000 -0400
+++ linux-2.6.0-test11.w1/security/selinux/include/objsec.h	2003-12-12 20:24:39.000000000 -0500
@@ -93,6 +93,12 @@
 	unsigned char set;
 };
 
+struct sk_security_struct {
+	unsigned long magic;		/* magic number for this module */
+	struct sock *sk;		/* back pointer to sk object */
+	u32 peer_sid;			/* SID of peer */
+};
+
 extern int inode_security_set_sid(struct inode *inode, u32 sid);
 
 #endif /* _SELINUX_OBJSEC_H_ */
