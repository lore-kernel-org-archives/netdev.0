From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: purge backlog queue counters when broadcast link is reset
Date: Sun, 28 Jun 2015 09:44:44 -0400
Message-ID: <1435499084-29332-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.biz.mail.bf1.yahoo.com ([98.139.221.61]:27689 "EHLO
	smtp102.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752114AbbF1NpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 09:45:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 1f66d161ab3d8b518903fa6c3f9c1f48d6919e74
("tipc: introduce starvation free send algorithm")
we introduced a counter per priority level for buffers
in the link backlog queue. We also introduced a new
function tipc_link_purge_backlog(), to reset these
counters to zero when the link is reset.

Unfortunately, we missed to call this function when
the broadcast link is reset, with the result that the
values of these counters might be permanently skewed
when new nodes are attached. This may in the worst case
lead to permananent, but spurious, broadcast link
congestion, where no broadcast packets can be sent at
all.

We fix this bug with this commit.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c | 5 +++++
 net/tipc/link.c  | 2 +-
 net/tipc/link.h  | 1 +
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 4906ca3..a816382 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -108,6 +108,11 @@ void tipc_bclink_remove_node(struct net *net, u32 addr)
 
 	tipc_bclink_lock(net);
 	tipc_nmap_remove(&tn->bclink->bcast_nodes, addr);
+
+	/* Last node? => reset backlog queue */
+	if (!tn->bclink->bcast_nodes.count)
+		tipc_link_purge_backlog(&tn->bclink->link);
+
 	tipc_bclink_unlock(net);
 }
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index ca8b8e0..eaa9fe5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -404,7 +404,7 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr)
 	l_ptr->reasm_buf = NULL;
 }
 
-static void tipc_link_purge_backlog(struct tipc_link *l)
+void tipc_link_purge_backlog(struct tipc_link *l)
 {
 	__skb_queue_purge(&l->backlogq);
 	l->backlog[TIPC_LOW_IMPORTANCE].len = 0;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 0c02c97..ae0a0ea 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -218,6 +218,7 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
 void tipc_link_purge_queues(struct tipc_link *l_ptr);
+void tipc_link_purge_backlog(struct tipc_link *l);
 void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
 int tipc_link_xmit_skb(struct net *net, struct sk_buff *skb, u32 dest,
-- 
1.9.1
