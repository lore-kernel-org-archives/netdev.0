From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 1/8] tipc: remove size variable from publ_list struct
Date: Tue, 2 Dec 2014 15:00:23 +0800
Message-ID: <1417503630-31352-2-git-send-email-ying.xue@windriver.com>
References: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <richard.alpe@ericsson.com>,
	<tero.aho@coriant.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47353 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbaLBHA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 02:00:59 -0500
In-Reply-To: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The size variable is introduced in publ_list struct to help us exactly
calculate SKB buffer sizes needed by publications when all publications
in name table are delivered in bulk in named_distribute(). But if
publication SKB buffer size is assumed to MTU, the size variable in
publ_list struct can be completely eliminated at the cost of wasting
a bit memory space for last SKB.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Tero Aho <tero.aho@coriant.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_distr.c |   19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 56248db..628cd85 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -41,26 +41,21 @@
 /**
  * struct publ_list - list of publications made by this node
  * @list: circular list of publications
- * @list_size: number of entries in list
  */
 struct publ_list {
 	struct list_head list;
-	u32 size;
 };
 
 static struct publ_list publ_zone = {
 	.list = LIST_HEAD_INIT(publ_zone.list),
-	.size = 0,
 };
 
 static struct publ_list publ_cluster = {
 	.list = LIST_HEAD_INIT(publ_cluster.list),
-	.size = 0,
 };
 
 static struct publ_list publ_node = {
 	.list = LIST_HEAD_INIT(publ_node.list),
-	.size = 0,
 };
 
 static struct publ_list *publ_lists[] = {
@@ -147,7 +142,6 @@ struct sk_buff *tipc_named_publish(struct publication *publ)
 	struct distr_item *item;
 
 	list_add_tail(&publ->local_list, &publ_lists[publ->scope]->list);
-	publ_lists[publ->scope]->size++;
 
 	if (publ->scope == TIPC_NODE_SCOPE)
 		return NULL;
@@ -172,7 +166,6 @@ struct sk_buff *tipc_named_withdraw(struct publication *publ)
 	struct distr_item *item;
 
 	list_del(&publ->local_list);
-	publ_lists[publ->scope]->size--;
 
 	if (publ->scope == TIPC_NODE_SCOPE)
 		return NULL;
@@ -200,16 +193,12 @@ static void named_distribute(struct sk_buff_head *list, u32 dnode,
 	struct publication *publ;
 	struct sk_buff *skb = NULL;
 	struct distr_item *item = NULL;
-	uint dsz = pls->size * ITEM_SIZE;
 	uint msg_dsz = (tipc_node_get_mtu(dnode, 0) / ITEM_SIZE) * ITEM_SIZE;
-	uint rem = dsz;
-	uint msg_rem = 0;
+	uint msg_rem = msg_dsz;
 
 	list_for_each_entry(publ, &pls->list, local_list) {
 		/* Prepare next buffer: */
 		if (!skb) {
-			msg_rem = min_t(uint, rem, msg_dsz);
-			rem -= msg_rem;
 			skb = named_prepare_buf(PUBLICATION, msg_rem, dnode);
 			if (!skb) {
 				pr_warn("Bulk publication failure\n");
@@ -227,8 +216,14 @@ static void named_distribute(struct sk_buff_head *list, u32 dnode,
 		if (!msg_rem) {
 			__skb_queue_tail(list, skb);
 			skb = NULL;
+			msg_rem = msg_dsz;
 		}
 	}
+	if (skb) {
+		msg_set_size(buf_msg(skb), INT_H_SIZE + (msg_dsz - msg_rem));
+		skb_trim(skb, INT_H_SIZE + (msg_dsz - msg_rem));
+		__skb_queue_tail(list, skb);
+	}
 }
 
 /**
-- 
1.7.9.5
