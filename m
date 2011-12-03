From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/9] infiniband: addr: Consolidate code to fetch neighbout
 hardware address from dst.
Date: Fri, 02 Dec 2011 21:52:14 -0500 (EST)
Message-ID: <20111202.215214.2206154836146990479.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755755Ab1LCCwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:52:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IPV4 should do exactly what the IPV6 code does here, which is
use the neighbour obtained via the dst entry.

And now that the two code paths do the same thing, use a common
helper function to perform the operation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/addr.c |   47 +++++++++++++++++----------------------
 1 files changed, 21 insertions(+), 26 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 70154f7..1612cfd 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -178,6 +178,25 @@ static void queue_req(struct addr_req *req)
 	mutex_unlock(&lock);
 }
 
+static int dst_fetch_ha(struct dst_entry *dst, struct rdma_dev_addr *addr)
+{
+	struct neighbour *n;
+	int ret;
+
+	rcu_read_lock();
+	n = dst_get_neighbour_noref(dst);
+	if (!n || !(n->nud_state & NUD_VALID)) {
+		if (n)
+			neigh_event_send(n, NULL);
+		ret = -ENODATA;
+	} else {
+		ret = rdma_copy_addr(addr, dst->dev, n->ha);
+	}
+	rcu_read_unlock();
+
+	return ret;
+}
+
 static int addr4_resolve(struct sockaddr_in *src_in,
 			 struct sockaddr_in *dst_in,
 			 struct rdma_dev_addr *addr)
@@ -185,7 +204,6 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 	__be32 src_ip = src_in->sin_addr.s_addr;
 	__be32 dst_ip = dst_in->sin_addr.s_addr;
 	struct rtable *rt;
-	struct neighbour *neigh;
 	struct flowi4 fl4;
 	int ret;
 
@@ -214,20 +232,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 		goto put;
 	}
 
-	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->dst.dev);
-	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
-		rcu_read_lock();
-		neigh_event_send(dst_get_neighbour_noref(&rt->dst), NULL);
-		rcu_read_unlock();
-		ret = -ENODATA;
-		if (neigh)
-			goto release;
-		goto put;
-	}
-
-	ret = rdma_copy_addr(addr, neigh->dev, neigh->ha);
-release:
-	neigh_release(neigh);
+	ret = dst_fetch_ha(&rt->dst, addr);
 put:
 	ip_rt_put(rt);
 out:
@@ -240,7 +245,6 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 			 struct rdma_dev_addr *addr)
 {
 	struct flowi6 fl6;
-	struct neighbour *neigh;
 	struct dst_entry *dst;
 	int ret;
 
@@ -276,16 +280,7 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 		goto put;
 	}
 
-	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(dst);
-	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
-		if (neigh)
-			neigh_event_send(neigh, NULL);
-		ret = -ENODATA;
-	} else {
-		ret = rdma_copy_addr(addr, dst->dev, neigh->ha);
-	}
-	rcu_read_unlock();
+	ret = dst_fetch_ha(dst, addr);
 put:
 	dst_release(dst);
 	return ret;
-- 
1.7.7.3
