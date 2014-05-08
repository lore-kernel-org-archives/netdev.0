From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 2/2] tipc: don't directly overwrite node action_flags
Date: Thu, 8 May 2014 08:54:40 +0800
Message-ID: <1399510480-29558-3-git-send-email-ying.xue@windriver.com>
References: <1399510480-29558-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53184 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbaEHAzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 20:55:01 -0400
In-Reply-To: <1399510480-29558-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each node action flag should be set or cleared separately, instead
we now set the whole flags variable in one shot, and it's turned
out to be hard to see which other flags are affected. Therefore,
for instance, we explicitly clear TIPC_WAIT_OWN_LINKS_DOWN bit in
node_lost_contact().

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |    2 +-
 net/tipc/node.c |    6 ++++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 26abb16..2140837 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1853,7 +1853,7 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf)
 			 * peer has lost contact -- don't allow peer's links
 			 * to reactivate before we recognize loss & clean up
 			 */
-			l_ptr->owner->action_flags = TIPC_WAIT_OWN_LINKS_DOWN;
+			l_ptr->owner->action_flags |= TIPC_WAIT_OWN_LINKS_DOWN;
 		}
 
 		link_state_event(l_ptr, RESET_MSG);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index bb66a26..facd561 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -308,11 +308,13 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		tipc_link_reset_fragments(l_ptr);
 	}
 
+	n_ptr->action_flags &= ~TIPC_WAIT_OWN_LINKS_DOWN;
+
 	/* Notify subscribers and prevent re-contact with node until
 	 * cleanup is done.
 	 */
-	n_ptr->action_flags = TIPC_WAIT_PEER_LINKS_DOWN |
-			      TIPC_NOTIFY_NODE_DOWN;
+	n_ptr->action_flags |= TIPC_WAIT_PEER_LINKS_DOWN |
+			       TIPC_NOTIFY_NODE_DOWN;
 }
 
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
-- 
1.7.9.5
