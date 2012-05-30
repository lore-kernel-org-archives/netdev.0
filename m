From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 3/6] net/mlx4_en: Fix improper use of "port" parameter in mlx4_en_event
Date: Wed, 30 May 2012 22:14:52 +0300
Message-ID: <1338405295-15427-4-git-send-email-yevgenyp@mellanox.com>
References: <1338405295-15427-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:57580 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751184Ab2E3TPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 15:15:03 -0400
In-Reply-To: <1338405295-15427-1-git-send-email-yevgenyp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Port is used as an array index before we know if that is proper.

For example, in the catas event case, port is zero; however,
the port index should lie in the range (1..2).

Fix this by using 'port' only in the events where it is of interest.

Test for port out of range in the default (unhandled event) case,
and do not output a message if it is not an ethernet port.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 988b242..69ba572 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -136,13 +136,12 @@ static void mlx4_en_event(struct mlx4_dev *dev, void *endev_ptr,
 	struct mlx4_en_dev *mdev = (struct mlx4_en_dev *) endev_ptr;
 	struct mlx4_en_priv *priv;
 
-	if (!mdev->pndev[port])
-		return;
-
-	priv = netdev_priv(mdev->pndev[port]);
 	switch (event) {
 	case MLX4_DEV_EVENT_PORT_UP:
 	case MLX4_DEV_EVENT_PORT_DOWN:
+		if (!mdev->pndev[port])
+			return;
+		priv = netdev_priv(mdev->pndev[port]);
 		/* To prevent races, we poll the link state in a separate
 		  task rather than changing it here */
 		priv->link_state = event;
@@ -154,7 +153,10 @@ static void mlx4_en_event(struct mlx4_dev *dev, void *endev_ptr,
 		break;
 
 	default:
-		mlx4_warn(mdev, "Unhandled event: %d\n", event);
+		if (port < 1 || port > dev->caps.num_ports ||
+		    !mdev->pndev[port])
+			return;
+		mlx4_warn(mdev, "Unhandled event %d for port %d\n", event, port);
 	}
 }
 
-- 
1.7.1
