From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 10/10] net/mlx4: Add support for A0 steering
Date: Thu, 11 Dec 2014 10:58:00 +0200
Message-ID: <1418288280-334-11-git-send-email-ogerlitz@mellanox.com>
References: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40599 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932227AbaLKI7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 03:59:47 -0500
In-Reply-To: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Add the required firmware commands for A0 steering and a way to enable
that. The firmware support focuses on INIT_HCA, QUERY_HCA, QUERY_PORT,
QUERY_DEV_CAP and QUERY_FUNC_CAP commands. Those commands are used
to configure and query the device.

The different A0 DMFS (steering) modes are:

Static - optimized performance, but flow steering rules are
limited. This mode should be choosed explicitly by the user
in order to be used.

Dynamic - this mode should be explicitly choosed by the user.
In this mode, the FW works in optimized steering mode as long as
it can and afterwards automatically drops to classic (full) DMFS.

Disable - this mode should be explicitly choosed by the user.
The user instructs the system not to use optimized steering, even if
the FW supports Dynamic A0 DMFS (and thus will be able to use optimized
steering in Default A0 DMFS mode).

Default - this mode is implicitly choosed. In this mode, if the FW
supports Dynamic A0 DMFS, it'll work in this mode. Otherwise, it'll
work at Disable A0 DMFS mode.

Under SRIOV configuration, when the A0 steering mode is enabled,
older guest VF drivers who aren't using the RX QP allocation flag
(MLX4_RESERVE_A0_QP) will get a QP from the general range and
fail when attempting to register a steering rule. To avoid that,
the PF context behaviour is changed once on A0 static mode, to
require support for the allocation flag in VF drivers too.

In order to enable A0 steering, we use log_num_mgm_entry_size param.
If the value of the parameter is not positive, we treat the absolute
value of log_num_mgm_entry_size as a bit field. Setting bit 2 of this
bit field enables static A0 steering.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    3 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |   48 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h        |    4 +
 drivers/net/ethernet/mellanox/mlx4/main.c      |  132 ++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |    2 -
 drivers/net/ethernet/mellanox/mlx4/qp.c        |    4 +-
 include/linux/mlx4/device.h                    |   17 +++-
 7 files changed, 191 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 568e1f4..6ff214d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2594,7 +2594,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 
 	if (mdev->dev->caps.steering_mode ==
-	    MLX4_STEERING_MODE_DEVICE_MANAGED)
+	    MLX4_STEERING_MODE_DEVICE_MANAGED &&
+	    mdev->dev->caps.dmfs_high_steer_mode != MLX4_STEERING_DMFS_A0_STATIC)
 		dev->hw_features |= NETIF_F_NTUPLE;
 
 	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 073b3d1..ef3b95b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -144,7 +144,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[15] = "Ethernet Backplane autoneg support",
 		[16] = "CONFIG DEV support",
 		[17] = "Asymmetric EQs support",
-		[18] = "More than 80 VFs support"
+		[18] = "More than 80 VFs support",
+		[19] = "Performance optimized for limited rule configuration flow steering support"
 	};
 	int i;
 
@@ -680,6 +681,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_FW_REASSIGN_MAC		0x9d
 #define QUERY_DEV_CAP_VXLAN			0x9e
 #define QUERY_DEV_CAP_MAD_DEMUX_OFFSET		0xb0
+#define QUERY_DEV_CAP_DMFS_HIGH_RATE_QPN_BASE_OFFSET	0xa8
+#define QUERY_DEV_CAP_DMFS_HIGH_RATE_QPN_RANGE_OFFSET	0xac
 
 	dev_cap->flags2 = 0;
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
@@ -876,6 +879,13 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	if (field32 & (1 << 0))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_MAD_DEMUX;
 
