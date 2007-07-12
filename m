From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Thu, 12 Jul 2007 14:47:22 +0300
Message-ID: <1184240842.3477.110.camel@ranko-fc2.spidernet.net>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>
	 <20070712073746.GA1708@ff.dom.local>
	 <1184231903.3477.65.camel@ranko-fc2.spidernet.net>
	 <20070712104641.GB1708@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:43753 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbXGLLrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 07:47:45 -0400
In-Reply-To: <20070712104641.GB1708@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-12 at 12:46 +0200, Jarek Poplawski wrote:
> On Thu, Jul 12, 2007 at 12:18:23PM +0300, Ranko Zivojnovic wrote:
> > On Thu, 2007-07-12 at 09:37 +0200, Jarek Poplawski wrote:
> > >  -               setup_timer(&elist[idx].timer, est_timer, est->interval);
> > >  +               setup_timer(&elist[idx].timer, est_timer, idx);
> > 
> > I left this because setup_timer expects unsigned long.
> 
> Are there any warnings? It'll look strange without such comment.
> I didn't check this, but maybe idx should be unsigned too?
> 

I'll make idx unsigned.

> > 
> > > - gen_kill_estimator is called during qdisc_destroy under
> > >   dev->queue_lock,
> > > - est_timer is running and waiting on this lock just on the
> > >   list entry of the destroyed class,
> > > - gen_kill_estimator kills the entry and returns,
> > > - in xxx_destroy_class kfree(cl) is done etc.,
> > > - est_timer gets the lock and does nbytes = e->bstats->bytes or
> > >   e->rate_est-bps = ... with freed memory.
> ...
> > I don't mind fixing all the classful qdiscs to call_rcu() to release
> > their class structures for consistency purposes ... in fact ... that is
> > exactly what I will do in order to avoid any potential future mishaps.
> > One may actually decide in the future to add a callback to a user
> > defined function to update some qdisc/class specific rates and given
> > this inconsistency in handling qdiscs vs classes - it could have a nasty
> > backfire.
> 
> I don't know if such broad changes are acceptable, or if it's even
> required that these structs have to belong to a class struct.
> 
> IMHO, unless I miss something, they could be included into
> gen_estimator struct after some api change. BTW, maybe it would be
> resonable to return a pointer to such gen_estimator from
> gen_new_estimator, then lookups could be avoided in
> gen_kill_estimator.
> 
> Alas, there is probably more (of course very unprobable): there
> is no dev_hold for gen_estimator now, so I hope it'll always manage
> to unlock in time -  before dev is freed.
> 

I agree - it does look like the most sensible thing to do - have
gnet_stats_basic and gnet_stats_rate_est allocated within the
gen_estimator struct rather than pointers looking here and there - and
provide api to maintain those stats - it simplifies the picture.

Also - the stats_lock in this case could be local to gen_estimator
struct, thus making the implementation completely "dev agnostic" - and
will not break on dev removal.

All this however will require a rather intrusive "surgical procedure" to
fix all the references.

I don't mind implementing and testing it - given there's consensus from
maintainers on the "correctness".

Waiting for feedback.

R.


