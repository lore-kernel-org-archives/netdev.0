From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 18/26] tipc: Optimizations to link creation code
Date: Sun, 13 Mar 2011 17:34:06 -0400
Message-ID: <1300052054-7531-19-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49921 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235Ab1CMVey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:54 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Enhances link creation code as follows:

1) Detects illegal attempts to add a requested link earlier in the
   link creation process. This prevents TIPC from wasting time
   initializing a link object it then throws away, and also eliminates
   the code needed to do the throwing away.

2) Passes in the node object associated with the requested link.
   This allows TIPC to eliminate a search to locate the node object,
   as well as code that attempted to create the node if it doesn't
   exist.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |    2 +-
 net/tipc/link.c     |   27 ++++++++++++++++++++-------
 net/tipc/link.h     |    3 ++-
 net/tipc/node.c     |   30 ++++--------------------------
 net/tipc/node.h     |    2 +-
 5 files changed, 28 insertions(+), 36 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 580b50a..caac5c9 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -169,7 +169,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 
 	/* Create a link endpoint for this bearer, if necessary */
 	if (!link) {
-		link = tipc_link_create(b_ptr, orig, &media_addr);
+		link = tipc_link_create(n_ptr, b_ptr, &media_addr);
 		if (!link) {
 			tipc_node_unlock(n_ptr);
 			return;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index e5f96d5..b73adeb 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -293,19 +293,35 @@ static void link_set_timer(struct link *l_ptr, u32 time)
 
 /**
  * tipc_link_create - create a new link
+ * @n_ptr: pointer to associated node
  * @b_ptr: pointer to associated bearer
- * @peer: network address of node at other end of link
  * @media_addr: media address to use when sending messages over link
  *
  * Returns pointer to link.
  */
 
-struct link *tipc_link_create(struct tipc_bearer *b_ptr, const u32 peer,
+struct link *tipc_link_create(struct tipc_node *n_ptr,
+			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr)
 {
 	struct link *l_ptr;
 	struct tipc_msg *msg;
 	char *if_name;
+	char addr_string[16];
+	u32 peer = n_ptr->addr;
+
+	if (n_ptr->link_cnt >= 2) {
+		tipc_addr_string_fill(addr_string, n_ptr->addr);
+		err("Attempt to establish third link to %s\n", addr_string);
+		return NULL;
+	}
+
+	if (n_ptr->links[b_ptr->identity]) {
+		tipc_addr_string_fill(addr_string, n_ptr->addr);
+		err("Attempt to establish second link on <%s> to %s\n",
+		    b_ptr->name, addr_string);
+		return NULL;
+	}
 
 	l_ptr = kzalloc(sizeof(*l_ptr), GFP_ATOMIC);
 	if (!l_ptr) {
@@ -322,6 +338,7 @@ struct link *tipc_link_create(struct tipc_bearer *b_ptr, const u32 peer,
 		tipc_zone(peer), tipc_cluster(peer), tipc_node(peer));
 		/* note: peer i/f is appended to link name by reset/activate */
 	memcpy(&l_ptr->media_addr, media_addr, sizeof(*media_addr));
+	l_ptr->owner = n_ptr;
 	l_ptr->checkpoint = 1;
 	l_ptr->b_ptr = b_ptr;
 	link_set_supervision_props(l_ptr, b_ptr->media->tolerance);
@@ -345,11 +362,7 @@ struct link *tipc_link_create(struct tipc_bearer *b_ptr, const u32 peer,
 
 	link_reset_statistics(l_ptr);
 
-	l_ptr->owner = tipc_node_attach_link(l_ptr);
-	if (!l_ptr->owner) {
-		kfree(l_ptr);
-		return NULL;
-	}
+	tipc_node_attach_link(n_ptr, l_ptr);
 
 	k_init_timer(&l_ptr->timer, (Handler)link_timeout, (unsigned long)l_ptr);
 	list_add_tail(&l_ptr->link_list, &b_ptr->links);
diff --git a/net/tipc/link.h b/net/tipc/link.h
index a7794e7..e6a30db 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -207,7 +207,8 @@ struct link {
 
 struct tipc_port;
 
-struct link *tipc_link_create(struct tipc_bearer *b_ptr, const u32 peer,
+struct link *tipc_link_create(struct tipc_node *n_ptr,
+			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr);
 void tipc_link_delete(struct link *l_ptr);
 void tipc_link_changeover(struct link *l_ptr);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index ca09b33..2d106ef 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -238,33 +238,11 @@ int tipc_node_is_up(struct tipc_node *n_ptr)
 	return tipc_node_active_links(n_ptr);
 }
 
-struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
+void tipc_node_attach_link(struct tipc_node *n_ptr, struct link *l_ptr)
 {
-	struct tipc_node *n_ptr = tipc_node_find(l_ptr->addr);
-
-	if (!n_ptr)
-		n_ptr = tipc_node_create(l_ptr->addr);
-	if (n_ptr) {
-		u32 bearer_id = l_ptr->b_ptr->identity;
-		char addr_string[16];
-
-		if (n_ptr->link_cnt >= 2) {
-			err("Attempt to create third link to %s\n",
-			    tipc_addr_string_fill(addr_string, n_ptr->addr));
-			return NULL;
-		}
-
-		if (!n_ptr->links[bearer_id]) {
-			n_ptr->links[bearer_id] = l_ptr;
-			atomic_inc(&tipc_num_links);
-			n_ptr->link_cnt++;
-			return n_ptr;
-		}
-		err("Attempt to establish second link on <%s> to %s\n",
-		    l_ptr->b_ptr->name,
-		    tipc_addr_string_fill(addr_string, l_ptr->addr));
-	}
-	return NULL;
+	n_ptr->links[l_ptr->b_ptr->identity] = l_ptr;
+	atomic_inc(&tipc_num_links);
+	n_ptr->link_cnt++;
 }
 
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr)
diff --git a/net/tipc/node.h b/net/tipc/node.h
index dde3165..5c61afc 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -111,7 +111,7 @@ extern u32 tipc_own_tag;
 struct tipc_node *tipc_node_find(u32 addr);
 struct tipc_node *tipc_node_create(u32 addr);
 void tipc_node_delete(struct tipc_node *n_ptr);
-struct tipc_node *tipc_node_attach_link(struct link *l_ptr);
+void tipc_node_attach_link(struct tipc_node *n_ptr, struct link *l_ptr);
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr);
 void tipc_node_link_down(struct tipc_node *n_ptr, struct link *l_ptr);
 void tipc_node_link_up(struct tipc_node *n_ptr, struct link *l_ptr);
-- 
1.7.3.3

