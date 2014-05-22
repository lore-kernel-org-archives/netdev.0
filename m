From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 1/2] net/mlx4_core: Deprecate use_prio module parameter
Date: Thu, 22 May 2014 15:55:39 +0300
Message-ID: <1400763340-15028-2-git-send-email-amirv@mellanox.com>
References: <1400763340-15028-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Carol Soto <clsoto@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43331 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754698AbaEVMzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 08:55:53 -0400
In-Reply-To: <1400763340-15028-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use_prio was added as part of an infrastructure for running FCoE in A0 mode.
FCoE didn't get into Mellanox Upstream driver, and when it will, it won't be
using A0 steering mode.

Therefore we can safely deprecate this module parameter without hurting any
existing user.

CC: Carol Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---

I rewrote the commit message - it wasn't accurate, and I think that's why it
was rejected in V0.
Setting this module param to '1' will result in driver failing to load - so
probably no one is doing it.
FCoE was planned to be added when ConnectX only had A0 steering mode, but now
that there are much better steering modes, it won't be based on it. Since this
is the only use for this module param, and nobody is supposed to be using it
currently, I think it is ok to deprecate it.

 drivers/net/ethernet/mellanox/mlx4/main.c | 8 ++++----
 include/linux/mlx4/device.h               | 1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index a56f601..08ff5dd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -132,8 +132,7 @@ MODULE_PARM_DESC(log_num_vlan, "Log2 max number of VLANs per ETH port (0-7)");
 
 static bool use_prio;
 module_param_named(use_prio, use_prio, bool, 0444);
-MODULE_PARM_DESC(use_prio, "Enable steering by VLAN priority on ETH ports "
-		  "(0/1, default 0)");
+MODULE_PARM_DESC(use_prio, "Enable steering by VLAN priority on ETH ports (deprecated)");
 
 int log_mtts_per_seg = ilog2(MLX4_MTT_ENTRY_PER_SEG);
 module_param_named(log_mtts_per_seg, log_mtts_per_seg, int, 0444);
@@ -290,7 +289,6 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 
 	dev->caps.log_num_macs  = log_num_mac;
 	dev->caps.log_num_vlans = MLX4_LOG_NUM_VLANS;
-	dev->caps.log_num_prios = use_prio ? 3 : 0;
 
 	for (i = 1; i <= dev->caps.num_ports; ++i) {
 		dev->caps.port_type[i] = MLX4_PORT_TYPE_NONE;
@@ -358,7 +356,6 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_ADDR] =
 		(1 << dev->caps.log_num_macs) *
 		(1 << dev->caps.log_num_vlans) *
-		(1 << dev->caps.log_num_prios) *
 		dev->caps.num_ports;
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_EXCH] = MLX4_NUM_FEXCH;
 
@@ -2775,6 +2772,9 @@ static int __init mlx4_verify_params(void)
 		pr_warning("mlx4_core: log_num_vlan - obsolete module param, using %d\n",
 			   MLX4_LOG_NUM_VLANS);
 
+	if (use_prio != 0)
+		pr_warn("mlx4_core: use_prio - obsolete module param, ignored\n");
+
 	if ((log_mtts_per_seg < 1) || (log_mtts_per_seg > 7)) {
 		pr_warning("mlx4_core: bad log_mtts_per_seg: %d\n", log_mtts_per_seg);
 		return -1;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index c0468e6..ca38871 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -449,7 +449,6 @@ struct mlx4_caps {
 	int                     reserved_qps_base[MLX4_NUM_QP_REGION];
 	int                     log_num_macs;
 	int                     log_num_vlans;
-	int                     log_num_prios;
 	enum mlx4_port_type	port_type[MLX4_MAX_PORTS + 1];
 	u8			supported_type[MLX4_MAX_PORTS + 1];
 	u8                      suggested_type[MLX4_MAX_PORTS + 1];
-- 
1.8.3.4
