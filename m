From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 17/29: ctnetlink: deliver events for conntracks changed from userspace
Date: Thu, 27 Nov 2008 17:15:26 +0100 (MET)
Message-ID: <20081127161526.13891.32280.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53376 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbYK0QP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:27 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 19abb7b090a6bce88d4e9b2914a0367f4f684432
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Nov 18 11:56:20 2008 +0100

    netfilter: ctnetlink: deliver events for conntracks changed from userspace
    
    As for now, the creation and update of conntracks via ctnetlink do not
    propagate an event to userspace. This can result in inconsistent situations
    if several userspace processes modify the connection tracking table by means
    of ctnetlink at the same time. Specifically, using the conntrack command
    line tool and conntrackd at the same time can trigger unconsistencies.
    
    This patch also modifies the event cache infrastructure to pass the
    process PID and the ECHO flag to nfnetlink_send() to report back
    to userspace if the process that triggered the change needs so.
    Based on a suggestion from Patrick McHardy.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index f11255e..2e0c536 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -199,7 +199,7 @@ __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple);
 
 extern void nf_conntrack_hash_insert(struct nf_conn *ct);
 
-extern void nf_conntrack_flush(struct net *net);
+extern void nf_conntrack_flush(struct net *net, u32 pid, int report);
 
 extern bool nf_ct_get_tuplepr(const struct sk_buff *skb,
 			      unsigned int nhoff, u_int16_t l3num,
diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 1285ff2..0ff0dc6 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -17,6 +17,13 @@ struct nf_conntrack_ecache {
 	unsigned int events;
 };
 
+/* This structure is passed to event handler */
+struct nf_ct_event {
+	struct nf_conn *ct;
+	u32 pid;
+	int report;
+};
+
 extern struct atomic_notifier_head nf_conntrack_chain;
 extern int nf_conntrack_register_notifier(struct notifier_block *nb);
 extern int nf_conntrack_unregister_notifier(struct notifier_block *nb);
@@ -39,22 +46,56 @@ nf_conntrack_event_cache(enum ip_conntrack_events event, struct nf_conn *ct)
 	local_bh_enable();
 }
 
-static inline void nf_conntrack_event(enum ip_conntrack_events event,
-				      struct nf_conn *ct)
+static inline void
+nf_conntrack_event_report(enum ip_conntrack_events event,
+			  struct nf_conn *ct,
+			  u32 pid,
+			  int report)
 {
+	struct nf_ct_event item = {
+		.ct 	= ct,
+		.pid	= pid,
+		.report = report
+	};
 	if (nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct))
-		atomic_notifier_call_chain(&nf_conntrack_chain, event, ct);
+		atomic_notifier_call_chain(&nf_conntrack_chain, event, &item);
 }
 
+static inline void
+nf_conntrack_event(enum ip_conntrack_events event, struct nf_conn *ct)
+{
+	nf_conntrack_event_report(event, ct, 0, 0);
+}
+
+struct nf_exp_event {
+	struct nf_conntrack_expect *exp;
+	u32 pid;
+	int report;
+};
+
 extern struct atomic_notifier_head nf_ct_expect_chain;
 extern int nf_ct_expect_register_notifier(struct notifier_block *nb);
 extern int nf_ct_expect_unregister_notifier(struct notifier_block *nb);
 
 static inline void
+nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
+			  struct nf_conntrack_expect *exp,
+			  u32 pid,
+			  int report)
+{
+	struct nf_exp_event item = {
+		.exp	= exp,
+		.pid	= pid,
+		.report = report
+	};
+	atomic_notifier_call_chain(&nf_ct_expect_chain, event, &item);
+}
+
+static inline void
 nf_ct_expect_event(enum ip_conntrack_expect_events event,
 		   struct nf_conntrack_expect *exp)
 {
-	atomic_notifier_call_chain(&nf_ct_expect_chain, event, exp);
+	nf_ct_expect_event_report(event, exp, 0, 0);
 }
 
 extern int nf_conntrack_ecache_init(struct net *net);
@@ -66,9 +107,17 @@ static inline void nf_conntrack_event_cache(enum ip_conntrack_events event,
 					    struct nf_conn *ct) {}
 static inline void nf_conntrack_event(enum ip_conntrack_events event,
 				      struct nf_conn *ct) {}
+static inline void nf_conntrack_event_report(enum ip_conntrack_events event,
+					     struct nf_conn *ct,
+					     u32 pid,
+					     int report) {}
 static inline void nf_ct_deliver_cached_events(const struct nf_conn *ct) {}
 static inline void nf_ct_expect_event(enum ip_conntrack_expect_events event,
 				      struct nf_conntrack_expect *exp) {}
