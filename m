From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 01/13] tipc: eliminate case of writing to freed memory
Date: Wed, 25 Jun 2014 20:41:30 -0500
Message-ID: <1403746902-20408-2-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24114 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755308AbaFZBso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:48:44 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the function tipc_nodesub_notify() we call a function pointer
aggregated into the object to be notified, whereafter we set
the function pointer to NULL. However, in some cases the function
pointed to will free the struct containing the function pointer,
resulting in a write to already freed memory.

This bug seems to always have been there, without causing any
notable harm.

In this commit we fix the problem by inverting the order of the
zeroing and the function call.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node_subscr.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
index 7c59ab1..2d13eea 100644
--- a/net/tipc/node_subscr.c
+++ b/net/tipc/node_subscr.c
@@ -84,11 +84,13 @@ void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub)
 void tipc_nodesub_notify(struct list_head *nsub_list)
 {
 	struct tipc_node_subscr *ns, *safe;
+	net_ev_handler handle_node_down;
 
 	list_for_each_entry_safe(ns, safe, nsub_list, nodesub_list) {
-		if (ns->handle_node_down) {
-			ns->handle_node_down(ns->usr_handle);
+		handle_node_down = ns->handle_node_down;
+		if (handle_node_down) {
 			ns->handle_node_down = NULL;
+			handle_node_down(ns->usr_handle);
 		}
 	}
 }
-- 
1.7.9.5
