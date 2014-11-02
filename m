From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 4/5] net/mlx4_en: Add __GFP_COLD gfp flags in alloc_pages
Date: Sun,  2 Nov 2014 16:26:16 +0200
Message-ID: <1414938377-421-5-git-send-email-ogerlitz@mellanox.com>
References: <1414938377-421-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52344 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751391AbaKBO01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2014 09:26:27 -0500
In-Reply-To: <1414938377-421-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Needed in order to get cache cold pages (L3 flushed) for HW scatter.

Otherwise memory may flush those entries when the packet comes from
PCI, causing back pressure resulting in BW decrease.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 4cb716f..317abc9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -156,7 +156,7 @@ static int mlx4_en_init_allocator(struct mlx4_en_priv *priv,
 		const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
 
 		if (mlx4_alloc_pages(priv, &ring->page_alloc[i],
-				     frag_info, GFP_KERNEL))
+				     frag_info, GFP_KERNEL | __GFP_COLD))
 			goto out;
 	}
 	return 0;
@@ -268,7 +268,7 @@ static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 
 			if (mlx4_en_prepare_rx_desc(priv, ring,
 						    ring->actual_size,
-						    GFP_KERNEL)) {
+						    GFP_KERNEL | __GFP_COLD)) {
 				if (ring->actual_size < MLX4_EN_MIN_RX_SIZE) {
 					en_err(priv, "Failed to allocate enough rx buffers\n");
 					return -ENOMEM;
@@ -635,7 +635,8 @@ static void mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
 	int index = ring->prod & ring->size_mask;
 
 	while ((u32) (ring->prod - ring->cons) < ring->actual_size) {
-		if (mlx4_en_prepare_rx_desc(priv, ring, index, GFP_ATOMIC))
+		if (mlx4_en_prepare_rx_desc(priv, ring, index,
+					    GFP_ATOMIC | __GFP_COLD))
 			break;
 		ring->prod++;
 		index = ring->prod & ring->size_mask;
-- 
1.7.1
