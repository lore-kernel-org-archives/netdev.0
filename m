From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/6] net/mlx4: Add VF MAC spoof checking support
Date: Wed, 24 Apr 2013 19:41:13 +0300
Message-ID: <1366821674-17902-6-git-send-email-ogerlitz@mellanox.com>
References: <1366821674-17902-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:54054 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757096Ab3DXQlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 12:41:22 -0400
In-Reply-To: <1366821674-17902-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Add ndo_set_vf_spoofchk support

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   41 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    9 ++++
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    5 ++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    8 ++++
 include/linux/mlx4/cmd.h                           |    1 +
 include/linux/mlx4/device.h                        |    3 +-
 6 files changed, 65 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index e394180..993b51d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1514,6 +1514,21 @@ static int mlx4_master_activate_admin_state(struct mlx4_priv *priv, int slave)
 				 (int)(vp_oper->state.default_vlan),
 				 vp_oper->vlan_idx, slave, port);
 		}
+		if (vp_admin->spoofchk) {
+			vp_oper->mac_idx = __mlx4_register_mac(&priv->dev,
+							       port,
+							       vp_admin->mac);
+			if (0 > vp_oper->mac_idx) {
+				err = vp_oper->mac_idx;
+				vp_oper->mac_idx = NO_INDX;
+				mlx4_warn((&priv->dev),
+					  "No mac resorces slave %d, port %d\n",
+					  slave, port);
+				return err;
+			}
+			mlx4_dbg((&(priv->dev)), "alloc mac %llx idx  %d slave %d port %d\n",
+				 vp_oper->state.mac, vp_oper->mac_idx, slave, port);
+		}
 	}
 	return 0;
 }
@@ -1530,6 +1545,10 @@ static void mlx4_master_deactivate_admin_state(struct mlx4_priv *priv, int slave
 					       port, vp_oper->vlan_idx);
 			vp_oper->vlan_idx = NO_INDX;
 		}
+		if (NO_INDX != vp_oper->mac_idx) {
+			__mlx4_unregister_mac(&priv->dev, port, vp_oper->mac_idx);
+			vp_oper->mac_idx = NO_INDX;
+		}
 	}
 	return;
 }
@@ -2085,6 +2104,28 @@ int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac)
 }
 EXPORT_SYMBOL_GPL(mlx4_set_vf_mac);
 
+int mlx4_set_vf_spoofchk(struct mlx4_dev *dev, int port, int vf, bool setting)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_vport_state *s_info;
+	int slave;
+
+	if ((!mlx4_is_master(dev)) ||
+	    !(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_FSM))
+		return -EPROTONOSUPPORT;
+
+	slave = mlx4_get_slave_indx(dev, vf);
+	if (slave < 0)
+		return -EINVAL;
+
+	s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
+	s_info->spoofchk = setting;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx4_set_vf_spoofchk);
+
+
 int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b00c118..9db9925 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1953,6 +1953,14 @@ static int mlx4_en_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos)
 	return mlx4_set_vf_vlan(mdev->dev, en_priv->port, vf, vlan, qos);
 }
 
+static int mlx4_en_set_vf_spoofchk(struct net_device *dev, int vf, bool setting)
+{
+	struct mlx4_en_priv *en_priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = en_priv->mdev;
+
+	return mlx4_set_vf_spoofchk(mdev->dev, en_priv->port, vf, setting);
+}
+
 
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
@@ -1992,6 +2000,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_vlan_rx_kill_vid	= mlx4_en_vlan_rx_kill_vid,
 	.ndo_set_vf_mac		= mlx4_en_set_vf_mac,
 	.ndo_set_vf_vlan	= mlx4_en_set_vf_vlan,
+	.ndo_set_vf_spoofchk	= mlx4_en_set_vf_spoofchk,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= mlx4_en_netpoll,
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 1a9abf0..a237584 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -131,7 +131,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[2] = "RSS XOR Hash Function support",
 		[3] = "Device manage flow steering support",
 		[4] = "Automatic mac reassignment support",
-		[5] = "VST (control vlan insertion/stripping) support"
+		[5] = "VST (control vlan insertion/stripping) support",
+		[6] = "FSM (MAC unti-spoofing) support"
 	};
 	int i;
 
@@ -655,6 +656,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(field32, outbox, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
 	if (field32 & (1 << 26))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_VLAN_CONTROL;
+	if (field32 & (1 << 20))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_FSM;
 
 	if (dev->flags & MLX4_FLAG_OLD_PORT_CMDS) {
 		for (i = 1; i <= dev_cap->num_ports; ++i) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 5083d4b..e12e0d2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -383,6 +383,14 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 			 vp_oper->vlan_idx, (int)(qpc->pri_path.feup),
 			 (int)(qpc->pri_path.fl));
 	}
+	if (vp_oper->state.spoofchk) {
+		qpc->pri_path.feup |= 1 << 5; /* set fsm bit */;
+		qpc->pri_path.grh_mylmc = (0x80 & qpc->pri_path.grh_mylmc) + vp_oper->mac_idx;
+		mlx4_dbg(dev, "spoof qp %d  port %d feup  0x%x, myLmc 0x%x mindx %d\n",
+			 be32_to_cpu(qpc->local_qpn) & 0xffffff, port,
+			 (int)qpc->pri_path.feup, (int)qpc->pri_path.grh_mylmc,
+			 vp_oper->mac_idx);
+	}
 	return 0;
 }
 
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 7daead7..95c3223 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -234,6 +234,7 @@ void mlx4_free_cmd_mailbox(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbo
 u32 mlx4_comm_get_version(void);
 int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac);
 int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos);
+int mlx4_set_vf_spoofchk(struct mlx4_dev *dev, int port, int vf, bool setting);
 
 
 #define MLX4_COMM_GET_IF_REV(cmd_chan_ver) (u8)((cmd_chan_ver) >> 8)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 2c4bc75..af5554d 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -153,7 +153,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_RSS_XOR		= 1LL <<  2,
 	MLX4_DEV_CAP_FLAG2_FS_EN		= 1LL <<  3,
 	MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN	= 1LL <<  4,
-	MLX4_DEV_CAP_FLAG2_VLAN_CONTROL		= 1LL <<  5
+	MLX4_DEV_CAP_FLAG2_VLAN_CONTROL		= 1LL <<  5,
+	MLX4_DEV_CAP_FLAG2_FSM			= 1LL <<  6,
 };
 
 enum {
-- 
1.7.1
