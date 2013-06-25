From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 02/10] net/mlx4_en: Do not query stats when device port is down
Date: Tue, 25 Jun 2013 12:09:30 +0300
Message-ID: <1372151378-21468-3-git-send-email-ogerlitz@mellanox.com>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jack Morgenstein <jackm@dev.mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52112 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751461Ab3FYJKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:25 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.com>

There are no counters allocated to the eth device when the port is down, so
this query is meaningless at that time.

It also leads to querying incorrect counters (since the counter_index is not
valid when the device port is down).

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 7299ada..c0b02d7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1375,12 +1375,13 @@ static void mlx4_en_do_get_stats(struct work_struct *work)
 
 	mutex_lock(&mdev->state_lock);
 	if (mdev->device_up) {
-		err = mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 0);
-		if (err)
-			en_dbg(HW, priv, "Could not update stats\n");
+		if (priv->port_up) {
+			err = mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 0);
+			if (err)
+				en_dbg(HW, priv, "Could not update stats\n");
 
-		if (priv->port_up)
 			mlx4_en_auto_moderation(priv);
+		}
 
 		queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 	}
-- 
1.7.1
