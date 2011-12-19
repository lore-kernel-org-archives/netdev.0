From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 1/5] mlx4: capability for link sensing
Date: Mon, 19 Dec 2011 16:00:26 +0200
Message-ID: <4EEF437A.3040004@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:38108 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752398Ab1LSQMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 11:12:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

For ConnectX3 devices, we allow link sensing only if FW explicitly
reported it supports the feature.
For older versions (ConnectX1 and 2), if the card supports both link layer types
(Ethenet and Infiniband), link sensing is supported.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   10 ++++++++--
 include/linux/mlx4/device.h               |    3 ++-
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index b969bfb..8f73143 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -274,6 +274,10 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.stat_rate_support  = dev_cap->stat_rate_support;
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 
+	/* Sense port always allowed on supported devices for ConnectX1 and 2 */
+	if (dev->pdev->device != 0x1003)
+		dev->caps.flags |= MLX4_DEV_CAP_FLAG_SENSE_SUPPORT;
+
 	dev->caps.log_num_macs  = log_num_mac;
 	dev->caps.log_num_vlans = MLX4_LOG_NUM_VLANS;
 	dev->caps.log_num_prios = use_prio ? 3 : 0;
@@ -311,7 +315,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		}
 		dev->caps.possible_type[i] = dev->caps.port_type[i];
 		mlx4_priv(dev)->sense.sense_allowed[i] =
-			dev->caps.supported_type[i] == MLX4_PORT_TYPE_AUTO;
+			((dev->caps.supported_type[i] == MLX4_PORT_TYPE_AUTO) &&
+			 (dev->caps.flags & MLX4_DEV_CAP_FLAG_SENSE_SUPPORT));
 
 		if (dev->caps.log_num_macs > dev_cap->log_max_macs[i]) {
 			dev->caps.log_num_macs = dev_cap->log_max_macs[i];
@@ -583,7 +588,8 @@ static ssize_t set_port_type(struct device *dev,
 			types[i] = mdev->caps.port_type[i+1];
 	}
 
-	if (!(mdev->caps.flags & MLX4_DEV_CAP_FLAG_DPDP)) {
+	if (!(mdev->caps.flags & MLX4_DEV_CAP_FLAG_DPDP) &&
+	    !(mdev->caps.flags & MLX4_DEV_CAP_FLAG_SENSE_SUPPORT)) {
 		for (i = 1; i <= mdev->caps.num_ports; i++) {
 			if (mdev->caps.possible_type[i] == MLX4_PORT_TYPE_AUTO) {
 				mdev->caps.possible_type[i] = mdev->caps.port_type[i];
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 5f784ff..b06a44b 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -94,7 +94,8 @@ enum {
 	MLX4_DEV_CAP_FLAG_UDP_RSS	= 1LL << 40,
 	MLX4_DEV_CAP_FLAG_VEP_UC_STEER	= 1LL << 41,
 	MLX4_DEV_CAP_FLAG_VEP_MC_STEER	= 1LL << 42,
-	MLX4_DEV_CAP_FLAG_COUNTERS	= 1LL << 48
+	MLX4_DEV_CAP_FLAG_COUNTERS	= 1LL << 48,
+	MLX4_DEV_CAP_FLAG_SENSE_SUPPORT	= 1LL << 55
 };
 
 #define MLX4_ATTR_EXTENDED_PORT_INFO	cpu_to_be16(0xff90)
-- 
1.7.7
