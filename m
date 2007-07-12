From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Thu, 12 Jul 2007 12:46:41 +0200
Message-ID: <20070712104641.GB1708@ff.dom.local>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net> <20070712073746.GA1708@ff.dom.local> <1184231903.3477.65.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:42234 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752562AbXGLKh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 06:37:58 -0400
Content-Disposition: inline
In-Reply-To: <1184231903.3477.65.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 12:18:23PM +0300, Ranko Zivojnovic wrote:
> On Thu, 2007-07-12 at 09:37 +0200, Jarek Poplawski wrote:
> > On Wed, Jul 11, 2007 at 04:41:37PM +0300, Ranko Zivojnovic wrote:
> > > Signed-off-by: Ranko Zivojnovic <ranko@spidernet.net>
> > 
> > Maybe it's only my issue, but it seems there are no tabs: all spaces...
> 
> Nope - you are right - just noticed my mailer converts tabs into spaces
> - sorry about this...
> 
> > 
> > ...plus some old doubts:
> > 
> 
> >  -               setup_timer(&elist[idx].timer, est_timer, est->interval);
> >  +               setup_timer(&elist[idx].timer, est_timer, idx);
> > 
> 
> I left this because setup_timer expects unsigned long.

Are there any warnings? It'll look strange without such comment.
I didn't check this, but maybe idx should be unsigned too?

> 
> > ...
> > >  /**
> > >   * gen_kill_estimator - remove a rate estimator
> > >   * @bstats: basic statistics
> > > @@ -195,31 +201,28 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
> > >   *
> > >   * Removes the rate estimator specified by &bstats and &rate_est
> > >   * and deletes the timer.
> > > + *
> > > + * NOTE: Called under rtnl_mutex
> > >   */
> > >  void gen_kill_estimator(struct gnet_stats_basic *bstats,
> > >         struct gnet_stats_rate_est *rate_est)
> > >  {
> > ...
> > > +               list_for_each_entry_safe(e, n, &elist[idx].list, list) {
> > > +                       if (e->rate_est != rate_est || e->bstats != bstats)
> > > +                               continue;
> > > 
> > > -                       kfree(est);
> > > -                       killed++;
> > > +                       list_del_rcu(&e->list);
> > > +                       call_rcu(&e->e_rcu, __gen_kill_estimator);
> > >                 }
> > > -               if (killed && elist[idx].list == NULL)
> > > -                       del_timer(&elist[idx].timer);
> > >         }
> > >  }
> > 
> > I've done a bit of mess last time, so maybe it was forgotten, but I
> > still think this kind of race is possible:
> > 
> > - gen_kill_estimator is called during qdisc_destroy under
> >   dev->queue_lock,
> > - est_timer is running and waiting on this lock just on the
> >   list entry of the destroyed class,
> > - gen_kill_estimator kills the entry and returns,
> > - in xxx_destroy_class kfree(cl) is done etc.,
> > - est_timer gets the lock and does nbytes = e->bstats->bytes or
> >   e->rate_est-bps = ... with freed memory.
...
> I don't mind fixing all the classful qdiscs to call_rcu() to release
> their class structures for consistency purposes ... in fact ... that is
> exactly what I will do in order to avoid any potential future mishaps.
> One may actually decide in the future to add a callback to a user
> defined function to update some qdisc/class specific rates and given
> this inconsistency in handling qdiscs vs classes - it could have a nasty
> backfire.

I don't know if such broad changes are acceptable, or if it's even
required that these structs have to belong to a class struct.

IMHO, unless I miss something, they could be included into
gen_estimator struct after some api change. BTW, maybe it would be
resonable to return a pointer to such gen_estimator from
gen_new_estimator, then lookups could be avoided in
gen_kill_estimator.

Alas, there is probably more (of course very unprobable): there
is no dev_hold for gen_estimator now, so I hope it'll always manage
to unlock in time -  before dev is freed.

Jarek P.
