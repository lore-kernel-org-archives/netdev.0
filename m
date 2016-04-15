From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 5/5] tipc: let first message on
	link be a state message
Date: Fri, 15 Apr 2016 13:33:07 -0400
Message-ID: <1460741587-13935-6-git-send-email-jon.maloy@ericsson.com>
References: <1460741587-13935-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1460741587-13935-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

According to the link FSM, a received traffic packet can take a link
from state ESTABLISHING to ESTABLISHED, but the link can still not be
fully set up in one atomic operation. This means that even if the the
very first packet on the link is a traffic packet with sequence number
1 (one), it has to be dropped and retransmitted.

This can be avoided if we let the mentioned packet be preceded by a
LINK_PROTOCOL/STATE message, which takes up the endpoint before the
arrival of the traffic.

We add this small feature in this commit.

This is a fully compatible change.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 6 +++---
 net/tipc/link.h | 2 +-
 net/tipc/node.c | 5 ++++-
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 774ad3c..2e28a7d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1107,12 +1107,12 @@ static bool tipc_link_release_pkts(struct tipc_link *l, u16 acked)
 	return released;
 }
 
-/* tipc_link_build_ack_msg: prepare link acknowledge message for transmission
+/* tipc_link_build_state_msg: prepare link state message for transmission
  *
  * Note that sending of broadcast ack is coordinated among nodes, to reduce
  * risk of ack storms towards the sender
  */
-int tipc_link_build_ack_msg(struct tipc_link *l, struct sk_buff_head *xmitq)
+int tipc_link_build_state_msg(struct tipc_link *l, struct sk_buff_head *xmitq)
 {
 	if (!l)
 		return 0;
@@ -1222,7 +1222,7 @@ int tipc_link_rcv(struct tipc_link *l, struct sk_buff *skb,
 		if (!tipc_data_input(l, skb, l->inputq))
 			rc |= tipc_link_input(l, skb, l->inputq);
 		if (unlikely(++l->rcv_unacked >= TIPC_MIN_LINK_WIN))
-			rc |= tipc_link_build_ack_msg(l, xmitq);
+			rc |= tipc_link_build_state_msg(l, xmitq);
 		if (unlikely(rc & ~TIPC_LINK_SND_BC_ACK))
 			break;
 	} while ((skb = __skb_dequeue(defq)));
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 6a94175..d7e9d42 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -123,7 +123,7 @@ int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[]);
 int tipc_link_timeout(struct tipc_link *l, struct sk_buff_head *xmitq);
 int tipc_link_rcv(struct tipc_link *l, struct sk_buff *skb,
 		  struct sk_buff_head *xmitq);
-int tipc_link_build_ack_msg(struct tipc_link *l, struct sk_buff_head *xmitq);
+int tipc_link_build_state_msg(struct tipc_link *l, struct sk_buff_head *xmitq);
 void tipc_link_add_bc_peer(struct tipc_link *snd_l,
 			   struct tipc_link *uc_l,
 			   struct sk_buff_head *xmitq);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index b00e12c..68d9f7b 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -545,6 +545,9 @@ static void __tipc_node_link_up(struct tipc_node *n, int bearer_id,
 	pr_debug("Established link <%s> on network plane %c\n",
 		 tipc_link_name(nl), tipc_link_plane(nl));
 
+	/* Ensure that a STATE message goes first */
+	tipc_link_build_state_msg(nl, xmitq);
+
 	/* First link? => give it both slots */
 	if (!ol) {
 		*slot0 = bearer_id;
@@ -1283,7 +1286,7 @@ static void tipc_node_bc_rcv(struct net *net, struct sk_buff *skb, int bearer_id
 	/* Broadcast ACKs are sent on a unicast link */
 	if (rc & TIPC_LINK_SND_BC_ACK) {
 		tipc_node_read_lock(n);
-		tipc_link_build_ack_msg(le->link, &xmitq);
+		tipc_link_build_state_msg(le->link, &xmitq);
 		tipc_node_read_unlock(n);
 	}
 
-- 
1.9.1


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
