From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/8] netfilter: conntrack: move expectation event helper to ecache.c
Date: Wed, 13 Apr 2016 01:02:46 +0200
Message-ID: <1460502166-20340-9-git-send-email-pablo@netfilter.org>
References: <1460502166-20340-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36539 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966112AbcDLXDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 19:03:09 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9E1CDC9EEE
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 01:03:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 8DC881B3009
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 01:03:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5F90C1B309B
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 01:03:05 +0200 (CEST)
In-Reply-To: <1460502166-20340-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Not performance critical, it is only invoked when an expectation is
added/destroyed.

While at it, kill unused nf_ct_expect_event() wrapper.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_ecache.h | 42 +++--------------------------
 net/netfilter/nf_conntrack_ecache.c         | 30 +++++++++++++++++++++
 2 files changed, 33 insertions(+), 39 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 019a5b8..fa36447 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -130,43 +130,9 @@ int nf_ct_expect_register_notifier(struct net *net,
 void nf_ct_expect_unregister_notifier(struct net *net,
 				      struct nf_exp_event_notifier *nb);
 
-static inline void
-nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
-			  struct nf_conntrack_expect *exp,
-			  u32 portid,
-			  int report)
-{
-	struct net *net = nf_ct_exp_net(exp);
-	struct nf_exp_event_notifier *notify;
-	struct nf_conntrack_ecache *e;
-
-	rcu_read_lock();
-	notify = rcu_dereference(net->ct.nf_expect_event_cb);
-	if (notify == NULL)
-		goto out_unlock;
-
-	e = nf_ct_ecache_find(exp->master);
-	if (e == NULL)
-		goto out_unlock;
-
-	if (e->expmask & (1 << event)) {
-		struct nf_exp_event item = {
-			.exp	= exp,
-			.portid	= portid,
-			.report = report
-		};
-		notify->fcn(1 << event, &item);
-	}
-out_unlock:
-	rcu_read_unlock();
-}
-
-static inline void
-nf_ct_expect_event(enum ip_conntrack_expect_events event,
-		   struct nf_conntrack_expect *exp)
-{
-	nf_ct_expect_event_report(event, exp, 0, 0);
-}
+void nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
+			       struct nf_conntrack_expect *exp,
+			       u32 portid, int report);
 
 int nf_conntrack_ecache_pernet_init(struct net *net);
 void nf_conntrack_ecache_pernet_fini(struct net *net);
@@ -203,8 +169,6 @@ static inline int nf_conntrack_event_report(enum ip_conntrack_events event,
 					    u32 portid,
 					    int report) { return 0; }
 static inline void nf_ct_deliver_cached_events(const struct nf_conn *ct) {}
-static inline void nf_ct_expect_event(enum ip_conntrack_expect_events event,
-				      struct nf_conntrack_expect *exp) {}
 static inline void nf_ct_expect_event_report(enum ip_conntrack_expect_events e,
 					     struct nf_conntrack_expect *exp,
  					     u32 portid,
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index a0ebab9..d28011b 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -221,6 +221,36 @@ out_unlock:
 }
 EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 
+void nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
+			       struct nf_conntrack_expect *exp,
+			       u32 portid, int report)
+
+{
+	struct net *net = nf_ct_exp_net(exp);
+	struct nf_exp_event_notifier *notify;
+	struct nf_conntrack_ecache *e;
+
+	rcu_read_lock();
+	notify = rcu_dereference(net->ct.nf_expect_event_cb);
+	if (!notify)
+		goto out_unlock;
+
+	e = nf_ct_ecache_find(exp->master);
+	if (!e)
+		goto out_unlock;
+
+	if (e->expmask & (1 << event)) {
+		struct nf_exp_event item = {
+			.exp	= exp,
+			.portid	= portid,
+			.report = report
+		};
+		notify->fcn(1 << event, &item);
+	}
+out_unlock:
+	rcu_read_unlock();
+}
+
 int nf_conntrack_register_notifier(struct net *net,
 				   struct nf_ct_event_notifier *new)
 {
-- 
2.1.4
