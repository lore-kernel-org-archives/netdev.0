From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: skb hooks for 2.5.59 (3/8)
Date: Fri, 31 Jan 2003 09:56:34 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301310952140.31382-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0301310948350.31382-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0301310948350.31382-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/security.h |  119 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/skbuff.h   |    3 +
 include/net/sock.h       |    2 
 net/core/datagram.c      |    5 +
 net/core/skbuff.c        |   16 ++++++
 security/dummy.c         |   39 +++++++++++++++
 6 files changed, 183 insertions(+), 1 deletion(-)

diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Thu Jan 30 21:29:06 2003
+++ linux-2.5.59.w1/include/linux/security.h	Thu Jan 30 21:29:32 2003
@@ -64,6 +64,7 @@
 #define LSM_SETID_FS	8
 
 /* forward declares to avoid warnings */
+struct sock;
 struct sk_buff;
 struct net_device;
 struct nfsctl_arg;
@@ -586,6 +587,50 @@
  * 	is being reparented to the init task.
  *	@p contains the task_struct for the kernel thread.
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
  * Security hooks for network devices.
  * @netdev_unregister:
  *	Update the module's state when a network device is unregistered,
@@ -967,6 +1012,16 @@
 	                            struct security_operations *ops);
 
 #ifdef CONFIG_SECURITY_NETWORK
+	int (*skb_alloc_security) (struct sk_buff * skb, int gfp_mask);
+	int (*skb_clone) (struct sk_buff * newskb,
+			  const struct sk_buff * oldskb);
+	void (*skb_copy) (struct sk_buff * newskb,
+			  const struct sk_buff * oldskb);
+	void (*skb_set_owner_w) (struct sk_buff * skb, struct sock * sk);
+	void (*skb_recv_datagram) (struct sk_buff * skb, struct sock * sk,
+				   unsigned flags);
+	void (*skb_free_security) (struct sk_buff * skb);
+
 	void (*netdev_unregister) (struct net_device * dev);
 #endif	/* CONFIG_SECURITY_NETWORK */
 };
@@ -2125,6 +2180,40 @@
 
 #ifdef CONFIG_SECURITY_NETWORK
 
+static inline int security_skb_alloc(struct sk_buff * skb, int gfp_mask)
+{
+	return security_ops->skb_alloc_security(skb, gfp_mask);
+}
+
+static inline int security_skb_clone(struct sk_buff * newskb, 
+				     const struct sk_buff * oldskb)
+{
+	return security_ops->skb_clone(newskb, oldskb);
+}
+
+static inline void security_skb_copy(struct sk_buff * newskb, 
+				     const struct sk_buff * oldskb)
+{
+	security_ops->skb_copy(newskb, oldskb);
+}
+
+static inline void security_skb_set_owner_w (struct sk_buff * skb, 
+					     struct sock * sk)
+{
+	security_ops->skb_set_owner_w (skb, sk);
+}
+
+static inline void security_skb_recv_datagram(struct sk_buff * skb, 
+					      struct sock * sk, unsigned flags)
+{
+	security_ops->skb_recv_datagram(skb, sk, flags);
+}
+
+static inline void security_skb_free(struct sk_buff * skb)
+{
+	security_ops->skb_free_security(skb);
+}
+
 static inline void security_netdev_unregister(struct net_device * dev)
 {
 	security_ops->netdev_unregister(dev);
@@ -2132,6 +2221,36 @@
 
 #else	/* CONFIG_SECURITY_NETWORK */
 
+static inline int security_skb_alloc(struct sk_buff * skb, int gfp_mask)
+{
+	return 0;
+}
+
+static inline int security_skb_clone(struct sk_buff * newskb, 
+				     const struct sk_buff * oldskb)
+{
+	return 0;
+}
+
+static inline void security_skb_copy(struct sk_buff * newskb, 
+				     const struct sk_buff * oldskb)
+{
+}
+
+static inline void security_skb_set_owner_w (struct sk_buff * skb, 
+					     struct sock * sk)
+{
+}
+
+static inline void security_skb_recv_datagram(struct sk_buff * skb, 
+					      struct sock * sk, unsigned flags)
+{
+}
+
+static inline void security_skb_free(struct sk_buff * skb)
+{
+}
+
 static inline void security_netdev_unregister(struct net_device * dev)
 {
 }
diff -urN -X dontdiff linux-2.5.59.w0/include/linux/skbuff.h linux-2.5.59.w1/include/linux/skbuff.h
--- linux-2.5.59.w0/include/linux/skbuff.h	Thu Jan 16 22:51:34 2003
+++ linux-2.5.59.w1/include/linux/skbuff.h	Thu Jan 30 21:29:32 2003
@@ -261,6 +261,9 @@
 #ifdef CONFIG_NET_SCHED
        __u32			tc_index;               /* traffic control index */
 #endif
+#ifdef CONFIG_SECURITY_NETWORK
+	void		*lsm_security;		/* replaces the above security field */
+#endif
 };
 
 #define SK_WMEM_MAX	65535
