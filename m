From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/38] netfilter: conntrack: seperate expect locking from nf_conntrack_lock
Date: Mon, 17 Mar 2014 13:42:43 +0100
Message-ID: <1395060178-11833-24-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59459 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933121AbaCQMnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:41 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>

Netfilter expectations are protected with the same lock as conntrack
entries (nf_conntrack_lock).  This patch split out expectations locking
to use it's own lock (nf_conntrack_expect_lock).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Reviewed-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_core.h |    2 +
 net/netfilter/nf_conntrack_core.c         |   60 ++++++++++++++++-------------
 net/netfilter/nf_conntrack_expect.c       |   20 +++++-----
 net/netfilter/nf_conntrack_h323_main.c    |    4 +-
 net/netfilter/nf_conntrack_helper.c       |   22 +++++------
 net/netfilter/nf_conntrack_netlink.c      |   32 +++++++--------
 net/netfilter/nf_conntrack_sip.c          |    8 ++--
 7 files changed, 79 insertions(+), 69 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 15308b8..d12a631 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -79,4 +79,6 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
 
 extern spinlock_t nf_conntrack_lock ;
 
+extern spinlock_t nf_conntrack_expect_lock;
+
 #endif /* _NF_CONNTRACK_CORE_H */
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 92d5977..4cdf1ad 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -63,6 +63,9 @@ EXPORT_SYMBOL_GPL(nfnetlink_parse_nat_setup_hook);
 DEFINE_SPINLOCK(nf_conntrack_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_lock);
 
+__cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
+EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
+
 unsigned int nf_conntrack_htable_size __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 
@@ -247,9 +250,6 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	NF_CT_ASSERT(atomic_read(&nfct->use) == 0);
 	NF_CT_ASSERT(!timer_pending(&ct->timeout));
 
-	/* To make sure we don't get any weird locking issues here:
-	 * destroy_conntrack() MUST NOT be called with a write lock
-	 * to nf_conntrack_lock!!! -HW */
 	rcu_read_lock();
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto && l4proto->destroy)
@@ -257,17 +257,18 @@ destroy_conntrack(struct nf_conntrack *nfct)
 
 	rcu_read_unlock();
 
-	spin_lock_bh(&nf_conntrack_lock);
+	local_bh_disable();
 	/* Expectations will have been removed in clean_from_lists,
 	 * except TFTP can create an expectation on the first packet,
 	 * before connection is in the list, so we need to clean here,
-	 * too. */
+	 * too.
+	 */
 	nf_ct_remove_expectations(ct);
 
 	nf_ct_del_from_dying_or_unconfirmed_list(ct);
 
 	NF_CT_STAT_INC(net, delete);
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 
 	if (ct->master)
 		nf_ct_put(ct->master);
@@ -851,7 +852,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	struct nf_conn_help *help;
 	struct nf_conntrack_tuple repl_tuple;
 	struct nf_conntrack_ecache *ecache;
-	struct nf_conntrack_expect *exp;
+	struct nf_conntrack_expect *exp = NULL;
 	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
 	struct nf_conn_timeout *timeout_ext;
 	unsigned int *timeouts;
@@ -895,30 +896,35 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 				 ecache ? ecache->expmask : 0,
 			     GFP_ATOMIC);
 
-	spin_lock_bh(&nf_conntrack_lock);
-	exp = nf_ct_find_expectation(net, zone, tuple);
-	if (exp) {
-		pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
-			 ct, exp);
-		/* Welcome, Mr. Bond.  We've been expecting you... */
-		__set_bit(IPS_EXPECTED_BIT, &ct->status);
-		/* exp->master safe, refcnt bumped in nf_ct_find_expectation */
-		ct->master = exp->master;
-		if (exp->helper) {
-			help = nf_ct_helper_ext_add(ct, exp->helper,
-						    GFP_ATOMIC);
-			if (help)
-				rcu_assign_pointer(help->helper, exp->helper);
-		}
+	local_bh_disable();
+	if (net->ct.expect_count) {
+		spin_lock(&nf_conntrack_expect_lock);
+		exp = nf_ct_find_expectation(net, zone, tuple);
+		if (exp) {
+			pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
+				 ct, exp);
+			/* Welcome, Mr. Bond.  We've been expecting you... */
+			__set_bit(IPS_EXPECTED_BIT, &ct->status);
+			/* exp->master safe, refcnt bumped in nf_ct_find_expectation */
+			ct->master = exp->master;
+			if (exp->helper) {
+				help = nf_ct_helper_ext_add(ct, exp->helper,
+							    GFP_ATOMIC);
+				if (help)
+					rcu_assign_pointer(help->helper, exp->helper);
+			}
 
 #ifdef CONFIG_NF_CONNTRACK_MARK
-		ct->mark = exp->master->mark;
+			ct->mark = exp->master->mark;
 #endif
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
-		ct->secmark = exp->master->secmark;
+			ct->secmark = exp->master->secmark;
 #endif
-		NF_CT_STAT_INC(net, expect_new);
-	} else {
+			NF_CT_STAT_INC(net, expect_new);
+		}
+		spin_unlock(&nf_conntrack_expect_lock);
+	}
+	if (!exp) {
 		__nf_ct_try_assign_helper(ct, tmpl, GFP_ATOMIC);
 		NF_CT_STAT_INC(net, new);
 	}
