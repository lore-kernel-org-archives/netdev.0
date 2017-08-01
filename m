From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 1/4] net/mlx4_en: Fix wrong indication of Wake-on-LAN (WoL) support
Date: Tue,  1 Aug 2017 16:43:43 +0300
Message-ID: <1501595026-32368-2-git-send-email-tariqt@mellanox.com>
References: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Inbar Karmy <inbark@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43055 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751940AbdHANog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 09:44:36 -0400
In-Reply-To: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inbar Karmy <inbark@mellanox.com>

Currently when WoL is supported but disabled, ethtool reports:
"Supports Wake-on: d".
Fix the indication of Wol support, so that the indication
remains "g" all the time if the NIC supports WoL.

Tested:
As accepted, when NIC supports WoL- ethtool reports:
	Supports Wake-on: g
	Wake-on: d
when NIC doesn't support WoL- ethtool reports:
        Supports Wake-on: d
        Wake-on: d

Fixes: 14c07b1358ed ("mlx4: Wake on LAN support")
Signed-off-by: Inbar Karmy <inbark@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 15 ++++++++-------
 drivers/net/ethernet/mellanox/mlx4/fw.c         |  4 ++++
 drivers/net/ethernet/mellanox/mlx4/fw.h         |  1 +
 drivers/net/ethernet/mellanox/mlx4/main.c       |  2 ++
 include/linux/mlx4/device.h                     |  1 +
 5 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index c751a1d434ad..3d4e4a5d00d1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -223,6 +223,7 @@ static void mlx4_en_get_wol(struct net_device *netdev,
 			    struct ethtool_wolinfo *wol)
 {
 	struct mlx4_en_priv *priv = netdev_priv(netdev);
+	struct mlx4_caps *caps = &priv->mdev->dev->caps;
 	int err = 0;
 	u64 config = 0;
 	u64 mask;
@@ -235,24 +236,24 @@ static void mlx4_en_get_wol(struct net_device *netdev,
 	mask = (priv->port == 1) ? MLX4_DEV_CAP_FLAG_WOL_PORT1 :
 		MLX4_DEV_CAP_FLAG_WOL_PORT2;
 
-	if (!(priv->mdev->dev->caps.flags & mask)) {
+	if (!(caps->flags & mask)) {
 		wol->supported = 0;
 		wol->wolopts = 0;
 		return;
 	}
 
+	if (caps->wol_port[priv->port])
+		wol->supported = WAKE_MAGIC;
+	else
+		wol->supported = 0;
+
 	err = mlx4_wol_read(priv->mdev->dev, &config, priv->port);
 	if (err) {
 		en_err(priv, "Failed to get WoL information\n");
 		return;
 	}
 
-	if (config & MLX4_EN_WOL_MAGIC)
-		wol->supported = WAKE_MAGIC;
-	else
-		wol->supported = 0;
-
-	if (config & MLX4_EN_WOL_ENABLED)
+	if ((config & MLX4_EN_WOL_ENABLED) && (config & MLX4_EN_WOL_MAGIC))
 		wol->wolopts = WAKE_MAGIC;
 	else
 		wol->wolopts = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 37e84a59e751..c165f16623a9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -764,6 +764,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET	0x3e
 #define QUERY_DEV_CAP_MAX_PKEY_OFFSET		0x3f
 #define QUERY_DEV_CAP_EXT_FLAGS_OFFSET		0x40
+#define QUERY_DEV_CAP_WOL_OFFSET		0x43
 #define QUERY_DEV_CAP_FLAGS_OFFSET		0x44
 #define QUERY_DEV_CAP_RSVD_UAR_OFFSET		0x48
 #define QUERY_DEV_CAP_UAR_SZ_OFFSET		0x49
@@ -920,6 +921,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(ext_flags, outbox, QUERY_DEV_CAP_EXT_FLAGS_OFFSET);
 	MLX4_GET(flags, outbox, QUERY_DEV_CAP_FLAGS_OFFSET);
 	dev_cap->flags = flags | (u64)ext_flags << 32;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_WOL_OFFSET);
+	dev_cap->wol_port[1] = !!(field & 0x20);
+	dev_cap->wol_port[2] = !!(field & 0x40);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_UAR_OFFSET);
 	dev_cap->reserved_uars = field >> 4;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_UAR_SZ_OFFSET);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 5343a0599253..b52ba01aa486 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -129,6 +129,7 @@ struct mlx4_dev_cap {
 	u32 dmfs_high_rate_qpn_range;
 	struct mlx4_rate_limit_caps rl_caps;
 	struct mlx4_port_cap port_cap[MLX4_MAX_PORTS + 1];
+	bool wol_port[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_func_cap {
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index a27c9c13a36e..09b9bc17bce9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -424,6 +424,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.stat_rate_support  = dev_cap->stat_rate_support;
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 	dev->caps.max_rss_tbl_sz     = dev_cap->max_rss_tbl_sz;
+	dev->caps.wol_port[1]          = dev_cap->wol_port[1];
+	dev->caps.wol_port[2]          = dev_cap->wol_port[2];
 
 	/* Save uar page shift */
 	if (!mlx4_is_slave(dev)) {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index aad5d81dfb44..b54517c05e9a 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -620,6 +620,7 @@ struct mlx4_caps {
 	u32			dmfs_high_rate_qpn_base;
 	u32			dmfs_high_rate_qpn_range;
 	u32			vf_caps;
+	bool			wol_port[MLX4_MAX_PORTS + 1];
 	struct mlx4_rate_limit_caps rl_caps;
 };
 
-- 
1.8.3.1
