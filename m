From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Thu, 12 Jul 2007 09:37:46 +0200
Message-ID: <20070712073746.GA1708@ff.dom.local>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:42745 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753257AbXGLH3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 03:29:05 -0400
Content-Disposition: inline
In-Reply-To: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 11, 2007 at 04:41:37PM +0300, Ranko Zivojnovic wrote:
> Fixes ABBA deadlock noted by Patrick McHardy <kaber@trash.net>:
> > There is at least one ABBA deadlock, est_timer() does:
> > read_lock(&est_lock)
> > spin_lock(e->stats_lock) (which is dev->queue_lock)
> > 
> > and qdisc_destroy calls htb_destroy under dev->queue_lock, which
> > calls htb_destroy_class, then gen_kill_estimator and this
> > write_locks est_lock.
> 
> est_lock completely removed and the RCU list implemented instead.
> Both gen_kill_estimator and gen_new_estimator are already called under
> rtnl_mutex.
> 
> Signed-off-by: Ranko Zivojnovic <ranko@spidernet.net>

Maybe it's only my issue, but it seems there are no tabs: all spaces...

...plus some old doubts:

> ---
>  net/core/gen_estimator.c |   73 ++++++++++++++++++++++++----------------------
>  1 files changed, 38 insertions(+), 35 deletions(-)
> 
> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
> index cc84d8d..444b2bd 100644
> --- a/net/core/gen_estimator.c
> +++ b/net/core/gen_estimator.c
...

> @@ -174,20 +175,25 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
>         est->last_packets = bstats->packets;
>         est->avpps = rate_est->pps<<10;
> 
> -       est->next = elist[est->interval].list;
> -       if (est->next == NULL) {
> -               init_timer(&elist[est->interval].timer);
> -               elist[est->interval].timer.data = est->interval;
> -               elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
> -               elist[est->interval].timer.function = est_timer;
> -               add_timer(&elist[est->interval].timer);
> +       if (!elist[idx].timer.function) {
> +               INIT_LIST_HEAD(&elist[idx].list);
> +               setup_timer(&elist[idx].timer, est_timer, est->interval);


 -               setup_timer(&elist[idx].timer, est_timer, est->interval);
 +               setup_timer(&elist[idx].timer, est_timer, idx);

...
>  /**
>   * gen_kill_estimator - remove a rate estimator
>   * @bstats: basic statistics
> @@ -195,31 +201,28 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
>   *
>   * Removes the rate estimator specified by &bstats and &rate_est
>   * and deletes the timer.
> + *
> + * NOTE: Called under rtnl_mutex
>   */
>  void gen_kill_estimator(struct gnet_stats_basic *bstats,
>         struct gnet_stats_rate_est *rate_est)
>  {
...
> +               list_for_each_entry_safe(e, n, &elist[idx].list, list) {
> +                       if (e->rate_est != rate_est || e->bstats != bstats)
> +                               continue;
> 
> -                       kfree(est);
> -                       killed++;
> +                       list_del_rcu(&e->list);
> +                       call_rcu(&e->e_rcu, __gen_kill_estimator);
>                 }
> -               if (killed && elist[idx].list == NULL)
> -                       del_timer(&elist[idx].timer);
>         }
>  }

I've done a bit of mess last time, so maybe it was forgotten, but I
still think this kind of race is possible:

- gen_kill_estimator is called during qdisc_destroy under
  dev->queue_lock,
- est_timer is running and waiting on this lock just on the
  list entry of the destroyed class,
- gen_kill_estimator kills the entry and returns,
- in xxx_destroy_class kfree(cl) is done etc.,
- est_timer gets the lock and does nbytes = e->bstats->bytes or
  e->rate_est-bps = ... with freed memory.

Regards,
Jarek P.