+	MLX4_GET(dev_cap->dmfs_high_rate_qpn_base, outbox,
+		 QUERY_DEV_CAP_DMFS_HIGH_RATE_QPN_BASE_OFFSET);
+	dev_cap->dmfs_high_rate_qpn_base &= MGM_QPN_MASK;
+	MLX4_GET(dev_cap->dmfs_high_rate_qpn_range, outbox,
+		 QUERY_DEV_CAP_DMFS_HIGH_RATE_QPN_RANGE_OFFSET);
+	dev_cap->dmfs_high_rate_qpn_range &= MGM_QPN_MASK;
+
 	MLX4_GET(field32, outbox, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
 	if (field32 & (1 << 16))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_UPDATE_QP;
@@ -935,6 +945,10 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	mlx4_dbg(dev, "Max GSO size: %d\n", dev_cap->max_gso_sz);
 	mlx4_dbg(dev, "Max counters: %d\n", dev_cap->max_counters);
 	mlx4_dbg(dev, "Max RSS Table size: %d\n", dev_cap->max_rss_tbl_sz);
+	mlx4_dbg(dev, "DMFS high rate steer QPn base: %d\n",
+		 dev_cap->dmfs_high_rate_qpn_base);
+	mlx4_dbg(dev, "DMFS high rate steer QPn range: %d\n",
+		 dev_cap->dmfs_high_rate_qpn_range);
 
 	dump_dev_cap_flags(dev, dev_cap->flags);
 	dump_dev_cap_flags2(dev, dev_cap->flags2);
@@ -996,6 +1010,7 @@ int mlx4_QUERY_PORT(struct mlx4_dev *dev, int port, struct mlx4_port_cap *port_c
 		port_cap->supported_port_types = field & 3;
 		port_cap->suggested_type = (field >> 3) & 1;
 		port_cap->default_sense = (field >> 4) & 1;
+		port_cap->dmfs_optimized_state = (field >> 5) & 1;
 		MLX4_GET(field, outbox, QUERY_PORT_MTU_OFFSET);
 		port_cap->ib_mtu	   = field & 0xf;
 		MLX4_GET(field, outbox, QUERY_PORT_WIDTH_OFFSET);
@@ -1530,6 +1545,12 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	struct mlx4_cmd_mailbox *mailbox;
 	__be32 *inbox;
 	int err;
+	static const u8 a0_dmfs_hw_steering[] =  {
+		[MLX4_STEERING_DMFS_A0_DEFAULT]		= 0,
+		[MLX4_STEERING_DMFS_A0_DYNAMIC]		= 1,
+		[MLX4_STEERING_DMFS_A0_STATIC]		= 2,
+		[MLX4_STEERING_DMFS_A0_DISABLE]		= 3
+	};
 
 #define INIT_HCA_IN_SIZE		 0x200
 #define INIT_HCA_VERSION_OFFSET		 0x000
@@ -1563,6 +1584,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 #define  INIT_HCA_FS_PARAM_OFFSET         0x1d0
 #define  INIT_HCA_FS_BASE_OFFSET          (INIT_HCA_FS_PARAM_OFFSET + 0x00)
 #define  INIT_HCA_FS_LOG_ENTRY_SZ_OFFSET  (INIT_HCA_FS_PARAM_OFFSET + 0x12)
+#define  INIT_HCA_FS_A0_OFFSET		  (INIT_HCA_FS_PARAM_OFFSET + 0x18)
 #define  INIT_HCA_FS_LOG_TABLE_SZ_OFFSET  (INIT_HCA_FS_PARAM_OFFSET + 0x1b)
 #define  INIT_HCA_FS_ETH_BITS_OFFSET      (INIT_HCA_FS_PARAM_OFFSET + 0x21)
 #define  INIT_HCA_FS_ETH_NUM_ADDRS_OFFSET (INIT_HCA_FS_PARAM_OFFSET + 0x22)
@@ -1673,8 +1695,11 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 		/* Enable Ethernet flow steering
 		 * with udp unicast and tcp unicast
 		 */
-		MLX4_PUT(inbox, (u8) (MLX4_FS_UDP_UC_EN | MLX4_FS_TCP_UC_EN),
-			 INIT_HCA_FS_ETH_BITS_OFFSET);
+		if (dev->caps.dmfs_high_steer_mode !=
+		    MLX4_STEERING_DMFS_A0_STATIC)
+			MLX4_PUT(inbox,
+				 (u8)(MLX4_FS_UDP_UC_EN | MLX4_FS_TCP_UC_EN),
+				 INIT_HCA_FS_ETH_BITS_OFFSET);
 		MLX4_PUT(inbox, (u16) MLX4_FS_NUM_OF_L2_ADDR,
 			 INIT_HCA_FS_ETH_NUM_ADDRS_OFFSET);
 		/* Enable IPoIB flow steering
@@ -1684,6 +1709,13 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 			 INIT_HCA_FS_IB_BITS_OFFSET);
 		MLX4_PUT(inbox, (u16) MLX4_FS_NUM_OF_L2_ADDR,
 			 INIT_HCA_FS_IB_NUM_ADDRS_OFFSET);
+
+		if (dev->caps.dmfs_high_steer_mode !=
+		    MLX4_STEERING_DMFS_A0_NOT_SUPPORTED)
+			MLX4_PUT(inbox,
+				 ((u8)(a0_dmfs_hw_steering[dev->caps.dmfs_high_steer_mode]
+				       << 6)),
+				 INIT_HCA_FS_A0_OFFSET);
 	} else {
 		MLX4_PUT(inbox, param->mc_base,	INIT_HCA_MC_BASE_OFFSET);
 		MLX4_PUT(inbox, param->log_mc_entry_sz,
@@ -1734,6 +1766,12 @@ int mlx4_QUERY_HCA(struct mlx4_dev *dev,
 	u32 dword_field;
 	int err;
 	u8 byte_field;
+	static const u8 a0_dmfs_query_hw_steering[] =  {
+		[0] = MLX4_STEERING_DMFS_A0_DEFAULT,
+		[1] = MLX4_STEERING_DMFS_A0_DYNAMIC,
+		[2] = MLX4_STEERING_DMFS_A0_STATIC,
+		[3] = MLX4_STEERING_DMFS_A0_DISABLE
+	};
 
 #define QUERY_HCA_GLOBAL_CAPS_OFFSET	0x04
 #define QUERY_HCA_CORE_CLOCK_OFFSET	0x0c
@@ -1786,6 +1824,10 @@ int mlx4_QUERY_HCA(struct mlx4_dev *dev,
 			 INIT_HCA_FS_LOG_ENTRY_SZ_OFFSET);
 		MLX4_GET(param->log_mc_table_sz, outbox,
 			 INIT_HCA_FS_LOG_TABLE_SZ_OFFSET);
+		MLX4_GET(byte_field, outbox,
+			 INIT_HCA_FS_A0_OFFSET);
+		param->dmfs_high_steer_mode =
+			a0_dmfs_query_hw_steering[(byte_field >> 6) & 3];
 	} else {
 		MLX4_GET(param->mc_base, outbox, INIT_HCA_MC_BASE_OFFSET);
 		MLX4_GET(param->log_mc_entry_sz, outbox,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 744398b..794e282 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -60,6 +60,7 @@ struct mlx4_port_cap {
 	int vendor_oui;
 	u16 wavelength;
 	u64 trans_code;
+	u8 dmfs_optimized_state;
 };
 
 struct mlx4_dev_cap {
@@ -124,6 +125,8 @@ struct mlx4_dev_cap {
 	int max_gso_sz;
 	int max_rss_tbl_sz;
 	u32 max_counters;
+	u32 dmfs_high_rate_qpn_base;
+	u32 dmfs_high_rate_qpn_range;
 	struct mlx4_port_cap port_cap[MLX4_MAX_PORTS + 1];
 };
 
@@ -194,6 +197,7 @@ struct mlx4_init_hca_param {
 	u8  mw_enabled;  /* Enable memory windows */
 	u8  uar_page_sz; /* log pg sz in 4k chunks */
 	u8  steering_mode; /* for QUERY_HCA */
+	u8  dmfs_high_steer_mode; /* for QUERY_HCA */
 	u64 dev_cap_enabled;
 	u16 cqe_size; /* For use only when CQE stride feature enabled */
 	u16 eqe_size; /* For use only when EQE stride feature enabled */
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 6173b80..e25436b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -105,7 +105,8 @@ MODULE_PARM_DESC(enable_64b_cqe_eqe,
 		 "Enable 64 byte CQEs/EQEs when the FW supports this (default: True)");
 
 #define PF_CONTEXT_BEHAVIOUR_MASK	(MLX4_FUNC_CAP_64B_EQE_CQE | \
-					 MLX4_FUNC_CAP_EQE_CQE_STRIDE)
+					 MLX4_FUNC_CAP_EQE_CQE_STRIDE | \
+					 MLX4_FUNC_CAP_DMFS_A0_STATIC)
 
 static char mlx4_version[] =
 	DRV_NAME ": Mellanox ConnectX core driver v"
