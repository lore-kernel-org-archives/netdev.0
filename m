From: pablo@netfilter.org
Subject: [PATCH 09/19] netfilter: rework user-space expectation helper support
Date: Sun, 25 Dec 2011 02:57:25 +0100
Message-ID: <1324778255-2830-10-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55999 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758021Ab1LYB6E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:58:04 -0500
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This partially reworks bc01befdcf3e40979eb518085a075cbf0aacede0
which added userspace expectation support.

This patch removes the nf_ct_userspace_expect_list since now we
force to use the new iptables CT target feature to add the helper
extension for conntracks that have attached expectations from
userspace.

A new version of the proof-of-concept code to implement userspace
helpers from userspace is available at:

http://people.netfilter.org/pablo/userspace-conntrack-helpers/nf-ftp-helper-POC.tar.bz2

This patch also modifies the CT target to allow to set the
conntrack's userspace helper status flags. This flag is used
to tell the conntrack system to explicitly allocate the helper
extension.

This helper extension is useful to link the userspace expectations
with the master conntrack that is being tracked from one userspace
helper.

This feature fixes a problem in the current approach of the
userspace helper support. Basically, if the master conntrack that
has got a userspace expectation vanishes, the expectations point to
one invalid memory address. Thus, triggering an oops in the
expectation deletion event path.

I decided not to add a new revision of the CT target because
I only needed to add a new flag for it. I'll document in this
issue in the iptables manpage. I have also changed the return
value from EINVAL to EOPNOTSUPP if one flag not supported is
specified. Thus, in the future adding new features that only
require a new flag can be added without a new revision.

There is no official code using this in userspace (apart from
the proof-of-concept) that uses this infrastructure but there
will be some by beginning 2012.

Reported-by: Sam Roberts <vieuxtech@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_common.h |    4 ++
 include/linux/netfilter/xt_CT.h               |    3 +-
 include/net/netfilter/nf_conntrack_expect.h   |    1 -
 net/netfilter/nf_conntrack_expect.c           |   63 ++++++++----------------
 net/netfilter/nf_conntrack_helper.c           |   12 +++++
 net/netfilter/nf_conntrack_netlink.c          |    5 ++-
 net/netfilter/xt_CT.c                         |    8 ++-
 7 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index 0d3dd66..9e3a283 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -83,6 +83,10 @@ enum ip_conntrack_status {
 	/* Conntrack is a fake untracked entry */
 	IPS_UNTRACKED_BIT = 12,
 	IPS_UNTRACKED = (1 << IPS_UNTRACKED_BIT),
+
+	/* Conntrack has a userspace helper. */
+	IPS_USERSPACE_HELPER_BIT = 13,
+	IPS_USERSPACE_HELPER = (1 << IPS_USERSPACE_HELPER_BIT),
 };
 
 /* Connection tracking event types */
diff --git a/include/linux/netfilter/xt_CT.h b/include/linux/netfilter/xt_CT.h
index b56e768..6390f09 100644
--- a/include/linux/netfilter/xt_CT.h
+++ b/include/linux/netfilter/xt_CT.h
@@ -3,7 +3,8 @@
 
 #include <linux/types.h>
 
