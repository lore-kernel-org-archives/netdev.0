From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V3 5/8] net/mlx4_en: Adding support of turning off link autonegotiation via ethtool
Date: Sun, 29 Jan 2017 18:56:17 +0200
Message-ID: <1485708980-23468-6-git-send-email-tariqt@mellanox.com>
References: <1485708980-23468-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40222 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751842AbdA2Q5O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 11:57:14 -0500
In-Reply-To: <1485708980-23468-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Levkovich <lariel@mellanox.com>

This feature will allow the user to disable auto negotiation
on the port for mlx4 devices while setting the speed is limited
to 1GbE speeds.
Other speeds will not be accepted in autoneg off mode.

This functionality is permitted providing that the firmware
is compatible with this feature.
The above is determined by querying a new dedicated capability
bit in the device.

Signed-off-by: Ariel Levkovich <lariel@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 24 +++++++++++++++++++-----
 include/linux/mlx4/device.h                     |  7 ++++++-
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 785757f17687..ca730d4abbb4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -902,6 +902,7 @@ static __be32 speed_set_ptys_admin(struct mlx4_en_priv *priv, u32 speed,
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_ptys_reg ptys_reg;
 	__be32 proto_admin;
+	u8 cur_autoneg;
 	int ret;
 
 	u32 ptys_adv = ethtool2ptys_link_modes(
@@ -931,10 +932,21 @@ static __be32 speed_set_ptys_admin(struct mlx4_en_priv *priv, u32 speed,
 		return 0;
 	}
 
-	proto_admin = link_ksettings->base.autoneg == AUTONEG_ENABLE ?
-		cpu_to_be32(ptys_adv) :
-		speed_set_ptys_admin(priv, speed,
-				     ptys_reg.eth_proto_cap);
+	cur_autoneg = ptys_reg.flags & MLX4_PTYS_AN_DISABLE_ADMIN ?
+				AUTONEG_DISABLE : AUTONEG_ENABLE;
+
+	if (link_ksettings->base.autoneg == AUTONEG_DISABLE) {
+		proto_admin = speed_set_ptys_admin(priv, speed,
+						   ptys_reg.eth_proto_cap);
+		if ((be32_to_cpu(proto_admin) &
+		     (MLX4_PROT_MASK(MLX4_1000BASE_CX_SGMII) |
+		      MLX4_PROT_MASK(MLX4_1000BASE_KX))) &&
+		    (ptys_reg.flags & MLX4_PTYS_AN_DISABLE_CAP))
+			ptys_reg.flags |= MLX4_PTYS_AN_DISABLE_ADMIN;
+	} else {
+		proto_admin = cpu_to_be32(ptys_adv);
+		ptys_reg.flags &= ~MLX4_PTYS_AN_DISABLE_ADMIN;
+	}
 
 	proto_admin &= ptys_reg.eth_proto_cap;
 	if (!proto_admin) {
@@ -942,7 +954,9 @@ static __be32 speed_set_ptys_admin(struct mlx4_en_priv *priv, u32 speed,
 		return -EINVAL; /* nothing to change due to bad input */
 	}
 
-	if (proto_admin == ptys_reg.eth_proto_admin)
+	if ((proto_admin == ptys_reg.eth_proto_admin) &&
+	    ((ptys_reg.flags & MLX4_PTYS_AN_DISABLE_CAP) &&
+	     (link_ksettings->base.autoneg == cur_autoneg)))
 		return 0; /* Nothing to change */
 
 	en_dbg(DRV, priv, "mlx4_ACCESS_PTYS_REG SET: ptys_reg.eth_proto_admin = 0x%x\n",
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 6533c16e27ad..c3ac945b2759 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1539,8 +1539,13 @@ enum mlx4_ptys_proto {
 	MLX4_PTYS_EN = 1<<2,
 };
 
+enum mlx4_ptys_flags {
+	MLX4_PTYS_AN_DISABLE_CAP   = 1 << 5,
+	MLX4_PTYS_AN_DISABLE_ADMIN = 1 << 6,
+};
+
 struct mlx4_ptys_reg {
-	u8 resrvd1;
+	u8 flags;
 	u8 local_port;
 	u8 resrvd2;
 	u8 proto_mask;
-- 
1.8.3.1
