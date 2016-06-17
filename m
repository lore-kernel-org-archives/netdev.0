From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 18/18] net/mlx5e: Add netdev hw feature flag offload-sniffer
Date: Fri, 17 Jun 2016 17:43:59 +0300
Message-ID: <1466174639-14576-19-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57744 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751386AbcFQOtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:49:49 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Huy Nguyen <huyn@mellanox.com>

Add netdev hw feature flag offload-sniffer to turn on/off kernel net
stack offload sniffer.  Kernel offload sniffer is a device driver
feature which when turned on, the device driver will start
receiving packets that weren't supposed to go through the kernel stack.

Optionally, those packets can be marked with PACKET_OFFLOAD_KERNEL in
skb->pkt_type so they will skip the unneeded kernel net stack
processing.
Please see ("net: Add offload kernel net stack packet type")

Example: ethtool eth1 =E2=80=93K offload-sniffer on

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 28 +++++++++++++++=
++++++++
 include/linux/netdev_features.h                   |  2 ++
 net/core/ethtool.c                                |  1 +
 3 files changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/driver=
s/net/ethernet/mellanox/mlx5/core/en_main.c
index 94d6f60..61201f4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1702,6 +1702,9 @@ int mlx5e_open_locked(struct net_device *netdev)
 	priv->netdev->rx_cpu_rmap =3D priv->mdev->rmap;
 #endif
=20
+	if (netdev->features & NETIF_F_OFFLOAD_SNIFFER)
+		mlx5e_sniffer_start(priv);
+
 	queue_delayed_work(priv->wq, &priv->update_stats_work, 0);
=20
 	return 0;
@@ -1737,6 +1740,9 @@ int mlx5e_close_locked(struct net_device *netdev)
=20
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
=20
+	if (netdev->features & NETIF_F_OFFLOAD_SNIFFER)
+		mlx5e_sniffer_stop(priv);
+
 	mlx5e_timestamp_cleanup(priv);
 	netif_carrier_off(priv->netdev);
 	mlx5e_redirect_rqts(priv);
@@ -2325,6 +2331,22 @@ static int set_feature_arfs(struct net_device *n=
etdev, bool enable)
 }
 #endif
=20
+static int set_feature_offload_sniffer(struct net_device *netdev, bool=
 enable)
+{
+	struct mlx5e_priv *priv =3D netdev_priv(netdev);
+	int err;
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
+		return 0;
+
+	if (enable)
+		err =3D mlx5e_sniffer_start(priv);
+	else
+		err =3D mlx5e_sniffer_stop(priv);
+
+	return err;
+}
+
 static int mlx5e_handle_feature(struct net_device *netdev,
 				netdev_features_t wanted_features,
 				netdev_features_t feature,
@@ -2371,6 +2393,8 @@ static int mlx5e_set_features(struct net_device *=
netdev,
 	err |=3D mlx5e_handle_feature(netdev, features, NETIF_F_NTUPLE,
 				    set_feature_arfs);
 #endif
+	err |=3D mlx5e_handle_feature(netdev, features, NETIF_F_OFFLOAD_SNIFF=
ER,
+				    set_feature_offload_sniffer);
=20
 	mutex_unlock(&priv->state_lock);
=20
@@ -2911,6 +2935,10 @@ static void mlx5e_build_netdev(struct net_device=
 *netdev)
 		netdev->hw_features |=3D NETIF_F_RXALL;
=20
 	netdev->features          =3D netdev->hw_features;
+
+	/* Put it here because default is off */
+	netdev->hw_features      |=3D NETIF_F_OFFLOAD_SNIFFER;
+
 	if (!priv->params.lro_en)
 		netdev->features  &=3D ~NETIF_F_LRO;
=20
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
index 9c6c8ef..c00590c2 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -74,6 +74,7 @@ enum {
 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
=20
 	NETIF_F_HW_TC_BIT,		/* Offload TC infrastructure */
+	NETIF_F_OFFLOAD_SNIFFER_BIT,	/* Kernel Offload sniffer */
=20
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -136,6 +137,7 @@ enum {
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
 #define NETIF_F_HW_TC		__NETIF_F(HW_TC)
+#define NETIF_F_OFFLOAD_SNIFFER __NETIF_F(OFFLOAD_SNIFFER)
=20
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUN=
T)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9774898..daaf9a5 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -104,6 +104,7 @@ static const char netdev_features_strings[NETDEV_FE=
ATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] =3D "l2-fwd-offload",
 	[NETIF_F_BUSY_POLL_BIT] =3D        "busy-poll",
 	[NETIF_F_HW_TC_BIT] =3D		 "hw-tc-offload",
+	[NETIF_F_OFFLOAD_SNIFFER_BIT] =3D  "offload-sniffer"
 };
=20
 static const char
--=20
2.8.0
