From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: tcp hooks for 2.5.59 (8/8)
Date: Fri, 31 Jan 2003 10:22:08 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301311017140.31802-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0301311010580.31382-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0301311010580.31382-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/security.h |  103 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/tcp.h      |   11 +++++
 include/net/tcp.h        |   26 ++++++++++-
 net/ipv4/syncookies.c    |    3 +
 net/ipv4/tcp_ipv4.c      |    4 +
 net/ipv4/tcp_minisocks.c |    6 ++
 security/dummy.c         |   36 ++++++++++++++++
 7 files changed, 186 insertions(+), 3 deletions(-)

diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Thu Jan 30 21:43:00 2003
+++ linux-2.5.59.w1/include/linux/security.h	Thu Jan 30 21:44:11 2003
@@ -77,6 +77,7 @@
 struct nfsctl_arg;
 struct sched_param;
 struct swap_info_struct;
+struct open_request;
 
 
 #ifdef CONFIG_SECURITY
@@ -594,6 +595,38 @@
  * 	is being reparented to the init task.
  *	@p contains the task_struct for the kernel thread.
  *
+ * Security hooks for TCP networking.
+ *
+ * @open_request_alloc_security:
+ *      Allocate the security blob for an open_request structure. The
+ *      req->security field is initialized to NULL when the structure is
+ *      allocated.
+ *      @req Pointer to the open_request structure.
+ *      Return 0 if successful, or -ENOMEM on out of memory condition.
+ * @open_request_free_security:
+ *      Free the security blob for an open_request structure.
+ *      @req Pointer to the open_request structure.
+ * @tcp_connection_request:
+ *      A new connection is being requested on a server. This hook allows
+ *      security information to be attached to the new connection request.
+ *      @sk contains the listening sock.
+ *      @skb contains the incoming network packet.
+ *      @req contains the open_request structure.
+ * @tcp_synack:
+ *      A TCP SYN-ACK packet is being sent out, the second part of the TCP
+ *      three-way handshake for a new connection.
+ *      @sk contains the listening sock.
+ *      @skb contains the outgoing network packet.
+ *      @req contains the open_request structure.
+ * @tcp_create_openreq_child:
+ *      A new connection is being established on a TCP sock. This hook allows
+ *      the association of security information with the new sock as it is
+ *      being created.
+ *      @sk contains the listening sock.
+ *      @newsk contains the sock associated with the new connection.
+ *      @skb contains the incoming network packet that finalized the connection.
+ *      @req contains the open_request structure.
+ *
  * Security hooks for socket operations.
  *
  * @socket_create:
@@ -1224,6 +1257,16 @@
 	                            struct security_operations *ops);
 
 #ifdef CONFIG_SECURITY_NETWORK
+	int (*open_request_alloc_security) (struct open_request * req);
+	void (*open_request_free_security) (struct open_request * req);
+	void (*tcp_connection_request) (struct sock * sk, struct sk_buff * skb,
+					struct open_request * req);
+	void (*tcp_synack) (struct sock * sk, struct sk_buff * skb,
+			    struct open_request * req);
+	void (*tcp_create_openreq_child) (struct sock * sk, struct sock * newsk,
+					  struct sk_buff * skb,
+					  struct open_request * req);
+
 	int (*unix_stream_connect) (struct socket * sock,
 				    struct socket * other, struct sock * newsk);
 	int (*unix_may_send) (struct socket * sock, struct socket * other);
@@ -2460,6 +2503,38 @@
 
 #ifdef CONFIG_SECURITY_NETWORK
 
+static inline int security_open_request_alloc (struct open_request * req)
+{
+	return security_ops->open_request_alloc_security (req);
+}
+
+static inline void security_open_request_free (struct open_request * req)
+{
+	security_ops->open_request_free_security (req);
+}
+
+static inline void security_tcp_connection_request(struct sock * sk, 
+						   struct sk_buff * skb,
+						   struct open_request * req)
+{
+	security_ops->tcp_connection_request(sk, skb, req);
+}
+
+static inline void security_tcp_synack(struct sock * sk, 
+				       struct sk_buff * skb, 
+				       struct open_request * req)
+{
+	security_ops->tcp_synack(sk, skb, req);
+}
+
+static inline void security_tcp_create_openreq_child(struct sock * sk, 
+						     struct sock * newsk, 
+						     struct sk_buff * skb, 
+						     struct open_request * req)
+{
+	security_ops->tcp_create_openreq_child(sk, newsk, skb, req);
+}
+
 static inline int security_unix_stream_connect(struct socket * sock,
 					       struct socket * other, 
 					       struct sock * newsk)
