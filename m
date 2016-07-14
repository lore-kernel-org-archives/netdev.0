From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 10/10] net/mlx5e: Add TC offload support for the VF representors netdevice
Date: Thu, 14 Jul 2016 10:32:46 +0300
Message-ID: <1468481566-29859-11-git-send-email-saeedm@mellanox.com>
References: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43396 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751136AbcGNHdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 03:33:20 -0400
In-Reply-To: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The VF representors support only TC filter/action offloads
(not mqprio) and this is enabled for them by default.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 35 +++++++++++++++++++++++-
 1 file changed, 34 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index fdaf2fa..1c7d8b8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -33,6 +33,7 @@
 #include <generated/utsrelease.h>
 #include <linux/mlx5/fs.h>
 #include <net/switchdev.h>
+#include <net/pkt_cls.h>
 
 #include "eswitch.h"
 #include "en.h"
@@ -222,6 +223,29 @@ static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 	return 0;
 }
 
+static int mlx5e_rep_ndo_setup_tc(struct net_device *dev, u32 handle,
+				  __be16 proto, struct tc_to_netdev *tc)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
+		return -EOPNOTSUPP;
+
+	switch (tc->type) {
+	case TC_SETUP_CLSFLOWER:
+		switch (tc->cls_flower->command) {
+		case TC_CLSFLOWER_REPLACE:
+			return mlx5e_configure_flower(priv, proto, tc->cls_flower);
+		case TC_CLSFLOWER_DESTROY:
+			return mlx5e_delete_flower(priv, tc->cls_flower);
+		case TC_CLSFLOWER_STATS:
+			return mlx5e_stats_flower(priv, tc->cls_flower);
+		}
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static const struct switchdev_ops mlx5e_rep_switchdev_ops = {
 	.switchdev_port_attr_get	= mlx5e_attr_get,
 };
@@ -231,6 +255,7 @@ static const struct net_device_ops mlx5e_netdev_ops_rep = {
 	.ndo_stop                = mlx5e_close,
 	.ndo_start_xmit          = mlx5e_xmit,
 	.ndo_get_phys_port_name  = mlx5e_rep_get_phys_port_name,
+	.ndo_setup_tc            = mlx5e_rep_ndo_setup_tc,
 	.ndo_get_stats64         = mlx5e_get_stats,
 };
 
@@ -284,7 +309,8 @@ static void mlx5e_build_rep_netdev(struct net_device *netdev)
 	netdev->switchdev_ops = &mlx5e_rep_switchdev_ops;
 #endif
 
-	netdev->features	 |= NETIF_F_VLAN_CHALLENGED;
+	netdev->features	 |= NETIF_F_VLAN_CHALLENGED | NETIF_F_HW_TC;
+	netdev->hw_features      |= NETIF_F_HW_TC;
 
 	eth_hw_addr_random(netdev);
 }
@@ -328,8 +354,14 @@ static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 	}
 	rep->vport_rx_rule = flow_rule;
 
+	err = mlx5e_tc_init(priv);
+	if (err)
+		goto err_del_flow_rule;
+
 	return 0;
 
+err_del_flow_rule:
+	mlx5_del_flow_rule(rep->vport_rx_rule);
 err_destroy_direct_tirs:
 	mlx5e_destroy_direct_tirs(priv);
 err_destroy_direct_rqts:
@@ -343,6 +375,7 @@ static void mlx5e_cleanup_rep_rx(struct mlx5e_priv *priv)
 	struct mlx5_eswitch_rep *rep = priv->ppriv;
 	int i;
 
+	mlx5e_tc_cleanup(priv);
 	mlx5_del_flow_rule(rep->vport_rx_rule);
 	mlx5e_destroy_direct_tirs(priv);
 	for (i = 0; i < priv->params.num_channels; i++)
-- 
2.8.0
