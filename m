From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/4] net/mlx4_en: Prepare ethtool private flags to support more flags
Date: Mon, 27 Jul 2015 14:46:32 +0300
Message-ID: <1437997594-8506-3-git-send-email-amirv@mellanox.com>
References: <1437997594-8506-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56761 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752279AbbG0LrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 07:47:16 -0400
In-Reply-To: <1437997594-8506-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Currently we support only one ethtool private flag. Prepare
mlx4_en_set_priv_flags function to support more than one private flag.
Will be used in the next patch to support hardware accelerated 802.1ad
vlan.


Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 35 ++++++++++++-------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 99ba1c5..70f6553 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1801,30 +1801,29 @@ static int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
 	bool bf_enabled_old = !!(priv->pflags & MLX4_EN_PRIV_FLAGS_BLUEFLAME);
 	int i;
 
-	if (bf_enabled_new == bf_enabled_old)
-		return 0; /* Nothing to do */
+	if (bf_enabled_new != bf_enabled_old) {
+		if (bf_enabled_new) {
+			bool bf_supported = true;
 
-	if (bf_enabled_new) {
-		bool bf_supported = true;
+			for (i = 0; i < priv->tx_ring_num; i++)
+				bf_supported &= priv->tx_ring[i]->bf_alloced;
 
-		for (i = 0; i < priv->tx_ring_num; i++)
-			bf_supported &= priv->tx_ring[i]->bf_alloced;
+			if (!bf_supported) {
+				en_err(priv, "BlueFlame is not supported\n");
+				return -EINVAL;
+			}
 
-		if (!bf_supported) {
-			en_err(priv, "BlueFlame is not supported\n");
-			return -EINVAL;
+			priv->pflags |= MLX4_EN_PRIV_FLAGS_BLUEFLAME;
+		} else {
+			priv->pflags &= ~MLX4_EN_PRIV_FLAGS_BLUEFLAME;
 		}
 
-		priv->pflags |= MLX4_EN_PRIV_FLAGS_BLUEFLAME;
-	} else {
-		priv->pflags &= ~MLX4_EN_PRIV_FLAGS_BLUEFLAME;
-	}
-
-	for (i = 0; i < priv->tx_ring_num; i++)
-		priv->tx_ring[i]->bf_enabled = bf_enabled_new;
+		for (i = 0; i < priv->tx_ring_num; i++)
+			priv->tx_ring[i]->bf_enabled = bf_enabled_new;
 
-	en_info(priv, "BlueFlame %s\n",
-		bf_enabled_new ?  "Enabled" : "Disabled");
+		en_info(priv, "BlueFlame %s\n",
+			bf_enabled_new ?  "Enabled" : "Disabled");
+	}
 
 	return 0;
 }
-- 
2.4.3.413.ga5fe668
