From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 7/7] tipc: ensure sequential
	message delivery across dual bearers
Date: Wed, 16 Jul 2014 20:18:38 -0400
Message-ID: <1405556318-14240-8-git-send-email-jon.maloy@ericsson.com>
References: <1405556318-14240-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1405556318-14240-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

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
index 6755184..5ae41e0 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -632,6 +632,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 			      struct tipc_media_addr *unused2)
 {
 	int bp_index;
+	struct tipc_msg *msg = buf_msg(buf);
 
 	/* Prepare broadcast link message for reliable transmission,
 	 * if first time trying to send it;
@@ -639,10 +640,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
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
@@ -659,12 +657,14 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
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
@@ -681,13 +681,6 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
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


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
