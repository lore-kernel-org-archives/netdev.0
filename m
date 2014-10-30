From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/8] net/mlx4_core: Add retrieval of CONFIG_DEV parameters
Date: Thu, 30 Oct 2014 18:06:54 +0200
Message-ID: <1414685216-28907-7-git-send-email-ogerlitz@mellanox.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37979 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759581AbaJ3QHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 12:07:08 -0400
In-Reply-To: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Add code to issue CONFIG_DEV "get" firmware command.

This command is used in order to obtain certain parameters used for
supporting various RX checksumming options and vxlan UDP port.

The GET operation is allowed for VFs too.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    4 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   88 +++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    5 +
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   17 ++++
 include/linux/mlx4/cmd.h                           |   29 +++++++
 include/linux/mlx4/device.h                        |    3 +-
 6 files changed, 139 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 1312ccf..3c05e58 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -990,11 +990,11 @@ static struct mlx4_cmd_info cmd_info[] = {
 	{
 		.opcode = MLX4_CMD_CONFIG_DEV,
 		.has_inbox = false,
-		.has_outbox = false,
+		.has_outbox = true,
 		.out_is_imm = false,
 		.encode_slave_id = false,
 		.verify = NULL,
-		.wrapper = mlx4_CMD_EPERM_wrapper
+		.wrapper = mlx4_CONFIG_DEV_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_ALLOC_RES,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index e7639e3..d6dba77 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -141,7 +141,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[12] = "Large cache line (>64B) CQE stride support",
 		[13] = "Large cache line (>64B) EQE stride support",
 		[14] = "Ethernet protocol control support",
-		[15] = "Ethernet Backplane autoneg support"
+		[15] = "Ethernet Backplane autoneg support",
+		[16] = "CONFIG DEV support"
 	};
 	int i;
 
@@ -574,6 +575,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MTT_ENTRY_SZ_OFFSET	0x90
 #define QUERY_DEV_CAP_D_MPT_ENTRY_SZ_OFFSET	0x92
 #define QUERY_DEV_CAP_BMME_FLAGS_OFFSET		0x94
+#define QUERY_DEV_CAP_CONFIG_DEV_OFFSET		0x94
 #define QUERY_DEV_CAP_RSVD_LKEY_OFFSET		0x98
 #define QUERY_DEV_CAP_MAX_ICM_SZ_OFFSET		0xa0
 #define QUERY_DEV_CAP_ETH_BACKPL_OFFSET		0x9c
@@ -749,6 +751,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_EQE_STRIDE;
 	MLX4_GET(dev_cap->bmme_flags, outbox,
 		 QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_CONFIG_DEV_OFFSET);
+	if (field & 0x20)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_CONFIG_DEV;
 	MLX4_GET(dev_cap->reserved_lkey, outbox,
 		 QUERY_DEV_CAP_RSVD_LKEY_OFFSET);
 	MLX4_GET(field32, outbox, QUERY_DEV_CAP_ETH_BACKPL_OFFSET);
@@ -1849,14 +1854,18 @@ int mlx4_CLOSE_HCA(struct mlx4_dev *dev, int panic)
 
 struct mlx4_config_dev {
 	__be32	update_flags;
-	__be32	rsdv1[3];
+	__be32	rsvd1[3];
 	__be16	vxlan_udp_dport;
 	__be16	rsvd2;
+	__be32	rsvd3[27];
+	__be16	rsvd4;
+	u8	rsvd5;
+	u8	rx_checksum_val;
 };
 
 #define MLX4_VXLAN_UDP_DPORT (1 << 0)
 
-static int mlx4_CONFIG_DEV(struct mlx4_dev *dev, struct mlx4_config_dev *config_dev)
+static int mlx4_CONFIG_DEV_set(struct mlx4_dev *dev, struct mlx4_config_dev *config_dev)
 {
 	int err;
 	struct mlx4_cmd_mailbox *mailbox;
@@ -1874,6 +1883,77 @@ static int mlx4_CONFIG_DEV(struct mlx4_dev *dev, struct mlx4_config_dev *config_
 	return err;
 }
 
+static int mlx4_CONFIG_DEV_get(struct mlx4_dev *dev, struct mlx4_config_dev *config_dev)
+{
+	int err;
+	struct mlx4_cmd_mailbox *mailbox;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 1, MLX4_CMD_CONFIG_DEV,
+			   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
+
+	if (!err)
+		memcpy(config_dev, mailbox->buf, sizeof(*config_dev));
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+/* Conversion between the HW values and the actual functionality.
+ * The value represented by the array index,
+ * and the functionality determined by the flags.
+ */
+static const u8 config_dev_csum_flags[] = {
+	[0] =	0,
+	[1] =	MLX4_RX_CSUM_MODE_VAL_NON_TCP_UDP,
+	[2] =	MLX4_RX_CSUM_MODE_VAL_NON_TCP_UDP	|
+		MLX4_RX_CSUM_MODE_L4,
+	[3] =	MLX4_RX_CSUM_MODE_L4			|
+		MLX4_RX_CSUM_MODE_IP_OK_IP_NON_TCP_UDP	|
+		MLX4_RX_CSUM_MODE_MULTI_VLAN
+};
+
+int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
+			      struct mlx4_config_dev_params *params)
+{
+	struct mlx4_config_dev config_dev;
+	int err;
+	u8 csum_mask;
+
+#define CONFIG_DEV_RX_CSUM_MODE_MASK			0x7
+#define CONFIG_DEV_RX_CSUM_MODE_PORT1_BIT_OFFSET	0
+#define CONFIG_DEV_RX_CSUM_MODE_PORT2_BIT_OFFSET	4
+
+	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_CONFIG_DEV))
+		return -ENOTSUPP;
+
+	err = mlx4_CONFIG_DEV_get(dev, &config_dev);
+	if (err)
+		return err;
+
+	csum_mask = (config_dev.rx_checksum_val >> CONFIG_DEV_RX_CSUM_MODE_PORT1_BIT_OFFSET) &
+			CONFIG_DEV_RX_CSUM_MODE_MASK;
+
+	if (csum_mask >= sizeof(config_dev_csum_flags)/sizeof(config_dev_csum_flags[0]))
+		return -EINVAL;
+	params->rx_csum_flags_port_1 = config_dev_csum_flags[csum_mask];
+
+	csum_mask = (config_dev.rx_checksum_val >> CONFIG_DEV_RX_CSUM_MODE_PORT2_BIT_OFFSET) &
+			CONFIG_DEV_RX_CSUM_MODE_MASK;
+
+	if (csum_mask >= sizeof(config_dev_csum_flags)/sizeof(config_dev_csum_flags[0]))
+		return -EINVAL;
+	params->rx_csum_flags_port_2 = config_dev_csum_flags[csum_mask];
+
+	params->vxlan_udp_dport = be16_to_cpu(config_dev.vxlan_udp_dport);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx4_config_dev_retrieval);
+
 int mlx4_config_vxlan_port(struct mlx4_dev *dev, __be16 udp_port)
 {
 	struct mlx4_config_dev config_dev;
@@ -1882,7 +1962,7 @@ int mlx4_config_vxlan_port(struct mlx4_dev *dev, __be16 udp_port)
 	config_dev.update_flags    = cpu_to_be32(MLX4_VXLAN_UDP_DPORT);
 	config_dev.vxlan_udp_dport = udp_port;
 
-	return mlx4_CONFIG_DEV(dev, &config_dev);
+	return mlx4_CONFIG_DEV_set(dev, &config_dev);
 }
 EXPORT_SYMBOL_GPL(mlx4_config_vxlan_port);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 254ec7b..f8fc7bd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -947,6 +947,11 @@ int mlx4_SW2HW_EQ_wrapper(struct mlx4_dev *dev, int slave,
 			  struct mlx4_cmd_mailbox *inbox,
 			  struct mlx4_cmd_mailbox *outbox,
 			  struct mlx4_cmd_info *cmd);
