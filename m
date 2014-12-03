From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next] tipc: fix missing spinlock init and nullptr oops
Date: Wed, 3 Dec 2014 16:58:40 +0100
Message-ID: <1417622320-19730-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <ying.xue@windriver.com>,
	<richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:54220 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaLCQCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 11:02:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

commit 908344cdda80 ("tipc: fix bug in multicast congestion
handling") introduced two bugs with the bclink wakeup
function. This commit fixes the missing spinlock init for the
waiting_sks list. We also eliminate the race condition
between the waiting_sks length check/dequeue operations in
tipc_bclink_wakeup_users by simply removing the redundant
length check.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Acked-by: Tero Aho <Tero.Aho@coriant.com>
---
 net/tipc/bcast.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

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
-- 
2.1.3
