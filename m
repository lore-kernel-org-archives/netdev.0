From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/23] tipc: Allow run-time alteration of default link settings
Date: Tue, 27 Dec 2011 12:39:29 -0500
Message-ID: <1325007582-31610-11-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39405 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775Ab1L0RkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:01 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Permits run-time alteration of default link settings on a per-media
and per-bearer basis, in addition to the existing per-link basis.
The following syntax can now be used:

    tipc-config -lt=<link-name|bearer-name|media-name>/<tolerance>
    tipc-config -lp=<link-name|bearer-name|media-name>/<priority>
    tipc-config -lw=<link-name|bearer-name|media-name>/<window>

Note that changes to the default settings for a given media type has
no effect on the default settings used by existing bearers. Similarly,
changes to default bearer settings has no effect on existing link
endpoints that utilize that interface.

Thanks to Florian Westphal <fw@strlen.de> for his contributions to
the development of this enhancement.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |   18 ++++---
 net/tipc/bearer.h |    8 +++
 net/tipc/link.c   |  150 ++++++++++++++++++++++++++++++++++++++--------------
 3 files changed, 127 insertions(+), 49 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index aa37261..b40e98a 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -65,10 +65,10 @@ static int media_name_valid(const char *name)
 }
 
 /**
- * media_find - locates specified media object by name
+ * tipc_media_find - locates specified media object by name
  */
 
