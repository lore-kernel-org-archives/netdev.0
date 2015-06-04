From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 11/13] IB/mlx5: Avoid using the MAD_IFC command under ISSI > 0 mode
Date: Thu,  4 Jun 2015 19:30:46 +0300
Message-ID: <1433435448-4937-12-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47650 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932280AbbFDQbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:20 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

In ISSI > 0 mode, most of the MAD_IFC command features are deprecated, and can't
be used. Therefore, when in that mode, we replace all of them with other commands
that provide the required functionality.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx5/mad.c     |  297 +++++++++++++++++++
 drivers/infiniband/hw/mlx5/main.c    |  517 ++++++++++++++++++++++------------
 drivers/infiniband/hw/mlx5/mlx5_ib.h |   16 +
 3 files changed, 657 insertions(+), 173 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mad.c b/drivers/infiniband/hw/mlx5/mad.c
index f2d9e70..a770490 100644
--- a/drivers/infiniband/hw/mlx5/mad.c
+++ b/drivers/infiniband/hw/mlx5/mad.c
@@ -137,3 +137,300 @@ out:
 	kfree(out_mad);
 	return err;
 }
+
+int mlx5_query_mad_ifc_smp_attr_node_info(struct ib_device *ibdev,
+					  struct ib_smp *out_mad)
+{
+	struct ib_smp *in_mad = NULL;
+	int err = -ENOMEM;
+
+	in_mad = kzalloc(sizeof(*in_mad), GFP_KERNEL);
+	if (!in_mad)
+		return -ENOMEM;
+
+	init_query_mad(in_mad);
+	in_mad->attr_id = IB_SMP_ATTR_NODE_INFO;
+
+	err = mlx5_MAD_IFC(to_mdev(ibdev), 1, 1, 1, NULL, NULL, in_mad,
+			   out_mad);
+
+	kfree(in_mad);
+	return err;
+}
+
+int mlx5_query_mad_ifc_system_image_guid(struct ib_device *ibdev,
+					 __be64 *sys_image_guid)
+{
+	struct ib_smp *out_mad = NULL;
+	int err = -ENOMEM;
+
+	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
+	if (!out_mad)
+		return -ENOMEM;
+
+	err = mlx5_query_mad_ifc_smp_attr_node_info(ibdev, out_mad);
+	if (err)
+		goto out;
+
+	memcpy(sys_image_guid, out_mad->data + 4, 8);
+
+out:
+	kfree(out_mad);
+
+	return err;
+}
+
+int mlx5_query_mad_ifc_max_pkeys(struct ib_device *ibdev,
+				 u16 *max_pkeys)
+{
+	struct ib_smp *out_mad = NULL;
+	int err = -ENOMEM;
+
+	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
+	if (!out_mad)
+		return -ENOMEM;
+
+	err = mlx5_query_mad_ifc_smp_attr_node_info(ibdev, out_mad);
+	if (err)
+		goto out;
+
+	*max_pkeys = be16_to_cpup((__be16 *)(out_mad->data + 28));
+
+out:
+	kfree(out_mad);
+
+	return err;
+}
+
+int mlx5_query_mad_ifc_vendor_id(struct ib_device *ibdev,
+				 u32 *vendor_id)
+{
+	struct ib_smp *out_mad = NULL;
+	int err = -ENOMEM;
+
+	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
+	if (!out_mad)
+		return -ENOMEM;
+
+	err = mlx5_query_mad_ifc_smp_attr_node_info(ibdev, out_mad);
+	if (err)
+		goto out;
+
+	*vendor_id = be32_to_cpup((__be32 *)(out_mad->data + 36)) & 0xffff;
+
+out:
+	kfree(out_mad);
+
+	return err;
+}
+
+int mlx5_query_mad_ifc_node_desc(struct mlx5_ib_dev *dev, char *node_desc)
+{
+	struct ib_smp *in_mad  = NULL;
+	struct ib_smp *out_mad = NULL;
+	int err = -ENOMEM;
+
+	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
+	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
+	if (!in_mad || !out_mad)
+		goto out;
+
+	init_query_mad(in_mad);
+	in_mad->attr_id = IB_SMP_ATTR_NODE_DESC;
+
+	err = mlx5_MAD_IFC(dev, 1, 1, 1, NULL, NULL, in_mad, out_mad);
+	if (err)
+		goto out;
+
+	memcpy(node_desc, out_mad->data, 64);
+out:
+	kfree(in_mad);
+	kfree(out_mad);
+	return err;
+}
+
+int mlx5_query_mad_ifc_node_guid(struct mlx5_ib_dev *dev, __be64 *node_guid)
+{
+	struct ib_smp *in_mad  = NULL;
+	struct ib_smp *out_mad = NULL;
+	int err = -ENOMEM;
+
+	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
+	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
+	if (!in_mad || !out_mad)
+		goto out;
+
+	init_query_mad(in_mad);
+	in_mad->attr_id = IB_SMP_ATTR_NODE_INFO;
+
+	err = mlx5_MAD_IFC(dev, 1, 1, 1, NULL, NULL, in_mad, out_mad);
+	if (err)
+		goto out;
+
+	memcpy(node_guid, out_mad->data + 12, 8);
+out:
+	kfree(in_mad);
+	kfree(out_mad);
+	return err;
+}
+
+int mlx5_query_mad_ifc_pkey(struct ib_device *ibdev, u8 port, u16 index,
+			    u16 *pkey)
+{
+	struct ib_smp *in_mad  = NULL;
+	struct ib_smp *out_mad = NULL;
+	int err = -ENOMEM;
+
+	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
+	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
+	if (!in_mad || !out_mad)
+		goto out;
+
+	init_query_mad(in_mad);
+	in_mad->attr_id  = IB_SMP_ATTR_PKEY_TABLE;
+	in_mad->attr_mod = cpu_to_be32(index / 32);
+
+	err = mlx5_MAD_IFC(to_mdev(ibdev), 1, 1, port, NULL, NULL, in_mad,
+			   out_mad);
+	if (err)
+		goto out;
+
+	*pkey = be16_to_cpu(((__be16 *)out_mad->data)[index % 32]);
+
+out:
+	kfree(in_mad);
+	kfree(out_mad);
+	return err;
+}
+
+int mlx5_query_mad_ifc_gids(struct ib_device *ibdev, u8 port, int index,
+			    union ib_gid *gid)
+{
+	struct ib_smp *in_mad  = NULL;
+	struct ib_smp *out_mad = NULL;
+	int err = -ENOMEM;
+
+	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
+	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
+	if (!in_mad || !out_mad)
+		goto out;
+
+	init_query_mad(in_mad);
+	in_mad->attr_id  = IB_SMP_ATTR_PORT_INFO;
+	in_mad->attr_mod = cpu_to_be32(port);
+
+	err = mlx5_MAD_IFC(to_mdev(ibdev), 1, 1, port, NULL, NULL, in_mad,
+			   out_mad);
+	if (err)
+		goto out;
+
+	memcpy(gid->raw, out_mad->data + 8, 8);
+
+	init_query_mad(in_mad);
+	in_mad->attr_id  = IB_SMP_ATTR_GUID_INFO;
+	in_mad->attr_mod = cpu_to_be32(index / 8);
+
+	err = mlx5_MAD_IFC(to_mdev(ibdev), 1, 1, port, NULL, NULL, in_mad,
+			   out_mad);
+	if (err)
+		goto out;
+
+	memcpy(gid->raw + 8, out_mad->data + (index % 8) * 8, 8);
+
+out:
+	kfree(in_mad);
+	kfree(out_mad);
+	return err;
+}
+
+int mlx5_query_mad_ifc_port(struct ib_device *ibdev, u8 port,
+			    struct ib_port_attr *props)
+{
+	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+	struct mlx5_core_dev *mdev = dev->mdev;
+	struct ib_smp *in_mad  = NULL;
+	struct ib_smp *out_mad = NULL;
+	int ext_active_speed;
+	int err = -ENOMEM;
+
+	if (port < 1 || port > MLX5_CAP_GEN(mdev, num_ports)) {
+		mlx5_ib_warn(dev, "invalid port number %d\n", port);
+		return -EINVAL;
+	}
+
+	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
+	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
+	if (!in_mad || !out_mad)
+		goto out;
+
+	memset(props, 0, sizeof(*props));
+
+	init_query_mad(in_mad);
+	in_mad->attr_id  = IB_SMP_ATTR_PORT_INFO;
+	in_mad->attr_mod = cpu_to_be32(port);
+
+	err = mlx5_MAD_IFC(dev, 1, 1, port, NULL, NULL, in_mad, out_mad);
+	if (err) {
+		mlx5_ib_warn(dev, "err %d\n", err);
+		goto out;
+	}
+
+	props->lid		= be16_to_cpup((__be16 *)(out_mad->data + 16));
+	props->lmc		= out_mad->data[34] & 0x7;
+	props->sm_lid		= be16_to_cpup((__be16 *)(out_mad->data + 18));
+	props->sm_sl		= out_mad->data[36] & 0xf;
+	props->state		= out_mad->data[32] & 0xf;
+	props->phys_state	= out_mad->data[33] >> 4;
+	props->port_cap_flags	= be32_to_cpup((__be32 *)(out_mad->data + 20));
+	props->gid_tbl_len	= out_mad->data[50];
+	props->max_msg_sz	= 1 << MLX5_CAP_GEN(mdev, log_max_msg);
+	props->pkey_tbl_len	= mdev->port_caps[port - 1].pkey_table_len;
+	props->bad_pkey_cntr	= be16_to_cpup((__be16 *)(out_mad->data + 46));
+	props->qkey_viol_cntr	= be16_to_cpup((__be16 *)(out_mad->data + 48));
+	props->active_width	= out_mad->data[31] & 0xf;
+	props->active_speed	= out_mad->data[35] >> 4;
+	props->max_mtu		= out_mad->data[41] & 0xf;
+	props->active_mtu	= out_mad->data[36] >> 4;
+	props->subnet_timeout	= out_mad->data[51] & 0x1f;
+	props->max_vl_num	= out_mad->data[37] >> 4;
+	props->init_type_reply	= out_mad->data[41] >> 4;
+
+	/* Check if extended speeds (EDR/FDR/...) are supported */
+	if (props->port_cap_flags & IB_PORT_EXTENDED_SPEEDS_SUP) {
+		ext_active_speed = out_mad->data[62] >> 4;
+
+		switch (ext_active_speed) {
+		case 1:
+			props->active_speed = 16; /* FDR */
+			break;
+		case 2:
+			props->active_speed = 32; /* EDR */
+			break;
+		}
+	}
+
+	/* If reported active speed is QDR, check if is FDR-10 */
+	if (props->active_speed == 4) {
+		if (mdev->port_caps[port - 1].ext_port_cap &
+		    MLX_EXT_PORT_CAP_FLAG_EXTENDED_PORT_INFO) {
+			init_query_mad(in_mad);
+			in_mad->attr_id = MLX5_ATTR_EXTENDED_PORT_INFO;
+			in_mad->attr_mod = cpu_to_be32(port);
+
+			err = mlx5_MAD_IFC(dev, 1, 1, port,
+					   NULL, NULL, in_mad, out_mad);
+			if (err)
+				goto out;
+
+			/* Checking LinkSpeedActive for FDR-10 */
+			if (out_mad->data[15] & 0x1)
+				props->active_speed = 8;
+		}
+	}
+
+out:
+	kfree(in_mad);
+	kfree(out_mad);
+
+	return err;
+}
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 9075649..a117e27 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -40,6 +40,7 @@
 #include <linux/io-mapping.h>
 #include <linux/sched.h>
 #include <rdma/ib_user_verbs.h>
