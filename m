From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net 2/2] net/mlx5_core: Fix race on driver load
Date: Thu,  6 Nov 2014 12:51:22 +0200
Message-ID: <1415271082-7644-3-git-send-email-eli@mellanox.com>
References: <1415271082-7644-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	ogerlitz@mellanox.com, Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:48825 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbaKFKvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 05:51:37 -0500
Received: by mail-wg0-f48.google.com with SMTP id m15so852273wgh.21
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 02:51:36 -0800 (PST)
In-Reply-To: <1415271082-7644-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When events arrive at driver load, the event handler gets called even before
the spinlock and list are initialized. Fix this by moving the initialization
before EQs creation.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 88b2ffa0edfb..ecc6341e728a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -855,14 +855,14 @@ static int init_one(struct pci_dev *pdev,
 	dev->profile = &profile[prof_sel];
 	dev->event = mlx5_core_event;
 
+	INIT_LIST_HEAD(&priv->ctx_list);
+	spin_lock_init(&priv->ctx_lock);
 	err = mlx5_dev_init(dev, pdev);
 	if (err) {
 		dev_err(&pdev->dev, "mlx5_dev_init failed %d\n", err);
 		goto out;
 	}
 
-	INIT_LIST_HEAD(&priv->ctx_list);
-	spin_lock_init(&priv->ctx_lock);
 	err = mlx5_register_device(dev);
 	if (err) {
 		dev_err(&pdev->dev, "mlx5_register_device failed %d\n", err);
-- 
2.1.2
