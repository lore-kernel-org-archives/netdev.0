From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 10/12] net/mlx5e: Add netdev support for VXLAN tunneling
Date: Mon, 22 Feb 2016 18:17:32 +0200
Message-ID: <1456157854-12750-11-git-send-email-saeedm@mellanox.com>
References: <1456157854-12750-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:42334 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752927AbcBVQTD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 11:19:03 -0500
In-Reply-To: <1456157854-12750-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

If a VXLAN udp dport is added to device it will:

   - Configure the hardware to offload the port (up to the max
     supported).
   - Advertise NETIF_F_GSO_UDP_TUNNEL and supported hw_enc_features.

Signed-off-by: Matthew Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c     |    8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    6 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   95 ++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c   |  170 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h   |   54 +++++++
 6 files changed, 332 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 1a82e23..11b592d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -6,6 +6,6 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
-		en_txrx.o en_clock.o
+		en_txrx.o en_clock.o vxlan.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 9ce87c6..97f5114 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2013-2016, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -566,6 +566,12 @@ const char *mlx5_command_str(int command)
 	case MLX5_CMD_OP_QUERY_WOL_ROL:
 		return "QUERY_WOL_ROL";
 
+	case MLX5_CMD_OP_ADD_VXLAN_UDP_DPORT:
+		return "ADD_VXLAN_UDP_DPORT";
+
+	case MLX5_CMD_OP_DELETE_VXLAN_UDP_DPORT:
+		return "DELETE_VXLAN_UDP_DPORT";
+
 	default: return "unknown command opcode";
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 786a247..a700c57 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -501,6 +501,11 @@ struct mlx5e_vlan_db {
 	bool          filter_disabled;
 };
 
+struct mlx5e_vxlan_db {
+	spinlock_t			lock; /* protect vxlan table */
+	struct radix_tree_root		tree;
+};
+
 struct mlx5e_flow_table {
 	int num_groups;
 	struct mlx5_flow_table		*t;
@@ -535,6 +540,7 @@ struct mlx5e_priv {
 	struct mlx5e_flow_tables   fts;
 	struct mlx5e_eth_addr_db   eth_addr;
 	struct mlx5e_vlan_db       vlan;
+	struct mlx5e_vxlan_db      vxlan;
 
 	struct mlx5e_params        params;
 	spinlock_t                 async_events_spinlock; /* sync hw events */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 704d75c..6f7eb3b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015-2016, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -31,8 +31,10 @@
  */
 
 #include <linux/mlx5/fs.h>
+#include <net/vxlan.h>
 #include "en.h"
 #include "eswitch.h"
+#include "vxlan.h"
 
 struct mlx5e_rq_param {
 	u32                        rqc[MLX5_ST_SZ_DW(rqc)];
@@ -2078,6 +2080,78 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 					    vf_stats);
 }
 
+static void mlx5e_add_vxlan_port(struct net_device *netdev,
+				 sa_family_t sa_family, __be16 port)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	if (!mlx5e_vxlan_allowed(priv->mdev))
+		return;
+
+	mlx5e_vxlan_add_port(priv, be16_to_cpu(port));
+}
+
+static void mlx5e_del_vxlan_port(struct net_device *netdev,
+				 sa_family_t sa_family, __be16 port)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	if (!mlx5e_vxlan_allowed(priv->mdev))
+		return;
+
+	mlx5e_vxlan_del_port(priv, be16_to_cpu(port));
+}
+
+static netdev_features_t mlx5e_vxlan_features_check(struct mlx5e_priv *priv,
+						    struct sk_buff *skb,
+						    netdev_features_t features)
+{
+	struct udphdr *udph;
+	u16 proto;
+	u16 port = 0;
+
+	switch (vlan_get_protocol(skb)) {
+	case htons(ETH_P_IP):
+		proto = ip_hdr(skb)->protocol;
+		break;
+	case htons(ETH_P_IPV6):
+		proto = ipv6_hdr(skb)->nexthdr;
+		break;
+	default:
+		goto out;
+	}
+
+	if (proto == IPPROTO_UDP) {
+		udph = udp_hdr(skb);
+		port = be16_to_cpu(udph->dest);
+	}
+
+	/* Verify if UDP port is being offloaded by HW */
+	if (port && mlx5e_vxlan_lookup_port(priv, port))
+		return features;
+
+out:
+	/* Disable CSUM and GSO if the udp dport is not offloaded by HW */
+	return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
+}
+
+static netdev_features_t mlx5e_features_check(struct sk_buff *skb,
+					      struct net_device *netdev,
+					      netdev_features_t features)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	features = vlan_features_check(skb, features);
+	features = vxlan_features_check(skb, features);
+
+	/* Validate if the tunneled packet is being offloaded by HW */
+	if (skb->encapsulation &&
+	    (features & NETIF_F_CSUM_MASK || features & NETIF_F_GSO_MASK))
+		return mlx5e_vxlan_features_check(priv, skb, features);
+
+	return features;
+}
+
 static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
