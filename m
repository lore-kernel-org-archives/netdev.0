From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/5] tipc: Optimizations to bearer enabling logic
Date: Tue, 12 Oct 2010 20:25:56 -0400
Message-ID: <1286929558-2954-3-git-send-email-paul.gortmaker@windriver.com>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61686 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab0JMA0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 20:26:02 -0400
In-Reply-To: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Introduces "enabling" state during activation of a new TIPC bearer,
which supplements the existing "disabled" and "enabled" states.
This change allows the new bearer to be added without having to
temporarily block the processing of incoming packets on existing
bearers during the binding of the new bearer to its associated
interface. It also makes it unnecessary to zero out the entire
bearer structure at the start of activation.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c  |    2 +-
 net/tipc/bearer.c |   27 +++++++++++++++++----------
 net/tipc/bearer.h |    8 ++++++--
 net/tipc/link.c   |    2 +-
 4 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index ecfaac1..ba6dcb2 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -645,7 +645,7 @@ void tipc_bcbearer_sort(void)
 	for (b_index = 0; b_index < MAX_BEARERS; b_index++) {
 		struct bearer *b = &tipc_bearers[b_index];
 
-		if (!b->active || !b->nodes.count)
+		if ((b->state != BEARER_ENABLED) || !b->nodes.count)
 			continue;
 
 		if (!bp_temp[b->priority].primary)
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 9969ec6..379338f 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -290,7 +290,7 @@ struct bearer *tipc_bearer_find_interface(const char *if_name)
 	u32 i;
 
 	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
-		if (!b_ptr->active)
+		if (b_ptr->state != BEARER_ENABLED)
 			continue;
 		b_if_name = strchr(b_ptr->publ.name, ':') + 1;
 		if (!strcmp(b_if_name, if_name))
@@ -312,7 +312,8 @@ static struct bearer *bearer_find(const char *name)
 		return NULL;
 
 	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
-		if (b_ptr->active && (!strcmp(b_ptr->publ.name, name)))
+		if ((b_ptr->state == BEARER_ENABLED) &&
+		    (!strcmp(b_ptr->publ.name, name)))
 			return b_ptr;
 	}
 	return NULL;
@@ -337,7 +338,8 @@ struct sk_buff *tipc_bearer_get_names(void)
 	for (i = 0, m_ptr = media_list; i < media_count; i++, m_ptr++) {
 		for (j = 0; j < MAX_BEARERS; j++) {
 			b_ptr = &tipc_bearers[j];
-			if (b_ptr->active && (b_ptr->media == m_ptr)) {
+			if ((b_ptr->state == BEARER_ENABLED) &&
+			    (b_ptr->media == m_ptr)) {
 				tipc_cfg_append_tlv(buf, TIPC_TLV_BEARER_NAME,
 						    b_ptr->publ.name,
 						    strlen(b_ptr->publ.name) + 1);
@@ -532,7 +534,7 @@ restart:
 	bearer_id = MAX_BEARERS;
 	with_this_prio = 1;
 	for (i = MAX_BEARERS; i-- != 0; ) {
-		if (!tipc_bearers[i].active) {
+		if (tipc_bearers[i].state != BEARER_ENABLED) {
 			bearer_id = i;
 			continue;
 		}
@@ -559,21 +561,23 @@ restart:
 	}
 
 	b_ptr = &tipc_bearers[bearer_id];
-	memset(b_ptr, 0, sizeof(struct bearer));
-
+	b_ptr->state = BEARER_ENABLING;
 	strcpy(b_ptr->publ.name, name);
+	b_ptr->priority = priority;
+
+	write_unlock_bh(&tipc_net_lock);
 	res = m_ptr->enable_bearer(&b_ptr->publ);
 	if (res) {
+		b_ptr->state = BEARER_DISABLED;
 		warn("Bearer <%s> rejected, enable failure (%d)\n", name, -res);
-		goto failed;
+		return res;
 	}
+	write_lock_bh(&tipc_net_lock);
 
 	b_ptr->identity = bearer_id;
 	b_ptr->media = m_ptr;
 	b_ptr->net_plane = bearer_id + 'A';
-	b_ptr->active = 1;
 	b_ptr->detect_scope = bcast_scope;
-	b_ptr->priority = priority;
 	INIT_LIST_HEAD(&b_ptr->cong_links);
 	INIT_LIST_HEAD(&b_ptr->links);
 	if (m_ptr->bcast) {
@@ -581,7 +585,10 @@ restart:
 							  bcast_scope, 2);
 	}
 	spin_lock_init(&b_ptr->publ.lock);
+	b_ptr->state = BEARER_ENABLED;
+
 	write_unlock_bh(&tipc_net_lock);
+
 	info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
 	     name, tipc_addr_string_fill(addr_string, bcast_scope), priority);
 	return 0;
@@ -672,7 +679,7 @@ void tipc_bearer_stop(void)
 	u32 i;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		if (tipc_bearers[i].active)
+		if (tipc_bearers[i].state == BEARER_ENABLED)
 			bearer_disable(&tipc_bearers[i]);
 	}
 	media_count = 0;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index a850b38..134c6cb 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -43,6 +43,10 @@
 #define MAX_BEARERS 8
 #define MAX_MEDIA 4
 
+/* Bearer state */
+#define BEARER_DISABLED	0
+#define BEARER_ENABLING	1
+#define BEARER_ENABLED		2
 
 /**
  * struct media - TIPC media information available to internal users
@@ -87,7 +91,7 @@ struct media {
  * @links: list of non-congested links associated with bearer
  * @cong_links: list of congested links associated with bearer
  * @continue_count: # of times bearer has resumed after congestion or blocking
- * @active: non-zero if bearer structure is represents a bearer
+ * @state: bearer state (disabled, enabling, enabled)
  * @net_plane: network plane ('A' through 'H') currently associated with bearer
  * @nodes: indicates which nodes in cluster can be reached through bearer
  */
@@ -102,7 +106,7 @@ struct bearer {
 	struct list_head links;
 	struct list_head cong_links;
 	u32 continue_count;
-	int active;
+	unsigned char state;
 	char net_plane;
 	struct tipc_node_map nodes;
 };
diff --git a/net/tipc/link.c b/net/tipc/link.c
index b8cf1e9..54bd99d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1830,7 +1830,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 
 		/* Ensure bearer is still enabled */
 
-		if (unlikely(!b_ptr->active))
+		if (unlikely(b_ptr->state != BEARER_ENABLED))
 			goto cont;
 
 		/* Ensure message is well-formed */
-- 
1.7.0.4

