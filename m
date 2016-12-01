From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Thu, 1 Dec 2016 18:33:50 +0200
Message-ID: <CALzJLG_=Z_anekLaiT0giK+RaOGRWmvK6MUP4UWXqsQQysR55w@mail.gmail.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161130150839.5203ece0@redhat.com> <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
 <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
 <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8O28ZBS3sdqLpohPZtpLbLs228K4aO6hYd4URsA3yefA@mail.gmail.com> <1480607729.18162.311.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:35936 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757295AbcLAQeN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:34:13 -0500
Received: by mail-lf0-f47.google.com with SMTP id t196so176013221lff.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:34:12 -0800 (PST)
In-Reply-To: <1480607729.18162.311.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 5:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-12-01 at 17:38 +0200, Saeed Mahameed wrote:
>
>>
>> Hi Eric, Thanks for the patch, I already acked it.
>
> Thanks !
>
>>
>> I have one educational question (not related to this patch, but
>> related to stats reading in general).
>> I was wondering why do we need to disable bh every time we read stats
>> "spin_lock_bh" ? is it essential ?
>>
>> I checked and in mlx4 we don't hold stats_lock in softirq
>> (en_rx.c/en_tx.c), so I don't see any deadlock risk in here..
>
> Excellent question, and I chose to keep the spinlock.
>
> That would be doable, only if we do not overwrite dev->stats.
>
> Current code is :
>
> static struct rtnl_link_stats64 *
> mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
> {
>         struct mlx4_en_priv *priv = netdev_priv(dev);
>
>         spin_lock_bh(&priv->stats_lock);
>         mlx4_en_fold_software_stats(dev);
>         netdev_stats_to_stats64(stats, &dev->stats);
>         spin_unlock_bh(&priv->stats_lock);
>
>         return stats;
> }
>
> If you remove the spin_lock_bh() :
>
>
> static struct rtnl_link_stats64 *
> mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
> {
>         struct mlx4_en_priv *priv = netdev_priv(dev);
>
>         mlx4_en_fold_software_stats(dev); // possible races
>
>         netdev_stats_to_stats64(stats, &dev->stats);
>
>         return stats;
> }
>
> 1) one mlx4_en_fold_software_stats(dev) could be preempted
> on a CONFIG_PREEMPT kernel, or interrupted by long irqs.
>
> 2) Another cpu would also call mlx4_en_fold_software_stats(dev) while
>    first cpu is busy.
>
> 3) Then when resuming first cpu/thread, part of the dev->stats fieds
> would be updated with 'old counters',
> while another thread might have updated them with newer values.
>
> 4) A SNMP reader could then get counters that are not monotonically
> increasing,
> which would be confusing/buggy.
>
> So removing the spinlock is doable, but needs to add a new parameter
> to mlx4_en_fold_software_stats() and call netdev_stats_to_stats64()
> before mlx4_en_fold_software_stats(dev)
>
> static struct rtnl_link_stats64 *
> mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
> {
>         struct mlx4_en_priv *priv = netdev_priv(dev);
>
>         netdev_stats_to_stats64(stats, &dev->stats);
>
>         // Passing a non NULL stats asks mlx4_en_fold_software_stats()
>         // to not update dev->stats, but stats directly.
>
>         mlx4_en_fold_software_stats(dev, stats)
>
>
>         return stats;
> }
>
>

Thanks for the detailed answer !!

BTW you went 5 steps ahead of my original question :)), so far you
already have a patch without locking at all (really impressive).

What i wanted to ask originally, was regarding the "_bh", i didn't
mean to completely remove the "spin_lock_bh",
I meant, what happens if we replace "spin_lock_bh"  with "spin_lock",
without disabling bh ?
I gues raw "sping_lock" handles points (2 to 4) from above, but it
won't handle long irqs.