@@ -2108,6 +2182,9 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_features        = mlx5e_set_features,
 	.ndo_change_mtu          = mlx5e_change_mtu,
 	.ndo_do_ioctl            = mlx5e_ioctl,
+	.ndo_add_vxlan_port      = mlx5e_add_vxlan_port,
+	.ndo_del_vxlan_port      = mlx5e_del_vxlan_port,
+	.ndo_features_check      = mlx5e_features_check,
 	.ndo_set_vf_mac          = mlx5e_set_vf_mac,
 	.ndo_set_vf_vlan         = mlx5e_set_vf_vlan,
 	.ndo_get_vf_config       = mlx5e_get_vf_config,
@@ -2264,6 +2341,16 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
+	if (mlx5e_vxlan_allowed(mdev)) {
+		netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL;
+		netdev->hw_enc_features |= NETIF_F_IP_CSUM;
+		netdev->hw_enc_features |= NETIF_F_RXCSUM;
+		netdev->hw_enc_features |= NETIF_F_TSO;
+		netdev->hw_enc_features |= NETIF_F_TSO6;
+		netdev->hw_enc_features |= NETIF_F_RXHASH;
+		netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL;
+	}
+
 	netdev->features          = netdev->hw_features;
 	if (!priv->params.lro_en)
 		netdev->features  &= ~NETIF_F_LRO;
@@ -2387,6 +2474,8 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 
 	mlx5e_init_eth_addr(priv);
 
+	mlx5e_vxlan_init(priv);
+
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 	mlx5e_dcbnl_ieee_setets_core(priv, &priv->params.ets);
 #endif
@@ -2397,6 +2486,9 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 		goto err_destroy_flow_tables;
 	}
 
+	if (mlx5e_vxlan_allowed(mdev))
+		vxlan_get_rx_port(netdev);
+
 	mlx5e_enable_async_events(priv);
 	schedule_work(&priv->set_rx_mode_work);
 
@@ -2449,6 +2541,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	mlx5e_disable_async_events(priv);
 	flush_scheduled_work();
 	unregister_netdev(netdev);
+	mlx5e_vxlan_cleanup(priv);
 	mlx5e_destroy_flow_tables(priv);
 	mlx5e_destroy_tirs(priv);
 	mlx5e_destroy_rqt(priv, MLX5E_SINGLE_RQ_RQT);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