+#include <linux/mlx5/vport.h>
 #include <rdma/ib_smi.h>
 #include <rdma/ib_umem.h>
 #include "user.h"
@@ -62,30 +63,168 @@ static char mlx5_version[] =
 	DRIVER_NAME ": Mellanox Connect-IB Infiniband driver v"
 	DRIVER_VERSION " (" DRIVER_RELDATE ")\n";
 
+static enum rdma_link_layer
+mlx5_ib_port_link_layer(struct ib_device *device)
+{
+	struct mlx5_ib_dev *dev = to_mdev(device);
+
+	switch (MLX5_CAP_GEN(dev->mdev, port_type)) {
+	case MLX5_CAP_PORT_TYPE_IB:
+		return IB_LINK_LAYER_INFINIBAND;
+	case MLX5_CAP_PORT_TYPE_ETH:
+		return IB_LINK_LAYER_ETHERNET;
+	default:
+		return IB_LINK_LAYER_UNSPECIFIED;
+	}
+}
+
+static int mlx5_use_mad_ifc(struct mlx5_ib_dev *dev)
+{
+	return !dev->mdev->issi;
+}
+
+enum {
+	MLX5_VPORT_ACCESS_METHOD_MAD,
+	MLX5_VPORT_ACCESS_METHOD_HCA,
+	MLX5_VPORT_ACCESS_METHOD_NIC,
+};
+
+static int mlx5_get_vport_access_method(struct ib_device *ibdev)
+{
+	if (mlx5_use_mad_ifc(to_mdev(ibdev)))
+		return MLX5_VPORT_ACCESS_METHOD_MAD;
+
+	if (mlx5_ib_port_link_layer(ibdev) ==
+	    IB_LINK_LAYER_ETHERNET)
+		return MLX5_VPORT_ACCESS_METHOD_NIC;
+
+	return MLX5_VPORT_ACCESS_METHOD_HCA;
+}
+
+static int mlx5_query_system_image_guid(struct ib_device *ibdev,
+					__be64 *sys_image_guid)
+{
+	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+	struct mlx5_core_dev *mdev = dev->mdev;
+	u64 tmp;
+	int err;
+
+	switch (mlx5_get_vport_access_method(ibdev)) {
+	case MLX5_VPORT_ACCESS_METHOD_MAD:
+		return mlx5_query_mad_ifc_system_image_guid(ibdev,
+							    sys_image_guid);
+
+	case MLX5_VPORT_ACCESS_METHOD_HCA:
+		err = mlx5_query_hca_vport_system_image_guid(mdev, &tmp);
+		if (!err)
+			*sys_image_guid = cpu_to_be64(tmp);
+		return err;
+
+	default:
+		return -EINVAL;
+	}
+}
+
+static int mlx5_query_max_pkeys(struct ib_device *ibdev,
+				u16 *max_pkeys)
+{
+	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+	struct mlx5_core_dev *mdev = dev->mdev;
+
+	switch (mlx5_get_vport_access_method(ibdev)) {
+	case MLX5_VPORT_ACCESS_METHOD_MAD:
+		return mlx5_query_mad_ifc_max_pkeys(ibdev, max_pkeys);
+
+	case MLX5_VPORT_ACCESS_METHOD_HCA:
+	case MLX5_VPORT_ACCESS_METHOD_NIC:
+		*max_pkeys = mlx5_to_sw_pkey_sz(MLX5_CAP_GEN(mdev,
+						pkey_table_size));
+		return 0;
+
+	default:
+		return -EINVAL;
+	}
+}
+
+static int mlx5_query_vendor_id(struct ib_device *ibdev,
+				u32 *vendor_id)
+{
+	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+
+	switch (mlx5_get_vport_access_method(ibdev)) {
+	case MLX5_VPORT_ACCESS_METHOD_MAD:
+		return mlx5_query_mad_ifc_vendor_id(ibdev, vendor_id);
+
+	case MLX5_VPORT_ACCESS_METHOD_HCA:
+	case MLX5_VPORT_ACCESS_METHOD_NIC:
+		return mlx5_core_query_vendor_id(dev->mdev, vendor_id);
+
+	default:
+		return -EINVAL;
+	}
+}
+
+static int mlx5_query_node_guid(struct mlx5_ib_dev *dev,
+				__be64 *node_guid)
+{
+	u64 tmp;
+	int err;
+
+	switch (mlx5_get_vport_access_method(&dev->ib_dev)) {
+	case MLX5_VPORT_ACCESS_METHOD_MAD:
+		return mlx5_query_mad_ifc_node_guid(dev, node_guid);
+
+	case MLX5_VPORT_ACCESS_METHOD_HCA:
+		err = mlx5_query_hca_vport_node_guid(dev->mdev, &tmp);
+		if (!err)
+			*node_guid = cpu_to_be64(tmp);
+		return err;
+
+	default:
+		return -EINVAL;
+	}
+}
+
+struct mlx5_reg_node_desc {
+	u8	desc[64];
+};
+
+static int mlx5_query_node_desc(struct mlx5_ib_dev *dev, char *node_desc)
+{
+	struct mlx5_reg_node_desc in;
+
+	if (mlx5_use_mad_ifc(dev))
+		return mlx5_query_mad_ifc_node_desc(dev, node_desc);
+
+	memset(&in, 0, sizeof(in));
+
+	return mlx5_core_access_reg(dev->mdev, &in, sizeof(in), node_desc,
+				    sizeof(struct mlx5_reg_node_desc),
+				    MLX5_REG_NODE_DESC, 0, 0);
+}
+
 static int mlx5_ib_query_device(struct ib_device *ibdev,
 				struct ib_device_attr *props)
 {
 	struct mlx5_ib_dev *dev = to_mdev(ibdev);
 	struct mlx5_core_dev *mdev = dev->mdev;
-	struct ib_smp *in_mad  = NULL;
-	struct ib_smp *out_mad = NULL;
 	int err = -ENOMEM;
 	int max_rq_sg;
 	int max_sq_sg;
 
-	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
-	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
-	if (!in_mad || !out_mad)
-		goto out;
-
-	init_query_mad(in_mad);
-	in_mad->attr_id = IB_SMP_ATTR_NODE_INFO;
+	memset(props, 0, sizeof(*props));
+	err = mlx5_query_system_image_guid(ibdev,
+					   &props->sys_image_guid);
+	if (err)
+		return err;
 
-	err = mlx5_MAD_IFC(to_mdev(ibdev), 1, 1, 1, NULL, NULL, in_mad, out_mad);
+	err = mlx5_query_max_pkeys(ibdev, &props->max_pkeys);
 	if (err)
-		goto out;
+		return err;
 
-	memset(props, 0, sizeof(*props));
+	err = mlx5_query_vendor_id(ibdev, &props->vendor_id);
+	if (err)
+		return err;
 
 	props->fw_ver = ((u64)fw_rev_maj(dev->mdev) << 32) |
 		(fw_rev_min(dev->mdev) << 16) |
@@ -117,11 +256,8 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 	if (MLX5_CAP_GEN(mdev, block_lb_mc))
 		props->device_cap_flags |= IB_DEVICE_BLOCK_MULTICAST_LOOPBACK;
 
-	props->vendor_id	   = be32_to_cpup((__be32 *)(out_mad->data + 36)) &
-		0xffffff;
-	props->vendor_part_id	   = be16_to_cpup((__be16 *)(out_mad->data + 30));
-	props->hw_ver		   = be32_to_cpup((__be32 *)(out_mad->data + 32));
-	memcpy(&props->sys_image_guid, out_mad->data +	4, 8);
+	props->vendor_part_id	   = mdev->pdev->device;
+	props->hw_ver		   = mdev->pdev->revision;
 
 	props->max_mr_size	   = ~0ull;
 	props->page_size_cap	   = 1ull << MLX5_CAP_GEN(mdev, log_pg_sz);
@@ -147,7 +283,6 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 	props->max_fast_reg_page_list_len = (unsigned int)-1;
 	props->atomic_cap	   = IB_ATOMIC_NONE;
 	props->masked_atomic_cap   = IB_ATOMIC_NONE;
-	props->max_pkeys	   = be16_to_cpup((__be16 *)(out_mad->data + 28));
 	props->max_mcast_grp	   = 1 << MLX5_CAP_GEN(mdev, log_max_mcg);
 	props->max_mcast_qp_attach = MLX5_CAP_GEN(mdev, max_qp_mcg);
 	props->max_total_mcast_qp_attach = props->max_mcast_qp_attach *
@@ -160,175 +295,232 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 	props->odp_caps = dev->odp_caps;
 #endif
 
-out:
-	kfree(in_mad);
-	kfree(out_mad);
-
-	return err;
+	return 0;
 }
 
