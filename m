From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 5/9] tipc: remove supportable flag from bclink structure
Date: Thu, 22 Nov 2012 15:59:50 -0500
Message-ID: <1353617994-3962-6-git-send-email-paul.gortmaker@windriver.com>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Ying Xue <ying.xue@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43255 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932575Ab2KVVAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:15 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

The "supportable" flag in bclink structure is a compatibility flag
indicating whether a peer node is capable of receiving TIPC broadcast
messages. However, all TIPC versions since tipc-1.5, and after the
inclusion in the upstream Linux kernel in 2006, support this capability.
It is highly unlikely that anybody is still using such an old
version of TIPC, let alone that they want to mix it with TIPC-2.0
nodes. Therefore, we now remove the "supportable" flag.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c | 4 +---
 net/tipc/node.c | 8 +++-----
 net/tipc/node.h | 2 --
 3 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 0cc6480..f3a078f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1426,8 +1426,7 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
 		pr_info("Broadcast link info for %s\n", addr_string);
-		pr_info("Supportable: %d,  Supported: %d,  Acked: %u\n",
-			n_ptr->bclink.supportable,
+		pr_info("Supported: %d,  Acked: %u\n",
 			n_ptr->bclink.supported,
 			n_ptr->bclink.acked);
 		pr_info("Last in: %u,  Oos state: %u,  Last sent: %u\n",
@@ -2014,7 +2013,6 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		} else {
 			l_ptr->max_pkt = l_ptr->max_pkt_target;
 		}
-		l_ptr->owner->bclink.supportable = (max_pkt_info != 0);
 
 		/* Synchronize broadcast link info, if not done previously */
 		if (!tipc_node_is_up(l_ptr->owner)) {
diff --git a/net/tipc/node.c b/net/tipc/node.c
index d21db20..6f3e9b3 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -264,11 +264,9 @@ static void node_established_contact(struct tipc_node *n_ptr)
 {
 	tipc_k_signal((Handler)tipc_named_node_up, n_ptr->addr);
 
-	if (n_ptr->bclink.supportable) {
-		n_ptr->bclink.acked = tipc_bclink_get_last_sent();
-		tipc_bclink_add_node(n_ptr->addr);
-		n_ptr->bclink.supported = 1;
-	}
+	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
+	tipc_bclink_add_node(n_ptr->addr);
+	n_ptr->bclink.supported = 1;
 }
 
 static void node_name_purge_complete(unsigned long node_addr)
diff --git a/net/tipc/node.h b/net/tipc/node.h
index cfcaf4d..3ac905f 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -67,7 +67,6 @@
  * @permit_changeover: non-zero if node has redundant links to this system
  * @signature: node instance identifier
  * @bclink: broadcast-related info
- *    @supportable: non-zero if node supports TIPC b'cast link capability
  *    @supported: non-zero if node supports TIPC b'cast capability
  *    @acked: sequence # of last outbound b'cast message acknowledged by node
  *    @last_in: sequence # of last in-sequence b'cast message received from node
@@ -92,7 +91,6 @@ struct tipc_node {
 	int permit_changeover;
 	u32 signature;
 	struct {
-		u8 supportable;
 		u8 supported;
 		u32 acked;
 		u32 last_in;
-- 
1.7.12.1
