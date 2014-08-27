From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] mlx4: Set user-space raw Ethernet QPs to properly handle VXLAN traffic
Date: Wed, 27 Aug 2014 16:44:39 +0300
Message-ID: <1409147079-18826-3-git-send-email-ogerlitz@mellanox.com>
References: <1409147079-18826-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50034 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933583AbaH0Nop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 09:44:45 -0400
In-Reply-To: <1409147079-18826-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Raw Ethernet QPs opened from user-space lack the proper setup to
recieve/handle VXLAN traffic when VXLAN offloads are enabled.

Fix that by adding a tunnel steering rule on top of the normal unicast
steering rule and set the tunnel_type field in the QP context.

Issue: 360382
Change-Id: I2198e871a581d2447156672630c026582489a5a9
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c |   30 ++++++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx4/qp.c   |    8 +++++++-
 2 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index e1e558a..af82563 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1089,6 +1089,30 @@ static int __mlx4_ib_destroy_flow(struct mlx4_dev *dev, u64 reg_id)
 	return err;
 }
 
+static int mlx4_ib_tunnel_steer_add(struct ib_qp *qp, struct ib_flow_attr *flow_attr,
+				    u64 *reg_id)
+{
+	void *ib_flow;
+	union ib_flow_spec *ib_spec;
+	struct mlx4_dev	*dev = to_mdev(qp->device)->dev;
+	int err = 0;
+
+	if (dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
+		return 0; /* do nothing */
+
+	ib_flow = flow_attr + 1;
+	ib_spec = (union ib_flow_spec *)ib_flow;
+
+	if (ib_spec->type !=  IB_FLOW_SPEC_ETH || flow_attr->num_of_specs != 1)
+		return 0; /* do nothing */
+
+	err = mlx4_tunnel_steer_add(to_mdev(qp->device)->dev, ib_spec->eth.val.dst_mac,
+				    flow_attr->port, qp->qp_num,
+				    MLX4_DOMAIN_UVERBS | (flow_attr->priority & 0xff),
+				    reg_id);
+	return err;
+}
+
 static struct ib_flow *mlx4_ib_create_flow(struct ib_qp *qp,
 				    struct ib_flow_attr *flow_attr,
 				    int domain)
@@ -1136,6 +1160,12 @@ static struct ib_flow *mlx4_ib_create_flow(struct ib_qp *qp,
 		i++;
 	}
 
+	if (i < ARRAY_SIZE(type) && flow_attr->type == IB_FLOW_ATTR_NORMAL) {
+		err = mlx4_ib_tunnel_steer_add(qp, flow_attr, &mflow->reg_id[i]);
+		if (err)
+			goto err_free;
+	}
+
 	return &mflow->ibflow;
 
 err_free:
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 6778045..efb9eff 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -1677,9 +1677,15 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
 		}
 	}
 
-	if (qp->ibqp.qp_type == IB_QPT_RAW_PACKET)
+	if (qp->ibqp.qp_type == IB_QPT_RAW_PACKET) {
 		context->pri_path.ackto = (context->pri_path.ackto & 0xf8) |
 					MLX4_IB_LINK_TYPE_ETH;
+		if (dev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
+			/* set QP to receive both tunneled & non-tunneled packets */
+			if (!(context->flags & (1 << MLX4_RSS_QPC_FLAG_OFFSET)))
+				context->srqn = cpu_to_be32(7 << 28);
+		}
+	}
 
 	if (ibqp->qp_type == IB_QPT_UD && (new_state == IB_QPS_RTR)) {
 		int is_eth = rdma_port_get_link_layer(
-- 
1.7.1
