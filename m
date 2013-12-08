From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 05/12] net/mlx4_core: Expose physical port id as PF/VF capability
Date: Sun,  8 Dec 2013 14:35:45 +0200
Message-ID: <1386506152-10298-6-git-send-email-amirv@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40348 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752672Ab3LHMgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 07:36:12 -0500
In-Reply-To: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Add the infrastructure needed to support ndo_get_phys_port_id which
allows users to identify to which physical port a net-device is connected
to by reading a unique port id.
This will work for VFs and PFs.
The driver uses a new device capability - phys_port_id, The PF driver
reads the port phys_port_id from Firmware and stores it. The VF driver
reads the port phys_port_id from the PF using QUERY_FUNC_CAP command.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   | 45 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.h   |  1 +
 drivers/net/ethernet/mellanox/mlx4/main.c |  5 ++++
 include/linux/mlx4/device.h               |  2 ++
 4 files changed, 53 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index bfe91ae..27a8434 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -214,6 +214,7 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 #define QUERY_FUNC_CAP_QP0_PROXY		0x14
 #define QUERY_FUNC_CAP_QP1_TUNNEL		0x18
 #define QUERY_FUNC_CAP_QP1_PROXY		0x1c
+#define QUERY_FUNC_CAP_PHYS_PORT_ID		0x28
 
 #define QUERY_FUNC_CAP_FLAGS1_FORCE_MAC		0x40
 #define QUERY_FUNC_CAP_FLAGS1_FORCE_VLAN	0x80
@@ -242,6 +243,9 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 		size += 2;
 		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_QP1_PROXY);
 
+		MLX4_PUT(outbox->buf, dev->caps.phys_port_id[vhcr->in_modifier],
+			 QUERY_FUNC_CAP_PHYS_PORT_ID);
+
 	} else if (vhcr->op_modifier == 0) {
 		/* enable rdma and ethernet interfaces, and new quota locations */
 		field = (QUERY_FUNC_CAP_FLAG_ETH | QUERY_FUNC_CAP_FLAG_RDMA |
@@ -432,6 +436,10 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u32 gen_or_port,
 	MLX4_GET(size, outbox, QUERY_FUNC_CAP_QP1_PROXY);
 	func_cap->qp1_proxy_qpn = size & 0xFFFFFF;
 
+	if (func_cap->flags1 & QUERY_FUNC_CAP_FLAGS1_NIC_INFO)
+		MLX4_GET(func_cap->phys_port_id, outbox,
+			 QUERY_FUNC_CAP_PHYS_PORT_ID);
+
 	/* All other resources are allocated by the master, but we still report
 	 * 'num' and 'reserved' capabilities as follows:
 	 * - num remains the maximum resource index
@@ -1712,6 +1720,43 @@ int mlx4_NOP(struct mlx4_dev *dev)
 	return mlx4_cmd(dev, 0, 0x1f, 0, MLX4_CMD_NOP, 100, MLX4_CMD_NATIVE);
 }
 
+int mlx4_get_phys_port_id(struct mlx4_dev *dev)
+{
+	u8 port;
+	u32 *outbox;
+	struct mlx4_cmd_mailbox *mailbox;
+	u32 in_mod;
+	u32 guid_hi, guid_lo;
+	int err, ret = 0;
+#define MOD_STAT_CFG_PORT_OFFSET 8
+#define MOD_STAT_CFG_GUID_H	 0X14
+#define MOD_STAT_CFG_GUID_L	 0X1c
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	outbox = mailbox->buf;
+
+	for (port = 1; port <= dev->caps.num_ports; port++) {
+		in_mod = port << MOD_STAT_CFG_PORT_OFFSET;
+		err = mlx4_cmd_box(dev, 0, mailbox->dma, in_mod, 0x2,
+				   MLX4_CMD_MOD_STAT_CFG, MLX4_CMD_TIME_CLASS_A,
+				   MLX4_CMD_NATIVE);
+		if (err) {
+			mlx4_err(dev, "Fail to get port %d uplink guid\n",
+				 port);
+			ret = err;
+		} else {
+			MLX4_GET(guid_hi, outbox, MOD_STAT_CFG_GUID_H);
+			MLX4_GET(guid_lo, outbox, MOD_STAT_CFG_GUID_L);
+			dev->caps.phys_port_id[port] = (u64)guid_lo |
+						       (u64)guid_hi << 32;
+		}
+	}
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return ret;
+}
+
 #define MLX4_WOL_SETUP_MODE (5 << 28)
 int mlx4_wol_read(struct mlx4_dev *dev, u64 *config, int port)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 9d95298..6811ee0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -141,6 +141,7 @@ struct mlx4_func_cap {
 	u8	physical_port;
 	u8	port_flags;
 	u8	flags1;
+	u64	phys_port_id;
 };
 
 struct mlx4_adapter {
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 01fc651..d5f5dcb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -606,6 +606,7 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		dev->caps.qp1_tunnel[i - 1] = func_cap.qp1_tunnel_qpn;
 		dev->caps.qp1_proxy[i - 1] = func_cap.qp1_proxy_qpn;
 		dev->caps.port_mask[i] = dev->caps.port_type[i];
+		dev->caps.phys_port_id[i] = func_cap.phys_port_id;
 		if (mlx4_get_slave_pkey_gid_tbl_len(dev, i,
 						    &dev->caps.gid_table_len[i],
 						    &dev->caps.pkey_table_len[i]))
@@ -1484,6 +1485,10 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 
 		choose_steering_mode(dev, &dev_cap);
 
+		err = mlx4_get_phys_port_id(dev);
+		if (err)
+			mlx4_err(dev, "Fail to get physical port id\n");
+
 		if (mlx4_is_master(dev))
 			mlx4_parav_master_pf_caps(dev);
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 7d3a523..294b7c5 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -454,6 +454,7 @@ struct mlx4_caps {
 	u32			userspace_caps; /* userspace must be aware of these */
 	u32			function_caps;  /* VFs must be aware of these */
 	u16			hca_core_clock;
+	u64			phys_port_id[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_buf_list {
@@ -1113,6 +1114,7 @@ int mlx4_assign_eq(struct mlx4_dev *dev, char *name, struct cpu_rmap *rmap,
 		   int *vector);
 void mlx4_release_eq(struct mlx4_dev *dev, int vec);
 
+int mlx4_get_phys_port_id(struct mlx4_dev *dev);
 int mlx4_wol_read(struct mlx4_dev *dev, u64 *config, int port);
 int mlx4_wol_write(struct mlx4_dev *dev, u64 config, int port);
 
-- 
1.8.3.4
