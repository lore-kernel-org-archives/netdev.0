From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 1/2] tipc: fix excessive network event logging
Date: Thu, 22 Jan 2015 17:10:31 +0100
Message-ID: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<jon.maloy@ericsson.com>, <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:64141 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675AbbAVQOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 11:14:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

If a large number of namespaces is spawned on a node and TIPC is
enabled in each of these, the excessive printk tracing of network
events will cause the system to grind down to a near halt.
The traces are still of debug value, so instead of removing them
completely we fix it by changing the link state and node availability
logging debug traces.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/link.c | 20 ++++++++++----------
 net/tipc/node.c | 22 +++++++++++-----------
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 193bc15..2846ad80 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -538,8 +538,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv / 4);
 			break;
 		case RESET_MSG:
-			pr_info("%s<%s>, requested by peer\n", link_rst_msg,
-				l_ptr->name);
+			pr_debug("%s<%s>, requested by peer\n",
+				 link_rst_msg, l_ptr->name);
 			tipc_link_reset(l_ptr);
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
@@ -549,7 +549,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		default:
-			pr_err("%s%u in WW state\n", link_unk_evt, event);
+			pr_debug("%s%u in WW state\n", link_unk_evt, event);
 		}
 		break;
 	case WORKING_UNKNOWN:
@@ -561,8 +561,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		case RESET_MSG:
-			pr_info("%s<%s>, requested by peer while probing\n",
-				link_rst_msg, l_ptr->name);
+			pr_debug("%s<%s>, requested by peer while probing\n",
+				 link_rst_msg, l_ptr->name);
 			tipc_link_reset(l_ptr);
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
@@ -588,8 +588,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 				l_ptr->fsm_msg_cnt++;
 				link_set_timer(l_ptr, cont_intv / 4);
 			} else {	/* Link has failed */
-				pr_warn("%s<%s>, peer not responding\n",
-					link_rst_msg, l_ptr->name);
+				pr_debug("%s<%s>, peer not responding\n",
+					 link_rst_msg, l_ptr->name);
 				tipc_link_reset(l_ptr);
 				l_ptr->state = RESET_UNKNOWN;
 				l_ptr->fsm_msg_cnt = 0;
@@ -1568,9 +1568,9 @@ static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
 
 		if (msg_linkprio(msg) &&
 		    (msg_linkprio(msg) != l_ptr->priority)) {
-			pr_warn("%s<%s>, priority change %u->%u\n",
-				link_rst_msg, l_ptr->name, l_ptr->priority,
-				msg_linkprio(msg));
+			pr_debug("%s<%s>, priority change %u->%u\n",
+				 link_rst_msg, l_ptr->name,
+				 l_ptr->priority, msg_linkprio(msg));
 			l_ptr->priority = msg_linkprio(msg);
 			tipc_link_reset(l_ptr); /* Enforce change to take effect */
 			break;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index b1eb092..ee5d33c 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -230,8 +230,8 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	n_ptr->action_flags |= TIPC_NOTIFY_LINK_UP;
 	n_ptr->link_id = l_ptr->peer_bearer_id << 16 | l_ptr->bearer_id;
 
-	pr_info("Established link <%s> on network plane %c\n",
-		l_ptr->name, l_ptr->net_plane);
+	pr_debug("Established link <%s> on network plane %c\n",
+		 l_ptr->name, l_ptr->net_plane);
 
 	if (!active[0]) {
 		active[0] = active[1] = l_ptr;
@@ -239,7 +239,7 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		goto exit;
 	}
 	if (l_ptr->priority < active[0]->priority) {
-		pr_info("New link <%s> becomes standby\n", l_ptr->name);
+		pr_debug("New link <%s> becomes standby\n", l_ptr->name);
 		goto exit;
 	}
 	tipc_link_dup_queue_xmit(active[0], l_ptr);
@@ -247,9 +247,9 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		active[0] = l_ptr;
 		goto exit;
 	}
-	pr_info("Old link <%s> becomes standby\n", active[0]->name);
+	pr_debug("Old link <%s> becomes standby\n", active[0]->name);
 	if (active[1] != active[0])
-		pr_info("Old link <%s> becomes standby\n", active[1]->name);
+		pr_debug("Old link <%s> becomes standby\n", active[1]->name);
 	active[0] = active[1] = l_ptr;
 exit:
 	/* Leave room for changeover header when returning 'mtu' to users: */
@@ -297,12 +297,12 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	n_ptr->link_id = l_ptr->peer_bearer_id << 16 | l_ptr->bearer_id;
 
 	if (!tipc_link_is_active(l_ptr)) {
-		pr_info("Lost standby link <%s> on network plane %c\n",
-			l_ptr->name, l_ptr->net_plane);
+		pr_debug("Lost standby link <%s> on network plane %c\n",
+			 l_ptr->name, l_ptr->net_plane);
 		return;
 	}
-	pr_info("Lost link <%s> on network plane %c\n",
-		l_ptr->name, l_ptr->net_plane);
+	pr_debug("Lost link <%s> on network plane %c\n",
+		 l_ptr->name, l_ptr->net_plane);
 
 	active = &n_ptr->active_links[0];
 	if (active[0] == l_ptr)
@@ -380,8 +380,8 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	char addr_string[16];
 	u32 i;
 
-	pr_info("Lost contact with %s\n",
-		tipc_addr_string_fill(addr_string, n_ptr->addr));
+	pr_debug("Lost contact with %s\n",
+		 tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	/* Flush broadcast link info associated with lost node */
 	if (n_ptr->bclink.recv_permitted) {
-- 
2.1.3