+static inline void nf_ct_expect_event_report(enum ip_conntrack_expect_events e,
+					     struct nf_conntrack_expect *exp,
+ 					     u32 pid,
+ 					     int report) {}
 static inline void nf_ct_event_cache_flush(struct net *net) {}
 
 static inline int nf_conntrack_ecache_init(struct net *net)
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 37a7fc1..ab17a15 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -100,6 +100,8 @@ void nf_ct_expect_init(struct nf_conntrack_expect *, unsigned int, u_int8_t,
 		       u_int8_t, const __be16 *, const __be16 *);
 void nf_ct_expect_put(struct nf_conntrack_expect *exp);
 int nf_ct_expect_related(struct nf_conntrack_expect *expect);
+int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
+				u32 pid, int report);
 
 #endif /*_NF_CONNTRACK_EXPECT_H*/
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 1e649fb..dc3fea0 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -181,7 +181,8 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	NF_CT_ASSERT(atomic_read(&nfct->use) == 0);
 	NF_CT_ASSERT(!timer_pending(&ct->timeout));
 
-	nf_conntrack_event(IPCT_DESTROY, ct);
+	if (!test_bit(IPS_DYING_BIT, &ct->status))
+		nf_conntrack_event(IPCT_DESTROY, ct);
 	set_bit(IPS_DYING_BIT, &ct->status);
 
 	/* To make sure we don't get any weird locking issues here:
@@ -972,8 +973,20 @@ void nf_ct_iterate_cleanup(struct net *net,
 }
 EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup);
 
+struct __nf_ct_flush_report {
+	u32 pid;
+	int report;
+};
+
 static int kill_all(struct nf_conn *i, void *data)
 {
+	struct __nf_ct_flush_report *fr = (struct __nf_ct_flush_report *)data;
+
+	/* get_next_corpse sets the dying bit for us */
+	nf_conntrack_event_report(IPCT_DESTROY,
+				  i,
+				  fr->pid,
+				  fr->report);
 	return 1;
 }
 
@@ -987,9 +1000,13 @@ void nf_ct_free_hashtable(struct hlist_head *hash, int vmalloced, unsigned int s
 }
 EXPORT_SYMBOL_GPL(nf_ct_free_hashtable);
 
-void nf_conntrack_flush(struct net *net)
+void nf_conntrack_flush(struct net *net, u32 pid, int report)
 {
-	nf_ct_iterate_cleanup(net, kill_all, NULL);
+	struct __nf_ct_flush_report fr = {
+		.pid 	= pid,
+		.report = report,
+	};
+	nf_ct_iterate_cleanup(net, kill_all, &fr);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_flush);
 
@@ -1005,7 +1022,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	nf_ct_event_cache_flush(net);
 	nf_conntrack_ecache_fini(net);
  i_see_dead_people:
-	nf_conntrack_flush(net);
+	nf_conntrack_flush(net, 0, 0);
 	if (atomic_read(&net->ct.count) != 0) {
 		schedule();
 		goto i_see_dead_people;
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index a5f5e2e..dee4190 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -35,9 +35,17 @@ static inline void
 __nf_ct_deliver_cached_events(struct nf_conntrack_ecache *ecache)
 {
 	if (nf_ct_is_confirmed(ecache->ct) && !nf_ct_is_dying(ecache->ct)
-	    && ecache->events)
-		atomic_notifier_call_chain(&nf_conntrack_chain, ecache->events,
-				    ecache->ct);
+	    && ecache->events) {
+		struct nf_ct_event item = {
+			.ct 	= ecache->ct,
+			.pid	= 0,
+			.report	= 0
+		};
+
+		atomic_notifier_call_chain(&nf_conntrack_chain,
+					   ecache->events,
+					   &item);
+	}
 
 	ecache->events = 0;
 	nf_ct_put(ecache->ct);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 37a703b..3a8a34a 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -362,7 +362,7 @@ static inline int refresh_timer(struct nf_conntrack_expect *i)
 	return 1;
 }
 
