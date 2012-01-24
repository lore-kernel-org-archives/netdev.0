From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 2/3] infiniband: cxgb4: Convert import_ep() over to
 dst_neigh_lookup().
Date: Tue, 24 Jan 2012 18:15:57 -0500 (EST)
Message-ID: <20120124.181557.1162311424589935621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Now we must provide the IP destination address, and a reference has
to be dropped when we're done with the entry.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 0668bb3..0cf6155 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1562,11 +1562,11 @@ static int import_ep(struct c4iw_ep *ep, __be32 peer_ip, struct dst_entry *dst,
 	struct neighbour *n;
 	int err, step;
 
-	rcu_read_lock();
-	n = dst_get_neighbour_noref(dst);
-	err = -ENODEV;
+	n = dst_neigh_lookup(dst, &peer_ip);
 	if (!n)
-		goto out;
+		return -ENODEV;
+
+	rcu_read_lock();
 	err = -ENOMEM;
 	if (n->dev->flags & IFF_LOOPBACK) {
 		struct net_device *pdev;
@@ -1614,6 +1614,8 @@ static int import_ep(struct c4iw_ep *ep, __be32 peer_ip, struct dst_entry *dst,
 out:
 	rcu_read_unlock();
 
+	neigh_release(n);
+
 	return err;
 }
 
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
