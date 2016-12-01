From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets
 counters
Date: Thu, 01 Dec 2016 07:55:29 -0800
Message-ID: <1480607729.18162.311.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130150839.5203ece0@redhat.com>
         <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
         <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
         <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8O28ZBS3sdqLpohPZtpLbLs228K4aO6hYd4URsA3yefA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33643 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754357AbcLAP4b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 10:56:31 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so4997528pgd.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 07:56:31 -0800 (PST)
In-Reply-To: <CALzJLG8O28ZBS3sdqLpohPZtpLbLs228K4aO6hYd4URsA3yefA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 17:38 +0200, Saeed Mahameed wrote:

> 
> Hi Eric, Thanks for the patch, I already acked it.

Thanks !

> 
> I have one educational question (not related to this patch, but
> related to stats reading in general).
> I was wondering why do we need to disable bh every time we read stats
> "spin_lock_bh" ? is it essential ?
> 
> I checked and in mlx4 we don't hold stats_lock in softirq
> (en_rx.c/en_tx.c), so I don't see any deadlock risk in here..

Excellent question, and I chose to keep the spinlock.

That would be doable, only if we do not overwrite dev->stats.

Current code is :

static struct rtnl_link_stats64 *
mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
{
        struct mlx4_en_priv *priv = netdev_priv(dev);

        spin_lock_bh(&priv->stats_lock);
        mlx4_en_fold_software_stats(dev);
        netdev_stats_to_stats64(stats, &dev->stats);
        spin_unlock_bh(&priv->stats_lock);

        return stats;
}

If you remove the spin_lock_bh() :

static struct rtnl_link_stats64 *
mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
{
        struct mlx4_en_priv *priv = netdev_priv(dev);

        mlx4_en_fold_software_stats(dev); // possible races

        netdev_stats_to_stats64(stats, &dev->stats);

        return stats;
}

1) one mlx4_en_fold_software_stats(dev) could be preempted
on a CONFIG_PREEMPT kernel, or interrupted by long irqs.

2) Another cpu would also call mlx4_en_fold_software_stats(dev) while
   first cpu is busy.

3) Then when resuming first cpu/thread, part of the dev->stats fieds 
would be updated with 'old counters',
while another thread might have updated them with newer values.

4) A SNMP reader could then get counters that are not monotonically
increasing,
which would be confusing/buggy.

So removing the spinlock is doable, but needs to add a new parameter
to mlx4_en_fold_software_stats() and call netdev_stats_to_stats64()
before mlx4_en_fold_software_stats(dev)

static struct rtnl_link_stats64 *
mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
{
        struct mlx4_en_priv *priv = netdev_priv(dev);

        netdev_stats_to_stats64(stats, &dev->stats);

	// Passing a non NULL stats asks mlx4_en_fold_software_stats()
	// to not update dev->stats, but stats directly.

        mlx4_en_fold_software_stats(dev, stats)


        return stats;
}
