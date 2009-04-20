From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 1/5] mlx4_en: Fix error handling while activating RX rings
Date: Mon, 20 Apr 2009 17:24:28 +0300
Message-ID: <49EC859C.700@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:38053 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756085AbZDTOZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 10:25:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of failure of either srq creation or page allocation,
the cleanup code handled the failed ring as well, and tried
to destroy resources that where not allocated.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_rx.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 7e40741..8673008 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -436,8 +436,9 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		/* Initialize page allocators */
 		err = mlx4_en_init_allocator(priv, ring);
 		if (err) {
-			 mlx4_err(mdev, "Failed initializing ring allocator\n");
-			 goto err_allocator;
+			mlx4_err(mdev, "Failed initializing ring allocator\n");
+			ring_ind--;
+			goto err_allocator;
 		}

 		/* Fill Rx buffers */
@@ -467,6 +468,7 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 				     ring->wqres.db.dma, &ring->srq);
 		if (err){
 			mlx4_err(mdev, "Failed to allocate srq\n");
+			ring_ind--;
 			goto err_srq;
 		}
 		ring->srq.event = mlx4_en_srq_event;
-- 
1.5.4