@@ -2637,6 +2712,34 @@
 
 #else	/* CONFIG_SECURITY_NETWORK */
 
+static inline int security_open_request_alloc (struct open_request * req)
+{
+	return 0;
+}
+
+static inline void security_open_request_free (struct open_request * req)
+{
+}
+
+static inline void security_tcp_connection_request(struct sock * sk, 
+						   struct sk_buff * skb,
+						   struct open_request * req)
+{
+}
+
+static inline void security_tcp_synack(struct sock * sk, 
+				       struct sk_buff * skb, 
+				       struct open_request * req)
+{
+}
+
+static inline void security_tcp_create_openreq_child(struct sock * sk, 
+						     struct sock * newsk, 
+						     struct sk_buff * skb, 
+						     struct open_request * req)
+{
+}
+
 static inline int security_unix_stream_connect(struct socket * sock,
 					       struct socket * other, 
 					       struct sock * newsk)
diff -urN -X dontdiff linux-2.5.59.w0/include/linux/tcp.h linux-2.5.59.w1/include/linux/tcp.h
--- linux-2.5.59.w0/include/linux/tcp.h	Sat Oct 19 19:57:49 2002
+++ linux-2.5.59.w1/include/linux/tcp.h	Thu Jan 30 21:44:11 2003
@@ -382,4 +382,15 @@
 
 #define tcp_sk(__sk) (&((struct tcp_sock *)__sk)->tcp)
 
+static inline void clone_tcp_sk(struct sock *newsk, struct sock *sk) {
+#ifdef CONFIG_SECURITY_NETWORK
+/* Save/restore the LSM security pointer around the copy */
+	void *sptr = newsk->security;
+	memcpy(newsk, sk, sizeof(struct tcp_sock));
+	newsk->security = sptr;
+#else
+	memcpy(newsk, sk, sizeof(struct tcp_sock));
+#endif
+}
+
 #endif	/* _LINUX_TCP_H */
diff -urN -X dontdiff linux-2.5.59.w0/include/net/tcp.h linux-2.5.59.w1/include/net/tcp.h
--- linux-2.5.59.w0/include/net/tcp.h	Sat Jan 11 10:47:20 2003
+++ linux-2.5.59.w1/include/net/tcp.h	Thu Jan 30 21:44:11 2003
@@ -29,6 +29,7 @@
 #include <linux/slab.h>
 #include <linux/cache.h>
 #include <linux/percpu.h>
+#include <linux/security.h>
 #include <net/checksum.h>
 #include <net/sock.h>
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
@@ -533,13 +534,34 @@
 		struct tcp_v6_open_req v6_req;
 #endif
 	} af;
+#ifdef CONFIG_SECURITY_NETWORK
+	/* LSM security field */
+	void			*security;
+#endif
 };
 
 /* SLAB cache for open requests. */
 extern kmem_cache_t *tcp_openreq_cachep;
 
-#define tcp_openreq_alloc()		kmem_cache_alloc(tcp_openreq_cachep, SLAB_ATOMIC)
-#define tcp_openreq_fastfree(req)	kmem_cache_free(tcp_openreq_cachep, req)
+static inline struct open_request *tcp_openreq_alloc(void)
+{
+	struct open_request *req =
+		kmem_cache_alloc(tcp_openreq_cachep, SLAB_ATOMIC);
+
+	if (req != NULL) {
+		if (security_open_request_alloc(req)) {
+			kmem_cache_free(tcp_openreq_cachep, req);
+			return NULL;
+		}
+	}
+	return req;
+}
+
+static inline void tcp_openreq_fastfree(struct open_request *req)
+{
+	security_open_request_free(req);
+	kmem_cache_free(tcp_openreq_cachep, req);
+}
 
 static inline void tcp_openreq_free(struct open_request *req)
 {
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/syncookies.c linux-2.5.59.w1/net/ipv4/syncookies.c
--- linux-2.5.59.w0/net/ipv4/syncookies.c	Thu Oct 31 16:01:08 2002
+++ linux-2.5.59.w1/net/ipv4/syncookies.c	Thu Jan 30 21:44:11 2003
@@ -17,6 +17,7 @@
 #include <linux/tcp.h>
 #include <linux/slab.h>
 #include <linux/random.h>
+#include <linux/security.h>
 #include <net/tcp.h>
 
 extern int sysctl_tcp_syncookies;
@@ -188,6 +189,8 @@
 		}
 	}
 
