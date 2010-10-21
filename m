From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/12] l2tp: make local function static
Date: Thu, 21 Oct 2010 10:50:46 -0700
Message-ID: <20101021175148.018298774@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36318 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756409Ab0JUSBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:06 -0400
Content-Disposition: inline; filename=l2tp-local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also moved the refcound inlines from l2tp_core.h to l2tp_core.c
since only used in that one file.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/l2tp/l2tp_core.c |   50 ++++++++++++++++++++++++++++++++++++++++----------
 net/l2tp/l2tp_core.h |   33 ---------------------------------
 net/l2tp/l2tp_ip.c   |    2 +-
 3 files changed, 41 insertions(+), 44 deletions(-)

--- a/net/l2tp/l2tp_core.c	2010-10-21 08:50:31.005090762 -0700
+++ b/net/l2tp/l2tp_core.c	2010-10-21 08:51:10.932904559 -0700
@@ -111,6 +111,10 @@ struct l2tp_net {
 	spinlock_t l2tp_session_hlist_lock;
 };
 
+static void l2tp_session_set_header_len(struct l2tp_session *session, int version);
+static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel);
+static void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel);
+
 static inline struct l2tp_net *l2tp_pernet(struct net *net)
 {
 	BUG_ON(!net);
@@ -118,6 +122,34 @@ static inline struct l2tp_net *l2tp_pern
 	return net_generic(net, l2tp_net_id);
 }
 
+
+/* Tunnel reference counts. Incremented per session that is added to
+ * the tunnel.
+ */
+static inline void l2tp_tunnel_inc_refcount_1(struct l2tp_tunnel *tunnel)
+{
+	atomic_inc(&tunnel->ref_count);
+}
+
+static inline void l2tp_tunnel_dec_refcount_1(struct l2tp_tunnel *tunnel)
+{
+	if (atomic_dec_and_test(&tunnel->ref_count))
+		l2tp_tunnel_free(tunnel);
+}
+#ifdef L2TP_REFCNT_DEBUG
+#define l2tp_tunnel_inc_refcount(_t) do { \
+		printk(KERN_DEBUG "l2tp_tunnel_inc_refcount: %s:%d %s: cnt=%d\n", __func__, __LINE__, (_t)->name, atomic_read(&_t->ref_count)); \
+		l2tp_tunnel_inc_refcount_1(_t);				\
+	} while (0)
+#define l2tp_tunnel_dec_refcount(_t) do { \
+		printk(KERN_DEBUG "l2tp_tunnel_dec_refcount: %s:%d %s: cnt=%d\n", __func__, __LINE__, (_t)->name, atomic_read(&_t->ref_count)); \
+		l2tp_tunnel_dec_refcount_1(_t);				\
+	} while (0)
+#else
+#define l2tp_tunnel_inc_refcount(t) l2tp_tunnel_inc_refcount_1(t)
+#define l2tp_tunnel_dec_refcount(t) l2tp_tunnel_dec_refcount_1(t)
+#endif
+
 /* Session hash global list for L2TPv3.
  * The session_id SHOULD be random according to RFC3931, but several
  * L2TP implementations use incrementing session_ids.  So we do a real
@@ -699,8 +731,8 @@ EXPORT_SYMBOL(l2tp_recv_common);
  * Returns 1 if the packet was not a good data packet and could not be
  * forwarded.  All such packets are passed up to userspace to deal with.
  */
-int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
-		       int (*payload_hook)(struct sk_buff *skb))
+static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
+			      int (*payload_hook)(struct sk_buff *skb))
 {
 	struct l2tp_session *session = NULL;
 	unsigned char *ptr, *optr;
@@ -922,7 +954,8 @@ static int l2tp_build_l2tpv3_header(stru
 	return bufp - optr;
 }
 
-int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb, size_t data_len)
+static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
+			  size_t data_len)
 {
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	unsigned int len = skb->len;
@@ -1089,7 +1122,7 @@ EXPORT_SYMBOL_GPL(l2tp_xmit_skb);
  * The tunnel context is deleted only when all session sockets have been
  * closed.
  */
-void l2tp_tunnel_destruct(struct sock *sk)
+static void l2tp_tunnel_destruct(struct sock *sk)
 {
 	struct l2tp_tunnel *tunnel;
 
@@ -1128,11 +1161,10 @@ void l2tp_tunnel_destruct(struct sock *s
 end:
 	return;
 }
-EXPORT_SYMBOL(l2tp_tunnel_destruct);
 
 /* When the tunnel is closed, all the attached sessions need to go too.
  */
-void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel)
+static void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel)
 {
 	int hash;
 	struct hlist_node *walk;
@@ -1198,7 +1230,7 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_closeall);
 /* Really kill the tunnel.
  * Come here only when all sessions have been cleared from the tunnel.
  */
