From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 07/16] mlx4: Wake on LAN support
Date: Wed, 23 Mar 2011 10:37:59 +0200
Message-ID: <4D89B167.80104@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<igory@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:58073 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755781Ab1CWIiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:38:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The driver queries the FW for WOL support.
Ethtool get/set_wol is implemented accordingly.
Only magic packets are supported at the time.

Signed-off-by: Igor Yarovinsky <igory@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_ethtool.c |   62 +++++++++++++++++++++++++++++++++++++++-
 drivers/net/mlx4/fw.c         |   20 +++++++++++++
 drivers/net/mlx4/fw.h         |    1 +
 drivers/net/mlx4/main.c       |    1 +
 drivers/net/mlx4/mlx4_en.h    |    7 ++++
 include/linux/mlx4/device.h   |    4 ++
 6 files changed, 93 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 8cfe858..c1f351f 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -131,8 +131,65 @@ static void mlx4_en_set_msglevel(struct net_device *dev, u32 val)
 static void mlx4_en_get_wol(struct net_device *netdev,
 			    struct ethtool_wolinfo *wol)
 {
-	wol->supported = 0;
-	wol->wolopts = 0;
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+	int err = 0;
+	u64 config = 0;
+
+	if (!priv->mdev->dev->caps.wol) {
+		wol->supported = 0;
+		wol->wolopts = 0;
+		return;
+	}
+
+	err = mlx4_wol_read(priv->mdev->dev, &config, priv->port);
+	if (err) {
+		en_err(priv, "Failed to get WoL information\n");
+		return;
+	}
+
+	if (config & MLX4_EN_WOL_MAGIC)
+		wol->supported = WAKE_MAGIC;
+	else
+		wol->supported = 0;
+
+	if (config & MLX4_EN_WOL_ENABLED)
+		wol->wolopts = WAKE_MAGIC;
+	else
+		wol->wolopts = 0;
+}
+
+static int mlx4_en_set_wol(struct net_device *netdev,
+			    struct ethtool_wolinfo *wol)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+	u64 config = 0;
+	int err = 0;
+
+	if (!priv->mdev->dev->caps.wol)
+		return -EOPNOTSUPP;
+
+	if (wol->supported & ~WAKE_MAGIC)
+		return -EINVAL;
+
+	err = mlx4_wol_read(priv->mdev->dev, &config, priv->port);
+	if (err) {
+		en_err(priv, "Failed to get WoL info, unable to modify\n");
+		return err;
+	}
+
+	if (wol->wolopts & WAKE_MAGIC) {
+		config |= MLX4_EN_WOL_DO_MODIFY | MLX4_EN_WOL_ENABLED |
+				MLX4_EN_WOL_MAGIC;
+	} else {
+		config &= ~(MLX4_EN_WOL_ENABLED | MLX4_EN_WOL_MAGIC);
+		config |= MLX4_EN_WOL_DO_MODIFY;
+	}
+
+	err = mlx4_wol_write(priv->mdev->dev, config, priv->port);
+	if (err)
+		en_err(priv, "Failed to set WoL information\n");
+
+	return err;
 }
 
 static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
@@ -442,6 +499,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_ethtool_stats = mlx4_en_get_ethtool_stats,
 	.self_test = mlx4_en_self_test,
 	.get_wol = mlx4_en_get_wol,
+	.set_wol = mlx4_en_set_wol,
 	.get_msglevel = mlx4_en_get_msglevel,
 	.set_msglevel = mlx4_en_set_msglevel,
 	.get_coalesce = mlx4_en_get_coalesce,
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 5de1db8..fd1c51b 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -276,6 +276,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->udp_rss = field & 0x1;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET);
 	dev_cap->loopback_support = field & 0x1;
+	dev_cap->wol = field & 0x40;
 	MLX4_GET(dev_cap->flags, outbox, QUERY_DEV_CAP_FLAGS_OFFSET);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_UAR_OFFSET);
 	dev_cap->reserved_uars = field >> 4;
@@ -908,3 +909,22 @@ int mlx4_NOP(struct mlx4_dev *dev)
 	/* Input modifier of 0x1f means "finish as soon as possible." */
 	return mlx4_cmd(dev, 0, 0x1f, 0, MLX4_CMD_NOP, 100);
 }
+
+#define MLX4_WOL_SETUP_MODE (5 << 28)
+int mlx4_wol_read(struct mlx4_dev *dev, u64 *config, int port)
+{
+	u32 in_mod = MLX4_WOL_SETUP_MODE | port << 8;
+
+	return mlx4_cmd_imm(dev, 0, config, in_mod, 0x3,
+			    MLX4_CMD_MOD_STAT_CFG, MLX4_CMD_TIME_CLASS_A);
+}
+EXPORT_SYMBOL_GPL(mlx4_wol_read);
+
+int mlx4_wol_write(struct mlx4_dev *dev, u64 config, int port)
+{
+	u32 in_mod = MLX4_WOL_SETUP_MODE | port << 8;
+
+	return mlx4_cmd(dev, config, in_mod, 0x1, MLX4_CMD_MOD_STAT_CFG,
+					MLX4_CMD_TIME_CLASS_A);
+}
+EXPORT_SYMBOL_GPL(mlx4_wol_write);
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index 65cc72e..f7b9cc2 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -80,6 +80,7 @@ struct mlx4_dev_cap {
 	u16 stat_rate_support;
 	int udp_rss;
 	int loopback_support;
+	int wol;
 	u32 flags;
 	int reserved_uars;
 	int uar_size;
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 517ca34..42d4fb4 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -227,6 +227,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.stat_rate_support  = dev_cap->stat_rate_support;
 	dev->caps.udp_rss	     = dev_cap->udp_rss;
 	dev->caps.loopback_support   = dev_cap->loopback_support;
+	dev->caps.wol		     = dev_cap->wol;
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 
 	dev->caps.log_num_macs  = log_num_mac;
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 2db245f..07aea8d 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -479,6 +479,13 @@ struct mlx4_en_priv {
 	int mc_addrs_cnt;
 	struct mlx4_en_stat_out_mbox hw_stats;
 	int vids[128];
+	bool wol;
+};
+
+enum mlx4_en_wol {
+	MLX4_EN_WOL_MAGIC = (1ULL << 61),
+	MLX4_EN_WOL_ENABLED = (1ULL << 62),
+	MLX4_EN_WOL_DO_MODIFY = (1ULL << 63),
 };
 
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 7838082..2460356 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -251,6 +251,7 @@ struct mlx4_caps {
 	u16			stat_rate_support;
 	int			udp_rss;
 	int			loopback_support;
+	int			wol;
 	u8			port_width_cap[MLX4_MAX_PORTS + 1];
 	int			max_gso_sz;
 	int                     reserved_qps_cnt[MLX4_NUM_QP_REGION];
@@ -535,4 +536,7 @@ int mlx4_test_interrupts(struct mlx4_dev *dev);
 int mlx4_assign_eq(struct mlx4_dev *dev, char* name , int* vector);
 void mlx4_release_eq(struct mlx4_dev *dev, int vec);
 
+int mlx4_wol_read(struct mlx4_dev *dev, u64 *config, int port);
+int mlx4_wol_write(struct mlx4_dev *dev, u64 config, int port);
+
 #endif /* MLX4_DEVICE_H */
-- 
1.6.0.2





