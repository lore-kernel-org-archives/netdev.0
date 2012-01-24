From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] infiniband: Convert dst_fetch_ha() over to
 dst_neigh_lookup().
Date: Tue, 24 Jan 2012 18:15:52 -0500 (EST)
Message-ID: <20120124.181552.1465561700058010931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sean.hefty@intel.com, hal.rosenstock@gmail.com,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43023 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab2AXXP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 18:15:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now we must provide the IP destination address, and a reference has
to be dropped when we're done with the entry.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/addr.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 1612cfd..6ef660c 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -178,22 +178,26 @@ static void queue_req(struct addr_req *req)
 	mutex_unlock(&lock);
 }
 
-static int dst_fetch_ha(struct dst_entry *dst, struct rdma_dev_addr *addr)
+static int dst_fetch_ha(struct dst_entry *dst, struct rdma_dev_addr *dev_addr, void *daddr)
 {
 	struct neighbour *n;
 	int ret;
 
+	n = dst_neigh_lookup(dst, daddr);
+
 	rcu_read_lock();
-	n = dst_get_neighbour_noref(dst);
 	if (!n || !(n->nud_state & NUD_VALID)) {
 		if (n)
 			neigh_event_send(n, NULL);
 		ret = -ENODATA;
 	} else {
-		ret = rdma_copy_addr(addr, dst->dev, n->ha);
+		ret = rdma_copy_addr(dev_addr, dst->dev, n->ha);
 	}
 	rcu_read_unlock();
 
+	if (n)
+		neigh_release(n);
+
 	return ret;
 }
 
@@ -232,7 +236,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 		goto put;
 	}
 
-	ret = dst_fetch_ha(&rt->dst, addr);
+	ret = dst_fetch_ha(&rt->dst, addr, &fl4.daddr);
 put:
 	ip_rt_put(rt);
 out:
@@ -280,7 +284,7 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 		goto put;
 	}
 
-	ret = dst_fetch_ha(dst, addr);
+	ret = dst_fetch_ha(dst, addr, &fl6.daddr);
 put:
 	dst_release(dst);
 	return ret;
-- 
1.7.7.6
