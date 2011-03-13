From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/26] tipc: Convert node object array to a hash table
Date: Sun, 13 Mar 2011 17:33:58 -0400
Message-ID: <1300052054-7531-11-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49889 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756570Ab1CMVen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:43 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Replaces the dynamically allocated array of pointers to the cluster's
node objects with a static hash table. Hash collisions are resolved
using chaining, with a typical hash chain having only a single node,
to avoid degrading performance during processing of incoming packets.
The conversion to a hash table reduces the memory requirements for
TIPC's node table to approximately the same size it had prior to
the previous commit.

In addition to the hash table itself, TIPC now also maintains a
linked list for the node objects, sorted by ascending network address.
This list allows TIPC to continue sending responses to user space
applications that request node and link information in sorted order.
The list also improves performance when name table update messages are
sent by making it easier to identify the nodes that must be notified.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |    6 +---
 net/tipc/net.c        |   15 +++-------
 net/tipc/net.h        |    4 ---
 net/tipc/node.c       |   70 ++++++++++++++++++++++++++++++-------------------
 net/tipc/node.h       |   30 ++++++++++++++-------
 5 files changed, 70 insertions(+), 55 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index f2086f6..1b70d5d 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -109,11 +109,9 @@ static void named_cluster_distribute(struct sk_buff *buf)
 {
 	struct sk_buff *buf_copy;
 	struct tipc_node *n_ptr;
-	u32 n_num;
 
-	for (n_num = 1; n_num <= tipc_highest_node; n_num++) {
-		n_ptr = tipc_nodes[n_num];
-		if (n_ptr && tipc_node_has_active_links(n_ptr)) {
+	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+		if (tipc_node_has_active_links(n_ptr)) {
 			buf_copy = skb_copy(buf, GFP_ATOMIC);
 			if (!buf_copy)
 				break;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index b5b337f..cce8d08 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -39,6 +39,7 @@
 #include "name_distr.h"
 #include "subscr.h"
 #include "port.h"
+#include "node.h"
 #include "config.h"
 
 /*
@@ -108,27 +109,21 @@
 */
 
 DEFINE_RWLOCK(tipc_net_lock);
-struct tipc_node **tipc_nodes;
-u32 tipc_highest_node;
 atomic_t tipc_num_links;
 
 static int net_start(void)
 {
-	tipc_nodes = kcalloc(4096, sizeof(*tipc_nodes), GFP_ATOMIC);
-	tipc_highest_node = 0;
 	atomic_set(&tipc_num_links, 0);
 
-	return tipc_nodes ? 0 : -ENOMEM;
+	return 0;
 }
 
 static void net_stop(void)
 {
-	u32 n_num;
+	struct tipc_node *node, *t_node;
 
-	for (n_num = 1; n_num <= tipc_highest_node; n_num++)
-		tipc_node_delete(tipc_nodes[n_num]);
-	kfree(tipc_nodes);
-	tipc_nodes = NULL;
+	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
+		tipc_node_delete(node);
 }
 
 static void net_route_named_msg(struct sk_buff *buf)
diff --git a/net/tipc/net.h b/net/tipc/net.h
index b52b974..0ba6093 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -37,10 +37,6 @@
 #ifndef _TIPC_NET_H
 #define _TIPC_NET_H
 
-struct tipc_node;
-
-extern struct tipc_node **tipc_nodes;
-extern u32 tipc_highest_node;
 extern atomic_t tipc_num_links;
 
 extern rwlock_t tipc_net_lock;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 64976f2..22aeb2b 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -44,9 +44,31 @@ static void node_established_contact(struct tipc_node *n_ptr);
 
 static DEFINE_SPINLOCK(node_create_lock);
 
+static struct hlist_head node_htable[NODE_HTABLE_SIZE];
+LIST_HEAD(tipc_node_list);
+static u32 tipc_num_nodes;
 u32 tipc_own_tag;
 
 /**
+ * tipc_node_find - locate specified node object, if it exists
+ */
+
+struct tipc_node *tipc_node_find(u32 addr)
+{
+	struct tipc_node *node;
+	struct hlist_node *pos;
+
+	if (unlikely(!in_own_cluster(addr)))
+		return NULL;
+
+	hlist_for_each_entry(node, pos, &node_htable[tipc_hashfn(addr)], hash) {
+		if (node->addr == addr)
+			return node;
+	}
+	return NULL;
+}
+
+/**
  * tipc_node_create - create neighboring node
  *
  * Currently, this routine is called by neighbor discovery code, which holds
@@ -58,8 +80,7 @@ u32 tipc_own_tag;
 
 struct tipc_node *tipc_node_create(u32 addr)
 {
-	struct tipc_node *n_ptr;
-	u32 n_num;
+	struct tipc_node *n_ptr, *temp_node;
 
 	spin_lock_bh(&node_create_lock);
 
@@ -78,12 +99,19 @@ struct tipc_node *tipc_node_create(u32 addr)
 
 	n_ptr->addr = addr;
 	spin_lock_init(&n_ptr->lock);
+	INIT_HLIST_NODE(&n_ptr->hash);
+	INIT_LIST_HEAD(&n_ptr->list);
 	INIT_LIST_HEAD(&n_ptr->nsub);
 
-	n_num = tipc_node(addr);
-	tipc_nodes[n_num] = n_ptr;
-	if (n_num > tipc_highest_node)
-		tipc_highest_node = n_num;
+	hlist_add_head(&n_ptr->hash, &node_htable[tipc_hashfn(addr)]);
+
+	list_for_each_entry(temp_node, &tipc_node_list, list) {
+		if (n_ptr->addr < temp_node->addr)
+			break;
+	}
+	list_add_tail(&n_ptr->list, &temp_node->list);
+
+	tipc_num_nodes++;
 
 	spin_unlock_bh(&node_create_lock);
 	return n_ptr;
@@ -91,18 +119,11 @@ struct tipc_node *tipc_node_create(u32 addr)
 
 void tipc_node_delete(struct tipc_node *n_ptr)
 {
-	u32 n_num;
-
-	if (!n_ptr)
-		return;
-
-	n_num = tipc_node(n_ptr->addr);
-	tipc_nodes[n_num] = NULL;
+	list_del(&n_ptr->list);
+	hlist_del(&n_ptr->hash);
 	kfree(n_ptr);
 
-	while (!tipc_nodes[tipc_highest_node])
-		if (--tipc_highest_node == 0)
-			break;
+	tipc_num_nodes--;
 }
 
 
@@ -379,7 +400,6 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 	struct tipc_node *n_ptr;
 	struct tipc_node_info node_info;
 	u32 payload_size;
-	u32 n_num;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
@@ -390,15 +410,14 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 						   " (network address)");
 
 	read_lock_bh(&tipc_net_lock);
-	if (!tipc_nodes) {
+	if (!tipc_num_nodes) {
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_none();
 	}
 
 	/* For now, get space for all other nodes */
 
-	payload_size = TLV_SPACE(sizeof(node_info)) *
-		(tipc_highest_node - 1);
+	payload_size = TLV_SPACE(sizeof(node_info)) * tipc_num_nodes;
 	if (payload_size > 32768u) {
 		read_unlock_bh(&tipc_net_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
@@ -412,9 +431,8 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLVs for all nodes in scope */
 
-	for (n_num = 1; n_num <= tipc_highest_node; n_num++) {
-		n_ptr = tipc_nodes[n_num];
-		if (!n_ptr || !tipc_in_scope(domain, n_ptr->addr))
+	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		node_info.addr = htonl(n_ptr->addr);
 		node_info.up = htonl(tipc_node_is_up(n_ptr));
@@ -433,7 +451,6 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	struct tipc_node *n_ptr;
 	struct tipc_link_info link_info;
 	u32 payload_size;
-	u32 n_num;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
@@ -472,11 +489,10 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLVs for any other links in scope */
 
-	for (n_num = 1; n_num <= tipc_highest_node; n_num++) {
+	list_for_each_entry(n_ptr, &tipc_node_list, list) {
 		u32 i;
 
-		n_ptr = tipc_nodes[n_num];
-		if (!n_ptr || !tipc_in_scope(domain, n_ptr->addr))
+		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		tipc_node_lock(n_ptr);
 		for (i = 0; i < MAX_BEARERS; i++) {
diff --git a/net/tipc/node.h b/net/tipc/node.h
index c510a2a..02e4927 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -2,7 +2,7 @@
  * net/tipc/node.h: Include file for TIPC node management routines
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -46,7 +46,8 @@
  * struct tipc_node - TIPC node structure
  * @addr: network address of node
  * @lock: spinlock governing access to structure
- * @next: pointer to next node in sorted list of cluster's nodes
+ * @hash: links to adjacent nodes in unsorted hash chain
+ * @list: links to adjacent nodes in sorted list of cluster's nodes
  * @nsub: list of "node down" subscriptions monitoring node
  * @active_links: pointers to active links to node
  * @links: pointers to all links to node
@@ -69,7 +70,8 @@
 struct tipc_node {
 	u32 addr;
 	spinlock_t lock;
-	struct tipc_node *next;
+	struct hlist_node hash;
+	struct list_head list;
 	struct list_head nsub;
 	struct link *active_links[2];
 	struct link *links[MAX_BEARERS];
@@ -90,8 +92,23 @@ struct tipc_node {
 	} bclink;
 };
 
+#define NODE_HTABLE_SIZE 512
+extern struct list_head tipc_node_list;
+
+/*
+ * A trivial power-of-two bitmask technique is used for speed, since this
+ * operation is done for every incoming TIPC packet. The number of hash table
+ * entries has been chosen so that no hash chain exceeds 8 nodes and will
+ * usually be much smaller (typically only a single node).
+ */
+static inline unsigned int tipc_hashfn(u32 addr)
+{
+	return addr & (NODE_HTABLE_SIZE - 1);
+}
+
 extern u32 tipc_own_tag;
 
+struct tipc_node *tipc_node_find(u32 addr);
 struct tipc_node *tipc_node_create(u32 addr);
 void tipc_node_delete(struct tipc_node *n_ptr);
 struct tipc_node *tipc_node_attach_link(struct link *l_ptr);
@@ -104,13 +121,6 @@ int tipc_node_is_up(struct tipc_node *n_ptr);
 struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
 
-static inline struct tipc_node *tipc_node_find(u32 addr)
-{
-	if (likely(in_own_cluster(addr)))
-		return tipc_nodes[tipc_node(addr)];
-	return NULL;
-}
-
 static inline void tipc_node_lock(struct tipc_node *n_ptr)
 {
 	spin_lock_bh(&n_ptr->lock);
-- 
1.7.3.3

