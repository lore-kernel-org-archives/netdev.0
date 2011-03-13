From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/26] tipc: Cosmetic changes to neighbor discovery logic
Date: Sun, 13 Mar 2011 17:34:04 -0400
Message-ID: <1300052054-7531-17-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49913 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235Ab1CMVev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:51 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Reworks the appearance of the routine that processes incoming
LINK_CONFIG messages to keep the main logic flow at a consistent level
of indentation, and to add comments outlining the various phases involved
in processing each message. This rework is being done to allow upcoming
enhancements to this routine to be integrated more cleanly.

The diff isn't really readable, so know that it was a case of the
old code being like:

	tipc_disc_recv_msg(..)
	{
		if (in_own_cluster(orig)) {
			...
			lines and lines of stuff
			...
		}
	}

which is now replaced with the more sane:

	tipc_disc_recv_msg(..)
	{
		if (!in_own_cluster(orig))
			return;
		...
		lines and lines of stuff
		...
	}

Instances of spin locking within the reindented block were replaced with
the identical tipc_node_[un]lock() abstractions.  Note that all these
changes are cosmetic in nature, and do not change the way LINK_CONFIG
messages are processed.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |  103 +++++++++++++++++++++++++++++----------------------
 1 files changed, 59 insertions(+), 44 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 09ce231..2345268 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -119,17 +119,21 @@ static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
 
 void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 {
+	struct tipc_node *n_ptr;
 	struct link *link;
-	struct tipc_media_addr media_addr;
+	struct tipc_media_addr media_addr, *addr;
+	struct sk_buff *rbuf;
 	struct tipc_msg *msg = buf_msg(buf);
 	u32 dest = msg_dest_domain(msg);
 	u32 orig = msg_prevnode(msg);
 	u32 net_id = msg_bc_netid(msg);
 	u32 type = msg_type(msg);
+	int link_fully_up;
 
 	msg_get_media_addr(msg, &media_addr);
 	buf_discard(buf);
 
+	/* Validate discovery message from requesting node */
 	if (net_id != tipc_net_id)
 		return;
 	if (!tipc_addr_domain_valid(dest))
@@ -143,56 +147,67 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	}
 	if (!tipc_in_scope(dest, tipc_own_addr))
 		return;
-	if (in_own_cluster(orig)) {
-		/* Always accept link here */
-		struct sk_buff *rbuf;
-		struct tipc_media_addr *addr;
-		struct tipc_node *n_ptr = tipc_node_find(orig);
-		int link_fully_up;
-
-		if (n_ptr == NULL) {
-			n_ptr = tipc_node_create(orig);
-			if (!n_ptr)
-				return;
-		}
-		spin_lock_bh(&n_ptr->lock);
-
-		/* Don't talk to neighbor during cleanup after last session */
+	if (!in_own_cluster(orig))
+		return;
 
-		if (n_ptr->cleanup_required) {
-			spin_unlock_bh(&n_ptr->lock);
+	/* Locate structure corresponding to requesting node */
+	n_ptr = tipc_node_find(orig);
+	if (!n_ptr) {
+		n_ptr = tipc_node_create(orig);
+		if (!n_ptr)
 			return;
-		}
+	}
+	tipc_node_lock(n_ptr);
+
+	/* Don't talk to neighbor during cleanup after last session */
+	if (n_ptr->cleanup_required) {
+		tipc_node_unlock(n_ptr);
+		return;
+	}
 
-		link = n_ptr->links[b_ptr->identity];
+	link = n_ptr->links[b_ptr->identity];
+
+	/* Create a link endpoint for this bearer, if necessary */
+	if (!link) {
+		link = tipc_link_create(b_ptr, orig, &media_addr);
 		if (!link) {
-			link = tipc_link_create(b_ptr, orig, &media_addr);
-			if (!link) {
-				spin_unlock_bh(&n_ptr->lock);
-				return;
-			}
-		}
-		addr = &link->media_addr;
-		if (memcmp(addr, &media_addr, sizeof(*addr))) {
-			if (tipc_link_is_up(link) || (!link->started)) {
-				disc_dupl_alert(b_ptr, orig, &media_addr);
-				spin_unlock_bh(&n_ptr->lock);
-				return;
-			}
-			warn("Resetting link <%s>, peer interface address changed\n",
-			     link->name);
-			memcpy(addr, &media_addr, sizeof(*addr));
-			tipc_link_reset(link);
+			tipc_node_unlock(n_ptr);
+			return;
 		}
-		link_fully_up = link_working_working(link);
-		spin_unlock_bh(&n_ptr->lock);
-		if ((type == DSC_RESP_MSG) || link_fully_up)
+	}
+
+	/*
+	 * Ensure requesting node's media address is correct
+	 *
+	 * If media address doesn't match and the link is working, reject the
+	 * request (must be from a duplicate node).
+	 *
+	 * If media address doesn't match and the link is not working, accept
+	 * the new media address and reset the link to ensure it starts up
+	 * cleanly.
+	 */
+	addr = &link->media_addr;
+	if (memcmp(addr, &media_addr, sizeof(*addr))) {
+		if (tipc_link_is_up(link) || (!link->started)) {
+			disc_dupl_alert(b_ptr, orig, &media_addr);
+			tipc_node_unlock(n_ptr);
 			return;
-		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, orig, b_ptr);
-		if (rbuf != NULL) {
-			b_ptr->media->send_msg(rbuf, b_ptr, &media_addr);
-			buf_discard(rbuf);
 		}
+		warn("Resetting link <%s>, peer interface address changed\n",
+		     link->name);
+		memcpy(addr, &media_addr, sizeof(*addr));
+		tipc_link_reset(link);
+	}
+
+	/* Accept discovery message & send response, if necessary */
+	link_fully_up = link_working_working(link);
+	tipc_node_unlock(n_ptr);
+	if ((type == DSC_RESP_MSG) || link_fully_up)
+		return;
+	rbuf = tipc_disc_init_msg(DSC_RESP_MSG, orig, b_ptr);
+	if (rbuf != NULL) {
+		b_ptr->media->send_msg(rbuf, b_ptr, &media_addr);
+		buf_discard(rbuf);
 	}
 }
 
-- 
1.7.3.3

