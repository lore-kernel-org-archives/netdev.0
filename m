From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: [PATCH 08/08] [TIPC]: TIPC network address handling cleanup
Date: Fri, 22 Feb 2008 11:59:38 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0246C898@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37825 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932222AbYBVUAW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 15:00:22 -0500
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id m1MK0KFL018288
	for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 12:00:22 -0800 (PST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch improves the code which manipulates TIPC network
address (aka <Z.C.N> values).

1) Address format validation routines are generalized to
   accept any valid <Z.C.N> value.

2) Eliminated inlining of scope checking code to prevent
   needless code duplication in non-critical path areas.

3) Introduced new primitives for manipulating network
   addresses to improve code readability.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/addr.c       |   35 ++++++++++++++++++++---------------
 net/tipc/addr.h       |   30 ++++++++++++++++++------------
 net/tipc/bearer.c     |    2 +-
 net/tipc/discover.c   |    2 +-
 net/tipc/name_table.c |    2 +-
 net/tipc/net.c        |    2 +-
 net/tipc/node.c       |    6 +++---
 7 files changed, 45 insertions(+), 34 deletions(-)

diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index e5207a1..84570ae 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -2,7 +2,7 @@
  * net/tipc/addr.c: TIPC address utility routines
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -49,8 +49,7 @@ u32 tipc_get_addr(void)
 /**
  * tipc_addr_domain_valid - validates a network domain address
  *
- * Accepts <Z.C.N>, <Z.C.0>, <Z.0.0>, and <0.0.0>,
- * where Z, C, and N are non-zero and do not exceed the configured
limits.
+ * Accepts <Z.C.N>, <Z.C.0>, <Z.0.0>, and <0.0.0>, where Z, C, & N are
non-zero.
  *
  * Returns 1 if domain address is valid, otherwise 0
  */
@@ -60,16 +59,6 @@ int tipc_addr_domain_valid(u32 addr)
 	u32 n = tipc_node(addr);
 	u32 c = tipc_cluster(addr);
 	u32 z = tipc_zone(addr);
-	u32 max_nodes = tipc_max_nodes;
-
-	if (is_slave(addr))
-		max_nodes = LOWEST_SLAVE + tipc_max_slaves;
-	if (n > max_nodes)
-		return 0;
-	if (c > tipc_max_clusters)
-		return 0;
-	if (z > tipc_max_zones)
-		return 0;
 
 	if (n && (!z || !c))
 		return 0;
@@ -81,8 +70,7 @@ int tipc_addr_domain_valid(u32 addr)
 /**
  * tipc_addr_node_valid - validates a proposed network address for this
node
  *
- * Accepts <Z.C.N>, where Z, C, and N are non-zero and do not exceed
- * the configured limits.
+ * Accepts <Z.C.N>, where Z, C, and N are non-zero.
  *
  * Returns 1 if address can be used, otherwise 0
  */
@@ -92,3 +80,20 @@ int tipc_addr_node_valid(u32 addr)
 	return (tipc_addr_domain_valid(addr) && tipc_node(addr));
 }
 
+/**
+ * tipc_in_scope - determines if network address lies within specified
domain
+ */
+
+int tipc_in_scope(u32 domain, u32 addr)
+{
+        if (likely(domain == addr))
+                return 1;
+	if (domain == 0)
+		return 1;
+	if (domain == addr_cluster(addr)) /* domain <Z.C.0> */
+		return 1;
+	if (domain == addr_zone(addr)) /* domain <Z.0.0> */
+		return 1;
+	return 0;
+}
+
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 3ba67e6..097eb20 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -2,7 +2,7 @@
  * net/tipc/addr.h: Include file for TIPC address utility routines
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -37,6 +37,17 @@
 #ifndef _TIPC_ADDR_H
 #define _TIPC_ADDR_H
 
+
+static inline u32 addr_zone(u32 addr)
+{
+        return addr & 0xff000000u;
+}
+
+static inline u32 addr_cluster(u32 addr)
+{
+        return addr & 0xfffff000u;
+}
+
 static inline u32 own_node(void)
 {
 	return tipc_node(tipc_own_addr);
@@ -57,6 +68,11 @@ static inline int in_own_cluster(u32 addr)
 	return !((addr ^ tipc_own_addr) >> 12);
 }
 
