From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] mlx4: Avoid leaking steering rules on flow creation error flow
Date: Thu, 30 Oct 2014 15:59:28 +0200
Message-ID: <1414677568-28409-3-git-send-email-ogerlitz@mellanox.com>
References: <1414677568-28409-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53771 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757996AbaJ3N7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 09:59:33 -0400
In-Reply-To: <1414677568-28409-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If mlx4_ib_create_flow() attempts to create > 1 rules with the
firmware, and one of these registrations fail, we leaked the
already created flow rules.

One example of the leak is when the registration of the VXLAN ghost
steering rule fails, we didn't unregister the original rule requested
by the user, introduced in commit d2fce8a9060d "mlx4: Set
user-space raw Ethernet QPs to properly handle VXLAN traffic".

While here, add dump of the VXLAN portion of steering rules
so it can actually be seen when flow creation fails.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c        |   10 ++++++++--
 drivers/net/ethernet/mellanox/mlx4/mcg.c |    4 ++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index bda5994..8b72cf3 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1173,18 +1173,24 @@ static struct ib_flow *mlx4_ib_create_flow(struct ib_qp *qp,
 		err = __mlx4_ib_create_flow(qp, flow_attr, domain, type[i],
 					    &mflow->reg_id[i]);
 		if (err)
-			goto err_free;
+			goto err_create_flow;
 		i++;
 	}
 
 	if (i < ARRAY_SIZE(type) && flow_attr->type == IB_FLOW_ATTR_NORMAL) {
 		err = mlx4_ib_tunnel_steer_add(qp, flow_attr, &mflow->reg_id[i]);
 		if (err)
-			goto err_free;
+			goto err_create_flow;
+		i++;
 	}
 
 	return &mflow->ibflow;
 
+err_create_flow:
+	while (i) {
+		(void)__mlx4_ib_destroy_flow(to_mdev(qp->device)->dev, mflow->reg_id[i]);
+		i--;
+	}
 err_free:
 	kfree(mflow);
 	return ERR_PTR(err);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index ca0f98c..8728431 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -955,6 +955,10 @@ static void mlx4_err_rule(struct mlx4_dev *dev, char *str,
 					cur->ib.dst_gid_msk);
 			break;
 
+		case MLX4_NET_TRANS_RULE_ID_VXLAN:
+			len += snprintf(buf + len, BUF_SIZE - len,
+					"VNID = %d ", be32_to_cpu(cur->vxlan.vni));
+			break;
 		case MLX4_NET_TRANS_RULE_ID_IPV6:
 			break;
 
-- 
1.7.1
