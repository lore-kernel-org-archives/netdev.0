From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/4] net/mlx4_core: Use low memory profile on kdump kernel
Date: Tue, 22 Jul 2014 15:44:11 +0300
Message-ID: <1406033052-16550-4-git-send-email-amirv@mellanox.com>
References: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:58662 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753212AbaGVMpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 08:45:00 -0400
In-Reply-To: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in kdump kernel, reduce number of resources allocated for
the hardware. This will enable the NIC to operate in this low memory
environment at the expense of performance and some features not related
to the basic NIC functionality.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 28 +++++++++++++++++++++++++---
 include/linux/mlx4/device.h               |  7 +++++++
 2 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 82ab427..80b8c5f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -120,6 +120,16 @@ static struct mlx4_profile default_profile = {
 	.num_mtt	= 1 << 20, /* It is really num mtt segements */
 };
 
+static struct mlx4_profile low_mem_profile = {
+	.num_qp		= 1 << 17,
+	.num_srq	= 1 << 6,
+	.rdmarc_per_qp	= 1 << 4,
+	.num_cq		= 1 << 8,
+	.num_mcg	= 1 << 8,
+	.num_mpt	= 1 << 9,
+	.num_mtt	= 1 << 7,
+};
+
 static int log_num_mac = 7;
 module_param_named(log_num_mac, log_num_mac, int, 0444);
 MODULE_PARM_DESC(log_num_mac, "Log2 max number of MACs per ETH port (1-7)");
@@ -129,6 +139,8 @@ module_param_named(log_num_vlan, log_num_vlan, int, 0444);
 MODULE_PARM_DESC(log_num_vlan, "Log2 max number of VLANs per ETH port (0-7)");
 /* Log2 max number of VLANs per ETH port (0-7) */
 #define MLX4_LOG_NUM_VLANS 7
+#define MLX4_MIN_LOG_NUM_VLANS 0
+#define MLX4_MIN_LOG_NUM_MAC 1
 
 static bool use_prio;
 module_param_named(use_prio, use_prio, bool, 0444);
@@ -287,8 +299,13 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	if (mlx4_is_mfunc(dev))
 		dev->caps.flags &= ~MLX4_DEV_CAP_FLAG_SENSE_SUPPORT;
 
-	dev->caps.log_num_macs  = log_num_mac;
-	dev->caps.log_num_vlans = MLX4_LOG_NUM_VLANS;
+	if (mlx4_low_memory_profile()) {
+		dev->caps.log_num_macs  = MLX4_MIN_LOG_NUM_MAC;
+		dev->caps.log_num_vlans = MLX4_MIN_LOG_NUM_VLANS;
+	} else {
+		dev->caps.log_num_macs  = log_num_mac;
+		dev->caps.log_num_vlans = MLX4_LOG_NUM_VLANS;
+	}
 
 	for (i = 1; i <= dev->caps.num_ports; ++i) {
 		dev->caps.port_type[i] = MLX4_PORT_TYPE_NONE;
@@ -1587,7 +1604,12 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		if (mlx4_is_master(dev))
 			mlx4_parav_master_pf_caps(dev);
 
-		profile = default_profile;
+		if (mlx4_low_memory_profile()) {
+			mlx4_info(dev, "Running from within kdump kernel. Using low memory profile\n");
+			profile = low_mem_profile;
+		} else {
+			profile = default_profile;
+		}
 		if (dev->caps.steering_mode ==
 		    MLX4_STEERING_MODE_DEVICE_MANAGED)
 			profile.num_mcg = MLX4_FS_NUM_MCG;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index fa660ae..e15b154 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1254,4 +1254,11 @@ int mlx4_vf_smi_enabled(struct mlx4_dev *dev, int slave, int port);
 int mlx4_vf_get_enable_smi_admin(struct mlx4_dev *dev, int slave, int port);
 int mlx4_vf_set_enable_smi_admin(struct mlx4_dev *dev, int slave, int port,
 				 int enable);
+
+/* Returns true if running in low memory profile (kdump kernel) */
+static inline bool mlx4_low_memory_profile(void)
+{
+	return reset_devices;
+}
+
 #endif /* MLX4_DEVICE_H */
-- 
1.8.3.4
