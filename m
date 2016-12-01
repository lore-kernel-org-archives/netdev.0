From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: fix use-after-free in
 mlx4_en_fold_software_stats()
Date: Thu, 01 Dec 2016 05:02:06 -0800
Message-ID: <1480597326.18162.276.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130150839.5203ece0@redhat.com>
         <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
         <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
         <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161201133706.316428e9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35118 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754235AbcLANCJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 08:02:09 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so4614227pga.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 05:02:08 -0800 (PST)
In-Reply-To: <20161201133706.316428e9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

My recent commit to get more precise rx/tx counters in ndo_get_stats64()
can lead to crashes at device dismantle, as Jesper found out.

We must prevent mlx4_en_fold_software_stats() trying to access
tx/rx rings if they are deleted.

Fix this by adding a test against priv->port_up in
mlx4_en_fold_software_stats()

Calling mlx4_en_fold_software_stats() from mlx4_en_stop_port()
allows us to eventually broadcast the latest/current counters to
rtnetlink monitors.

Fixes: 40931b85113d ("mlx4: give precise rx/tx bytes/packets counters")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-and-bisected-by: Jesper Dangaard Brouer <brouer@redhat.com>
Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++++
 drivers/net/ethernet/mellanox/mlx4/en_port.c   |    2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 12ea3405f442717478bf0e8882edaf0de77986cb..091b904262bc7932d3edf99cf850affb23b9ce6e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1809,8 +1809,12 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 
 	netif_tx_disable(dev);
 
+	spin_lock_bh(&priv->stats_lock);
+	mlx4_en_fold_software_stats(dev);
 	/* Set port as not active */
 	priv->port_up = false;
+	spin_unlock_bh(&priv->stats_lock);
+
 	priv->counter_index = MLX4_SINK_COUNTER_INDEX(mdev->dev);
 
 	/* Promsicuous mode */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index c6c4f1238923e09eced547454b86c68720292859..9166d90e732858610b1407fe85cbf6cbe27f5e0b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -154,7 +154,7 @@ void mlx4_en_fold_software_stats(struct net_device *dev)
 	unsigned long packets, bytes;
 	int i;
 
-	if (mlx4_is_master(mdev->dev))
+	if (!priv->port_up || mlx4_is_master(mdev->dev))
 		return;
 
 	packets = 0;