@@ -463,8 +464,28 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		(1 << dev->caps.log_num_vlans) *
 		dev->caps.num_ports;
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_EXCH] = MLX4_NUM_FEXCH;
+
+	if (dev_cap->dmfs_high_rate_qpn_base > 0 &&
+	    dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_FS_EN)
+		dev->caps.dmfs_high_rate_qpn_base = dev_cap->dmfs_high_rate_qpn_base;
+	else
+		dev->caps.dmfs_high_rate_qpn_base =
+			dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW];
+
+	if (dev_cap->dmfs_high_rate_qpn_range > 0 &&
+	    dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_FS_EN) {
+		dev->caps.dmfs_high_rate_qpn_range = dev_cap->dmfs_high_rate_qpn_range;
+		dev->caps.dmfs_high_steer_mode = MLX4_STEERING_DMFS_A0_DEFAULT;
+		dev->caps.flags2 |= MLX4_DEV_CAP_FLAG2_FS_A0;
+	} else {
+		dev->caps.dmfs_high_steer_mode = MLX4_STEERING_DMFS_A0_NOT_SUPPORTED;
+		dev->caps.dmfs_high_rate_qpn_base =
+			dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW];
+		dev->caps.dmfs_high_rate_qpn_range = MLX4_A0_STEERING_TABLE_SIZE;
+	}
+
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_RSS_RAW_ETH] =
-		MLX4_A0_STEERING_TABLE_SIZE;
+		dev->caps.dmfs_high_rate_qpn_range;
 
 	dev->caps.reserved_qps = dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW] +
 		dev->caps.reserved_qps_cnt[MLX4_QP_REGION_ETH_ADDR] +
