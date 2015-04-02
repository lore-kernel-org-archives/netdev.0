From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 15/18] net/mlx4_en: Add interface identify support
Date: Thu,  2 Apr 2015 16:31:20 +0300
Message-ID: <1427981483-19317-16-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45699 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752660AbbDBNcC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:02 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Add support for the interface ethtool identify feature.

Make the physical port LED to blink with green and yellow colors.

The device handles the LED blink by itself (synchrous use of
set_phys_id), by returning 0 to ETHTOOL_ID_ACTIVE command.

Signed-off-by: Eyal Grossman <eyalgr@mellanox.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   27 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c         |   10 ++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    1 +
 drivers/net/ethernet/mellanox/mlx4/port.c       |   26 ++++++++++++++++++++++
 include/linux/mlx4/cmd.h                        |    1 +
 include/linux/mlx4/device.h                     |    2 +
 6 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index eba969b..3f44e2b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1939,6 +1939,32 @@ static int mlx4_en_get_module_eeprom(struct net_device *dev,
 	return 0;
 }
 
+static int mlx4_en_set_phys_id(struct net_device *dev,
+			       enum ethtool_phys_id_state state)
+{
+	int err;
+	u16 beacon_duration;
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+
+	if (!(mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PORT_BEACON))
+		return -EOPNOTSUPP;
+
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		beacon_duration = PORT_BEACON_MAX_LIMIT;
+		break;
+	case ETHTOOL_ID_INACTIVE:
+		beacon_duration = 0;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	err = mlx4_SET_PORT_BEACON(mdev->dev, priv->port, beacon_duration);
+	return err;
+}
+
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
 	.get_settings = mlx4_en_get_settings,
@@ -1948,6 +1974,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_sset_count = mlx4_en_get_sset_count,
 	.get_ethtool_stats = mlx4_en_get_ethtool_stats,
 	.self_test = mlx4_en_self_test,
+	.set_phys_id = mlx4_en_set_phys_id,
 	.get_wol = mlx4_en_get_wol,
 	.set_wol = mlx4_en_set_wol,
 	.get_msglevel = mlx4_en_get_msglevel,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index b93e23b..6317844 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -150,6 +150,7 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[24] = "Ethernet Flow control statistics support",
 		[25] = "Granular QoS per VF support",
 		[26] = "Port ETS Scheduler support",
+		[27] = "Port beacon support",
 	};
 	int i;
 
@@ -647,6 +648,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_RSS_OFFSET		0x2e
 #define QUERY_DEV_CAP_MAX_RDMA_OFFSET		0x2f
 #define QUERY_DEV_CAP_RSZ_SRQ_OFFSET		0x33
+#define QUERY_DEV_CAP_PORT_BEACON_OFFSET	0x34
 #define QUERY_DEV_CAP_ACK_DELAY_OFFSET		0x35
 #define QUERY_DEV_CAP_MTU_WIDTH_OFFSET		0x36
 #define QUERY_DEV_CAP_VL_PORT_OFFSET		0x37
@@ -786,6 +788,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	if (field & 0x80)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_FS_EN;
 	dev_cap->fs_log_max_ucast_qp_range_size = field & 0x1f;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_PORT_BEACON_OFFSET);
+	if (field & 0x80)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_PORT_BEACON;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_FLOW_STEERING_IPOIB_OFFSET);
 	if (field & 0x80)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_DMFS_IPOIB;
@@ -1165,6 +1170,11 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	field &= 0xd7;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_VXLAN);
 
+	/* For guests, disable port BEACON */
+	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_PORT_BEACON_OFFSET);
+	field &= 0x7f;
+	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_PORT_BEACON_OFFSET);
+
 	/* For guests, report Blueflame disabled */
 	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_BF_OFFSET);
 	field &= 0x7f;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 67eeea2..9de3021 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -482,6 +482,7 @@ enum {
 	MLX4_EN_FLAG_RX_CSUM_NON_TCP_UDP	= (1 << 5),
 };
 
+#define PORT_BEACON_MAX_LIMIT (65535)
 #define MLX4_EN_MAC_HASH_SIZE (1 << BITS_PER_BYTE)
 #define MLX4_EN_MAC_HASH_IDX 5
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index ca4488e..e8d716d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -835,6 +835,12 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 				MLX4_CMD_NATIVE);
 	}
 
+	/* Slaves are not allowed to SET_PORT beacon (LED) blink */
+	if (op_mod == MLX4_SET_PORT_BEACON_OPCODE) {
+		mlx4_warn(dev, "denying SET_PORT Beacon slave:%d\n", slave);
+		return -EPERM;
+	}
+
 	/* For IB, we only consider:
 	 * - The capability mask, which is set to the aggregate of all
 	 *   slave function capabilities
@@ -1064,6 +1070,26 @@ int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering, int enable)
 }
 EXPORT_SYMBOL(mlx4_SET_PORT_VXLAN);
 
+int mlx4_SET_PORT_BEACON(struct mlx4_dev *dev, u8 port, u16 time)
+{
+	int err;
+	struct mlx4_cmd_mailbox *mailbox;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	*((__be32 *)mailbox->buf) = cpu_to_be32(time);
+
+	err = mlx4_cmd(dev, mailbox->dma, port, MLX4_SET_PORT_BEACON_OPCODE,
+		       MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+		       MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_BEACON);
+
 int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_vhcr *vhcr,
 				struct mlx4_cmd_mailbox *inbox,
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 62c4d4d..f62e7cf 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -191,6 +191,7 @@ enum {
 	/* Set port opcode modifiers */
 	MLX4_SET_PORT_IB_OPCODE		= 0x0,
 	MLX4_SET_PORT_ETH_OPCODE	= 0x1,
+	MLX4_SET_PORT_BEACON_OPCODE	= 0x4,
 };
 
 enum {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 15f4676..b761be7 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -208,6 +208,7 @@ enum {
 	MLX4_DEV_CAP_FLAG2_FLOWSTATS_EN         = 1LL <<  24,
 	MLX4_DEV_CAP_FLAG2_QOS_VPP		= 1LL <<  25,
 	MLX4_DEV_CAP_FLAG2_ETS_CFG		= 1LL <<  26,
+	MLX4_DEV_CAP_FLAG2_PORT_BEACON		= 1LL <<  27,
 };
 
 enum {
@@ -1311,6 +1312,7 @@ int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
 int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 			   u8 promisc);
+int mlx4_SET_PORT_BEACON(struct mlx4_dev *dev, u8 port, u16 time);
 int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering, int enable);
 int mlx4_find_cached_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *idx);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
-- 
1.7.1
