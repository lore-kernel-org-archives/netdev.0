From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] mlx4_en: Fix cleanup if workqueue create in mlx4_en_add() fails
Date: Mon, 20 Apr 2009 21:32:08 -0700
Message-ID: <adavdoywrsn.fsf_-_@cisco.com>
References: <49EC859C.700@mellanox.co.il> <49EC85FD.2080009@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:62289 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbZDUEcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 00:32:09 -0400
In-Reply-To: <49EC85FD.2080009@mellanox.co.il> (Yevgeny Petrilin's message of
	"Mon, 20 Apr 2009 17:26:05 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If creating a workqueue fails, don't jump to the error path where that
same workqueue is destroyed, since destroy_workqueue() can't handle a
NULL pointer.

This was spotted by the Coverity checker (CID 2617).

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/mlx4/en_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index eda72dd..510633f 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -181,7 +181,7 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	mdev->workqueue = create_singlethread_workqueue("mlx4_en");
 	if (!mdev->workqueue) {
 		err = -ENOMEM;
-		goto err_close_nic;
+		goto err_mr;
 	}
 
 	/* At this stage all non-port specific tasks are complete:
@@ -214,9 +214,8 @@ err_free_netdev:
 	flush_workqueue(mdev->workqueue);
 
 	/* Stop event queue before we drop down to release shared SW state */
-
-err_close_nic:
 	destroy_workqueue(mdev->workqueue);
+
 err_mr:
 	mlx4_mr_free(dev, &mdev->mr);
 err_uar:
