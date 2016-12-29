From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 3/5] net/mlx4: Remove BUG_ON from ICM allocation routine
Date: Thu, 29 Dec 2016 18:37:11 +0200
Message-ID: <1483029433-3624-4-git-send-email-tariqt@mellanox.com>
References: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51876 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753118AbcL2Qh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 11:37:58 -0500
In-Reply-To: <1483029433-3624-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

This patch removes BUG_ON() macro from mlx4_alloc_icm_coherent()
by checking DMA address alignment in advance and performing proper
folding in case of error.

Fixes: 5b0bf5e25efe ("mlx4_core: Support ICM tables in coherent memory")
Reported-by: Ozgur Karatas <okaratas@member.fsf.org>
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/icm.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
index 2a9dd460a95f..e1f9e7cebf8f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.c
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
@@ -118,8 +118,13 @@ static int mlx4_alloc_icm_coherent(struct device *dev, struct scatterlist *mem,
 	if (!buf)
 		return -ENOMEM;
 
+	if (offset_in_page(buf)) {
+		dma_free_coherent(dev, PAGE_SIZE << order,
+				  buf, sg_dma_address(mem));
+		return -ENOMEM;
+	}
+
 	sg_set_buf(mem, buf, PAGE_SIZE << order);
-	BUG_ON(mem->offset);
 	sg_dma_len(mem) = PAGE_SIZE << order;
 	return 0;
 }
-- 
1.8.3.1
