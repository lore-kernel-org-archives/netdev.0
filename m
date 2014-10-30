From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/8] net/mlx4_en: Remove RX buffers alignment to IP_ALIGN
Date: Thu, 30 Oct 2014 18:06:51 +0200
Message-ID: <1414685216-28907-4-git-send-email-ogerlitz@mellanox.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39652 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759458AbaJ3QHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 12:07:06 -0400
In-Reply-To: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

When IP_ALIGN has a non zero value, hardware will write to a non aligned
address. The only reader from this address is when copying the header
from the first frag into the linear buffer (further access to the IP
address will be from the linear buffer, in which the headers are
aligned). Since the penalty of non align access by the hardware is
greater than the software memcpy, changing the frag_align to always be 0.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |   16 ++++------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    1 -
 2 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c8e75da..4cb716f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -74,7 +74,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 	page_alloc->page_size = PAGE_SIZE << order;
 	page_alloc->page = page;
 	page_alloc->dma = dma;
-	page_alloc->page_offset = frag_info->frag_align;
+	page_alloc->page_offset = 0;
 	/* Not doing get_page() for each frag is a big win
 	 * on asymetric workloads. Note we can not use atomic_set().
 	 */
@@ -945,15 +945,8 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
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
+		priv->frag_info[i].frag_stride = ALIGN(frag_sizes[i],
+						       SMP_CACHE_BYTES);
 		buf_size += priv->frag_info[i].frag_size;
 		i++;
 	}
@@ -966,11 +959,10 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 	       eff_mtu, priv->num_frags);
 	for (i = 0; i < priv->num_frags; i++) {
 		en_err(priv,
-		       "  frag:%d - size:%d prefix:%d align:%d stride:%d\n",
+		       "  frag:%d - size:%d prefix:%d stride:%d\n",
 		       i,
 		       priv->frag_info[i].frag_size,
 		       priv->frag_info[i].frag_prefix_size,
-		       priv->frag_info[i].frag_align,
 		       priv->frag_info[i].frag_stride);
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6beb4d3..ef83d12 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -481,7 +481,6 @@ struct mlx4_en_frag_info {
 	u16 frag_size;
 	u16 frag_prefix_size;
 	u16 frag_stride;
-	u16 frag_align;
 };
 
 #ifdef CONFIG_MLX4_EN_DCB
-- 
1.7.1
