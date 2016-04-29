From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net v2 1/1] tipc: only process unicast on intended node
Date: Fri, 29 Apr 2016 10:40:24 -0400
Message-ID: <1461940824-20121-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Hamish Martin <hamish.martin@alliedtelesis.co.nz>,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:22758 "EHLO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753023AbcD2OlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 10:41:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hamish Martin <hamish.martin@alliedtelesis.co.nz>

We have observed complete lock up of broadcast-link transmission due to
unacknowledged packets never being removed from the 'transmq' queue. This
is traced to nodes having their ack field set beyond the sequence number
of packets that have actually been transmitted to them.
Consider an example where node 1 has sent 10 packets to node 2 on a
link and node 3 has sent 20 packets to node 2 on another link. We
see examples of an ack from node 2 destined for node 3 being treated as
an ack from node 2 at node 1. This leads to the ack on the node 1 to node
2 link being increased to 20 even though we have only sent 10 packets.
When node 1 does get around to sending further packets, none of the
packets with sequence numbers less than 21 are actually removed from the
transmq.
To resolve this we reinstate some code lost in commit d999297c3dbb ("tipc:
reduce locking scope during packet reception") which ensures that only
messages destined for the receiving node are processed by that node. This
prevents the sequence numbers from getting out of sync and resolves the
packet leakage, thereby resolving the broadcast-link transmission
lock-ups we observed.

While we are aware that this change only patches over a root problem that
we still haven't identified, this is a sanity test that it is always
legitimate to do. It will remain in the code even after we identify and
fix the real problem.

Reviewed-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
Reviewed-by: John Thompson <john.thompson@alliedtelesis.co.nz>
Signed-off-by: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index ace178f..9aaa1bc 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1444,6 +1444,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b)
 	int bearer_id = b->identity;
 	struct tipc_link_entry *le;
 	u16 bc_ack = msg_bcast_ack(hdr);
+	u32 self = tipc_own_addr(net);
 	int rc = 0;
 
 	__skb_queue_head_init(&xmitq);
@@ -1460,6 +1461,10 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b)
 			return tipc_node_bc_rcv(net, skb, bearer_id);
 	}
 
+	/* Discard unicast link messages destined for another node */
+	if (unlikely(!msg_short(hdr) && (msg_destnode(hdr) != self)))
+		goto discard;
+
 	/* Locate neighboring node that sent packet */
 	n = tipc_node_find(net, msg_prevnode(hdr));
 	if (unlikely(!n))
-- 
1.9.1
