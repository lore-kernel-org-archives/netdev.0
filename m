From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 08/13] IB/mlx4: Add RoCE/IB dedicated counters
Date: Wed, 10 Jun 2015 17:59:33 +0300
Message-ID: <1433948378-17570-9-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38060 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933134AbbFJPBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:01:14 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

This is an infrastructure step to attach all the QPs opened from the
IB driver to a counter in order to collect VF stats from the PF using
those counters.

If the port's type is Ethernet, the counter policy demands two counters
per port (one for RoCE and one for Ethernet). The port default counter
(allocated in mlx4_core) is used for the Ethernet netdev QPs and we
allocate another counter for RoCE.

If the port's traffic is Infiniband, the counter policy demands
one counter per port, so it can use the port's default counter.

Also, Add 'allocated' flag for each counter in order to clean it at
unload.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/mad.c     |    2 +-
 drivers/infiniband/hw/mlx4/main.c    |   43 +++++++++++++++++++++++----------
 drivers/infiniband/hw/mlx4/mlx4_ib.h |    7 ++++-
 drivers/infiniband/hw/mlx4/qp.c      |    4 +-
 4 files changed, 39 insertions(+), 17 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index ad6a881..74ca13f 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -831,7 +831,7 @@ static int iboe_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_ib_dev *dev = to_mdev(ibdev);
 	int err;
-	u32 inmod = dev->counters[port_num - 1] & 0xffff;
+	u32 inmod = dev->counters[port_num - 1].index & 0xffff;
 	u8 mode;
 
 	if (in_mad->mad_hdr.mgmt_class != IB_MGMT_CLASS_PERF_MGMT)
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 024b0f7..b6bd217 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2098,6 +2098,8 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 	struct mlx4_ib_iboe *iboe;
 	int ib_num_ports = 0;
 	int num_req_counters;
+	int allocated;
+	u32 counter_index;
 
 	pr_info_once("%s", mlx4_ib_version);
 
@@ -2263,19 +2265,31 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 	num_req_counters = mlx4_is_bonded(dev) ? 1 : ibdev->num_ports;
 	for (i = 0; i < num_req_counters; ++i) {
 		mutex_init(&ibdev->qp1_proxy_lock[i]);
+		allocated = 0;
 		if (mlx4_ib_port_link_layer(&ibdev->ib_dev, i + 1) ==
 						IB_LINK_LAYER_ETHERNET) {
-			err = mlx4_counter_alloc(ibdev->dev, &ibdev->counters[i]);
+			err = mlx4_counter_alloc(ibdev->dev, &counter_index);
+			/* if failed to allocate a new counter, use default */
 			if (err)
-				ibdev->counters[i] = -1;
-		} else {
-			ibdev->counters[i] = -1;
+				counter_index =
+					mlx4_get_default_counter_index(dev,
+								       i + 1);
+			else
+				allocated = 1;
+		} else { /* IB_LINK_LAYER_INFINIBAND use the default counter */
+			counter_index = mlx4_get_default_counter_index(dev,
+								       i + 1);
 		}
+		ibdev->counters[i].index = counter_index;
+		ibdev->counters[i].allocated = allocated;
+		pr_info("counter index %d for port %d allocated %d\n",
+			counter_index, i + 1, allocated);
 	}
 	if (mlx4_is_bonded(dev))
-		for (i = 1; i < ibdev->num_ports ; ++i)
-			ibdev->counters[i] = ibdev->counters[0];
-
+		for (i = 1; i < ibdev->num_ports ; ++i) {
+			ibdev->counters[i].index = ibdev->counters[0].index;
+			ibdev->counters[i].allocated = 0;
+		}
 
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB)
 		ib_num_ports++;
@@ -2415,10 +2429,12 @@ err_steer_qp_release:
 		mlx4_qp_release_range(dev, ibdev->steer_qpn_base,
 				      ibdev->steer_qpn_count);
 err_counter:
-	for (; i; --i)
-		if (ibdev->counters[i - 1] != -1)
-			mlx4_counter_free(ibdev->dev, ibdev->counters[i - 1]);
-
+	for (i = 0; i < ibdev->num_ports; ++i) {
+		if (ibdev->counters[i].index != -1 &&
+		    ibdev->counters[i].allocated)
+			mlx4_counter_free(ibdev->dev,
+					  ibdev->counters[i].index);
+	}
 err_map:
 	iounmap(ibdev->uar_map);
 
@@ -2535,8 +2551,9 @@ static void mlx4_ib_remove(struct mlx4_dev *dev, void *ibdev_ptr)
 
 	iounmap(ibdev->uar_map);
 	for (p = 0; p < ibdev->num_ports; ++p)
-		if (ibdev->counters[p] != -1)
-			mlx4_counter_free(ibdev->dev, ibdev->counters[p]);
+		if (ibdev->counters[p].index != -1 &&
+		    ibdev->counters[p].allocated)
+			mlx4_counter_free(ibdev->dev, ibdev->counters[p].index);
 	mlx4_foreach_port(p, dev, MLX4_PORT_TYPE_IB)
 		mlx4_CLOSE_PORT(dev, p);
 
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index ef80e6c..b3912d1 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -503,6 +503,11 @@ struct mlx4_ib_iov_port {
 	struct mlx4_ib_iov_sysfs_attr mcg_dentry;
 };
 
+struct counter_index {
+	u32		index;
+	u8		allocated;
+};
+
 struct mlx4_ib_dev {
 	struct ib_device	ib_dev;
 	struct mlx4_dev	       *dev;
@@ -521,7 +526,7 @@ struct mlx4_ib_dev {
 	struct mutex		cap_mask_mutex;
 	bool			ib_active;
 	struct mlx4_ib_iboe	iboe;
-	int			counters[MLX4_MAX_PORTS];
+	struct counter_index    counters[MLX4_MAX_PORTS];
 	int		       *eq_table;
 	struct kobject	       *iov_parent;
 	struct kobject	       *ports_parent;
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index c7d916f..c5a3a5f 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -1539,9 +1539,9 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
 	}
 
 	if (cur_state == IB_QPS_INIT && new_state == IB_QPS_RTR) {
-		if (dev->counters[qp->port - 1] != -1) {
+		if (dev->counters[qp->port - 1].index != -1) {
 			context->pri_path.counter_index =
-						dev->counters[qp->port - 1];
+					dev->counters[qp->port - 1].index;
 			optpar |= MLX4_QP_OPTPAR_COUNTER_INDEX;
 		} else
 			context->pri_path.counter_index =
-- 
1.7.1
