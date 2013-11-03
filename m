From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 9/9] net/mlx4_core: Implement resource quota enforcement
Date: Sun,  3 Nov 2013 10:03:25 +0200
Message-ID: <1383465805-28640-10-git-send-email-ogerlitz@mellanox.com>
References: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51782 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752609Ab3KCIDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Nov 2013 03:03:36 -0500
In-Reply-To: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Implements resource quota grant decision when resources are requested,
for the following resources:  QPs, CQs, SRQs, MPTs, MTTs, vlans, MACs,
and Counters.

When granting a resource, the quota system increases the allocated-count
for that slave.

When the slave later frees the resource, its allocated-count is reduced.

A spinlock is used to protect the integrity of each resource's free-pool counter.
(One slave may be in the process of being granted a resource while another
slave has crashed, initiating cleanup of that slave's resource quotas).

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    1 +
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  185 ++++++++++++++++++--
 2 files changed, 173 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index e7eb86e..e582a41 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -505,6 +505,7 @@ struct slave_list {
 };
 
 struct resource_allocator {
+	spinlock_t alloc_lock; /* protect quotas */
 	union {
 		int res_reserved;
 		int res_port_rsvd[MLX4_MAX_PORTS];
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index cc5d6d0..b1603e2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -284,6 +284,85 @@ static const char *ResourceType(enum mlx4_resource rt)
 }
 
 static void rem_slave_vlans(struct mlx4_dev *dev, int slave);
+static inline int mlx4_grant_resource(struct mlx4_dev *dev, int slave,
+				      enum mlx4_resource res_type, int count,
+				      int port)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct resource_allocator *res_alloc =
+		&priv->mfunc.master.res_tracker.res_alloc[res_type];
+	int err = -EINVAL;
+	int allocated, free, reserved, guaranteed, from_free;
+
+	if (slave > dev->num_vfs)
+		return -EINVAL;
+
+	spin_lock(&res_alloc->alloc_lock);
+	allocated = (port > 0) ?
+		res_alloc->allocated[(port - 1) * (dev->num_vfs + 1) + slave] :
+		res_alloc->allocated[slave];
+	free = (port > 0) ? res_alloc->res_port_free[port - 1] :
+		res_alloc->res_free;
+	reserved = (port > 0) ? res_alloc->res_port_rsvd[port - 1] :
+		res_alloc->res_reserved;
+	guaranteed = res_alloc->guaranteed[slave];
+
+	if (allocated + count > res_alloc->quota[slave])
+		goto out;
+
+	if (allocated + count <= guaranteed) {
+		err = 0;
+	} else {
+		/* portion may need to be obtained from free area */
+		if (guaranteed - allocated > 0)
+			from_free = count - (guaranteed - allocated);
+		else
+			from_free = count;
+
+		if (free - from_free > reserved)
+			err = 0;
+	}
+
+	if (!err) {
+		/* grant the request */
+		if (port > 0) {
+			res_alloc->allocated[(port - 1) * (dev->num_vfs + 1) + slave] += count;
+			res_alloc->res_port_free[port - 1] -= count;
+		} else {
+			res_alloc->allocated[slave] += count;
+			res_alloc->res_free -= count;
+		}
+	}
+
+out:
+	spin_unlock(&res_alloc->alloc_lock);
+	return err;
+}
+
+static inline void mlx4_release_resource(struct mlx4_dev *dev, int slave,
+				    enum mlx4_resource res_type, int count,
+				    int port)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct resource_allocator *res_alloc =
+		&priv->mfunc.master.res_tracker.res_alloc[res_type];
+
+	if (slave > dev->num_vfs)
+		return;
+
+	spin_lock(&res_alloc->alloc_lock);
+	if (port > 0) {
+		res_alloc->allocated[(port - 1) * (dev->num_vfs + 1) + slave] -= count;
+		res_alloc->res_port_free[port - 1] += count;
+	} else {
+		res_alloc->allocated[slave] -= count;
+		res_alloc->res_free += count;
+	}
+
+	spin_unlock(&res_alloc->alloc_lock);
+	return;
+}
+
 static inline void initialize_res_quotas(struct mlx4_dev *dev,
 					 struct resource_allocator *res_alloc,
 					 enum mlx4_resource res_type,
@@ -373,6 +452,7 @@ int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 		    !res_alloc->allocated)
 			goto no_mem_err;
 
