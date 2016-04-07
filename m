From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 2/2] tipc: purge deferred updates from dead nodes
Date: Thu,  7 Apr 2016 10:40:44 -0400
Message-ID: <1460040044-30770-3-git-send-email-jon.maloy@ericsson.com>
References: <1460040044-30770-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Erik Hugne <erik.hugne@gmail.com>,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:23845 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756616AbcDGOlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 10:41:23 -0400
In-Reply-To: <1460040044-30770-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@gmail.com>

If a peer node becomes unavailable, in addition to removing the
nametable entries from this node we also need to purge all deferred
updates associated with this node.

Signed-off-by: Erik Hugne <erik.hugne@gmail.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/name_distr.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 4f4f581..6b626a6 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -224,12 +224,31 @@ static void tipc_publ_purge(struct net *net, struct publication *publ, u32 addr)
 	kfree_rcu(p, rcu);
 }
 
+/**
+ * tipc_dist_queue_purge - remove deferred updates from a node that went down
+ */
+static void tipc_dist_queue_purge(struct net *net, u32 addr)
+{
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct distr_queue_item *e, *tmp;
+
+	spin_lock_bh(&tn->nametbl_lock);
+	list_for_each_entry_safe(e, tmp, &tn->dist_queue, next) {
+		if (e->node != addr)
+			continue;
+		list_del(&e->next);
+		kfree(e);
+	}
+	spin_unlock_bh(&tn->nametbl_lock);
+}
+
 void tipc_publ_notify(struct net *net, struct list_head *nsub_list, u32 addr)
 {
 	struct publication *publ, *tmp;
 
 	list_for_each_entry_safe(publ, tmp, nsub_list, nodesub_list)
 		tipc_publ_purge(net, publ, addr);
+	tipc_dist_queue_purge(net, addr);
 }
 
 /**
-- 
1.9.1
