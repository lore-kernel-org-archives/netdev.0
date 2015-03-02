From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net 2/2] net/mlx4_en: Disbale GRO for incoming loopback/selftest packets
Date: Mon,  2 Mar 2015 18:22:16 +0200
Message-ID: <1425313336-28082-3-git-send-email-ogerlitz@mellanox.com>
References: <1425313336-28082-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37602 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753865AbbCBQW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 11:22:27 -0500
In-Reply-To: <1425313336-28082-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Packets which are sent from the selftest (ethtool) flow,
should not be passed to GRO stack but rather dropped by
the driver after validation. To achieve that, we disable
GRO for the duration of the selftest.

Fixes: dd65beac48a5 ("net/mlx4_en: Extend usage of napi_gro_frags")
Reported-by: Carol Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 2d8ee66..a61009f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -81,12 +81,14 @@ static int mlx4_en_test_loopback(struct mlx4_en_priv *priv)
 {
 	u32 loopback_ok = 0;
 	int i;
-
+	bool gro_enabled;
 
         priv->loopback_ok = 0;
 	priv->validate_loopback = 1;
+	gro_enabled = priv->dev->features & NETIF_F_GRO;
 
 	mlx4_en_update_loopback_state(priv->dev, priv->dev->features);
+	priv->dev->features &= ~NETIF_F_GRO;
 
 	/* xmit */
 	if (mlx4_en_test_loopback_xmit(priv)) {
@@ -108,6 +110,10 @@ static int mlx4_en_test_loopback(struct mlx4_en_priv *priv)
 mlx4_en_test_loopback_exit:
 
 	priv->validate_loopback = 0;
+
+	if (gro_enabled)
+		priv->dev->features |= NETIF_F_GRO;
+
 	mlx4_en_update_loopback_state(priv->dev, priv->dev->features);
 	return !loopback_ok;
 }
-- 
1.7.1
