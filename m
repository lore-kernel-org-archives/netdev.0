From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Wed, 16 Oct 2002 00:36:06 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210160027110.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(note: we'd like to use the existing skb security field, but have not 
touched yet it as you may want to maintain the padding there).


diff -urN -X dontdiff linux-2.5.42.w0/include/linux/security.h linux-2.5.42.w1/include/linux/security.h
--- linux-2.5.42.w0/include/linux/security.h	Tue Oct 15 20:28:55 2002
+++ linux-2.5.42.w1/include/linux/security.h	Tue Oct 15 20:25:40 2002
@@ -630,6 +630,50 @@
  * to use nonblocking allocation.
  * 
  *
+ * Lifecycle hooks for network buffers.
+ *
+ * @skb_alloc_security:
+ *	This hook is called by the &sk_buff allocator when a new buffer is
+ *	being allocated.  An LSM module may allocate and assign a new security
+ *	blob for the &sk_buff via this hook.
+ *	@skb contains the buffer being allocated.
+ *	@gfp_mask contains the kernel allocation gfp_mask value.
+ *	Return 0 if successful, or -ENOMEM on out of memory condition.
+ * @skb_clone:
+ *	This hook is called when an &sk_buff is being cloned, and may be used,
+ *	for example, to increment a reference count on the associated security
+ *	blob.  The security blob in the @newskb will not have been allocated.
+ *	@newskb contains the newly cloned buffer.
+ *	@oldskb contains the buffer being cloned.
+ *	Returns 0 on success -ENOMEM on failure.
+ * @skb_copy:
+ *	This hook is called when an &sk_buff header is being copied, which
+ *	occurs during the skb_copy() and pskb_copy() functions in
+ *	<net/core/skbuff.c>
+ *	@newskb contains the newly copied buffer.
+ *	@oldskb contains the buffer being copied.
+ * @skb_set_owner_w:
+ *	This hook is called when the ownership of an &sk_buff is being assigned
+ *	to a sending socket.  Typically, this would be used to copy security
+ *	attributes from the sending socket to the &sk_buff.
+ *	@skb contains the buffer being owned.
+ *	@sk contains sock to which ownership is being assigned.
+ * @skb_recv_datagram:
+ *      This hook is called when a process is receiving a datagram
+ *      message.  At this point, there is an association between the
+ *      current process, the socket, and the skb.
+ *      @skb contains the buffer being returned.
+ *      @sk is the receiving sock.
+ *      @flags contains operational flags.
+ * @skb_free_security:
+ *	This hook is called when an &sk_buff is being destroyed, and should be
+ *	used to free any associated security blob.
+ *	@skb contains the buffer being destroyed.
+ *
+ * These are the lifecycle hooks for network buffers. They are used to help
+ * manage the lifecycle of security blobs for &sk_buff structures, and are not
+ * intended to be used for access decisions.
+ *
  * @ptrace:
  *	Check permission before allowing the @parent process to trace the
  *	@child process.
@@ -846,6 +890,16 @@
 
 	void (*netdev_unregister) (struct net_device * dev);
 	
+	int (*skb_alloc_security) (struct sk_buff * skb, int gfp_mask);
+	int (*skb_clone) (struct sk_buff * newskb,
+	                  const struct sk_buff * oldskb);
+	void (*skb_copy) (struct sk_buff * newskb,
+	                  const struct sk_buff * oldskb);
+	void (*skb_set_owner_w) (struct sk_buff * skb, struct sock * sk);
+	void (*skb_recv_datagram) (struct sk_buff * skb, struct sock * sk,
+	                           unsigned flags);
+	void (*skb_free_security) (struct sk_buff * skb);
+	
 	int (*ipc_permission) (struct kern_ipc_perm * ipcp, short flag);
 
 	int (*msg_queue_alloc_security) (struct msg_queue * msq);
diff -urN -X dontdiff linux-2.5.42.w0/include/linux/skbuff.h linux-2.5.42.w1/include/linux/skbuff.h
--- linux-2.5.42.w0/include/linux/skbuff.h	Sun Sep  1 11:34:46 2002
+++ linux-2.5.42.w1/include/linux/skbuff.h	Tue Oct 15 20:23:42 2002
@@ -245,6 +245,8 @@
 #ifdef CONFIG_NET_SCHED
        __u32			tc_index;               /* traffic control index */
 #endif
+
+	void		*lsm_security;		/* replaces the above security field */
 };
 
 #define SK_WMEM_MAX	65535
diff -urN -X dontdiff linux-2.5.42.w0/include/net/sock.h linux-2.5.42.w1/include/net/sock.h
--- linux-2.5.42.w0/include/net/sock.h	Sat Oct 12 15:09:43 2002
+++ linux-2.5.42.w1/include/net/sock.h	Tue Oct 15 20:23:42 2002
@@ -663,6 +663,7 @@
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
 	atomic_add(skb->truesize, &sk->wmem_alloc);
+	security_ops->skb_set_owner_w(skb, sk);
 }
 
 static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
diff -urN -X dontdiff linux-2.5.42.w0/net/core/datagram.c linux-2.5.42.w1/net/core/datagram.c
--- linux-2.5.42.w0/net/core/datagram.c	Sun Aug 11 12:20:40 2002
+++ linux-2.5.42.w1/net/core/datagram.c	Tue Oct 15 20:23:42 2002
@@ -176,8 +176,10 @@
 		} else
 			skb = skb_dequeue(&sk->receive_queue);
 
-		if (skb)
+		if (skb) {
+			security_ops->skb_recv_datagram(skb, sk, flags);
 			return skb;
+		}
 
 		/* User doesn't want to wait */
 		error = -EAGAIN;