@@ -927,7 +933,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	nf_conntrack_get(&ct->ct_general);
 	nf_ct_add_to_unconfirmed_list(ct);
 
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 
 	if (exp) {
 		if (exp->expectfn)
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index f02805e..f87e8f6 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -66,9 +66,9 @@ static void nf_ct_expectation_timed_out(unsigned long ul_expect)
 {
 	struct nf_conntrack_expect *exp = (void *)ul_expect;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	nf_ct_unlink_expect(exp);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 	nf_ct_expect_put(exp);
 }
 
@@ -191,12 +191,14 @@ void nf_ct_remove_expectations(struct nf_conn *ct)
 	if (!help)
 		return;
 
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	hlist_for_each_entry_safe(exp, next, &help->expectations, lnode) {
 		if (del_timer(&exp->timeout)) {
 			nf_ct_unlink_expect(exp);
 			nf_ct_expect_put(exp);
 		}
 	}
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_remove_expectations);
 
@@ -231,12 +233,12 @@ static inline int expect_matches(const struct nf_conntrack_expect *a,
 /* Generally a bad idea to call this: could have matched already. */
 void nf_ct_unexpect_related(struct nf_conntrack_expect *exp)
 {
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	if (del_timer(&exp->timeout)) {
 		nf_ct_unlink_expect(exp);
 		nf_ct_expect_put(exp);
 	}
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_unexpect_related);
 
@@ -349,7 +351,7 @@ static int nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	setup_timer(&exp->timeout, nf_ct_expectation_timed_out,
 		    (unsigned long)exp);
 	helper = rcu_dereference_protected(master_help->helper,
-					   lockdep_is_held(&nf_conntrack_lock));
+					   lockdep_is_held(&nf_conntrack_expect_lock));
 	if (helper) {
 		exp->timeout.expires = jiffies +
 			helper->expect_policy[exp->class].timeout * HZ;
@@ -409,7 +411,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 	}
 	/* Will be over limit? */
 	helper = rcu_dereference_protected(master_help->helper,
-					   lockdep_is_held(&nf_conntrack_lock));
+					   lockdep_is_held(&nf_conntrack_expect_lock));
 	if (helper) {
 		p = &helper->expect_policy[expect->class];
 		if (p->max_expected &&
@@ -436,7 +438,7 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 {
 	int ret;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	ret = __nf_ct_expect_check(expect);
 	if (ret <= 0)
 		goto out;
@@ -444,11 +446,11 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 	ret = nf_ct_expect_insert(expect);
 	if (ret < 0)
 		goto out;
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 	nf_ct_expect_event_report(IPEXP_NEW, expect, portid, report);
 	return ret;
 out:
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_related_report);
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 70866d1..3a3a60b 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1476,7 +1476,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 		nf_ct_refresh(ct, skb, info->timeout * HZ);
 
 		/* Set expect timeout */
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		exp = find_expect(ct, &ct->tuplehash[dir].tuple.dst.u3,
 				  info->sig_port[!dir]);
 		if (exp) {
@@ -1486,7 +1486,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 			nf_ct_dump_tuple(&exp->tuple);
 			set_expect_timeout(exp, info->timeout);
 		}
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 	}
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 27d9302..29bd704 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -250,16 +250,14 @@ out:
 }
 EXPORT_SYMBOL_GPL(__nf_ct_try_assign_helper);
 
