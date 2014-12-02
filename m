From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 2/8] tipc: make name table
	allocated dynamically
Date: Tue, 2 Dec 2014 15:00:24 +0800
Message-ID: <1417503630-31352-3-git-send-email-ying.xue@windriver.com>
References: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Name table locking policy is going to be adjusted from read-write
lock protection to RCU lock protection in the future commits. But
its essential precondition is to convert the allocation way of name
table from static to dynamic mode.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_distr.c |   44 +++++++++---------------------------
 net/tipc/name_table.c |   60 ++++++++++++++++++++++++-------------------------
 net/tipc/name_table.h |   16 ++++++++++++-
 3 files changed, 55 insertions(+), 65 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 628cd85..ed00929 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -38,34 +38,6 @@
 #include "link.h"
 #include "name_distr.h"
 
-/**
- * struct publ_list - list of publications made by this node
- * @list: circular list of publications
- */
-struct publ_list {
-	struct list_head list;
-};
-
-static struct publ_list publ_zone = {
-	.list = LIST_HEAD_INIT(publ_zone.list),
-};
-
-static struct publ_list publ_cluster = {
-	.list = LIST_HEAD_INIT(publ_cluster.list),
-};
-
-static struct publ_list publ_node = {
-	.list = LIST_HEAD_INIT(publ_node.list),
-};
-
-static struct publ_list *publ_lists[] = {
-	NULL,
-	&publ_zone,	/* publ_lists[TIPC_ZONE_SCOPE]		*/
-	&publ_cluster,	/* publ_lists[TIPC_CLUSTER_SCOPE]	*/
-	&publ_node	/* publ_lists[TIPC_NODE_SCOPE]		*/
-};
-
-
 int sysctl_tipc_named_timeout __read_mostly = 2000;
 
 /**
@@ -141,7 +113,8 @@ struct sk_buff *tipc_named_publish(struct publication *publ)
 	struct sk_buff *buf;
 	struct distr_item *item;
 
-	list_add_tail(&publ->local_list, &publ_lists[publ->scope]->list);
+	list_add_tail(&publ->local_list,
+		      &tipc_nametbl->publ_list[publ->scope]);
 
 	if (publ->scope == TIPC_NODE_SCOPE)
 		return NULL;
@@ -188,7 +161,7 @@ struct sk_buff *tipc_named_withdraw(struct publication *publ)
  * @pls: linked list of publication items to be packed into buffer chain
  */
 static void named_distribute(struct sk_buff_head *list, u32 dnode,
-			     struct publ_list *pls)
+			     struct list_head *pls)
 {
 	struct publication *publ;
 	struct sk_buff *skb = NULL;
@@ -196,7 +169,7 @@ static void named_distribute(struct sk_buff_head *list, u32 dnode,
 	uint msg_dsz = (tipc_node_get_mtu(dnode, 0) / ITEM_SIZE) * ITEM_SIZE;
 	uint msg_rem = msg_dsz;
 
-	list_for_each_entry(publ, &pls->list, local_list) {
+	list_for_each_entry(publ, pls, local_list) {
 		/* Prepare next buffer: */
 		if (!skb) {
 			skb = named_prepare_buf(PUBLICATION, msg_rem, dnode);
@@ -236,8 +209,10 @@ void tipc_named_node_up(u32 dnode)
 	__skb_queue_head_init(&head);
 
 	read_lock_bh(&tipc_nametbl_lock);
-	named_distribute(&head, dnode, &publ_cluster);
-	named_distribute(&head, dnode, &publ_zone);
+	named_distribute(&head, dnode,
+			 &tipc_nametbl->publ_list[TIPC_CLUSTER_SCOPE]);
+	named_distribute(&head, dnode,
+			 &tipc_nametbl->publ_list[TIPC_ZONE_SCOPE]);
 	read_unlock_bh(&tipc_nametbl_lock);
 
 	tipc_link_xmit(&head, dnode, dnode);
@@ -427,7 +402,8 @@ void tipc_named_reinit(void)
 	write_lock_bh(&tipc_nametbl_lock);
 
 	for (scope = TIPC_ZONE_SCOPE; scope <= TIPC_NODE_SCOPE; scope++)
-		list_for_each_entry(publ, &publ_lists[scope]->list, local_list)
+		list_for_each_entry(publ, &tipc_nametbl->publ_list[scope],
+				    local_list)
 			publ->node = tipc_own_addr;
 
 	write_unlock_bh(&tipc_nametbl_lock);
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 772be1c..df3da29 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -2,7 +2,7 @@
  * net/tipc/name_table.c: TIPC name table code
  *
  * Copyright (c) 2000-2006, 2014, Ericsson AB
- * Copyright (c) 2004-2008, 2010-2011, Wind River Systems
+ * Copyright (c) 2004-2008, 2010-2014, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -103,18 +103,7 @@ struct name_seq {
 	spinlock_t lock;
 };
 
-/**
- * struct name_table - table containing all existing port name publications
- * @types: pointer to fixed-sized array of name sequence lists,
- *         accessed via hashing on 'type'; name sequence lists are *not* sorted
- * @local_publ_count: number of publications issued by this node
- */
-struct name_table {
-	struct hlist_head *types;
-	u32 local_publ_count;
-};
-
-static struct name_table table;
+struct name_table *tipc_nametbl;
 DEFINE_RWLOCK(tipc_nametbl_lock);
 
 static int hash(int x)
@@ -475,7 +464,7 @@ static struct name_seq *nametbl_find_seq(u32 type)
 	struct hlist_head *seq_head;
 	struct name_seq *ns;
 
-	seq_head = &table.types[hash(type)];
+	seq_head = &tipc_nametbl->seq_hlist[hash(type)];
 	hlist_for_each_entry(ns, seq_head, ns_list) {
 		if (ns->type == type)
 			return ns;
@@ -488,6 +477,7 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 					     u32 scope, u32 node, u32 port, u32 key)
 {
 	struct name_seq *seq = nametbl_find_seq(type);
+	int index = hash(type);
 
 	if ((scope < TIPC_ZONE_SCOPE) || (scope > TIPC_NODE_SCOPE) ||
 	    (lower > upper)) {
@@ -497,7 +487,8 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 	}
 
 	if (!seq)
-		seq = tipc_nameseq_create(type, &table.types[hash(type)]);
+		seq = tipc_nameseq_create(type,
+					  &tipc_nametbl->seq_hlist[index]);
 	if (!seq)
 		return NULL;
 
@@ -667,7 +658,7 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 	struct publication *publ;
 	struct sk_buff *buf = NULL;
 
-	if (table.local_publ_count >= TIPC_MAX_PUBLICATIONS) {
+	if (tipc_nametbl->local_publ_count >= TIPC_MAX_PUBLICATIONS) {
 		pr_warn("Publication failed, local publication limit reached (%u)\n",
 			TIPC_MAX_PUBLICATIONS);
 		return NULL;
@@ -677,7 +668,7 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 	publ = tipc_nametbl_insert_publ(type, lower, upper, scope,
 				   tipc_own_addr, port_ref, key);
 	if (likely(publ)) {
-		table.local_publ_count++;
+		tipc_nametbl->local_publ_count++;
 		buf = tipc_named_publish(publ);
 		/* Any pending external events? */
 		tipc_named_process_backlog();
@@ -700,7 +691,7 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 	write_lock_bh(&tipc_nametbl_lock);
 	publ = tipc_nametbl_remove_publ(type, lower, tipc_own_addr, ref, key);
 	if (likely(publ)) {
-		table.local_publ_count--;
+		tipc_nametbl->local_publ_count--;
 		buf = tipc_named_withdraw(publ);
 		/* Any pending external events? */
 		tipc_named_process_backlog();
@@ -725,12 +716,14 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 void tipc_nametbl_subscribe(struct tipc_subscription *s)
 {
 	u32 type = s->seq.type;
+	int index = hash(type);
 	struct name_seq *seq;
 
 	write_lock_bh(&tipc_nametbl_lock);
 	seq = nametbl_find_seq(type);
 	if (!seq)
-		seq = tipc_nameseq_create(type, &table.types[hash(type)]);
+		seq = tipc_nameseq_create(type,
+					  &tipc_nametbl->seq_hlist[index]);
 	if (seq) {
 		spin_lock_bh(&seq->lock);
 		tipc_nameseq_subscribe(seq, s);
@@ -882,7 +875,7 @@ static int nametbl_list(char *buf, int len, u32 depth_info,
 		lowbound = 0;
 		upbound = ~0;
 		for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
-			seq_head = &table.types[i];
+			seq_head = &tipc_nametbl->seq_hlist[i];
 			hlist_for_each_entry(seq, seq_head, ns_list) {
 				ret += nameseq_list(seq, buf + ret, len - ret,
 						   depth, seq->type,
@@ -898,7 +891,7 @@ static int nametbl_list(char *buf, int len, u32 depth_info,
 		}
 		ret += nametbl_header(buf + ret, len - ret, depth);
 		i = hash(type);
-		seq_head = &table.types[i];
+		seq_head = &tipc_nametbl->seq_hlist[i];
 		hlist_for_each_entry(seq, seq_head, ns_list) {
 			if (seq->type == type) {
 				ret += nameseq_list(seq, buf + ret, len - ret,
@@ -945,12 +938,18 @@ struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
 
 int tipc_nametbl_init(void)
 {
-	table.types = kcalloc(TIPC_NAMETBL_SIZE, sizeof(struct hlist_head),
-			      GFP_ATOMIC);
-	if (!table.types)
+	int i;
+
+	tipc_nametbl = kzalloc(sizeof(*tipc_nametbl), GFP_ATOMIC);
+	if (!tipc_nametbl)
 		return -ENOMEM;
 
-	table.local_publ_count = 0;
+	for (i = 0; i < TIPC_NAMETBL_SIZE; i++)
+		INIT_HLIST_HEAD(&tipc_nametbl->seq_hlist[i]);
+
+	INIT_LIST_HEAD(&tipc_nametbl->publ_list[TIPC_ZONE_SCOPE]);
+	INIT_LIST_HEAD(&tipc_nametbl->publ_list[TIPC_CLUSTER_SCOPE]);
+	INIT_LIST_HEAD(&tipc_nametbl->publ_list[TIPC_NODE_SCOPE]);
 	return 0;
 }
 
@@ -990,16 +989,17 @@ void tipc_nametbl_stop(void)
 	 */
 	write_lock_bh(&tipc_nametbl_lock);
 	for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
-		if (hlist_empty(&table.types[i]))
+		if (hlist_empty(&tipc_nametbl->seq_hlist[i]))
 			continue;
-		seq_head = &table.types[i];
+		seq_head = &tipc_nametbl->seq_hlist[i];
 		hlist_for_each_entry_safe(seq, safe, seq_head, ns_list) {
 			tipc_purge_publications(seq);
 		}
 	}
-	kfree(table.types);
-	table.types = NULL;
 	write_unlock_bh(&tipc_nametbl_lock);
+
+	kfree(tipc_nametbl);
+
 }
 
 static int __tipc_nl_add_nametable_publ(struct tipc_nl_msg *msg,
@@ -1113,7 +1113,7 @@ static int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type,
 		i = 0;
 
 	for (; i < TIPC_NAMETBL_SIZE; i++) {
-		seq_head = &table.types[i];
+		seq_head = &tipc_nametbl->seq_hlist[i];
 
 		if (*last_type) {
 			seq = nametbl_find_seq(*last_type);
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index c628778..c1fd734 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -43,7 +43,9 @@ struct tipc_port_list;
 /*
  * TIPC name types reserved for internal TIPC use (both current and planned)
  */
-#define TIPC_ZM_SRV 3		/* zone master service name type */
+#define TIPC_ZM_SRV		3	/* zone master service name type */
+#define TIPC_PUBL_SCOPE_NUM	(TIPC_NODE_SCOPE + 1)
+#define TIPC_NAMETBL_SIZE	1024	/* must be a power of 2 */
 
 /**
  * struct publication - info about a published (name or) name sequence
@@ -79,8 +81,20 @@ struct publication {
 	struct list_head zone_list;
 };
 
+/**
+ * struct name_table - table containing all existing port name publications
+ * @seq_hlist: name sequence hash lists
+ * @publ_list: pulication lists
+ * @local_publ_count: number of publications issued by this node
+ */
+struct name_table {
+	struct hlist_head seq_hlist[TIPC_NAMETBL_SIZE];
+	struct list_head publ_list[TIPC_PUBL_SCOPE_NUM];
+	u32 local_publ_count;
+};
 
 extern rwlock_t tipc_nametbl_lock;
+extern struct name_table *tipc_nametbl;
 
 int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