-static struct media *media_find(const char *name)
+struct media *tipc_media_find(const char *name)
 {
 	u32 i;
 
@@ -118,7 +118,7 @@ int  tipc_register_media(struct media *m_ptr)
 		goto exit;
 	if (media_count >= MAX_MEDIA)
 		goto exit;
-	if (media_find(m_ptr->name) || media_find_id(m_ptr->type_id))
+	if (tipc_media_find(m_ptr->name) || media_find_id(m_ptr->type_id))
 		goto exit;
 
 	media_list[media_count] = m_ptr;
@@ -229,10 +229,10 @@ static int bearer_name_validate(const char *name,
 }
 
 /**
- * bearer_find - locates bearer object with matching bearer name
+ * tipc_bearer_find - locates bearer object with matching bearer name
  */
 
-static struct tipc_bearer *bearer_find(const char *name)
+struct tipc_bearer *tipc_bearer_find(const char *name)
 {
 	struct tipc_bearer *b_ptr;
 	u32 i;
@@ -463,7 +463,7 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 
 	write_lock_bh(&tipc_net_lock);
 
-	m_ptr = media_find(b_name.media_name);
+	m_ptr = tipc_media_find(b_name.media_name);
 	if (!m_ptr) {
 		warn("Bearer <%s> rejected, media <%s> not registered\n", name,
 		     b_name.media_name);
@@ -513,6 +513,8 @@ restart:
 
 	b_ptr->identity = bearer_id;
 	b_ptr->media = m_ptr;
+	b_ptr->tolerance = m_ptr->tolerance;
+	b_ptr->window = m_ptr->window;
 	b_ptr->net_plane = bearer_id + 'A';
 	b_ptr->active = 1;
 	b_ptr->priority = priority;
@@ -546,7 +548,7 @@ int tipc_block_bearer(const char *name)
 	struct link *temp_l_ptr;
 
 	read_lock_bh(&tipc_net_lock);
-	b_ptr = bearer_find(name);
+	b_ptr = tipc_bearer_find(name);
 	if (!b_ptr) {
 		warn("Attempt to block unknown bearer <%s>\n", name);
 		read_unlock_bh(&tipc_net_lock);
@@ -600,7 +602,7 @@ int tipc_disable_bearer(const char *name)
 	int res;
 
 	write_lock_bh(&tipc_net_lock);
-	b_ptr = bearer_find(name);
+	b_ptr = tipc_bearer_find(name);
 	if (b_ptr == NULL) {
 		warn("Attempt to disable unknown bearer <%s>\n", name);
 		res = -EINVAL;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 54a5a57..cfe77c4 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -118,6 +118,8 @@ struct media {
  * @name: bearer name (format = media:interface)
  * @media: ptr to media structure associated with bearer
  * @priority: default link priority for bearer
+ * @window: default window size for bearer
+ * @tolerance: default link tolerance for bearer
  * @identity: array index of this bearer within TIPC bearer array
  * @link_req: ptr to (optional) structure making periodic link setup requests
  * @links: list of non-congested links associated with bearer
@@ -139,6 +141,8 @@ struct tipc_bearer {
 	spinlock_t lock;
 	struct media *media;
 	u32 priority;
+	u32 window;
+	u32 tolerance;
 	u32 identity;
 	struct link_req *link_req;
 	struct list_head links;
@@ -176,6 +180,8 @@ int tipc_disable_bearer(const char *name);
 int  tipc_eth_media_start(void);
 void tipc_eth_media_stop(void);
 
+int tipc_media_set_priority(const char *name, u32 new_value);
+int tipc_media_set_window(const char *name, u32 new_value);
 void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a);
 struct sk_buff *tipc_media_get_names(void);
 
@@ -183,7 +189,9 @@ struct sk_buff *tipc_bearer_get_names(void);
 void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest);
 void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest);
 void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct link *l_ptr);
+struct tipc_bearer *tipc_bearer_find(const char *name);
 struct tipc_bearer *tipc_bearer_find_interface(const char *if_name);
+struct media *tipc_media_find(const char *name);
 int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr, struct link *l_ptr);
 int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct link *l_ptr);
 void tipc_bearer_stop(void);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index ae98a72..332915e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -343,7 +343,7 @@ struct link *tipc_link_create(struct tipc_node *n_ptr,
 	l_ptr->checkpoint = 1;
 	l_ptr->peer_session = INVALID_SESSION;
 	l_ptr->b_ptr = b_ptr;
-	link_set_supervision_props(l_ptr, b_ptr->media->tolerance);
+	link_set_supervision_props(l_ptr, b_ptr->tolerance);
 	l_ptr->state = RESET_UNKNOWN;
 
 	l_ptr->pmsg = (struct tipc_msg *)&l_ptr->proto_msg;
@@ -355,7 +355,7 @@ struct link *tipc_link_create(struct tipc_node *n_ptr,
 	strcpy((char *)msg_data(msg), if_name);
 
 	l_ptr->priority = b_ptr->priority;
-	tipc_link_set_queue_limits(l_ptr, b_ptr->media->window);
+	tipc_link_set_queue_limits(l_ptr, b_ptr->window);
 
 	link_init_max_pkt(l_ptr);
 
@@ -2754,13 +2754,113 @@ static struct link *link_find_link(const char *name, struct tipc_node **node)
 	return l_ptr;
 }
 
+/**
+ * link_value_is_valid -- validate proposed link tolerance/priority/window
+ *
+ * @cmd - value type (TIPC_CMD_SET_LINK_*)
+ * @new_value - the new value
+ *
+ * Returns 1 if value is within range, 0 if not.
+ */
+
+static int link_value_is_valid(u16 cmd, u32 new_value)
+{
+	switch (cmd) {
+	case TIPC_CMD_SET_LINK_TOL:
+		return (new_value >= TIPC_MIN_LINK_TOL) &&
+			(new_value <= TIPC_MAX_LINK_TOL);
+	case TIPC_CMD_SET_LINK_PRI:
+		return (new_value <= TIPC_MAX_LINK_PRI);
+	case TIPC_CMD_SET_LINK_WINDOW:
+		return (new_value >= TIPC_MIN_LINK_WIN) &&
+			(new_value <= TIPC_MAX_LINK_WIN);
+	}
+	return 0;
+}
+
+
+/**
+ * link_cmd_set_value - change priority/tolerance/window for link/bearer/media
+ * @name - ptr to link, bearer, or media name
+ * @new_value - new value of link, bearer, or media setting
+ * @cmd - which link, bearer, or media attribute to set (TIPC_CMD_SET_LINK_*)
+ *
+ * Caller must hold 'tipc_net_lock' to ensure link/bearer/media is not deleted.
+ *
+ * Returns 0 if value updated and negative value on error.
+ */
+
+static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
+{
+	struct tipc_node *node;
+	struct link *l_ptr;
+	struct tipc_bearer *b_ptr;
+	struct media *m_ptr;
+
+	l_ptr = link_find_link(name, &node);
+	if (l_ptr) {
+		/*
+		 * acquire node lock for tipc_link_send_proto_msg().
+		 * see "TIPC locking policy" in net.c.
+		 */
+		tipc_node_lock(node);
+		switch (cmd) {
+		case TIPC_CMD_SET_LINK_TOL:
+			link_set_supervision_props(l_ptr, new_value);
+			tipc_link_send_proto_msg(l_ptr,
+				STATE_MSG, 0, 0, new_value, 0, 0);
+			break;
+		case TIPC_CMD_SET_LINK_PRI:
+			l_ptr->priority = new_value;
+			tipc_link_send_proto_msg(l_ptr,
+				STATE_MSG, 0, 0, 0, new_value, 0);
+			break;
+		case TIPC_CMD_SET_LINK_WINDOW:
+			tipc_link_set_queue_limits(l_ptr, new_value);
+			break;
+		}
+		tipc_node_unlock(node);
+		return 0;
+	}
+
+	b_ptr = tipc_bearer_find(name);
+	if (b_ptr) {
+		switch (cmd) {
+		case TIPC_CMD_SET_LINK_TOL:
+			b_ptr->tolerance = new_value;
+			return 0;
+		case TIPC_CMD_SET_LINK_PRI:
+			b_ptr->priority = new_value;
+			return 0;
+		case TIPC_CMD_SET_LINK_WINDOW:
+			b_ptr->window = new_value;
+			return 0;
+		}
+		return -EINVAL;
+	}
+
+	m_ptr = tipc_media_find(name);
+	if (!m_ptr)
+		return -ENODEV;
+	switch (cmd) {
+	case TIPC_CMD_SET_LINK_TOL:
+		m_ptr->tolerance = new_value;
+		return 0;
+	case TIPC_CMD_SET_LINK_PRI:
+		m_ptr->priority = new_value;
+		return 0;
+	case TIPC_CMD_SET_LINK_WINDOW:
+		m_ptr->window = new_value;
+		return 0;
+	}
+	return -EINVAL;
+}
+
 struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space,
 				     u16 cmd)
 {
 	struct tipc_link_config *args;
 	u32 new_value;
-	struct link *l_ptr;
-	struct tipc_node *node;
 	int res;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_CONFIG))
