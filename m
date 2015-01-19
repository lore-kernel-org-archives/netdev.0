From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next] tipc: ratelimit network event
	traces
Date: Mon, 19 Jan 2015 10:02:44 +0100
Message-ID: <1421658164-26185-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <richard.alpe@ericsson.com>, <ying.xue@windriver.com>,
	<jon.maloy@ericsson.com>, <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

If a large number of namespaces is spawned on a node and TIPC is
enabled in each of these, the excessive printk tracing of network
events will cause the system to grind down to a near halt.
We fix this by adding ratelimiting to the info/warning logs
regarding link state and node availability.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c | 21 +++++++++++----------
 net/tipc/node.c | 24 +++++++++++++-----------
 2 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 193bc15..bedb590 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -538,8 +538,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv / 4);
 			break;
 		case RESET_MSG:
-			pr_info("%s<%s>, requested by peer\n", link_rst_msg,
-				l_ptr->name);
+			pr_info_ratelimited("%s<%s>, requested by peer\n",
+					    link_rst_msg, l_ptr->name);
 			tipc_link_reset(l_ptr);
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
@@ -549,7 +549,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		default:
-			pr_err("%s%u in WW state\n", link_unk_evt, event);
+			pr_err_ratelimited("%s%u in WW state\n", link_unk_evt,
+					   event);
 		}
 		break;
 	case WORKING_UNKNOWN:
@@ -561,8 +562,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		case RESET_MSG:
-			pr_info("%s<%s>, requested by peer while probing\n",
-				link_rst_msg, l_ptr->name);
+			pr_info_ratelimited("%s<%s>, requested by peer while probing\n",
+					    link_rst_msg, l_ptr->name);
 			tipc_link_reset(l_ptr);
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
@@ -588,8 +589,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 				l_ptr->fsm_msg_cnt++;
 				link_set_timer(l_ptr, cont_intv / 4);
 			} else {	/* Link has failed */
-				pr_warn("%s<%s>, peer not responding\n",
-					link_rst_msg, l_ptr->name);
+				pr_warn_ratelimited("%s<%s>, peer not responding\n",
+						    link_rst_msg, l_ptr->name);
 				tipc_link_reset(l_ptr);
 				l_ptr->state = RESET_UNKNOWN;
 				l_ptr->fsm_msg_cnt = 0;
@@ -1568,9 +1569,9 @@ static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
 
 		if (msg_linkprio(msg) &&
 		    (msg_linkprio(msg) != l_ptr->priority)) {
-			pr_warn("%s<%s>, priority change %u->%u\n",
-				link_rst_msg, l_ptr->name, l_ptr->priority,
-				msg_linkprio(msg));
+			pr_warn_ratelimited("%s<%s>, priority change %u->%u\n",
+					    link_rst_msg, l_ptr->name,
+					    l_ptr->priority, msg_linkprio(msg));
 			l_ptr->priority = msg_linkprio(msg);
 			tipc_link_reset(l_ptr); /* Enforce change to take effect */
 			break;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index b1eb092..01a03a7 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -230,8 +230,8 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	n_ptr->action_flags |= TIPC_NOTIFY_LINK_UP;
 	n_ptr->link_id = l_ptr->peer_bearer_id << 16 | l_ptr->bearer_id;
 
-	pr_info("Established link <%s> on network plane %c\n",
-		l_ptr->name, l_ptr->net_plane);
+	pr_info_ratelimited("Established link <%s> on network plane %c\n",
+			    l_ptr->name, l_ptr->net_plane);
 
 	if (!active[0]) {
 		active[0] = active[1] = l_ptr;
@@ -239,7 +239,8 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		goto exit;
 	}
 	if (l_ptr->priority < active[0]->priority) {
-		pr_info("New link <%s> becomes standby\n", l_ptr->name);
+		pr_info_ratelimited("New link <%s> becomes standby\n",
+				    l_ptr->name);
 		goto exit;
 	}
 	tipc_link_dup_queue_xmit(active[0], l_ptr);
@@ -247,9 +248,10 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		active[0] = l_ptr;
 		goto exit;
 	}
-	pr_info("Old link <%s> becomes standby\n", active[0]->name);
+	pr_info_ratelimited("Old link <%s> becomes standby\n", active[0]->name);
 	if (active[1] != active[0])
-		pr_info("Old link <%s> becomes standby\n", active[1]->name);
+		pr_info_ratelimited("Old link <%s> becomes standby\n",
+				    active[1]->name);
 	active[0] = active[1] = l_ptr;
 exit:
 	/* Leave room for changeover header when returning 'mtu' to users: */
@@ -297,12 +299,12 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	n_ptr->link_id = l_ptr->peer_bearer_id << 16 | l_ptr->bearer_id;
 
 	if (!tipc_link_is_active(l_ptr)) {
-		pr_info("Lost standby link <%s> on network plane %c\n",
-			l_ptr->name, l_ptr->net_plane);
+		pr_info_ratelimited("Lost standby link <%s> on network plane %c\n",
+				    l_ptr->name, l_ptr->net_plane);
 		return;
 	}
-	pr_info("Lost link <%s> on network plane %c\n",
-		l_ptr->name, l_ptr->net_plane);
+	pr_info_ratelimited("Lost link <%s> on network plane %c\n",
+			    l_ptr->name, l_ptr->net_plane);
 
 	active = &n_ptr->active_links[0];
 	if (active[0] == l_ptr)
@@ -380,8 +382,8 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	char addr_string[16];
 	u32 i;
 
-	pr_info("Lost contact with %s\n",
-		tipc_addr_string_fill(addr_string, n_ptr->addr));
+	pr_info_ratelimited("Lost contact with %s\n",
+			    tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	/* Flush broadcast link info associated with lost node */
 	if (n_ptr->bclink.recv_permitted) {
-- 
2.1.3


------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
