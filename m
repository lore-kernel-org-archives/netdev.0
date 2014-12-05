From: <richard.alpe@ericsson.com>
Subject: [PATCH] tipc: fix broadcast link wakeup after congestion
Date: Fri, 5 Dec 2014 18:59:20 +0100
Message-ID: <1417802360-5383-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:51345 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbaLESDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 13:03:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

commit 908344cdda80 ("tipc: fix bug in multicast congestion
handling") introduced two bugs in the bclink wakeup function.

This patch fixes the missing spinlock init for the broadcast link
waiting_sks list and eliminates a broadcast link wakeup race caused
by operation on the wakeup list without proper locking.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Acked-by: Tero Aho <Tero.Aho@coriant.com>
---
 net/tipc/bcast.c | 9 ++++++---
 net/tipc/link.c  | 8 ++++----
 net/tipc/node.c  | 2 +-
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index f0761c7..96ceefe 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -233,8 +233,11 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
  */
 void tipc_bclink_wakeup_users(void)
 {
-	while (skb_queue_len(&bclink->link.waiting_sks))
-		tipc_sk_rcv(skb_dequeue(&bclink->link.waiting_sks));
+	struct sk_buff *skb;
+
+	while ((skb = skb_dequeue(&bclink->link.waiting_sks)))
+		tipc_sk_rcv(skb);
+
 }
 
 /**
@@ -950,7 +953,7 @@ int tipc_bclink_init(void)
 	spin_lock_init(&bclink->lock);
 	__skb_queue_head_init(&bcl->outqueue);
 	__skb_queue_head_init(&bcl->deferred_queue);
-	__skb_queue_head_init(&bcl->waiting_sks);
+	skb_queue_head_init(&bcl->waiting_sks);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
 	__skb_queue_head_init(&bclink->node.waiting_sks);
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
