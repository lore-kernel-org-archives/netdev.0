From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 16/18] tipc: guarantee delivery of UP event before first broadcast
Date: Thu, 12 Oct 2017 16:02:37 +0200
Message-ID: <1507816959-31787-17-git-send-email-jon.maloy@ericsson.com>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:48659 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751901AbdJLOC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:02:57 -0400
In-Reply-To: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following scenario is possible:
- A user joins a group, and immediately sends out a broadcast message
  to its members.
- The broadcast message, following a different data path than the
  initial JOIN message sent out during the joining procedure, arrives
  to a receiver before the latter..
- The receiver drops the message, since it is not ready to accept any
  messages until the JOIN has arrived.

We avoid this by treating group protocol JOIN messages like unicast
messages.
- We let them pass through the recipient's multicast input queue, just
  like ordinary unicasts.
- We force the first following broadacst to be sent as replicated
  unicast and being acknowledged by the recipient before accepting
  any more broadcast transmissions.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c   | 7 +++++--
 net/tipc/socket.c | 4 ++++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 70a2149..723dd69 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1039,6 +1039,7 @@ int tipc_link_retrans(struct tipc_link *l, struct tipc_link *nacker,
 static bool tipc_data_input(struct tipc_link *l, struct sk_buff *skb,
 			    struct sk_buff_head *inputq)
 {
+	struct sk_buff_head *mc_inputq = l->bc_rcvlink->inputq;
 	struct tipc_msg *hdr = buf_msg(skb);
 
 	switch (msg_user(hdr)) {
@@ -1047,12 +1048,14 @@ static bool tipc_data_input(struct tipc_link *l, struct sk_buff *skb,
 	case TIPC_HIGH_IMPORTANCE:
 	case TIPC_CRITICAL_IMPORTANCE:
 		if (unlikely(msg_in_group(hdr) || msg_mcast(hdr))) {
-			skb_queue_tail(l->bc_rcvlink->inputq, skb);
+			skb_queue_tail(mc_inputq, skb);
 			return true;
 		}
-	case GROUP_PROTOCOL:
 	case CONN_MANAGER:
 		return true;
+	case GROUP_PROTOCOL:
+		skb_queue_tail(mc_inputq, skb);
+		return true;
 	case NAME_DISTRIBUTOR:
 		l->bc_rcvlink->state = LINK_ESTABLISHED;
 		skb_queue_tail(l->namedq, skb);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 379c5b9..358a603 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2761,6 +2761,10 @@ static int tipc_sk_join(struct tipc_sock *tsk, struct tipc_group_req *mreq)
 	rc = tipc_sk_publish(tsk, mreq->scope, &seq);
 	if (rc)
 		tipc_group_delete(net, grp);
+
+	/* Eliminate any risk that a broadcast overtakes the sent JOIN */
+	tsk->mc_method.rcast = true;
+	tsk->mc_method.mandatory = true;
 	return rc;
 }
 
-- 
2.1.4