+	security_tcp_connection_request(sk, skb, req);
+
 	/* Try to redo what tcp_v4_send_synack did. */
 	req->window_clamp = dst_metric(&rt->u.dst, RTAX_WINDOW);
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/tcp_ipv4.c linux-2.5.59.w1/net/ipv4/tcp_ipv4.c
--- linux-2.5.59.w0/net/ipv4/tcp_ipv4.c	Thu Jan 30 21:33:15 2003
+++ linux-2.5.59.w1/net/ipv4/tcp_ipv4.c	Thu Jan 30 21:44:11 2003
@@ -1334,6 +1334,8 @@
 	if (skb) {
 		struct tcphdr *th = skb->h.th;
 
+		security_tcp_synack(sk, skb, req);
+
 		th->check = tcp_v4_check(th, skb->len,
 					 req->af.v4_req.loc_addr,
 					 req->af.v4_req.rmt_addr,
@@ -1550,6 +1552,8 @@
 	}
 	req->snt_isn = isn;
 
+	security_tcp_connection_request(sk, skb, req);
+
 	if (tcp_v4_send_synack(sk, req, dst))
 		goto drop_and_free;
 
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/tcp_minisocks.c linux-2.5.59.w1/net/ipv4/tcp_minisocks.c
--- linux-2.5.59.w0/net/ipv4/tcp_minisocks.c	Thu Jan  9 16:08:27 2003
+++ linux-2.5.59.w1/net/ipv4/tcp_minisocks.c	Thu Jan 30 21:44:11 2003
@@ -23,6 +23,7 @@
 #include <linux/config.h>
 #include <linux/mm.h>
 #include <linux/sysctl.h>
+#include <linux/security.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
 #include <net/xfrm.h>
@@ -654,7 +655,8 @@
 		struct sk_filter *filter;
 #endif
 
-		memcpy(newsk, sk, sizeof(struct tcp_sock));
+		clone_tcp_sk(newsk, sk);
+
 		newsk->state = TCP_SYN_RECV;
 
 		/* SANITY */
@@ -801,6 +803,8 @@
 			newsk->no_largesend = 1;
 
 		TCP_INC_STATS_BH(TcpPassiveOpens);
+
+		security_tcp_create_openreq_child(sk, newsk, skb, req);
 	}
 	return newsk;
 }
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Thu Jan 30 21:43:00 2003
+++ linux-2.5.59.w1/security/dummy.c	Thu Jan 30 22:14:55 2003
@@ -21,6 +21,7 @@
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
 #include <net/sock.h>
+#include <net/tcp.h>
 
 static int dummy_ptrace (struct task_struct *parent, struct task_struct *child)
 {
@@ -625,6 +626,36 @@
 
 #ifdef CONFIG_SECURITY_NETWORK
 
+static int dummy_open_request_alloc_security(struct open_request * req)
+{
+	req->security = NULL;
+	return 0;
+}
+
+static void dummy_open_request_free_security(struct open_request * req)
+{
+	return;
+}
+
+static void dummy_tcp_connection_request(struct sock *sk, struct sk_buff * skb, 
+					 struct open_request *req)
+{
+	return;
+}
+
+static void dummy_tcp_synack(struct sock *sk, struct sk_buff * skb, 
+			     struct open_request *req)
+{
+	return;
+}
+
+static void dummy_tcp_create_openreq_child(struct sock *sk, struct sock *newsk, 
+					   struct sk_buff *skb,
+					   struct open_request *req)
+{
+	return;
+}
+
 static int dummy_unix_stream_connect (struct socket *sock,
 				      struct socket *other,
 				      struct sock *newsk)
@@ -923,6 +954,11 @@
 	set_to_dummy_if_null(ops, netlink_recv);	
 	set_to_dummy_if_null(ops, ip_decode_options);
 #ifdef CONFIG_SECURITY_NETWORK
+	set_to_dummy_if_null(ops, open_request_alloc_security);
+	set_to_dummy_if_null(ops, open_request_free_security);
+	set_to_dummy_if_null(ops, tcp_connection_request);
+	set_to_dummy_if_null(ops, tcp_synack);
+	set_to_dummy_if_null(ops, tcp_create_openreq_child);
 	set_to_dummy_if_null(ops, unix_stream_connect);
 	set_to_dummy_if_null(ops, unix_may_send);
 	set_to_dummy_if_null(ops, socket_create);
