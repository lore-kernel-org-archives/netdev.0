From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 1/7] net/mlx5e: Avoid NULL pointer access in case of configuration failure
Date: Tue,  3 Nov 2015 08:07:18 +0200
Message-ID: <1446530844-14077-2-git-send-email-ogerlitz@mellanox.com>
References: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38556 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753089AbbKCGHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 01:07:52 -0500
In-Reply-To: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

In case a configuration operation that involves closing and re-opening
resources (e.g RX/TX queue size change) fails at the re-opening stage
these resources will remain closed.
So when executing (following) configuration operations (e.g ifconfig
down) we cannot assume that these resources are available.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index bb801a9..9df6f9a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1404,6 +1404,12 @@ int mlx5e_close_locked(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
+	/* May already be CLOSED in case a previous configuration operation
+	 * (e.g RX/TX queue size change) that involves close&open failed.
+	 */
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
+		return 0;
+
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
 
 	mlx5e_redirect_rqts(priv);
-- 
2.3.7
