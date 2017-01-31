From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 1/8] net/mlx5: Fixed static checker warnings
Date: Tue, 31 Jan 2017 22:58:36 +0200
Message-ID: <20170131205843.23235-2-saeedm@mellanox.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60062 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751106AbdAaVFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 16:05:39 -0500
In-Reply-To: <20170131205843.23235-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

For some reason, sparse doesn't like using an expression of type (!x)
with a bitwise | and &.  In order to mitigate that, we use a local
variable.

Since getting a typeof(bitfield) is incorrect, we cast such cases.

This removes the following sparse complaints on the core driver
(and similar ones on the IB driver too):

drivers/net/ethernet/mellanox/mlx5/core/srq.c:83:9: warning: dubious: !x & y
drivers/net/ethernet/mellanox/mlx5/core/srq.c:96:9: warning: dubious: !x & y
drivers/net/ethernet/mellanox/mlx5/core/port.c:59:9: warning: dubious: !x & y
drivers/net/ethernet/mellanox/mlx5/core/vport.c:561:9: warning: dubious: !x & y

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Reported-by: Bart Van Assche <bart.vanassche@sandisk.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 8 ++++----
 include/linux/mlx5/device.h                     | 3 ++-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 640f10f2e994..f00855920894 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -487,11 +487,11 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 			MLX5_SET(fte_match_set_lyr_2_4, headers_c, cvlan_tag, 1);
 			MLX5_SET(fte_match_set_lyr_2_4, headers_v, cvlan_tag, 1);
 
-			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_vid, mask->vlan_id);
-			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_vid, key->vlan_id);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_vid, (u16)mask->vlan_id);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_vid, (u16)key->vlan_id);
 
-			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_prio, mask->vlan_priority);
-			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_prio, key->vlan_priority);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_prio, (u8)mask->vlan_priority);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_prio, (u8)key->vlan_priority);
 		}
 	}
 
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 7b6cd67a263f..dd0b253bd15d 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -67,10 +67,11 @@
 
 /* insert a value to a struct */
 #define MLX5_SET(typ, p, fld, v) do { \
+	typeof(v) _v = v; \
 	BUILD_BUG_ON(__mlx5_st_sz_bits(typ) % 32);             \
 	*((__be32 *)(p) + __mlx5_dw_off(typ, fld)) = \
 	cpu_to_be32((be32_to_cpu(*((__be32 *)(p) + __mlx5_dw_off(typ, fld))) & \
-		     (~__mlx5_dw_mask(typ, fld))) | (((v) & __mlx5_mask(typ, fld)) \
+		     (~__mlx5_dw_mask(typ, fld))) | (((_v) & __mlx5_mask(typ, fld)) \
 		     << __mlx5_dw_bit_off(typ, fld))); \
 } while (0)
 
-- 
2.11.0
