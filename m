From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/15] tipc: Prevent broadcast link stalling in dual LAN environments
Date: Mon,  6 Feb 2012 19:52:36 -0500
Message-ID: <1328575968-20643-4-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50170 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529Ab2BGAxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:10 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensure that sequence number information about incoming broadcast link
messages is initialized only by the activation of the first link to a
given cluster node.  Previously, a race condition allowed reset and/or
activation messages for a second link to re-initialize this sequence
number information with obsolete values. This could trigger TIPC to
request the retransmission of previously acknowledged broadcast link
messages from that node, resulting in broadcast link processing becoming
stalled if the node had already released one or more of those messages
and was unable to perform the required retransmission.

Thanks to Laser <gotolaser@gmail.com> for identifying this problem
and assisting in the development of this fix.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index bee316c..4ea6cad 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2128,14 +2128,15 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		}
 		l_ptr->owner->bclink.supported = (max_pkt_info != 0);
 
+		/* Synchronize broadcast link info, if not done previously */
+
+		if (!tipc_node_is_up(l_ptr->owner))
+			l_ptr->owner->bclink.last_in = msg_last_bcast(msg);
+
 		link_state_event(l_ptr, msg_type(msg));
 
 		l_ptr->peer_session = msg_session(msg);
 		l_ptr->peer_bearer_id = msg_bearer_id(msg);
-
-		/* Synchronize broadcast sequence numbers */
-		if (!tipc_node_redundant_links(l_ptr->owner))
-			l_ptr->owner->bclink.last_in = mod(msg_last_bcast(msg));
 		break;
 	case STATE_MSG:
 
-- 
1.7.9