diff -urN -X dontdiff linux-2.5.59.w0/include/net/sock.h linux-2.5.59.w1/include/net/sock.h
--- linux-2.5.59.w0/include/net/sock.h	Mon Nov 18 23:56:19 2002
+++ linux-2.5.59.w1/include/net/sock.h	Thu Jan 30 21:29:33 2003
@@ -44,6 +44,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>	/* struct sk_buff */
+#include <linux/security.h>
 
 #ifdef CONFIG_FILTER
 #include <linux/filter.h>
@@ -700,6 +701,7 @@
 	sock_hold(sk);
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
+	security_skb_set_owner_w(skb, sk);
 	atomic_add(skb->truesize, &sk->wmem_alloc);
 }
 
diff -urN -X dontdiff linux-2.5.59.w0/net/core/datagram.c linux-2.5.59.w1/net/core/datagram.c
--- linux-2.5.59.w0/net/core/datagram.c	Sun Aug 11 12:20:40 2002
+++ linux-2.5.59.w1/net/core/datagram.c	Thu Jan 30 21:29:33 2003
@@ -47,6 +47,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/poll.h>
 #include <linux/highmem.h>
+#include <linux/security.h>
 
 #include <net/protocol.h>
 #include <linux/skbuff.h>
@@ -176,8 +177,10 @@
 		} else
 			skb = skb_dequeue(&sk->receive_queue);
 
-		if (skb)
+		if (skb) {
+			security_skb_recv_datagram(skb, sk, flags);
 			return skb;
+		}
 
 		/* User doesn't want to wait */
 		error = -EAGAIN;
diff -urN -X dontdiff linux-2.5.59.w0/net/core/skbuff.c linux-2.5.59.w1/net/core/skbuff.c
--- linux-2.5.59.w0/net/core/skbuff.c	Thu Jan 16 22:51:35 2003
+++ linux-2.5.59.w1/net/core/skbuff.c	Thu Jan 30 21:29:33 2003
@@ -53,6 +53,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/security.h>
 
 #include <net/protocol.h>
 #include <net/dst.h>
@@ -195,6 +196,11 @@
 	if (!data)
 		goto nodata;
 
+	if (security_skb_alloc(skb, gfp_mask)) {
+ 		kfree(data);
+		goto nodata;
+	}
+
 	/* XXX: does not include slab overhead */
 	skb->truesize = size + sizeof(struct sk_buff);
 
@@ -257,6 +263,9 @@
 #ifdef CONFIG_NET_SCHED
 	skb->tc_index	  = 0;
 #endif
+#ifdef CONFIG_SECURITY_NETWORK
+	skb->lsm_security = NULL;
+#endif
 }
 
 static void skb_drop_fraglist(struct sk_buff *skb)
@@ -339,6 +348,7 @@
 	nf_bridge_put(skb->nf_bridge);
 #endif
 #endif
+	security_skb_free(skb);
 	skb_headerinit(skb, NULL, 0);  /* clean state */
 	kfree_skbmem(skb);
 }
@@ -366,6 +376,11 @@
 		if (!n)
 			return NULL;
 	}
+	
+	if (security_skb_clone(n, skb)) {
+		skb_head_to_pool(n);
+		return NULL;
+	}
 
 #define C(x) n->x = skb->x
 
@@ -470,6 +485,7 @@
 #ifdef CONFIG_NET_SCHED
 	new->tc_index	= old->tc_index;
 #endif
+	security_skb_copy(new, old);
 }
 
 /**
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Thu Jan 30 21:29:06 2003
+++ linux-2.5.59.w1/security/dummy.c	Thu Jan 30 21:29:33 2003
@@ -599,6 +599,39 @@
 
 #ifdef CONFIG_SECURITY_NETWORK
 
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
 static void dummy_netdev_unregister (struct net_device *dev)
 {
 	return;
@@ -735,6 +768,12 @@
 	set_to_dummy_if_null(ops, register_security);
 	set_to_dummy_if_null(ops, unregister_security);
 #ifdef CONFIG_SECURITY_NETWORK
+	set_to_dummy_if_null(ops, skb_alloc_security);
+	set_to_dummy_if_null(ops, skb_clone);
+	set_to_dummy_if_null(ops, skb_copy);
+	set_to_dummy_if_null(ops, skb_set_owner_w);
+	set_to_dummy_if_null(ops, skb_recv_datagram);
+	set_to_dummy_if_null(ops, skb_free_security);
 	set_to_dummy_if_null(ops, netdev_unregister);
 #endif	/* CONFIG_SECURITY_NETWORK */
 }
