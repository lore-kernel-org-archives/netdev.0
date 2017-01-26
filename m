From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 4/4] mlx5: Make building vxlan hardware offload configurable
Date: Thu, 26 Jan 2017 15:32:41 -0800
Message-ID: <20170126233241.2268449-5-tom@herbertland.com>
References: <20170126233241.2268449-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <saeedm@mellanox.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40795 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750749AbdA0Ahx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 19:37:53 -0500
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0QNHntC011146
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 15:32:55 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 287pqh8sxv-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 15:32:55 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 c1ed927ce41f11e6bfa424be05904660-21fd0a50 for <netdev@vger.kernel.org>;        Thu,
 26 Jan 2017 15:32:53 -0800
In-Reply-To: <20170126233241.2268449-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a configuration option (CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD)
for controlling whether the support for UDP encapsulation offlaod is
supported. Note that only VXLAN offload is supported currently,
however the config option is named to be generic for UDP offloads.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  8 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  4 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 27 +++++++++++++++++------
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index b38c920..d8ed54a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -57,3 +57,11 @@ config MLX5_CORE_EN_TC
 	  Say Y here if you want to use TC hardware offload support.
 
 	  If unsure, set to Y
+
+config MLX5_CORE_EN_UDP_ENCAP_OFFLOAD
+	bool "UDP encapsulation offload"
+	default y
+	---help---
+	  Say Y here if you want to use UDP encapsulation hardware offload.
+	  Currently, VXLAN offload is uspported.
+
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index c308531..c08c9c8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -7,7 +7,7 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
-		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
+		en_rx.o en_rx_am.o en_txrx.o en_clock.o \
 		en_arfs.o en_fs_ethtool.o en_selftest.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
@@ -17,3 +17,5 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN_ESWITCH) += eswitch.o eswitch_offloads.o en_rep.
 mlx5_core-$(CONFIG_MLX5_CORE_EN_SRIOV) += sriov.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_TC) += en_tc.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD) += vxlan.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2d2c982..31a8d88 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -34,14 +34,16 @@
 #include <linux/crash_dump.h>
 #include <net/pkt_cls.h>
 #include <linux/mlx5/fs.h>
-#include <net/vxlan.h>
 #include <linux/bpf.h>
 #include "en.h"
 #include "en_tc.h"
 #ifdef CONFIG_MLX5_CORE_EN_ESWITCH
 #include "eswitch.h"
 #endif
+#ifdef CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD
+#include <net/vxlan.h>
 #include "vxlan.h"
+#endif
 
 struct mlx5e_rq_param {
 	u32			rqc[MLX5_ST_SZ_DW(rqc)];
@@ -3111,6 +3113,7 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 }
 #endif /* CONFIG_MLX5_CORE_EN_ESWITCH */
 
+#ifdef CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD
 void mlx5e_add_vxlan_port(struct net_device *netdev,
 			  struct udp_tunnel_info *ti)
 {
@@ -3171,20 +3174,22 @@ static netdev_features_t mlx5e_vxlan_features_check(struct mlx5e_priv *priv,
 	/* Disable CSUM and GSO if the udp dport is not offloaded by HW */
 	return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 }
+#endif
 
 static netdev_features_t mlx5e_features_check(struct sk_buff *skb,
 					      struct net_device *netdev,
 					      netdev_features_t features)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-
 	features = vlan_features_check(skb, features);
+#ifdef CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD
 	features = vxlan_features_check(skb, features);
 
 	/* Validate if the tunneled packet is being offloaded by HW */
 	if (skb->encapsulation &&
 	    (features & NETIF_F_CSUM_MASK || features & NETIF_F_GSO_MASK))
-		return mlx5e_vxlan_features_check(priv, skb, features);
+		return mlx5e_vxlan_features_check(netdev_priv(netdev),
+						  skb, features);
+#endif
 
 	return features;
 }
@@ -3365,8 +3370,10 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_features        = mlx5e_set_features,
 	.ndo_change_mtu          = mlx5e_change_mtu,
 	.ndo_do_ioctl            = mlx5e_ioctl,
+#ifdef CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD
 	.ndo_udp_tunnel_add	 = mlx5e_add_vxlan_port,
 	.ndo_udp_tunnel_del	 = mlx5e_del_vxlan_port,
+#endif
 	.ndo_set_tx_maxrate      = mlx5e_set_tx_maxrate,
 	.ndo_features_check      = mlx5e_features_check,
 #ifdef CONFIG_RFS_ACCEL
@@ -3643,6 +3650,7 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
+#ifdef CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD
 	if (mlx5e_vxlan_allowed(mdev)) {
 		netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL |
 					   NETIF_F_GSO_UDP_TUNNEL_CSUM |
@@ -3656,6 +3664,7 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 					   NETIF_F_GSO_PARTIAL;
 		netdev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
 	}
+#endif
 
 	mlx5_query_port_fcs(mdev, &fcs_supported, &fcs_enabled);
 
@@ -3717,16 +3726,18 @@ static void mlx5e_nic_init(struct mlx5_core_dev *mdev,
 			   const struct mlx5e_profile *profile,
 			   void *ppriv)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-
 	mlx5e_build_nic_netdev_priv(mdev, netdev, profile, ppriv);
 	mlx5e_build_nic_netdev(netdev);
-	mlx5e_vxlan_init(priv);
+#ifdef CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD
+	mlx5e_vxlan_init(netdev_priv(netdev));
+#endif
 }
 
 static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
 {
+#ifdef CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD
 	mlx5e_vxlan_cleanup(priv);
+#endif
 
 	if (priv->xdp_prog)
 		bpf_prog_put(priv->xdp_prog);
@@ -3847,12 +3858,14 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 	if (netdev->reg_state != NETREG_REGISTERED)
 		return;
 
+#ifdef CONFIG_MLX5_CORE_EN_UDP_ENCAP_OFFLOAD
 	/* Device already registered: sync netdev system state */
 	if (mlx5e_vxlan_allowed(mdev)) {
 		rtnl_lock();
 		udp_tunnel_get_rx_info(netdev);
 		rtnl_unlock();
 	}
+#endif
 
 	queue_work(priv->wq, &priv->set_rx_mode_work);
 }
-- 
2.9.3
