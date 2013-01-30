From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 10/11] net/mlx4_en: Don't reassign port mac address on firmware that supports it
Date: Wed, 30 Jan 2013 12:34:26 +0200
Message-ID: <1359542067-10760-11-git-send-email-amirv@mellanox.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Matan Barak <matanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:38459 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754443Ab3A3Keu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:50 -0500
In-Reply-To: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Mac reassignments should only be done when not supported by the firmware. To
accomplish that, checking firmware capability bit to know whether we should
reassign macs in the driver.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    3 ++-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    7 ++++++-
 include/linux/mlx4/device.h                    |    3 ++-
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 616c3a3..9b78f61 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1291,7 +1291,8 @@ void mlx4_en_stop_port(struct net_device *dev)
 
 	/* Unregister Mac address for the port */
 	mlx4_put_eth_qp(mdev->dev, priv->port, priv->mac, priv->base_qpn);
-	mdev->mac_removed[priv->port] = 1;
+	if (!(mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN))
+		mdev->mac_removed[priv->port] = 1;
 
 	/* Remove flow steering rules for the port*/
 	if (mdev->dev->caps.steering_mode ==
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 91acf71..38b62c7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -127,7 +127,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[0] = "RSS support",
 		[1] = "RSS Toeplitz Hash Function support",
 		[2] = "RSS XOR Hash Function support",
-		[3] = "Device manage flow steering support"
+		[3] = "Device manage flow steering support",
+		[4] = "Automatic mac reassignment support"
 	};
 	int i;
 
@@ -478,6 +479,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_BMME_FLAGS_OFFSET		0x94
 #define QUERY_DEV_CAP_RSVD_LKEY_OFFSET		0x98
 #define QUERY_DEV_CAP_MAX_ICM_SZ_OFFSET		0xa0
+#define QUERY_DEV_CAP_FW_REASSIGN_MAC		0x9d
 
 	dev_cap->flags2 = 0;
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
@@ -637,6 +639,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		 QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
 	MLX4_GET(dev_cap->reserved_lkey, outbox,
 		 QUERY_DEV_CAP_RSVD_LKEY_OFFSET);
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_FW_REASSIGN_MAC);
+	if (field & 1<<6)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN;
 	MLX4_GET(dev_cap->max_icm_sz, outbox,
 		 QUERY_DEV_CAP_MAX_ICM_SZ_OFFSET);
 	if (dev_cap->flags & MLX4_DEV_CAP_FLAG_COUNTERS)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index ae9741b..054aae4 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -150,7 +150,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_RSS			= 1LL <<  0,
 	MLX4_DEV_CAP_FLAG2_RSS_TOP		= 1LL <<  1,
 	MLX4_DEV_CAP_FLAG2_RSS_XOR		= 1LL <<  2,
-	MLX4_DEV_CAP_FLAG2_FS_EN		= 1LL <<  3
+	MLX4_DEV_CAP_FLAG2_FS_EN		= 1LL <<  3,
+	MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN	= 1LL <<  4
 };
 
 enum {
-- 
1.7.8.2
