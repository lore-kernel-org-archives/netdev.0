From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/7] net/mlx4_en: Issue the dump eth statistics command under lock
Date: Wed, 16 Jan 2013 17:42:09 +0200
Message-ID: <1358350935-3281-2-git-send-email-amirv@mellanox.com>
References: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:38518 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753876Ab3APPmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 10:42:44 -0500
In-Reply-To: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Performing the DUMP_ETH_STATS firmware command outside the lock leads to kernel
panic when data structures such as RX/TX rings are freed in parallel, e.g when
one changes the mtu or ring sizes.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b467513..b6c645f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -977,12 +977,12 @@ static void mlx4_en_do_get_stats(struct work_struct *work)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err;
 
-	err = mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 0);
-	if (err)
-		en_dbg(HW, priv, "Could not update stats\n");
-
 	mutex_lock(&mdev->state_lock);
 	if (mdev->device_up) {
+		err = mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 0);
+		if (err)
+			en_dbg(HW, priv, "Could not update stats\n");
+
 		if (priv->port_up)
 			mlx4_en_auto_moderation(priv);
 
-- 
1.7.8.2
