From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 4/6] net/mlx4_core: Do not BUG_ON during reset when PCI is offline
Date: Wed, 17 Feb 2016 17:24:25 +0200
Message-ID: <1455722667-23179-5-git-send-email-ogerlitz@mellanox.com>
References: <1455722667-23179-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44376 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965188AbcBQPZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 10:25:26 -0500
In-Reply-To: <1455722667-23179-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

The PCI channel could go offline during reset due to EEH.  Don't bug on in
this case, the error is recoverable.

Fixes: f6bc11e42646 ('net/mlx4_core: Enhance the catas flow to support device reset')
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Reviewed-by: Yishai Hadas <yishaih@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/catas.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
index 715de8a..c7e9399 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -182,10 +182,17 @@ void mlx4_enter_error_state(struct mlx4_dev_persistent *persist)
 		err = mlx4_reset_slave(dev);
 	else
 		err = mlx4_reset_master(dev);
-	BUG_ON(err != 0);
 
+	if (!err) {
+		mlx4_err(dev, "device was reset successfully\n");
+	} else {
+		/* EEH could have disabled the PCI channel during reset. That's
+		 * recoverable and the PCI error flow will handle it.
+		 */
+		if (!pci_channel_offline(dev->persist->pdev))
+			BUG_ON(1);
+	}
 	dev->persist->state |= MLX4_DEVICE_STATE_INTERNAL_ERROR;
-	mlx4_err(dev, "device was reset successfully\n");
 	mutex_unlock(&persist->device_state_mutex);
 
 	/* At that step HW was already reset, now notify clients */
-- 
2.3.7
