From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 04/10] net/mlx4_core: Port aggregation low level interface
Date: Tue,  3 Feb 2015 16:48:32 +0200
Message-ID: <1422974919-28084-5-git-send-email-ogerlitz@mellanox.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60056 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751725AbbBCOtv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 09:49:51 -0500
In-Reply-To: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

Implement the hardware interface required for port aggregation.

1. Disable RX port check on receive - don't perform a validity check
that matches to QP's port and the port where the packet is received.

2. Virtual to physical port remap - configure virtual to physical port
mapping. Port remap capability for virtual functions.

Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |    9 +++++
 drivers/net/ethernet/mellanox/mlx4/fw.c  |   56 +++++++++++++++++++++++++++---
 include/linux/mlx4/cmd.h                 |    7 ++++
 include/linux/mlx4/device.h              |   10 +++++-
 include/linux/mlx4/qp.h                  |    1 +
 5 files changed, 77 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 154effb..a681d7c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1583,6 +1583,15 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.verify = NULL,
 		.wrapper = mlx4_CMD_EPERM_wrapper
 	},
+	{
+		.opcode = MLX4_CMD_VIRT_PORT_MAP,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_CMD_EPERM_wrapper
+	},
 };
 
 static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index dbabfae..4b08a39 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -142,7 +142,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[17] = "Asymmetric EQs support",
 		[18] = "More than 80 VFs support",
 		[19] = "Performance optimized for limited rule configuration flow steering support",
-		[20] = "Recoverable error events support"
+		[20] = "Recoverable error events support",
+		[21] = "Port Remap support"
 	};
 	int i;
 
@@ -863,6 +864,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_EQE_STRIDE;
 	MLX4_GET(dev_cap->bmme_flags, outbox,
 		 QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
+	if (dev_cap->bmme_flags & MLX4_FLAG_PORT_REMAP)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_PORT_REMAP;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_CONFIG_DEV_OFFSET);
 	if (field & 0x20)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_CONFIG_DEV;
@@ -1120,9 +1123,10 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	field &= 0x7f;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_BF_OFFSET);
 
