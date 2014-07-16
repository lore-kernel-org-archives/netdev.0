From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_en: cq->irq_desc wasn't set in legacy EQ's
Date: Wed, 16 Jul 2014 13:33:50 +0300
Message-ID: <1405506830-12178-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39583 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751705AbaGPKeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 06:34:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a regression introduced by commit 35f6f45 ("net/mlx4_en: Don't use
irq_affinity_notifier to track changes in IRQ affinity map").
When core is started in legacy EQ's (number of IRQ's < rx rings), cq->irq_desc
was NULL.  This caused a kernel crash under heavy traffic - when having more
than rx NAPI budget completions.
Fixed to have it set for both EQ modes.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 14c0004..82322b1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -129,14 +129,15 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 						  name);
 				}
 
-				cq->irq_desc =
-					irq_to_desc(mlx4_eq_get_irq(mdev->dev,
-								    cq->vector));
 			}
 		} else {
 			cq->vector = (cq->ring + 1 + priv->port) %
 				mdev->dev->caps.num_comp_vectors;
 		}
+
+		cq->irq_desc =
+			irq_to_desc(mlx4_eq_get_irq(mdev->dev,
+						    cq->vector));
 	} else {
 		/* For TX we use the same irq per
 		ring we assigned for the RX    */
-- 
1.8.3.4
