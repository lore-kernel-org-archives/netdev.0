From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: tcp hooks for 2.5.42 (7/7)
Date: Wed, 16 Oct 2002 00:41:35 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210160030350.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN -X dontdiff linux-2.5.42.w0/include/linux/security.h linux-2.5.42.w1/include/linux/security.h
--- linux-2.5.42.w0/include/linux/security.h	Tue Oct 15 21:13:49 2002
+++ linux-2.5.42.w1/include/linux/security.h	Tue Oct 15 21:21:51 2002
@@ -54,6 +54,7 @@
 struct nfsctl_arg;
 struct sched_param;
 struct swap_info_struct;
+struct open_request;
 
 /**
  * struct security_operations - main security structure
@@ -873,6 +874,38 @@
  * using only the socket layer hooks, since we need to know the actual target
  * socket, which is not looked up until we are inside the af_unix code.
  *
+ * TCP hooks.
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
+ *	@sk contains the listening sock.
+ *      @newsk contains the sock associated with the new connection.
+ *      @skb contains the incoming network packet that finalized the connection.
+ *	@req contains the open_request structure.
+ *
  * @ptrace:
  *	Check permission before allowing the @parent process to trace the
  *	@child process.
@@ -1138,6 +1171,16 @@
 				    struct socket * other, struct sock * newsk);
 	int (*unix_may_send) (struct socket * sock, struct socket * other);
 
+	int (*open_request_alloc_security) (struct open_request * req);
+	void (*open_request_free_security) (struct open_request * req);
+	void (*tcp_connection_request) (struct sock * sk, struct sk_buff * skb,
+	                                struct open_request * req);
+	void (*tcp_synack) (struct sock * sk, struct sk_buff * skb,
+	                    struct open_request * req);
+	void (*tcp_create_openreq_child) (struct sock * sk, struct sock * newsk,
+	                                  struct sk_buff * skb,
+	                                  struct open_request * req);
+	                                  
 	int (*ipc_permission) (struct kern_ipc_perm * ipcp, short flag);
 
 	int (*msg_queue_alloc_security) (struct msg_queue * msq);
diff -urN -X dontdiff linux-2.5.42.w0/include/linux/tcp.h linux-2.5.42.w1/include/linux/tcp.h
--- linux-2.5.42.w0/include/linux/tcp.h	Sun Sep  1 11:34:46 2002
+++ linux-2.5.42.w1/include/linux/tcp.h	Tue Oct 15 21:28:28 2002
@@ -381,4 +381,14 @@
 
 #define tcp_sk(__sk) (&((struct tcp_sock *)__sk)->tcp)
 
+/*
+ * Save/restore the LSM security pointer around the copy.
+ */
+static inline void clone_tcp_sk(struct sock *newsk, struct sock *sk)
+{
+	void *sptr = newsk->security;
+	memcpy(newsk, sk, sizeof(struct tcp_sock));
+	newsk->security = sptr;
+}
+
 #endif	/* _LINUX_TCP_H */
diff -urN -X dontdiff linux-2.5.42.w0/include/net/tcp.h linux-2.5.42.w1/include/net/tcp.h
--- linux-2.5.42.w0/include/net/tcp.h	Sat Oct 12 15:09:43 2002
+++ linux-2.5.42.w1/include/net/tcp.h	Tue Oct 15 21:14:39 2002
@@ -531,13 +531,33 @@
 		struct tcp_v6_open_req v6_req;
 #endif
 	} af;
+	/* LSM security field */
+	void			*security;
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
+		req->security = NULL;
+		if (security_ops->open_request_alloc_security(req)) {
+			kmem_cache_free(tcp_openreq_cachep, req);
+			return NULL;
+		}
+	}
+	return req;
+}
+
+static inline void tcp_openreq_fastfree(struct open_request *req)
+{
+	security_ops->open_request_free_security(req);
+	kmem_cache_free(tcp_openreq_cachep, req);
+}
 
 static inline void tcp_openreq_free(struct open_request *req)
 {
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/syncookies.c linux-2.5.42.w1/net/ipv4/syncookies.c
--- linux-2.5.42.w0/net/ipv4/syncookies.c	Fri Aug  2 07:16:02 2002
+++ linux-2.5.42.w1/net/ipv4/syncookies.c	Tue Oct 15 21:14:39 2002
@@ -181,6 +181,8 @@
 		goto out; 
 	}
 
