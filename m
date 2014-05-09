From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 7/8] tipc: clean up neigbor
	discovery message reception
Date: Fri,  9 May 2014 09:13:28 -0400
Message-ID: <1399641209-26112-8-git-send-email-jon.maloy@ericsson.com>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The function tipc_disc_rcv(), which is handling received neighbor
discovery messages, is perceived as messy, and it is hard to verify
its correctness by code inspection. The fact that the task it is set
to resolve is fairly complex does not make the situation better.

In this commit we try to take a more systematic approach to the
problem. We define a decision machine which takes three state flags
 as input, and produces three action flags as output. We then walk
through all permutations of the state flags, and for each of them we
describe verbally what is going on, plus that we set zero or more of
the action flags. The action flags indicate what should be done once
the decision machine has finished its job, while the last part of the
function deals with performing those actions.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/discover.c |  219 ++++++++++++++++++++++++++-------------------------
 1 file changed, 111 insertions(+), 108 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index b15cbed..aa722a4 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/discover.c
  *
- * Copyright (c) 2003-2006, Ericsson AB
+ * Copyright (c) 2003-2006, 2014, Ericsson AB
  * Copyright (c) 2005-2006, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -106,147 +106,150 @@ static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
 }
 
 /**
- * tipc_disc_rcv - handle incoming link setup message (request or response)
+ * tipc_disc_rcv - handle incoming discovery message (request or response)
  * @buf: buffer containing message
- * @b_ptr: bearer that message arrived on
+ * @bearer: bearer that message arrived on
  */
