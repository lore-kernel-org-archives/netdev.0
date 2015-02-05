From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 8/9] tipc: simplify socket
	multicast reception
Date: Thu,  5 Feb 2015 08:36:43 -0500
Message-ID: <1423143404-23322-9-git-send-email-jon.maloy@ericsson.com>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The structure 'tipc_port_list' is used to collect port numbers
representing multicast destination socket on a receiving node.
The list is not based on a standard linked list, and is in reality
optimized for the uncommon case that there are more than one
multicast destinations per node. This makes the list handling
unecessarily complex, and as a consequence, even the socket
multicast reception becomes more complex.

In this commit, we replace 'tipc_port_list' with a new 'struct
tipc_plist', which is based on a standard list. We give the new
list stack (push/pop) semantics, someting that simplifies
the implementation of the function tipc_sk_mcast_rcv().

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c      | 49 +------------------------------------------------
 net/tipc/bcast.h      | 24 ++++--------------------
 net/tipc/name_table.c | 44 +++++++++++++++++++++++++++++++++++++++++---
 net/tipc/name_table.h | 18 ++++++++++++++++--
 net/tipc/socket.c     | 48 +++++++++++++++++++++---------------------------
 net/tipc/socket.h     |  2 +-
 6 files changed, 84 insertions(+), 101 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 2dfaf27..3eaa931 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/bcast.c: TIPC broadcast code
  *
- * Copyright (c) 2004-2006, 2014, Ericsson AB
+ * Copyright (c) 2004-2006, 2014-2015, Ericsson AB
  * Copyright (c) 2004, Intel Corporation.
  * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
@@ -1037,50 +1037,3 @@ static void tipc_nmap_diff(struct tipc_node_map *nm_a,
 		}
 	}
 }
-
-/**
- * tipc_port_list_add - add a port to a port list, ensuring no duplicates
- */
-void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port)
-{
-	struct tipc_port_list *item = pl_ptr;
-	int i;
-	int item_sz = PLSIZE;
-	int cnt = pl_ptr->count;
-
-	for (; ; cnt -= item_sz, item = item->next) {
-		if (cnt < PLSIZE)
-			item_sz = cnt;
-		for (i = 0; i < item_sz; i++)
-			if (item->ports[i] == port)
-				return;
-		if (i < PLSIZE) {
-			item->ports[i] = port;
-			pl_ptr->count++;
-			return;
-		}
-		if (!item->next) {
-			item->next = kmalloc(sizeof(*item), GFP_ATOMIC);
-			if (!item->next) {
-				pr_warn("Incomplete multicast delivery, no memory\n");
-				return;
-			}
-			item->next->next = NULL;
-		}
-	}
-}
-
-/**
- * tipc_port_list_free - free dynamically created entries in port_list chain
- *
- */
-void tipc_port_list_free(struct tipc_port_list *pl_ptr)
-{
-	struct tipc_port_list *item;
-	struct tipc_port_list *next;
-
-	for (item = pl_ptr->next; item; item = next) {
-		next = item->next;
-		kfree(item);
-	}
-}
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 6ea190d..8f4d4dc 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/bcast.h: Include file for TIPC broadcast code
  *
- * Copyright (c) 2003-2006, 2014, Ericsson AB
+ * Copyright (c) 2003-2006, 2014-2015, Ericsson AB
  * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -41,22 +41,6 @@
 #include "link.h"
 #include "node.h"
 