new file mode 100644
index 0000000..9f10df2
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
@@ -0,0 +1,170 @@
+/*
+ * Copyright (c) 2016, Mellanox Technologies, Ltd.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mlx5/driver.h>
+#include "mlx5_core.h"
+#include "vxlan.h"
+
+void mlx5e_vxlan_init(struct mlx5e_priv *priv)
+{
+	struct mlx5e_vxlan_db *vxlan_db = &priv->vxlan;
+
+	spin_lock_init(&vxlan_db->lock);
+	INIT_RADIX_TREE(&vxlan_db->tree, GFP_ATOMIC);
+}
+
+static int mlx5e_vxlan_core_add_port_cmd(struct mlx5_core_dev *mdev, u16 port)
+{
+	struct mlx5_outbox_hdr *hdr;
+	int err;
+
+	u32 in[MLX5_ST_SZ_DW(add_vxlan_udp_dport_in)];
+	u32 out[MLX5_ST_SZ_DW(add_vxlan_udp_dport_out)];
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+	MLX5_SET(add_vxlan_udp_dport_in, in, opcode,
+		 MLX5_CMD_OP_ADD_VXLAN_UDP_DPORT);
+	MLX5_SET(add_vxlan_udp_dport_in, in, vxlan_udp_port, port);
+
+	err = mlx5_cmd_exec(mdev, in, sizeof(in), out, sizeof(out));
+	if (err)
+		return err;
+
+	hdr = (struct mlx5_outbox_hdr *)out;
+	return hdr->status ? -ENOMEM : 0;
+}
+
+static int mlx5e_vxlan_core_del_port_cmd(struct mlx5_core_dev *mdev, u16 port)
+{
+	u32 in[MLX5_ST_SZ_DW(delete_vxlan_udp_dport_in)];
+	u32 out[MLX5_ST_SZ_DW(delete_vxlan_udp_dport_out)];
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+
+	MLX5_SET(delete_vxlan_udp_dport_in, in, opcode,
+		 MLX5_CMD_OP_DELETE_VXLAN_UDP_DPORT);
+	MLX5_SET(delete_vxlan_udp_dport_in, in, vxlan_udp_port, port);
+
+	return mlx5_cmd_exec_check_status(mdev, in, sizeof(in), out,
+					  sizeof(out));
+}
+
+struct mlx5e_vxlan *mlx5e_vxlan_lookup_port(struct mlx5e_priv *priv, u16 port)
+{
+	struct mlx5e_vxlan_db *vxlan_db = &priv->vxlan;
+	struct mlx5e_vxlan *vxlan;
+
+	spin_lock(&vxlan_db->lock);
+	vxlan = radix_tree_lookup(&vxlan_db->tree, port);
+	spin_unlock(&vxlan_db->lock);
+
+	return vxlan;
+}
+
+int mlx5e_vxlan_add_port(struct mlx5e_priv *priv, u16 port)
+{
+	struct mlx5e_vxlan_db *vxlan_db = &priv->vxlan;
+	struct mlx5e_vxlan *vxlan;
+	int err;
+
+	err = mlx5e_vxlan_core_add_port_cmd(priv->mdev, port);
+	if (err)
+		return err;
+
+	vxlan = kzalloc(sizeof(*vxlan), GFP_KERNEL);
+	if (!vxlan) {
+		err = -ENOMEM;
+		goto err_delete_port;
+	}
+
+	vxlan->udp_port = port;
+
+	spin_lock_irq(&vxlan_db->lock);
+	err = radix_tree_insert(&vxlan_db->tree, vxlan->udp_port, vxlan);
+	spin_unlock_irq(&vxlan_db->lock);
+	if (err)
+		goto err_free;
+
+	return 0;
+
+err_free:
+	kfree(vxlan);
+err_delete_port:
+	mlx5e_vxlan_core_del_port_cmd(priv->mdev, port);
+	return err;
+}
+
+static void __mlx5e_vxlan_core_del_port(struct mlx5e_priv *priv, u16 port)
+{
+	struct mlx5e_vxlan_db *vxlan_db = &priv->vxlan;
+	struct mlx5e_vxlan *vxlan;
+
+	spin_lock_irq(&vxlan_db->lock);
+	vxlan = radix_tree_delete(&vxlan_db->tree, port);
+	spin_unlock_irq(&vxlan_db->lock);
+
+	if (!vxlan)
+		return;
+
+	mlx5e_vxlan_core_del_port_cmd(priv->mdev, vxlan->udp_port);
+
+	kfree(vxlan);
+}
+
+void mlx5e_vxlan_del_port(struct mlx5e_priv *priv, u16 port)
+{
+	if (!mlx5e_vxlan_lookup_port(priv, port))
+		return;
+
+	__mlx5e_vxlan_core_del_port(priv, port);
+}
+
+void mlx5e_vxlan_cleanup(struct mlx5e_priv *priv)
+{
+	struct mlx5e_vxlan_db *vxlan_db = &priv->vxlan;
+	struct mlx5e_vxlan *vxlan;
+	unsigned int port = 0;
+
+	spin_lock_irq(&vxlan_db->lock);
+	while (radix_tree_gang_lookup(&vxlan_db->tree, (void **)&vxlan, port, 1)) {
+		port = vxlan->udp_port;
+		spin_unlock_irq(&vxlan_db->lock);
+		__mlx5e_vxlan_core_del_port(priv, (u16)port);
+		spin_lock_irq(&vxlan_db->lock);
+	}
+	spin_unlock_irq(&vxlan_db->lock);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
new file mode 100644
index 0000000..a016850
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
@@ -0,0 +1,54 @@
+/*
+ * Copyright (c) 2016, Mellanox Technologies, Ltd.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#ifndef __MLX5_VXLAN_H__
+#define __MLX5_VXLAN_H__
+
+#include <linux/mlx5/driver.h>
+#include "en.h"
+
+struct mlx5e_vxlan {
+	u16 udp_port;
+};
+
+static inline bool mlx5e_vxlan_allowed(struct mlx5_core_dev *mdev)
+{
+	return (MLX5_CAP_ETH(mdev, tunnel_stateless_vxlan) &&
+		mlx5_core_is_pf(mdev));
+}
+
+void mlx5e_vxlan_init(struct mlx5e_priv *priv);
+int  mlx5e_vxlan_add_port(struct mlx5e_priv *priv, u16 port);
+void mlx5e_vxlan_del_port(struct mlx5e_priv *priv, u16 port);
+struct mlx5e_vxlan *mlx5e_vxlan_lookup_port(struct mlx5e_priv *priv, u16 port);
+void mlx5e_vxlan_cleanup(struct mlx5e_priv *priv);
+
+#endif /* __MLX5_VXLAN_H__ */
-- 
1.7.1
