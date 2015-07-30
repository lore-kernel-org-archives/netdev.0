From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 04/12] tipc: extend node FSM
Date: Thu, 30 Jul 2015 18:24:18 -0400
Message-ID: <1438295066-29655-5-git-send-email-jon.maloy@ericsson.com>
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

In the next commit, we will move link synch/failover orchestration to
the link aggregation level. In order to do this, we first need to extend
the node FSM with two more states, NODE_SYNCHING and NODE_FAILINGOVER,
plus four new events to enter and leave those states.

This commit introduces this change, without yet making use of it.
The node FSM now looks as follows:

                           +-----------------------------------------+
                           |                            PEER_DOWN_EVT|
                           |                                         |
  +------------------------+----------------+                        |
  |SELF_DOWN_EVT           |                |                        |
  |                        |                |                        |
  |              +-----------+          +-----------+                |
  |              |NODE_      |          |NODE_      |                |
  |   +----------|FAILINGOVER|<---------|SYNCHING   |------------+   |
  |   |SELF_     +-----------+ FAILOVER_+-----------+    PEER_   |   |
  |   |DOWN_EVT   |         A  BEGIN_EVT A         |     DOWN_EVT|   |
  |   |           |         |            |         |             |   |
  |   |           |         |            |         |             |   |
  |   |           |FAILOVER_|FAILOVER_   |SYNCH_   |SYNCH_       |   |
  |   |           |END_EVT  |BEGIN_EVT   |BEGIN_EVT|END_EVT      |   |
  |   |           |         |            |         |             |   |
  |   |           |         |            |         |             |   |
  |   |           |        +--------------+        |             |   |
  |   |           +------->|   SELF_UP_   |<-------+             |   |
  |   |   +----------------|   PEER_UP    |------------------+   |   |
  |   |   |SELF_DOWN_EVT   +--------------+     PEER_DOWN_EVT|   |   |
  |   |   |                   A          A                   |   |   |
  |   |   |                   |          |                   |   |   |
  |   |   |        PEER_UP_EVT|          |SELF_UP_EVT        |   |   |
  |   |   |                   |          |                   |   |   |
  V   V   V                   |          |                   V   V   V
+------------+       +-----------+    +-----------+       +------------+
|SELF_DOWN_  |       |SELF_UP_   |    |PEER_UP_   |       |PEER_DOWN   |
|PEER_LEAVING|<------|PEER_COMING|    |SELF_COMING|------>|SELF_LEAVING|
+------------+ SELF_ +-----------+    +-----------+ PEER_ +------------+
       |       DOWN_EVT       A          A          DOWN_EVT     |
       |                      |          |                       |
       |                      |          |                       |
       |           SELF_UP_EVT|          |PEER_UP_EVT            |
       |                      |          |                       |
       |                      |          |                       |
       |PEER_DOWN_EVT       +--------------+        SELF_DOWN_EVT|
       +------------------->|  SELF_DOWN_  |<--------------------+
                            |  PEER_DOWN   |
                            +--------------+

Tested-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 net/tipc/node.h | 14 ++++++---
 2 files changed, 92 insertions(+), 11 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 65c2c80..6b18d73 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -494,8 +494,12 @@ static void tipc_node_fsm_evt(struct tipc_node *n, int evt)
 		case SELF_LOST_CONTACT_EVT:
 		case PEER_LOST_CONTACT_EVT:
 			break;
+		case NODE_SYNCH_END_EVT:
+		case NODE_SYNCH_BEGIN_EVT:
+		case NODE_FAILOVER_BEGIN_EVT:
+		case NODE_FAILOVER_END_EVT:
 		default:
-			pr_err("Unknown node fsm evt %x/%x\n", state, evt);
+			goto illegal_evt;
 		}
 		break;
 	case SELF_UP_PEER_UP:
@@ -506,11 +510,19 @@ static void tipc_node_fsm_evt(struct tipc_node *n, int evt)
 		case PEER_LOST_CONTACT_EVT:
 			state = SELF_LEAVING_PEER_DOWN;
 			break;
+		case NODE_SYNCH_BEGIN_EVT:
+			state = NODE_SYNCHING;
+			break;
+		case NODE_FAILOVER_BEGIN_EVT:
+			state = NODE_FAILINGOVER;
+			break;
 		case SELF_ESTABL_CONTACT_EVT:
 		case PEER_ESTABL_CONTACT_EVT:
+		case NODE_SYNCH_END_EVT:
+		case NODE_FAILOVER_END_EVT:
 			break;
 		default:
-			pr_err("Unknown node fsm evt %x/%x\n", state, evt);
+			goto illegal_evt;
 		}
 		break;
 	case SELF_DOWN_PEER_LEAVING:
@@ -522,8 +534,12 @@ static void tipc_node_fsm_evt(struct tipc_node *n, int evt)
 		case PEER_ESTABL_CONTACT_EVT:
 		case SELF_LOST_CONTACT_EVT:
 			break;
+		case NODE_SYNCH_END_EVT:
+		case NODE_SYNCH_BEGIN_EVT:
+		case NODE_FAILOVER_BEGIN_EVT:
+		case NODE_FAILOVER_END_EVT:
 		default:
-			pr_err("Unknown node fsm evt %x/%x\n", state, evt);
+			goto illegal_evt;
 		}
 		break;
 	case SELF_UP_PEER_COMING:
