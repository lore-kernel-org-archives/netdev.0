From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Tue, 10 Jul 2007 14:17:56 +0200
Message-ID: <20070710121756.GB3130@ff.dom.local>
References: <1183727654.6389.3.camel@ranko-fc2.spidernet.net> <468E4FD9.4060702@trash.net> <1183733732.6389.26.camel@ranko-fc2.spidernet.net> <1183794918.30237.69.camel@localhost.localdomain> <Pine.LNX.4.64.0707071704370.1808@x2> <1183984861.18656.21.camel@ranko-fc2.spidernet.net> <46923DA8.9010208@trash.net> <1183999420.18656.54.camel@ranko-fc2.spidernet.net> <20070710073447.GA1870@ff.dom.local> <1184062147.11966.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:52744 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750708AbXGJMJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 08:09:17 -0400
Content-Disposition: inline
In-Reply-To: <1184062147.11966.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 10, 2007 at 01:09:07PM +0300, Ranko Zivojnovic wrote:
> On Tue, 2007-07-10 at 09:34 +0200, Jarek Poplawski wrote:
> > On Mon, Jul 09, 2007 at 07:43:40PM +0300, Ranko Zivojnovic wrote:
> > > On Mon, 2007-07-09 at 15:52 +0200, Patrick McHardy wrote:
> > > > Ranko Zivojnovic wrote:
> > > > > Patrick, I've taken liberty to try and implement this myself. Attached
> > > > > is the whole new gen_estimator-fix-locking-and-timer-related-bugs.patch
> > > > > that is RCU lists based. Please be kind to review.
> > ...
> > 
> > I've some doubts/suggestions too:
> > 
> > > --- a/net/core/gen_estimator.c	2007-06-25 02:21:48.000000000 +0300
> > > +++ b/net/core/gen_estimator.c	2007-07-09 19:08:06.801544963 +0300
...
> > >  	struct gnet_stats_rate_est *rate_est)
> > >  {
> > ...
> > > +		list_for_each_entry_safe(e, n, &elist[idx].list, list) {
> > 
> > IMHO, at least for readability list_for_each_entry_rcu() is better here.
> 
> Should not hurt - however functionality wise not necessary as the list
> is protected by rtnl_mutex from being altered - also, for correctness,
> it should be list_for_each_safe_rcu() as there is a list_del_rcu in the
> loop... 
> 
> However I decided not to use _rcu based iteration neither the
> rcu_read_lock() after going through the RCU documentation and a bunch of
> examples in kernel that iterate through the lists using non _rcu macros
> and do list_del_rcu() just fine.
> 
> For readability, the reference to list_del_rcu as well as call_rcu, I
> believe, should be enough of the indication. Please do correct me if I
> am wrong here.

It's only my opinion, and it's probably not very popular at least
at net/ code, so it's more about general policy and not this
particular code. But:
- if somebody is looking after some rcu related problems, why can't
he/she spare some time by omitting lists without _rcu and not
analyzing why/how such lists are used and locked?
- if some day rcu code should change and needs to know precisely,
where all the reads and writes take place (or some automatic tool
needs this for checking), and it's no problem to show this now,
why leave this for future?

> 
> > 
> > > +			if (e->rate_est != rate_est || e->bstats != bstats)
> > > +				continue;
> > >  
> > > -			kfree(est);
> > > -			killed++;
> > > +			list_del_rcu(&e->list);
> > > +			call_rcu(&e->e_rcu, __gen_kill_estimator);
> > 
> > I think a race is possible here: e.g. a timer could be running
> > after return from this function yet, and trying to use *bstats,
> > *rate_est and maybe even stats_lock after their destruction.
> > 
> 
> That will not happen because est_timer protects the loop with
> rcu_read_lock() as well as the iteration is done using
> list_for_each_entry_rcu(). The destruction callback is deferred and will
> happen only after the outermost rcu_read_unlock() is called. Well - that
> is at least what the documentation says...

I'm not very sure it's really possible, so I hope it'll be checked
by somebody more. I don't mean gen_estimator struct here, but
gnet_stats_basic and gnet_stats_rate_est structs here, which are
allocated elsewhere, and could be destructed just 'after' - if not
before: that's the question... E.g. when we are leaving this
function, on another cpu a timer could traverse this list and I'm
not sure rcu has to show the change fast enough - before freeing
these other structs.

> 
> > BTW, I think, rcu_read_lock/unlock are recommended around e.g.
> > rcu lists traversals, even if the current implementation doesn't
> > use them now.
> 
> I am afraid I do not understand what that the current implementation is
> not using right now... The whole concept and the implementation of the
> RCU, as I understand it, depends on rcu_read_lock/unlock to protect the
> read-side critical sections...
> 
> Please be kind to elaborate...

Don't take this very seriously, there are many opinions...

Cheers,
Jarek P.

PS: I think you could read more about this here:

http://marc.info/?l=linux-kernel&m=118193431820959&w=2

Especially this:

List:       linux-kernel
Subject:    Re: Using RCU with rcu_read_lock()?
From:       Peter Zijlstra <a.p.zijlstra () chello ! nl>
Date:       2007-06-15 19:04:19
Message-ID: 1181934259.11113.6.camel () lappy
[Download message RAW]

On Fri, 2007-06-15 at 15:00 -0400, Dmitry Torokhov wrote:
> Hi,
> 
> I have a piece of code that is always called under a spinlock with
> interrups disabled. Within that piece of code I iterate through a
> list. I have another piece of code that wants to modify that list. I
> have 2 options:
> 
> 1) Have the other piece of code acquire the same spinlock
> 2) Use RCU
> 
> I don't want to do 1) because the otheir piece of code does not really
> care about object owning the spinlock and so acquiring the spinlock is
> "not nice". However it is guaranteed that the piece of code that
> accesses lock runs atomically with interrupts disabled. So
> rcu_read_lock() would be superfluos there.
> 
> Is it possible to still use list_for_each_rcu() and friends to access
> that list without rcu_read_lock()? Or it is betteruse complete RCU
> interface and eat cost of couple of extra instrctions?

Yes, preemptible rcu requires that you use the full interface, also, it
more clearly documents the code. Trying to find code that breaks these
assumptions is very tedious work after the fact.

Please do use the RCU interface in full.

