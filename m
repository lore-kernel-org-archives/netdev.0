From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 29/62: nf_conntrack: support conntrack templates
Date: Tue, 16 Feb 2010 15:55:59 +0100 (MET)
Message-ID: <20100216145556.2796.23190.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52029 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932486Ab0BPO4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:01 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b2a15a604d379af323645e330638e2cfcc696aff
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 3 14:13:03 2010 +0100

    netfilter: nf_conntrack: support conntrack templates
    
    Support initializing selected parameters of new conntrack entries from a
    "conntrack template", which is a specially marked conntrack entry attached
    to the skb.
    
    Currently the helper and the event delivery masks can be initialized this
    way.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index ebfed90..c608677 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -72,6 +72,10 @@ enum ip_conntrack_status {
 	/* Connection has fixed timeout. */
 	IPS_FIXED_TIMEOUT_BIT = 10,
 	IPS_FIXED_TIMEOUT = (1 << IPS_FIXED_TIMEOUT_BIT),
+
+	/* Conntrack is a template */
+	IPS_TEMPLATE_BIT = 11,
+	IPS_TEMPLATE = (1 << IPS_TEMPLATE_BIT),
 };
 
 /* Connection tracking event types */
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index a0904ad..5043d61 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -272,6 +272,11 @@ nf_conntrack_alloc(struct net *net,
 		   const struct nf_conntrack_tuple *repl,
 		   gfp_t gfp);
 
+static inline int nf_ct_is_template(const struct nf_conn *ct)
+{
+	return test_bit(IPS_TEMPLATE_BIT, &ct->status);
+}
+
 /* It's confirmed if it is, or has been in the hash table. */
 static inline int nf_ct_is_confirmed(struct nf_conn *ct)
 {
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 86be7c4..e17aaa3 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -47,7 +47,8 @@ extern void nf_conntrack_helper_unregister(struct nf_conntrack_helper *);
 
 extern struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, gfp_t gfp);
 
-extern int __nf_ct_try_assign_helper(struct nf_conn *ct, gfp_t flags);
+extern int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
+				     gfp_t flags);
 
 extern void nf_ct_helper_destroy(struct nf_conn *ct);
 
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 331ead3..77627fa 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -59,7 +59,7 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 #if !defined(CONFIG_NF_NAT) && !defined(CONFIG_NF_NAT_MODULE)
 	/* Previously seen (loopback)?  Ignore.  Do this before
 	   fragment check. */
-	if (skb->nfct)
+	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
 		return NF_ACCEPT;
 #endif
 #endif
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 0956eba..55ce22e 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -212,7 +212,7 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 	struct sk_buff *reasm;
 
 	/* Previously seen (loopback)?  */
-	if (skb->nfct)
+	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
 		return NF_ACCEPT;
 
 	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, skb));
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 53b8da6..471e2a7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -618,7 +618,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_free);
 /* Allocate a new conntrack: we return -ENOMEM if classification
    failed due to stress.  Otherwise it really is unclassifiable. */
 static struct nf_conntrack_tuple_hash *
