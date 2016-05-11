From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: eliminate risk of double link_up events
Date: Wed, 11 May 2016 19:15:45 -0400
Message-ID: <1463008545-28994-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:48107 "EHLO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751580AbcEKXQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 19:16:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an ACTIVATE or data packet is received in a link in state
ESTABLISHING, the link does not immediately change state to
ESTABLISHED, but does instead return a LINK_UP event to the caller,
which will execute the state change in a different lock context.

This non-atomic approach incurs a low risk that we may have two
LINK_UP events pending simultaneously for the same link, resulting
in the final part of the setup procedure being executed twice. The
only potential harm caused by this it that we may see two LINK_UP
events issued to subsribers of the topology server, something that
may cause confusion.

This commit eliminates this risk by checking if the link is already
up before proceeding with the second half of the setup.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index d903f56..e01e2c71 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -542,7 +542,7 @@ static void __tipc_node_link_up(struct tipc_node *n, int bearer_id,
 	struct tipc_link *ol = node_active_link(n, 0);
 	struct tipc_link *nl = n->links[bearer_id].link;
 
-	if (!nl)
+	if (!nl || tipc_link_is_up(nl))
 		return;
 
 	tipc_link_fsm_evt(nl, LINK_ESTABLISH_EVT);
-- 
1.9.1
