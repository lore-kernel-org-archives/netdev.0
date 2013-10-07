From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net V1 2/2] net/mlx4_en: Fix pages never dma unmapped on rx
Date: Mon,  7 Oct 2013 13:38:13 +0200
Message-ID: <1381145893-20930-3-git-send-email-amirv@mellanox.com>
References: <1381145893-20930-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53114 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751520Ab3JGLiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Oct 2013 07:38:46 -0400
In-Reply-To: <1381145893-20930-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug introduced by commit 51151a16 (mlx4: allow
order-0 memory allocations in RX path).

dma_unmap_page never reached because condition to detect last fragment
in page is wrong. offset+frag_stride can't be greater than size, need to
make sure no additional frag will fit in page => compare offset +
frag_stride + next_frag_size instead.
next_frag_size is the same as the current one, since page is shared only
with frags of the same size.

CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
After looking at the code again, need to use 2*frag_stride and not to look at
size of next frag in skb. Changed it accordingly

 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 066fc27..afe2efa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -135,9 +135,10 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
 			      int i)
 {
 	const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
+	u32 next_frag_end = frags[i].page_offset + 2 * frag_info->frag_stride;
 
-	if (frags[i].page_offset + frag_info->frag_stride >
-	    frags[i].page_size)
+
+	if (next_frag_end > frags[i].page_size)
 		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].page_size,
 			       PCI_DMA_FROMDEVICE);
 
-- 
1.8.3.4