-int mlx5_ib_query_port(struct ib_device *ibdev, u8 port,
-		       struct ib_port_attr *props)
+enum mlx5_ib_width {
+	MLX5_IB_WIDTH_1X	= 1 << 0,
+	MLX5_IB_WIDTH_2X	= 1 << 1,
+	MLX5_IB_WIDTH_4X	= 1 << 2,
+	MLX5_IB_WIDTH_8X	= 1 << 3,
+	MLX5_IB_WIDTH_12X	= 1 << 4
+};
+
+static int translate_active_width(struct ib_device *ibdev, u8 active_width,
+				  u8 *ib_width)
 {
 	struct mlx5_ib_dev *dev = to_mdev(ibdev);
-	struct mlx5_core_dev *mdev = dev->mdev;
-	struct ib_smp *in_mad  = NULL;
-	struct ib_smp *out_mad = NULL;
-	int ext_active_speed;
-	int err = -ENOMEM;
+	int err = 0;
+
+	if (active_width & MLX5_IB_WIDTH_1X) {
+		*ib_width = IB_WIDTH_1X;
+	} else if (active_width & MLX5_IB_WIDTH_2X) {
+		mlx5_ib_dbg(dev, "active_width %d is not supported by IB spec\n",
+			    (int)active_width);
+		err = -EINVAL;
+	} else if (active_width & MLX5_IB_WIDTH_4X) {
+		*ib_width = IB_WIDTH_4X;
+	} else if (active_width & MLX5_IB_WIDTH_8X) {
+		*ib_width = IB_WIDTH_8X;
+	} else if (active_width & MLX5_IB_WIDTH_12X) {
+		*ib_width = IB_WIDTH_12X;
+	} else {
+		mlx5_ib_dbg(dev, "Invalid active_width %d\n",
+			    (int)active_width);
+		err = -EINVAL;
+	}
 
-	if (port < 1 || port > MLX5_CAP_GEN(mdev, num_ports)) {
-		mlx5_ib_warn(dev, "invalid port number %d\n", port);
-		return -EINVAL;
+	return err;
+}
+
+static int mlx5_mtu_to_ib_mtu(int mtu)
+{
+	switch (mtu) {
+	case 256: return 1;
+	case 512: return 2;
+	case 1024: return 3;
+	case 2048: return 4;
+	case 4096: return 5;
+	default:
+		pr_warn("invalid mtu\n");
+		return -1;
 	}
+}
 
-	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
-	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
-	if (!in_mad || !out_mad)
-		goto out;
+enum ib_max_vl_num {
+	__IB_MAX_VL_0		= 1,
+	__IB_MAX_VL_0_1		= 2,
+	__IB_MAX_VL_0_3		= 3,
+	__IB_MAX_VL_0_7		= 4,
+	__IB_MAX_VL_0_14	= 5,
+};
 
-	memset(props, 0, sizeof(*props));
+enum mlx5_vl_hw_cap {
+	MLX5_VL_HW_0	= 1,
+	MLX5_VL_HW_0_1	= 2,
+	MLX5_VL_HW_0_2	= 3,
+	MLX5_VL_HW_0_3	= 4,
+	MLX5_VL_HW_0_4	= 5,
+	MLX5_VL_HW_0_5	= 6,
+	MLX5_VL_HW_0_6	= 7,
+	MLX5_VL_HW_0_7	= 8,
+	MLX5_VL_HW_0_14	= 15
+};
 
-	init_query_mad(in_mad);
-	in_mad->attr_id  = IB_SMP_ATTR_PORT_INFO;
-	in_mad->attr_mod = cpu_to_be32(port);
+static int translate_max_vl_num(struct ib_device *ibdev, u8 vl_hw_cap,
+				u8 *max_vl_num)
+{
+	switch (vl_hw_cap) {
+	case MLX5_VL_HW_0:
+		*max_vl_num = __IB_MAX_VL_0;
+		break;
+	case MLX5_VL_HW_0_1:
+		*max_vl_num = __IB_MAX_VL_0_1;
+		break;
+	case MLX5_VL_HW_0_3:
+		*max_vl_num = __IB_MAX_VL_0_3;
+		break;
+	case MLX5_VL_HW_0_7:
+		*max_vl_num = __IB_MAX_VL_0_7;
+		break;
+	case MLX5_VL_HW_0_14:
+		*max_vl_num = __IB_MAX_VL_0_14;
+		break;
 
-	err = mlx5_MAD_IFC(dev, 1, 1, port, NULL, NULL, in_mad, out_mad);
-	if (err) {
-		mlx5_ib_warn(dev, "err %d\n", err);
-		goto out;
+	default:
+		return -EINVAL;
 	}
 
+	return 0;
+}
 
-	props->lid		= be16_to_cpup((__be16 *)(out_mad->data + 16));
-	props->lmc		= out_mad->data[34] & 0x7;
-	props->sm_lid		= be16_to_cpup((__be16 *)(out_mad->data + 18));
-	props->sm_sl		= out_mad->data[36] & 0xf;
-	props->state		= out_mad->data[32] & 0xf;
-	props->phys_state	= out_mad->data[33] >> 4;
-	props->port_cap_flags	= be32_to_cpup((__be32 *)(out_mad->data + 20));
-	props->gid_tbl_len	= out_mad->data[50];
-	props->max_msg_sz	= 1 << MLX5_CAP_GEN(mdev, log_max_msg);
-	props->pkey_tbl_len	= mdev->port_caps[port - 1].pkey_table_len;
-	props->bad_pkey_cntr	= be16_to_cpup((__be16 *)(out_mad->data + 46));
-	props->qkey_viol_cntr	= be16_to_cpup((__be16 *)(out_mad->data + 48));
-	props->active_width	= out_mad->data[31] & 0xf;
-	props->active_speed	= out_mad->data[35] >> 4;
-	props->max_mtu		= out_mad->data[41] & 0xf;
-	props->active_mtu	= out_mad->data[36] >> 4;
-	props->subnet_timeout	= out_mad->data[51] & 0x1f;
-	props->max_vl_num	= out_mad->data[37] >> 4;
-	props->init_type_reply	= out_mad->data[41] >> 4;
-
-	/* Check if extended speeds (EDR/FDR/...) are supported */
-	if (props->port_cap_flags & IB_PORT_EXTENDED_SPEEDS_SUP) {
-		ext_active_speed = out_mad->data[62] >> 4;
-
-		switch (ext_active_speed) {
-		case 1:
-			props->active_speed = 16; /* FDR */
-			break;
-		case 2:
-			props->active_speed = 32; /* EDR */
-			break;
-		}
-	}
+static int mlx5_query_hca_port(struct ib_device *ibdev, u8 port,
+			       struct ib_port_attr *props)
+{
+	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+	struct mlx5_core_dev *mdev = dev->mdev;
+	struct mlx5_hca_vport_context *rep;
+	int max_mtu;
+	int oper_mtu;
+	int err;
+	u8 ib_link_width_oper;
+	u8 vl_hw_cap;
 
-	/* If reported active speed is QDR, check if is FDR-10 */
-	if (props->active_speed == 4) {
-		if (mdev->port_caps[port - 1].ext_port_cap &
-		    MLX_EXT_PORT_CAP_FLAG_EXTENDED_PORT_INFO) {
-			init_query_mad(in_mad);
-			in_mad->attr_id = MLX5_ATTR_EXTENDED_PORT_INFO;
-			in_mad->attr_mod = cpu_to_be32(port);
-
-			err = mlx5_MAD_IFC(dev, 1, 1, port,
-					   NULL, NULL, in_mad, out_mad);
-			if (err)
-				goto out;
-
-			/* Checking LinkSpeedActive for FDR-10 */
-			if (out_mad->data[15] & 0x1)
-				props->active_speed = 8;
-		}
+	rep = kzalloc(sizeof(*rep), GFP_KERNEL);
+	if (!rep) {
+		err = -ENOMEM;
+		goto out;
 	}
 
-out:
-	kfree(in_mad);
-	kfree(out_mad);
+	memset(props, 0, sizeof(*props));
 
-	return err;
-}
+	err = mlx5_query_hca_vport_context(mdev, 0, port, 0, rep);
+	if (err)
+		goto out;
 
-static int mlx5_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
-			     union ib_gid *gid)
-{
-	struct ib_smp *in_mad  = NULL;
-	struct ib_smp *out_mad = NULL;
-	int err = -ENOMEM;
+	props->lid		= rep->lid;
+	props->lmc		= rep->lmc;
+	props->sm_lid		= rep->sm_lid;
+	props->sm_sl		= rep->sm_sl;
+	props->state		= rep->vport_state;
+	props->phys_state	= rep->port_physical_state;
+	props->port_cap_flags	= rep->cap_mask1;
+	props->gid_tbl_len	= mlx5_get_gid_table_len(MLX5_CAP_GEN(mdev, gid_table_size));
+	props->max_msg_sz	= 1 << MLX5_CAP_GEN(mdev, log_max_msg);
+	props->pkey_tbl_len	= mlx5_to_sw_pkey_sz(MLX5_CAP_GEN(mdev, pkey_table_size));
+	props->bad_pkey_cntr	= rep->pkey_violation_counter;
+	props->qkey_viol_cntr	= rep->qkey_violation_counter;
+	props->subnet_timeout	= rep->subnet_timeout;
+	props->init_type_reply	= rep->init_type_reply;
 
-	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
-	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
-	if (!in_mad || !out_mad)
+	err = mlx5_query_port_link_width_oper(mdev, &ib_link_width_oper, port);
+	if (err)
 		goto out;
 
-	init_query_mad(in_mad);
-	in_mad->attr_id  = IB_SMP_ATTR_PORT_INFO;
-	in_mad->attr_mod = cpu_to_be32(port);
-
-	err = mlx5_MAD_IFC(to_mdev(ibdev), 1, 1, port, NULL, NULL, in_mad, out_mad);
+	err = translate_active_width(ibdev, ib_link_width_oper,
+				     &props->active_width);
+	if (err)
+		goto out;
+	err = mlx5_query_port_proto_oper(mdev, &props->active_speed, MLX5_PTYS_IB,
+					 port);
 	if (err)
 		goto out;
 
-	memcpy(gid->raw, out_mad->data + 8, 8);
+	err = mlx5_query_port_max_mtu(mdev, &max_mtu, port);
+	if (err)
+		goto out;
 
-	init_query_mad(in_mad);
-	in_mad->attr_id  = IB_SMP_ATTR_GUID_INFO;
-	in_mad->attr_mod = cpu_to_be32(index / 8);
+	props->max_mtu = mlx5_mtu_to_ib_mtu(max_mtu);
 
-	err = mlx5_MAD_IFC(to_mdev(ibdev), 1, 1, port, NULL, NULL, in_mad, out_mad);
+	err = mlx5_query_port_oper_mtu(mdev, &oper_mtu, port);
 	if (err)
 		goto out;
 
-	memcpy(gid->raw + 8, out_mad->data + (index % 8) * 8, 8);
+	props->active_mtu = mlx5_mtu_to_ib_mtu(oper_mtu);
+
+	err = mlx5_query_port_vl_hw_cap(mdev, &vl_hw_cap, port);
+	if (err)
+		goto out;
 
+	err = translate_max_vl_num(ibdev, vl_hw_cap,
+				   &props->max_vl_num);
 out:
-	kfree(in_mad);
-	kfree(out_mad);
+	kfree(rep);
 	return err;
 }
 
-static int mlx5_ib_query_pkey(struct ib_device *ibdev, u8 port, u16 index,
-			      u16 *pkey)
+int mlx5_ib_query_port(struct ib_device *ibdev, u8 port,
+		       struct ib_port_attr *props)
 {
-	struct ib_smp *in_mad  = NULL;
-	struct ib_smp *out_mad = NULL;
-	int err = -ENOMEM;
+	switch (mlx5_get_vport_access_method(ibdev)) {
+	case MLX5_VPORT_ACCESS_METHOD_MAD:
+		return mlx5_query_mad_ifc_port(ibdev, port, props);
 
-	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
-	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
-	if (!in_mad || !out_mad)
-		goto out;
+	case MLX5_VPORT_ACCESS_METHOD_HCA:
+		return mlx5_query_hca_port(ibdev, port, props);
 
-	init_query_mad(in_mad);
-	in_mad->attr_id  = IB_SMP_ATTR_PKEY_TABLE;
-	in_mad->attr_mod = cpu_to_be32(index / 32);
+	default:
+		return -EINVAL;
+	}
+}
 
-	err = mlx5_MAD_IFC(to_mdev(ibdev), 1, 1, port, NULL, NULL, in_mad, out_mad);
-	if (err)
-		goto out;
+static int mlx5_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
+			     union ib_gid *gid)
+{
+	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+	struct mlx5_core_dev *mdev = dev->mdev;
 
-	*pkey = be16_to_cpu(((__be16 *)out_mad->data)[index % 32]);
+	switch (mlx5_get_vport_access_method(ibdev)) {
+	case MLX5_VPORT_ACCESS_METHOD_MAD:
+		return mlx5_query_mad_ifc_gids(ibdev, port, index, gid);
+
+	case MLX5_VPORT_ACCESS_METHOD_HCA:
+		return mlx5_query_hca_vport_gid(mdev, 0, port, 0, index, gid);
+
+	default:
+		return -EINVAL;
+	}
 
-out:
-	kfree(in_mad);
-	kfree(out_mad);
-	return err;
 }
 
-struct mlx5_reg_node_desc {
-	u8	desc[64];
-};
+static int mlx5_ib_query_pkey(struct ib_device *ibdev, u8 port, u16 index,
+			      u16 *pkey)
+{
+	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+	struct mlx5_core_dev *mdev = dev->mdev;
+
+	switch (mlx5_get_vport_access_method(ibdev)) {
+	case MLX5_VPORT_ACCESS_METHOD_MAD:
+		return mlx5_query_mad_ifc_pkey(ibdev, port, index, pkey);
+
+	case MLX5_VPORT_ACCESS_METHOD_HCA:
+	case MLX5_VPORT_ACCESS_METHOD_NIC:
+		return mlx5_query_hca_vport_pkey(mdev, 0, port,  0, index,
+						 pkey);
+	default:
+		return -EINVAL;
+	}
+}
 
 static int mlx5_ib_modify_device(struct ib_device *ibdev, int mask,
 				 struct ib_device_modify *props)
@@ -727,37 +919,15 @@ static int mlx5_ib_mcg_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 
 static int init_node_data(struct mlx5_ib_dev *dev)
 {
-	struct ib_smp *in_mad  = NULL;
-	struct ib_smp *out_mad = NULL;
-	int err = -ENOMEM;
-
-	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
-	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
-	if (!in_mad || !out_mad)
-		goto out;
-
-	init_query_mad(in_mad);
-	in_mad->attr_id = IB_SMP_ATTR_NODE_DESC;
-
-	err = mlx5_MAD_IFC(dev, 1, 1, 1, NULL, NULL, in_mad, out_mad);
-	if (err)
-		goto out;
-
-	memcpy(dev->ib_dev.node_desc, out_mad->data, 64);
-
-	in_mad->attr_id = IB_SMP_ATTR_NODE_INFO;
+	int err;
 
-	err = mlx5_MAD_IFC(dev, 1, 1, 1, NULL, NULL, in_mad, out_mad);
+	err = mlx5_query_node_desc(dev, dev->ib_dev.node_desc);
 	if (err)
-		goto out;
+		return err;
 
-	dev->mdev->rev_id = be32_to_cpup((__be32 *)(out_mad->data + 32));
-	memcpy(&dev->ib_dev.node_guid, out_mad->data + 12, 8);
+	dev->mdev->rev_id = dev->mdev->pdev->revision;
 
-out:
-	kfree(in_mad);
-	kfree(out_mad);
-	return err;
+	return mlx5_query_node_guid(dev, &dev->ib_dev.node_guid);
 }
 
 static ssize_t show_fw_pages(struct device *device, struct device_attribute *attr,
@@ -1195,7 +1365,8 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	if (err)
 		goto err_dealloc;
 
-	get_ext_port_caps(dev);
+	if (mlx5_use_mad_ifc(dev))
+		get_ext_port_caps(dev);
 
 	MLX5_INIT_DOORBELL_LOCK(&dev->uar_lock);
 
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 0c441ad..f731b25 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -594,6 +594,22 @@ struct ib_xrcd *mlx5_ib_alloc_xrcd(struct ib_device *ibdev,
 int mlx5_ib_dealloc_xrcd(struct ib_xrcd *xrcd);
 int mlx5_ib_get_buf_offset(u64 addr, int page_shift, u32 *offset);
 int mlx5_query_ext_port_caps(struct mlx5_ib_dev *dev, u8 port);
+int mlx5_query_mad_ifc_smp_attr_node_info(struct ib_device *ibdev,
+					  struct ib_smp *out_mad);
+int mlx5_query_mad_ifc_system_image_guid(struct ib_device *ibdev,
+					 __be64 *sys_image_guid);
+int mlx5_query_mad_ifc_max_pkeys(struct ib_device *ibdev,
+				 u16 *max_pkeys);
+int mlx5_query_mad_ifc_vendor_id(struct ib_device *ibdev,
+				 u32 *vendor_id);
+int mlx5_query_mad_ifc_node_desc(struct mlx5_ib_dev *dev, char *node_desc);
+int mlx5_query_mad_ifc_node_guid(struct mlx5_ib_dev *dev, __be64 *node_guid);
+int mlx5_query_mad_ifc_pkey(struct ib_device *ibdev, u8 port, u16 index,
+			    u16 *pkey);
+int mlx5_query_mad_ifc_gids(struct ib_device *ibdev, u8 port, int index,
+			    union ib_gid *gid);
+int mlx5_query_mad_ifc_port(struct ib_device *ibdev, u8 port,
+			    struct ib_port_attr *props);
 int mlx5_ib_query_port(struct ib_device *ibdev, u8 port,
 		       struct ib_port_attr *props);
 int mlx5_ib_init_fmr(struct mlx5_ib_dev *dev);
-- 
1.7.1
