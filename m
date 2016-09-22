From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V3 3/5] net/mlx4_en: Disable vlan HW acceleration when in VF vlan protocol 802.1ad mode
Date: Thu, 22 Sep 2016 12:11:14 +0300
Message-ID: <1474535476-10662-4-git-send-email-tariqt@mellanox.com>
References: <1474535476-10662-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Moshe Shemesh <moshe@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Ariel Elior <ariel.elior@qlogic.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        Dept-GELinuxNICDev@qlogic.com,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>,
        Tariq Toukan <tariqt@mel
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43292 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756117AbcIVJME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 05:12:04 -0400
In-Reply-To: <1474535476-10662-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

In Ethernet VF, disable vlan HW acceleration on VF
while it is set to VF vlan protocol 802.1ad mode.

Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 62516f8369ba..a94f8a3f026c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -3224,6 +3224,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 
 	if (mlx4_is_slave(mdev->dev)) {
+		bool vlan_offload_disabled;
 		int phv;
 
 		err = get_phv_bit(mdev->dev, port, &phv);
@@ -3231,6 +3232,18 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			dev->hw_features |= NETIF_F_HW_VLAN_STAG_TX;
 			priv->pflags |= MLX4_EN_PRIV_FLAGS_PHV;
 		}
+		err = mlx4_get_is_vlan_offload_disabled(mdev->dev, port,
+							&vlan_offload_disabled);
+		if (!err && vlan_offload_disabled) {
+			dev->hw_features &= ~(NETIF_F_HW_VLAN_CTAG_TX |
+					      NETIF_F_HW_VLAN_CTAG_RX |
+					      NETIF_F_HW_VLAN_STAG_TX |
+					      NETIF_F_HW_VLAN_STAG_RX);
+			dev->features &= ~(NETIF_F_HW_VLAN_CTAG_TX |
+					   NETIF_F_HW_VLAN_CTAG_RX |
+					   NETIF_F_HW_VLAN_STAG_TX |
+					   NETIF_F_HW_VLAN_STAG_RX);
+		}
 	} else {
 		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PHV_EN &&
 		    !(mdev->dev->caps.flags2 &
-- 
1.8.3.1
