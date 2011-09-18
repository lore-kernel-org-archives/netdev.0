From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 23/28] tipc: relocate/coalesce node cast in tipc_named_node_up
Date: Sat, 17 Sep 2011 23:32:19 -0400
Message-ID: <1316316744-29514-24-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50001 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756393Ab1IRDdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:33:00 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions like this are called using unsigned longs from
function pointers.  In this case, the function is passed in
a node which is normally internally treated as a u32 by TIPC.

Rather than add more casts into this function in the future
for each added use of node within, move the cast to a single
place on a local.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 21bc028..97546f0 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -173,13 +173,14 @@ void tipc_named_withdraw(struct publication *publ)
  * tipc_named_node_up - tell specified node about all publications by this node
  */
 
-void tipc_named_node_up(unsigned long node)
+void tipc_named_node_up(unsigned long nodearg)
 {
 	struct tipc_node *n_ptr;
 	struct link *l_ptr;
 	struct publication *publ;
 	struct distr_item *item = NULL;
 	struct sk_buff *buf = NULL;
+	u32 node = (u32)nodearg;
 	u32 left = 0;
 	u32 rest;
 	u32 max_item_buf = 0;
@@ -187,7 +188,7 @@ void tipc_named_node_up(unsigned long node)
 	/* compute maximum amount of publication data to send per message */
 
 	read_lock_bh(&tipc_net_lock);
-	n_ptr = tipc_node_find((u32)node);
+	n_ptr = tipc_node_find(node);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->active_links[0];
-- 
1.7.4.4
