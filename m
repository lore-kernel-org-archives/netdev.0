From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: fix bug in link failover handling
Date: Mon,  9 Mar 2015 16:16:22 -0400
Message-ID: <1425932182-31518-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:31096 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752497AbbCIUQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 16:16:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit c637c1035534867b85b78b453c38c495b58e2c5a
("tipc: resolve race problem at unicast message reception") we
introduced a new mechanism for delivering buffers upwards from link
to socket layer.

That code contains a bug in how we handle the new link input queue
during failover. When a link is reset, some of its users may be blocked
because of congestion, and in order to resolve this, we add any pending
wakeup pseudo messages to the link's input queue, and deliver them to
the socket. This misses the case where the other, remaining link also
may have congested users. Currently, the owner node's reference to the
remaining link's input queue is unconditionally overwritten by the
reset link's input queue. This has the effect that wakeup events from
the remaining link may be unduely delayed (but not lost) for a
potentially long period.

We fix this by adding the pending events from the reset link to the
input queue that is currently referenced by the node, whichever one
it is.

This commit should be applied to both net and net-next.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index a4cf364..14f09b3 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -464,10 +464,11 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	/* Clean up all queues, except inputq: */
 	__skb_queue_purge(&l_ptr->outqueue);
 	__skb_queue_purge(&l_ptr->deferred_queue);
-	skb_queue_splice_init(&l_ptr->wakeupq, &l_ptr->inputq);
-	if (!skb_queue_empty(&l_ptr->inputq))
+	if (!owner->inputq)
+		owner->inputq = &l_ptr->inputq;
+	skb_queue_splice_init(&l_ptr->wakeupq, owner->inputq);
+	if (!skb_queue_empty(owner->inputq))
 		owner->action_flags |= TIPC_MSG_EVT;
-	owner->inputq = &l_ptr->inputq;
 	l_ptr->next_out = NULL;
 	l_ptr->unacked_window = 0;
 	l_ptr->checkpoint = 1;
-- 
1.9.1