-#define TIPC_BCLINK_RESET	1
-#define PLSIZE			32
-#define	BCBEARER		MAX_BEARERS
-
-/**
- * struct tipc_port_list - set of node local destination ports
- * @count: # of ports in set (only valid for first entry in list)
- * @next: pointer to next entry in list
- * @ports: array of port references
- */
-struct tipc_port_list {
-	int count;
-	struct tipc_port_list *next;
-	u32 ports[PLSIZE];
-};
-
 /**
  * struct tipc_bcbearer_pair - a pair of bearers used by broadcast link
  * @primary: pointer to primary bearer
@@ -71,6 +55,9 @@ struct tipc_bcbearer_pair {
 	struct tipc_bearer *secondary;
 };
 
+#define TIPC_BCLINK_RESET	1
+#define	BCBEARER		MAX_BEARERS
+
 /**
  * struct tipc_bcbearer - bearer used by broadcast link
  * @bearer: (non-standard) broadcast bearer structure
@@ -126,9 +113,6 @@ static inline int tipc_nmap_equal(struct tipc_node_map *nm_a,
 	return !memcmp(nm_a, nm_b, sizeof(*nm_a));
 }
 
-void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port);
-void tipc_port_list_free(struct tipc_port_list *pl_ptr);
-
 int tipc_bclink_init(struct net *net);
 void tipc_bclink_stop(struct net *net);
 void tipc_bclink_set_flags(struct net *tn, unsigned int flags);
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index ce09b86..18a3d44 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/name_table.c: TIPC name table code
  *
- * Copyright (c) 2000-2006, 2014, Ericsson AB
+ * Copyright (c) 2000-2006, 2014-2015, Ericsson AB
  * Copyright (c) 2004-2008, 2010-2014, Wind River Systems
  * All rights reserved.
  *
@@ -618,7 +618,7 @@ not_found:
  * Returns non-zero if any off-node ports overlap
  */
 int tipc_nametbl_mc_translate(struct net *net, u32 type, u32 lower, u32 upper,
-			      u32 limit, struct tipc_port_list *dports)
+			      u32 limit, struct tipc_plist *dports)
 {
 	struct name_seq *seq;
 	struct sub_seq *sseq;
@@ -643,7 +643,7 @@ int tipc_nametbl_mc_translate(struct net *net, u32 type, u32 lower, u32 upper,
 		info = sseq->info;
 		list_for_each_entry(publ, &info->node_list, node_list) {
 			if (publ->scope <= limit)
-				tipc_port_list_add(dports, publ->ref);
+				tipc_plist_push(dports, publ->ref);
 		}
 
 		if (info->cluster_list_size != info->node_list_size)
@@ -1212,3 +1212,41 @@ int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	return skb->len;
 }
+
+void tipc_plist_push(struct tipc_plist *pl, u32 port)
+{
+	struct tipc_plist *nl;
+
+	if (likely(!pl->port)) {
+		pl->port = port;
+		return;
+	}
+	if (pl->port == port)
+		return;
+	list_for_each_entry(nl, &pl->list, list) {
+		if (nl->port == port)
+			return;
+	}
+	nl = kmalloc(sizeof(*nl), GFP_ATOMIC);
+	if (nl) {
+		nl->port = port;
+		list_add(&nl->list, &pl->list);
+	}
+}
+
+u32 tipc_plist_pop(struct tipc_plist *pl)
+{
+	struct tipc_plist *nl;
+	u32 port = 0;
+
+	if (likely(list_empty(&pl->list))) {
+		port = pl->port;
+		pl->port = 0;
+		return port;
+	}
+	nl = list_first_entry(&pl->list, typeof(*nl), list);
+	port = nl->port;
+	list_del(&nl->list);
+	kfree(nl);
+	return port;
+}
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index f67b3d8..52501fd 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -38,7 +38,7 @@
 #define _TIPC_NAME_TABLE_H
 
 struct tipc_subscription;
-struct tipc_port_list;
+struct tipc_plist;
 
 /*
  * TIPC name types reserved for internal TIPC use (both current and planned)
@@ -101,7 +101,7 @@ struct sk_buff *tipc_nametbl_get(struct net *net, const void *req_tlv_area,
 				 int req_tlv_space);
 u32 tipc_nametbl_translate(struct net *net, u32 type, u32 instance, u32 *node);
 int tipc_nametbl_mc_translate(struct net *net, u32 type, u32 lower, u32 upper,
-			      u32 limit, struct tipc_port_list *dports);
+			      u32 limit, struct tipc_plist *dports);
 struct publication *tipc_nametbl_publish(struct net *net, u32 type, u32 lower,
 					 u32 upper, u32 scope, u32 port_ref,
 					 u32 key);
@@ -118,4 +118,18 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s);
 int tipc_nametbl_init(struct net *net);
 void tipc_nametbl_stop(struct net *net);
 
+struct tipc_plist {
+	struct list_head list;
+	u32 port;
+};
+
+static inline void tipc_plist_init(struct tipc_plist *pl)
+{
+	INIT_LIST_HEAD(&pl->list);
+	pl->port = 0;
+}
+
+void tipc_plist_push(struct tipc_plist *pl, u32 port);
+u32 tipc_plist_pop(struct tipc_plist *pl);
+
 #endif
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index c1a4611..26aec84 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/socket.c: TIPC socket API
  *
- * Copyright (c) 2001-2007, 2012-2014, Ericsson AB
+ * Copyright (c) 2001-2007, 2012-2015, Ericsson AB
  * Copyright (c) 2004-2008, 2010-2013, Wind River Systems
  * All rights reserved.
  *
@@ -778,48 +778,42 @@ new_mtu:
 
 /* tipc_sk_mcast_rcv - Deliver multicast message to all destination sockets
  */
-void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf)
+void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *skb)
 {
-	struct tipc_msg *msg = buf_msg(buf);
-	struct tipc_port_list dports = {0, NULL, };
-	struct tipc_port_list *item;
-	struct sk_buff *b;
-	uint i, last, dst = 0;
+	struct tipc_msg *msg = buf_msg(skb);
+	struct tipc_plist dports;
+	struct sk_buff *cskb;
+	u32 portid;
 	u32 scope = TIPC_CLUSTER_SCOPE;
-	struct sk_buff_head msgs;
+	struct sk_buff_head msgq;
+	uint hsz = skb_headroom(skb) + msg_hdr_sz(msg);
+
+	skb_queue_head_init(&msgq);
+	tipc_plist_init(&dports);
 
 	if (in_own_node(net, msg_orignode(msg)))
 		scope = TIPC_NODE_SCOPE;
 
 	if (unlikely(!msg_mcast(msg))) {
 		pr_warn("Received non-multicast msg in multicast\n");
-		kfree_skb(buf);
 		goto exit;
 	}
 	/* Create destination port list: */
 	tipc_nametbl_mc_translate(net, msg_nametype(msg), msg_namelower(msg),
 				  msg_nameupper(msg), scope, &dports);
-	last = dports.count;
-	if (!last) {
-		kfree_skb(buf);
-		return;
-	}
-
-	for (item = &dports; item; item = item->next) {
-		for (i = 0; i < PLSIZE && ++dst <= last; i++) {
-			b = (dst != last) ? skb_clone(buf, GFP_ATOMIC) : buf;
-			if (!b) {
-				pr_warn("Failed do clone mcast rcv buffer\n");
-				continue;
-			}
-			msg_set_destport(msg, item->ports[i]);
-			skb_queue_head_init(&msgs);
-			skb_queue_tail(&msgs, b);
-			tipc_sk_rcv(net, &msgs);
+	portid = tipc_plist_pop(&dports);
+	for (; portid; portid = tipc_plist_pop(&dports)) {
+		cskb = __pskb_copy(skb, hsz, GFP_ATOMIC);
+		if (!cskb) {
+			pr_warn("Failed do clone mcast rcv buffer\n");
+			continue;
 		}
+		msg_set_destport(buf_msg(cskb), portid);
+		skb_queue_tail(&msgq, cskb);
 	}
+	tipc_sk_rcv(net, &msgq);
 exit:
-	tipc_port_list_free(&dports);
+	kfree_skb(skb);
 }
 
 /**
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index e3dbdc0..95b0159 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -1,6 +1,6 @@
 /* net/tipc/socket.h: Include file for TIPC socket code
  *
- * Copyright (c) 2014, Ericsson AB
+ * Copyright (c) 2014-2015, Ericsson AB
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
