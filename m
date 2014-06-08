From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/2] net/mlx4_core: Fix SRIOV free-pool management when enforcing resource quotas
Date: Sun,  8 Jun 2014 13:49:45 +0300
Message-ID: <1402224586-21187-2-git-send-email-ogerlitz@mellanox.com>
References: <1402224586-21187-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:58774 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751907AbaFHKtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 06:49:52 -0400
In-Reply-To: <1402224586-21187-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The Hypervisor driver tracks free slots and reserved slots at the global level
and tracks allocated slots and guaranteed slots per VF.

Guaranteed slots are treated as reserved by the driver, so the total
reserved slots is the sum of all guaranteed slots over all the VFs.

As VFs allocate resources, free (global) is decremented and allocated (per VF)
is incremented for those resources. However, reserved (global) is never changed.

This means that effectively, when a VF allocates a resource from its
guaranteed pool, it is actually reducing that resource's free pool (since
the global reserved count was not also reduced).

The fix for this problem is the following: For each resource, as long as a
VF's allocated count is <= its guaranteed number, when allocating for that
VF, the reserved count (global) should be reduced by the allocation as well.

When the global reserved count reaches zero, the remaining global free count
is still accessible as the free pool for that resource.

When the VF frees resources, the reverse happens: the global reserved count
for a resource is incremented only once the VFs allocated number falls below
its guaranteed number.

This fix was developed by Rick Kready <kready@us.ibm.com>

Reported-by: Rick Kready <kready@us.ibm.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   41 ++++++++++++++++++--
 1 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 4aaf9bf..6d7b3b0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -279,7 +279,7 @@ enum qp_transition {
 };
 
 /* For Debug uses */
-static const char *ResourceType(enum mlx4_resource rt)
+static const char *resource_str(enum mlx4_resource rt)
 {
 	switch (rt) {
 	case RES_QP: return "RES_QP";
@@ -307,6 +307,7 @@ static inline int mlx4_grant_resource(struct mlx4_dev *dev, int slave,
 		&priv->mfunc.master.res_tracker.res_alloc[res_type];
 	int err = -EINVAL;
 	int allocated, free, reserved, guaranteed, from_free;
+	int from_rsvd;
 
 	if (slave > dev->num_vfs)
 		return -EINVAL;
@@ -321,11 +322,16 @@ static inline int mlx4_grant_resource(struct mlx4_dev *dev, int slave,
 		res_alloc->res_reserved;
 	guaranteed = res_alloc->guaranteed[slave];
 
-	if (allocated + count > res_alloc->quota[slave])
+	if (allocated + count > res_alloc->quota[slave]) {
+		mlx4_warn(dev, "VF %d port %d res %s: quota exceeded, count %d alloc %d quota %d\n",
+			  slave, port, resource_str(res_type), count,
+			  allocated, res_alloc->quota[slave]);
 		goto out;
+	}
 
 	if (allocated + count <= guaranteed) {
 		err = 0;
+		from_rsvd = count;
 	} else {
 		/* portion may need to be obtained from free area */
 		if (guaranteed - allocated > 0)
@@ -333,8 +339,14 @@ static inline int mlx4_grant_resource(struct mlx4_dev *dev, int slave,
 		else
 			from_free = count;
 
-		if (free - from_free > reserved)
+		from_rsvd = count - from_free;
+
+		if (free - from_free >= reserved)
 			err = 0;
+		else
+			mlx4_warn(dev, "VF %d port %d res %s: free pool empty, free %d from_free %d rsvd %d\n",
+				  slave, port, resource_str(res_type), free,
+				  from_free, reserved);
 	}
 
 	if (!err) {
@@ -342,9 +354,11 @@ static inline int mlx4_grant_resource(struct mlx4_dev *dev, int slave,
 		if (port > 0) {
 			res_alloc->allocated[(port - 1) * (dev->num_vfs + 1) + slave] += count;
 			res_alloc->res_port_free[port - 1] -= count;
+			res_alloc->res_port_rsvd[port - 1] -= from_rsvd;
 		} else {
 			res_alloc->allocated[slave] += count;
 			res_alloc->res_free -= count;
+			res_alloc->res_reserved -= from_rsvd;
 		}
 	}
 
@@ -360,17 +374,36 @@ static inline void mlx4_release_resource(struct mlx4_dev *dev, int slave,
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct resource_allocator *res_alloc =
 		&priv->mfunc.master.res_tracker.res_alloc[res_type];
+	int allocated, guaranteed, from_rsvd;
 
 	if (slave > dev->num_vfs)
 		return;
 
 	spin_lock(&res_alloc->alloc_lock);
+
+	allocated = (port > 0) ?
+		res_alloc->allocated[(port - 1) * (dev->num_vfs + 1) + slave] :
+		res_alloc->allocated[slave];
+	guaranteed = res_alloc->guaranteed[slave];
+
+	if (allocated - count >= guaranteed) {
+		from_rsvd = 0;
+	} else {
+		/* portion may need to be returned to reserved area */
+		if (allocated - guaranteed > 0)
+			from_rsvd = count - (allocated - guaranteed);
+		else
+			from_rsvd = count;
+	}
+
 	if (port > 0) {
 		res_alloc->allocated[(port - 1) * (dev->num_vfs + 1) + slave] -= count;
 		res_alloc->res_port_free[port - 1] += count;
+		res_alloc->res_port_rsvd[port - 1] += from_rsvd;
 	} else {
 		res_alloc->allocated[slave] -= count;
 		res_alloc->res_free += count;
+		res_alloc->res_reserved += from_rsvd;
 	}
 
 	spin_unlock(&res_alloc->alloc_lock);
@@ -4134,7 +4167,7 @@ static int _move_all_busy(struct mlx4_dev *dev, int slave,
 					if (print)
 						mlx4_dbg(dev,
 							 "%s id 0x%llx is busy\n",
-							  ResourceType(type),
+							  resource_str(type),
 							  r->res_id);
 					++busy;
 				} else {
-- 
1.7.1
