From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/17] tipc: Introduce node signature field in neighbor discovery message
Date: Wed, 29 Feb 2012 18:18:27 -0500
Message-ID: <1330557523-2024-2-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53922 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965089Ab2B2XS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:18:56 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Adds support for the new "node signature" in neighbor discovery messages,
which is a 16 bit identifier chosen randomly when TIPC is initialized.
This field makes it possible for nodes receiving a neighbor discovery
message to detect if multiple neighboring nodes are using the same network
address (i.e. <Z.C.N>), even when the messages are arriving on different
interfaces.

This first phase of node signature support creates the signature,
incorporates it into outgoing neighbor discovery messages, and tracks
the signature used by valid neighbors. An upcoming patch builds on this
foundation to implement the improved duplicate neighbor detection checking.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |    3 +++
 net/tipc/msg.h      |   10 ++++++++++
 net/tipc/node.c     |    1 +
 net/tipc/node.h     |    7 +++++++
 4 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index a00e5f8..7ae1b4c 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -82,6 +82,7 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
 		msg = buf_msg(buf);
 		tipc_msg_init(msg, LINK_CONFIG, type, INT_H_SIZE, dest_domain);
 		msg_set_non_seq(msg, 1);
+		msg_set_node_sig(msg, tipc_random);
 		msg_set_dest_domain(msg, dest_domain);
 		msg_set_bc_netid(msg, tipc_net_id);
 		b_ptr->media->addr2msg(&b_ptr->addr, msg_media_addr(msg));
@@ -128,6 +129,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	u32 orig = msg_prevnode(msg);
 	u32 net_id = msg_bc_netid(msg);
 	u32 type = msg_type(msg);
+	u32 signature = msg_node_sig(msg);
 	int link_fully_up;
 
 	media_addr.broadcast = 1;
@@ -197,6 +199,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	}
 
 	/* Accept discovery message & send response, if necessary */
+	n_ptr->signature = signature;
 	link_fully_up = link_working_working(link);
 
 	if ((type == DSC_REQ_MSG) && !link_fully_up && !b_ptr->blocked) {
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 7b0cda1..2ec13b7 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -517,6 +517,16 @@ static inline void msg_set_seq_gap(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 1, 16, 0x1fff, n);
 }
 
+static inline u32 msg_node_sig(struct tipc_msg *m)
+{
+	return msg_bits(m, 1, 0, 0xffff);
+}
+
+static inline void msg_set_node_sig(struct tipc_msg *m, u32 n)
+{
+	msg_set_bits(m, 1, 0, 0xffff, n);
+}
+
 
 /*
  * Word 2
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 7bc45e1..1534259 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -112,6 +112,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 	}
 	list_add_tail(&n_ptr->list, &temp_node->list);
 	n_ptr->block_setup = WAIT_PEER_DOWN;
+	n_ptr->signature = INVALID_NODE_SIG;
 
 	tipc_num_nodes++;
 
diff --git a/net/tipc/node.h b/net/tipc/node.h
index e1b78a2..7bf526a 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -42,6 +42,11 @@
 #include "net.h"
 #include "bearer.h"
 
+/*
+ * Out-of-range value for node signature
+ */
+#define INVALID_NODE_SIG 0x10000
+
 /* Flags used to block (re)establishment of contact with a neighboring node */
 
 #define WAIT_PEER_DOWN	0x0001	/* wait to see that peer's links are down */
@@ -61,6 +66,7 @@
  * @block_setup: bit mask of conditions preventing link establishment to node
  * @link_cnt: number of links to node
  * @permit_changeover: non-zero if node has redundant links to this system
+ * @signature: node instance identifier
  * @bclink: broadcast-related info
  *    @supportable: non-zero if node supports TIPC b'cast link capability
  *    @supported: non-zero if node supports TIPC b'cast capability
@@ -86,6 +92,7 @@ struct tipc_node {
 	int working_links;
 	int block_setup;
 	int permit_changeover;
+	u32 signature;
 	struct {
 		u8 supportable;
 		u8 supported;
-- 
1.7.9.1
