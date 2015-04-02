From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 09/18] net/mlx4: Allocate VPPs for each port on PF init
Date: Thu,  2 Apr 2015 16:31:14 +0300
Message-ID: <1427981483-19317-10-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45763 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753042AbbDBNcV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:21 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Initialization of granular Qos per VF mechanism.

Query the port availible VPPs and allocates those on all supported
priorities in an equal share. Allocation is done only in SRIOV mode,
when the feature is supported by the device and port type is Ethernet.

Allocation currently is done only on the default priority 0.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c    |   66 +++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw_qos.h |    3 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h   |    7 +++
 3 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 23dc98e..1e4a929 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1883,6 +1883,63 @@ static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 	return 0;
 }
 
+static void mlx4_set_default_port_qos(struct mlx4_dev *dev, int port)
+{
+	struct mlx4_qos_manager *port_qos_ctl;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	port_qos_ctl = &priv->mfunc.master.qos_ctl[port];
+	bitmap_zero(port_qos_ctl->priority_bm, MLX4_NUM_UP);
+
+	/* Enable only default prio at PF init routine */
+	set_bit(MLX4_DEFAULT_QOS_PRIO, port_qos_ctl->priority_bm);
+}
+
+static void mlx4_allocate_port_vpps(struct mlx4_dev *dev, int port)
+{
+	int i;
+	int err;
+	int num_vfs;
+	u16 availible_vpp;
+	u8 vpp_param[MLX4_NUM_UP];
+	struct mlx4_qos_manager *port_qos;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	err = mlx4_ALLOCATE_VPP_get(dev, port, &availible_vpp, vpp_param);
+	if (err) {
+		mlx4_info(dev, "Failed query availible VPPs\n");
+		return;
+	}
+
+	port_qos = &priv->mfunc.master.qos_ctl[port];
+	num_vfs = (availible_vpp /
+		   bitmap_weight(port_qos->priority_bm, MLX4_NUM_UP));
+
+	for (i = 0; i < MLX4_NUM_UP; i++) {
+		if (test_bit(i, port_qos->priority_bm))
+			vpp_param[i] = num_vfs;
+	}
+
+	err = mlx4_ALLOCATE_VPP_set(dev, port, vpp_param);
+	if (err) {
+		mlx4_info(dev, "Failed allocating VPPs\n");
+		return;
+	}
+
+	/* Query actual allocated VPP, just to make sure */
+	err = mlx4_ALLOCATE_VPP_get(dev, port, &availible_vpp, vpp_param);
+	if (err) {
+		mlx4_info(dev, "Failed query availible VPPs\n");
+		return;
+	}
+
+	port_qos->num_of_qos_vfs = num_vfs;
+	mlx4_dbg(dev, "Port %d Availible VPPs %d\n", port, availible_vpp);
+
+	for (i = 0; i < MLX4_NUM_UP; i++)
+		mlx4_dbg(dev, "Port %d UP %d Allocated %d VPPs\n", port, i,
+			 vpp_param[i]);
+}
 
 static int mlx4_master_activate_admin_state(struct mlx4_priv *priv, int slave)
 {
@@ -2288,6 +2345,15 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 			spin_lock_init(&s_state->lock);
 		}
 
+		if (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_QOS_VPP) {
+			for (port = 1; port <= dev->caps.num_ports; port++) {
+				if (mlx4_is_eth(dev, port)) {
+					mlx4_set_default_port_qos(dev, port);
+					mlx4_allocate_port_vpps(dev, port);
+				}
+			}
+		}
+
 		memset(&priv->mfunc.master.cmd_eqe, 0, dev->caps.eqe_size);
 		priv->mfunc.master.cmd_eqe.type = MLX4_EVENT_TYPE_CMD;
 		INIT_WORK(&priv->mfunc.master.comm_work,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
index b3fffaf..4a5320f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw_qos.h
@@ -41,6 +41,9 @@
 #define MLX4_NUM_UP 8
 #define MLX4_NUM_TC 8
 
+/* Default supported priorities for VPP allocation */
+#define MLX4_DEFAULT_QOS_PRIO (0)
+
 struct mlx4_vport_qos_param {
 	u32 bw_share;
 	u32 max_avg_bw;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 9e5236b..1add698 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -50,6 +50,7 @@
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/doorbell.h>
 #include <linux/mlx4/cmd.h>
+#include "fw_qos.h"
 
 #define DRV_NAME	"mlx4_core"
 #define PFX		DRV_NAME ": "
@@ -553,6 +554,11 @@ struct mlx4_slave_event_eq {
 	struct mlx4_eqe event_eqe[SLAVE_EVENT_EQ_SIZE];
 };
 
+struct mlx4_qos_manager {
+	int num_of_qos_vfs;
+	DECLARE_BITMAP(priority_bm, MLX4_NUM_UP);
+};
+
 struct mlx4_master_qp0_state {
 	int proxy_qp0_active;
 	int qp0_active;
@@ -577,6 +583,7 @@ struct mlx4_mfunc_master_ctx {
 	struct mlx4_eqe		cmd_eqe;
 	struct mlx4_slave_event_eq slave_eq;
 	struct mutex		gen_eqe_mutex[MLX4_MFUNC_MAX];
+	struct mlx4_qos_manager qos_ctl[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_mfunc {
-- 
1.7.1
