From: kaber@trash.net
Subject: [PATCH 40/72] netfilter: ctnetlink: add expectation deletion events
Date: Thu, 21 Oct 2010 17:19:27 +0200
Message-ID: <1287674399-31455-41-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199Ab0JUPUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:10 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch allows to listen to events that inform about
expectations destroyed.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nf_conntrack_common.h |    1 +
 include/net/netfilter/nf_conntrack_expect.h   |    8 +++++-
 net/netfilter/nf_conntrack_expect.c           |    6 +++-
 net/netfilter/nf_conntrack_netlink.c          |   30 +++++++++++++++++-------
 4 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index 23a1a08..50cdc25 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -98,6 +98,7 @@ enum ip_conntrack_events {
 
 enum ip_conntrack_expect_events {
 	IPEXP_NEW,		/* new expectation */
+	IPEXP_DESTROY,		/* destroyed expectation */
 };
 
 /* expectation flags */
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 416b838..0f8a8c5 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -82,7 +82,13 @@ struct nf_conntrack_expect *
 nf_ct_find_expectation(struct net *net, u16 zone,
 		       const struct nf_conntrack_tuple *tuple);
 
-void nf_ct_unlink_expect(struct nf_conntrack_expect *exp);
+void nf_ct_unlink_expect_report(struct nf_conntrack_expect *exp,
+				u32 pid, int report);
+static inline void nf_ct_unlink_expect(struct nf_conntrack_expect *exp)
+{
+	nf_ct_unlink_expect_report(exp, 0, 0);
+}
+
 void nf_ct_remove_expectations(struct nf_conn *ct);
 void nf_ct_unexpect_related(struct nf_conntrack_expect *exp);
 void nf_ct_remove_userspace_expectations(void);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index b30a1f2..46e8966 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -41,7 +41,8 @@ static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
 static HLIST_HEAD(nf_ct_userspace_expect_list);
 
 /* nf_conntrack_expect helper functions */
-void nf_ct_unlink_expect(struct nf_conntrack_expect *exp)
+void nf_ct_unlink_expect_report(struct nf_conntrack_expect *exp,
+				u32 pid, int report)
 {
 	struct nf_conn_help *master_help = nfct_help(exp->master);
 	struct net *net = nf_ct_exp_net(exp);
@@ -55,11 +56,12 @@ void nf_ct_unlink_expect(struct nf_conntrack_expect *exp)
 	if (!(exp->flags & NF_CT_EXPECT_USERSPACE))
 		master_help->expecting[exp->class]--;
 
+	nf_ct_expect_event_report(IPEXP_DESTROY, exp, pid, report);
 	nf_ct_expect_put(exp);
 
 	NF_CT_STAT_INC(net, expect_delete);
 }
-EXPORT_SYMBOL_GPL(nf_ct_unlink_expect);
+EXPORT_SYMBOL_GPL(nf_ct_unlink_expect_report);
 
 static void nf_ct_expectation_timed_out(unsigned long ul_expect)
 {
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b4077be..62bad22 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1632,17 +1632,20 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	struct sk_buff *skb;
-	unsigned int type;
+	unsigned int type, group;
 	int flags = 0;
 
-	if (events & (1 << IPEXP_NEW)) {
+	if (events & (1 << IPEXP_DESTROY)) {
+		type = IPCTNL_MSG_EXP_DELETE;
+		group = NFNLGRP_CONNTRACK_EXP_DESTROY;
+	} else if (events & (1 << IPEXP_NEW)) {
 		type = IPCTNL_MSG_EXP_NEW;
 		flags = NLM_F_CREATE|NLM_F_EXCL;
+		group = NFNLGRP_CONNTRACK_EXP_NEW;
 	} else
 		return 0;
 
-	if (!item->report &&
-	    !nfnetlink_has_listeners(net, NFNLGRP_CONNTRACK_EXP_NEW))
+	if (!item->report && !nfnetlink_has_listeners(net, group))
 		return 0;
 
 	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
@@ -1665,8 +1668,7 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
-	nfnetlink_send(skb, net, item->pid, NFNLGRP_CONNTRACK_EXP_NEW,
-		       item->report, GFP_ATOMIC);
+	nfnetlink_send(skb, net, item->pid, group, item->report, GFP_ATOMIC);
 	return 0;
 
 nla_put_failure:
@@ -1849,7 +1851,13 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		}
 
 		/* after list removal, usage count == 1 */
-		nf_ct_unexpect_related(exp);
+		spin_lock_bh(&nf_conntrack_lock);
+		if (del_timer(&exp->timeout)) {
+			nf_ct_unlink_expect_report(exp, NETLINK_CB(skb).pid,
+						   nlmsg_report(nlh));
+			nf_ct_expect_put(exp);
+		}
+		spin_unlock_bh(&nf_conntrack_lock);
 		/* have to put what we 'get' above.
 		 * after this line usage count == 0 */
 		nf_ct_expect_put(exp);
@@ -1866,7 +1874,9 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 				m_help = nfct_help(exp->master);
 				if (!strcmp(m_help->helper->name, name) &&
 				    del_timer(&exp->timeout)) {
-					nf_ct_unlink_expect(exp);
+					nf_ct_unlink_expect_report(exp,
+							NETLINK_CB(skb).pid,
+							nlmsg_report(nlh));
 					nf_ct_expect_put(exp);
 				}
 			}
@@ -1880,7 +1890,9 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 						  &net->ct.expect_hash[i],
 						  hnode) {
 				if (del_timer(&exp->timeout)) {
-					nf_ct_unlink_expect(exp);
+					nf_ct_unlink_expect_report(exp,
+							NETLINK_CB(skb).pid,
+							nlmsg_report(nlh));
 					nf_ct_expect_put(exp);
 				}
 			}
-- 
1.7.1

