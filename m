From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 04/25] netns ct: point from conntrack to netns
Date: Sun, 22 Jun 2008 05:02:39 +0400
Message-ID: <20080622010239.GE5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Conntrack (struct nf_conn) gets new pointer: ->ct_net --
pointer to netns in which it was created.

It's write-once field (modulo bugs).

->ct_net doesn't pin netns: conntracks are recycled after certain timeouts,
and background traffic will constantly pin netns again and again preventing
it from even starting shutdown sequence.

So far, every conntrack is created in init_net.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack.h |   16 ++++++++++++++--
 net/netfilter/nf_conntrack_core.c    |   13 +++++++++----
 net/netfilter/nf_conntrack_netlink.c |    2 +-
 3 files changed, 24 insertions(+), 7 deletions(-)

--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -129,7 +129,9 @@ struct nf_conn
 
 	/* Extensions */
 	struct nf_ct_ext *ext;
-
+#ifdef CONFIG_NET_NS
+	struct net *ct_net;
+#endif
 	struct rcu_head rcu;
 };
 
@@ -153,6 +155,15 @@ static inline u_int8_t nf_ct_protonum(const struct nf_conn *ct)
 /* get master conntrack via master expectation */
 #define master_ct(conntr) (conntr->master)
 
+static inline struct net *ct_net(const struct nf_conn *ct)
+{
+#ifdef CONFIG_NET_NS
+	return ct->ct_net;
+#else
+	return &init_net;
+#endif
+}
+
 /* Alter reply tuple (maybe alter helper). */
 extern void
 nf_conntrack_alter_reply(struct nf_conn *ct,
@@ -257,7 +268,8 @@ extern void
 nf_ct_iterate_cleanup(int (*iter)(struct nf_conn *i, void *data), void *data);
 extern void nf_conntrack_free(struct nf_conn *ct);
 extern struct nf_conn *
-nf_conntrack_alloc(const struct nf_conntrack_tuple *orig,
+nf_conntrack_alloc(struct net *net,
+		   const struct nf_conntrack_tuple *orig,
 		   const struct nf_conntrack_tuple *repl);
 
 /* It's confirmed if it is, or has been in the hash table. */
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -463,7 +463,8 @@ static noinline int early_drop(unsigned int hash)
 	return dropped;
 }
 
-struct nf_conn *nf_conntrack_alloc(const struct nf_conntrack_tuple *orig,
+struct nf_conn *nf_conntrack_alloc(struct net *net,
+				   const struct nf_conntrack_tuple *orig,
 				   const struct nf_conntrack_tuple *repl)
 {
 	struct nf_conn *ct = NULL;
@@ -501,6 +502,9 @@ struct nf_conn *nf_conntrack_alloc(const struct nf_conntrack_tuple *orig,
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
+#ifdef CONFIG_NET_NS
+	ct->ct_net = net;
+#endif
 	INIT_RCU_HEAD(&ct->rcu);
 
 	return ct;
@@ -526,7 +530,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_free);
 /* Allocate a new conntrack: we return -ENOMEM if classification
    failed due to stress.  Otherwise it really is unclassifiable. */
 static struct nf_conntrack_tuple_hash *
-init_conntrack(const struct nf_conntrack_tuple *tuple,
+init_conntrack(struct net *net,
+	       const struct nf_conntrack_tuple *tuple,
 	       struct nf_conntrack_l3proto *l3proto,
 	       struct nf_conntrack_l4proto *l4proto,
 	       struct sk_buff *skb,
@@ -542,7 +547,7 @@ init_conntrack(const struct nf_conntrack_tuple *tuple,
 		return NULL;
 	}
 
-	ct = nf_conntrack_alloc(tuple, &repl_tuple);
+	ct = nf_conntrack_alloc(net, tuple, &repl_tuple);
 	if (ct == NULL || IS_ERR(ct)) {
 		pr_debug("Can't allocate conntrack.\n");
 		return (struct nf_conntrack_tuple_hash *)ct;
@@ -627,7 +632,7 @@ resolve_normal_ct(struct sk_buff *skb,
 	/* look for tuple match */
 	h = nf_conntrack_find_get(&tuple);
 	if (!h) {
-		h = init_conntrack(&tuple, l3proto, l4proto, skb, dataoff);
+		h = init_conntrack(&init_net, &tuple, l3proto, l4proto, skb, dataoff);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1128,7 +1128,7 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 	struct nf_conn_help *help;
 	struct nf_conntrack_helper *helper;
 
-	ct = nf_conntrack_alloc(otuple, rtuple);
+	ct = nf_conntrack_alloc(&init_net, otuple, rtuple);
 	if (ct == NULL || IS_ERR(ct))
 		return -ENOMEM;
 
-- 
1.5.4.5