+/* appropiate ct lock protecting must be taken by caller */
 static inline int unhelp(struct nf_conntrack_tuple_hash *i,
 			 const struct nf_conntrack_helper *me)
 {
 	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(i);
 	struct nf_conn_help *help = nfct_help(ct);
 
-	if (help && rcu_dereference_protected(
-			help->helper,
-			lockdep_is_held(&nf_conntrack_lock)
-			) == me) {
+	if (help && rcu_dereference_raw(help->helper) == me) {
 		nf_conntrack_event(IPCT_HELPER, ct);
 		RCU_INIT_POINTER(help->helper, NULL);
 	}
@@ -284,17 +282,17 @@ static LIST_HEAD(nf_ct_helper_expectfn_list);
 
 void nf_ct_helper_expectfn_register(struct nf_ct_helper_expectfn *n)
 {
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	list_add_rcu(&n->head, &nf_ct_helper_expectfn_list);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_register);
 
 void nf_ct_helper_expectfn_unregister(struct nf_ct_helper_expectfn *n)
 {
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	list_del_rcu(&n->head);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_unregister);
 
@@ -399,13 +397,14 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 	int cpu;
 
 	/* Get rid of expectations */
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	for (i = 0; i < nf_ct_expect_hsize; i++) {
 		hlist_for_each_entry_safe(exp, next,
 					  &net->ct.expect_hash[i], hnode) {
 			struct nf_conn_help *help = nfct_help(exp->master);
 			if ((rcu_dereference_protected(
 					help->helper,
-					lockdep_is_held(&nf_conntrack_lock)
+					lockdep_is_held(&nf_conntrack_expect_lock)
 					) == me || exp->helper == me) &&
 			    del_timer(&exp->timeout)) {
 				nf_ct_unlink_expect(exp);
@@ -413,6 +412,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 			}
 		}
 	}
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 
 	/* Get rid of expecteds, set helpers to NULL. */
 	for_each_possible_cpu(cpu) {
@@ -423,10 +423,12 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 			unhelp(h, me);
 		spin_unlock_bh(&pcpu->lock);
 	}
+	spin_lock_bh(&nf_conntrack_lock);
 	for (i = 0; i < net->ct.htable_size; i++) {
 		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
 			unhelp(h, me);
 	}
+	spin_unlock_bh(&nf_conntrack_lock);
 }
 
 void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
@@ -444,10 +446,8 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	synchronize_rcu();
 
 	rtnl_lock();
-	spin_lock_bh(&nf_conntrack_lock);
 	for_each_net(net)
 		__nf_conntrack_helper_unregister(me, net);
-	spin_unlock_bh(&nf_conntrack_lock);
 	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_unregister);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4ac8ce6..be4d1b0 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1376,14 +1376,14 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 					    nf_ct_protonum(ct));
 	if (helper == NULL) {
 #ifdef CONFIG_MODULES
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 
 		if (request_module("nfct-helper-%s", helpname) < 0) {
-			spin_lock_bh(&nf_conntrack_lock);
+			spin_lock_bh(&nf_conntrack_expect_lock);
 			return -EOPNOTSUPP;
 		}
 
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
 						    nf_ct_protonum(ct));
 		if (helper)
@@ -1821,9 +1821,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	err = -EEXIST;
 	ct = nf_ct_tuplehash_to_ctrack(h);
 	if (!(nlh->nlmsg_flags & NLM_F_EXCL)) {
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		err = ctnetlink_change_conntrack(ct, cda);
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 		if (err == 0) {
 			nf_conntrack_eventmask_report((1 << IPCT_REPLY) |
 						      (1 << IPCT_ASSURED) |
@@ -2152,9 +2152,9 @@ ctnetlink_nfqueue_parse(const struct nlattr *attr, struct nf_conn *ct)
 	if (ret < 0)
 		return ret;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	ret = ctnetlink_nfqueue_parse_ct((const struct nlattr **)cda, ct);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 
 	return ret;
 }
@@ -2709,13 +2709,13 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		}
 
 		/* after list removal, usage count == 1 */
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		if (del_timer(&exp->timeout)) {
 			nf_ct_unlink_expect_report(exp, NETLINK_CB(skb).portid,
 						   nlmsg_report(nlh));
 			nf_ct_expect_put(exp);
 		}
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 		/* have to put what we 'get' above.
 		 * after this line usage count == 0 */
 		nf_ct_expect_put(exp);
@@ -2724,7 +2724,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		struct nf_conn_help *m_help;
 
 		/* delete all expectations for this helper */
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, next,
 						  &net->ct.expect_hash[i],
@@ -2739,10 +2739,10 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 				}
 			}
 		}
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 	} else {
 		/* This basically means we have to flush everything*/
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, next,
 						  &net->ct.expect_hash[i],
@@ -2755,7 +2755,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 				}
 			}
 		}
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 	}
 
 	return 0;
@@ -2981,11 +2981,11 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	exp = __nf_ct_expect_find(net, zone, &tuple);
 
 	if (!exp) {
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
 			err = ctnetlink_create_expect(net, zone, cda,
@@ -2999,7 +2999,7 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 	err = -EEXIST;
 	if (!(nlh->nlmsg_flags & NLM_F_EXCL))
 		err = ctnetlink_change_expect(exp, cda);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 
 	return err;
 }
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 466410e..4c3ba1c 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -800,7 +800,7 @@ static int refresh_signalling_expectation(struct nf_conn *ct,
 	struct hlist_node *next;
 	int found = 0;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	hlist_for_each_entry_safe(exp, next, &help->expectations, lnode) {
 		if (exp->class != SIP_EXPECT_SIGNALLING ||
 		    !nf_inet_addr_cmp(&exp->tuple.dst.u3, addr) ||
@@ -815,7 +815,7 @@ static int refresh_signalling_expectation(struct nf_conn *ct,
 		found = 1;
 		break;
 	}
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 	return found;
 }
 
@@ -825,7 +825,7 @@ static void flush_expectations(struct nf_conn *ct, bool media)
 	struct nf_conntrack_expect *exp;
 	struct hlist_node *next;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	hlist_for_each_entry_safe(exp, next, &help->expectations, lnode) {
 		if ((exp->class != SIP_EXPECT_SIGNALLING) ^ media)
 			continue;
@@ -836,7 +836,7 @@ static void flush_expectations(struct nf_conn *ct, bool media)
 		if (!media)
 			break;
 	}
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 
 static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
-- 
1.7.10.4
