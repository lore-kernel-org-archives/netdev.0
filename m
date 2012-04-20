From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/16] tipc: Factor out name publication code to a separate function
Date: Fri, 20 Apr 2012 17:05:10 -0400
Message-ID: <1334955924-907-3-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62187 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab2DTVF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:28 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

This is done so that it can be reused with differing publication
lists, instead of being hard coded to the cluster publicaton list.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |   61 +++++++++++++++++++++++++++----------------------
 1 file changed, 34 insertions(+), 27 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 870a001..3be0eb9 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -176,6 +176,39 @@ void tipc_named_withdraw(struct publication *publ)
 	named_cluster_distribute(buf);
 }
 
+/*
+ * named_distribute - prepare name info for bulk distribution to another node
+ */
+static void named_distribute(struct list_head *message_list, u32 node,
+			     struct publ_list *pls, u32 max_item_buf)
+{
+	struct publication *publ;
+	struct sk_buff *buf = NULL;
+	struct distr_item *item = NULL;
+	u32 left = 0;
+	u32 rest = pls->size * ITEM_SIZE;
+
+	list_for_each_entry(publ, &pls->list, local_list) {
+		if (!buf) {
+			left = (rest <= max_item_buf) ? rest : max_item_buf;
+			rest -= left;
+			buf = named_prepare_buf(PUBLICATION, left, node);
+			if (!buf) {
+				warn("Bulk publication failure\n");
+				return;
+			}
+			item = (struct distr_item *)msg_data(buf_msg(buf));
+		}
+		publ_to_item(item, publ);
+		item++;
+		left -= ITEM_SIZE;
+		if (!left) {
+			list_add_tail((struct list_head *)buf, message_list);
+			buf = NULL;
+		}
+	}
+}
+
 /**
  * tipc_named_node_up - tell specified node about all publications by this node
  */
@@ -184,13 +217,8 @@ void tipc_named_node_up(unsigned long nodearg)
 {
 	struct tipc_node *n_ptr;
 	struct tipc_link *l_ptr;
-	struct publication *publ;
-	struct distr_item *item = NULL;
-	struct sk_buff *buf = NULL;
 	struct list_head message_list;
 	u32 node = (u32)nodearg;
-	u32 left = 0;
-	u32 rest;
 	u32 max_item_buf = 0;
 
 	/* compute maximum amount of publication data to send per message */
@@ -214,28 +242,7 @@ void tipc_named_node_up(unsigned long nodearg)
 	INIT_LIST_HEAD(&message_list);
 
 	read_lock_bh(&tipc_nametbl_lock);
-	rest = publ_cluster.size * ITEM_SIZE;
-
-	list_for_each_entry(publ, &publ_cluster.list, local_list) {
-		if (!buf) {
-			left = (rest <= max_item_buf) ? rest : max_item_buf;
-			rest -= left;
-			buf = named_prepare_buf(PUBLICATION, left, node);
-			if (!buf) {
-				warn("Bulk publication distribution failure\n");
-				goto exit;
-			}
-			item = (struct distr_item *)msg_data(buf_msg(buf));
-		}
-		publ_to_item(item, publ);
-		item++;
-		left -= ITEM_SIZE;
-		if (!left) {
-			list_add_tail((struct list_head *)buf, &message_list);
-			buf = NULL;
-		}
-	}
-exit:
+	named_distribute(&message_list, node, &publ_cluster, max_item_buf);
 	read_unlock_bh(&tipc_nametbl_lock);
 
 	tipc_link_send_names(&message_list, (u32)node);
-- 
1.7.9.3
