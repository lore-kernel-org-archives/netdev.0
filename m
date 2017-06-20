From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/10] net/mlx5e: IPoIB, Add ioctl support to IPoIB device driver
Date: Tue, 20 Jun 2017 17:13:14 +0300
Message-ID: <20170620141314.25620-11-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Feras Daoud <ferasda@mellanox.com>,
        Eitan Rabin <rabin@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42076 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752040AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feras Daoud <ferasda@mellanox.com>

Add ioctl support to IPoIB device driver. For now, this
ioctl will support timestamp get and set.

Signed-off-by: Feras Daoud <ferasda@mellanox.com>
Signed-off-by: Eitan Rabin <rabin@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h          |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c    | 10 ++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c     |  6 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c | 16 ++++++++++++++++
 4 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 626683f0f487..5d9ace493d85 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -853,8 +853,8 @@ void mlx5e_timestamp_init(struct mlx5e_priv *priv);
 void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv);
 void mlx5e_pps_event_handler(struct mlx5e_priv *priv,
 			     struct ptp_clock_event *event);
-int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr);
-int mlx5e_hwstamp_get(struct net_device *dev, struct ifreq *ifr);
+int mlx5e_hwstamp_set(struct mlx5e_priv *priv, struct ifreq *ifr);
+int mlx5e_hwstamp_get(struct mlx5e_priv *priv, struct ifreq *ifr);
 int mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool val);
 
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index e29494464cae..66f432385dbb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -86,9 +86,8 @@ static void mlx5e_timestamp_overflow(struct work_struct *work)
 	schedule_delayed_work(&tstamp->overflow_work, tstamp->overflow_period);
 }
 
-int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
+int mlx5e_hwstamp_set(struct mlx5e_priv *priv, struct ifreq *ifr)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct hwtstamp_config config;
 	int err;
 
@@ -130,10 +129,10 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 	case HWTSTAMP_FILTER_NTP_ALL:
 		/* Disable CQE compression */
-		netdev_warn(dev, "Disabling cqe compression");
+		netdev_warn(priv->netdev, "Disabling cqe compression");
 		err = mlx5e_modify_rx_cqe_compression_locked(priv, false);
 		if (err) {
-			netdev_err(dev, "Failed disabling cqe compression err=%d\n", err);
+			netdev_err(priv->netdev, "Failed disabling cqe compression err=%d\n", err);
 			mutex_unlock(&priv->state_lock);
 			return err;
 		}
@@ -151,9 +150,8 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 			    sizeof(config)) ? -EFAULT : 0;
 }
 
-int mlx5e_hwstamp_get(struct net_device *dev, struct ifreq *ifr)
+int mlx5e_hwstamp_get(struct mlx5e_priv *priv, struct ifreq *ifr)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct hwtstamp_config *cfg = &priv->tstamp.hwtstamp_config;
 
 	if (!MLX5_CAP_GEN(priv->mdev, device_frequency_khz))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index de1e936fc2be..20ee29a2209e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3317,11 +3317,13 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 
 static int mlx5e_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		return mlx5e_hwstamp_set(dev, ifr);
+		return mlx5e_hwstamp_set(priv, ifr);
 	case SIOCGHWTSTAMP:
-		return mlx5e_hwstamp_get(dev, ifr);
+		return mlx5e_hwstamp_get(priv, ifr);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 58bf0665f50b..1ee5bce85901 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -43,6 +43,7 @@ static int mlx5i_close(struct net_device *netdev);
 static int  mlx5i_dev_init(struct net_device *dev);
 static void mlx5i_dev_cleanup(struct net_device *dev);
 static int mlx5i_change_mtu(struct net_device *netdev, int new_mtu);
+static int mlx5i_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 
 static const struct net_device_ops mlx5i_netdev_ops = {
 	.ndo_open                = mlx5i_open,
@@ -50,6 +51,7 @@ static const struct net_device_ops mlx5i_netdev_ops = {
 	.ndo_init                = mlx5i_dev_init,
 	.ndo_uninit              = mlx5i_dev_cleanup,
 	.ndo_change_mtu          = mlx5i_change_mtu,
+	.ndo_do_ioctl            = mlx5i_ioctl,
 };
 
 /* IPoIB mlx5 netdev profile */
@@ -356,6 +358,20 @@ static int mlx5i_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static int mlx5i_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(dev);
+
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return mlx5e_hwstamp_set(priv, ifr);
+	case SIOCGHWTSTAMP:
+		return mlx5e_hwstamp_get(priv, ifr);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static void mlx5i_dev_cleanup(struct net_device *dev)
 {
 	struct mlx5e_priv    *priv   = mlx5i_epriv(dev);
-- 
2.11.0
