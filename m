From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 13/14] netfilter: rename netlink related "pid" variables to "portid"
Date: Wed, 17 Apr 2013 18:47:08 +0200
Message-ID: <1366217229-22705-14-git-send-email-kaber@trash.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60970 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936249Ab3DQQrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:47:35 -0400
In-Reply-To: <1366217229-22705-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of the confusing mix of pid and portid and use portid consistently
for all netlink related socket identities.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink.h         |  9 +++++----
 include/net/netfilter/nf_conntrack.h        |  2 +-
 include/net/netfilter/nf_conntrack_expect.h |  4 ++--
 net/netfilter/nf_conntrack_core.c           |  8 ++++----
 net/netfilter/nf_conntrack_expect.c         |  8 ++++----
 net/netfilter/nfnetlink.c                   | 13 +++++++------
 6 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index ecbb8e4..60b1641 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -29,10 +29,11 @@ extern int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
 extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 
 extern int nfnetlink_has_listeners(struct net *net, unsigned int group);
-extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned int group,
-			  int echo, gfp_t flags);
-extern int nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error);
-extern int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u_int32_t pid, int flags);
+extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
+			  unsigned int group, int echo, gfp_t flags);
+extern int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error);
+extern int nfnetlink_unicast(struct sk_buff *skb, struct net *net,
+			     u32 portid, int flags);
 
 extern void nfnl_lock(__u8 subsys_id);
 extern void nfnl_unlock(__u8 subsys_id);
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index caca0c4..644d9c2 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -184,7 +184,7 @@ extern int nf_conntrack_hash_check_insert(struct nf_conn *ct);
 extern void nf_ct_delete_from_lists(struct nf_conn *ct);
 extern void nf_ct_dying_timeout(struct nf_conn *ct);
 
-extern void nf_conntrack_flush_report(struct net *net, u32 pid, int report);
+extern void nf_conntrack_flush_report(struct net *net, u32 portid, int report);
 
 extern bool nf_ct_get_tuplepr(const struct sk_buff *skb,
 			      unsigned int nhoff, u_int16_t l3num,
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index cbbae76..3f3aecb 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -88,7 +88,7 @@ nf_ct_find_expectation(struct net *net, u16 zone,
 		       const struct nf_conntrack_tuple *tuple);
 
 void nf_ct_unlink_expect_report(struct nf_conntrack_expect *exp,
-				u32 pid, int report);
+				u32 portid, int report);
 static inline void nf_ct_unlink_expect(struct nf_conntrack_expect *exp)
 {
 	nf_ct_unlink_expect_report(exp, 0, 0);
@@ -106,7 +106,7 @@ void nf_ct_expect_init(struct nf_conntrack_expect *, unsigned int, u_int8_t,
 		       u_int8_t, const __be16 *, const __be16 *);
 void nf_ct_expect_put(struct nf_conntrack_expect *exp);
 int nf_ct_expect_related_report(struct nf_conntrack_expect *expect, 
-				u32 pid, int report);
+				u32 portid, int report);
 static inline int nf_ct_expect_related(struct nf_conntrack_expect *expect)
 {
 	return nf_ct_expect_related_report(expect, 0, 0);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 007e8c4..54ddc2f 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1260,7 +1260,7 @@ void nf_ct_iterate_cleanup(struct net *net,
 EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup);
 
 struct __nf_ct_flush_report {
-	u32 pid;
+	u32 portid;
 	int report;
 };
 
@@ -1275,7 +1275,7 @@ static int kill_report(struct nf_conn *i, void *data)
 
 	/* If we fail to deliver the event, death_by_timeout() will retry */
 	if (nf_conntrack_event_report(IPCT_DESTROY, i,
-				      fr->pid, fr->report) < 0)
+				      fr->portid, fr->report) < 0)
 		return 1;
 
 	/* Avoid the delivery of the destroy event in death_by_timeout(). */
@@ -1298,10 +1298,10 @@ void nf_ct_free_hashtable(void *hash, unsigned int size)
 }
 EXPORT_SYMBOL_GPL(nf_ct_free_hashtable);
 
-void nf_conntrack_flush_report(struct net *net, u32 pid, int report)
+void nf_conntrack_flush_report(struct net *net, u32 portid, int report)
 {
 	struct __nf_ct_flush_report fr = {
-		.pid 	= pid,
+		.portid	= portid,
 		.report = report,
 	};
 	nf_ct_iterate_cleanup(net, kill_report, &fr);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 8c10e3d..0adfdcc 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -40,7 +40,7 @@ static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
 
 /* nf_conntrack_expect helper functions */
 void nf_ct_unlink_expect_report(struct nf_conntrack_expect *exp,
-				u32 pid, int report)
+				u32 portid, int report)
 {
 	struct nf_conn_help *master_help = nfct_help(exp->master);
 	struct net *net = nf_ct_exp_net(exp);
@@ -54,7 +54,7 @@ void nf_ct_unlink_expect_report(struct nf_conntrack_expect *exp,
 	hlist_del(&exp->lnode);
 	master_help->expecting[exp->class]--;
 
-	nf_ct_expect_event_report(IPEXP_DESTROY, exp, pid, report);
+	nf_ct_expect_event_report(IPEXP_DESTROY, exp, portid, report);
 	nf_ct_expect_put(exp);
 
 	NF_CT_STAT_INC(net, expect_delete);
@@ -412,7 +412,7 @@ out:
 }
 
 int nf_ct_expect_related_report(struct nf_conntrack_expect *expect, 
-				u32 pid, int report)
+				u32 portid, int report)
 {
 	int ret;
 
@@ -425,7 +425,7 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 	if (ret < 0)
 		goto out;
 	spin_unlock_bh(&nf_conntrack_lock);
-	nf_ct_expect_event_report(IPEXP_NEW, expect, pid, report);
+	nf_ct_expect_event_report(IPEXP_NEW, expect, portid, report);
 	return ret;
 out:
 	spin_unlock_bh(&nf_conntrack_lock);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index bc4c499..1640bd7 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -112,22 +112,23 @@ int nfnetlink_has_listeners(struct net *net, unsigned int group)
 }
 EXPORT_SYMBOL_GPL(nfnetlink_has_listeners);
 
-int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid,
+int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
 		   unsigned int group, int echo, gfp_t flags)
 {
-	return nlmsg_notify(net->nfnl, skb, pid, group, echo, flags);
+	return nlmsg_notify(net->nfnl, skb, portid, group, echo, flags);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_send);
 
-int nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error)
+int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error)
 {
-	return netlink_set_err(net->nfnl, pid, group, error);
+	return netlink_set_err(net->nfnl, portid, group, error);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_set_err);
 
-int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u_int32_t pid, int flags)
+int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
+		      int flags)
 {
-	return netlink_unicast(net->nfnl, skb, pid, flags);
+	return netlink_unicast(net->nfnl, skb, portid, flags);
 }
 EXPORT_SYMBOL_GPL(nfnetlink_unicast);
 
-- 
1.8.1.4
