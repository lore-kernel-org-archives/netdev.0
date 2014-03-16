From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: mlx4 netpoll and rx/tx weirdness
Date: Sun, 16 Mar 2014 09:17:01 -0700
Message-ID: <1394986621.9668.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871ty41dps.fsf_-_@xmission.com>
	 <87lhwcw9j9.fsf_-_@xmission.com>
	 <1394897014.15764.26.camel@deadeye.wl.decadent.org.uk>
	 <20140315.122912.1621610280186900725.davem@davemloft.net>
	 <87ob17kz96.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ben@decadent.org.uk,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:62914 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbaCPQRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 12:17:04 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so4680918pbc.18
        for <netdev@vger.kernel.org>; Sun, 16 Mar 2014 09:17:03 -0700 (PDT)
In-Reply-To: <87ob17kz96.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-15 at 13:01 -0700, Eric W. Biederman wrote:

> Given this comment I have to ask:  How insane is the mellanox mlx4
> driver that has separate rx and tx queues, separate rx and tx interrupts
> and uses separate napi bottom halves to process each, and honors the
> budget passed into it's rx napi handler.

I believe this driver had TX completion from hard irq, and NAPI polling
for RX.

This was changed quite recently to also do TX completion from softirq
handler.

> 
> Right now the mlx4 code disables interrupts and calls napi_synchronize
> in it's netpoll routine instead of just scheduling the napi bottom
> halves as all of the sane drivers do.  napi_synchronize trying to sleep
> in hard irq context is pretty terrible, but I can see roughly how that
> should be fixed.
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index fa5ee719e04b..2e6fded14e60 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1302,16 +1302,10 @@ out:
>  static void mlx4_en_netpoll(struct net_device *dev)
>  {
>         struct mlx4_en_priv *priv = netdev_priv(dev);
> -       struct mlx4_en_cq *cq;
> -       unsigned long flags;
>         int i;
>  
>         for (i = 0; i < priv->rx_ring_num; i++) {
> -               cq = priv->rx_cq[i];
> -               spin_lock_irqsave(&cq->lock, flags);
> -               napi_synchronize(&cq->napi);
> -               mlx4_en_process_rx_cq(dev, cq, 0);
> -               spin_unlock_irqrestore(&cq->lock, flags);
> +               napi_schedule(&priv->tx_cq[i]->napi);
>         }
>  }

Wait a minute, I thought ndo_poll_controller() had to be synchronous,
not schedule a napi ?

> 
> What I can't see is what is a clean thing to do with the mlx4 tx bottom
> napi bottom half.  As it won't processes the tx cq when I pass in a
> budget of 0.

Just ignore the budget to drain tx queues, as David said.

> 
> What I can't see is how to prevent a netpoll stalling after enough
> packets are transmitted from hard irq context say with sysrq-l on
> a machine with enough cpus to fill the tx queue.

Is this specific to mlx4 ?
