From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 4/8] mlx4_en: Work with part of the ports.
Date: Tue, 02 Jun 2009 12:22:18 +0300
Message-ID: <4A24EF4A.80704@mellanox.co.il>
References: <4A0AB34A.10100@mellanox.co.il><4A1948D7.8010504@mellanox.co.il><4A1A57AA.1080209@mellanox.co.il> <20090525.014435.203274473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39877 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758708AbZFBIbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 04:31:36 -0400
In-Reply-To: <20090525.014435.203274473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the initialization of one of the ports failed,
there is no need to fail the other one as well.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c |   19 +------------------
 1 files changed, 1 insertions(+), 18 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 23955d8..b510000 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -248,28 +248,11 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	/* Create a netdev for each port */
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
 		mlx4_info(mdev, "Activating port:%d\n", i);
-		if (mlx4_en_init_netdev(mdev, i, &mdev->profile.prof[i])) {
+		if (mlx4_en_init_netdev(mdev, i, &mdev->profile.prof[i]))
 			mdev->pndev[i] = NULL;
-			goto err_free_netdev;
-		}
 	}
 	return mdev;
 
-
-err_free_netdev:
-	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
-		if (mdev->pndev[i])
-			mlx4_en_destroy_netdev(mdev->pndev[i]);
-	}
-
-	mutex_lock(&mdev->state_lock);
-	mdev->device_up = false;
-	mutex_unlock(&mdev->state_lock);
-	flush_workqueue(mdev->workqueue);
-
-	/* Stop event queue before we drop down to release shared SW state */
-	destroy_workqueue(mdev->workqueue);
-
 err_mr:
 	mlx4_mr_free(dev, &mdev->mr);
 err_uar:
-- 
1.6.0


