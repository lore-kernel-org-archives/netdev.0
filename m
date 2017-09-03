From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/47] netfilter: expect: add and use nf_ct_expect_iterate helpers
Date: Mon,  4 Sep 2017 00:25:50 +0200
Message-ID: <1504477589-12045-9-git-send-email-pablo@netfilter.org>
References: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50824 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753173AbdICW0p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:26:45 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 43995190F71
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 33D84B502E
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:18 +0200 (CEST)
In-Reply-To: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We have several spots that open-code a expect walk, add a helper
that is similar to nf_ct_iterate_destroy/nf_ct_iterate_cleanup.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_expect.h |  5 +++
 net/netfilter/nf_conntrack_expect.c         | 54 +++++++++++++++++++++++++
 net/netfilter/nf_conntrack_helper.c         | 34 +++++++---------
 net/netfilter/nf_conntrack_netlink.c        | 63 ++++++++++-------------------
 4 files changed, 95 insertions(+), 61 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 2ba54feaccd8..818def011110 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -107,6 +107,11 @@ void nf_ct_remove_expectations(struct nf_conn *ct);
 void nf_ct_unexpect_related(struct nf_conntrack_expect *exp);
 bool nf_ct_remove_expect(struct nf_conntrack_expect *exp);
 
+void nf_ct_expect_iterate_destroy(bool (*iter)(struct nf_conntrack_expect *e, void *data), void *data);
+void nf_ct_expect_iterate_net(struct net *net,
+			      bool (*iter)(struct nf_conntrack_expect *e, void *data),
+                              void *data, u32 portid, int report);
+
 /* Allocate space for an expectation: this is mandatory before calling
    nf_ct_expect_related.  You will have to call put afterwards. */
 struct nf_conntrack_expect *nf_ct_expect_alloc(struct nf_conn *me);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 2c63808bea96..dad2c0c22ad5 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -474,6 +474,60 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_related_report);
 
+void nf_ct_expect_iterate_destroy(bool (*iter)(struct nf_conntrack_expect *e, void *data),
+				  void *data)
+{
+	struct nf_conntrack_expect *exp;
+	const struct hlist_node *next;
+	unsigned int i;
+
+	spin_lock_bh(&nf_conntrack_expect_lock);
+
+	for (i = 0; i < nf_ct_expect_hsize; i++) {
+		hlist_for_each_entry_safe(exp, next,
+					  &nf_ct_expect_hash[i],
+					  hnode) {
+			if (iter(exp, data) && del_timer(&exp->timeout)) {
+				nf_ct_unlink_expect(exp);
+				nf_ct_expect_put(exp);
+			}
+		}
+	}
+
+	spin_unlock_bh(&nf_conntrack_expect_lock);
+}
+EXPORT_SYMBOL_GPL(nf_ct_expect_iterate_destroy);
+
+void nf_ct_expect_iterate_net(struct net *net,
+			      bool (*iter)(struct nf_conntrack_expect *e, void *data),
+			      void *data,
+			      u32 portid, int report)
+{
+	struct nf_conntrack_expect *exp;
+	const struct hlist_node *next;
+	unsigned int i;
+
+	spin_lock_bh(&nf_conntrack_expect_lock);
+
+	for (i = 0; i < nf_ct_expect_hsize; i++) {
+		hlist_for_each_entry_safe(exp, next,
+					  &nf_ct_expect_hash[i],
+					  hnode) {
+
+			if (!net_eq(nf_ct_exp_net(exp), net))
+				continue;
+
+			if (iter(exp, data) && del_timer(&exp->timeout)) {
+				nf_ct_unlink_expect_report(exp, portid, report);
+				nf_ct_expect_put(exp);
+			}
+		}
+	}
+
+	spin_unlock_bh(&nf_conntrack_expect_lock);
+}
+EXPORT_SYMBOL_GPL(nf_ct_expect_iterate_net);
+
 #ifdef CONFIG_NF_CONNTRACK_PROCFS
 struct ct_expect_iter_state {
 	struct seq_net_private p;
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 9129bb3b5153..551a1eddf0fa 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -437,12 +437,22 @@ int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_register);
 
