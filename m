From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 1/2] tipc: refactor name table updates out of named packet receive routine
Date: Mon, 25 Aug 2014 16:54:28 +0200
Message-ID: <1408978469-10584-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <jon.maloy@ericsson.com>, <ying.xue@windriver.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:51152 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933008AbaHYOt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:49:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

We need to perform the same actions when processing deferred name
table updates, so this functionality is moved to a separate
function.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/name_distr.c | 74 ++++++++++++++++++++++++++-------------------------
 1 file changed, 38 insertions(+), 36 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index dcc15bc..0591f33 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -263,52 +263,54 @@ static void named_purge_publ(struct publication *publ)
 }
 
 /**
+ * tipc_update_nametbl - try to process a nametable update and notify
+ *			 subscribers
+ *
+ * tipc_nametbl_lock must be held.
+ * Returns the publication item if successful, otherwise NULL.
+ */
+struct publication *tipc_update_nametbl(struct distr_item *i, u32 node,
+					u32 dtype)
+{
+	struct publication *publ = NULL;
+
+	if (dtype == PUBLICATION) {
+		publ = tipc_nametbl_insert_publ(ntohl(i->type), ntohl(i->lower),
+						ntohl(i->upper),
+						TIPC_CLUSTER_SCOPE, node,
+						ntohl(i->ref), ntohl(i->key));
+		if (publ) {
+			tipc_nodesub_subscribe(&publ->subscr, node, publ,
+					       (net_ev_handler)
+					       named_purge_publ);
+		}
+	} else if (dtype == WITHDRAWAL) {
+		publ = tipc_nametbl_remove_publ(ntohl(i->type), ntohl(i->lower),
+						node, ntohl(i->ref),
+						ntohl(i->key));
+		if (publ) {
+			tipc_nodesub_unsubscribe(&publ->subscr);
+			kfree(publ);
+		}
+	} else {
+		pr_warn("Unrecognized name table message received\n");
+	}
+	return publ;
+}
+
+/**
  * tipc_named_rcv - process name table update message sent by another node
  */
 void tipc_named_rcv(struct sk_buff *buf)
 {
-	struct publication *publ;
 	struct tipc_msg *msg = buf_msg(buf);
 	struct distr_item *item = (struct distr_item *)msg_data(msg);
 	u32 count = msg_data_sz(msg) / ITEM_SIZE;
 
 	write_lock_bh(&tipc_nametbl_lock);
 	while (count--) {
-		if (msg_type(msg) == PUBLICATION) {
-			publ = tipc_nametbl_insert_publ(ntohl(item->type),
-							ntohl(item->lower),
-							ntohl(item->upper),
-							TIPC_CLUSTER_SCOPE,
-							msg_orignode(msg),
-							ntohl(item->ref),
-							ntohl(item->key));
-			if (publ) {
-				tipc_nodesub_subscribe(&publ->subscr,
-						       msg_orignode(msg),
-						       publ,
-						       (net_ev_handler)
-						       named_purge_publ);
-			}
-		} else if (msg_type(msg) == WITHDRAWAL) {
-			publ = tipc_nametbl_remove_publ(ntohl(item->type),
-							ntohl(item->lower),
-							msg_orignode(msg),
-							ntohl(item->ref),
-							ntohl(item->key));
-
-			if (publ) {
-				tipc_nodesub_unsubscribe(&publ->subscr);
-				kfree(publ);
-			} else {
-				pr_err("Unable to remove publication by node 0x%x\n"
-				       " (type=%u, lower=%u, ref=%u, key=%u)\n",
-				       msg_orignode(msg), ntohl(item->type),
-				       ntohl(item->lower), ntohl(item->ref),
-				       ntohl(item->key));
-			}
-		} else {
-			pr_warn("Unrecognized name table message received\n");
-		}
+		tipc_update_nametbl(item, msg_orignode(msg),
+				    msg_type(msg));
 		item++;
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
-- 
1.8.3.2
