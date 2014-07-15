From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 7/7] tipc: ensure sequential message delivery across dual bearers
Date: Tue, 15 Jul 2014 13:46:10 -0400
Message-ID: <1405446370-11781-8-git-send-email-jon.maloy@ericsson.com>
References: <1405446370-11781-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.gq1.yahoo.com ([98.137.12.179]:29392 "HELO
	smtp104.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757434AbaGORqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:46:23 -0400
In-Reply-To: <1405446370-11781-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we run broadcast packets over dual bearers/interfaces, the
current transmission code is flipping bearers between each sent
packet, with the purpose of leveraging the double bandwidth
available. The receiving bclink is resequencing the packets if
needed, so all messages are delivered upwards from the broadcast
link in the correct order, even if they may arrive in concurrent
interrupts.

However, at the moment of delivery upwards to the socket, we release
all spinlocks (bclink_lock, node_lock), so it is still possible
that arriving messages bypass each other before they reach the socket
queue.

We fix this by applying the same technique we are using for unicast
traffic. We use a link selector (i.e., the last bit of sending port
number) to ensure that messages from the same sender socket always are
sent over the same bearer. This guarantees sequential delivery between
socket pairs, which is sufficient to satisfy the protocol spec, as well
as all known user requirements.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c |   17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e7b7f87..d0aba9a 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -636,6 +636,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 			      struct tipc_media_addr *unused2)
 {
 	int bp_index;
+	struct tipc_msg *msg = buf_msg(buf);
 
 	/* Prepare broadcast link message for reliable transmission,
 	 * if first time trying to send it;
@@ -643,10 +644,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 	 * since they are sent in an unreliable manner and don't need it
 	 */
 	if (likely(!msg_non_seq(buf_msg(buf)))) {
-		struct tipc_msg *msg;
-
 		bcbuf_set_acks(buf, bclink->bcast_nodes.count);
-		msg = buf_msg(buf);
 		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tipc_net_id);
 		bcl->stats.sent_info++;
@@ -663,12 +661,14 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 	for (bp_index = 0; bp_index < MAX_BEARERS; bp_index++) {
 		struct tipc_bearer *p = bcbearer->bpairs[bp_index].primary;
 		struct tipc_bearer *s = bcbearer->bpairs[bp_index].secondary;
-		struct tipc_bearer *b = p;
+		struct tipc_bearer *bp[2] = {p, s};
+		struct tipc_bearer *b = bp[msg_link_selector(msg)];
 		struct sk_buff *tbuf;
 
 		if (!p)
 			break; /* No more bearers to try */
-
+		if (!b)
+			b = p;
 		tipc_nmap_diff(&bcbearer->remains, &b->nodes,
 			       &bcbearer->remains_new);
 		if (bcbearer->remains_new.count == bcbearer->remains.count)
@@ -685,13 +685,6 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 			tipc_bearer_send(b->identity, tbuf, &b->bcast_addr);
 			kfree_skb(tbuf); /* Bearer keeps a clone */
 		}
-
-		/* Swap bearers for next packet */
-		if (s) {
-			bcbearer->bpairs[bp_index].primary = s;
-			bcbearer->bpairs[bp_index].secondary = p;
-		}
-
 		if (bcbearer->remains_new.count == 0)
 			break; /* All targets reached */
 
-- 
1.7.9.5
