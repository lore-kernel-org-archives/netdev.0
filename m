From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 25/25] mlx5_ib: skeleton for mlx5_ib to support ipoib_ops
Date: Mon, 13 Mar 2017 20:31:36 +0200
Message-ID: <1489429896-10781-26-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49876 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753253AbdCMScM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:12 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/infiniband/hw/mlx5/Makefile         |   2 +-
 drivers/infiniband/hw/mlx5/main.c           |  10 +
 drivers/infiniband/hw/mlx5/mlx5_ipoib_ops.c | 289 ++++++++++++++++++++++++++++
 3 files changed, 300 insertions(+), 1 deletion(-)
 create mode 100644 drivers/infiniband/hw/mlx5/mlx5_ipoib_ops.c

diff --git a/drivers/infiniband/hw/mlx5/Makefile b/drivers/infiniband/hw/mlx5/Makefile
index 90ad2adc752f..0c4caa339565 100644
--- a/drivers/infiniband/hw/mlx5/Makefile
+++ b/drivers/infiniband/hw/mlx5/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_MLX5_INFINIBAND)	+= mlx5_ib.o
 
-mlx5_ib-y :=	main.o cq.o doorbell.o qp.o mem.o srq.o mr.o ah.o mad.o gsi.o ib_virt.o cmd.o
+mlx5_ib-y :=	main.o cq.o doorbell.o qp.o mem.o srq.o mr.o ah.o mad.o gsi.o ib_virt.o cmd.o mlx5_ipoib_ops.o
 mlx5_ib-$(CONFIG_INFINIBAND_ON_DEMAND_PAGING) += odp.o
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 4a043cf35b9a..c9bcaf2cc0c6 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -72,6 +72,14 @@ enum {
 	MLX5_ATOMIC_SIZE_QP_8BYTES = 1 << 3,
 };
 