diff -urN -X dontdiff linux-2.5.42.w0/net/core/skbuff.c linux-2.5.42.w1/net/core/skbuff.c
--- linux-2.5.42.w0/net/core/skbuff.c	Sun Sep  1 11:34:46 2002
+++ linux-2.5.42.w1/net/core/skbuff.c	Tue Oct 15 20:23:42 2002
@@ -53,6 +53,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/security.h>
 
 #include <net/protocol.h>
 #include <net/dst.h>
@@ -194,6 +195,11 @@
 	if (!data)
 		goto nodata;
 
+	if (security_ops->skb_alloc_security(skb, gfp_mask)) {
+ 		kfree(data);
+		goto nodata;
+	}
+
 	/* XXX: does not include slab overhead */
 	skb->truesize = size + sizeof(struct sk_buff);
 
@@ -252,6 +258,7 @@
 #ifdef CONFIG_NET_SCHED
 	skb->tc_index	  = 0;
 #endif
+	skb->lsm_security = NULL;
 }
 
 static void skb_drop_fraglist(struct sk_buff *skb)
@@ -328,6 +335,7 @@
 #ifdef CONFIG_NETFILTER
 	nf_conntrack_put(skb->nfct);
 #endif
+	security_ops->skb_free_security(skb);
 	skb_headerinit(skb, NULL, 0);  /* clean state */
 	kfree_skbmem(skb);
 }
@@ -355,6 +363,11 @@
 		if (!n)
 			return NULL;
 	}
+	
+	if (security_ops->skb_clone(n, skb)) {
+		skb_head_to_pool(n);
+		return NULL;
+	}
 
 #define C(x) n->x = skb->x
 
@@ -442,6 +455,7 @@
 #ifdef CONFIG_NET_SCHED
 	new->tc_index	= old->tc_index;
 #endif
+	security_ops->skb_copy(new, old);
 }
 
 /**
diff -urN -X dontdiff linux-2.5.42.w0/security/capability.c linux-2.5.42.w1/security/capability.c
--- linux-2.5.42.w0/security/capability.c	Tue Oct 15 20:28:55 2002
+++ linux-2.5.42.w1/security/capability.c	Tue Oct 15 20:23:42 2002
@@ -719,6 +719,37 @@
 	return;
 }
 
+static int cap_skb_alloc_security (struct sk_buff *skb, int gfp_mask)
+{
+	return 0;
+}
+
+static int cap_skb_clone (struct sk_buff *newskb, const struct sk_buff *oldskb)
+{
+	return 0;
+}
+
+static void cap_skb_copy (struct sk_buff *newskb, const struct sk_buff *oldskb)
+{
+	return;
+}
+
+static void cap_skb_set_owner_w (struct sk_buff *skb, struct sock *sk)
+{
+	return;
+}
+
+static void cap_skb_recv_datagram (struct sk_buff *skb, struct sock *sk,
+				   unsigned flags)
+{
+	return;
+}
+
+static void cap_skb_free_security (struct sk_buff *skb)
+{
+	return;
+}
+
 static int cap_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -822,6 +853,13 @@
 	.task_kmod_set_label =		cap_task_kmod_set_label,
 	.task_reparent_to_init =	cap_task_reparent_to_init,
 
+	.skb_alloc_security =		cap_skb_alloc_security,
+	.skb_clone =			cap_skb_clone,
+	.skb_copy =			cap_skb_copy,
+	.skb_set_owner_w =		cap_skb_set_owner_w,
+	.skb_recv_datagram =		cap_skb_recv_datagram,
+	.skb_free_security =		cap_skb_free_security,
+
 	.ipc_permission =		cap_ipc_permission,
 
 	.msg_queue_alloc_security =	cap_msg_queue_alloc_security,
diff -urN -X dontdiff linux-2.5.42.w0/security/dummy.c linux-2.5.42.w1/security/dummy.c
--- linux-2.5.42.w0/security/dummy.c	Tue Oct 15 20:28:55 2002
+++ linux-2.5.42.w1/security/dummy.c	Tue Oct 15 20:23:42 2002
@@ -534,6 +534,39 @@
 	return;
 }
 
+static int dummy_skb_alloc_security (struct sk_buff *skb, int gfp_mask)
+{
+	return 0;
+}
+
+static int dummy_skb_clone (struct sk_buff *newskb,
+			     const struct sk_buff *oldskb)
+{
+	return 0;
+}
+
+static void dummy_skb_copy (struct sk_buff *newskb,
+			    const struct sk_buff *oldskb)
+{
+	return;
+}
+
+static void dummy_skb_set_owner_w (struct sk_buff *skb, struct sock *sk)
+{
+	return;
+}
+
+static void dummy_skb_recv_datagram (struct sk_buff *skb, struct sock *sk,
+				     unsigned flags)
+{
+	return;
+}
+
+static void dummy_skb_free_security (struct sk_buff *skb)
+{
+	return;
+}
+
 static int dummy_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -637,6 +670,13 @@
 	.task_kmod_set_label =		dummy_task_kmod_set_label,
 	.task_reparent_to_init =	dummy_task_reparent_to_init,
 
+	.skb_alloc_security =		dummy_skb_alloc_security,
+	.skb_clone =			dummy_skb_clone,
+	.skb_copy =			dummy_skb_copy,
+	.skb_set_owner_w =		dummy_skb_set_owner_w,
+	.skb_recv_datagram =		dummy_skb_recv_datagram,
+	.skb_free_security =		dummy_skb_free_security,
+
 	.ipc_permission =		dummy_ipc_permission,
 	
 	.msg_queue_alloc_security =	dummy_msg_queue_alloc_security,