+static inline int in_own_zone(u32 addr)
+{
+	return !((addr ^ tipc_own_addr) >> 24);
+}
+
 static inline int is_slave(u32 addr)
 {
 	return addr & 0x800;
@@ -67,17 +83,6 @@ static inline int may_route(u32 addr)
 	return(addr ^ tipc_own_addr) >> 11;
 }
 
-static inline int in_scope(u32 domain, u32 addr)
-{
-	if (!domain || (domain == addr))
-		return 1;
-	if (domain == (addr & 0xfffff000u)) /* domain <Z.C.0> */
-		return 1;
-	if (domain == (addr & 0xff000000u)) /* domain <Z.0.0> */
-		return 1;
-	return 0;
-}
-
 /**
  * addr_scope - convert message lookup domain to equivalent 2-bit scope
value
  */
@@ -119,5 +124,6 @@ static inline char *addr_string_fill(char *string,
u32 addr)
 
 int tipc_addr_domain_valid(u32);
 int tipc_addr_node_valid(u32 addr);
+int tipc_in_scope(u32 domain, u32 addr);
 
 #endif
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 271a375..ec2fd2e 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -491,7 +491,7 @@ int tipc_enable_bearer(const char *name, u32
bcast_scope, u32 priority)
 		return -EINVAL;
 	}
 	if (!tipc_addr_domain_valid(bcast_scope) ||
-	    !in_scope(bcast_scope, tipc_own_addr)) {
+	    !tipc_in_scope(bcast_scope, tipc_own_addr)) {
 		warn("Bearer <%s> rejected, illegal broadcast scope\n",
name);
 		return -EINVAL;
 	}
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 5d643e5..c2c69c8 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -184,7 +184,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf)
 			disc_dupl_alert(b_ptr, tipc_own_addr,
&media_addr);
 		return;
 	}
-	if (!in_scope(dest, tipc_own_addr))
+	if (!tipc_in_scope(dest, tipc_own_addr))
 		return;
 	if (is_slave(tipc_own_addr) && is_slave(orig))
 		return;
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index ac7dfdd..dba78a0 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -611,7 +611,7 @@ u32 tipc_nametbl_translate(u32 type, u32 instance,
u32 *destnode)
 	struct name_seq *seq;
 	u32 ref;
 
-	if (!in_scope(*destnode, tipc_own_addr))
+	if (!tipc_in_scope(*destnode, tipc_own_addr))
 		return 0;
 
 	read_lock_bh(&tipc_nametbl_lock);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index c39c762..e218c5b 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -234,7 +234,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
 
 	/* Handle message for this node */
 	dnode = msg_short(msg) ? tipc_own_addr : msg_destnode(msg);
-	if (in_scope(dnode, tipc_own_addr)) {
+	if (tipc_in_scope(dnode, tipc_own_addr)) {
 		if (msg_isdata(msg)) {
 			if (msg_mcast(msg))
 				tipc_port_recv_mcast(buf, NULL);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 598f4d3..1d2cd1f 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -575,7 +575,7 @@ u32 tipc_available_nodes(const u32 domain)
 	u32 cnt = 0;
 
 	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
-		if (!in_scope(domain, n_ptr->addr))
+		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		if (tipc_node_is_up(n_ptr))
 			cnt++;
@@ -616,7 +616,7 @@ struct sk_buff *tipc_node_get_nodes(const void
*req_tlv_area, int req_tlv_space)
 	/* Add TLVs for all nodes in scope */
 
 	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
-		if (!in_scope(domain, n_ptr->addr))
+		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		node_info.addr = htonl(n_ptr->addr);
 		node_info.up = htonl(tipc_node_is_up(n_ptr));
@@ -669,7 +669,7 @@ struct sk_buff *tipc_node_get_links(const void
*req_tlv_area, int req_tlv_space)
 	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
 		u32 i;
 
-		if (!in_scope(domain, n_ptr->addr))
+		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		for (i = 0; i < MAX_BEARERS; i++) {
 			if (!n_ptr->links[i])
-- 
1.5.3.2
