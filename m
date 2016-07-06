From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 4/4] net/mlx4_core: Add an option to configure SVLAN TPID
Date: Wed,  6 Jul 2016 15:29:06 +0300
Message-ID: <1467808146-29573-5-git-send-email-tariqt@mellanox.com>
References: <1467808146-29573-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33226 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751895AbcGFMaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 08:30:52 -0400
In-Reply-To: <1467808146-29573-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

Expose mlx4_config_svlan_tpid, that checks for feature support
in device capabilities and sets the Service Tag TPID accordingly.

Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 25 ++++++++++++++++++++++++-
 include/linux/mlx4/cmd.h                |  1 +
 include/linux/mlx4/device.h             |  2 ++
 3 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 6a10129..2d89009 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -160,6 +160,7 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[33] = "RoCEv2 support",
 		[34] = "DMFS Sniffer support (UC & MC)",
 		[35] = "QinQ VST mode support",
+		[36] = "QinQ Service VLAN TPID configuration support",
 	};
 	int i;
 
@@ -722,6 +723,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_D_MPT_ENTRY_SZ_OFFSET	0x92
 #define QUERY_DEV_CAP_BMME_FLAGS_OFFSET		0x94
 #define QUERY_DEV_CAP_CONFIG_DEV_OFFSET		0x94
+#define QUERY_DEV_CAP_SVLAN_TPID_OFFSET		0x95
 #define QUERY_DEV_CAP_PHV_EN_OFFSET		0x96
 #define QUERY_DEV_CAP_RSVD_LKEY_OFFSET		0x98
 #define QUERY_DEV_CAP_MAX_ICM_SZ_OFFSET		0xa0
@@ -935,6 +937,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_PHV_EN;
 	if (field & 0x40)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_SKIP_OUTER_VLAN;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_SVLAN_TPID_OFFSET);
+	if (field & (1 << 0))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_SVLAN_TPID;
 
 	MLX4_GET(dev_cap->reserved_lkey, outbox,
 		 QUERY_DEV_CAP_RSVD_LKEY_OFFSET);
@@ -2278,7 +2283,7 @@ struct mlx4_config_dev {
 	__be16  roce_v2_udp_dport;
 	__be32	roce_flags;
 	__be32	rsvd4[25];
-	__be16	rsvd5;
+	__be16	svlan_tpid;
 	u8	rsvd6;
 	u8	rx_checksum_val;
 };
@@ -2286,6 +2291,7 @@ struct mlx4_config_dev {
 #define MLX4_VXLAN_UDP_DPORT (1 << 0)
 #define MLX4_ROCE_V2_UDP_DPORT BIT(3)
 #define MLX4_DISABLE_RX_PORT BIT(18)
+#define MLX4_SVLAN_TPID BIT(20)
 
 static int mlx4_CONFIG_DEV_set(struct mlx4_dev *dev, struct mlx4_config_dev *config_dev)
 {
@@ -2372,6 +2378,8 @@ int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
 
 	params->vxlan_udp_dport = be16_to_cpu(config_dev.vxlan_udp_dport);
 
+	params->svlan_tpid = be16_to_cpu(config_dev.svlan_tpid);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx4_config_dev_retrieval);
@@ -2414,6 +2422,21 @@ int mlx4_config_roce_v2_port(struct mlx4_dev *dev, u16 udp_port)
 }
 EXPORT_SYMBOL_GPL(mlx4_config_roce_v2_port);
 
+int mlx4_config_svlan_tpid(struct mlx4_dev *dev, __be16 svlan_tpid)
+{
+	struct mlx4_config_dev config_dev;
+
+	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_SVLAN_TPID))
+		return -ENOTSUPP;
+
+	memset(&config_dev, 0, sizeof(config_dev));
+	config_dev.update_flags    = cpu_to_be32(MLX4_SVLAN_TPID);
+	config_dev.svlan_tpid = svlan_tpid;
+
+	return mlx4_CONFIG_DEV_set(dev, &config_dev);
+}
+EXPORT_SYMBOL_GPL(mlx4_config_svlan_tpid);
+
 int mlx4_virt2phy_port_map(struct mlx4_dev *dev, u32 port1, u32 port2)
 {
 	struct mlx4_cmd_mailbox *mailbox;
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 1f35686..080541b 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -246,6 +246,7 @@ struct mlx4_config_dev_params {
 	u16	vxlan_udp_dport;
 	u8	rx_csum_flags_port_1;
 	u8	rx_csum_flags_port_2;
+	u16	svlan_tpid;
 };
 
 enum mlx4_en_congestion_control_algorithm {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 09218d1..fbc974c 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -221,6 +221,7 @@ enum {
 	MLX4_DEV_CAP_FLAG2_ROCE_V1_V2		= 1ULL <<  33,
 	MLX4_DEV_CAP_FLAG2_DMFS_UC_MC_SNIFFER   = 1ULL <<  34,
 	MLX4_DEV_CAP_FLAG2_SVLAN_BY_QP          = 1ULL <<  35,
+	MLX4_DEV_CAP_FLAG2_SVLAN_TPID		= 1ULL <<  36,
 };
 
 enum {
@@ -1476,6 +1477,7 @@ int mlx4_get_base_gid_ix(struct mlx4_dev *dev, int slave, int port);
 int mlx4_config_vxlan_port(struct mlx4_dev *dev, __be16 udp_port);
 int mlx4_disable_rx_port_check(struct mlx4_dev *dev, bool dis);
 int mlx4_config_roce_v2_port(struct mlx4_dev *dev, u16 udp_port);
+int mlx4_config_svlan_tpid(struct mlx4_dev *dev, __be16 svlan_tpid);
 int mlx4_virt2phy_port_map(struct mlx4_dev *dev, u32 port1, u32 port2);
 int mlx4_vf_smi_enabled(struct mlx4_dev *dev, int slave, int port);
 int mlx4_vf_get_enable_smi_admin(struct mlx4_dev *dev, int slave, int port);
-- 
1.8.3.1
