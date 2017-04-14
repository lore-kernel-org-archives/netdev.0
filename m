From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/9] netfilter: nf_ct_expect: use proper RCU list traversal/update APIs
Date: Fri, 14 Apr 2017 02:26:49 +0200
Message-ID: <1492129611-29336-8-git-send-email-pablo@netfilter.org>
References: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35318 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754162AbdDNA1M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 20:27:12 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7C973E0435
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6DFDEDA863
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AD02CDA863
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:05 +0200 (CEST)
In-Reply-To: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

We should use proper RCU list APIs to manipulate help->expectations,
as we can dump the conntrack's expectations via nfnetlink, i.e. in
ctnetlink_exp_ct_dump_table(), where only rcu_read_lock is acquired.

So for list traversal, use hlist_for_each_entry_rcu; for list add/del,
use hlist_add_head_rcu and hlist_del_rcu.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c  | 4 ++--
 net/netfilter/nf_conntrack_netlink.c | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4b2e1fb28bb4..d80073037856 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -57,7 +57,7 @@ void nf_ct_unlink_expect_report(struct nf_conntrack_expect *exp,
 	hlist_del_rcu(&exp->hnode);
 	net->ct.expect_count--;
 
-	hlist_del(&exp->lnode);
+	hlist_del_rcu(&exp->lnode);
 	master_help->expecting[exp->class]--;
 
 	nf_ct_expect_event_report(IPEXP_DESTROY, exp, portid, report);
@@ -363,7 +363,7 @@ static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	/* two references : one for hash insert, one for the timer */
 	atomic_add(2, &exp->use);
 
-	hlist_add_head(&exp->lnode, &master_help->expectations);
+	hlist_add_head_rcu(&exp->lnode, &master_help->expectations);
 	master_help->expecting[exp->class]++;
 
 	hlist_add_head_rcu(&exp->hnode, &nf_ct_expect_hash[h]);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index f78eadba343d..dc7dfd68fafe 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2680,8 +2680,8 @@ ctnetlink_exp_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	last = (struct nf_conntrack_expect *)cb->args[1];
 	for (; cb->args[0] < nf_ct_expect_hsize; cb->args[0]++) {
 restart:
-		hlist_for_each_entry(exp, &nf_ct_expect_hash[cb->args[0]],
-				     hnode) {
+		hlist_for_each_entry_rcu(exp, &nf_ct_expect_hash[cb->args[0]],
+					 hnode) {
 			if (l3proto && exp->tuple.src.l3num != l3proto)
 				continue;
 
@@ -2732,7 +2732,7 @@ ctnetlink_exp_ct_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	rcu_read_lock();
 	last = (struct nf_conntrack_expect *)cb->args[1];
 restart:
-	hlist_for_each_entry(exp, &help->expectations, lnode) {
+	hlist_for_each_entry_rcu(exp, &help->expectations, lnode) {
 		if (l3proto && exp->tuple.src.l3num != l3proto)
 			continue;
 		if (cb->args[1]) {
-- 
2.1.4
