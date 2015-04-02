From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 12/18] net/mlx4: Warn users of depracated QoS Firmware
Date: Thu,  2 Apr 2015 16:31:17 +0300
Message-ID: <1427981483-19317-13-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45723 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752801AbbDBNcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:04 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

A new capability bit was introduced in the past to to differ devices
using the QoS ETS feature. The old was deprecated since then.
If driver sees device which set only the old capabilty, it will print
warning to user suggesting to upgrade the FW.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    7 +++++--
 drivers/net/ethernet/mellanox/mlx4/main.c      |    8 ++++++++
 include/linux/mlx4/device.h                    |    1 +
 4 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0fd5ec9..b02a2e8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2814,7 +2814,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->msg_enable = MLX4_EN_MSG_LEVEL;
 #ifdef CONFIG_MLX4_EN_DCB
 	if (!mlx4_is_slave(priv->mdev->dev)) {
-		if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_SET_ETH_SCHED) {
+		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETS_CFG) {
 			dev->dcbnl_ops = &mlx4_en_dcbnl_ops;
 		} else {
 			en_info(priv, "enabling only PFC DCB ops\n");
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 94e857e..16bbd6c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -149,6 +149,7 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[23] = "QP rate limiting support",
 		[24] = "Ethernet Flow control statistics support",
 		[25] = "Granular QoS per VF support",
+		[26] = "Port ETS Scheduler support",
 	};
 	int i;
 
@@ -900,6 +901,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_VXLAN);
 	if (field & 1<<3)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS;
+	if (field & (1 << 5))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_ETS_CFG;
 	MLX4_GET(dev_cap->max_icm_sz, outbox,
 		 QUERY_DEV_CAP_MAX_ICM_SZ_OFFSET);
 	if (dev_cap->flags & MLX4_DEV_CAP_FLAG_COUNTERS)
@@ -1157,9 +1160,9 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	field &= 0x7f;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET);
 
-	/* For guests, disable vxlan tunneling */
+	/* For guests, disable vxlan tunneling and QoS support */
 	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_VXLAN);
-	field &= 0xf7;
+	field &= 0xd7;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_VXLAN);
 
 	/* For guests, report Blueflame disabled */
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index ee0a670..3becad3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -528,6 +528,14 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev->caps.alloc_res_qp_mask =
 			(dev->caps.bf_reg_size ? MLX4_RESERVE_ETH_BF_QP : 0) |
 			MLX4_RESERVE_A0_QP;
+
+		if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETS_CFG) &&
+		    dev->caps.flags & MLX4_DEV_CAP_FLAG_SET_ETH_SCHED) {
+			mlx4_warn(dev, "Old device ETS support detected\n");
+			mlx4_warn(dev, "Consider upgrading device FW.\n");
+			dev->caps.flags2 |= MLX4_DEV_CAP_FLAG2_ETS_CFG;
+		}
+
 	} else {
 		dev->caps.alloc_res_qp_mask = 0;
 	}
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index c37208f..15f4676 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -207,6 +207,7 @@ enum {
 	MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT	= 1LL <<  23,
 	MLX4_DEV_CAP_FLAG2_FLOWSTATS_EN         = 1LL <<  24,
 	MLX4_DEV_CAP_FLAG2_QOS_VPP		= 1LL <<  25,
+	MLX4_DEV_CAP_FLAG2_ETS_CFG		= 1LL <<  26,
 };
 
 enum {
-- 
1.7.1
