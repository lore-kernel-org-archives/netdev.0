From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 11/18] net/mlx4_en: Enable TX rate limit per VF
Date: Thu,  2 Apr 2015 16:31:16 +0300
Message-ID: <1427981483-19317-12-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45694 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751780AbbDBNcC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:02 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Support granular QoS per VF, by implementing the ndo_set_vf_rate.

Enforce a rate limit per VF when called, and enabled only for VFs in
VST mode with user priority supported by the device.

We don't enforce VFs to be in VST mode at the moment of configuration,
but rather save the given rate limit and enforce it when the VF is
moved to VST with user priority which is supported (currently 0).

VST<->VGT or VST qos value state changes are disallowed when a rate
limit is configured. Minimum BW share is not supported yet.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c       |  177 +++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   11 ++
 include/linux/mlx4/cmd.h                       |    2 +
 3 files changed, 189 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index ea8947a..bfc3584 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2781,6 +2781,103 @@ static int mlx4_slaves_closest_port(struct mlx4_dev *dev, int slave, int port)
 	return port;
 }
 
+static int mlx4_set_vport_qos(struct mlx4_priv *priv, int slave, int port,
+			      int max_tx_rate)
+{
+	int i;
+	int err;
+	struct mlx4_qos_manager *port_qos;
+	struct mlx4_dev *dev = &priv->dev;
+	struct mlx4_vport_qos_param vpp_qos[MLX4_NUM_UP];
+
+	port_qos = &priv->mfunc.master.qos_ctl[port];
+	memset(vpp_qos, 0, sizeof(struct mlx4_vport_qos_param) * MLX4_NUM_UP);
+
+	if (slave > port_qos->num_of_qos_vfs) {
+		mlx4_info(dev, "No availible VPP resources for this VF\n");
+		return -EINVAL;
+	}
+
+	/* Query for default QoS values from Vport 0 is needed */
+	err = mlx4_SET_VPORT_QOS_get(dev, port, 0, vpp_qos);
+	if (err) {
+		mlx4_info(dev, "Failed to query Vport 0 QoS values\n");
+		return err;
+	}
+
+	for (i = 0; i < MLX4_NUM_UP; i++) {
+		if (test_bit(i, port_qos->priority_bm) && max_tx_rate) {
+			vpp_qos[i].max_avg_bw = max_tx_rate;
+			vpp_qos[i].enable = 1;
+		} else {
+			/* if user supplied tx_rate == 0, meaning no rate limit
+			 * configuration is required. so we are leaving the
+			 * value of max_avg_bw as queried from Vport 0.
+			 */
+			vpp_qos[i].enable = 0;
+		}
+	}
+
+	err = mlx4_SET_VPORT_QOS_set(dev, port, slave, vpp_qos);
+	if (err) {
+		mlx4_info(dev, "Failed to set Vport %d QoS values\n", slave);
+		return err;
+	}
+
+	return 0;
+}
+
+static bool mlx4_is_vf_vst_and_prio_qos(struct mlx4_dev *dev, int port,
+					struct mlx4_vport_state *vf_admin)
+{
+	struct mlx4_qos_manager *info;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	if (!mlx4_is_master(dev) ||
+	    !(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_QOS_VPP))
+		return false;
+
+	info = &priv->mfunc.master.qos_ctl[port];
+
+	if (vf_admin->default_vlan != MLX4_VGT &&
+	    test_bit(vf_admin->default_qos, info->priority_bm))
+		return true;
+
+	return false;
+}
+
+static bool mlx4_valid_vf_state_change(struct mlx4_dev *dev, int port,
+				       struct mlx4_vport_state *vf_admin,
+				       int vlan, int qos)
+{
+	struct mlx4_vport_state dummy_admin = {0};
+
+	if (!mlx4_is_vf_vst_and_prio_qos(dev, port, vf_admin) ||
+	    !vf_admin->tx_rate)
+		return true;
+
+	dummy_admin.default_qos = qos;
+	dummy_admin.default_vlan = vlan;
+
+	/* VF wants to move to other VST state which is valid with current
+	 * rate limit. Either differnt default vlan in VST or other
+	 * supported QoS priority. Otherwise we don't allow this change when
+	 * the TX rate is still configured.
+	 */
+	if (mlx4_is_vf_vst_and_prio_qos(dev, port, &dummy_admin))
+		return true;
+
+	mlx4_info(dev, "Cannot change VF state to %s while rate is set\n",
+		  (vlan == MLX4_VGT) ? "VGT" : "VST");
+
+	if (vlan != MLX4_VGT)
+		mlx4_info(dev, "VST priority %d not supported for QoS\n", qos);
+
+	mlx4_info(dev, "Please set rate to 0 prior to this VF state change\n");
+
+	return false;
+}
+
 int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -2824,12 +2921,22 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 	port = mlx4_slaves_closest_port(dev, slave, port);
 	vf_admin = &priv->mfunc.master.vf_admin[slave].vport[port];
 
+	if (!mlx4_valid_vf_state_change(dev, port, vf_admin, vlan, qos))
+		return -EPERM;
+
 	if ((0 == vlan) && (0 == qos))
 		vf_admin->default_vlan = MLX4_VGT;
 	else
 		vf_admin->default_vlan = vlan;
 	vf_admin->default_qos = qos;
 
