From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 08/31] netns ct: add ->ct_net -- pointer from conntrack to
	netns
Date: Mon, 21 Jul 2008 20:36:47 +0400
Message-ID: <20080721163647.GL13264@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, den@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Conntrack (struct nf_conn) gets new pointer: ->ct_net -- pointer to netns
in which it was created.

It's write-once field (modulo bugs).

->ct_net doesn't pin netns: conntracks are recycled after certain timeouts,
and background traffic will constantly pin netns again and again preventing
it from even starting shutdown sequence.

So far, every conntrack is created in init_net (including untracked one).

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack.h |   18 ++++++++++++++++--
 net/netfilter/nf_conntrack_core.c    |   16 ++++++++++++----
 net/netfilter/nf_conntrack_netlink.c |    2 +-
 3 files changed, 29 insertions(+), 7 deletions(-)

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
 
@@ -153,6 +155,17 @@ static inline u_int8_t nf_ct_protonum(const struct nf_conn *ct)
 /* get master conntrack via master expectation */
 #define master_ct(conntr) (conntr->master)
 
+extern struct net init_net;
+
+static inline struct net *nf_ct_net(const struct nf_conn *ct)
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
@@ -257,7 +270,8 @@ extern void
 nf_ct_iterate_cleanup(int (*iter)(struct nf_conn *i, void *data), void *data);
 extern void nf_conntrack_free(struct nf_conn *ct);
 extern struct nf_conn *
-nf_conntrack_alloc(const struct nf_conntrack_tuple *orig,
+nf_conntrack_alloc(struct net *net,
+		   const struct nf_conntrack_tuple *orig,
 		   const struct nf_conntrack_tuple *repl,
 		   gfp_t gfp);
 
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -463,7 +463,8 @@ static noinline int early_drop(unsigned int hash)
 	return dropped;
 }
 
-struct nf_conn *nf_conntrack_alloc(const struct nf_conntrack_tuple *orig,
+struct nf_conn *nf_conntrack_alloc(struct net *net,
+				   const struct nf_conntrack_tuple *orig,
 				   const struct nf_conntrack_tuple *repl,
 				   gfp_t gfp)
 {
@@ -502,6 +503,9 @@ struct nf_conn *nf_conntrack_alloc(const struct nf_conntrack_tuple *orig,
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
+#ifdef CONFIG_NET_NS
+	ct->ct_net = net;
+#endif
 	INIT_RCU_HEAD(&ct->rcu);
 
 	return ct;
@@ -527,7 +531,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_free);
 /* Allocate a new conntrack: we return -ENOMEM if classification
    failed due to stress.  Otherwise it really is unclassifiable. */
 static struct nf_conntrack_tuple_hash *
-init_conntrack(const struct nf_conntrack_tuple *tuple,
+init_conntrack(struct net *net,
+	       const struct nf_conntrack_tuple *tuple,
 	       struct nf_conntrack_l3proto *l3proto,
 	       struct nf_conntrack_l4proto *l4proto,
 	       struct sk_buff *skb,
@@ -543,7 +548,7 @@ init_conntrack(const struct nf_conntrack_tuple *tuple,
 		return NULL;
 	}
 
-	ct = nf_conntrack_alloc(tuple, &repl_tuple, GFP_ATOMIC);
+	ct = nf_conntrack_alloc(net, tuple, &repl_tuple, GFP_ATOMIC);
 	if (ct == NULL || IS_ERR(ct)) {
 		pr_debug("Can't allocate conntrack.\n");
 		return (struct nf_conntrack_tuple_hash *)ct;
@@ -628,7 +633,7 @@ resolve_normal_ct(struct sk_buff *skb,
 	/* look for tuple match */
 	h = nf_conntrack_find_get(&tuple);
 	if (!h) {
-		h = init_conntrack(&tuple, l3proto, l4proto, skb, dataoff);
+		h = init_conntrack(&init_net, &tuple, l3proto, l4proto, skb, dataoff);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -1174,6 +1179,9 @@ int nf_conntrack_init(struct net *net)
 
 	/* Set up fake conntrack:
 	    - to never be deleted, not in any hashes */
+#ifdef CONFIG_NET_NS
+	nf_conntrack_untracked.ct_net = &init_net;
+#endif
 	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
 	/*  - and look it like as a confirmed connection */
 	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1129,7 +1129,7 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 	struct nf_conn_help *help;
 	struct nf_conntrack_helper *helper;
 
-	ct = nf_conntrack_alloc(otuple, rtuple, GFP_KERNEL);
+	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_KERNEL);
 	if (ct == NULL || IS_ERR(ct))
 		return -ENOMEM;
 
-- 
1.5.4.5