@@ -2769,6 +2869,10 @@ struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space
 	args = (struct tipc_link_config *)TLV_DATA(req_tlv_area);
 	new_value = ntohl(args->value);
 
+	if (!link_value_is_valid(cmd, new_value))
+		return tipc_cfg_reply_error_string(
+			"cannot change, value invalid");
+
 	if (!strcmp(args->name, tipc_bclink_name)) {
 		if ((cmd == TIPC_CMD_SET_LINK_WINDOW) &&
 		    (tipc_bclink_set_queue_limits(new_value) == 0))
@@ -2778,43 +2882,7 @@ struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space
 	}
 
 	read_lock_bh(&tipc_net_lock);
-	l_ptr = link_find_link(args->name, &node);
-	if (!l_ptr) {
-		read_unlock_bh(&tipc_net_lock);
-		return tipc_cfg_reply_error_string("link not found");
-	}
-
-	tipc_node_lock(node);
-	res = -EINVAL;
-	switch (cmd) {
-	case TIPC_CMD_SET_LINK_TOL:
-		if ((new_value >= TIPC_MIN_LINK_TOL) &&
-		    (new_value <= TIPC_MAX_LINK_TOL)) {
-			link_set_supervision_props(l_ptr, new_value);
-			tipc_link_send_proto_msg(l_ptr, STATE_MSG,
-						 0, 0, new_value, 0, 0);
-			res = 0;
-		}
-		break;
-	case TIPC_CMD_SET_LINK_PRI:
-		if ((new_value >= TIPC_MIN_LINK_PRI) &&
-		    (new_value <= TIPC_MAX_LINK_PRI)) {
-			l_ptr->priority = new_value;
-			tipc_link_send_proto_msg(l_ptr, STATE_MSG,
-						 0, 0, 0, new_value, 0);
-			res = 0;
-		}
-		break;
-	case TIPC_CMD_SET_LINK_WINDOW:
-		if ((new_value >= TIPC_MIN_LINK_WIN) &&
-		    (new_value <= TIPC_MAX_LINK_WIN)) {
-			tipc_link_set_queue_limits(l_ptr, new_value);
-			res = 0;
-		}
-		break;
-	}
-	tipc_node_unlock(node);
-
+	res = link_cmd_set_value(args->name, new_value, cmd);
 	read_unlock_bh(&tipc_net_lock);
 	if (res)
 		return tipc_cfg_reply_error_string("cannot change link setting");
-- 
1.7.4.4