+		spin_lock_init(&res_alloc->alloc_lock);
 		for (t = 0; t < dev->num_vfs + 1; t++) {
 			switch (i) {
 			case RES_QP:
@@ -1399,12 +1479,19 @@ static int qp_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 	case RES_OP_RESERVE:
 		count = get_param_l(&in_param);
 		align = get_param_h(&in_param);
-		err = __mlx4_qp_reserve_range(dev, count, align, &base);
+		err = mlx4_grant_resource(dev, slave, RES_QP, count, 0);
 		if (err)
 			return err;
 
+		err = __mlx4_qp_reserve_range(dev, count, align, &base);
+		if (err) {
+			mlx4_release_resource(dev, slave, RES_QP, count, 0);
+			return err;
+		}
+
 		err = add_res_range(dev, slave, base, count, RES_QP, 0);
 		if (err) {
+			mlx4_release_resource(dev, slave, RES_QP, count, 0);
 			__mlx4_qp_release_range(dev, base, count);
 			return err;
 		}
@@ -1452,15 +1539,24 @@ static int mtt_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		return err;
 
 	order = get_param_l(&in_param);
+
+	err = mlx4_grant_resource(dev, slave, RES_MTT, 1 << order, 0);
+	if (err)
+		return err;
+
 	base = __mlx4_alloc_mtt_range(dev, order);
-	if (base == -1)
+	if (base == -1) {
+		mlx4_release_resource(dev, slave, RES_MTT, 1 << order, 0);
 		return -ENOMEM;
+	}
 
 	err = add_res_range(dev, slave, base, 1, RES_MTT, order);
-	if (err)
+	if (err) {
+		mlx4_release_resource(dev, slave, RES_MTT, 1 << order, 0);
 		__mlx4_free_mtt_range(dev, base, order);
-	else
+	} else {
 		set_param_l(out_param, base);
+	}
 
 	return err;
 }
@@ -1475,13 +1571,20 @@ static int mpt_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 
 	switch (op) {
 	case RES_OP_RESERVE:
+		err = mlx4_grant_resource(dev, slave, RES_MPT, 1, 0);
+		if (err)
+			break;
+
 		index = __mlx4_mpt_reserve(dev);
-		if (index == -1)
+		if (index == -1) {
+			mlx4_release_resource(dev, slave, RES_MPT, 1, 0);
 			break;
+		}
 		id = index & mpt_mask(dev);
 
 		err = add_res_range(dev, slave, id, 1, RES_MPT, index);
 		if (err) {
+			mlx4_release_resource(dev, slave, RES_MPT, 1, 0);
 			__mlx4_mpt_release(dev, index);
 			break;
 		}
@@ -1515,12 +1618,19 @@ static int cq_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 
 	switch (op) {
 	case RES_OP_RESERVE_AND_MAP:
-		err = __mlx4_cq_alloc_icm(dev, &cqn);
+		err = mlx4_grant_resource(dev, slave, RES_CQ, 1, 0);
 		if (err)
 			break;
 
+		err = __mlx4_cq_alloc_icm(dev, &cqn);
+		if (err) {
+			mlx4_release_resource(dev, slave, RES_CQ, 1, 0);
+			break;
+		}
+
 		err = add_res_range(dev, slave, cqn, 1, RES_CQ, 0);
 		if (err) {
+			mlx4_release_resource(dev, slave, RES_CQ, 1, 0);
 			__mlx4_cq_free_icm(dev, cqn);
 			break;
 		}
@@ -1543,12 +1653,19 @@ static int srq_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 
 	switch (op) {
 	case RES_OP_RESERVE_AND_MAP:
-		err = __mlx4_srq_alloc_icm(dev, &srqn);
+		err = mlx4_grant_resource(dev, slave, RES_SRQ, 1, 0);
 		if (err)
 			break;
 
+		err = __mlx4_srq_alloc_icm(dev, &srqn);
+		if (err) {
+			mlx4_release_resource(dev, slave, RES_SRQ, 1, 0);
+			break;
+		}
+
 		err = add_res_range(dev, slave, srqn, 1, RES_SRQ, 0);
 		if (err) {
+			mlx4_release_resource(dev, slave, RES_SRQ, 1, 0);
 			__mlx4_srq_free_icm(dev, srqn);
 			break;
 		}
@@ -1569,9 +1686,13 @@ static int mac_add_to_slave(struct mlx4_dev *dev, int slave, u64 mac, int port)
 	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
 	struct mac_res *res;
 
+	if (mlx4_grant_resource(dev, slave, RES_MAC, 1, port))
+		return -EINVAL;
 	res = kzalloc(sizeof *res, GFP_KERNEL);
-	if (!res)
+	if (!res) {
+		mlx4_release_resource(dev, slave, RES_MAC, 1, port);
 		return -ENOMEM;
+	}
 	res->mac = mac;
 	res->port = (u8) port;
 	list_add_tail(&res->list,
@@ -1591,6 +1712,7 @@ static void mac_del_from_slave(struct mlx4_dev *dev, int slave, u64 mac,
 	list_for_each_entry_safe(res, tmp, mac_list, list) {
 		if (res->mac == mac && res->port == (u8) port) {
 			list_del(&res->list);
+			mlx4_release_resource(dev, slave, RES_MAC, 1, port);
 			kfree(res);
 			break;
 		}
@@ -1608,6 +1730,7 @@ static void rem_slave_macs(struct mlx4_dev *dev, int slave)
 	list_for_each_entry_safe(res, tmp, mac_list, list) {
 		list_del(&res->list);
 		__mlx4_unregister_mac(dev, res->port, res->mac);
+		mlx4_release_resource(dev, slave, RES_MAC, 1, res->port);
 		kfree(res);
 	}
 }
@@ -1656,9 +1779,13 @@ static int vlan_add_to_slave(struct mlx4_dev *dev, int slave, u16 vlan,
 		}
 	}
 
+	if (mlx4_grant_resource(dev, slave, RES_VLAN, 1, port))
+		return -EINVAL;
 	res = kzalloc(sizeof(*res), GFP_KERNEL);
-	if (!res)
+	if (!res) {
+		mlx4_release_resource(dev, slave, RES_VLAN, 1, port);
 		return -ENOMEM;
+	}
 	res->vlan = vlan;
 	res->port = (u8) port;
 	res->vlan_index = vlan_index;
@@ -1682,6 +1809,8 @@ static void vlan_del_from_slave(struct mlx4_dev *dev, int slave, u16 vlan,
 		if (res->vlan == vlan && res->port == (u8) port) {
 			if (!--res->ref_count) {
 				list_del(&res->list);
+				mlx4_release_resource(dev, slave, RES_VLAN,
+						      1, port);
 				kfree(res);
 			}
 			break;
@@ -1703,6 +1832,7 @@ static void rem_slave_vlans(struct mlx4_dev *dev, int slave)
 		/* dereference the vlan the num times the slave referenced it */
 		for (i = 0; i < res->ref_count; i++)
 			__mlx4_unregister_vlan(dev, res->port, res->vlan);
+		mlx4_release_resource(dev, slave, RES_VLAN, 1, res->port);
 		kfree(res);
 	}
 }
@@ -1749,15 +1879,23 @@ static int counter_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 	if (op != RES_OP_RESERVE)
 		return -EINVAL;
 
-	err = __mlx4_counter_alloc(dev, &index);
+	err = mlx4_grant_resource(dev, slave, RES_COUNTER, 1, 0);
 	if (err)
 		return err;
 
+	err = __mlx4_counter_alloc(dev, &index);
+	if (err) {
+		mlx4_release_resource(dev, slave, RES_COUNTER, 1, 0);
+		return err;
+	}
+
 	err = add_res_range(dev, slave, index, 1, RES_COUNTER, 0);
-	if (err)
+	if (err) {
 		__mlx4_counter_free(dev, index);
-	else
+		mlx4_release_resource(dev, slave, RES_COUNTER, 1, 0);
+	} else {
 		set_param_l(out_param, index);
+	}
 
 	return err;
 }
@@ -1864,6 +2002,7 @@ static int qp_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		err = rem_res_range(dev, slave, base, count, RES_QP, 0);
 		if (err)
 			break;
+		mlx4_release_resource(dev, slave, RES_QP, count, 0);
 		__mlx4_qp_release_range(dev, base, count);
 		break;
 	case RES_OP_MAP_ICM:
@@ -1901,8 +2040,10 @@ static int mtt_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 	base = get_param_l(&in_param);
 	order = get_param_h(&in_param);
 	err = rem_res_range(dev, slave, base, 1, RES_MTT, order);
-	if (!err)
+	if (!err) {
+		mlx4_release_resource(dev, slave, RES_MTT, 1 << order, 0);
 		__mlx4_free_mtt_range(dev, base, order);
+	}
 	return err;
 }
 
@@ -1927,6 +2068,7 @@ static int mpt_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		err = rem_res_range(dev, slave, id, 1, RES_MPT, 0);
 		if (err)
 			break;
+		mlx4_release_resource(dev, slave, RES_MPT, 1, 0);
 		__mlx4_mpt_release(dev, index);
 		break;
 	case RES_OP_MAP_ICM:
@@ -1961,6 +2103,7 @@ static int cq_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		if (err)
 			break;
 
+		mlx4_release_resource(dev, slave, RES_CQ, 1, 0);
 		__mlx4_cq_free_icm(dev, cqn);
 		break;
 
@@ -1985,6 +2128,7 @@ static int srq_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		if (err)
 			break;
 
+		mlx4_release_resource(dev, slave, RES_SRQ, 1, 0);
 		__mlx4_srq_free_icm(dev, srqn);
 		break;
 
@@ -2056,6 +2200,7 @@ static int counter_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		return err;
 
 	__mlx4_counter_free(dev, index);
+	mlx4_release_resource(dev, slave, RES_COUNTER, 1, 0);
 
 	return err;
 }
@@ -3785,6 +3930,11 @@ static void rem_slave_qps(struct mlx4_dev *dev, int slave)
 						 &tracker->res_tree[RES_QP]);
 					list_del(&qp->com.list);
 					spin_unlock_irq(mlx4_tlock(dev));
+					if (!valid_reserved(dev, slave, qpn)) {
+						__mlx4_qp_release_range(dev, qpn, 1);
+						mlx4_release_resource(dev, slave,
+								      RES_QP, 1, 0);
+					}
 					kfree(qp);
 					state = 0;
 					break;
@@ -3856,6 +4006,8 @@ static void rem_slave_srqs(struct mlx4_dev *dev, int slave)
 						 &tracker->res_tree[RES_SRQ]);
 					list_del(&srq->com.list);
 					spin_unlock_irq(mlx4_tlock(dev));
