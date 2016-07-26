From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 1/5] tipc: introduce constants
	for tipc address validation
Date: Tue, 26 Jul 2016 08:47:18 +0200
Message-ID: <1469515642-9498-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1469515642-9498-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1469515642-9498-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In this commit, we introduce defines for tipc address size,
offset and mask specification for Zone.Cluster.Node.
There is no functional change in this commit.

Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 include/uapi/linux/tipc.h | 30 ++++++++++++++++++++++++++----
 net/tipc/addr.h           |  5 +----
 net/tipc/bearer.c         |  4 ++--
 3 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index 6f71b9b41595..bf049e8fe31b 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -60,26 +60,48 @@ struct tipc_name_seq {
 	__u32 upper;
 };
 
+/* TIPC Address Size, Offset, Mask specification for Z.C.N
+ */
+#define TIPC_NODE_BITS          12
+#define TIPC_CLUSTER_BITS       12
+#define TIPC_ZONE_BITS          8
+
+#define TIPC_NODE_OFFSET        0
+#define TIPC_CLUSTER_OFFSET     TIPC_NODE_BITS
+#define TIPC_ZONE_OFFSET        (TIPC_CLUSTER_OFFSET + TIPC_CLUSTER_BITS)
+
+#define TIPC_NODE_SIZE          ((1UL << TIPC_NODE_BITS) - 1)
+#define TIPC_CLUSTER_SIZE       ((1UL << TIPC_CLUSTER_BITS) - 1)
+#define TIPC_ZONE_SIZE          ((1UL << TIPC_ZONE_BITS) - 1)
+
+#define TIPC_NODE_MASK		(TIPC_NODE_SIZE << TIPC_NODE_OFFSET)
+#define TIPC_CLUSTER_MASK	(TIPC_CLUSTER_SIZE << TIPC_CLUSTER_OFFSET)
+#define TIPC_ZONE_MASK		(TIPC_ZONE_SIZE << TIPC_ZONE_OFFSET)
+
+#define TIPC_ZONE_CLUSTER_MASK (TIPC_ZONE_MASK | TIPC_CLUSTER_MASK)
+
 static inline __u32 tipc_addr(unsigned int zone,
 			      unsigned int cluster,
 			      unsigned int node)
 {
-	return (zone << 24) | (cluster << 12) | node;
+	return (zone << TIPC_ZONE_OFFSET) |
+		(cluster << TIPC_CLUSTER_OFFSET) |
+		node;
 }
 
 static inline unsigned int tipc_zone(__u32 addr)
 {
-	return addr >> 24;
+	return addr >> TIPC_ZONE_OFFSET;
 }
 
 static inline unsigned int tipc_cluster(__u32 addr)
 {
-	return (addr >> 12) & 0xfff;
+	return (addr & TIPC_CLUSTER_MASK) >> TIPC_CLUSTER_OFFSET;
 }
 
 static inline unsigned int tipc_node(__u32 addr)
 {
-	return addr & 0xfff;
+	return addr & TIPC_NODE_MASK;
 }
 
 /*
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 64f4004a6fac..bebb347803ce 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -43,9 +43,6 @@
 #include <net/netns/generic.h>
 #include "core.h"
 
-#define TIPC_ZONE_MASK		0xff000000u
-#define TIPC_CLUSTER_MASK	0xfffff000u
-
 static inline u32 tipc_own_addr(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
@@ -60,7 +57,7 @@ static inline u32 tipc_zone_mask(u32 addr)
 
 static inline u32 tipc_cluster_mask(u32 addr)
 {
-	return addr & TIPC_CLUSTER_MASK;
+	return addr & TIPC_ZONE_CLUSTER_MASK;
 }
 
 u32 tipc_own_addr(struct net *net);
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 4131d5a86f55..65b0998a9bab 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -225,7 +225,7 @@ static int tipc_enable_bearer(struct net *net, const char *name,
 	if (tipc_addr_domain_valid(disc_domain) &&
 	    (disc_domain != tn->own_addr)) {
 		if (tipc_in_scope(disc_domain, tn->own_addr)) {
-			disc_domain = tn->own_addr & TIPC_CLUSTER_MASK;
+			disc_domain = tn->own_addr & TIPC_ZONE_CLUSTER_MASK;
 			res = 0;   /* accept any node in own cluster */
 		} else if (in_own_cluster_exact(net, disc_domain))
 			res = 0;   /* accept specified node in own cluster */
@@ -832,7 +832,7 @@ int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
 	u32 prio;
 
 	prio = TIPC_MEDIA_LINK_PRI;
-	domain = tn->own_addr & TIPC_CLUSTER_MASK;
+	domain = tn->own_addr & TIPC_ZONE_CLUSTER_MASK;
 
 	if (!info->attrs[TIPC_NLA_BEARER])
 		return -EINVAL;
-- 
2.1.4


------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports.http://sdm.link/zohodev2dev
