From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 20/21] tipc: Add monitoring of number of nodes discovered by bearer
Date: Tue, 10 May 2011 16:44:36 -0400
Message-ID: <1305060277-15600-21-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52482 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937Ab1EJUpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:16 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Augments TIPC's discovery object to track the number of neighboring nodes
having an active link to the associated bearer.

This means tipc_disc_update_link_req() becomes either one of:

       tipc_disc_add_dest()
or:
       tipc_disc_remove_dest()

depending on the code flow direction of things.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c   |    4 ++--
 net/tipc/discover.c |   32 +++++++++++++++++++++++++++-----
 net/tipc/discover.h |    3 ++-
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 5fcd1c1..85209ea 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -344,15 +344,15 @@ struct sk_buff *tipc_bearer_get_names(void)
 void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest)
 {
 	tipc_nmap_add(&b_ptr->nodes, dest);
-	tipc_disc_update_link_req(b_ptr->link_req);
 	tipc_bcbearer_sort();
+	tipc_disc_add_dest(b_ptr->link_req);
 }
 
 void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest)
 {
 	tipc_nmap_remove(&b_ptr->nodes, dest);
-	tipc_disc_update_link_req(b_ptr->link_req);
 	tipc_bcbearer_sort();
+	tipc_disc_remove_dest(b_ptr->link_req);
 }
 
 /*
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index dba4767..3cb232d 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -53,6 +53,7 @@
  * @bearer: bearer issuing requests
  * @dest: destination address for request messages
  * @domain: network domain to which links can be established
+ * @num_nodes: number of nodes currently discovered (i.e. with an active link)
  * @buf: request message to be (repeatedly) sent
  * @timer: timer governing period between requests
  * @timer_intv: current interval between requests (in ms)
@@ -61,6 +62,7 @@ struct link_req {
 	struct tipc_bearer *bearer;
 	struct tipc_media_addr dest;
 	u32 domain;
+	int num_nodes;
 	struct sk_buff *buf;
 	struct timer_list timer;
 	unsigned int timer_intv;
@@ -216,15 +218,12 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 }
 
 /**
- * tipc_disc_update_link_req - update frequency of periodic link setup requests
+ * disc_update - update frequency of periodic link setup requests
  * @req: ptr to link request structure
  */
 
-void tipc_disc_update_link_req(struct link_req *req)
+static void disc_update(struct link_req *req)
 {
-	if (!req)
-		return;
-
 	if (req->timer_intv == TIPC_LINK_REQ_SLOW) {
 		if (!req->bearer->nodes.count) {
 			req->timer_intv = TIPC_LINK_REQ_FAST;
@@ -241,6 +240,28 @@ void tipc_disc_update_link_req(struct link_req *req)
 }
 
 /**
+ * tipc_disc_add_dest - increment set of discovered nodes
+ * @req: ptr to link request structure
+ */
+
+void tipc_disc_add_dest(struct link_req *req)
+{
+	req->num_nodes++;
+	disc_update(req);
+}
+
+/**
+ * tipc_disc_remove_dest - decrement set of discovered nodes
+ * @req: ptr to link request structure
+ */
+
+void tipc_disc_remove_dest(struct link_req *req)
+{
+	req->num_nodes--;
+	disc_update(req);
+}
+
+/**
  * disc_send_msg - send link setup request message
  * @req: ptr to link request structure
  */
@@ -307,6 +328,7 @@ int tipc_disc_create(struct tipc_bearer *b_ptr,
 	memcpy(&req->dest, dest, sizeof(*dest));
 	req->bearer = b_ptr;
 	req->domain = dest_domain;
+	req->num_nodes = 0;
 	req->timer_intv = TIPC_LINK_REQ_INIT;
 	k_init_timer(&req->timer, (Handler)disc_timeout, (unsigned long)req);
 	k_start_timer(&req->timer, req->timer_intv);
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index d6e44e3..a3af595 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -42,7 +42,8 @@ struct link_req;
 int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest,
 		     u32 dest_domain);
 void tipc_disc_delete(struct link_req *req);
-void tipc_disc_update_link_req(struct link_req *req);
+void tipc_disc_add_dest(struct link_req *req);
+void tipc_disc_remove_dest(struct link_req *req);
 void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr);
 
 #endif
-- 
1.7.4.4