+					mlx4_release_resource(dev, slave,
+							      RES_SRQ, 1, 0);
 					kfree(srq);
 					state = 0;
 					break;
@@ -3922,6 +4074,8 @@ static void rem_slave_cqs(struct mlx4_dev *dev, int slave)
 						 &tracker->res_tree[RES_CQ]);
 					list_del(&cq->com.list);
 					spin_unlock_irq(mlx4_tlock(dev));
+					mlx4_release_resource(dev, slave,
+							      RES_CQ, 1, 0);
 					kfree(cq);
 					state = 0;
 					break;
@@ -3985,6 +4139,8 @@ static void rem_slave_mrs(struct mlx4_dev *dev, int slave)
 						 &tracker->res_tree[RES_MPT]);
 					list_del(&mpt->com.list);
 					spin_unlock_irq(mlx4_tlock(dev));
+					mlx4_release_resource(dev, slave,
+							      RES_MPT, 1, 0);
 					kfree(mpt);
 					state = 0;
 					break;
@@ -4054,6 +4210,8 @@ static void rem_slave_mtts(struct mlx4_dev *dev, int slave)
 						 &tracker->res_tree[RES_MTT]);
 					list_del(&mtt->com.list);
 					spin_unlock_irq(mlx4_tlock(dev));
+					mlx4_release_resource(dev, slave, RES_MTT,
+							      1 << mtt->order, 0);
 					kfree(mtt);
 					state = 0;
 					break;
@@ -4212,6 +4370,7 @@ static void rem_slave_counters(struct mlx4_dev *dev, int slave)
 			list_del(&counter->com.list);
 			kfree(counter);
 			__mlx4_counter_free(dev, index);
+			mlx4_release_resource(dev, slave, RES_COUNTER, 1, 0);
 		}
 	}
 	spin_unlock_irq(mlx4_tlock(dev));
-- 
1.7.1
