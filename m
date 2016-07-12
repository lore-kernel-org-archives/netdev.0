From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 2/2] net/mlx5e: start/stop all tx queues upon open/close netdev
Date: Wed, 13 Jul 2016 00:07:00 +0300
Message-ID: <1468357620-27831-3-git-send-email-saeedm@mellanox.com>
References: <1468357620-27831-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40574 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750938AbcGLVHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 17:07:48 -0400
In-Reply-To: <1468357620-27831-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Start all tx queues (including inactive ones) when opening the netdev.
Stop all tx queues (including inactive ones) when closing the netdev.

This is a workaround for the tx timeout watchdog false alarm issue in
which the netdev watchdog is polling all the tx queues which may include
inactive queues and thus once lowering the real tx queues number
(ethtool -L) it will generate tx timeout watchdog false alarms.

Fixes: 3947ca185999 ('net/mlx5e: Implement ndo_tx_timeout callback')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0cebc7e..5a4d88c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1348,6 +1348,11 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv)
 			goto err_close_channels;
 	}
 
+	/* FIXME: This is a W/A for tx timeout watch dog false alarm when
+	 * polling for inactive tx queues.
+	 */
+	netif_tx_start_all_queues(priv->netdev);
+
 	kfree(cparam);
 	return 0;
 
@@ -1367,6 +1372,12 @@ static void mlx5e_close_channels(struct mlx5e_priv *priv)
 {
 	int i;
 
+	/* FIXME: This is a W/A only for tx timeout watch dog false alarm when
+	 * polling for inactive tx queues.
+	 */
+	netif_tx_stop_all_queues(priv->netdev);
+	netif_tx_disable(priv->netdev);
+
 	for (i = 0; i < priv->params.num_channels; i++)
 		mlx5e_close_channel(priv->channel[i]);
 
-- 
2.8.0
