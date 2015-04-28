From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: fix problem with parallel link synchronization mechanism
Date: Tue, 28 Apr 2015 16:59:04 -0400
Message-ID: <1430254744-10081-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:26341 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965987AbbD1U7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:59:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we try to accumulate arrived packets in the links's
'deferred' queue during the parallel link syncronization phase.

This entails two problems:

- With an unlucky combination of arriving packets the algorithm
  may go into a lockstep with the out-of-sequence handling function,
  where the synch mechanism is adding a packet to the deferred queue,
  while the out-of-sequence handling is retrieving it again, thus
  ending up in a loop inside the node_lock scope.

- Even if this is avoided, the link will very often send out
  unnecessary protocol messages, in the worst case leading to
  redundant retransmissions.

We fix this by just dropping arriving packets on the upcoming link
during the synchronization phase, thus relying on the retransmission
protocol to resolve the situation once the two links have arrived to
a synchronized state.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 57be6e6..f97c235 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1145,11 +1145,8 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		}
 		/* Synchronize with parallel link if applicable */
 		if (unlikely((l_ptr->flags & LINK_SYNCHING) && !msg_dup(msg))) {
-			link_handle_out_of_seq_msg(l_ptr, skb);
-			if (link_synch(l_ptr))
-				link_retrieve_defq(l_ptr, &head);
-			skb = NULL;
-			goto unlock;
+			if (!link_synch(l_ptr))
+				goto unlock;
 		}
 		l_ptr->next_in_no++;
 		if (unlikely(!skb_queue_empty(&l_ptr->deferdq)))
-- 
1.9.1
