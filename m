From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/16] tipc: introduce publication lists struct
Date: Fri, 20 Apr 2012 17:05:09 -0400
Message-ID: <1334955924-907-2-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65441 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab2DTVF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:27 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

There is currently a single list that is containing both cluster-scope and
zone-scope publications, and the list count is a separate free floating
variable.  Create a struct to bind the count to the list, and to pave
the way for factoring out the publications into zone/cluster/node scope.

The current "publ_root" most matches what will be the cluster scope
list, so it is named accordingly in this commit.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |   27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index d57da61..870a001 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -68,12 +68,19 @@ struct distr_item {
 };
 
 /**
- * List of externally visible publications by this node --
- * that is, all publications having scope > TIPC_NODE_SCOPE.
+ * struct publ_list - list of publications made by this node
+ * @list: circular list of publications
+ * @list_size: number of entries in list
  */
+struct publ_list {
+	struct list_head list;
+	u32 size;
+};
 
-static LIST_HEAD(publ_root);
-static u32 publ_cnt;
+static struct publ_list publ_cluster = {
+	.list = LIST_HEAD_INIT(publ_cluster.list),
+	.size = 0,
+};
 
 /**
  * publ_to_item - add publication info to a publication message
@@ -132,8 +139,8 @@ void tipc_named_publish(struct publication *publ)
 	struct sk_buff *buf;
 	struct distr_item *item;
 
-	list_add_tail(&publ->local_list, &publ_root);
-	publ_cnt++;
+	list_add_tail(&publ->local_list, &publ_cluster.list);
+	publ_cluster.size++;
 
 	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
 	if (!buf) {
@@ -156,7 +163,7 @@ void tipc_named_withdraw(struct publication *publ)
 	struct distr_item *item;
 
 	list_del(&publ->local_list);
-	publ_cnt--;
+	publ_cluster.size--;
 
 	buf = named_prepare_buf(WITHDRAWAL, ITEM_SIZE, 0);
 	if (!buf) {
@@ -207,9 +214,9 @@ void tipc_named_node_up(unsigned long nodearg)
 	INIT_LIST_HEAD(&message_list);
 
 	read_lock_bh(&tipc_nametbl_lock);
-	rest = publ_cnt * ITEM_SIZE;
+	rest = publ_cluster.size * ITEM_SIZE;
 
-	list_for_each_entry(publ, &publ_root, local_list) {
+	list_for_each_entry(publ, &publ_cluster.list, local_list) {
 		if (!buf) {
 			left = (rest <= max_item_buf) ? rest : max_item_buf;
 			rest -= left;
@@ -329,7 +336,7 @@ void tipc_named_reinit(void)
 
 	write_lock_bh(&tipc_nametbl_lock);
 
-	list_for_each_entry(publ, &publ_root, local_list)
+	list_for_each_entry(publ, &publ_cluster.list, local_list)
 		publ->node = tipc_own_addr;
 
 	write_unlock_bh(&tipc_nametbl_lock);
-- 
1.7.9.3
