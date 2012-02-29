From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/17] tipc: Detect duplicate nodes using different network interfaces
Date: Wed, 29 Feb 2012 18:18:28 -0500
Message-ID: <1330557523-2024-3-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53929 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965106Ab2B2XS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:18:57 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Utilizes the new "node signature" field in neighbor discovery messages
to ensure that all links TIPC associates with a given <Z.C.N> network
address belong to the same neighboring node. (Previously, TIPC could not
tell if link setup requests arriving on different interfaces were from
the same node or from two different nodes that has mistakenly been assigned
the same network address.)

The revised algorithm for detecting a duplicate node considers both the
node signature and the network interface adddress specified in a request
message when deciding how to respond to a link setup request. This prevents
false alarms that might otherwise arise during normal network operation
under the following scenarios:

a) A neighboring node reboots. (The node's signature changes, but the
network interface address remains unchanged.)

b) A neighboring node's network interface is replaced. (The node's signature
remains unchanged, but the network interface address changes.)

c) A neighboring node is completely replaced. (The node's signature and
network interface address both change.)

The algorithm also handles cases in which a node reboots and re-establishes
its links to TIPC (or begins re-establishing those links) before TIPC
detects that it is using a new node signature. In such cases of "delayed
rediscovery" TIPC simply accepts the new signature without disrupting
communication that is already underway over the links.

Thanks to Laser [gotolaser@gmail.com] for his contributions to the
development of this enhancement.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |   72 +++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 58 insertions(+), 14 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 7ae1b4c..f5f9bf7 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -122,7 +122,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 {
 	struct tipc_node *n_ptr;
 	struct tipc_link *link;
-	struct tipc_media_addr media_addr, *addr;
+	struct tipc_media_addr media_addr;
 	struct sk_buff *rbuf;
 	struct tipc_msg *msg = buf_msg(buf);
 	u32 dest = msg_dest_domain(msg);
@@ -130,13 +130,14 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	u32 net_id = msg_bc_netid(msg);
 	u32 type = msg_type(msg);
 	u32 signature = msg_node_sig(msg);
+	int addr_mismatch;
 	int link_fully_up;
 
 	media_addr.broadcast = 1;
 	b_ptr->media->msg2addr(&media_addr, msg_media_addr(msg));
 	buf_discard(buf);
 
-	/* Validate discovery message from requesting node */
+	/* Ensure message from node is valid and communication is permitted */
 	if (net_id != tipc_net_id)
 		return;
 	if (media_addr.broadcast)
@@ -164,15 +165,50 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	}
 	tipc_node_lock(n_ptr);
 
+	/* Prepare to validate requesting node's signature and media address */
 	link = n_ptr->links[b_ptr->identity];
+	addr_mismatch = (link != NULL) &&
+		memcmp(&link->media_addr, &media_addr, sizeof(media_addr));
 
-	/* Create a link endpoint for this bearer, if necessary */
-	if (!link) {
-		link = tipc_link_create(n_ptr, b_ptr, &media_addr);
-		if (!link) {
+	/*
+	 * Ensure discovery message's signature is correct
+	 *
+	 * If signature is incorrect and there is no working link to the node,
+	 * accept the new signature but invalidate all existing links to the
+	 * node so they won't re-activate without a new discovery message.
+	 *
+	 * If signature is incorrect and the requested link to the node is
+	 * working, accept the new signature. (This is an instance of delayed
+	 * rediscovery, where a link endpoint was able to re-establish contact
+	 * with its peer endpoint on a node that rebooted before receiving a
+	 * discovery message from that node.)
+	 *
+	 * If signature is incorrect and there is a working link to the node
+	 * that is not the requested link, reject the request (must be from
+	 * a duplicate node).
+	 */
+	if (signature != n_ptr->signature) {
+		if (n_ptr->working_links == 0) {
+			struct tipc_link *curr_link;
+			int i;
+
+			for (i = 0; i < MAX_BEARERS; i++) {
+				curr_link = n_ptr->links[i];
+				if (curr_link) {
+					memset(&curr_link->media_addr, 0,
+					       sizeof(media_addr));
+					tipc_link_reset(curr_link);
+				}
+			}
+			addr_mismatch = (link != NULL);
+		} else if (tipc_link_is_up(link) && !addr_mismatch) {
+			/* delayed rediscovery */
+		} else {
+			disc_dupl_alert(b_ptr, orig, &media_addr);
 			tipc_node_unlock(n_ptr);
 			return;
 		}
+		n_ptr->signature = signature;
 	}
 
 	/*
@@ -185,21 +221,29 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	 * the new media address and reset the link to ensure it starts up
 	 * cleanly.
 	 */
-	addr = &link->media_addr;
-	if (memcmp(addr, &media_addr, sizeof(*addr))) {
-		if (tipc_link_is_up(link) || (!link->started)) {
+
+	if (addr_mismatch) {
+		if (tipc_link_is_up(link)) {
 			disc_dupl_alert(b_ptr, orig, &media_addr);
 			tipc_node_unlock(n_ptr);
 			return;
+		} else {
+			memcpy(&link->media_addr, &media_addr,
+			       sizeof(media_addr));
+			tipc_link_reset(link);
+		}
+	}
+
+	/* Create a link endpoint for this bearer, if necessary */
+	if (!link) {
+		link = tipc_link_create(n_ptr, b_ptr, &media_addr);
+		if (!link) {
+			tipc_node_unlock(n_ptr);
+			return;
 		}
-		warn("Resetting link <%s>, peer interface address changed\n",
-		     link->name);
-		memcpy(addr, &media_addr, sizeof(*addr));
-		tipc_link_reset(link);
 	}
 
 	/* Accept discovery message & send response, if necessary */
-	n_ptr->signature = signature;
 	link_fully_up = link_working_working(link);
 
 	if ((type == DSC_REQ_MSG) && !link_fully_up && !b_ptr->blocked) {
-- 
1.7.9.1
