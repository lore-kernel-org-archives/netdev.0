From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/16] tipc: Add routines for safe checking of node's network address
Date: Fri, 20 Apr 2012 17:05:14 -0400
Message-ID: <1334955924-907-7-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62193 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754129Ab2DTVFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:33 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Introduces routines that test whether a given network address is
equal to a node's own network address or if it lies within the node's
own network cluster, and which work properly regardless of whether
the node is using the default network address <0.0.0> or a non-zero
network address that is assigned later on. In essence, these routines
ensure that address <0.0.0> is treated as an alias for "this node",
regardless of which network address the node is actually using.

Old users of the pre-existing more strict match in_own_cluster()
have been accordingly redirected to what is now called
in_own_cluster_exact() --- which does not extend matching to <0,0,0>.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/addr.h       |   20 +++++++++++++++++++-
 net/tipc/bearer.c     |    2 +-
 net/tipc/name_table.c |    6 +++---
 net/tipc/node.c       |    2 +-
 4 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index e4f35af..d706a1d 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -50,12 +50,30 @@ static inline u32 tipc_cluster_mask(u32 addr)
 	return addr & TIPC_CLUSTER_MASK;
 }
 
-static inline int in_own_cluster(u32 addr)
+static inline int in_own_cluster_exact(u32 addr)
 {
 	return !((addr ^ tipc_own_addr) >> 12);
 }
 
 /**
+ * in_own_node - test for node inclusion; <0.0.0> always matches
+ */
+
+static inline int in_own_node(u32 addr)
+{
+	return (addr == tipc_own_addr) || !addr;
+}
+
+/**
+ * in_own_cluster - test for cluster inclusion; <0.0.0> always matches
+ */
+
+static inline int in_own_cluster(u32 addr)
+{
+	return in_own_cluster_exact(addr) || !addr;
+}
+
+/**
  * addr_domain - convert 2-bit scope value to equivalent message lookup domain
  *
  * Needed when address of a named message must be looked up a second time
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 5dfd89c..0bfdeba 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -449,7 +449,7 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 		if (tipc_in_scope(disc_domain, tipc_own_addr)) {
 			disc_domain = tipc_own_addr & TIPC_CLUSTER_MASK;
 			res = 0;   /* accept any node in own cluster */
-		} else if (in_own_cluster(disc_domain))
+		} else if (in_own_cluster_exact(disc_domain))
 			res = 0;   /* accept specified node in own cluster */
 	}
 	if (res) {
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 5d70042..1e0518d 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -342,7 +342,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	list_add(&publ->zone_list, &info->zone_list);
 	info->zone_list_size++;
 
-	if (in_own_cluster(node)) {
+	if (in_own_cluster_exact(node)) {
 		list_add(&publ->cluster_list, &info->cluster_list);
 		info->cluster_list_size++;
 	}
@@ -411,7 +411,7 @@ found:
 
 	/* Remove publication from cluster scope list, if present */
 
-	if (in_own_cluster(node)) {
+	if (in_own_cluster_exact(node)) {
 		list_del(&publ->cluster_list);
 		info->cluster_list_size--;
 	}
@@ -604,7 +604,7 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 		publ = list_first_entry(&info->node_list, struct publication,
 					node_list);
 		list_move_tail(&publ->node_list, &info->node_list);
-	} else if (in_own_cluster(*destnode)) {
+	} else if (in_own_cluster_exact(*destnode)) {
 		if (list_empty(&info->cluster_list))
 			goto no_match;
 		publ = list_first_entry(&info->cluster_list, struct publication,
diff --git a/net/tipc/node.c b/net/tipc/node.c
index a34cabc..6a71bea 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -72,7 +72,7 @@ struct tipc_node *tipc_node_find(u32 addr)
 	struct tipc_node *node;
 	struct hlist_node *pos;
 
-	if (unlikely(!in_own_cluster(addr)))
+	if (unlikely(!in_own_cluster_exact(addr)))
 		return NULL;
 
 	hlist_for_each_entry(node, pos, &node_htable[tipc_hashfn(addr)], hash) {
-- 
1.7.9.3
