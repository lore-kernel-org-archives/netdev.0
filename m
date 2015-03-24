From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_en: Call register_netdevice in the proper location
Date: Tue, 24 Mar 2015 15:18:38 +0200
Message-ID: <1427203119-27149-2-git-send-email-ogerlitz@mellanox.com>
References: <1427203119-27149-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49666 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752698AbbCXNSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 09:18:46 -0400
In-Reply-To: <1427203119-27149-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Netdevice registration should be performed a the end of the driver
initialization flow. If we don't do that, after calling register_netdevice,
device callbacks may be issued by higher layers of the stack before
final configuration of the device is done.

For example (VXLAN configuration race), mlx4_SET_PORT_VXLAN was issued
after the register_netdev command. System network scripts may configure
the interface (UP) right after the registration, which also attach
unicast VXLAN steering rule, before mlx4_SET_PORT_VXLAN was called,
causing the firmware to fail the rule attachment.

Fixes: 837052d0ccc5 ("net/mlx4_en: Add netdev support for TCP/IP offloads of vxlan tunneling")
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index ebce5bb..3485acf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2805,13 +2805,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	netif_carrier_off(dev);
 	mlx4_en_set_default_moderation(priv);
 
-	err = register_netdev(dev);
-	if (err) {
-		en_err(priv, "Netdev registration failed for port %d\n", port);
-		goto out;
-	}
-	priv->registered = 1;
-
 	en_warn(priv, "Using %d TX rings\n", prof->tx_ring_num);
 	en_warn(priv, "Using %d RX rings\n", prof->rx_ring_num);
 
@@ -2853,6 +2846,14 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	mlx4_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
 
+	err = register_netdev(dev);
+	if (err) {
+		en_err(priv, "Netdev registration failed for port %d\n", port);
+		goto out;
+	}
+
+	priv->registered = 1;
+
 	return 0;
 
 out:
-- 
1.7.1
