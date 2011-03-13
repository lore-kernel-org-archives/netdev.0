From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/26] tipc: Add network address mask helper routines
Date: Sun, 13 Mar 2011 17:33:51 -0400
Message-ID: <1300052054-7531-4-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49855 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755784Ab1CMVec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:32 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Introduces a pair of helper routines that convert the network address
for a TIPC node into the network address for its cluster or zone.

This is a cosmetic change designed to avoid future errors caused by
the incorrect use of address bitmasks, and does not alter the existing
operation of TIPC.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/addr.c |    4 ++--
 net/tipc/addr.h |   17 +++++++++++++----
 net/tipc/node.c |    2 +-
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 88463d9..087e399 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -81,9 +81,9 @@ int tipc_in_scope(u32 domain, u32 addr)
 {
 	if (!domain || (domain == addr))
 		return 1;
-	if (domain == (addr & 0xfffff000u)) /* domain <Z.C.0> */
+	if (domain == tipc_cluster_mask(addr)) /* domain <Z.C.0> */
 		return 1;
-	if (domain == (addr & 0xff000000u)) /* domain <Z.0.0> */
+	if (domain == tipc_zone_mask(addr)) /* domain <Z.0.0> */
 		return 1;
 	return 0;
 }
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 2490fad..8971aba 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -37,6 +37,16 @@
 #ifndef _TIPC_ADDR_H
 #define _TIPC_ADDR_H
 
+static inline u32 tipc_zone_mask(u32 addr)
+{
+	return addr & 0xff000000u;
+}
+
+static inline u32 tipc_cluster_mask(u32 addr)
+{
+	return addr & 0xfffff000u;
+}
+
 static inline int in_own_cluster(u32 addr)
 {
 	return !((addr ^ tipc_own_addr) >> 12);
@@ -49,14 +59,13 @@ static inline int in_own_cluster(u32 addr)
  * after a network hop.
  */
 
-static inline int addr_domain(int sc)
+static inline u32 addr_domain(u32 sc)
 {
 	if (likely(sc == TIPC_NODE_SCOPE))
 		return tipc_own_addr;
 	if (sc == TIPC_CLUSTER_SCOPE)
-		return tipc_addr(tipc_zone(tipc_own_addr),
-				 tipc_cluster(tipc_own_addr), 0);
-	return tipc_addr(tipc_zone(tipc_own_addr), 0, 0);
+		return tipc_cluster_mask(tipc_own_addr);
+	return tipc_zone_mask(tipc_own_addr);
 }
 
 int tipc_addr_domain_valid(u32);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index d040d47..14f98c8 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -470,7 +470,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLV for broadcast link */
 
-	link_info.dest = htonl(tipc_own_addr & 0xfffff000);
+	link_info.dest = htonl(tipc_cluster_mask(tipc_own_addr));
 	link_info.up = htonl(1);
 	strlcpy(link_info.str, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 	tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO, &link_info, sizeof(link_info));
-- 
1.7.3.3

