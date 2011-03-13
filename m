From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/26] tipc: Fix problem with missing link in "tipc-config -l" output
Date: Sun, 13 Mar 2011 17:33:55 -0400
Message-ID: <1300052054-7531-8-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49877 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756359Ab1CMVei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:38 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Removes a race condition that could cause TIPC's internal counter
of the number of links it has to neighboring nodes to have the
incorrect value if two independent threads of control simultaneously
create new link endpoints connecting to two different nodes using two
different bearers. Such under counting would result in TIPC failing to
list the final link(s) in its response to a configuration request to
list all of the node's links. The counter is now updated atomically
to ensure that simultaneous increments do not interfere with each
other.

Thanks go to Peter Butler <pbutler@pt.com> for his assistance in
diagnosing and fixing this problem.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/net.c  |    3 ++-
 net/tipc/net.h  |    4 ++--
 net/tipc/node.c |    7 ++++---
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index 9bacfd0..dd78d86 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -2,7 +2,7 @@
  * net/tipc/net.c: TIPC network routing code
  *
  * Copyright (c) 1995-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -115,6 +115,7 @@ static int net_start(void)
 	tipc_net.nodes = kcalloc(tipc_max_nodes + 1,
 				 sizeof(*tipc_net.nodes), GFP_ATOMIC);
 	tipc_net.highest_node = 0;
+	atomic_set(&tipc_net.links, 0);
 
 	return tipc_net.nodes ? 0 : -ENOMEM;
 }
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 4ae59ad..aa431ef 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -2,7 +2,7 @@
  * net/tipc/net.h: Include file for TIPC network routing code
  *
  * Copyright (c) 1995-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -49,7 +49,7 @@ struct tipc_node;
 struct network {
 	struct tipc_node **nodes;
 	u32 highest_node;
-	u32 links;
+	atomic_t links;
 };
 
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 713ab5d..a24fad3 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -233,7 +233,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 
 		if (!n_ptr->links[bearer_id]) {
 			n_ptr->links[bearer_id] = l_ptr;
-			tipc_net.links++;
+			atomic_inc(&tipc_net.links);
 			n_ptr->link_cnt++;
 			return n_ptr;
 		}
@@ -247,7 +247,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr)
 {
 	n_ptr->links[l_ptr->b_ptr->identity] = NULL;
-	tipc_net.links--;
+	atomic_dec(&tipc_net.links);
 	n_ptr->link_cnt--;
 }
 
@@ -450,7 +450,8 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 	/* Get space for all unicast links + multicast link */
 
-	payload_size = TLV_SPACE(sizeof(link_info)) * (tipc_net.links + 1);
+	payload_size = TLV_SPACE(sizeof(link_info)) *
+		(atomic_read(&tipc_net.links) + 1);
 	if (payload_size > 32768u) {
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-- 
1.7.3.3

