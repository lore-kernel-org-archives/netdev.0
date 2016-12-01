From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets
 counters
Date: Thu, 1 Dec 2016 13:37:06 +0100
Message-ID: <20161201133706.316428e9@redhat.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161130150839.5203ece0@redhat.com>
        <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
        <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
        <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
        <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
        <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42872 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757155AbcLAMhK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 07:37:10 -0500
In-Reply-To: <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 30 Nov 2016 13:00:52 -0800 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2016-11-30 at 22:42 +0200, Saeed Mahameed wrote:
> > On Wed, Nov 30, 2016 at 7:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:  
> > > On Wed, 2016-11-30 at 18:46 +0200, Saeed Mahameed wrote:
[...]
> > >
> > > I am suggesting I will fix the bug I introduced.
> > >
> > > Do not panic.
> > >
> > >  
> > 
> > Not at all, I trust you are the only one who is capable of providing
> > the best solution.
> > I am just trying to read your mind :-).
> > 
> > As i said i like the solution and i want to adapt it to mlx5, so I am
> > a little bit enthusiastic :)  
> 
> What about the following fix guys ?

Confirming this fixed the crash on shutdown for me, thanks!

 
> As a bonus we update the stats right before they are sent to monitors
> via rtnetlink ;)
> 
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 12ea3405f442717478bf0e8882edaf0de77986cb..091b904262bc7932d3edf99cf850affb23b9ce6e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1809,8 +1809,12 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
>  
>  	netif_tx_disable(dev);
>  
> +	spin_lock_bh(&priv->stats_lock);
> +	mlx4_en_fold_software_stats(dev);
>  	/* Set port as not active */
>  	priv->port_up = false;
> +	spin_unlock_bh(&priv->stats_lock);
> +
>  	priv->counter_index = MLX4_SINK_COUNTER_INDEX(mdev->dev);
>  
>  	/* Promsicuous mode */
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
> index c6c4f1238923e09eced547454b86c68720292859..9166d90e732858610b1407fe85cbf6cbe27f5e0b 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
> @@ -154,7 +154,7 @@ void mlx4_en_fold_software_stats(struct net_device *dev)
>  	unsigned long packets, bytes;
>  	int i;
>  
> -	if (mlx4_is_master(mdev->dev))
> +	if (!priv->port_up || mlx4_is_master(mdev->dev))
>  		return;
>  
>  	packets = 0;
> 
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
