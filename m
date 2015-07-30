From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 06/12] tipc: move protocol
	message sending away from link FSM
Date: Thu, 30 Jul 2015 18:24:20 -0400
Message-ID: <1438295066-29655-7-git-send-email-jon.maloy@ericsson.com>
References: <1438295066-29655-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1438295066-29655-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The implementation of the link FSM currently takes decisions about and
sends out link protocol messages. This is unnecessary, since such
actions are not the result of any link state change, and are even
decided based on non-FSM state information ("silent_intv_cnt").

We now move the sending of unicast link protocol messages to the
function tipc_link_timeout(), and the initial broadcast synchronization
message to tipc_node_link_up(). The latter is done because a link
instance should not need to know whether it is the first or second
link to a destination. Such information is now restricted to and
handled by the link aggregation layer in node.c

Tested-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 51 ++++++++++++++++++++++++++++++---------------------
 net/tipc/link.h |  2 ++
 net/tipc/node.c |  1 +
 3 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index d5f4005..9a3ccf9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -134,8 +134,6 @@ static void tipc_link_build_proto_msg(struct tipc_link *l, int mtyp, bool probe,
 				      struct sk_buff_head *xmitq);
 static void link_reset_statistics(struct tipc_link *l_ptr);
 static void link_print(struct tipc_link *l_ptr, const char *str);
-static void tipc_link_build_bcast_sync_msg(struct tipc_link *l,
-					   struct sk_buff_head *xmitq);
 static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf);
 static int tipc_link_input(struct tipc_link *l, struct sk_buff *skb);
 static bool tipc_data_input(struct tipc_link *l, struct sk_buff *skb);
@@ -245,8 +243,8 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
  * Give a newly added peer node the sequence number where it should
  * start receiving and acking broadcast packets.
  */
-static void tipc_link_build_bcast_sync_msg(struct tipc_link *l,
-					   struct sk_buff_head *xmitq)
+void tipc_link_build_bcast_sync_msg(struct tipc_link *l,
+				    struct sk_buff_head *xmitq)
 {
 	struct sk_buff *skb;
 	struct sk_buff_head list;
@@ -272,7 +270,7 @@ static void tipc_link_build_bcast_sync_msg(struct tipc_link *l,
 static int tipc_link_fsm_evt(struct tipc_link *l, int evt,
 			     struct sk_buff_head *xmitq)
 {
-	int mtyp = 0, rc = 0;
+	int rc = 0;
 	struct tipc_link *pl;
 	enum {
 		LINK_RESET     = 1,
@@ -380,17 +378,7 @@ static int tipc_link_fsm_evt(struct tipc_link *l, int evt,
 	}
 	if (actions & LINK_ACTIVATE)
 		rc = TIPC_LINK_UP_EVT;
-	if (actions & (SND_STATE | SND_PROBE))
-		mtyp = STATE_MSG;
-	if (actions & SND_RESET)
-		mtyp = RESET_MSG;
-	if (actions & SND_ACTIVATE)
-		mtyp = ACTIVATE_MSG;
-	if (actions & (SND_PROBE | SND_STATE | SND_RESET | SND_ACTIVATE))
-		tipc_link_build_proto_msg(l, mtyp, actions & SND_PROBE,
-					  0, 0, 0, xmitq);
-	if (actions & SND_BCAST_SYNC)
-		tipc_link_build_bcast_sync_msg(l, xmitq);
+
 	return rc;
 }
 
@@ -440,16 +428,37 @@ static void link_profile_stats(struct tipc_link *l)
 int tipc_link_timeout(struct tipc_link *l, struct sk_buff_head *xmitq)
 {
 	int rc = 0;
+	int mtyp = STATE_MSG;
+	bool xmit = false;
+	bool prb = false;
 
 	if (l->exec_mode == TIPC_LINK_BLOCKED)
 		return rc;
 
 	link_profile_stats(l);
-	if (l->silent_intv_cnt)
-		rc = tipc_link_fsm_evt(l, SILENCE_EVT, xmitq);
-	else if (link_working(l) && tipc_bclink_acks_missing(l->owner))
-		tipc_link_build_proto_msg(l, STATE_MSG, 0, 0, 0, 0, xmitq);
-	l->silent_intv_cnt++;
+
+	if (l->state == TIPC_LINK_WORKING) {
+		if (!l->silent_intv_cnt) {
+			if (tipc_bclink_acks_missing(l->owner))
+				xmit = true;
+		} else if (l->silent_intv_cnt <= l->abort_limit) {
+			xmit = true;
+			prb = true;
+		} else {
+			l->exec_mode = TIPC_LINK_BLOCKED;
+			rc |= TIPC_LINK_DOWN_EVT;
+		}
+		l->silent_intv_cnt++;
+	} else if (l->state == TIPC_LINK_RESETTING) {
+		xmit = true;
+		mtyp = RESET_MSG;
+	} else if (l->state == TIPC_LINK_ESTABLISHING) {
+		xmit = true;
+		mtyp = ACTIVATE_MSG;
+	}
+	if (xmit)
+		tipc_link_build_proto_msg(l, mtyp, prb, 0, 0, 0, xmitq);
+
 	return rc;
 }
 
diff --git a/net/tipc/link.h b/net/tipc/link.h
index e377d9b..b317c4d 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -212,6 +212,8 @@ struct tipc_link *tipc_link_create(struct tipc_node *n,
 				   struct sk_buff_head *namedq);
 void tipc_link_tnl_prepare(struct tipc_link *l, struct tipc_link *tnl,
 			   int mtyp, struct sk_buff_head *xmitq);
+void tipc_link_build_bcast_sync_msg(struct tipc_link *l,
+				    struct sk_buff_head *xmitq);
 void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index b0372bb..9e20acf 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -335,6 +335,7 @@ static void tipc_node_link_up(struct tipc_node *n, int bearer_id,
 		*slot0 = bearer_id;
 		*slot1 = bearer_id;
 		nl->exec_mode = TIPC_LINK_OPEN;
+		tipc_link_build_bcast_sync_msg(nl, xmitq);
 		node_established_contact(n);
 		return;
 	}
-- 
1.9.1


------------------------------------------------------------------------------