-void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
+static bool expect_iter_me(struct nf_conntrack_expect *exp, void *data)
 {
-	struct nf_conntrack_expect *exp;
-	const struct hlist_node *next;
-	unsigned int i;
+	struct nf_conn_help *help = nfct_help(exp->master);
+	const struct nf_conntrack_helper *me = data;
+	const struct nf_conntrack_helper *this;
+
+	if (exp->helper == me)
+		return true;
 
+	this = rcu_dereference_protected(help->helper,
+					 lockdep_is_held(&nf_conntrack_expect_lock));
+	return this == me;
+}
+
+void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
+{
 	mutex_lock(&nf_ct_helper_mutex);
 	hlist_del_rcu(&me->hnode);
 	nf_ct_helper_count--;
@@ -453,21 +463,7 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	 */
 	synchronize_rcu();
 
-	/* Get rid of expectations */
-	spin_lock_bh(&nf_conntrack_expect_lock);
-	for (i = 0; i < nf_ct_expect_hsize; i++) {
-		hlist_for_each_entry_safe(exp, next,
-					  &nf_ct_expect_hash[i], hnode) {
-			struct nf_conn_help *help = nfct_help(exp->master);
-			if ((rcu_dereference_protected(
-					help->helper,
-					lockdep_is_held(&nf_conntrack_expect_lock)
-					) == me || exp->helper == me))
-				nf_ct_remove_expect(exp);
-		}
-	}
-	spin_unlock_bh(&nf_conntrack_expect_lock);
-
+	nf_ct_expect_iterate_destroy(expect_iter_me, NULL);
 	nf_ct_iterate_destroy(unhelp, me);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_unregister);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4dba71de4de7..4922c8aefb2a 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2898,6 +2898,21 @@ static int ctnetlink_get_expect(struct net *net, struct sock *ctnl,
 	return err == -EAGAIN ? -ENOBUFS : err;
 }
 
+static bool expect_iter_name(struct nf_conntrack_expect *exp, void *data)
+{
+	const struct nf_conn_help *m_help;
+	const char *name = data;
+
+	m_help = nfct_help(exp->master);
+
+	return strcmp(m_help->helper->name, name) == 0;
+}
+
+static bool expect_iter_all(struct nf_conntrack_expect *exp, void *data)
+{
+	return true;
+}
+
 static int ctnetlink_del_expect(struct net *net, struct sock *ctnl,
 				struct sk_buff *skb, const struct nlmsghdr *nlh,
 				const struct nlattr * const cda[],
@@ -2906,10 +2921,8 @@ static int ctnetlink_del_expect(struct net *net, struct sock *ctnl,
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple tuple;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
-	struct hlist_node *next;
 	u_int8_t u3 = nfmsg->nfgen_family;
 	struct nf_conntrack_zone zone;
-	unsigned int i;
 	int err;
 
 	if (cda[CTA_EXPECT_TUPLE]) {
@@ -2949,49 +2962,15 @@ static int ctnetlink_del_expect(struct net *net, struct sock *ctnl,
 		nf_ct_expect_put(exp);
 	} else if (cda[CTA_EXPECT_HELP_NAME]) {
 		char *name = nla_data(cda[CTA_EXPECT_HELP_NAME]);
-		struct nf_conn_help *m_help;
 
-		/* delete all expectations for this helper */
-		spin_lock_bh(&nf_conntrack_expect_lock);
-		for (i = 0; i < nf_ct_expect_hsize; i++) {
-			hlist_for_each_entry_safe(exp, next,
-						  &nf_ct_expect_hash[i],
-						  hnode) {
-
-				if (!net_eq(nf_ct_exp_net(exp), net))
-					continue;
-
-				m_help = nfct_help(exp->master);
-				if (!strcmp(m_help->helper->name, name) &&
-				    del_timer(&exp->timeout)) {
-					nf_ct_unlink_expect_report(exp,
-							NETLINK_CB(skb).portid,
-							nlmsg_report(nlh));
-					nf_ct_expect_put(exp);
-				}
-			}
-		}
-		spin_unlock_bh(&nf_conntrack_expect_lock);
+		nf_ct_expect_iterate_net(net, expect_iter_name, name,
+					 NETLINK_CB(skb).portid,
+					 nlmsg_report(nlh));
 	} else {
 		/* This basically means we have to flush everything*/
-		spin_lock_bh(&nf_conntrack_expect_lock);
-		for (i = 0; i < nf_ct_expect_hsize; i++) {
-			hlist_for_each_entry_safe(exp, next,
-						  &nf_ct_expect_hash[i],
-						  hnode) {
-
-				if (!net_eq(nf_ct_exp_net(exp), net))
-					continue;
-
-				if (del_timer(&exp->timeout)) {
-					nf_ct_unlink_expect_report(exp,
-							NETLINK_CB(skb).portid,
-							nlmsg_report(nlh));
-					nf_ct_expect_put(exp);
-				}
-			}
-		}
-		spin_unlock_bh(&nf_conntrack_expect_lock);
+		nf_ct_expect_iterate_net(net, expect_iter_all, NULL,
+					 NETLINK_CB(skb).portid,
+					 nlmsg_report(nlh));
 	}
 
 	return 0;
-- 
2.1.4
