From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 1/6] net/mlx4_en: Issue the dump eth statistics command under lock
Date: Thu, 24 Jan 2013 13:54:14 +0200
Message-ID: <1359028459-30961-2-git-send-email-amirv@mellanox.com>
References: <1359028459-30961-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:38445 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752868Ab3AXLyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 06:54:39 -0500
In-Reply-To: <1359028459-30961-1-git-send-email-amirv@mellanox.com>
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
