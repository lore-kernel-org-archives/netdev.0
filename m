From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 06/13] net/mlx4_core: Add port attribute when tracking counters
Date: Wed, 10 Jun 2015 17:59:31 +0300
Message-ID: <1433948378-17570-7-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37823 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933594AbbFJPAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:00:31 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Counter will get its port attribute within the resource tracker when
the first QP attached to it is modified to RTR. If a QP is counter-less,
an attempt to create a new counter with assigned port will be made.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   90 +++++++++++++++++++-
 1 files changed, 87 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 802eb2a..73db584 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -723,6 +723,9 @@ static void update_gid(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *inbox,
 	}
 }
 
+static int handle_counter(struct mlx4_dev *dev, struct mlx4_qp_context *qpc,
+			  u8 slave, int port);
+
 static int update_vport_qp_param(struct mlx4_dev *dev,
 				 struct mlx4_cmd_mailbox *inbox,
 				 u8 slave, u32 qpn)
@@ -738,6 +741,10 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 	qp_type	= (be32_to_cpu(qpc->flags) >> 16) & 0xff;
 
+	err = handle_counter(dev, qpc, slave, port);
+	if (err)
+		goto out;
+
 	if (MLX4_VGT != vp_oper->state.default_vlan) {
 		/* the reserved QPs (special, proxy, tunnel)
 		 * do not operate over vlans
@@ -882,6 +889,83 @@ static void put_res(struct mlx4_dev *dev, int slave, u64 res_id,
 	spin_unlock_irq(mlx4_tlock(dev));
 }
 
+static int counter_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
+			     u64 in_param, u64 *out_param, int port);
+
+static int handle_existing_counter(struct mlx4_dev *dev, u8 slave, int port,
+				   int counter_index)
+{
+	struct res_common *r;
+	struct res_counter *counter;
+	int ret = 0;
+
+	if (counter_index == MLX4_SINK_COUNTER_INDEX(dev))
+		return ret;
+
+	spin_lock_irq(mlx4_tlock(dev));
+	r = find_res(dev, counter_index, RES_COUNTER);
+	if (!r || r->owner != slave)
+		ret = -EINVAL;
+	counter = container_of(r, struct res_counter, com);
+	if (!counter->port)
+		counter->port = port;
+
+	spin_unlock_irq(mlx4_tlock(dev));
+	return ret;
+}
+
+static int handle_unexisting_counter(struct mlx4_dev *dev,
+				     struct mlx4_qp_context *qpc, u8 slave,
+				     int port)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
+	struct res_common *tmp;
+	struct res_counter *counter;
+	u64 counter_idx = MLX4_SINK_COUNTER_INDEX(dev);
+	int err = 0;
+
+	spin_lock_irq(mlx4_tlock(dev));
+	list_for_each_entry(tmp,
+			    &tracker->slave_list[slave].res_list[RES_COUNTER],
+			    list) {
+		counter = container_of(tmp, struct res_counter, com);
+		if (port == counter->port) {
+			qpc->pri_path.counter_index  = counter->com.res_id;
+			spin_unlock_irq(mlx4_tlock(dev));
+			return 0;
+		}
+	}
+	spin_unlock_irq(mlx4_tlock(dev));
+
+	/* No existing counter, need to allocate a new counter */
+	err = counter_alloc_res(dev, slave, RES_OP_RESERVE, 0, 0, &counter_idx,
+				port);
+	if (err == -ENOENT) {
+		err = 0;
+	} else if (err && err != -ENOSPC) {
+		mlx4_err(dev, "%s: failed to create new counter for slave %d err %d\n",
+			 __func__, slave, err);
+	} else {
+		qpc->pri_path.counter_index = counter_idx;
+		mlx4_dbg(dev, "%s: alloc new counter for slave %d index %d\n",
+			 __func__, slave, qpc->pri_path.counter_index);
+		err = 0;
+	}
+
+	return err;
+}
+
+static int handle_counter(struct mlx4_dev *dev, struct mlx4_qp_context *qpc,
+			  u8 slave, int port)
+{
+	if (qpc->pri_path.counter_index != MLX4_SINK_COUNTER_INDEX(dev))
+		return handle_existing_counter(dev, slave, port,
+					       qpc->pri_path.counter_index);
+
+	return handle_unexisting_counter(dev, qpc, slave, port);
+}
+
 static struct res_common *alloc_qp_tr(int id)
 {
 	struct res_qp *ret;
@@ -2025,7 +2109,7 @@ static int vlan_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 }
 
 static int counter_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
-			     u64 in_param, u64 *out_param)
+			     u64 in_param, u64 *out_param, int port)
 {
 	u32 index;
 	int err;
@@ -2043,7 +2127,7 @@ static int counter_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		return err;
 	}
 
-	err = add_res_range(dev, slave, index, 1, RES_COUNTER, 0);
+	err = add_res_range(dev, slave, index, 1, RES_COUNTER, port);
 	if (err) {
 		__mlx4_counter_free(dev, index);
 		mlx4_release_resource(dev, slave, RES_COUNTER, 1, 0);
@@ -2125,7 +2209,7 @@ int mlx4_ALLOC_RES_wrapper(struct mlx4_dev *dev, int slave,
 
 	case RES_COUNTER:
 		err = counter_alloc_res(dev, slave, vhcr->op_modifier, alop,
-					vhcr->in_param, &vhcr->out_param);
+					vhcr->in_param, &vhcr->out_param, 0);
 		break;
 
 	case RES_XRCD:
-- 
1.7.1