+	security_ops->tcp_connection_request(sk, skb, req);
+
 	/* Try to redo what tcp_v4_send_synack did. */
 	req->window_clamp = rt->u.dst.window;  
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/tcp_ipv4.c linux-2.5.42.w1/net/ipv4/tcp_ipv4.c
--- linux-2.5.42.w0/net/ipv4/tcp_ipv4.c	Tue Oct 15 20:58:10 2002
+++ linux-2.5.42.w1/net/ipv4/tcp_ipv4.c	Tue Oct 15 21:14:39 2002
@@ -1302,6 +1302,8 @@
 	if (skb) {
 		struct tcphdr *th = skb->h.th;
 
+		security_ops->tcp_synack(sk, skb, req);
+
 		th->check = tcp_v4_check(th, skb->len,
 					 req->af.v4_req.loc_addr,
 					 req->af.v4_req.rmt_addr,
@@ -1518,6 +1520,8 @@
 	}
 	req->snt_isn = isn;
 
+	security_ops->tcp_connection_request(sk, skb, req);
+
 	if (tcp_v4_send_synack(sk, req, dst))
 		goto drop_and_free;
 
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/tcp_minisocks.c linux-2.5.42.w1/net/ipv4/tcp_minisocks.c
--- linux-2.5.42.w0/net/ipv4/tcp_minisocks.c	Sat Oct 12 15:09:44 2002
+++ linux-2.5.42.w1/net/ipv4/tcp_minisocks.c	Tue Oct 15 21:29:19 2002
@@ -652,7 +652,7 @@
 		struct sk_filter *filter;
 #endif
 
-		memcpy(newsk, sk, sizeof(struct tcp_sock));
+		clone_tcp_sk(newsk, sk);
 		newsk->state = TCP_SYN_RECV;
 
 		/* SANITY */
@@ -789,6 +789,7 @@
 			newsk->no_largesend = 1;
 
 		TCP_INC_STATS_BH(TcpPassiveOpens);
+		security_ops->tcp_create_openreq_child(sk, newsk, skb, req);
 	}
 	return newsk;
 }
diff -urN -X dontdiff linux-2.5.42.w0/security/capability.c linux-2.5.42.w1/security/capability.c
--- linux-2.5.42.w0/security/capability.c	Tue Oct 15 21:13:49 2002
+++ linux-2.5.42.w1/security/capability.c	Tue Oct 15 21:25:05 2002
@@ -897,6 +897,35 @@
 	return 0;
 }
 
+static int cap_open_request_alloc_security(struct open_request * req)
+{
+	return 0;
+}
+
+static void cap_open_request_free_security(struct open_request * req)
+{
+	return;
+}
+
+static void cap_tcp_connection_request(struct sock *sk, struct sk_buff * skb,
+                                       struct open_request *req)
+{
+	return;
+}
+
+static void cap_tcp_synack(struct sock *sk, struct sk_buff * skb,
+                           struct open_request *req)
+{
+	return;
+}
+ 
+static void cap_tcp_create_openreq_child(struct sock *sk, struct sock *newsk,
+                                         struct sk_buff *skb,
+                                         struct open_request *req)
+{
+	return;
+}
+
 static int cap_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -1037,6 +1066,12 @@
 	.unix_stream_connect =		cap_socket_unix_stream_connect,
 	.unix_may_send =		cap_socket_unix_may_send,
 
+	.open_request_alloc_security =	cap_open_request_alloc_security,
+	.open_request_free_security =	cap_open_request_free_security,
+	.tcp_connection_request =	cap_tcp_connection_request,
+	.tcp_synack =			cap_tcp_synack,
+  	.tcp_create_openreq_child =	cap_tcp_create_openreq_child,
+
 	.ipc_permission =		cap_ipc_permission,
 
 	.msg_queue_alloc_security =	cap_msg_queue_alloc_security,
diff -urN -X dontdiff linux-2.5.42.w0/security/dummy.c linux-2.5.42.w1/security/dummy.c
--- linux-2.5.42.w0/security/dummy.c	Tue Oct 15 21:13:49 2002
+++ linux-2.5.42.w1/security/dummy.c	Tue Oct 15 21:27:24 2002
@@ -718,6 +718,35 @@
 	return 0;
 }
 
+static int dummy_open_request_alloc_security(struct open_request * req)
+{
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
 static int dummy_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -858,6 +887,12 @@
 	.unix_stream_connect =		dummy_socket_unix_stream_connect,
 	.unix_may_send =		dummy_socket_unix_may_send,
 
+	.open_request_alloc_security =	dummy_open_request_alloc_security,
+	.open_request_free_security =	dummy_open_request_free_security,
+	.tcp_connection_request =	dummy_tcp_connection_request,
+	.tcp_synack =			dummy_tcp_synack,
+	.tcp_create_openreq_child =	dummy_tcp_create_openreq_child,
+
 	.ipc_permission =		dummy_ipc_permission,
 	
 	.msg_queue_alloc_security =	dummy_msg_queue_alloc_security,
