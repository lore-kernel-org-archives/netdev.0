From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 03/13] net/mlx4_core: Add sink counter
Date: Wed, 10 Jun 2015 17:59:28 +0300
Message-ID: <1433948378-17570-4-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37814 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933140AbbFJPAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:00:31 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Reserve the last valid counter index for "sink" counter, when a
new counter cannot be allocated, the driver will use this counter.

In order to avoid allocating this counter on any other flow, fix the
indices bitmap allocation range, and reserve the sink counter index.

Add macro for the sink counter index and replace all appearences of the
index with the macro.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/qp.c                   |    3 ++-
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c         |   11 +++++++----
 include/linux/mlx4/device.h                       |    1 +
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 02fc91c..c7d916f 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -1544,7 +1544,8 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
 						dev->counters[qp->port - 1];
 			optpar |= MLX4_QP_OPTPAR_COUNTER_INDEX;
 		} else
-			context->pri_path.counter_index = 0xff;
+			context->pri_path.counter_index =
+				MLX4_SINK_COUNTER_INDEX(dev->dev);
 
 		if (qp->flags & MLX4_IB_QP_NETIF) {
 			mlx4_ib_steer_qp_reg(dev, qp, 1);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index 34f2fdf..97bcb91 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -66,7 +66,7 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 		context->pri_path.sched_queue |= user_prio << 3;
 		context->pri_path.feup = MLX4_FEUP_FORCE_ETH_UP;
 	}
-	context->pri_path.counter_index = 0xff;
+	context->pri_path.counter_index = MLX4_SINK_COUNTER_INDEX(mdev->dev);
 	context->cqn_send = cpu_to_be32(cqn);
 	context->cqn_recv = cpu_to_be32(cqn);
 	context->db_rec_addr = cpu_to_be64(priv->res.db.dma << 2);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 11f5568..9c1b8b0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -479,7 +479,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		}
 	}
 
-	dev->caps.max_counters = 1 << ilog2(dev_cap->max_counters);
+	dev->caps.max_counters = dev_cap->max_counters;
 
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW] = dev_cap->reserved_qps;
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_ETH_ADDR] =
@@ -2193,13 +2193,16 @@ err_free_icm:
 static int mlx4_init_counters_table(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	int nent;
+	int nent_pow2;
 
 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_COUNTERS))
 		return -ENOENT;
 
-	nent = dev->caps.max_counters;
-	return mlx4_bitmap_init(&priv->counters_bitmap, nent, nent - 1, 0, 0);
+	nent_pow2 = roundup_pow_of_two(dev->caps.max_counters);
+	/* reserve last counter index for sink counter */
+	return mlx4_bitmap_init(&priv->counters_bitmap, nent_pow2,
+				nent_pow2 - 1, 0,
+				nent_pow2 - dev->caps.max_counters + 1);
 }
 
 static void mlx4_cleanup_counters_table(struct mlx4_dev *dev)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index ad31e47..312c504 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -957,6 +957,7 @@ struct mlx4_mad_ifc {
 			((dev)->caps.flags & MLX4_DEV_CAP_FLAG_IBOE))
 
 #define MLX4_INVALID_SLAVE_ID	0xFF
+#define MLX4_SINK_COUNTER_INDEX(dev)	(dev->caps.max_counters - 1)
 
 void handle_port_mgmt_change_event(struct work_struct *work);
 
-- 
1.7.1
