From: adobriyan@gmail.com
Subject: [PATCH 07/38] netns ct: add ->ct_net -- pointer from conntrack to netns
Date: Fri, 22 Aug 2008 01:59:34 +0400
Message-ID: <20080821215934.GG31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:38566 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941AbYHUV6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 17:58:11 -0400
Received: by yx-out-2324.google.com with SMTP id 8so101073yxm.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 14:58:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Conntrack (struct nf_conn) gets pointer to netns: ->ct_net -- netns in which
it was created. It comes from netdevice.

->ct_net is write-once field.

Every conntrack in system has ->ct_net initialized, no exceptions.

->ct_net doesn't pin netns: conntracks are recycled after timeouts and
pinning background traffic will prevent netns from even starting shutdown
sequence.

Right now every conntrack is created in init_net.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack.h |   18 ++++++++++++++++--
 net/netfilter/nf_conntrack_core.c    |   16 ++++++++++++----
 net/netfilter/nf_conntrack_netlink.c |    3 +--
 3 files changed, 29 insertions(+), 8 deletions(-)

--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -123,7 +123,9 @@ struct nf_conn
 
 	/* Extensions */
 	struct nf_ct_ext *ext;
-
+#ifdef CONFIG_NET_NS
+	struct net *ct_net;
+#endif
 	struct rcu_head rcu;
 };
 
@@ -147,6 +149,17 @@ static inline u_int8_t nf_ct_protonum(const struct nf_conn *ct)
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
@@ -251,7 +264,8 @@ extern void
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
@@ -464,7 +464,8 @@ static noinline int early_drop(unsigned int hash)
 	return dropped;
 }
 
-struct nf_conn *nf_conntrack_alloc(const struct nf_conntrack_tuple *orig,
+struct nf_conn *nf_conntrack_alloc(struct net *net,
+				   const struct nf_conntrack_tuple *orig,
 				   const struct nf_conntrack_tuple *repl,
 				   gfp_t gfp)
 {
@@ -503,6 +504,9 @@ struct nf_conn *nf_conntrack_alloc(const struct nf_conntrack_tuple *orig,
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
+#ifdef CONFIG_NET_NS
+	ct->ct_net = net;
+#endif
 	INIT_RCU_HEAD(&ct->rcu);
 
 	return ct;
@@ -528,7 +532,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_free);
 /* Allocate a new conntrack: we return -ENOMEM if classification
    failed due to stress.  Otherwise it really is unclassifiable. */
 static struct nf_conntrack_tuple_hash *
-init_conntrack(const struct nf_conntrack_tuple *tuple,
+init_conntrack(struct net *net,
+	       const struct nf_conntrack_tuple *tuple,
 	       struct nf_conntrack_l3proto *l3proto,
 	       struct nf_conntrack_l4proto *l4proto,
 	       struct sk_buff *skb,
@@ -544,7 +549,7 @@ init_conntrack(const struct nf_conntrack_tuple *tuple,
 		return NULL;
 	}
 
-	ct = nf_conntrack_alloc(tuple, &repl_tuple, GFP_ATOMIC);
+	ct = nf_conntrack_alloc(net, tuple, &repl_tuple, GFP_ATOMIC);
 	if (ct == NULL || IS_ERR(ct)) {
 		pr_debug("Can't allocate conntrack.\n");
 		return (struct nf_conntrack_tuple_hash *)ct;
@@ -631,7 +636,7 @@ resolve_normal_ct(struct sk_buff *skb,
 	/* look for tuple match */
 	h = nf_conntrack_find_get(&tuple);
 	if (!h) {
-		h = init_conntrack(&tuple, l3proto, l4proto, skb, dataoff);
+		h = init_conntrack(&init_net, &tuple, l3proto, l4proto, skb, dataoff);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -1185,6 +1190,9 @@ int nf_conntrack_init(struct net *net)
 
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
@@ -1125,7 +1125,7 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 	struct nf_conn_help *help;
 	struct nf_conntrack_helper *helper;
 
-	ct = nf_conntrack_alloc(otuple, rtuple, GFP_KERNEL);
+	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_KERNEL);
 	if (ct == NULL || IS_ERR(ct))
 		return -ENOMEM;
 
-- 
1.5.6.3


