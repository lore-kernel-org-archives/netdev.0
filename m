From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4_en: Enable DCB ETS ops only when supported by the firmware
Date: Thu,  4 Apr 2013 17:26:13 +0300
Message-ID: <1365085574-12057-3-git-send-email-ogerlitz@mellanox.com>
References: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:46611 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761561Ab3DDO0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:26:24 -0400
In-Reply-To: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the DCB ETS ops only when supported by the firmware. For older firmware/cards
which don't support ETS, advertize only PFC DCB ops.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |    5 +++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   10 ++++++++--
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    1 +
 include/linux/mlx4/device.h                    |    1 +
 5 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index b799ab1..b7dc59f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -253,3 +253,8 @@ const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
 	.getdcbx	= mlx4_en_dcbnl_getdcbx,
 	.setdcbx	= mlx4_en_dcbnl_setdcbx,
 };
+
+const struct dcbnl_rtnl_ops mlx4_en_dcbnl_pfc_ops = {
+	.ieee_getpfc	= mlx4_en_dcbnl_ieee_getpfc,
+	.ieee_setpfc	= mlx4_en_dcbnl_ieee_setpfc,
+};
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 61b5678..62795b5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2013,8 +2013,14 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
 	INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
 #ifdef CONFIG_MLX4_EN_DCB
-	if (!mlx4_is_slave(priv->mdev->dev))
-		dev->dcbnl_ops = &mlx4_en_dcbnl_ops;
+	if (!mlx4_is_slave(priv->mdev->dev)) {
+		if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_SET_ETH_SCHED) {
+			dev->dcbnl_ops = &mlx4_en_dcbnl_ops;
+		} else {
+			en_info(priv, "enabling only PFC DCB ops\n");
+			dev->dcbnl_ops = &mlx4_en_dcbnl_pfc_ops;
+		}
+	}
 #endif
 
 	for (i = 0; i < MLX4_EN_MAC_HASH_SIZE; ++i)
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 8764397..ab470d9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -109,6 +109,7 @@ static void dump_dev_cap_flags(struct mlx4_dev *dev, u64 flags)
 		[41] = "Unicast VEP steering support",
 		[42] = "Multicast VEP steering support",
 		[48] = "Counters support",
+		[53] = "Port ETS Scheduler support",
 		[55] = "Port link type sensing support",
 		[59] = "Port management change event support",
 		[61] = "64 byte EQE support",
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index f710b7c..d4cb5d3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -624,6 +624,7 @@ int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
 
 #ifdef CONFIG_MLX4_EN_DCB
 extern const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops;
+extern const struct dcbnl_rtnl_ops mlx4_en_dcbnl_pfc_ops;
 #endif
 
 int mlx4_en_setup_tc(struct net_device *dev, u8 up);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 811f91c..1bc5a75 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -140,6 +140,7 @@ enum {
 	MLX4_DEV_CAP_FLAG_VEP_UC_STEER	= 1LL << 41,
 	MLX4_DEV_CAP_FLAG_VEP_MC_STEER	= 1LL << 42,
 	MLX4_DEV_CAP_FLAG_COUNTERS	= 1LL << 48,
+	MLX4_DEV_CAP_FLAG_SET_ETH_SCHED = 1LL << 53,
 	MLX4_DEV_CAP_FLAG_SENSE_SUPPORT	= 1LL << 55,
 	MLX4_DEV_CAP_FLAG_PORT_MNG_CHG_EV = 1LL << 59,
 	MLX4_DEV_CAP_FLAG_64B_EQE	= 1LL << 61,
-- 
1.7.1
