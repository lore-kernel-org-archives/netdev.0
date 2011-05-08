From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 8 May 2011 07:47:49 -0700
Message-ID: <20110508144749.GR2641@linux.vnet.ibm.com>
References: <178E8895FB84C07251538EF7@Ximines.local>
 <1304793174.3207.22.camel@edumazet-laptop>
 <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
 <F57561A93EFF5E88729A8D53@nimrod.local>
 <7B76F9D75FD26D716624004B@nimrod.local>
 <20110508125028.GK2641@linux.vnet.ibm.com>
 <B2891EFD056565BBD4DBCE16@nimrod.local>
 <20110508134425.GL2641@linux.vnet.ibm.com>
 <C449131127D58077CB25C9D8@Ximines.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:56420 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754475Ab1EHOry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 10:47:54 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p48EIpnl008034
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 10:18:51 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p48ElpIB1347828
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 10:47:51 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p48Elpnk006665
	for <netdev@vger.kernel.org>; Sun, 8 May 2011 10:47:51 -0400
Content-Disposition: inline
In-Reply-To: <C449131127D58077CB25C9D8@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 08, 2011 at 03:27:07PM +0100, Alex Bligh wrote:
> Paul,
> 
> >>Yes, really 20-49us and 50-99us, not ms. Raw data attached :-)
> >>
> >>I'm guessing there are circumstances where there is an early exit.
> >
> >Well, if you were onlining and offlining CPUs, then if there was only
> >one CPU online, this could happen.
> 
> No, I wasn't doing that.

OK.

> > And there really is only one CPU
> >online during boot, so if your measurements included early boot time,
> >this could easily explain these very short timings.
> 
> No, I waited a few minutes after boot for the system to stabilize, and
> all CPUs were definitely online.
> 
> The patch to the kernel I am running is below.

OK, interesting...

My guess is that you need to be using ktime_get_ts().  Isn't ktime_get()
subject to various sorts of adjustment?

> >>There is nothing much going on these systems (idle, no other users,
> >>just normal system daemons).
> >
> >And normal system daemons might cause this, right?
> 
> Yes. Everything is normal, except I did
> service udev stop
> unshare -n bash
> which together stop the system running interface scripts when
> interfaces are created (as upstart and upstart-udev-bridge are
> now integrated, you can't kill upstart, so you have to rely on
> unshare -n to stop the events being propagated). That's just
> to avoid measuring the time it takes to execute the scripts.

OK, so you really could be seeing grace periods started by these system
daemons.

							Thanx, Paul

> -- 
> Alex Bligh
> 
> diff --git a/kernel/rcutree.c b/kernel/rcutree.c
> index dd4aea8..e401018 100644
> --- a/kernel/rcutree.c
> +++ b/kernel/rcutree.c
> @@ -1518,6 +1518,7 @@ EXPORT_SYMBOL_GPL(call_rcu_bh);
> void synchronize_sched(void)
> {
>        struct rcu_synchronize rcu;
> +       ktime_t time_start = ktime_get();
> 
>        if (rcu_blocking_is_gp())
>                return;
> @@ -1529,6 +1530,7 @@ void synchronize_sched(void)
>        /* Wait for it. */
>        wait_for_completion(&rcu.completion);
>        destroy_rcu_head_on_stack(&rcu.head);
> +       pr_err("synchronize_sched() in %lld us\n",
> ktime_us_delta(ktime_get(), time_start));
> }
> EXPORT_SYMBOL_GPL(synchronize_sched);
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 856b6ee..013f627 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5164,7 +5164,9 @@ static void rollback_registered_many(struct
> list_head *head)
>        dev = list_first_entry(head, struct net_device, unreg_list);
>        call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
> 
> +       pr_err("begin rcu_barrier()\n");
>        rcu_barrier();
> +       pr_err("end rcu_barrier()\n");
> 
>        list_for_each_entry(dev, head, unreg_list)
>                dev_put(dev);
> @@ -5915,8 +5917,10 @@ EXPORT_SYMBOL(free_netdev);
>  */
> void synchronize_net(void)
> {
> +       pr_err("begin synchronize_net()\n");
>        might_sleep();
>        synchronize_rcu();
> +       pr_err("end synchronize_net()\n");
> }
> EXPORT_SYMBOL(synchronize_net);
> 
> 
