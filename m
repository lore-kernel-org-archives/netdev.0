From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 2/8] mlx4: add rtnl lock protection in mlx4_en_restart
Date: Thu,  7 Jan 2016 00:39:25 +0100
Message-ID: <1452123571-19140-3-git-send-email-hannes@stressinduktion.org>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Eugenia Emantayev <eugenia@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:38270 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752515AbcAFXjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:39:43 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id B631120566
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 18:39:42 -0500 (EST)
In-Reply-To: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't really understand the use of the state_lock. Can't it be simply
replaced by rtnl_lock? It seems a lot of current users depend on
rtnl_lock anyway.

Anyway, fix this up for the moment.

Cc: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0c7e3f69a73bb6..94abd0843901cf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1846,6 +1846,7 @@ static void mlx4_en_restart(struct work_struct *work)
 
 	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
 
+	rtnl_lock();
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		mlx4_en_stop_port(dev, 1);
@@ -1853,6 +1854,7 @@ static void mlx4_en_restart(struct work_struct *work)
 			en_err(priv, "Failed restarting port %d\n", priv->port);
 	}
 	mutex_unlock(&mdev->state_lock);
+	rtnl_unlock();
 }
 
 static void mlx4_en_clear_stats(struct net_device *dev)
-- 
2.5.0