-int nf_ct_expect_related(struct nf_conntrack_expect *expect)
+static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 {
 	const struct nf_conntrack_expect_policy *p;
 	struct nf_conntrack_expect *i;
@@ -371,11 +371,8 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
 	struct net *net = nf_ct_exp_net(expect);
 	struct hlist_node *n;
 	unsigned int h;
-	int ret;
-
-	NF_CT_ASSERT(master_help);
+	int ret = 0;
 
-	spin_lock_bh(&nf_conntrack_lock);
 	if (!master_help->helper) {
 		ret = -ESHUTDOWN;
 		goto out;
@@ -409,18 +406,50 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
 			printk(KERN_WARNING
 			       "nf_conntrack: expectation table full\n");
 		ret = -EMFILE;
-		goto out;
 	}
+out:
+	return ret;
+}
+
+int nf_ct_expect_related(struct nf_conntrack_expect *expect)
+{
+	int ret;
+
+	spin_lock_bh(&nf_conntrack_lock);
+	ret = __nf_ct_expect_check(expect);
+	if (ret < 0)
+		goto out;
 
 	nf_ct_expect_insert(expect);
+	atomic_inc(&expect->use);
+	spin_unlock_bh(&nf_conntrack_lock);
 	nf_ct_expect_event(IPEXP_NEW, expect);
-	ret = 0;
+	nf_ct_expect_put(expect);
+	return ret;
 out:
 	spin_unlock_bh(&nf_conntrack_lock);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_related);
 
+int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
+				u32 pid, int report)
+{
+	int ret;
+
+	spin_lock_bh(&nf_conntrack_lock);
+	ret = __nf_ct_expect_check(expect);
+	if (ret < 0)
+		goto out;
+	nf_ct_expect_insert(expect);
+out:
+	spin_unlock_bh(&nf_conntrack_lock);
+	if (ret == 0)
+		nf_ct_expect_event_report(IPEXP_NEW, expect, pid, report);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nf_ct_expect_related_report);
+
 #ifdef CONFIG_PROC_FS
 struct ct_expect_iter_state {
 	struct seq_net_private p;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4f6486c..ccc5ef1 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -410,7 +410,8 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	struct nlattr *nest_parms;
-	struct nf_conn *ct = (struct nf_conn *)ptr;
+	struct nf_ct_event *item = (struct nf_ct_event *)ptr;
+	struct nf_conn *ct = item->ct;
 	struct sk_buff *skb;
 	unsigned int type;
 	sk_buff_data_t b;
@@ -443,7 +444,7 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	b = skb->tail;
 
 	type |= NFNL_SUBSYS_CTNETLINK << 8;
-	nlh   = NLMSG_PUT(skb, 0, 0, type, sizeof(struct nfgenmsg));
+	nlh   = NLMSG_PUT(skb, item->pid, 0, type, sizeof(struct nfgenmsg));
 	nfmsg = NLMSG_DATA(nlh);
 
 	nlh->nlmsg_flags    = flags;
@@ -511,7 +512,7 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	rcu_read_unlock();
 
 	nlh->nlmsg_len = skb->tail - b;
-	nfnetlink_send(skb, 0, group, 0);
+	nfnetlink_send(skb, item->pid, group, item->report);
 	return NOTIFY_DONE;
 
 nla_put_failure:
@@ -722,7 +723,9 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY, u3);
 	else {
 		/* Flush the whole table */
-		nf_conntrack_flush(&init_net);
+		nf_conntrack_flush(&init_net,
+				   NETLINK_CB(skb).pid,
+				   nlmsg_report(nlh));
 		return 0;
 	}
 
@@ -743,6 +746,14 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		}
 	}
 
+	nf_conntrack_event_report(IPCT_DESTROY,
+				  ct,
+				  NETLINK_CB(skb).pid,
+				  nlmsg_report(nlh));
+
+	/* death_by_timeout would report the event again */
+	set_bit(IPS_DYING_BIT, &ct->status);
+
 	nf_ct_kill(ct);
 	nf_ct_put(ct);
 
@@ -1088,11 +1099,35 @@ ctnetlink_change_conntrack(struct nf_conn *ct, struct nlattr *cda[])
 	return 0;
 }
 
+static inline void
+ctnetlink_event_report(struct nf_conn *ct, u32 pid, int report)
+{
+	unsigned int events = 0;
+
+	if (test_bit(IPS_EXPECTED_BIT, &ct->status))
+		events |= IPCT_RELATED;
+	else
+		events |= IPCT_NEW;
+
+	nf_conntrack_event_report(IPCT_STATUS |
+				  IPCT_HELPER |
+				  IPCT_REFRESH |
+				  IPCT_PROTOINFO |
+				  IPCT_NATSEQADJ |
+				  IPCT_MARK |
+				  events,
+				  ct,
+				  pid,
+				  report);
+}
+
 static int
 ctnetlink_create_conntrack(struct nlattr *cda[],
 			   struct nf_conntrack_tuple *otuple,
 			   struct nf_conntrack_tuple *rtuple,
-			   struct nf_conn *master_ct)
+			   struct nf_conn *master_ct,
+			   u32 pid,
+			   int report)
 {
 	struct nf_conn *ct;
 	int err = -EINVAL;
@@ -1198,9 +1233,12 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 		ct->master = master_ct;
 	}
 