-init_conntrack(struct net *net,
+init_conntrack(struct net *net, struct nf_conn *tmpl,
 	       const struct nf_conntrack_tuple *tuple,
 	       struct nf_conntrack_l3proto *l3proto,
 	       struct nf_conntrack_l4proto *l4proto,
@@ -628,6 +628,7 @@ init_conntrack(struct net *net,
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
 	struct nf_conntrack_tuple repl_tuple;
+	struct nf_conntrack_ecache *ecache;
 	struct nf_conntrack_expect *exp;
 
 	if (!nf_ct_invert_tuple(&repl_tuple, tuple, l3proto, l4proto)) {
@@ -648,7 +649,11 @@ init_conntrack(struct net *net,
 	}
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
-	nf_ct_ecache_ext_add(ct, 0, 0, GFP_ATOMIC);
+
+	ecache = tmpl ? nf_ct_ecache_find(tmpl) : NULL;
+	nf_ct_ecache_ext_add(ct, ecache ? ecache->ctmask : 0,
+				 ecache ? ecache->expmask : 0,
+			     GFP_ATOMIC);
 
 	spin_lock_bh(&nf_conntrack_lock);
 	exp = nf_ct_find_expectation(net, tuple);
@@ -673,7 +678,7 @@ init_conntrack(struct net *net,
 		nf_conntrack_get(&ct->master->ct_general);
 		NF_CT_STAT_INC(net, expect_new);
 	} else {
-		__nf_ct_try_assign_helper(ct, GFP_ATOMIC);
+		__nf_ct_try_assign_helper(ct, tmpl, GFP_ATOMIC);
 		NF_CT_STAT_INC(net, new);
 	}
 
@@ -694,7 +699,7 @@ init_conntrack(struct net *net,
 
 /* On success, returns conntrack ptr, sets skb->nfct and ctinfo */
 static inline struct nf_conn *
-resolve_normal_ct(struct net *net,
+resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		  struct sk_buff *skb,
 		  unsigned int dataoff,
 		  u_int16_t l3num,
@@ -718,7 +723,8 @@ resolve_normal_ct(struct net *net,
 	/* look for tuple match */
 	h = nf_conntrack_find_get(net, &tuple);
 	if (!h) {
-		h = init_conntrack(net, &tuple, l3proto, l4proto, skb, dataoff);
+		h = init_conntrack(net, tmpl, &tuple, l3proto, l4proto,
+				   skb, dataoff);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -755,7 +761,7 @@ unsigned int
 nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		struct sk_buff *skb)
 {
-	struct nf_conn *ct;
+	struct nf_conn *ct, *tmpl = NULL;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
@@ -764,10 +770,14 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	int set_reply = 0;
 	int ret;
 
-	/* Previously seen (loopback or untracked)?  Ignore. */
 	if (skb->nfct) {
-		NF_CT_STAT_INC_ATOMIC(net, ignore);
-		return NF_ACCEPT;
+		/* Previously seen (loopback or untracked)?  Ignore. */
+		tmpl = (struct nf_conn *)skb->nfct;
+		if (!nf_ct_is_template(tmpl)) {
+			NF_CT_STAT_INC_ATOMIC(net, ignore);
+			return NF_ACCEPT;
+		}
+		skb->nfct = NULL;
 	}
 
 	/* rcu_read_lock()ed by nf_hook_slow */
@@ -778,7 +788,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		pr_debug("not prepared to track yet or error occured\n");
 		NF_CT_STAT_INC_ATOMIC(net, error);
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
-		return -ret;
+		ret = -ret;
+		goto out;
 	}
 
 	l4proto = __nf_ct_l4proto_find(pf, protonum);
@@ -791,22 +802,25 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		if (ret <= 0) {
 			NF_CT_STAT_INC_ATOMIC(net, error);
 			NF_CT_STAT_INC_ATOMIC(net, invalid);
-			return -ret;
+			ret = -ret;
+			goto out;
 		}
 	}
 
-	ct = resolve_normal_ct(net, skb, dataoff, pf, protonum,
+	ct = resolve_normal_ct(net, tmpl, skb, dataoff, pf, protonum,
 			       l3proto, l4proto, &set_reply, &ctinfo);
 	if (!ct) {
 		/* Not valid part of a connection */
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
-		return NF_ACCEPT;
+		ret = NF_ACCEPT;
+		goto out;
 	}
 
 	if (IS_ERR(ct)) {
 		/* Too stressed to deal. */
 		NF_CT_STAT_INC_ATOMIC(net, drop);
-		return NF_DROP;
+		ret = NF_DROP;
+		goto out;
 	}
 
 	NF_CT_ASSERT(skb->nfct);
@@ -821,11 +835,15 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		if (ret == -NF_DROP)
 			NF_CT_STAT_INC_ATOMIC(net, drop);
-		return -ret;
+		ret = -ret;
+		goto out;
 	}
 
 	if (set_reply && !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
 		nf_conntrack_event_cache(IPCT_REPLY, ct);
+out:
+	if (tmpl)
+		nf_ct_put(tmpl);
 
 	return ret;
 }
@@ -864,7 +882,7 @@ void nf_conntrack_alter_reply(struct nf_conn *ct,
 		return;
 
 	rcu_read_lock();
-	__nf_ct_try_assign_helper(ct, GFP_ATOMIC);
+	__nf_ct_try_assign_helper(ct, NULL, GFP_ATOMIC);
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_alter_reply);
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index c0e461f..8144b0d 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -96,13 +96,22 @@ struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, gfp_t gfp)
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_ext_add);
 
-int __nf_ct_try_assign_helper(struct nf_conn *ct, gfp_t flags)
+int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
+			      gfp_t flags)
 {
+	struct nf_conntrack_helper *helper = NULL;
+	struct nf_conn_help *help;
 	int ret = 0;
-	struct nf_conntrack_helper *helper;
-	struct nf_conn_help *help = nfct_help(ct);
 
-	helper = __nf_ct_helper_find(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	if (tmpl != NULL) {
+		help = nfct_help(tmpl);
+		if (help != NULL)
+			helper = help->helper;
+	}
+
+	help = nfct_help(ct);
+	if (helper == NULL)
+		helper = __nf_ct_helper_find(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 	if (helper == NULL) {
 		if (help)
 			rcu_assign_pointer(help->helper, NULL);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index f5c0b09..09044f9 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1249,7 +1249,7 @@ ctnetlink_create_conntrack(struct net *net,
 		}
 	} else {
 		/* try an implicit helper assignation */
-		err = __nf_ct_try_assign_helper(ct, GFP_ATOMIC);
+		err = __nf_ct_try_assign_helper(ct, NULL, GFP_ATOMIC);
 		if (err < 0)
 			goto err2;
 	}
