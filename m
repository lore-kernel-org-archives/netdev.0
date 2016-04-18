From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 3/7] mlx4: protect mlx4_en_start_port in mlx4_en_restart with rtnl_lock
Date: Mon, 18 Apr 2016 21:19:44 +0200
Message-ID: <1461007188-1603-4-git-send-email-hannes@stressinduktion.org>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:37599 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751658AbcDRTUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 15:20:04 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 5447820DAF
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:20:03 -0400 (EDT)
In-Reply-To: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx4_en_start_port requires rtnl_lock to be held.

Cc: Eugenia Emantayev <eugenia@mellanox.com>
Cc: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b4b258c8ca47d4..8bd143dda95d11 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1856,6 +1856,7 @@ static void mlx4_en_restart(struct work_struct *work)
 
 	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
 
+	rtnl_lock();
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		mlx4_en_stop_port(dev, 1);
@@ -1863,6 +1864,7 @@ static void mlx4_en_restart(struct work_struct *work)
 			en_err(priv, "Failed restarting port %d\n", priv->port);
 	}
 	mutex_unlock(&mdev->state_lock);
+	rtnl_unlock();
 }
 
 static void mlx4_en_clear_stats(struct net_device *dev)
-- 
2.5.5