+	/* If rate was configured prior to VST, we saved the configured rate
+	 * in vf_admin->rate and now, if priority supported we enforce the QoS
+	 */
+	if (mlx4_is_vf_vst_and_prio_qos(dev, port, vf_admin) &&
+	    vf_admin->tx_rate)
+		vf_admin->qos_vport = slave;
+
 	if (mlx4_master_immediate_activate_vlan_qos(priv, slave, port))
 		mlx4_info(dev,
 			  "updating vf %d port %d config will take effect on next VF restart\n",
@@ -2838,6 +2945,69 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos)
 }
 EXPORT_SYMBOL_GPL(mlx4_set_vf_vlan);
 
+int mlx4_set_vf_rate(struct mlx4_dev *dev, int port, int vf, int min_tx_rate,
+		     int max_tx_rate)
+{
+	int err;
+	int slave;
+	struct mlx4_vport_state *vf_admin;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	if (!mlx4_is_master(dev) ||
+	    !(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_QOS_VPP))
+		return -EPROTONOSUPPORT;
+
+	if (min_tx_rate) {
+		mlx4_info(dev, "Minimum BW share not supported\n");
+		return -EPROTONOSUPPORT;
+	}
+
+	slave = mlx4_get_slave_indx(dev, vf);
+	if (slave < 0)
+		return -EINVAL;
+
+	port = mlx4_slaves_closest_port(dev, slave, port);
+	vf_admin = &priv->mfunc.master.vf_admin[slave].vport[port];
+
+	err = mlx4_set_vport_qos(priv, slave, port, max_tx_rate);
+	if (err) {
+		mlx4_info(dev, "vf %d failed to set rate %d\n", vf,
+			  max_tx_rate);
+		return err;
+	}
+
+	vf_admin->tx_rate = max_tx_rate;
+	/* if VF is not in supported mode (VST with supported prio),
+	 * we do not change vport configuration for its QPs, but save
+	 * the rate, so it will be enforced when it moves to supported
+	 * mode next time.
+	 */
+	if (!mlx4_is_vf_vst_and_prio_qos(dev, port, vf_admin)) {
+		mlx4_info(dev,
+			  "rate set for VF %d when not in valid state\n", vf);
+
+		if (vf_admin->default_vlan != MLX4_VGT)
+			mlx4_info(dev, "VST priority not supported by QoS\n");
+		else
+			mlx4_info(dev, "VF in VGT mode (needed VST)\n");
+
+		mlx4_info(dev,
+			  "rate %d take affect when VF moves to valid state\n",
+			  max_tx_rate);
+		return 0;
+	}
+
+	/* If user sets rate 0 assigning default vport for its QPs */
+	vf_admin->qos_vport = max_tx_rate ? slave : MLX4_VPP_DEFAULT_VPORT;
+
+	if (priv->mfunc.master.slave_state[slave].active &&
+	    dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_UPDATE_QP)
+		mlx4_master_immediate_activate_vlan_qos(priv, slave, port);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx4_set_vf_rate);
+
  /* mlx4_get_slave_default_vlan -
  * return true if VST ( default vlan)
  * if VST, will return vlan & qos (if not NULL)
@@ -2911,7 +3081,12 @@ int mlx4_get_vf_config(struct mlx4_dev *dev, int port, int vf, struct ifla_vf_in
 
 	ivf->vlan		= s_info->default_vlan;
 	ivf->qos		= s_info->default_qos;
-	ivf->max_tx_rate	= s_info->tx_rate;
+
+	if (mlx4_is_vf_vst_and_prio_qos(dev, port, s_info))
+		ivf->max_tx_rate = s_info->tx_rate;
+	else
+		ivf->max_tx_rate = 0;
+
 	ivf->min_tx_rate	= 0;
 	ivf->spoofchk		= s_info->spoofchk;
 	ivf->linkstate		= s_info->link_state;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4ee564c..0fd5ec9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2240,6 +2240,16 @@ static int mlx4_en_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos)
 	return mlx4_set_vf_vlan(mdev->dev, en_priv->port, vf, vlan, qos);
 }
 
+static int mlx4_en_set_vf_rate(struct net_device *dev, int vf, int min_tx_rate,
+			       int max_tx_rate)
+{
+	struct mlx4_en_priv *en_priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = en_priv->mdev;
+
+	return mlx4_set_vf_rate(mdev->dev, en_priv->port, vf, min_tx_rate,
+				max_tx_rate);
+}
+
 static int mlx4_en_set_vf_spoofchk(struct net_device *dev, int vf, bool setting)
 {
 	struct mlx4_en_priv *en_priv = netdev_priv(dev);
@@ -2458,6 +2468,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_vlan_rx_kill_vid	= mlx4_en_vlan_rx_kill_vid,
 	.ndo_set_vf_mac		= mlx4_en_set_vf_mac,
 	.ndo_set_vf_vlan	= mlx4_en_set_vf_vlan,
+	.ndo_set_vf_rate	= mlx4_en_set_vf_rate,
 	.ndo_set_vf_spoofchk	= mlx4_en_set_vf_spoofchk,
 	.ndo_set_vf_link_state	= mlx4_en_set_vf_link_state,
 	.ndo_get_vf_config	= mlx4_en_get_vf_config,
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 88326ed..a788839 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -296,6 +296,8 @@ void mlx4_free_cmd_mailbox(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbo
 u32 mlx4_comm_get_version(void);
 int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac);
 int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos);
+int mlx4_set_vf_rate(struct mlx4_dev *dev, int port, int vf, int min_tx_rate,
+		     int max_tx_rate);
 int mlx4_set_vf_spoofchk(struct mlx4_dev *dev, int port, int vf, bool setting);
 int mlx4_get_vf_config(struct mlx4_dev *dev, int port, int vf, struct ifla_vf_info *ivf);
 int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_state);
-- 
1.7.1
