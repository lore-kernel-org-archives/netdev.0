From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 5/7] tipc: eliminate unnecessary call to broadcast ack function
Date: Fri, 13 Mar 2015 10:27:38 -0400
Message-ID: <1426256860-31208-6-git-send-email-jon.maloy@ericsson.com>
References: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:31972 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754412AbbCMO2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:28:17 -0400
In-Reply-To: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The unicast packet header contains a broadcast acknowledge sequence
number, that may need to be conveyed to the broadcast link for proper
treatment. Currently, the function tipc_rcv(), which is on the most
critical data path, calls the function tipc_bclink_acknowledge() to
have this done. This call is made for each received packet, and results
in the unconditional grabbing of the broadcast link spinlock.

This is unnecessary, since we can see directly from tipc_rcv() if
the acknowledged number differs from what has been previously acked
from the node in question. In the vast majority of cases the numbers
won't differ, and there is nothing to update.

We now make the call to tipc_bclink_acknowledge() conditional
to that the two ack values differ.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c | 4 ++++
 net/tipc/link.c  | 2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 3e41704..5ee5076 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -215,7 +215,11 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	struct net *net = n_ptr->net;
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
+	if (unlikely(!n_ptr->bclink.recv_permitted))
+		return;
+
 	tipc_bclink_lock(net);
+
 	/* Bail out if tx queue is empty (no clean up is required) */
 	skb = skb_peek(&tn->bcl->outqueue);
 	if (!skb)
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 56c39b1..2652c32 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1117,7 +1117,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		ackd = msg_ack(msg);
 
 		/* Release acked messages */
-		if (likely(n_ptr->bclink.recv_permitted))
+		if (unlikely(n_ptr->bclink.acked != msg_bcast_ack(msg)))
 			tipc_bclink_acknowledge(n_ptr, msg_bcast_ack(msg));
 
 		released = 0;
-- 
1.9.1
