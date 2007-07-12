From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Thu, 12 Jul 2007 12:18:23 +0300
Message-ID: <1184231903.3477.65.camel@ranko-fc2.spidernet.net>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>
	 <20070712073746.GA1708@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:20811 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbXGLJSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 05:18:47 -0400
In-Reply-To: <20070712073746.GA1708@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-12 at 09:37 +0200, Jarek Poplawski wrote:
> On Wed, Jul 11, 2007 at 04:41:37PM +0300, Ranko Zivojnovic wrote:
> > Signed-off-by: Ranko Zivojnovic <ranko@spidernet.net>
> 
> Maybe it's only my issue, but it seems there are no tabs: all spaces...

Nope - you are right - just noticed my mailer converts tabs into spaces
- sorry about this...

> 
> ...plus some old doubts:
> 

>  -               setup_timer(&elist[idx].timer, est_timer, est->interval);
>  +               setup_timer(&elist[idx].timer, est_timer, idx);
> 

I left this because setup_timer expects unsigned long.

> ...
> >  /**
> >   * gen_kill_estimator - remove a rate estimator
> >   * @bstats: basic statistics
> > @@ -195,31 +201,28 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
> >   *
> >   * Removes the rate estimator specified by &bstats and &rate_est
> >   * and deletes the timer.
> > + *
> > + * NOTE: Called under rtnl_mutex
> >   */
> >  void gen_kill_estimator(struct gnet_stats_basic *bstats,
> >         struct gnet_stats_rate_est *rate_est)
> >  {
> ...
> > +               list_for_each_entry_safe(e, n, &elist[idx].list, list) {
> > +                       if (e->rate_est != rate_est || e->bstats != bstats)
> > +                               continue;
> > 
> > -                       kfree(est);
> > -                       killed++;
> > +                       list_del_rcu(&e->list);
> > +                       call_rcu(&e->e_rcu, __gen_kill_estimator);
> >                 }
> > -               if (killed && elist[idx].list == NULL)
> > -                       del_timer(&elist[idx].timer);
> >         }
> >  }
> 
> I've done a bit of mess last time, so maybe it was forgotten, but I
> still think this kind of race is possible:
> 
> - gen_kill_estimator is called during qdisc_destroy under
>   dev->queue_lock,
> - est_timer is running and waiting on this lock just on the
>   list entry of the destroyed class,
> - gen_kill_estimator kills the entry and returns,
> - in xxx_destroy_class kfree(cl) is done etc.,
> - est_timer gets the lock and does nbytes = e->bstats->bytes or
>   e->rate_est-bps = ... with freed memory.

Unfortunately I cannot say for sure that _currently_ anything really bad
can happen here... someone with better knowledge will have to confirm
this - Patrick?

Here's why - the only updates that are being done in the est_timer are
to the structure pointed by 'e'. Yes - it is possible the values it will
refer to could be random (freed memory), _however_ the 'e' structure is
still valid as it is _not_ kfree()'d directly from gen_kill_estimator()
- i.e. it will not be kfree()'d until rcu_read_unlock() is called -
which is outside the loop.

I don't mind fixing all the classful qdiscs to call_rcu() to release
their class structures for consistency purposes ... in fact ... that is
exactly what I will do in order to avoid any potential future mishaps.
One may actually decide in the future to add a callback to a user
defined function to update some qdisc/class specific rates and given
this inconsistency in handling qdiscs vs classes - it could have a nasty
backfire.

Will have a new patch soon.

Regards,

Ranko