@@ -537,8 +553,12 @@ static void tipc_node_fsm_evt(struct tipc_node *n, int evt)
 		case SELF_ESTABL_CONTACT_EVT:
 		case PEER_LOST_CONTACT_EVT:
 			break;
+		case NODE_SYNCH_END_EVT:
+		case NODE_SYNCH_BEGIN_EVT:
+		case NODE_FAILOVER_BEGIN_EVT:
+		case NODE_FAILOVER_END_EVT:
 		default:
-			pr_err("Unknown node fsm evt %x/%x\n", state, evt);
+			goto illegal_evt;
 		}
 		break;
 	case SELF_COMING_PEER_UP:
@@ -552,8 +572,12 @@ static void tipc_node_fsm_evt(struct tipc_node *n, int evt)
 		case SELF_LOST_CONTACT_EVT:
 		case PEER_ESTABL_CONTACT_EVT:
 			break;
+		case NODE_SYNCH_END_EVT:
+		case NODE_SYNCH_BEGIN_EVT:
+		case NODE_FAILOVER_BEGIN_EVT:
+		case NODE_FAILOVER_END_EVT:
 		default:
-			pr_err("Unknown node fsm evt %x/%x\n", state, evt);
+			goto illegal_evt;
 		}
 		break;
 	case SELF_LEAVING_PEER_DOWN:
@@ -565,16 +589,67 @@ static void tipc_node_fsm_evt(struct tipc_node *n, int evt)
 		case PEER_ESTABL_CONTACT_EVT:
 		case PEER_LOST_CONTACT_EVT:
 			break;
+		case NODE_SYNCH_END_EVT:
+		case NODE_SYNCH_BEGIN_EVT:
+		case NODE_FAILOVER_BEGIN_EVT:
+		case NODE_FAILOVER_END_EVT:
+		default:
+			goto illegal_evt;
+		}
+		break;
+	case NODE_FAILINGOVER:
+		switch (evt) {
+		case SELF_LOST_CONTACT_EVT:
+			state = SELF_DOWN_PEER_LEAVING;
+			break;
+		case PEER_LOST_CONTACT_EVT:
+			state = SELF_LEAVING_PEER_DOWN;
+			break;
+		case NODE_FAILOVER_END_EVT:
+			state = SELF_UP_PEER_UP;
+			break;
+		case NODE_FAILOVER_BEGIN_EVT:
+		case SELF_ESTABL_CONTACT_EVT:
+		case PEER_ESTABL_CONTACT_EVT:
+			break;
+		case NODE_SYNCH_BEGIN_EVT:
+		case NODE_SYNCH_END_EVT:
 		default:
-			pr_err("Unknown node fsm evt %x/%x\n", state, evt);
+			goto illegal_evt;
+		}
+		break;
+	case NODE_SYNCHING:
+		switch (evt) {
+		case SELF_LOST_CONTACT_EVT:
+			state = SELF_DOWN_PEER_LEAVING;
+			break;
+		case PEER_LOST_CONTACT_EVT:
+			state = SELF_LEAVING_PEER_DOWN;
+			break;
+		case NODE_SYNCH_END_EVT:
+			state = SELF_UP_PEER_UP;
+			break;
+		case NODE_FAILOVER_BEGIN_EVT:
+			state = NODE_FAILINGOVER;
+			break;
+		case NODE_SYNCH_BEGIN_EVT:
+		case SELF_ESTABL_CONTACT_EVT:
+		case PEER_ESTABL_CONTACT_EVT:
+			break;
+		case NODE_FAILOVER_END_EVT:
+		default:
+			goto illegal_evt;
 		}
 		break;
 	default:
 		pr_err("Unknown node fsm state %x\n", state);
 		break;
 	}
-
 	n->state = state;
+	return;
+
+illegal_evt:
+	pr_err("Illegal node fsm evt %x in state %x\n", evt, state);
 }
 
 bool tipc_node_filter_skb(struct tipc_node *n, struct tipc_link *l,
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 49df0e93..65e2728 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -56,13 +56,19 @@ enum {
 	SELF_UP_PEER_COMING    = 0xac,
 	SELF_COMING_PEER_UP    = 0xca,
 	SELF_LEAVING_PEER_DOWN = 0x1d,
+	NODE_FAILINGOVER       = 0xf0,
+	NODE_SYNCHING          = 0xcc
 };
 
 enum {
-	SELF_ESTABL_CONTACT_EVT = 0xec,
-	SELF_LOST_CONTACT_EVT   = 0x1c,
-	PEER_ESTABL_CONTACT_EVT = 0xfec,
-	PEER_LOST_CONTACT_EVT   = 0xf1c
+	SELF_ESTABL_CONTACT_EVT = 0xece,
+	SELF_LOST_CONTACT_EVT   = 0x1ce,
+	PEER_ESTABL_CONTACT_EVT = 0xfece,
+	PEER_LOST_CONTACT_EVT   = 0xf1ce,
+	NODE_FAILOVER_BEGIN_EVT = 0xfbe,
+	NODE_FAILOVER_END_EVT   = 0xfee,
+	NODE_SYNCH_BEGIN_EVT    = 0xcbe,
+	NODE_SYNCH_END_EVT      = 0xcee
 };
 
 /* Flags used to take different actions according to flag type
-- 
1.9.1


------------------------------------------------------------------------------
