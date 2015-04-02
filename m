From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 17/18] net/mlx4_en: Add RX-ALL support
Date: Thu,  2 Apr 2015 16:31:22 +0300
Message-ID: <1427981483-19317-18-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Muhammad Mahajna <muhammadm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45743 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752093AbbDBNcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:08 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Muhammad Mahajna <muhammadm@mellanox.com>

Enabled when the device supports KEEP FCS and IGNORE FCS.

When the flag is set, pass all received frames up the stack,
even ones with invalid FCS, controlled by ethtool.

Signed-off-by: Muhammad Mahajna <muhammadm@mellanox.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   14 ++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    8 +++++
 drivers/net/ethernet/mellanox/mlx4/main.c      |   21 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |    6 +++-
 drivers/net/ethernet/mellanox/mlx4/port.c      |   34 ++++++++++++++++++++++++
 include/linux/mlx4/device.h                    |    3 ++
 6 files changed, 84 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 2cf8af7..b13aa03 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2204,6 +2204,17 @@ static int mlx4_en_set_features(struct net_device *netdev,
 		reset = true;
 	}
 
+	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_RXALL)) {
+		u8 ignore_fcs_value = (features & NETIF_F_RXALL) ? 1 : 0;
+
+		en_info(priv, "Turn %s RX-ALL\n",
+			ignore_fcs_value ? "ON" : "OFF");
+		ret = mlx4_SET_PORT_fcs_check(priv->mdev->dev,
+					      priv->port, ignore_fcs_value);
+		if (ret)
+			return ret;
+	}
+
 	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_HW_VLAN_CTAG_RX)) {
 		en_info(priv, "Turn %s RX vlan strip offload\n",
 			(features & NETIF_F_HW_VLAN_CTAG_RX) ? "ON" : "OFF");
@@ -2914,6 +2925,9 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_FCS_KEEP)
 		dev->hw_features |= NETIF_F_RXFCS;
 
+	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_IGNORE_FCS)
+		dev->hw_features |= NETIF_F_RXALL;
+
 	if (mdev->dev->caps.steering_mode ==
 	    MLX4_STEERING_MODE_DEVICE_MANAGED &&
 	    mdev->dev->caps.dmfs_high_steer_mode != MLX4_STEERING_DMFS_A0_STATIC)
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 6317844..b9881fc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -151,6 +151,7 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[25] = "Granular QoS per VF support",
 		[26] = "Port ETS Scheduler support",
 		[27] = "Port beacon support",
+		[28] = "RX-ALL support",
 	};
 	int i;
 
@@ -893,6 +894,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_CONFIG_DEV_OFFSET);
 	if (field & 0x20)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_CONFIG_DEV;
+	if (field & (1 << 2))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_IGNORE_FCS;
 	MLX4_GET(dev_cap->reserved_lkey, outbox,
 		 QUERY_DEV_CAP_RSVD_LKEY_OFFSET);
 	MLX4_GET(field32, outbox, QUERY_DEV_CAP_ETH_BACKPL_OFFSET);
@@ -1220,6 +1223,11 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	field &= 0xef;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_CQ_EQ_CACHE_LINE_STRIDE);
 
+	/* turn off ignore FCS feature for guests */
+	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_CONFIG_DEV_OFFSET);
+	field &= 0xfb;
+	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_CONFIG_DEV_OFFSET);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 3becad3..acceb75 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -297,6 +297,25 @@ static int mlx4_dev_port(struct mlx4_dev *dev, int port,
 	return err;
 }
 
+static inline void mlx4_enable_ignore_fcs(struct mlx4_dev *dev)
+{
+	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_IGNORE_FCS))
+		return;
+
+	if (mlx4_is_mfunc(dev)) {
+		mlx4_dbg(dev, "SRIOV mode - Disabling Ignore FCS");
+		dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_IGNORE_FCS;
+		return;
+	}
+
+	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_FCS_KEEP)) {
+		mlx4_dbg(dev,
+			 "Keep FCS is not supported - Disabling Ignore FCS");
+		dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_IGNORE_FCS;
+		return;
+	}
+}
+
 #define MLX4_A0_STEERING_TABLE_SIZE	256
 static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 {
@@ -540,6 +559,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev->caps.alloc_res_qp_mask = 0;
 	}
 
+	mlx4_enable_ignore_fcs(dev);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 32469c6..f30eeb7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -763,9 +763,11 @@ enum {
 
 
 struct mlx4_set_port_general_context {
-	u8 reserved[3];
+	u16 reserved1;
+	u8 v_ignore_fcs;
 	u8 flags;
-	u16 reserved2;
+	u8 ignore_fcs;
+	u8 reserved2;
 	__be16 mtu;
 	u8 pptx;
 	u8 pfctx;
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index e8d716d..c2b2131 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -45,6 +45,14 @@
 #define MLX4_VLAN_VALID		(1u << 31)
 #define MLX4_VLAN_MASK		0xfff
 
+#define MLX4_STATS_TRAFFIC_COUNTERS_MASK	0xfULL
+#define MLX4_STATS_TRAFFIC_DROPS_MASK		0xc0ULL
+#define MLX4_STATS_ERROR_COUNTERS_MASK		0x1ffc30ULL
+#define MLX4_STATS_PORT_COUNTERS_MASK		0x1fe00000ULL
+
+#define MLX4_FLAG_V_IGNORE_FCS_MASK		0x2
+#define MLX4_IGNORE_FCS_MASK			0x1
+
 void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table)
 {
 	int i;
@@ -1027,6 +1035,32 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 }
 EXPORT_SYMBOL(mlx4_SET_PORT_qpn_calc);
 
+int mlx4_SET_PORT_fcs_check(struct mlx4_dev *dev, u8 port, u8 ignore_fcs_value)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_general_context *context;
+	u32 in_mod;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	context->v_ignore_fcs |= MLX4_FLAG_V_IGNORE_FCS_MASK;
+	if (ignore_fcs_value)
+		context->ignore_fcs |= MLX4_IGNORE_FCS_MASK;
+	else
+		context->ignore_fcs &= ~MLX4_IGNORE_FCS_MASK;
+
+	in_mod = MLX4_SET_PORT_GENERAL << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_fcs_check);
+
 enum {
 	VXLAN_ENABLE_MODIFY	= 1 << 7,
 	VXLAN_STEERING_MODIFY	= 1 << 6,
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b761be7..f9ce34b 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -209,6 +209,7 @@ enum {
 	MLX4_DEV_CAP_FLAG2_QOS_VPP		= 1LL <<  25,
 	MLX4_DEV_CAP_FLAG2_ETS_CFG		= 1LL <<  26,
 	MLX4_DEV_CAP_FLAG2_PORT_BEACON		= 1LL <<  27,
+	MLX4_DEV_CAP_FLAG2_IGNORE_FCS		= 1LL <<  28,
 };
 
 enum {
@@ -1313,6 +1314,8 @@ int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 			   u8 promisc);
 int mlx4_SET_PORT_BEACON(struct mlx4_dev *dev, u8 port, u16 time);
+int mlx4_SET_PORT_fcs_check(struct mlx4_dev *dev, u8 port,
+			    u8 ignore_fcs_value);
 int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering, int enable);
 int mlx4_find_cached_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *idx);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
-- 
1.7.1
