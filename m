From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 2/2] tipc: make discovery domain a bearer attribute
Date: Fri, 28 Mar 2014 10:32:09 +0100
Message-ID: <1395999129-31688-3-git-send-email-erik.hugne@ericsson.com>
References: <1395999129-31688-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, <aleksandar.igic@dektech.com.au>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg20.ericsson.net ([193.180.251.56]:44659 "EHLO
	sesbmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbaC1JcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:32:00 -0400
In-Reply-To: <1395999129-31688-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

The node discovery domain is assigned when a bearer is enabled.
In the previous commit we reflect this attribute directly in the
bearer structure since it's needed to reinitialize the node
discovery mechanism after a hardware address change.

There's no need to replicate this attribute anywhere else, so we
remove it from the tipc_link_req structure.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bearer.c   |  4 ++--
 net/tipc/discover.c | 19 +++++++------------
 net/tipc/discover.h |  3 +--
 3 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 3cd65d4..3fef7eb 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -336,7 +336,7 @@ restart:
 	b_ptr->net_plane = bearer_id + 'A';
 	b_ptr->priority = priority;
 
-	res = tipc_disc_create(b_ptr, &b_ptr->bcast_addr, disc_domain);
+	res = tipc_disc_create(b_ptr, &b_ptr->bcast_addr);
 	if (res) {
 		bearer_disable(b_ptr, false);
 		pr_warn("Bearer <%s> rejected, discovery object creation failed\n",
@@ -363,7 +363,7 @@ static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
 	pr_info("Resetting bearer <%s>\n", b_ptr->name);
 	tipc_disc_delete(b_ptr->link_req);
 	tipc_link_reset_list(b_ptr->identity);
-	tipc_disc_create(b_ptr, &b_ptr->bcast_addr, b_ptr->domain);
+	tipc_disc_create(b_ptr, &b_ptr->bcast_addr);
 	read_unlock_bh(&tipc_net_lock);
 	return 0;
 }
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index fa94da6..542fe34 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -48,7 +48,6 @@
  * struct tipc_link_req - information about an ongoing link setup request
  * @bearer: bearer issuing requests
  * @dest: destination address for request messages
- * @domain: network domain to which links can be established
  * @num_nodes: number of nodes currently discovered (i.e. with an active link)
  * @lock: spinlock for controlling access to requests
  * @buf: request message to be (repeatedly) sent
@@ -58,7 +57,6 @@
 struct tipc_link_req {
 	struct tipc_bearer *bearer;
 	struct tipc_media_addr dest;
-	u32 domain;
 	int num_nodes;
 	spinlock_t lock;
 	struct sk_buff *buf;
@@ -69,14 +67,13 @@ struct tipc_link_req {
 /**
  * tipc_disc_init_msg - initialize a link setup message
  * @type: message type (request or response)
- * @dest_domain: network domain of node(s) which should respond to message
  * @b_ptr: ptr to bearer issuing message
  */
-static struct sk_buff *tipc_disc_init_msg(u32 type, u32 dest_domain,
-					  struct tipc_bearer *b_ptr)
+static struct sk_buff *tipc_disc_init_msg(u32 type, struct tipc_bearer *b_ptr)
 {
 	struct sk_buff *buf = tipc_buf_acquire(INT_H_SIZE);
 	struct tipc_msg *msg;
+	u32 dest_domain = b_ptr->domain;
 
 	if (buf) {
 		msg = buf_msg(buf);
@@ -149,7 +146,7 @@ void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	}
 	if (!tipc_in_scope(dest, tipc_own_addr))
 		return;
-	if (!tipc_in_scope(b_ptr->link_req->domain, orig))
+	if (!tipc_in_scope(b_ptr->domain, orig))
 		return;
 
 	/* Locate structure corresponding to requesting node */
@@ -242,7 +239,7 @@ void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	link_fully_up = link_working_working(link);
 
 	if ((type == DSC_REQ_MSG) && !link_fully_up) {
-		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, orig, b_ptr);
+		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, b_ptr);
 		if (rbuf) {
 			tipc_bearer_send(b_ptr, rbuf, &media_addr);
 			kfree_skb(rbuf);
@@ -306,7 +303,7 @@ static void disc_timeout(struct tipc_link_req *req)
 	spin_lock_bh(&req->lock);
 
 	/* Stop searching if only desired node has been found */
-	if (tipc_node(req->domain) && req->num_nodes) {
+	if (tipc_node(req->bearer->domain) && req->num_nodes) {
 		req->timer_intv = TIPC_LINK_REQ_INACTIVE;
 		goto exit;
 	}
@@ -342,8 +339,7 @@ exit:
  *
  * Returns 0 if successful, otherwise -errno.
  */
-int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest,
-		     u32 dest_domain)
+int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest)
 {
 	struct tipc_link_req *req;
 
@@ -351,7 +347,7 @@ int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest,
 	if (!req)
 		return -ENOMEM;
 
-	req->buf = tipc_disc_init_msg(DSC_REQ_MSG, dest_domain, b_ptr);
+	req->buf = tipc_disc_init_msg(DSC_REQ_MSG, b_ptr);
 	if (!req->buf) {
 		kfree(req);
 		return -ENOMSG;
@@ -359,7 +355,6 @@ int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest,
 
 	memcpy(&req->dest, dest, sizeof(*dest));
 	req->bearer = b_ptr;
-	req->domain = dest_domain;
 	req->num_nodes = 0;
 	req->timer_intv = TIPC_LINK_REQ_INIT;
 	spin_lock_init(&req->lock);
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index b4fc962..07f3472 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -39,8 +39,7 @@
 
 struct tipc_link_req;
 
-int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest,
-		     u32 dest_domain);
+int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest);
 void tipc_disc_delete(struct tipc_link_req *req);
 void tipc_disc_add_dest(struct tipc_link_req *req);
 void tipc_disc_remove_dest(struct tipc_link_req *req);
-- 
1.8.3.2