@@ -753,7 +774,8 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 
 	if ((func_cap.pf_context_behaviour | PF_CONTEXT_BEHAVIOUR_MASK) !=
 	    PF_CONTEXT_BEHAVIOUR_MASK) {
-		mlx4_err(dev, "Unknown pf context behaviour\n");
+		mlx4_err(dev, "Unknown pf context behaviour %x known flags %x\n",
+			 func_cap.pf_context_behaviour, PF_CONTEXT_BEHAVIOUR_MASK);
 		return -ENOSYS;
 	}
 
@@ -1640,10 +1662,46 @@ static int choose_log_fs_mgm_entry_size(int qp_per_entry)
 	return (i <= MLX4_MAX_MGM_LOG_ENTRY_SIZE) ? i : -1;
 }
 
+static const char *dmfs_high_rate_steering_mode_str(int dmfs_high_steer_mode)
+{
+	switch (dmfs_high_steer_mode) {
+	case MLX4_STEERING_DMFS_A0_DEFAULT:
+		return "default performance";
+
+	case MLX4_STEERING_DMFS_A0_DYNAMIC:
+		return "dynamic hybrid mode";
+
+	case MLX4_STEERING_DMFS_A0_STATIC:
+		return "performance optimized for limited rule configuration (static)";
+
+	case MLX4_STEERING_DMFS_A0_DISABLE:
+		return "disabled performance optimized steering";
+
+	case MLX4_STEERING_DMFS_A0_NOT_SUPPORTED:
+		return "performance optimized steering not supported";
+
+	default:
+		return "Unrecognized mode";
+	}
+}
+
+#define MLX4_DMFS_A0_STEERING			(1UL << 2)
+
 static void choose_steering_mode(struct mlx4_dev *dev,
 				 struct mlx4_dev_cap *dev_cap)
 {
-	if (mlx4_log_num_mgm_entry_size == -1 &&
+	if (mlx4_log_num_mgm_entry_size <= 0) {
+		if ((-mlx4_log_num_mgm_entry_size) & MLX4_DMFS_A0_STEERING) {
+			if (dev->caps.dmfs_high_steer_mode ==
+			    MLX4_STEERING_DMFS_A0_NOT_SUPPORTED)
+				mlx4_err(dev, "DMFS high rate mode not supported\n");
+			else
+				dev->caps.dmfs_high_steer_mode =
+					MLX4_STEERING_DMFS_A0_STATIC;
+		}
+	}
+
+	if (mlx4_log_num_mgm_entry_size <= 0 &&
 	    dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_FS_EN &&
 	    (!mlx4_is_mfunc(dev) ||
 	     (dev_cap->fs_max_num_qp_per_entry >= (dev->num_vfs + 1))) &&
@@ -1656,6 +1714,9 @@ static void choose_steering_mode(struct mlx4_dev *dev,
 		dev->caps.fs_log_max_ucast_qp_range_size =
 			dev_cap->fs_log_max_ucast_qp_range_size;
 	} else {
+		if (dev->caps.dmfs_high_steer_mode !=
+		    MLX4_STEERING_DMFS_A0_NOT_SUPPORTED)
+			dev->caps.dmfs_high_steer_mode = MLX4_STEERING_DMFS_A0_DISABLE;
 		if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER &&
 		    dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER)
 			dev->caps.steering_mode = MLX4_STEERING_MODE_B0;
@@ -1682,7 +1743,8 @@ static void choose_tunnel_offload_mode(struct mlx4_dev *dev,
 				       struct mlx4_dev_cap *dev_cap)
 {
 	if (dev->caps.steering_mode == MLX4_STEERING_MODE_DEVICE_MANAGED &&
-	    dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS)
+	    dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS &&
+	    dev->caps.dmfs_high_steer_mode != MLX4_STEERING_DMFS_A0_STATIC)
 		dev->caps.tunnel_offload_mode = MLX4_TUNNEL_OFFLOAD_MODE_VXLAN;
 	else
 		dev->caps.tunnel_offload_mode = MLX4_TUNNEL_OFFLOAD_MODE_NONE;
@@ -1691,6 +1753,35 @@ static void choose_tunnel_offload_mode(struct mlx4_dev *dev,
 		 == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) ? "vxlan" : "none");
 }
 
+static int mlx4_validate_optimized_steering(struct mlx4_dev *dev)
+{
+	int i;
+	struct mlx4_port_cap port_cap;
+
+	if (dev->caps.dmfs_high_steer_mode == MLX4_STEERING_DMFS_A0_NOT_SUPPORTED)
+		return -EINVAL;
+
+	for (i = 1; i <= dev->caps.num_ports; i++) {
+		if (mlx4_dev_port(dev, i, &port_cap)) {
+			mlx4_err(dev,
+				 "QUERY_DEV_CAP command failed, can't veify DMFS high rate steering.\n");
+		} else if ((dev->caps.dmfs_high_steer_mode !=
+			    MLX4_STEERING_DMFS_A0_DEFAULT) &&
+			   (port_cap.dmfs_optimized_state ==
+			    !!(dev->caps.dmfs_high_steer_mode ==
+			    MLX4_STEERING_DMFS_A0_DISABLE))) {
+			mlx4_err(dev,
+				 "DMFS high rate steer mode differ, driver requested %s but %s in FW.\n",
+				 dmfs_high_rate_steering_mode_str(
+					dev->caps.dmfs_high_steer_mode),
+				 (port_cap.dmfs_optimized_state ?
+					"enabled" : "disabled"));
+		}
+	}
+
+	return 0;
+}
+
 static int mlx4_init_fw(struct mlx4_dev *dev)
 {
 	struct mlx4_mod_stat_cfg   mlx4_cfg;
@@ -1743,6 +1834,10 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		choose_steering_mode(dev, &dev_cap);
 		choose_tunnel_offload_mode(dev, &dev_cap);
 
+		if (dev->caps.dmfs_high_steer_mode == MLX4_STEERING_DMFS_A0_STATIC &&
+		    mlx4_is_master(dev))
+			dev->caps.function_caps |= MLX4_FUNC_CAP_DMFS_A0_STATIC;
+
 		err = mlx4_get_phys_port_id(dev);
 		if (err)
 			mlx4_err(dev, "Fail to get physical port id\n");
@@ -1829,6 +1924,24 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 				mlx4_err(dev, "Failed to map internal clock. Timestamping is not supported\n");
 			}
 		}
