From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 1/2] tipc: add support for link state subscriptions
Date: Thu, 24 Apr 2014 16:26:46 +0200
Message-ID: <1398349607-16012-2-git-send-email-erik.hugne@ericsson.com>
References: <1398349607-16012-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:64907 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756972AbaDXOZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:25:46 -0400
In-Reply-To: <1398349607-16012-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

When links are established over a bearer plane, we create a node
local publication containing information about the peer node and
bearer plane. This allows TIPC applications to use the standard
TIPC topology server subscription mechanism to get notifications
when a link goes up or down.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/uapi/linux/tipc.h | 1 +
 net/tipc/node.c           | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index 852373d..53cd790 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -87,6 +87,7 @@ static inline unsigned int tipc_node(__u32 addr)
 
 #define TIPC_CFG_SRV		0	/* configuration service name type */
 #define TIPC_TOP_SRV		1	/* topology service name type */
+#define TIPC_LINK_STATE		2	/* link state name type */
 #define TIPC_RESERVED_TYPES	64	/* lowest user-publishable name type */
 
 /*
diff --git a/net/tipc/node.c b/net/tipc/node.c
index be90115..3b86a74 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -144,9 +144,11 @@ void tipc_node_stop(void)
 void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
 	struct tipc_link **active = &n_ptr->active_links[0];
+	u32 addr = n_ptr->addr;
 
 	n_ptr->working_links++;
-
+	tipc_nametbl_publish(TIPC_LINK_STATE, addr, addr, TIPC_NODE_SCOPE,
+			     l_ptr->bearer_id, addr);
 	pr_info("Established link <%s> on network plane %c\n",
 		l_ptr->name, l_ptr->net_plane);
 
@@ -203,8 +205,10 @@ static void node_select_active_links(struct tipc_node *n_ptr)
 void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
 	struct tipc_link **active;
+	u32 addr = n_ptr->addr;
 
 	n_ptr->working_links--;
+	tipc_nametbl_withdraw(TIPC_LINK_STATE, addr, l_ptr->bearer_id, addr);
 
 	if (!tipc_link_is_active(l_ptr)) {
 		pr_info("Lost standby link <%s> on network plane %c\n",
-- 
1.8.3.2
