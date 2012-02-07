From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/15] tipc: Fix problem with broadcast link synchronization between nodes
Date: Mon,  6 Feb 2012 19:52:38 -0500
Message-ID: <1328575968-20643-6-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50175 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756130Ab2BGAxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:12 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Corrects a problem in which a link endpoint that activates as the
result of receiving a RESET/STATE sequence of link protocol messages
fails to properly record the broadcast link status information about
the node to which it is now communicating with. (The problem does
not occur with the more common RESET/ACTIVATE sequence of messages.)
The fix ensures that the broadcast link status info is updated after
the RESET message resets the link endpoint, rather than before, thereby
preventing new information from being overwritten by the reset operation.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 3405f56..1150ba5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2105,6 +2105,8 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 			l_ptr->owner->block_setup = WAIT_NODE_DOWN;
 		}
 
+		link_state_event(l_ptr, RESET_MSG);
+
 		/* fall thru' */
 	case ACTIVATE_MSG:
 		/* Update link settings according other endpoint's values */
@@ -2134,10 +2136,11 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		if (!tipc_node_is_up(l_ptr->owner))
 			l_ptr->owner->bclink.last_in = msg_last_bcast(msg);
 
-		link_state_event(l_ptr, msg_type(msg));
-
 		l_ptr->peer_session = msg_session(msg);
 		l_ptr->peer_bearer_id = msg_bearer_id(msg);
+
+		if (msg_type(msg) == ACTIVATE_MSG)
+			link_state_event(l_ptr, ACTIVATE_MSG);
 		break;
 	case STATE_MSG:
 
-- 
1.7.9
