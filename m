From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 3/7] mlx4_en: Incoming traffic alignment optimizations
Date: Mon, 17 Oct 2011 22:17:23 +0200
Message-ID: <4E9C8D53.5040006@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:35020 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754371Ab1JQWYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 18:24:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Packet headers are copied to skb linear part (which is IP aligned), so there is no reason for
the scatter entry to be IP aligned.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |   12 +++---------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    2 +-
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index fbf1dcf..8ae1eb5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -744,15 +744,9 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 			(eff_mtu > buf_size + frag_sizes[i]) ?
 				frag_sizes[i] : eff_mtu - buf_size;
 		priv->frag_info[i].frag_prefix_size = buf_size;
-		if (!i)	{
-			priv->frag_info[i].frag_align = NET_IP_ALIGN;
-			priv->frag_info[i].frag_stride =
-				ALIGN(frag_sizes[i] + NET_IP_ALIGN, SMP_CACHE_BYTES);
-		} else {
-			priv->frag_info[i].frag_align = 0;
-			priv->frag_info[i].frag_stride =
-				ALIGN(frag_sizes[i], SMP_CACHE_BYTES);
-		}
+		priv->frag_info[i].frag_align = 0;
+		priv->frag_info[i].frag_stride =
+			ALIGN(frag_sizes[i], SMP_CACHE_BYTES);
 		priv->frag_info[i].last_offset = mlx4_en_last_alloc_offset(
 						priv, priv->frag_info[i].frag_stride,
 						priv->frag_info[i].frag_align);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 3b753f7..013cda2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -91,7 +91,7 @@
 /* Receive fragment sizes; we use at most 4 fragments (for 9600 byte MTU
  * and 4K allocations) */
 enum {
-	FRAG_SZ0 = 512 - NET_IP_ALIGN,
+	FRAG_SZ0 = 2048,
 	FRAG_SZ1 = 1024,
 	FRAG_SZ2 = 4096,
 	FRAG_SZ3 = MLX4_EN_ALLOC_SIZE
-- 
1.7.7
