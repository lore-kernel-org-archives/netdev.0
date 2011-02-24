From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/17] tipc: Combine bearer structure with tipc_bearer structure
Date: Wed, 23 Feb 2011 20:26:30 -0500
Message-ID: <1298510805-20630-3-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34474 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755571Ab1BXB1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:04 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Combines two distinct structures containing information about a TIPC bearer
into a single structure. The structures were previously kept separate so
that public information about a bearer could be made available to plug-in
media types using TIPC's native API, while the remaining information was
kept private for use by TIPC itself. However, now that the native API has
been removed there is no longer any need for this arrangement.

Since one of the structures was already embedded within the other, the
change largely involves replacing instances of "publ.foo" with "foo".
The changes do not otherwise alter the operation of TIPC bearers.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c    |   28 +++++++-------
 net/tipc/bearer.c   |   98 +++++++++++++++++++++++++--------------------------
 net/tipc/bearer.h   |   67 ++++++++++++++++-------------------
 net/tipc/discover.c |   26 +++++++-------
 net/tipc/discover.h |    6 ++--
 net/tipc/link.c     |   13 +++----
 net/tipc/link.h     |    4 +-
 net/tipc/node.c     |    4 +-
 8 files changed, 119 insertions(+), 127 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 70ab5ef..b4d659d 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -3,7 +3,7 @@
  *
  * Copyright (c) 2004-2006, Ericsson AB
  * Copyright (c) 2004, Intel Corporation.
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -61,8 +61,8 @@
  */
 
 struct bcbearer_pair {
-	struct bearer *primary;
-	struct bearer *secondary;
+	struct tipc_bearer *primary;
+	struct tipc_bearer *secondary;
 };
 
 /**
@@ -81,7 +81,7 @@ struct bcbearer_pair {
  */
 
 struct bcbearer {
-	struct bearer bearer;
+	struct tipc_bearer bearer;
 	struct media media;
 	struct bcbearer_pair bpairs[MAX_BEARERS];
 	struct bcbearer_pair bpairs_temp[TIPC_MAX_LINK_PRI + 1];
@@ -574,8 +574,8 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 	bcbearer->remains = tipc_bcast_nmap;
 
 	for (bp_index = 0; bp_index < MAX_BEARERS; bp_index++) {
-		struct bearer *p = bcbearer->bpairs[bp_index].primary;
-		struct bearer *s = bcbearer->bpairs[bp_index].secondary;
+		struct tipc_bearer *p = bcbearer->bpairs[bp_index].primary;
+		struct tipc_bearer *s = bcbearer->bpairs[bp_index].secondary;
 
 		if (!p)
 			break;	/* no more bearers to try */
@@ -584,11 +584,11 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		if (bcbearer->remains_new.count == bcbearer->remains.count)
 			continue;	/* bearer pair doesn't add anything */
 
-		if (p->publ.blocked ||
-		    p->media->send_msg(buf, &p->publ, &p->media->bcast_addr)) {
+		if (p->blocked ||
+		    p->media->send_msg(buf, p, &p->media->bcast_addr)) {
 			/* unable to send on primary bearer */
-			if (!s || s->publ.blocked ||
-			    s->media->send_msg(buf, &s->publ,
+			if (!s || s->blocked ||
+			    s->media->send_msg(buf, s,
 					       &s->media->bcast_addr)) {
 				/* unable to send on either bearer */
 				continue;
@@ -633,7 +633,7 @@ void tipc_bcbearer_sort(void)
 	memset(bp_temp, 0, sizeof(bcbearer->bpairs_temp));
 
 	for (b_index = 0; b_index < MAX_BEARERS; b_index++) {
-		struct bearer *b = &tipc_bearers[b_index];
+		struct tipc_bearer *b = &tipc_bearers[b_index];
 
 		if (!b->active || !b->nodes.count)
 			continue;
@@ -682,12 +682,12 @@ void tipc_bcbearer_sort(void)
 
 void tipc_bcbearer_push(void)
 {
-	struct bearer *b_ptr;
+	struct tipc_bearer *b_ptr;
 
 	spin_lock_bh(&bc_lock);
 	b_ptr = &bcbearer->bearer;
-	if (b_ptr->publ.blocked) {
-		b_ptr->publ.blocked = 0;
+	if (b_ptr->blocked) {
+		b_ptr->blocked = 0;
 		tipc_bearer_lock_push(b_ptr);
 	}
 	spin_unlock_bh(&bc_lock);
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 837b7a4..9e2ff0e 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -2,7 +2,7 @@
  * net/tipc/bearer.c: TIPC bearer code
  *
  * Copyright (c) 1996-2006, Ericsson AB
- * Copyright (c) 2004-2006, Wind River Systems
+ * Copyright (c) 2004-2006, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -44,7 +44,7 @@
 static struct media media_list[MAX_MEDIA];
 static u32 media_count;
 
-struct bearer tipc_bearers[MAX_BEARERS];
+struct tipc_bearer tipc_bearers[MAX_BEARERS];
 
 /**
  * media_name_valid - validate media name
@@ -278,13 +278,13 @@ static int bearer_name_validate(const char *name,
  * bearer_find - locates bearer object with matching bearer name
  */
 
-static struct bearer *bearer_find(const char *name)
+static struct tipc_bearer *bearer_find(const char *name)
 {
-	struct bearer *b_ptr;
+	struct tipc_bearer *b_ptr;
 	u32 i;
 
 	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
-		if (b_ptr->active && (!strcmp(b_ptr->publ.name, name)))
+		if (b_ptr->active && (!strcmp(b_ptr->name, name)))
 			return b_ptr;
 	}
 	return NULL;
@@ -294,16 +294,16 @@ static struct bearer *bearer_find(const char *name)
  * tipc_bearer_find_interface - locates bearer object with matching interface name
  */
 
-struct bearer *tipc_bearer_find_interface(const char *if_name)
+struct tipc_bearer *tipc_bearer_find_interface(const char *if_name)
 {
-	struct bearer *b_ptr;
+	struct tipc_bearer *b_ptr;
 	char *b_if_name;
 	u32 i;
 
 	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
 		if (!b_ptr->active)
 			continue;
-		b_if_name = strchr(b_ptr->publ.name, ':') + 1;
+		b_if_name = strchr(b_ptr->name, ':') + 1;
 		if (!strcmp(b_if_name, if_name))
 			return b_ptr;
 	}
@@ -318,7 +318,7 @@ struct sk_buff *tipc_bearer_get_names(void)
 {
 	struct sk_buff *buf;
 	struct media *m_ptr;
-	struct bearer *b_ptr;
+	struct tipc_bearer *b_ptr;
 	int i, j;
 
 	buf = tipc_cfg_reply_alloc(MAX_BEARERS * TLV_SPACE(TIPC_MAX_BEARER_NAME));
@@ -331,8 +331,8 @@ struct sk_buff *tipc_bearer_get_names(void)
 			b_ptr = &tipc_bearers[j];
 			if (b_ptr->active && (b_ptr->media == m_ptr)) {
 				tipc_cfg_append_tlv(buf, TIPC_TLV_BEARER_NAME,
-						    b_ptr->publ.name,
-						    strlen(b_ptr->publ.name) + 1);
+						    b_ptr->name,
+						    strlen(b_ptr->name) + 1);
 			}
 		}
 	}
@@ -340,14 +340,14 @@ struct sk_buff *tipc_bearer_get_names(void)
 	return buf;
 }
 
-void tipc_bearer_add_dest(struct bearer *b_ptr, u32 dest)
+void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest)
 {
 	tipc_nmap_add(&b_ptr->nodes, dest);
 	tipc_disc_update_link_req(b_ptr->link_req);
 	tipc_bcbearer_sort();
 }
 
-void tipc_bearer_remove_dest(struct bearer *b_ptr, u32 dest)
+void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest)
 {
 	tipc_nmap_remove(&b_ptr->nodes, dest);
 	tipc_disc_update_link_req(b_ptr->link_req);
@@ -362,12 +362,12 @@ void tipc_bearer_remove_dest(struct bearer *b_ptr, u32 dest)
  * bearer.lock must be taken before calling
  * Returns binary true(1) ore false(0)
  */
-static int bearer_push(struct bearer *b_ptr)
+static int bearer_push(struct tipc_bearer *b_ptr)
 {
 	u32 res = 0;
 	struct link *ln, *tln;
 
-	if (b_ptr->publ.blocked)
+	if (b_ptr->blocked)
 		return 0;
 
 	while (!list_empty(&b_ptr->cong_links) && (res != PUSH_FAILED)) {
@@ -382,13 +382,13 @@ static int bearer_push(struct bearer *b_ptr)
 	return list_empty(&b_ptr->cong_links);
 }
 
-void tipc_bearer_lock_push(struct bearer *b_ptr)
+void tipc_bearer_lock_push(struct tipc_bearer *b_ptr)
 {
 	int res;
 
-	spin_lock_bh(&b_ptr->publ.lock);
+	spin_lock_bh(&b_ptr->lock);
 	res = bearer_push(b_ptr);
-	spin_unlock_bh(&b_ptr->publ.lock);
+	spin_unlock_bh(&b_ptr->lock);
 	if (res)
 		tipc_bcbearer_push();
 }
@@ -398,16 +398,14 @@ void tipc_bearer_lock_push(struct bearer *b_ptr)
  * Interrupt enabling new requests after bearer congestion or blocking:
  * See bearer_send().
  */
-void tipc_continue(struct tipc_bearer *tb_ptr)
+void tipc_continue(struct tipc_bearer *b_ptr)
 {
-	struct bearer *b_ptr = (struct bearer *)tb_ptr;
-
-	spin_lock_bh(&b_ptr->publ.lock);
+	spin_lock_bh(&b_ptr->lock);
 	b_ptr->continue_count++;
 	if (!list_empty(&b_ptr->cong_links))
 		tipc_k_signal((Handler)tipc_bearer_lock_push, (unsigned long)b_ptr);
-	b_ptr->publ.blocked = 0;
-	spin_unlock_bh(&b_ptr->publ.lock);
+	b_ptr->blocked = 0;
+	spin_unlock_bh(&b_ptr->lock);
 }
 
 /*
@@ -418,7 +416,7 @@ void tipc_continue(struct tipc_bearer *tb_ptr)
  * bearer.lock is busy
  */
 
-static void tipc_bearer_schedule_unlocked(struct bearer *b_ptr, struct link *l_ptr)
+static void tipc_bearer_schedule_unlocked(struct tipc_bearer *b_ptr, struct link *l_ptr)
 {
 	list_move_tail(&l_ptr->link_list, &b_ptr->cong_links);
 }
@@ -431,11 +429,11 @@ static void tipc_bearer_schedule_unlocked(struct bearer *b_ptr, struct link *l_p
  * bearer.lock is free
  */
 
-void tipc_bearer_schedule(struct bearer *b_ptr, struct link *l_ptr)
+void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct link *l_ptr)
 {
-	spin_lock_bh(&b_ptr->publ.lock);
+	spin_lock_bh(&b_ptr->lock);
 	tipc_bearer_schedule_unlocked(b_ptr, l_ptr);
-	spin_unlock_bh(&b_ptr->publ.lock);
+	spin_unlock_bh(&b_ptr->lock);
 }
 
 
@@ -444,18 +442,18 @@ void tipc_bearer_schedule(struct bearer *b_ptr, struct link *l_ptr)
  * and if there is, try to resolve it before returning.
  * 'tipc_net_lock' is read_locked when this function is called
  */
-int tipc_bearer_resolve_congestion(struct bearer *b_ptr, struct link *l_ptr)
+int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr, struct link *l_ptr)
 {
 	int res = 1;
 
 	if (list_empty(&b_ptr->cong_links))
 		return 1;
-	spin_lock_bh(&b_ptr->publ.lock);
+	spin_lock_bh(&b_ptr->lock);
 	if (!bearer_push(b_ptr)) {
 		tipc_bearer_schedule_unlocked(b_ptr, l_ptr);
 		res = 0;
 	}
-	spin_unlock_bh(&b_ptr->publ.lock);
+	spin_unlock_bh(&b_ptr->lock);
 	return res;
 }
 
@@ -463,9 +461,9 @@ int tipc_bearer_resolve_congestion(struct bearer *b_ptr, struct link *l_ptr)
  * tipc_bearer_congested - determines if bearer is currently congested
  */
 
-int tipc_bearer_congested(struct bearer *b_ptr, struct link *l_ptr)
+int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct link *l_ptr)
 {
-	if (unlikely(b_ptr->publ.blocked))
+	if (unlikely(b_ptr->blocked))
 		return 1;
 	if (likely(list_empty(&b_ptr->cong_links)))
 		return 0;
@@ -478,7 +476,7 @@ int tipc_bearer_congested(struct bearer *b_ptr, struct link *l_ptr)
 
 int tipc_enable_bearer(const char *name, u32 bcast_scope, u32 priority)
 {
-	struct bearer *b_ptr;
+	struct tipc_bearer *b_ptr;
 	struct media *m_ptr;
 	struct bearer_name b_name;
 	char addr_string[16];
@@ -528,7 +526,7 @@ restart:
 			bearer_id = i;
 			continue;
 		}
-		if (!strcmp(name, tipc_bearers[i].publ.name)) {
+		if (!strcmp(name, tipc_bearers[i].name)) {
 			warn("Bearer <%s> rejected, already enabled\n", name);
 			goto failed;
 		}
@@ -551,8 +549,8 @@ restart:
 	}
 
 	b_ptr = &tipc_bearers[bearer_id];
-	strcpy(b_ptr->publ.name, name);
-	res = m_ptr->enable_bearer(&b_ptr->publ);
+	strcpy(b_ptr->name, name);
+	res = m_ptr->enable_bearer(b_ptr);
 	if (res) {
 		warn("Bearer <%s> rejected, enable failure (%d)\n", name, -res);
 		goto failed;
@@ -570,7 +568,7 @@ restart:
 		b_ptr->link_req = tipc_disc_init_link_req(b_ptr, &m_ptr->bcast_addr,
 							  bcast_scope, 2);
 	}
-	spin_lock_init(&b_ptr->publ.lock);
+	spin_lock_init(&b_ptr->lock);
 	write_unlock_bh(&tipc_net_lock);
 	info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
 	     name, tipc_addr_string_fill(addr_string, bcast_scope), priority);
@@ -587,7 +585,7 @@ failed:
 
 int tipc_block_bearer(const char *name)
 {
-	struct bearer *b_ptr = NULL;
+	struct tipc_bearer *b_ptr = NULL;
 	struct link *l_ptr;
 	struct link *temp_l_ptr;
 
@@ -600,8 +598,8 @@ int tipc_block_bearer(const char *name)
 	}
 
 	info("Blocking bearer <%s>\n", name);
-	spin_lock_bh(&b_ptr->publ.lock);
-	b_ptr->publ.blocked = 1;
+	spin_lock_bh(&b_ptr->lock);
+	b_ptr->blocked = 1;
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
 		struct tipc_node *n_ptr = l_ptr->owner;
 
@@ -609,7 +607,7 @@ int tipc_block_bearer(const char *name)
 		tipc_link_reset(l_ptr);
 		spin_unlock_bh(&n_ptr->lock);
 	}
-	spin_unlock_bh(&b_ptr->publ.lock);
+	spin_unlock_bh(&b_ptr->lock);
 	read_unlock_bh(&tipc_net_lock);
 	return 0;
 }
@@ -620,27 +618,27 @@ int tipc_block_bearer(const char *name)
  * Note: This routine assumes caller holds tipc_net_lock.
  */
 
-static void bearer_disable(struct bearer *b_ptr)
+static void bearer_disable(struct tipc_bearer *b_ptr)
 {
 	struct link *l_ptr;
 	struct link *temp_l_ptr;
 
-	info("Disabling bearer <%s>\n", b_ptr->publ.name);
+	info("Disabling bearer <%s>\n", b_ptr->name);
 	tipc_disc_stop_link_req(b_ptr->link_req);
-	spin_lock_bh(&b_ptr->publ.lock);
+	spin_lock_bh(&b_ptr->lock);
 	b_ptr->link_req = NULL;
-	b_ptr->publ.blocked = 1;
-	b_ptr->media->disable_bearer(&b_ptr->publ);
+	b_ptr->blocked = 1;
+	b_ptr->media->disable_bearer(b_ptr);
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
 		tipc_link_delete(l_ptr);
 	}
-	spin_unlock_bh(&b_ptr->publ.lock);
-	memset(b_ptr, 0, sizeof(struct bearer));
+	spin_unlock_bh(&b_ptr->lock);
+	memset(b_ptr, 0, sizeof(struct tipc_bearer));
 }
 
 int tipc_disable_bearer(const char *name)
 {
-	struct bearer *b_ptr;
+	struct tipc_bearer *b_ptr;
 	int res;
 
 	write_lock_bh(&tipc_net_lock);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 85f451d..255dea6 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -2,7 +2,7 @@
  * net/tipc/bearer.h: Include file for TIPC bearer code
  *
  * Copyright (c) 1996-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -61,26 +61,7 @@ struct tipc_media_addr {
 	} dev_addr;
 };
 
-/**
- * struct tipc_bearer - TIPC bearer info available to media code
- * @usr_handle: pointer to additional media-specific information about bearer
- * @mtu: max packet size bearer can support
- * @blocked: non-zero if bearer is blocked
- * @lock: spinlock for controlling access to bearer
- * @addr: media-specific address associated with bearer
- * @name: bearer name (format = media:interface)
- *
- * Note: TIPC initializes "name" and "lock" fields; media code is responsible
- * for initialization all other fields when a bearer is enabled.
- */
-struct tipc_bearer {
-	void *usr_handle;
-	u32 mtu;
-	int blocked;
-	spinlock_t lock;
-	struct tipc_media_addr addr;
-	char name[TIPC_MAX_BEARER_NAME];
-};
+struct tipc_bearer;
 
 /**
  * struct media - TIPC media information available to internal users
@@ -115,8 +96,13 @@ struct media {
 };
 
 /**
- * struct bearer - TIPC bearer information available to internal users
- * @publ: bearer information available to privileged users
+ * struct tipc_bearer - TIPC bearer structure
+ * @usr_handle: pointer to additional media-specific information about bearer
+ * @mtu: max packet size bearer can support
+ * @blocked: non-zero if bearer is blocked
+ * @lock: spinlock for controlling access to bearer
+ * @addr: media-specific address associated with bearer
+ * @name: bearer name (format = media:interface)
  * @media: ptr to media structure associated with bearer
  * @priority: default link priority for bearer
  * @detect_scope: network address mask used during automatic link creation
@@ -128,10 +114,18 @@ struct media {
  * @active: non-zero if bearer structure is represents a bearer
  * @net_plane: network plane ('A' through 'H') currently associated with bearer
  * @nodes: indicates which nodes in cluster can be reached through bearer
+ *
+ * Note: media-specific code is responsible for initialization of the fields
+ * indicated below when a bearer is enabled; TIPC's generic bearer code takes
+ * care of initializing all other fields.
  */
-
-struct bearer {
-	struct tipc_bearer publ;
+struct tipc_bearer {
+	void *usr_handle;			/* initalized by media */
+	u32 mtu;				/* initalized by media */
+	int blocked;				/* initalized by media */
+	struct tipc_media_addr addr;		/* initalized by media */
+	char name[TIPC_MAX_BEARER_NAME];
+	spinlock_t lock;
 	struct media *media;
 	u32 priority;
 	u32 detect_scope;
@@ -152,7 +146,7 @@ struct bearer_name {
 
 struct link;
 
-extern struct bearer tipc_bearers[];
+extern struct tipc_bearer tipc_bearers[];
 
 /*
  * TIPC routines available to supported media types
@@ -186,14 +180,14 @@ void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a);
 struct sk_buff *tipc_media_get_names(void);
 
 struct sk_buff *tipc_bearer_get_names(void);
-void tipc_bearer_add_dest(struct bearer *b_ptr, u32 dest);
-void tipc_bearer_remove_dest(struct bearer *b_ptr, u32 dest);
-void tipc_bearer_schedule(struct bearer *b_ptr, struct link *l_ptr);
-struct bearer *tipc_bearer_find_interface(const char *if_name);
-int tipc_bearer_resolve_congestion(struct bearer *b_ptr, struct link *l_ptr);
-int tipc_bearer_congested(struct bearer *b_ptr, struct link *l_ptr);
+void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest);
+void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest);
+void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct link *l_ptr);
+struct tipc_bearer *tipc_bearer_find_interface(const char *if_name);
+int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr, struct link *l_ptr);
+int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct link *l_ptr);
 void tipc_bearer_stop(void);
-void tipc_bearer_lock_push(struct bearer *b_ptr);
+void tipc_bearer_lock_push(struct tipc_bearer *b_ptr);
 
 
 /**
@@ -214,10 +208,11 @@ void tipc_bearer_lock_push(struct bearer *b_ptr);
  * and let TIPC's link code deal with the undelivered message.
  */
 
-static inline int tipc_bearer_send(struct bearer *b_ptr, struct sk_buff *buf,
+static inline int tipc_bearer_send(struct tipc_bearer *b_ptr,
+				   struct sk_buff *buf,
 				   struct tipc_media_addr *dest)
 {
-	return !b_ptr->media->send_msg(buf, &b_ptr->publ, dest);
+	return !b_ptr->media->send_msg(buf, b_ptr, dest);
 }
 
 #endif	/* _TIPC_BEARER_H */
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index fa026bd..59a86fc 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -2,7 +2,7 @@
  * net/tipc/discover.c
  *
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005-2006, Wind River Systems
+ * Copyright (c) 2005-2006, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -57,7 +57,7 @@
  * @timer_intv: current interval between requests (in ms)
  */
 struct link_req {
-	struct bearer *bearer;
+	struct tipc_bearer *bearer;
 	struct tipc_media_addr dest;
 	struct sk_buff *buf;
 	struct timer_list timer;
@@ -75,7 +75,7 @@ struct link_req {
 static struct sk_buff *tipc_disc_init_msg(u32 type,
 					  u32 req_links,
 					  u32 dest_domain,
-					  struct bearer *b_ptr)
+					  struct tipc_bearer *b_ptr)
 {
 	struct sk_buff *buf = tipc_buf_acquire(DSC_H_SIZE);
 	struct tipc_msg *msg;
@@ -87,7 +87,7 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
 		msg_set_req_links(msg, req_links);
 		msg_set_dest_domain(msg, dest_domain);
 		msg_set_bc_netid(msg, tipc_net_id);
-		msg_set_media_addr(msg, &b_ptr->publ.addr);
+		msg_set_media_addr(msg, &b_ptr->addr);
 	}
 	return buf;
 }
@@ -99,7 +99,7 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
  * @media_addr: media address advertised by duplicated node
  */
 
-static void disc_dupl_alert(struct bearer *b_ptr, u32 node_addr,
+static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
 			    struct tipc_media_addr *media_addr)
 {
 	char node_addr_str[16];
@@ -111,7 +111,7 @@ static void disc_dupl_alert(struct bearer *b_ptr, u32 node_addr,
 	tipc_media_addr_printf(&pb, media_addr);
 	tipc_printbuf_validate(&pb);
 	warn("Duplicate %s using %s seen on <%s>\n",
-	     node_addr_str, media_addr_str, b_ptr->publ.name);
+	     node_addr_str, media_addr_str, b_ptr->name);
 }
 
 /**
@@ -120,7 +120,7 @@ static void disc_dupl_alert(struct bearer *b_ptr, u32 node_addr,
  * @b_ptr: bearer that message arrived on
  */
 
-void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
+void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 {
 	struct link *link;
 	struct tipc_media_addr media_addr;
@@ -140,7 +140,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 	if (!tipc_addr_node_valid(orig))
 		return;
 	if (orig == tipc_own_addr) {
-		if (memcmp(&media_addr, &b_ptr->publ.addr, sizeof(media_addr)))
+		if (memcmp(&media_addr, &b_ptr->addr, sizeof(media_addr)))
 			disc_dupl_alert(b_ptr, tipc_own_addr, &media_addr);
 		return;
 	}
@@ -193,7 +193,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 			return;
 		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, 1, orig, b_ptr);
 		if (rbuf != NULL) {
-			b_ptr->media->send_msg(rbuf, &b_ptr->publ, &media_addr);
+			b_ptr->media->send_msg(rbuf, b_ptr, &media_addr);
 			buf_discard(rbuf);
 		}
 	}
@@ -249,9 +249,9 @@ void tipc_disc_update_link_req(struct link_req *req)
 
 static void disc_timeout(struct link_req *req)
 {
-	spin_lock_bh(&req->bearer->publ.lock);
+	spin_lock_bh(&req->bearer->lock);
 
-	req->bearer->media->send_msg(req->buf, &req->bearer->publ, &req->dest);
+	req->bearer->media->send_msg(req->buf, req->bearer, &req->dest);
 
 	if ((req->timer_intv == TIPC_LINK_REQ_SLOW) ||
 	    (req->timer_intv == TIPC_LINK_REQ_FAST)) {
@@ -266,7 +266,7 @@ static void disc_timeout(struct link_req *req)
 	}
 	k_start_timer(&req->timer, req->timer_intv);
 
-	spin_unlock_bh(&req->bearer->publ.lock);
+	spin_unlock_bh(&req->bearer->lock);
 }
 
 /**
@@ -279,7 +279,7 @@ static void disc_timeout(struct link_req *req)
  * Returns pointer to link request structure, or NULL if unable to create.
  */
 
-struct link_req *tipc_disc_init_link_req(struct bearer *b_ptr,
+struct link_req *tipc_disc_init_link_req(struct tipc_bearer *b_ptr,
 					 const struct tipc_media_addr *dest,
 					 u32 dest_domain,
 					 u32 req_links)
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index d2c3cff..4046d77 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -2,7 +2,7 @@
  * net/tipc/discover.h
  *
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -39,13 +39,13 @@
 
 struct link_req;
 
-struct link_req *tipc_disc_init_link_req(struct bearer *b_ptr,
+struct link_req *tipc_disc_init_link_req(struct tipc_bearer *b_ptr,
 					 const struct tipc_media_addr *dest,
 					 u32 dest_domain,
 					 u32 req_links);
 void tipc_disc_update_link_req(struct link_req *req);
 void tipc_disc_stop_link_req(struct link_req *req);
 
-void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr);
+void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr);
 
 #endif
diff --git a/net/tipc/link.c b/net/tipc/link.c
index e30770d..1c5c53a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -113,7 +113,7 @@ static void link_init_max_pkt(struct link *l_ptr)
 {
 	u32 max_pkt;
 
-	max_pkt = (l_ptr->b_ptr->publ.mtu & ~3);
+	max_pkt = (l_ptr->b_ptr->mtu & ~3);
 	if (max_pkt > MAX_MSG_SIZE)
 		max_pkt = MAX_MSG_SIZE;
 
@@ -303,7 +303,7 @@ static void link_set_timer(struct link *l_ptr, u32 time)
  * Returns pointer to link.
  */
 
-struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
+struct link *tipc_link_create(struct tipc_bearer *b_ptr, const u32 peer,
 			      const struct tipc_media_addr *media_addr)
 {
 	struct link *l_ptr;
@@ -317,7 +317,7 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 	}
 
 	l_ptr->addr = peer;
-	if_name = strchr(b_ptr->publ.name, ':') + 1;
+	if_name = strchr(b_ptr->name, ':') + 1;
 	sprintf(l_ptr->name, "%u.%u.%u:%s-%u.%u.%u:",
 		tipc_zone(tipc_own_addr), tipc_cluster(tipc_own_addr),
 		tipc_node(tipc_own_addr),
@@ -1595,11 +1595,10 @@ static int link_recv_buf_validate(struct sk_buff *buf)
  * structure (i.e. cannot be NULL), but bearer can be inactive.
  */
 
-void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
+void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 {
 	read_lock_bh(&tipc_net_lock);
 	while (head) {
-		struct bearer *b_ptr = (struct bearer *)tb_ptr;
 		struct tipc_node *n_ptr;
 		struct link *l_ptr;
 		struct sk_buff *crs;
@@ -2658,7 +2657,7 @@ void tipc_link_set_queue_limits(struct link *l_ptr, u32 window)
 static struct link *link_find_link(const char *name, struct tipc_node **node)
 {
 	struct link_name link_name_parts;
-	struct bearer *b_ptr;
+	struct tipc_bearer *b_ptr;
 	struct link *l_ptr;
 
 	if (!link_name_validate(name, &link_name_parts))
@@ -2961,7 +2960,7 @@ static void link_print(struct link *l_ptr, const char *str)
 
 	tipc_printf(buf, str);
 	tipc_printf(buf, "Link %x<%s>:",
-		    l_ptr->addr, l_ptr->b_ptr->publ.name);
+		    l_ptr->addr, l_ptr->b_ptr->name);
 
 #ifdef CONFIG_TIPC_DEBUG
 	if (link_reset_reset(l_ptr) || link_reset_unknown(l_ptr))
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 85fd3bc..bdb0fa2 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -122,7 +122,7 @@ struct link {
 	u32 checkpoint;
 	u32 peer_session;
 	u32 peer_bearer_id;
-	struct bearer *b_ptr;
+	struct tipc_bearer *b_ptr;
 	u32 tolerance;
 	u32 continuity_interval;
 	u32 abort_limit;
@@ -213,7 +213,7 @@ struct link {
 
 struct tipc_port;
 
-struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
+struct link *tipc_link_create(struct tipc_bearer *b_ptr, const u32 peer,
 			      const struct tipc_media_addr *media_addr);
 void tipc_link_delete(struct link *l_ptr);
 void tipc_link_changeover(struct link *l_ptr);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 3af53e3..e4dba1d 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -2,7 +2,7 @@
  * net/tipc/node.c: TIPC node management routines
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005-2006, Wind River Systems
+ * Copyright (c) 2005-2006, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -238,7 +238,7 @@ struct tipc_node *tipc_node_attach_link(struct link *l_ptr)
 			return n_ptr;
 		}
 		err("Attempt to establish second link on <%s> to %s\n",
-		    l_ptr->b_ptr->publ.name,
+		    l_ptr->b_ptr->name,
 		    tipc_addr_string_fill(addr_string, l_ptr->addr));
 	}
 	return NULL;
-- 
1.7.3.3