+int mlx4_CONFIG_DEV_wrapper(struct mlx4_dev *dev, int slave,
+			    struct mlx4_vhcr *vhcr,
+			    struct mlx4_cmd_mailbox *inbox,
+			    struct mlx4_cmd_mailbox *outbox,
+			    struct mlx4_cmd_info *cmd);
 int mlx4_DMA_wrapper(struct mlx4_dev *dev, int slave,
 		     struct mlx4_vhcr *vhcr,
 		     struct mlx4_cmd_mailbox *inbox,
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 5d2498d..d718ca0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2872,6 +2872,23 @@ out_add:
 	return err;
 }
 
+int mlx4_CONFIG_DEV_wrapper(struct mlx4_dev *dev, int slave,
+			    struct mlx4_vhcr *vhcr,
+			    struct mlx4_cmd_mailbox *inbox,
+			    struct mlx4_cmd_mailbox *outbox,
+			    struct mlx4_cmd_info *cmd)
+{
+	int err;
+	u8 get = vhcr->op_modifier;
+
+	if (get != 1)
+		return -EPERM;
+
+	err = mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd);
+
+	return err;
+}
+
 static int get_containing_mtt(struct mlx4_dev *dev, int slave, int start,
 			      int len, struct res_mtt **res)
 {
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index ff5f5de..64d2594 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -199,6 +199,33 @@ enum {
 	MLX4_CMD_NATIVE
 };
 
+/*
+ * MLX4_RX_CSUM_MODE_VAL_NON_TCP_UDP -
+ * Receive checksum value is reported in CQE also for non TCP/UDP packets.
+ *
+ * MLX4_RX_CSUM_MODE_L4 -
+ * L4_CSUM bit in CQE, which indicates whether or not L4 checksum
+ * was validated correctly, is supported.
+ *
+ * MLX4_RX_CSUM_MODE_IP_OK_IP_NON_TCP_UDP -
+ * IP_OK CQE's field is supported also for non TCP/UDP IP packets.
+ *
+ * MLX4_RX_CSUM_MODE_MULTI_VLAN -
+ * Receive Checksum offload is supported for packets with more than 2 vlan headers.
+ */
+enum mlx4_rx_csum_mode {
+	MLX4_RX_CSUM_MODE_VAL_NON_TCP_UDP		= 1UL << 0,
+	MLX4_RX_CSUM_MODE_L4				= 1UL << 1,
+	MLX4_RX_CSUM_MODE_IP_OK_IP_NON_TCP_UDP		= 1UL << 2,
+	MLX4_RX_CSUM_MODE_MULTI_VLAN			= 1UL << 3
+};
+
+struct mlx4_config_dev_params {
+	u16	vxlan_udp_dport;
+	u8	rx_csum_flags_port_1;
+	u8	rx_csum_flags_port_2;
+};
+
 struct mlx4_dev;
 
 struct mlx4_cmd_mailbox {
@@ -250,6 +277,8 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos);
 int mlx4_set_vf_spoofchk(struct mlx4_dev *dev, int port, int vf, bool setting);
 int mlx4_get_vf_config(struct mlx4_dev *dev, int port, int vf, struct ifla_vf_info *ivf);
 int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_state);
+int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
+			      struct mlx4_config_dev_params *params);
 /*
  * mlx4_get_slave_default_vlan -
  * return true if VST ( default vlan)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e4c136e..5cc5eac 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -188,7 +188,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_CQE_STRIDE		= 1LL <<  12,
 	MLX4_DEV_CAP_FLAG2_EQE_STRIDE		= 1LL <<  13,
 	MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL        = 1LL <<  14,
-	MLX4_DEV_CAP_FLAG2_ETH_BACKPL_AN_REP	= 1LL <<  15
+	MLX4_DEV_CAP_FLAG2_ETH_BACKPL_AN_REP	= 1LL <<  15,
+	MLX4_DEV_CAP_FLAG2_CONFIG_DEV		= 1LL <<  16
 };
 
 enum {
-- 
1.7.1