-	/* For guests, disable mw type 2 */
+	/* For guests, disable mw type 2 and port remap*/
 	MLX4_GET(bmme_flags, outbox->buf, QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
 	bmme_flags &= ~MLX4_BMME_FLAG_TYPE_2_WIN;
+	bmme_flags &= ~MLX4_FLAG_PORT_REMAP;
 	MLX4_PUT(outbox->buf, bmme_flags, QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
 
 	/* turn off device-managed steering capability if not enabled */
@@ -2100,13 +2104,16 @@ struct mlx4_config_dev {
 	__be32	rsvd1[3];
 	__be16	vxlan_udp_dport;
 	__be16	rsvd2;
-	__be32	rsvd3[27];
-	__be16	rsvd4;
-	u8	rsvd5;
+	__be32	rsvd3;
+	__be32	roce_flags;
+	__be32	rsvd4[25];
+	__be16	rsvd5;
+	u8	rsvd6;
 	u8	rx_checksum_val;
 };
 
 #define MLX4_VXLAN_UDP_DPORT (1 << 0)
+#define MLX4_DISABLE_RX_PORT BIT(18)
 
 static int mlx4_CONFIG_DEV_set(struct mlx4_dev *dev, struct mlx4_config_dev *config_dev)
 {
@@ -2209,6 +2216,45 @@ int mlx4_config_vxlan_port(struct mlx4_dev *dev, __be16 udp_port)
 }
 EXPORT_SYMBOL_GPL(mlx4_config_vxlan_port);
 
+#define CONFIG_DISABLE_RX_PORT BIT(15)
+int mlx4_disable_rx_port_check(struct mlx4_dev *dev, bool dis)
+{
+	struct mlx4_config_dev config_dev;
+
+	memset(&config_dev, 0, sizeof(config_dev));
+	config_dev.update_flags = cpu_to_be32(MLX4_DISABLE_RX_PORT);
+	if (dis)
+		config_dev.roce_flags =
+			cpu_to_be32(CONFIG_DISABLE_RX_PORT);
+
+	return mlx4_CONFIG_DEV_set(dev, &config_dev);
+}
+
+int mlx4_virt2phy_port_map(struct mlx4_dev *dev, u32 port1, u32 port2)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct {
+		__be32 v_port1;
+		__be32 v_port2;
+	} *v2p;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return -ENOMEM;
+
+	v2p = mailbox->buf;
+	v2p->v_port1 = cpu_to_be32(port1);
+	v2p->v_port2 = cpu_to_be32(port2);
+
+	err = mlx4_cmd(dev, mailbox->dma, 0,
+		       MLX4_SET_PORT_VIRT2PHY, MLX4_CMD_VIRT_PORT_MAP,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
 
 int mlx4_SET_ICM_SIZE(struct mlx4_dev *dev, u64 icm_size, u64 *aux_pages)
 {
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index ae95adc..7b6d4e9 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -71,6 +71,7 @@ enum {
 
 	/*master notify fw on finish for slave's flr*/
 	MLX4_CMD_INFORM_FLR_DONE = 0x5b,
+	MLX4_CMD_VIRT_PORT_MAP   = 0x5c,
 	MLX4_CMD_GET_OP_REQ      = 0x59,
 
 	/* TPT commands */
@@ -171,6 +172,12 @@ enum {
 };
 
 enum {
+	/* virtual to physical port mapping opcode modifiers */
+	MLX4_GET_PORT_VIRT2PHY = 0x0,
+	MLX4_SET_PORT_VIRT2PHY = 0x1,
+};
+
+enum {
 	MLX4_MAILBOX_SIZE	= 4096,
 	MLX4_ACCESS_MEM_ALIGN	= 256,
 };
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index c95d659..d9afd99 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -201,7 +201,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_SYS_EQS		= 1LL <<  17,
 	MLX4_DEV_CAP_FLAG2_80_VFS		= 1LL <<  18,
 	MLX4_DEV_CAP_FLAG2_FS_A0		= 1LL <<  19,
-	MLX4_DEV_CAP_FLAG2_RECOVERABLE_ERROR_EVENT = 1LL << 20
+	MLX4_DEV_CAP_FLAG2_RECOVERABLE_ERROR_EVENT = 1LL << 20,
+	MLX4_DEV_CAP_FLAG2_PORT_REMAP		= 1LL <<  21
 };
 
 enum {
@@ -253,9 +254,14 @@ enum {
 	MLX4_BMME_FLAG_TYPE_2_WIN	= 1 <<  9,
 	MLX4_BMME_FLAG_RESERVED_LKEY	= 1 << 10,
 	MLX4_BMME_FLAG_FAST_REG_WR	= 1 << 11,
+	MLX4_BMME_FLAG_PORT_REMAP	= 1 << 24,
 	MLX4_BMME_FLAG_VSD_INIT2RTR	= 1 << 28,
 };
 
+enum {
+	MLX4_FLAG_PORT_REMAP		= MLX4_BMME_FLAG_PORT_REMAP
+};
+
 enum mlx4_event {
 	MLX4_EVENT_TYPE_COMP		   = 0x00,
 	MLX4_EVENT_TYPE_PATH_MIG	   = 0x01,
@@ -1378,6 +1384,8 @@ int mlx4_phys_to_slave_port(struct mlx4_dev *dev, int slave, int port);
 int mlx4_get_base_gid_ix(struct mlx4_dev *dev, int slave, int port);
 
 int mlx4_config_vxlan_port(struct mlx4_dev *dev, __be16 udp_port);
+int mlx4_disable_rx_port_check(struct mlx4_dev *dev, bool dis);
+int mlx4_virt2phy_port_map(struct mlx4_dev *dev, u32 port1, u32 port2);
 int mlx4_vf_smi_enabled(struct mlx4_dev *dev, int slave, int port);
 int mlx4_vf_get_enable_smi_admin(struct mlx4_dev *dev, int slave, int port);
 int mlx4_vf_set_enable_smi_admin(struct mlx4_dev *dev, int slave, int port,
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 467ccdf..2bbc62a 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -96,6 +96,7 @@ enum {
 	MLX4_QP_BIT_RRE				= 1 << 15,
 	MLX4_QP_BIT_RWE				= 1 << 14,
 	MLX4_QP_BIT_RAE				= 1 << 13,
+	MLX4_QP_BIT_FPP				= 1 <<	3,
 	MLX4_QP_BIT_RIC				= 1 <<	4,
 };
 
-- 
1.7.1
