From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: change TX coalescing defaults
Date: Mon, 05 Nov 2012 18:20:42 -0800
Message-ID: <1352168442.3140.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Vimalkumar <j.vimal@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:40196 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933594Ab2KFCUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 21:20:45 -0500
Received: by mail-pa0-f46.google.com with SMTP id hz1so4380264pad.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 18:20:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

mlx4 currently uses a too high tx coalescing setting, deferring
TX completion interrupts by up to 128 us.

With the recent skb_orphan() removal in commit 8112ec3b872,
performance of a single TCP flow is capped to ~4 Gbps, unless
we increase tcp_limit_output_bytes.

I suggest using 16 us instead of 128 us, allowing a finer control.

Performance of a single TCP flow is restored to previous levels,
while keeping TCP small queues fully enabled with default sysctl.

This patch is also a BQL prereq.

Reported-by: Vimalkumar <j.vimal@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
---
By the way, is BQL addition planned for this driver ?

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index edd9cb8..2b23ca2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -870,7 +870,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 	/* If we haven't received a specific coalescing setting
 	 * (module param), we set the moderation parameters as follows:
 	 * - moder_cnt is set to the number of mtu sized packets to
-	 *   satisfy our coelsing target.
+	 *   satisfy our coalescing target.
 	 * - moder_time is set to a fixed value.
 	 */
 	priv->rx_frames = MLX4_EN_RX_COAL_TARGET;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 9d27e42..8a5e70d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -126,7 +126,7 @@ enum {
 #define MLX4_EN_RX_COAL_TIME	0x10
 
 #define MLX4_EN_TX_COAL_PKTS	16
-#define MLX4_EN_TX_COAL_TIME	0x80
+#define MLX4_EN_TX_COAL_TIME	0x10
 
 #define MLX4_EN_RX_RATE_LOW		400000
 #define MLX4_EN_RX_COAL_TIME_LOW	0