+struct net_device *mlx5_alloc_rdma_netdev(struct ib_device *hca,
+				     u8 port_num,
+				     enum rdma_netdev_t type,
+				     const char *name,
+				     unsigned char name_assign_type,
+				     void (*setup)(struct net_device *));
+void mlx5_free_rdma_netdev(struct net_device *netdev);
+
 static enum rdma_link_layer
 mlx5_port_type_cap_to_rdma_ll(int port_type_cap)
 {
@@ -3436,6 +3444,8 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	dev->ib_dev.alloc_mr		= mlx5_ib_alloc_mr;
 	dev->ib_dev.map_mr_sg		= mlx5_ib_map_mr_sg;
 	dev->ib_dev.check_mr_status	= mlx5_ib_check_mr_status;
+	dev->ib_dev.alloc_rdma_netdev	= mlx5_alloc_rdma_netdev;
+	dev->ib_dev.free_rdma_netdev	= mlx5_free_rdma_netdev;
 	dev->ib_dev.get_port_immutable  = mlx5_port_immutable;
 	dev->ib_dev.get_dev_fw_str      = get_dev_fw_str;
 	if (mlx5_core_is_pf(mdev)) {
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ipoib_ops.c b/drivers/infiniband/hw/mlx5/mlx5_ipoib_ops.c
new file mode 100644
index 000000000000..9ca2fc4fbc15
--- /dev/null
+++ b/drivers/infiniband/hw/mlx5/mlx5_ipoib_ops.c
@@ -0,0 +1,289 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include <linux/netdevice.h>
+#include <rdma/ib_ipoib_accel_ops.h>
+#include "mlx5_ib.h"
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/fs.h>
+
+/*FIX ME*/
+#include "../../ulp/ipoib/ipoib.h"
+
+#define IB_DEFAULT_Q_KEY   0xb1b
+
+int mlx5_ib_config_ipoib_qp(struct mlx5_ib_dev *ib_dev, struct mlx5_core_qp *qp)
+{
+	u32 *in;
+	struct mlx5_qp_context *context;
+	int inlen;
+	void *addr_path;
+	void *qpc;
+	int ret;
+
+	inlen = MLX5_ST_SZ_BYTES(create_qp_in);
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	qpc = MLX5_ADDR_OF(create_qp_in, in, qpc);
+	MLX5_SET(qpc, qpc, st, MLX5_QP_ST_UD);
+	MLX5_SET(qpc, qpc, pm_state, MLX5_QP_PM_MIGRATED);
+	MLX5_SET(qpc, qpc, ulp_stateless_offload_mode,
+		 MLX5_QP_ENHANCED_ULP_STATELESS_MODE);
+
+	addr_path = MLX5_ADDR_OF(qpc, qpc, primary_address_path);
+	MLX5_SET(ads, addr_path, port, 1);
+	MLX5_SET(ads, addr_path, grh, 1);
+
+	ret = mlx5_core_create_qp(ib_dev->mdev, qp, in, inlen);
+	if (ret) {
+		pr_err("Failed creating IPoIB QP err : %d\n", ret);
+		goto clean_inbox;
+	}
+
+	/* QP states */
+	context = kzalloc(sizeof(*context), GFP_KERNEL);
+	if (!context)
+		goto clean_inbox;
+
+	context->flags = cpu_to_be32(MLX5_QP_PM_MIGRATED << 11);
+	context->pri_path.port = 1;
+	context->qkey = cpu_to_be32(IB_DEFAULT_Q_KEY);
+
+	ret = mlx5_core_qp_modify(ib_dev->mdev,
+				  MLX5_CMD_OP_RST2INIT_QP, 0, context, qp);
+	if (ret) {
+		pr_warn("Failed to modify qp RST2INIT, err: %d\n", ret);
+		goto clean_in_modify;
+	}
+	memset(context, 0, sizeof(*context));
+
+	ret = mlx5_core_qp_modify(ib_dev->mdev,
+				  MLX5_CMD_OP_INIT2RTR_QP, 0, context,
+				  qp);
+	if (ret) {
+		pr_warn("Failed to modify qp INIT2RTR, err: %d\n", ret);
+		goto clean_in_modify;
+	}
+
+	ret = mlx5_core_qp_modify(ib_dev->mdev,
+				  MLX5_CMD_OP_RTR2RTS_QP, 0, context,
+				  qp);
+	if (ret) {
+		pr_warn("Failed to modify qp RTR2RTS, err: %d\n", ret);
+		goto clean_in_modify;
+	}
+
+	kvfree(in);
+	kfree(context);
+
+	return 0;
+
+clean_in_modify:
+	kvfree(in);
+clean_inbox:
+	kvfree(in);
+	return ret;
+}
+
+static void mlx5_ib_clean_qp(struct mlx5_ib_dev *ib_dev,
+			     struct mlx5_core_qp *qp)
+{
+	mlx5_core_destroy_qp(ib_dev->mdev, qp);
+	kfree(qp);
+}
+
+int mlx5_ib_dev_init(struct net_device *dev, struct ib_device *hca,
+		     int *qp_num)
+{
+	void *next_priv = ipoib_dev_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
+	struct mlx5_ib_dev *ib_dev = to_mdev(hca);
+	int ret;
+
+	ret = mlx5i_attach(ib_dev->mdev, next_priv);
+	if (ret) {
+		pr_err("Failed resources allocation for device: %s ret: %d\n",
+		       dev->name, ret);
+		return ret;
+	}
+
+	*qp_num = rn->qp_num;
+
+	pr_debug("resources allocated for device: %s\n", dev->name);
+
+	return 0;
+}
+
+void mlx5_ib_dev_cleanup(struct net_device *dev, struct ib_device *hca)
+{
+	void *next_priv = ipoib_dev_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
+	struct mlx5_ib_dev *ib_dev = to_mdev(hca);
+	struct mlx5_qp_context context;
+	int ret;
+
+	/* detach qp from flow-steering by reset it */
+	ret = mlx5_core_qp_modify(ib_dev->mdev,
+				  MLX5_CMD_OP_2RST_QP, 0, &context,
+				  (struct mlx5_core_qp *)rn->context);
+	if (ret)
+		pr_err("%s failed (ret: %d) to reset QP\n", __func__, ret);
+
+	mlx5i_detach(ib_dev->mdev, next_priv);
+
+	mlx5_ib_clean_qp(ib_dev, (struct mlx5_core_qp *)rn->context);
+}
+
+int mlx5_ib_dev_open(struct net_device *dev)
+{
+	void *next_priv = ipoib_dev_priv(dev);
+
+	return mlx5i_open(next_priv);
+}
+
+int mlx5_ib_dev_stop(struct net_device *dev)
+{
+	void *next_priv = ipoib_dev_priv(dev);
+
+	return mlx5i_close(next_priv);
+}
+
+void mlx5_ib_send(struct net_device *dev, struct sk_buff *skb,
+		  struct ipoib_ah *address, u32 dqpn, u32 dqkey)
+{
+	void *next_priv = ipoib_dev_priv(dev);
+
+	mlx5i_xmit(skb, next_priv, &to_mah(address->ah)->av, dqpn, dqkey);
+}
+
+int mlx5_ib_attach_mcast(struct net_device *dev, struct ib_device *hca,
+			 union ib_gid *gid, u16 lid, int set_qkey)
+{
+	struct rdma_netdev *rn = netdev_priv(dev);
+	struct mlx5_ib_dev *ib_dev = to_mdev(hca);
+	int err;
+
+	pr_debug("%s attaching QPN 0x%x, MGID %pI6\n",
+		 dev->name, rn->qp_num, gid->raw);
+
+	err = mlx5_core_attach_mcg(ib_dev->mdev, gid, rn->qp_num);
+	if (err)
+		pr_err("%s failed attaching QPN 0x%x, MGID %pI6\n",
+		       dev->name, rn->qp_num, gid->raw);
+
+	return err;
+}
+
+int mlx5_ib_dettach_mcast(struct net_device *dev, struct ib_device *hca,
+			  union ib_gid *gid, u16 lid)
+{
+	struct rdma_netdev *rn = netdev_priv(dev);
+	struct mlx5_ib_dev *ib_dev = to_mdev(hca);
+	int err;
+
+	pr_debug("%s de-attaching QPN 0x%x, MGID %pI6\n",
+		 dev->name, rn->qp_num, gid->raw);
+
+	err = mlx5_core_detach_mcg(ib_dev->mdev, gid, rn->qp_num);
+	if (err)
+		pr_err("%s failed dettaching QPN 0x%x, MGID %pI6\n",
+		       dev->name, rn->qp_num, gid->raw);
+
+	return err;
+}
+
+static const struct net_device_ops ipoib_netdev_default_pf = {
+	.ndo_open		 = mlx5_ib_dev_open,
+	.ndo_stop		 = mlx5_ib_dev_stop,
+};
+
+struct net_device *mlx5_alloc_rdma_netdev(struct ib_device *hca,
+				     u8 port_num,
+				     enum rdma_netdev_t type,
+				     const char *name,
+				     unsigned char name_assign_type,
+				     void (*setup)(struct net_device *))
+{
+	struct net_device *dev;
+	struct mlx5_ib_dev *ib_dev = to_mdev(hca);
+	struct mlx5_core_qp *qp;
+	struct mlx5i_create_ext_param param;
+	struct rdma_netdev *rn;
+	int ret;
+
+	/* new IPoIB QP */
+	qp = kzalloc(sizeof(*qp), GFP_KERNEL);
+	if (!qp) {
+		pr_warn("Failed allocate memroy for QP\n");
+		return NULL;
+	}
+
+	/* config and move qp to RTS */
+	ret = mlx5_ib_config_ipoib_qp(ib_dev, qp);
+	if (ret) {
+		pr_warn("Failed config IPoIB QP ret: %d\n", ret);
+		goto clean_qp;
+	}
+
+	param.size_base_priv = sizeof(struct ipoib_rdma_netdev);
+	param.qpn = qp->qpn;
+	dev = mlx5i_create_netdev(ib_dev->mdev, name, setup, &param);
+	if (!dev) {
+		pr_err("%s: Failed to create net device\n", __func__);
+		goto clean_qp;
+	}
+
+	pr_debug("%s qpn: %d created\n", __func__, qp->qpn);
+
+	/* set func pointers */
+	rn = netdev_priv(dev);
+	rn->qp_num = qp->qpn;
+	rn->context = qp;
+
+	dev->netdev_ops = &ipoib_netdev_default_pf;
+	rn->ib_dev_init = mlx5_ib_dev_init;
+	rn->ib_dev_cleanup = mlx5_ib_dev_cleanup;
+	rn->send = mlx5_ib_send;
+	rn->attach_mcast = mlx5_ib_attach_mcast;
+	rn->detach_mcast = mlx5_ib_dettach_mcast;
+
+	return dev;
+
+clean_qp:
+	mlx5_ib_clean_qp(ib_dev, qp);
+	return NULL;
+}
+
+void mlx5_free_rdma_netdev(struct net_device *netdev)
+{
+}
-- 
1.8.3.1