+	nf_conntrack_get(&ct->ct_general);
 	add_timer(&ct->timeout);
 	nf_conntrack_hash_insert(ct);
 	rcu_read_unlock();
+	ctnetlink_event_report(ct, pid, report);
+	nf_ct_put(ct);
 
 	return 0;
 
@@ -1265,7 +1303,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			err = ctnetlink_create_conntrack(cda,
 							 &otuple,
 							 &rtuple,
-							 master_ct);
+							 master_ct,
+							 NETLINK_CB(skb).pid,
+							 nlmsg_report(nlh));
 		if (err < 0 && master_ct)
 			nf_ct_put(master_ct);
 
@@ -1277,6 +1317,8 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	 * so there's no need to increase the refcount */
 	err = -EEXIST;
 	if (!(nlh->nlmsg_flags & NLM_F_EXCL)) {
+		struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
+
 		/* we only allow nat config for new conntracks */
 		if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
 			err = -EOPNOTSUPP;
@@ -1287,8 +1329,19 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			err = -EOPNOTSUPP;
 			goto out_unlock;
 		}
-		err = ctnetlink_change_conntrack(nf_ct_tuplehash_to_ctrack(h),
-						 cda);
+
+		err = ctnetlink_change_conntrack(ct, cda);
+		if (err == 0) {
+			nf_conntrack_get(&ct->ct_general);
+			spin_unlock_bh(&nf_conntrack_lock);
+			ctnetlink_event_report(ct,
+					       NETLINK_CB(skb).pid,
+					       nlmsg_report(nlh));
+			nf_ct_put(ct);
+		} else
+			spin_unlock_bh(&nf_conntrack_lock);
+
+		return err;
 	}
 
 out_unlock:
@@ -1423,7 +1476,8 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	struct nf_conntrack_expect *exp = (struct nf_conntrack_expect *)ptr;
+	struct nf_exp_event *item = (struct nf_exp_event *)ptr;
+	struct nf_conntrack_expect *exp = item->exp;
 	struct sk_buff *skb;
 	unsigned int type;
 	sk_buff_data_t b;
@@ -1445,7 +1499,7 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 	b = skb->tail;
 
 	type |= NFNL_SUBSYS_CTNETLINK_EXP << 8;
-	nlh   = NLMSG_PUT(skb, 0, 0, type, sizeof(struct nfgenmsg));
+	nlh   = NLMSG_PUT(skb, item->pid, 0, type, sizeof(struct nfgenmsg));
 	nfmsg = NLMSG_DATA(nlh);
 
 	nlh->nlmsg_flags    = flags;
@@ -1459,7 +1513,7 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 	rcu_read_unlock();
 
 	nlh->nlmsg_len = skb->tail - b;
-	nfnetlink_send(skb, 0, NFNLGRP_CONNTRACK_EXP_NEW, 0);
+	nfnetlink_send(skb, item->pid, NFNLGRP_CONNTRACK_EXP_NEW, item->report);
 	return NOTIFY_DONE;
 
 nla_put_failure:
@@ -1673,7 +1727,7 @@ ctnetlink_change_expect(struct nf_conntrack_expect *x, struct nlattr *cda[])
 }
 
 static int
-ctnetlink_create_expect(struct nlattr *cda[], u_int8_t u3)
+ctnetlink_create_expect(struct nlattr *cda[], u_int8_t u3, u32 pid, int report)
 {
 	struct nf_conntrack_tuple tuple, mask, master_tuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
@@ -1720,7 +1774,7 @@ ctnetlink_create_expect(struct nlattr *cda[], u_int8_t u3)
 	memcpy(&exp->mask.src.u3, &mask.src.u3, sizeof(exp->mask.src.u3));
 	exp->mask.src.u.all = mask.src.u.all;
 
-	err = nf_ct_expect_related(exp);
+	err = nf_ct_expect_related_report(exp, pid, report);
 	nf_ct_expect_put(exp);
 
 out:
@@ -1753,8 +1807,12 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (!exp) {
 		spin_unlock_bh(&nf_conntrack_lock);
 		err = -ENOENT;
-		if (nlh->nlmsg_flags & NLM_F_CREATE)
-			err = ctnetlink_create_expect(cda, u3);
+		if (nlh->nlmsg_flags & NLM_F_CREATE) {
+			err = ctnetlink_create_expect(cda,
+						      u3,
+						      NETLINK_CB(skb).pid,
+						      nlmsg_report(nlh));
+		}
 		return err;
 	}
 
