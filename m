From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Fix pages never dma unmapped on rx
Date: Sun,  6 Oct 2013 14:57:20 +0200
Message-ID: <1381064240-12902-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39322 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752062Ab3JFM5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Oct 2013 08:57:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug introduced by commit 51151a16 (mlx4: allow
order-0 memory allocations in RX path).

dma_unmap_page never reached because condition to detect last fragment
in page is wrong. offset+frag_stride can't be greater than size, need to
make sure no additional frag will fit in page => compare offset +
frag_stride + next_frag_size instead.
next_frag_size could be next frag in the same skb, or the first frag in
the next.

CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index dec455c..44d8865 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -131,8 +131,11 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
 			      int i)
 {
 	const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
+	u16 next_frag_end = frags[i].offset + frag_info->frag_stride;
 
-	if (frags[i].offset + frag_info->frag_stride > frags[i].size)
+	next_frag_end += frags[(i + 1) % priv->num_frags].size;
+
+	if (next_frag_end > frags[i].size)
 		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].size,
 					 PCI_DMA_FROMDEVICE);
 
-- 
1.8.3.4
