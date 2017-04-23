From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 6/7] net/mlx5e: Fix small packet threshold
Date: Sun, 23 Apr 2017 13:08:01 +0300
Message-ID: <20170423100802.27630-7-saeedm@mellanox.com>
References: <20170423100802.27630-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48694 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1044748AbdDWKIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 06:08:12 -0400
In-Reply-To: <20170423100802.27630-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

RX packet headers are meant to be contained in SKB linear part,
and chose a threshold of 128.
It turns out this is not enough, i.e. for IPv6 packet over VxLAN.
In this case, UDP/IPv4 needs 42 bytes, GENEVE header is 8 bytes,
and 86 bytes for TCP/IPv6. In total 136 bytes that is more than
current 128 bytes. In this case expand header flow is reached.
The warning in skb_try_coalesce() caused by a wrong truesize
was already fixed here:
commit 158f323b9868 ("net: adjust skb->truesize in pskb_expand_head()").
Still, we prefer to totally avoid the expand header flow for performance reasons.
Tested regular TCP_STREAM with iperf for 1 and 8 streams, no degradation was found.

Fixes: 461017cb006a ("net/mlx5e: Support RX multi-packet WQE (Striding RQ)")
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index dc52053128bc..3d9490cd2db1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -90,7 +90,7 @@
 #define MLX5E_VALID_NUM_MTTS(num_mtts) (MLX5_MTT_OCTW(num_mtts) - 1 <= U16_MAX)
 
 #define MLX5_UMR_ALIGN				(2048)
-#define MLX5_MPWRQ_SMALL_PACKET_THRESHOLD	(128)
+#define MLX5_MPWRQ_SMALL_PACKET_THRESHOLD	(256)
 
 #define MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ                 (64 * 1024)
 #define MLX5E_DEFAULT_LRO_TIMEOUT                       32
-- 
2.11.0
