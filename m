From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/16] tipc: Reduce footprint by un-inlining address routines
Date: Tue, 11 May 2010 20:30:13 -0400
Message-ID: <65ef8f6e73376f8a8ba0e37827552c86ebe0d81f.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35250 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065Ab0ELAab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:31 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UVIc000120
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:31 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Convert address-related inline routines that are more than one
line into standard functions, thereby eliminating a significant
amount of repeated code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/addr.c |   32 ++++++++++++++++++++++++++++++++
 net/tipc/addr.h |   37 +++----------------------------------
 2 files changed, 35 insertions(+), 34 deletions(-)

diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index e5207a1..c048543 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -92,3 +92,35 @@ int tipc_addr_node_valid(u32 addr)
 	return (tipc_addr_domain_valid(addr) && tipc_node(addr));
 }
 
+int tipc_in_scope(u32 domain, u32 addr)
+{
+	if (!domain || (domain == addr))
+		return 1;
+	if (domain == (addr & 0xfffff000u)) /* domain <Z.C.0> */
+		return 1;
+	if (domain == (addr & 0xff000000u)) /* domain <Z.0.0> */
+		return 1;
+	return 0;
+}
+
+/**
+ * tipc_addr_scope - convert message lookup domain to a 2-bit scope value
+ */
+
+int tipc_addr_scope(u32 domain)
+{
+	if (likely(!domain))
+		return TIPC_ZONE_SCOPE;
+	if (tipc_node(domain))
+		return TIPC_NODE_SCOPE;
+	if (tipc_cluster(domain))
+		return TIPC_CLUSTER_SCOPE;
+	return TIPC_ZONE_SCOPE;
+}
+
+char *tipc_addr_string_fill(char *string, u32 addr)
+{
+	snprintf(string, 16, "<%u.%u.%u>",
+		 tipc_zone(addr), tipc_cluster(addr), tipc_node(addr));
+	return string;
+}
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 4d4aee0..c1cc572 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -67,32 +67,6 @@ static inline int may_route(u32 addr)
 	return(addr ^ tipc_own_addr) >> 11;
 }
 
-static inline int tipc_in_scope(u32 domain, u32 addr)
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
-/**
- * tipc_addr_scope - convert message lookup domain to a 2-bit scope value
- */
-
-static inline int tipc_addr_scope(u32 domain)
-{
-	if (likely(!domain))
-		return TIPC_ZONE_SCOPE;
-	if (tipc_node(domain))
-		return TIPC_NODE_SCOPE;
-	if (tipc_cluster(domain))
-		return TIPC_CLUSTER_SCOPE;
-	return TIPC_ZONE_SCOPE;
-}
-
 /**
  * addr_domain - convert 2-bit scope value to equivalent message lookup domain
  *
@@ -110,14 +84,9 @@ static inline int addr_domain(int sc)
 	return tipc_addr(tipc_zone(tipc_own_addr), 0, 0);
 }
 
-static inline char *tipc_addr_string_fill(char *string, u32 addr)
-{
-	snprintf(string, 16, "<%u.%u.%u>",
-		 tipc_zone(addr), tipc_cluster(addr), tipc_node(addr));
-	return string;
-}
-
 int tipc_addr_domain_valid(u32);
 int tipc_addr_node_valid(u32 addr);
-
+int tipc_in_scope(u32 domain, u32 addr);
+int tipc_addr_scope(u32 domain);
+char *tipc_addr_string_fill(char *string, u32 addr);
 #endif
-- 
1.7.1.rc2

