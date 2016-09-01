From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/3] tipc: send broadcast nack
	directly upon sequence gap detection
Date: Thu,  1 Sep 2016 13:52:51 -0400
Message-ID: <1472752371-30338-4-git-send-email-jon.maloy@ericsson.com>
References: <1472752371-30338-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1472752371-30338-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Because of the risk of an excessive number of NACK messages and
retransissions, receivers have until now abstained from sending
broadcast NACKS directly upon detection of a packet sequence number
gap. We have instead relied on such gaps being detected by link
protocol STATE message exchange, something that by necessity delays
such detection and subsequent retransmissions.

With the introduction of unicast NACK transmission and rate control
of retransmissions we can now remove this limitation. We now allow
receiving nodes to send NACKS immediately, while coordinating the
permission to do so among the nodes in order to avoid NACK storms.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 58bb44d..b36e16c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -242,8 +242,8 @@ static void tipc_link_build_proto_msg(struct tipc_link *l, int mtyp, bool probe,
 				      u16 rcvgap, int tolerance, int priority,
 				      struct sk_buff_head *xmitq);
 static void link_print(struct tipc_link *l, const char *str);
-static void tipc_link_build_nack_msg(struct tipc_link *l,
-				     struct sk_buff_head *xmitq);
+static int tipc_link_build_nack_msg(struct tipc_link *l,
+				    struct sk_buff_head *xmitq);
 static void tipc_link_build_bc_init_msg(struct tipc_link *l,
 					struct sk_buff_head *xmitq);
 static bool tipc_link_release_pkts(struct tipc_link *l, u16 to);
@@ -1184,17 +1184,26 @@ void tipc_link_build_reset_msg(struct tipc_link *l, struct sk_buff_head *xmitq)
 }
 
 /* tipc_link_build_nack_msg: prepare link nack message for transmission
+ * Note that sending of broadcast NACK is coordinated among nodes, to
+ * reduce the risk of NACK storms towards the sender
  */
-static void tipc_link_build_nack_msg(struct tipc_link *l,
-				     struct sk_buff_head *xmitq)
+static int tipc_link_build_nack_msg(struct tipc_link *l,
+				    struct sk_buff_head *xmitq)
 {
 	u32 def_cnt = ++l->stats.deferred_recv;
+	int match1, match2;
 
-	if (link_is_bc_rcvlink(l))
-		return;
+	if (link_is_bc_rcvlink(l)) {
+		match1 = def_cnt & 0xf;
+		match2 = tipc_own_addr(l->net) & 0xf;
+		if (match1 == match2)
+			return TIPC_LINK_SND_STATE;
+		return 0;
+	}
 
 	if ((skb_queue_len(&l->deferdq) == 1) || !(def_cnt % TIPC_NACK_INTV))
 		tipc_link_build_proto_msg(l, STATE_MSG, 0, 0, 0, 0, xmitq);
+	return 0;
 }
 
 /* tipc_link_rcv - process TIPC packets/messages arriving from off-node
@@ -1245,7 +1254,7 @@ int tipc_link_rcv(struct tipc_link *l, struct sk_buff *skb,
 		/* Defer delivery if sequence gap */
 		if (unlikely(seqno != rcv_nxt)) {
 			__tipc_skb_queue_sorted(defq, seqno, skb);
-			tipc_link_build_nack_msg(l, xmitq);
+			rc |= tipc_link_build_nack_msg(l, xmitq);
 			break;
 		}
 
-- 
2.7.4


------------------------------------------------------------------------------
