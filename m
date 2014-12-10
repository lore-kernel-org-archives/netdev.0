From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next] tipc: fix broadcast wakeup contention after congestion
Date: Wed, 10 Dec 2014 09:46:54 +0100
Message-ID: <1418201214-30767-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:46898 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbaLJIvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 03:51:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

commit 908344cdda80 ("tipc: fix bug in multicast congestion handling")
introduced a race in the broadcast link wakeup functionality.

This patch eliminates this broadcast link wakeup race caused by
operation on the wakeup list without proper locking. If this race
hit and corrupted the list all subsequent wakeup messages would be
lost, resulting in a considerable memory leak.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/link.c | 8 ++++----
 net/tipc/node.c | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 34bf15c..23bcc11 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -293,7 +293,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	l_ptr->next_out_no = 1;
 	__skb_queue_head_init(&l_ptr->outqueue);
 	__skb_queue_head_init(&l_ptr->deferred_queue);
-	__skb_queue_head_init(&l_ptr->waiting_sks);
+	skb_queue_head_init(&l_ptr->waiting_sks);
 
 	link_reset_statistics(l_ptr);
 
@@ -358,7 +358,7 @@ static bool link_schedule_user(struct tipc_link *link, u32 oport,
 		return false;
 	TIPC_SKB_CB(buf)->chain_sz = chain_sz;
 	TIPC_SKB_CB(buf)->chain_imp = imp;
-	__skb_queue_tail(&link->waiting_sks, buf);
+	skb_queue_tail(&link->waiting_sks, buf);
 	link->stats.link_congs++;
 	return true;
 }
@@ -378,8 +378,8 @@ static void link_prepare_wakeup(struct tipc_link *link)
 		if (pend_qsz >= link->queue_limit[TIPC_SKB_CB(skb)->chain_imp])
 			break;
 		pend_qsz += TIPC_SKB_CB(skb)->chain_sz;
-		__skb_unlink(skb, &link->waiting_sks);
-		__skb_queue_tail(&link->owner->waiting_sks, skb);
+		skb_unlink(skb, &link->waiting_sks);
+		skb_queue_tail(&link->owner->waiting_sks, skb);
 	}
 }
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 69b96be..8d353ec 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -115,7 +115,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 	INIT_LIST_HEAD(&n_ptr->list);
 	INIT_LIST_HEAD(&n_ptr->publ_list);
 	INIT_LIST_HEAD(&n_ptr->conn_sks);
-	__skb_queue_head_init(&n_ptr->waiting_sks);
+	skb_queue_head_init(&n_ptr->waiting_sks);
 	__skb_queue_head_init(&n_ptr->bclink.deferred_queue);
 
 	hlist_add_head_rcu(&n_ptr->hash, &node_htable[tipc_hashfn(addr)]);
-- 
2.1.3
