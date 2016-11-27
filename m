From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 03/10] net/mlx4_en: Add new FDB entry only if there is space in the mac table
Date: Sun, 27 Nov 2016 17:51:10 +0200
Message-ID: <1480261877-19720-4-git-send-email-tariqt@mellanox.com>
References: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50459 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753079AbcK0Pve (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:51:34 -0500
In-Reply-To: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

Before adding a new mac to the FDB (Forwarding Database),
make sure there is space for it. Each port has 128
macs that are allocated between the hypervisor and the VFs.
If there is no space, return error.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 6 ++++++
 drivers/net/ethernet/mellanox/mlx4/port.c      | 8 ++++++++
 include/linux/mlx4/device.h                    | 1 +
 3 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9018bb1b2e12..60c3b2da8714 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1123,6 +1123,12 @@ static void mlx4_en_do_uc_filter(struct mlx4_en_priv *priv,
 			}
 			mac = mlx4_mac_to_u64(ha->addr);
 			memcpy(entry->mac, ha->addr, ETH_ALEN);
+
+			if (!mlx4_is_available_mac(mdev->dev, priv->port)) {
+				mlx4_warn(mdev, "Cannot add mac:%pM, no free macs.\n", &mac);
+				break;
+			}
+
 			err = mlx4_register_mac(mdev->dev, priv->port, mac);
 			if (err < 0) {
 				en_err(priv, "Failed registering MAC %pM on port %d: %d\n",
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 86cb58690845..ccc4670f92b5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -2104,3 +2104,11 @@ int mlx4_get_port_free_macs(struct mlx4_dev *mdev, int port)
 		mlx4_get_port_total_macs(mdev, port));
 }
 EXPORT_SYMBOL(mlx4_get_port_free_macs);
+
+bool mlx4_is_available_mac(struct mlx4_dev *mdev, int port)
+{
+	int free_macs = mlx4_get_port_free_macs(mdev, port);
+
+	return free_macs >= MLX4_VF_MAC_QUOTA;
+}
+EXPORT_SYMBOL(mlx4_is_available_mac);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 4220fe8fe094..1dcd6ac3b1f3 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1494,6 +1494,7 @@ struct mlx4_slaves_pport mlx4_phys_to_slaves_pport_actv(
 
 int mlx4_config_vxlan_port(struct mlx4_dev *dev, __be16 udp_port);
 int mlx4_get_port_free_macs(struct mlx4_dev *mdev, int port);
+bool mlx4_is_available_mac(struct mlx4_dev *mdev, int port);
 int mlx4_disable_rx_port_check(struct mlx4_dev *dev, bool dis);
 int mlx4_config_roce_v2_port(struct mlx4_dev *dev, u16 udp_port);
 int mlx4_virt2phy_port_map(struct mlx4_dev *dev, u32 port1, u32 port2);
-- 
1.8.3.1
