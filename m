From: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
Subject: [PATCH] tipc: Only process unicast on intended node
Date: Fri, 29 Apr 2016 13:35:18 +1200
Message-ID: <1461893718-17404-1-git-send-email-hamish.martin@alliedtelesis.co.nz>
Cc: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
To: jon.maloy@ericsson.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:42358 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbcD2Bfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 21:35:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Signed-off-by: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
Reviewed-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
Reviewed-by: John Thompson <john.thompson@alliedtelesis.co.nz>
---
 net/tipc/node.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index ace178fd3850..e5dda495d4b6 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1460,6 +1460,11 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b)
 			return tipc_node_bc_rcv(net, skb, bearer_id);
 	}
 
+	/* Discard unicast link messages destined for another node */
+	if (unlikely(!msg_short(hdr) &&
+		     (msg_destnode(hdr) != tipc_own_addr(net))))
+		goto discard;
+
 	/* Locate neighboring node that sent packet */
 	n = tipc_node_find(net, msg_prevnode(hdr));
 	if (unlikely(!n))
-- 
2.8.1