-void l2tp_tunnel_free(struct l2tp_tunnel *tunnel)
+static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel)
 {
 	struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
 
@@ -1217,7 +1249,6 @@ void l2tp_tunnel_free(struct l2tp_tunnel
 	atomic_dec(&l2tp_tunnel_count);
 	kfree(tunnel);
 }
-EXPORT_SYMBOL_GPL(l2tp_tunnel_free);
 
 /* Create a socket for the tunnel, if one isn't set up by
  * userspace. This is used for static tunnels where there is no
@@ -1512,7 +1543,7 @@ EXPORT_SYMBOL_GPL(l2tp_session_delete);
 /* We come here whenever a session's send_seq, cookie_len or
  * l2specific_len parameters are set.
  */
-void l2tp_session_set_header_len(struct l2tp_session *session, int version)
+static void l2tp_session_set_header_len(struct l2tp_session *session, int version)
 {
 	if (version == L2TP_HDR_VER_2) {
 		session->hdr_len = 6;
@@ -1525,7 +1556,6 @@ void l2tp_session_set_header_len(struct
 	}
 
 }
-EXPORT_SYMBOL_GPL(l2tp_session_set_header_len);
 
 struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunnel, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
 {
--- a/net/l2tp/l2tp_core.h	2010-10-21 08:50:31.021092298 -0700
+++ b/net/l2tp/l2tp_core.h	2010-10-21 08:51:10.932904559 -0700
@@ -231,48 +231,15 @@ extern int l2tp_tunnel_create(struct net
 extern int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel);
 extern struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunnel, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg);
 extern int l2tp_session_delete(struct l2tp_session *session);
-extern void l2tp_tunnel_free(struct l2tp_tunnel *tunnel);
 extern void l2tp_session_free(struct l2tp_session *session);
 extern void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb, unsigned char *ptr, unsigned char *optr, u16 hdrflags, int length, int (*payload_hook)(struct sk_buff *skb));
-extern int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb, int (*payload_hook)(struct sk_buff *skb));
 extern int l2tp_udp_encap_recv(struct sock *sk, struct sk_buff *skb);
 
-extern int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb, size_t data_len);
 extern int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len);
-extern void l2tp_tunnel_destruct(struct sock *sk);
-extern void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel);
-extern void l2tp_session_set_header_len(struct l2tp_session *session, int version);
 
 extern int l2tp_nl_register_ops(enum l2tp_pwtype pw_type, const struct l2tp_nl_cmd_ops *ops);
 extern void l2tp_nl_unregister_ops(enum l2tp_pwtype pw_type);
 
-/* Tunnel reference counts. Incremented per session that is added to
- * the tunnel.
- */
-static inline void l2tp_tunnel_inc_refcount_1(struct l2tp_tunnel *tunnel)
-{
-	atomic_inc(&tunnel->ref_count);
-}
-
-static inline void l2tp_tunnel_dec_refcount_1(struct l2tp_tunnel *tunnel)
-{
-	if (atomic_dec_and_test(&tunnel->ref_count))
-		l2tp_tunnel_free(tunnel);
-}
-#ifdef L2TP_REFCNT_DEBUG
-#define l2tp_tunnel_inc_refcount(_t) do { \
-		printk(KERN_DEBUG "l2tp_tunnel_inc_refcount: %s:%d %s: cnt=%d\n", __func__, __LINE__, (_t)->name, atomic_read(&_t->ref_count)); \
-		l2tp_tunnel_inc_refcount_1(_t);				\
-	} while (0)
-#define l2tp_tunnel_dec_refcount(_t) do { \
-		printk(KERN_DEBUG "l2tp_tunnel_dec_refcount: %s:%d %s: cnt=%d\n", __func__, __LINE__, (_t)->name, atomic_read(&_t->ref_count)); \
-		l2tp_tunnel_dec_refcount_1(_t);				\
-	} while (0)
-#else
-#define l2tp_tunnel_inc_refcount(t) l2tp_tunnel_inc_refcount_1(t)
-#define l2tp_tunnel_dec_refcount(t) l2tp_tunnel_dec_refcount_1(t)
-#endif
-
 /* Session reference counts. Incremented when code obtains a reference
  * to a session.
  */
--- a/net/l2tp/l2tp_ip.c	2010-10-21 08:50:50.434951463 -0700
+++ b/net/l2tp/l2tp_ip.c	2010-10-21 08:51:10.932904559 -0700
@@ -576,7 +576,7 @@ out:
 	return copied;
 }
 
-struct proto l2tp_ip_prot = {
+static struct proto l2tp_ip_prot = {
 	.name		   = "L2TP/IP",
 	.owner		   = THIS_MODULE,
 	.init		   = l2tp_ip_open,


