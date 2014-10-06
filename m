From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 04/14] net/mlx4_en: tx_info allocated with kmalloc() instead of vmalloc()
Date: Mon,  6 Oct 2014 09:15:53 +0300
Message-ID: <1412576163-7224-5-git-send-email-amirv@mellanox.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37929 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751343AbaJFGQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 02:16:33 -0400
In-Reply-To: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Try to allocate using kmalloc_node() first, only on failure use
vmalloc()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 3ea17f9..02ade59 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -68,7 +68,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	ring->inline_thold = priv->prof->inline_thold;
 
 	tmp = size * sizeof(struct mlx4_en_tx_info);
-	ring->tx_info = vmalloc_node(tmp, node);
+	ring->tx_info = kmalloc_node(tmp, GFP_KERNEL | __GFP_NOWARN, node);
 	if (!ring->tx_info) {
 		ring->tx_info = vmalloc(tmp);
 		if (!ring->tx_info) {
@@ -151,7 +151,7 @@ err_bounce:
 	kfree(ring->bounce_buf);
 	ring->bounce_buf = NULL;
 err_info:
-	vfree(ring->tx_info);
+	kvfree(ring->tx_info);
 	ring->tx_info = NULL;
 err_ring:
 	kfree(ring);
@@ -174,7 +174,7 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 	kfree(ring->bounce_buf);
 	ring->bounce_buf = NULL;
-	vfree(ring->tx_info);
+	kvfree(ring->tx_info);
 	ring->tx_info = NULL;
 	kfree(ring);
 	*pring = NULL;
-- 
1.8.3.1