+
+		if (dev->caps.dmfs_high_steer_mode !=
+		    MLX4_STEERING_DMFS_A0_NOT_SUPPORTED) {
+			if (mlx4_validate_optimized_steering(dev))
+				mlx4_warn(dev, "Optimized steering validation failed\n");
+
+			if (dev->caps.dmfs_high_steer_mode ==
+			    MLX4_STEERING_DMFS_A0_DISABLE) {
+				dev->caps.dmfs_high_rate_qpn_base =
+					dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW];
+				dev->caps.dmfs_high_rate_qpn_range =
+					MLX4_A0_STEERING_TABLE_SIZE;
+			}
+
+			mlx4_dbg(dev, "DMFS high rate steer mode is: %s\n",
+				 dmfs_high_rate_steering_mode_str(
+					dev->caps.dmfs_high_steer_mode));
+		}
 	} else {
 		err = mlx4_init_slave(dev);
 		if (err) {
@@ -3201,10 +3314,11 @@ static int __init mlx4_verify_params(void)
 		port_type_array[0] = true;
 	}
 
-	if (mlx4_log_num_mgm_entry_size != -1 &&
-	    (mlx4_log_num_mgm_entry_size < MLX4_MIN_MGM_LOG_ENTRY_SIZE ||
-	     mlx4_log_num_mgm_entry_size > MLX4_MAX_MGM_LOG_ENTRY_SIZE)) {
-		pr_warn("mlx4_core: mlx4_log_num_mgm_entry_size (%d) not in legal range (-1 or %d..%d)\n",
+	if (mlx4_log_num_mgm_entry_size < -7 ||
+	    (mlx4_log_num_mgm_entry_size > 0 &&
+	     (mlx4_log_num_mgm_entry_size < MLX4_MIN_MGM_LOG_ENTRY_SIZE ||
+	      mlx4_log_num_mgm_entry_size > MLX4_MAX_MGM_LOG_ENTRY_SIZE))) {
+		pr_warn("mlx4_core: mlx4_log_num_mgm_entry_size (%d) not in legal range (-7..0 or %d..%d)\n",
 			mlx4_log_num_mgm_entry_size,
 			MLX4_MIN_MGM_LOG_ENTRY_SIZE,
 			MLX4_MAX_MGM_LOG_ENTRY_SIZE);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index cebd118..bdd4eea 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -689,8 +689,6 @@ enum mlx4_qp_table_zones {
 	MLX4_QP_TABLE_ZONE_NUM
 };
 
-#define MLX4_A0_STEERING_TABLE_SIZE    256
-
 struct mlx4_qp_table {
 	struct mlx4_bitmap	*bitmap_gen;
 	struct mlx4_zone_allocator *zones;
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index d8d040c..1586ecc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -712,8 +712,8 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 	int k;
 	int fixed_reserved_from_bot_rv = 0;
 	int bottom_reserved_for_rss_bitmap;
-	u32 max_table_offset = dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW] +
-		MLX4_A0_STEERING_TABLE_SIZE;
+	u32 max_table_offset = dev->caps.dmfs_high_rate_qpn_base +
+			dev->caps.dmfs_high_rate_qpn_range;
 
 	spin_lock_init(&qp_table->lock);
 	INIT_RADIX_TREE(&dev->qp_table_tree, GFP_ATOMIC);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 39890cd..25c791e 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -117,6 +117,14 @@ enum {
 	MLX4_STEERING_MODE_DEVICE_MANAGED
 };
 
+enum {
+	MLX4_STEERING_DMFS_A0_DEFAULT,
+	MLX4_STEERING_DMFS_A0_DYNAMIC,
+	MLX4_STEERING_DMFS_A0_STATIC,
+	MLX4_STEERING_DMFS_A0_DISABLE,
+	MLX4_STEERING_DMFS_A0_NOT_SUPPORTED
+};
+
 static inline const char *mlx4_steering_mode_str(int steering_mode)
 {
 	switch (steering_mode) {
@@ -191,7 +199,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_ETH_BACKPL_AN_REP	= 1LL <<  15,
 	MLX4_DEV_CAP_FLAG2_CONFIG_DEV		= 1LL <<  16,
 	MLX4_DEV_CAP_FLAG2_SYS_EQS		= 1LL <<  17,
-	MLX4_DEV_CAP_FLAG2_80_VFS		= 1LL <<  18
+	MLX4_DEV_CAP_FLAG2_80_VFS		= 1LL <<  18,
+	MLX4_DEV_CAP_FLAG2_FS_A0		= 1LL <<  19
 };
 
 enum {
@@ -225,7 +234,8 @@ enum {
 
 enum {
 	MLX4_FUNC_CAP_64B_EQE_CQE	= 1L << 0,
-	MLX4_FUNC_CAP_EQE_CQE_STRIDE	= 1L << 1
+	MLX4_FUNC_CAP_EQE_CQE_STRIDE	= 1L << 1,
+	MLX4_FUNC_CAP_DMFS_A0_STATIC	= 1L << 2
 };
 
 
@@ -482,6 +492,7 @@ struct mlx4_caps {
 	int			reserved_mcgs;
 	int			num_qp_per_mgm;
 	int			steering_mode;
+	int			dmfs_high_steer_mode;
 	int			fs_log_max_ucast_qp_range_size;
 	int			num_pds;
 	int			reserved_pds;
@@ -522,6 +533,8 @@ struct mlx4_caps {
 	int			tunnel_offload_mode;
 	u8			rx_checksum_flags_port[MLX4_MAX_PORTS + 1];
 	u8			alloc_res_qp_mask;
+	u32			dmfs_high_rate_qpn_base;
+	u32			dmfs_high_rate_qpn_range;
 };
 
 struct mlx4_buf_list {
-- 
1.7.1
