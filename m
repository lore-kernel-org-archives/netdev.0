From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 10/10] IB/mlx4: Load balance ports in port aggregation mode
Date: Tue,  3 Feb 2015 16:48:39 +0200
Message-ID: <1422974919-28084-12-git-send-email-ogerlitz@mellanox.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60148 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965506AbbBCOua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 09:50:30 -0500
In-Reply-To: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

When the mlx4 IB (RoCE) device works in link aggregation mode, it
exposes a single port to upper layers. Therefore, applications always
set '1' in port_num attribute when modifying a QP or creating an address handle.

To make sure that a node uses all available ports the mlx4 driver will
override the port_num attribute with a round robin policy.

Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/ah.c      |    1 +
 drivers/infiniband/hw/mlx4/main.c    |    1 +
 drivers/infiniband/hw/mlx4/mlx4_ib.h |    8 ++++++++
 drivers/infiniband/hw/mlx4/qp.c      |   19 +++++++++++++++++++
 4 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/ah.c b/drivers/infiniband/hw/mlx4/ah.c
index 2d8c339..f50a546 100644
--- a/drivers/infiniband/hw/mlx4/ah.c
+++ b/drivers/infiniband/hw/mlx4/ah.c
@@ -36,6 +36,7 @@
 #include <linux/slab.h>
 #include <linux/inet.h>
 #include <linux/string.h>
+#include <linux/mlx4/driver.h>
 
 #include "mlx4_ib.h"
 
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index ca52238..2ed5b99 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2153,6 +2153,7 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 	MLX4_INIT_DOORBELL_LOCK(&ibdev->uar_lock);
 
 	ibdev->dev = dev;
+	ibdev->bond_next_port	= 0;
 
 	strlcpy(ibdev->ib_dev.name, "mlx4_%d", IB_DEVICE_NAME_MAX);
 	ibdev->ib_dev.owner		= THIS_MODULE;
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 2b49f9d..721540c 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -534,6 +534,7 @@ struct mlx4_ib_dev {
 	struct mlx4_ib_qp      *qp1_proxy[MLX4_MAX_PORTS];
 	/* lock when destroying qp1_proxy and getting netdev events */
 	struct mutex		qp1_proxy_lock[MLX4_MAX_PORTS];
+	u8			bond_next_port;
 };
 
 struct ib_event_work {
@@ -629,6 +630,13 @@ static inline struct mlx4_ib_ah *to_mah(struct ib_ah *ibah)
 	return container_of(ibah, struct mlx4_ib_ah, ibah);
 }
 
+static inline u8 mlx4_ib_bond_next_port(struct mlx4_ib_dev *dev)
+{
+	dev->bond_next_port = (dev->bond_next_port + 1) % dev->num_ports;
+
+	return dev->bond_next_port + 1;
+}
+
 int mlx4_ib_init_sriov(struct mlx4_ib_dev *dev);
 void mlx4_ib_close_sriov(struct mlx4_ib_dev *dev);
 
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 2f85fc7..792f9dc 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -1905,6 +1905,22 @@ int mlx4_ib_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
 		goto out;
 	}
 
+	if (mlx4_is_bonded(dev->dev) && (attr_mask & IB_QP_PORT)) {
+		if ((cur_state == IB_QPS_RESET) && (new_state == IB_QPS_INIT)) {
+			if ((ibqp->qp_type == IB_QPT_RC) ||
+			    (ibqp->qp_type == IB_QPT_UD) ||
+			    (ibqp->qp_type == IB_QPT_UC) ||
+			    (ibqp->qp_type == IB_QPT_RAW_PACKET) ||
+			    (ibqp->qp_type == IB_QPT_XRC_INI)) {
+				attr->port_num = mlx4_ib_bond_next_port(dev);
+			}
+		} else {
+			/* no sense in changing port_num
+			 * when ports are bonded */
+			attr_mask &= ~IB_QP_PORT;
+		}
+	}
+
 	if ((attr_mask & IB_QP_PORT) &&
 	    (attr->port_num == 0 || attr->port_num > dev->num_ports)) {
 		pr_debug("qpn 0x%x: invalid port number (%d) specified "
@@ -1955,6 +1971,9 @@ int mlx4_ib_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
 
 	err = __mlx4_ib_modify_qp(ibqp, attr, attr_mask, cur_state, new_state);
 
+	if (mlx4_is_bonded(dev->dev) && (attr_mask & IB_QP_PORT))
+		attr->port_num = 1;
+
 out:
 	mutex_unlock(&qp->mutex);
 	return err;
-- 
1.7.1
