From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next V2 1/6] net/mlx5: Fix static checker warnings
Date: Tue,  7 Feb 2017 01:38:24 +0200
Message-ID: <20170206233829.29716-2-saeedm@mellanox.com>
References: <20170206233829.29716-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52046 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751456AbdBFXjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 18:39:01 -0500
In-Reply-To: <20170206233829.29716-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

For some reason, sparse doesn't like using an expression of type (!x)
with a bitwise | and &.  In order to mitigate that, we use a local variable.

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
 include/linux/mlx5/device.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 7b6cd67a263f..dd9a263ed368 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -67,10 +67,11 @@
 
 /* insert a value to a struct */
 #define MLX5_SET(typ, p, fld, v) do { \
+	u32 _v = v; \
 	BUILD_BUG_ON(__mlx5_st_sz_bits(typ) % 32);             \
 	*((__be32 *)(p) + __mlx5_dw_off(typ, fld)) = \
 	cpu_to_be32((be32_to_cpu(*((__be32 *)(p) + __mlx5_dw_off(typ, fld))) & \
-		     (~__mlx5_dw_mask(typ, fld))) | (((v) & __mlx5_mask(typ, fld)) \
+		     (~__mlx5_dw_mask(typ, fld))) | (((_v) & __mlx5_mask(typ, fld)) \
 		     << __mlx5_dw_bit_off(typ, fld))); \
 } while (0)
 
-- 
2.11.0
