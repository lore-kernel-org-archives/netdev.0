From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 22/28] tipc: Prevent fragmented messages during initial name table exchange
Date: Sat, 17 Sep 2011 23:32:18 -0400
Message-ID: <1316316744-29514-23-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49999 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756378Ab1IRDc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:59 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Reduces the maximum size of messages sent during the initial exchange
of name table information between two nodes to be no larger than the
MTU of the first link established between the nodes. This ensures that
messages will never need to be fragmented, which would add unnecessary
overhead to the name table synchronization mechanism.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |   22 +++++++++++++++++++---
 1 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index cd356e5..21bc028 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -175,16 +175,32 @@ void tipc_named_withdraw(struct publication *publ)
 
 void tipc_named_node_up(unsigned long node)
 {
+	struct tipc_node *n_ptr;
+	struct link *l_ptr;
 	struct publication *publ;
 	struct distr_item *item = NULL;
 	struct sk_buff *buf = NULL;
 	u32 left = 0;
 	u32 rest;
-	u32 max_item_buf;
+	u32 max_item_buf = 0;
+
+	/* compute maximum amount of publication data to send per message */
+
+	read_lock_bh(&tipc_net_lock);
+	n_ptr = tipc_node_find((u32)node);
+	if (n_ptr) {
+		tipc_node_lock(n_ptr);
+		l_ptr = n_ptr->active_links[0];
+		if (l_ptr)
+			max_item_buf = ((l_ptr->max_pkt - INT_H_SIZE) /
+				ITEM_SIZE) * ITEM_SIZE;
+		tipc_node_unlock(n_ptr);
+	}
+	read_unlock_bh(&tipc_net_lock);
+	if (!max_item_buf)
+		return;
 
 	read_lock_bh(&tipc_nametbl_lock);
-	max_item_buf = TIPC_MAX_USER_MSG_SIZE / ITEM_SIZE;
-	max_item_buf *= ITEM_SIZE;
 	rest = publ_cnt * ITEM_SIZE;
 
 	list_for_each_entry(publ, &publ_root, local_list) {
-- 
1.7.4.4
