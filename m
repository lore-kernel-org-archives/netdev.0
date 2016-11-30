From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets
 counters
Date: Wed, 30 Nov 2016 13:00:52 -0800
Message-ID: <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130150839.5203ece0@redhat.com>
         <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
         <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34439 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757050AbcK3VBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 16:01:54 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so2334239pgc.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 13:01:54 -0800 (PST)
In-Reply-To: <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 22:42 +0200, Saeed Mahameed wrote:
> On Wed, Nov 30, 2016 at 7:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2016-11-30 at 18:46 +0200, Saeed Mahameed wrote:
> >
> >> we had/still have the proper stats they are the ones that
> >> mlx4_en_fold_software_stats is trying to cache into  (they always
> >> exist),
> >> but the ones that you are trying to read from (the mlx4 rings) are gone !
> >>
> >> This bug is totally new and as i warned, this is another symptom of
> >> the real root cause (can't sleep while reading stats).
> >>
> >> Eric what do you suggest ? Keep pre-allocated MAX_RINGS stats  and
> >> always iterate over all of them to query stats ?
> >> what if you have one ring/none/1K ? how would you know how many to query ?
> >
> > I am suggesting I will fix the bug I introduced.
> >
> > Do not panic.
> >
> >
> 
> Not at all, I trust you are the only one who is capable of providing
> the best solution.
> I am just trying to read your mind :-).
> 
> As i said i like the solution and i want to adapt it to mlx5, so I am
> a little bit enthusiastic :)

What about the following fix guys ?

As a bonus we update the stats right before they are sent to monitors
via rtnetlink ;)


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