-void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *b_ptr)
+void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *bearer)
 {
-	struct tipc_node *n_ptr;
+	struct tipc_node *node;
 	struct tipc_link *link;
-	struct tipc_media_addr media_addr;
+	struct tipc_media_addr maddr;
 	struct sk_buff *rbuf;
 	struct tipc_msg *msg = buf_msg(buf);
-	u32 dest = msg_dest_domain(msg);
-	u32 orig = msg_prevnode(msg);
+	u32 ddom = msg_dest_domain(msg);
+	u32 onode = msg_prevnode(msg);
 	u32 net_id = msg_bc_netid(msg);
-	u32 type = msg_type(msg);
+	u32 mtyp = msg_type(msg);
 	u32 signature = msg_node_sig(msg);
-	int addr_mismatch;
-	int link_fully_up;
-
-	media_addr.broadcast = 1;
-	b_ptr->media->msg2addr(b_ptr, &media_addr, msg_media_addr(msg));
+	bool addr_match = false;
+	bool sign_match = false;
+	bool link_up = false;
+	bool accept_addr = false;
+	bool accept_sign = false;
+	bool respond = false;
+
+	bearer->media->msg2addr(bearer, &maddr, msg_media_addr(msg));
 	kfree_skb(buf);
 
 	/* Ensure message from node is valid and communication is permitted */
 	if (net_id != tipc_net_id)
 		return;
-	if (media_addr.broadcast)
+	if (maddr.broadcast)
 		return;
-	if (!tipc_addr_domain_valid(dest))
+	if (!tipc_addr_domain_valid(ddom))
 		return;
-	if (!tipc_addr_node_valid(orig))
+	if (!tipc_addr_node_valid(onode))
 		return;
-	if (orig == tipc_own_addr) {
-		if (memcmp(&media_addr, &b_ptr->addr, sizeof(media_addr)))
-			disc_dupl_alert(b_ptr, tipc_own_addr, &media_addr);
+
+	if (in_own_node(onode)) {
+		if (memcmp(&maddr, &bearer->addr, sizeof(maddr)))
+			disc_dupl_alert(bearer, tipc_own_addr, &maddr);
 		return;
 	}
-	if (!tipc_in_scope(dest, tipc_own_addr))
+	if (!tipc_in_scope(ddom, tipc_own_addr))
 		return;
-	if (!tipc_in_scope(b_ptr->domain, orig))
+	if (!tipc_in_scope(bearer->domain, onode))
 		return;
 
-	/* Locate structure corresponding to requesting node */
-	n_ptr = tipc_node_find(orig);
-	if (!n_ptr) {
-		n_ptr = tipc_node_create(orig);
-		if (!n_ptr)
-			return;
-	}
-	tipc_node_lock(n_ptr);
+	/* Locate, or if necessary, create, node: */
+	node = tipc_node_find(onode);
+	if (!node)
+		node = tipc_node_create(onode);
+	if (!node)
+		return;
 
-	/* Prepare to validate requesting node's signature and media address */
-	link = n_ptr->links[b_ptr->identity];
-	addr_mismatch = (link != NULL) &&
-		memcmp(&link->media_addr, &media_addr, sizeof(media_addr));
+	tipc_node_lock(node);
+	link = node->links[bearer->identity];
 
-	/*
-	 * Ensure discovery message's signature is correct
-	 *
-	 * If signature is incorrect and there is no working link to the node,
-	 * accept the new signature but invalidate all existing links to the
-	 * node so they won't re-activate without a new discovery message.
-	 *
-	 * If signature is incorrect and the requested link to the node is
-	 * working, accept the new signature. (This is an instance of delayed
-	 * rediscovery, where a link endpoint was able to re-establish contact
-	 * with its peer endpoint on a node that rebooted before receiving a
-	 * discovery message from that node.)
-	 *
-	 * If signature is incorrect and there is a working link to the node
-	 * that is not the requested link, reject the request (must be from
-	 * a duplicate node).
-	 */
-	if (signature != n_ptr->signature) {
-		if (n_ptr->working_links == 0) {
-			struct tipc_link *curr_link;
-			int i;
-
-			for (i = 0; i < MAX_BEARERS; i++) {
-				curr_link = n_ptr->links[i];
-				if (curr_link) {
-					memset(&curr_link->media_addr, 0,
-					       sizeof(media_addr));
-					tipc_link_reset(curr_link);
-				}
-			}
-			addr_mismatch = (link != NULL);
-		} else if (tipc_link_is_up(link) && !addr_mismatch) {
-			/* delayed rediscovery */
-		} else {
-			disc_dupl_alert(b_ptr, orig, &media_addr);
-			tipc_node_unlock(n_ptr);
-			return;
-		}
-		n_ptr->signature = signature;
+	/* Prepare to validate requesting node's signature and media address */
+	sign_match = (signature == node->signature);
+	addr_match = link && !memcmp(&link->media_addr, &maddr, sizeof(maddr));
+	link_up = link && tipc_link_is_up(link);
+
+
+	/* These three flags give us eight permutations: */
+
+	if (sign_match && addr_match && link_up) {
+		/* All is fine. Do nothing. */
+	} else if (sign_match && addr_match && !link_up) {
+		/* Respond. The link will come up in due time */
+		respond = true;
+	} else if (sign_match && !addr_match && link_up) {
+		/* Peer has changed i/f address without rebooting.
+		 * If so, the link will reset soon, and the next
+		 * discovery will be accepted. So we can ignore it.
+		 * It may also be an cloned or malicious peer having
+		 * chosen the same node address and signature as an
+		 * existing one.
+		 * Ignore requests until the link goes down, if ever.
+		 */
+		disc_dupl_alert(bearer, onode, &maddr);
+	} else if (sign_match && !addr_match && !link_up) {
+		/* Peer link has changed i/f address without rebooting.
+		 * It may also be a cloned or malicious peer; we can't
+		 * distinguish between the two.
+		 * The signature is correct, so we must accept.
+		 */
+		accept_addr = true;
+		respond = true;
+	} else if (!sign_match && addr_match && link_up) {
+		/* Peer node rebooted. Two possibilities:
+		 *  - Delayed re-discovery; this link endpoint has already
+		 *    reset and re-established contact with the peer, before
+		 *    receiving a discovery message from that node.
+		 *    (The peer happened to receive one from this node first).
+		 *  - The peer came back so fast that our side has not
+		 *    discovered it yet. Probing from this side will soon
+		 *    reset the link, since there can be no working link
+		 *    endpoint at the peer end, and the link will re-establish.
+		 *  Accept the signature, since it comes from a known peer.
+		 */
+		accept_sign = true;
+	} else if (!sign_match && addr_match && !link_up) {
+		/*  The peer node has rebooted.
+		 *  Accept signature, since it is a known peer.
+		 */
+		accept_sign = true;
+		respond = true;
+	} else if (!sign_match && !addr_match && link_up) {
+		/* Peer rebooted with new address, or a new/duplicate peer.
+		 * Ignore until the link goes down, if ever.
+		 */
+		disc_dupl_alert(bearer, onode, &maddr);
+	} else if (!sign_match && !addr_match && !link_up) {
+		/* Peer rebooted with new address, or it is a new peer.
+		 * Accept signature and address.
+		*/
+		accept_sign = true;
+		accept_addr = true;
+		respond = true;
 	}
 
-	/*
-	 * Ensure requesting node's media address is correct
-	 *
-	 * If media address doesn't match and the link is working, reject the
-	 * request (must be from a duplicate node).
-	 *
-	 * If media address doesn't match and the link is not working, accept
-	 * the new media address and reset the link to ensure it starts up
-	 * cleanly.
-	 */
-	if (addr_mismatch) {
-		if (tipc_link_is_up(link)) {
-			disc_dupl_alert(b_ptr, orig, &media_addr);
-			tipc_node_unlock(n_ptr);
-			return;
-		} else {
-			memcpy(&link->media_addr, &media_addr,
-			       sizeof(media_addr));
-			tipc_link_reset(link);
-		}
-	}
+	if (accept_sign)
+		node->signature = signature;
 
-	/* Create a link endpoint for this bearer, if necessary */
-	if (!link) {
-		link = tipc_link_create(n_ptr, b_ptr, &media_addr);
-		if (!link) {
-			tipc_node_unlock(n_ptr);
-			return;
+	if (accept_addr) {
+		if (!link)
+			link = tipc_link_create(node, bearer, &maddr);
+		if (link) {
+			memcpy(&link->media_addr, &maddr, sizeof(maddr));
+			tipc_link_reset(link);
+		} else {
+			respond = false;
 		}
 	}
 
-	/* Accept discovery message & send response, if necessary */
-	link_fully_up = link_working_working(link);
-
-	if ((type == DSC_REQ_MSG) && !link_fully_up) {
+	/* Send response, if necessary */
+	if (respond && (mtyp == DSC_REQ_MSG)) {
 		rbuf = tipc_buf_acquire(INT_H_SIZE);
 		if (rbuf) {
-			tipc_disc_init_msg(rbuf, DSC_RESP_MSG, b_ptr);
-			tipc_bearer_send(b_ptr->identity, rbuf, &media_addr);
+			tipc_disc_init_msg(rbuf, DSC_RESP_MSG, bearer);
+			tipc_bearer_send(bearer->identity, rbuf, &maddr);
 			kfree_skb(rbuf);
 		}
 	}
-
-	tipc_node_unlock(n_ptr);
+	tipc_node_unlock(node);
 }
 
 /**
-- 
1.7.9.5


------------------------------------------------------------------------------
Is your legacy SCM system holding you back? Join Perforce May 7 to find out:
&#149; 3 signs your SCM is hindering your productivity
&#149; Requirements for releasing software faster
&#149; Expert tips and advice for migrating your SCM now
http://p.sf.net/sfu/perforce