-#define XT_CT_NOTRACK	0x1
+#define XT_CT_NOTRACK		0x1
+#define XT_CT_USERSPACE_HELPER	0x2
 
 struct xt_ct_target_info {
 	__u16 flags;
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 0f8a8c5..4619caa 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -91,7 +91,6 @@ static inline void nf_ct_unlink_expect(struct nf_conntrack_expect *exp)
 
 void nf_ct_remove_expectations(struct nf_conn *ct);
 void nf_ct_unexpect_related(struct nf_conntrack_expect *exp);
-void nf_ct_remove_userspace_expectations(void);
 
 /* Allocate space for an expectation: this is mandatory before calling
    nf_ct_expect_related.  You will have to call put afterwards. */
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 340c80d..bebb167 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -38,8 +38,6 @@ unsigned int nf_ct_expect_max __read_mostly;
 
 static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
 
-static HLIST_HEAD(nf_ct_userspace_expect_list);
-
 /* nf_conntrack_expect helper functions */
 void nf_ct_unlink_expect_report(struct nf_conntrack_expect *exp,
 				u32 pid, int report)
@@ -47,14 +45,14 @@ void nf_ct_unlink_expect_report(struct nf_conntrack_expect *exp,
 	struct nf_conn_help *master_help = nfct_help(exp->master);
 	struct net *net = nf_ct_exp_net(exp);
 
+	NF_CT_ASSERT(master_help);
 	NF_CT_ASSERT(!timer_pending(&exp->timeout));
 
 	hlist_del_rcu(&exp->hnode);
 	net->ct.expect_count--;
 
 	hlist_del(&exp->lnode);
-	if (!(exp->flags & NF_CT_EXPECT_USERSPACE))
-		master_help->expecting[exp->class]--;
+	master_help->expecting[exp->class]--;
 
 	nf_ct_expect_event_report(IPEXP_DESTROY, exp, pid, report);
 	nf_ct_expect_put(exp);
@@ -314,37 +312,34 @@ void nf_ct_expect_put(struct nf_conntrack_expect *exp)
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_put);
 
-static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
+static int nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 {
 	struct nf_conn_help *master_help = nfct_help(exp->master);
+	struct nf_conntrack_helper *helper;
 	struct net *net = nf_ct_exp_net(exp);
-	const struct nf_conntrack_expect_policy *p;
 	unsigned int h = nf_ct_expect_dst_hash(&exp->tuple);
 
 	/* two references : one for hash insert, one for the timer */
 	atomic_add(2, &exp->use);
 
-	if (master_help) {
-		hlist_add_head(&exp->lnode, &master_help->expectations);
-		master_help->expecting[exp->class]++;
-	} else if (exp->flags & NF_CT_EXPECT_USERSPACE)
-		hlist_add_head(&exp->lnode, &nf_ct_userspace_expect_list);
+	hlist_add_head(&exp->lnode, &master_help->expectations);
+	master_help->expecting[exp->class]++;
 
 	hlist_add_head_rcu(&exp->hnode, &net->ct.expect_hash[h]);
 	net->ct.expect_count++;
 
 	setup_timer(&exp->timeout, nf_ct_expectation_timed_out,
 		    (unsigned long)exp);
-	if (master_help) {
-		p = &rcu_dereference_protected(
-				master_help->helper,
-				lockdep_is_held(&nf_conntrack_lock)
-				)->expect_policy[exp->class];
-		exp->timeout.expires = jiffies + p->timeout * HZ;
+	helper = rcu_dereference_protected(master_help->helper,
+					   lockdep_is_held(&nf_conntrack_lock));
+	if (helper) {
+		exp->timeout.expires = jiffies +
+			helper->expect_policy[exp->class].timeout * HZ;
 	}
 	add_timer(&exp->timeout);
 
 	NF_CT_STAT_INC(net, expect_create);
+	return 0;
 }
 
 /* Race with expectations being used means we could have none to find; OK. */
@@ -389,14 +384,13 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 	struct nf_conntrack_expect *i;
 	struct nf_conn *master = expect->master;
 	struct nf_conn_help *master_help = nfct_help(master);
+	struct nf_conntrack_helper *helper;
 	struct net *net = nf_ct_exp_net(expect);
 	struct hlist_node *n;
 	unsigned int h;
 	int ret = 1;
 
-	/* Don't allow expectations created from kernel-space with no helper */
-	if (!(expect->flags & NF_CT_EXPECT_USERSPACE) &&
-	    (!master_help || (master_help && !master_help->helper))) {
+	if (!master_help) {
 		ret = -ESHUTDOWN;
 		goto out;
 	}
@@ -414,11 +408,10 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 		}
 	}
 	/* Will be over limit? */
-	if (master_help) {
-		p = &rcu_dereference_protected(
-			master_help->helper,
-			lockdep_is_held(&nf_conntrack_lock)
-			)->expect_policy[expect->class];
+	helper = rcu_dereference_protected(master_help->helper,
+					   lockdep_is_held(&nf_conntrack_lock));
+	if (helper) {
+		p = &helper->expect_policy[expect->class];
 		if (p->max_expected &&
 		    master_help->expecting[expect->class] >= p->max_expected) {
 			evict_oldest_expect(master, expect);
@@ -450,8 +443,9 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 	if (ret <= 0)
 		goto out;
 
-	ret = 0;
-	nf_ct_expect_insert(expect);
+	ret = nf_ct_expect_insert(expect);
+	if (ret < 0)
+		goto out;
 	spin_unlock_bh(&nf_conntrack_lock);
 	nf_ct_expect_event_report(IPEXP_NEW, expect, pid, report);
 	return ret;
@@ -461,21 +455,6 @@ out:
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_related_report);
 
-void nf_ct_remove_userspace_expectations(void)
-{
-	struct nf_conntrack_expect *exp;
-	struct hlist_node *n, *next;
-
-	hlist_for_each_entry_safe(exp, n, next,
-				  &nf_ct_userspace_expect_list, lnode) {
-		if (del_timer(&exp->timeout)) {
-			nf_ct_unlink_expect(exp);
-			nf_ct_expect_put(exp);
-		}
-	}
-}
-EXPORT_SYMBOL_GPL(nf_ct_remove_userspace_expectations);
-
 #ifdef CONFIG_PROC_FS
 struct ct_expect_iter_state {
 	struct seq_net_private p;
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 93c4bdb..c9e0de0 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -121,6 +121,18 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 	int ret = 0;
 
 	if (tmpl != NULL) {
+		/* we've got a userspace helper. */
+		if (tmpl->status & IPS_USERSPACE_HELPER) {
+			help = nf_ct_helper_ext_add(ct, flags);
+			if (help == NULL) {
+				ret = -ENOMEM;
+				goto out;
+			}
+			rcu_assign_pointer(help->helper, NULL);
+			__set_bit(IPS_USERSPACE_HELPER_BIT, &ct->status);
+			ret = 0;
+			goto out;
+		}
 		help = nfct_help(tmpl);
 		if (help != NULL)
 			helper = help->helper;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 636617c..7395480 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2040,6 +2040,10 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	}
 	help = nfct_help(ct);
 	if (!help) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+	if (test_bit(IPS_USERSPACE_HELPER_BIT, &ct->status)) {
 		if (!cda[CTA_EXPECT_TIMEOUT]) {
 			err = -EINVAL;
 			goto out;
@@ -2264,7 +2268,6 @@ static void __exit ctnetlink_exit(void)
 {
 	pr_info("ctnetlink: unregistering from nfnetlink.\n");
 
-	nf_ct_remove_userspace_expectations();
 	unregister_pernet_subsys(&ctnetlink_net_ops);
 	nfnetlink_subsys_unregister(&ctnl_exp_subsys);
 	nfnetlink_subsys_unregister(&ctnl_subsys);
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 0221d10..8e87123 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -62,8 +62,8 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 	int ret = 0;
 	u8 proto;
 
-	if (info->flags & ~XT_CT_NOTRACK)
-		return -EINVAL;
+	if (info->flags & ~(XT_CT_NOTRACK | XT_CT_USERSPACE_HELPER))
+		return -EOPNOTSUPP;
 
 	if (info->flags & XT_CT_NOTRACK) {
 		ct = nf_ct_untracked_get();
@@ -92,7 +92,9 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 				  GFP_KERNEL))
 		goto err3;
 
-	if (info->helper[0]) {
+	if (info->flags & XT_CT_USERSPACE_HELPER) {
+		__set_bit(IPS_USERSPACE_HELPER_BIT, &ct->status);
+	} else if (info->helper[0]) {
 		ret = -ENOENT;
 		proto = xt_ct_find_proto(par);
 		if (!proto) {
-- 
1.7.2.5
