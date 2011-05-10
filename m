From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 18/21] tipc: Enhance handling of discovery object creation failures
Date: Tue, 10 May 2011 16:44:34 -0400
Message-ID: <1305060277-15600-19-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52458 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712Ab1EJUpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:10 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Modifies bearer creation and deletion code to improve handling of
scenarios when a neighbor discovery object cannot be created. The
creation routine now aborts the creation of a bearer if its discovery
object cannot be created, and deletes the newly created bearer, rather
than failing quietly and leaving an unusable bearer hanging around.

Since the exit via the goto label really isn't a definitive failure
in all cases, relabel it appropriately.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c   |   30 ++++++++++++++++++------------
 net/tipc/discover.c |   45 +++++++++++++++++++++------------------------
 net/tipc/discover.h |    8 +++-----
 3 files changed, 42 insertions(+), 41 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index f7c29af..5fcd1c1 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -46,6 +46,8 @@ static u32 media_count;
 
 struct tipc_bearer tipc_bearers[MAX_BEARERS];
 
+static void bearer_disable(struct tipc_bearer *b_ptr);
+
 /**
  * media_name_valid - validate media name
  *
@@ -518,7 +520,7 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 	if (!m_ptr) {
 		warn("Bearer <%s> rejected, media <%s> not registered\n", name,
 		     b_name.media_name);
-		goto failed;
+		goto exit;
 	}
 
 	if (priority == TIPC_MEDIA_LINK_PRI)
@@ -534,14 +536,14 @@ restart:
 		}
 		if (!strcmp(name, tipc_bearers[i].name)) {
 			warn("Bearer <%s> rejected, already enabled\n", name);
-			goto failed;
+			goto exit;
 		}
 		if ((tipc_bearers[i].priority == priority) &&
 		    (++with_this_prio > 2)) {
 			if (priority-- == 0) {
 				warn("Bearer <%s> rejected, duplicate priority\n",
 				     name);
-				goto failed;
+				goto exit;
 			}
 			warn("Bearer <%s> priority adjustment required %u->%u\n",
 			     name, priority + 1, priority);
@@ -551,7 +553,7 @@ restart:
 	if (bearer_id >= MAX_BEARERS) {
 		warn("Bearer <%s> rejected, bearer limit reached (%u)\n",
 		     name, MAX_BEARERS);
-		goto failed;
+		goto exit;
 	}
 
 	b_ptr = &tipc_bearers[bearer_id];
@@ -559,7 +561,7 @@ restart:
 	res = m_ptr->enable_bearer(b_ptr);
 	if (res) {
 		warn("Bearer <%s> rejected, enable failure (%d)\n", name, -res);
-		goto failed;
+		goto exit;
 	}
 
 	b_ptr->identity = bearer_id;
@@ -569,14 +571,18 @@ restart:
 	b_ptr->priority = priority;
 	INIT_LIST_HEAD(&b_ptr->cong_links);
 	INIT_LIST_HEAD(&b_ptr->links);
-	b_ptr->link_req = tipc_disc_init_link_req(b_ptr, &m_ptr->bcast_addr,
-						  disc_domain);
 	spin_lock_init(&b_ptr->lock);
-	write_unlock_bh(&tipc_net_lock);
+
+	res = tipc_disc_create(b_ptr, &m_ptr->bcast_addr, disc_domain);
+	if (res) {
+		bearer_disable(b_ptr);
+		warn("Bearer <%s> rejected, discovery object creation failed\n",
+		     name);
+		goto exit;
+	}
 	info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
 	     name, tipc_addr_string_fill(addr_string, disc_domain), priority);
-	return 0;
-failed:
+exit:
 	write_unlock_bh(&tipc_net_lock);
 	return res;
 }
@@ -627,14 +633,14 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
 	struct link *temp_l_ptr;
 
 	info("Disabling bearer <%s>\n", b_ptr->name);
-	tipc_disc_stop_link_req(b_ptr->link_req);
 	spin_lock_bh(&b_ptr->lock);
-	b_ptr->link_req = NULL;
 	b_ptr->blocked = 1;
 	b_ptr->media->disable_bearer(b_ptr);
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
 		tipc_link_delete(l_ptr);
 	}
+	if (b_ptr->link_req)
+		tipc_disc_delete(b_ptr->link_req);
 	spin_unlock_bh(&b_ptr->lock);
 	memset(b_ptr, 0, sizeof(struct tipc_bearer));
 }
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index d2163bd..6acf32a 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -216,22 +216,6 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 }
 
 /**
- * tipc_disc_stop_link_req - stop sending periodic link setup requests
- * @req: ptr to link request structure
- */
-
-void tipc_disc_stop_link_req(struct link_req *req)
-{
-	if (!req)
-		return;
-
-	k_cancel_timer(&req->timer);
-	k_term_timer(&req->timer);
-	buf_discard(req->buf);
-	kfree(req);
-}
-
-/**
  * tipc_disc_update_link_req - update frequency of periodic link setup requests
  * @req: ptr to link request structure
  */
@@ -286,28 +270,27 @@ static void disc_timeout(struct link_req *req)
 }
 
 /**
- * tipc_disc_init_link_req - start sending periodic link setup requests
+ * tipc_disc_create - create object to send periodic link setup requests
  * @b_ptr: ptr to bearer issuing requests
  * @dest: destination address for request messages
  * @dest_domain: network domain to which links can be established
  *
- * Returns pointer to link request structure, or NULL if unable to create.
+ * Returns 0 if successful, otherwise -errno.
  */
 
-struct link_req *tipc_disc_init_link_req(struct tipc_bearer *b_ptr,
-					 const struct tipc_media_addr *dest,
-					 u32 dest_domain)
+int tipc_disc_create(struct tipc_bearer *b_ptr,
+		     struct tipc_media_addr *dest, u32 dest_domain)
 {
 	struct link_req *req;
 
 	req = kmalloc(sizeof(*req), GFP_ATOMIC);
 	if (!req)
-		return NULL;
+		return -ENOMEM;
 
 	req->buf = tipc_disc_init_msg(DSC_REQ_MSG, dest_domain, b_ptr);
 	if (!req->buf) {
 		kfree(req);
-		return NULL;
+		return -ENOMSG;
 	}
 
 	memcpy(&req->dest, dest, sizeof(*dest));
@@ -316,6 +299,20 @@ struct link_req *tipc_disc_init_link_req(struct tipc_bearer *b_ptr,
 	req->timer_intv = TIPC_LINK_REQ_INIT;
 	k_init_timer(&req->timer, (Handler)disc_timeout, (unsigned long)req);
 	k_start_timer(&req->timer, req->timer_intv);
-	return req;
+	b_ptr->link_req = req;
+	return 0;
+}
+
+/**
+ * tipc_disc_delete - destroy object sending periodic link setup requests
+ * @req: ptr to link request structure
+ */
+
+void tipc_disc_delete(struct link_req *req)
+{
+	k_cancel_timer(&req->timer);
+	k_term_timer(&req->timer);
+	buf_discard(req->buf);
+	kfree(req);
 }
 
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index e48a167..d6e44e3 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -39,12 +39,10 @@
 
 struct link_req;
 
-struct link_req *tipc_disc_init_link_req(struct tipc_bearer *b_ptr,
-					 const struct tipc_media_addr *dest,
-					 u32 dest_domain);
+int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest,
+		     u32 dest_domain);
+void tipc_disc_delete(struct link_req *req);
 void tipc_disc_update_link_req(struct link_req *req);
-void tipc_disc_stop_link_req(struct link_req *req);
-
 void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr);
 
 #endif
-- 
1.7.4.4

