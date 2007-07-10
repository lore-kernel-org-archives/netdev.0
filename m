From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
	to -mm tree
Date: Tue, 10 Jul 2007 13:09:07 +0300
Message-ID: <1184062147.11966.37.camel@localhost.localdomain>
References: <20070706062629.GC1846@ff.dom.local>
	 <20070706064523.GA2144@ff.dom.local>
	 <1183727654.6389.3.camel@ranko-fc2.spidernet.net>
	 <468E4FD9.4060702@trash.net>
	 <1183733732.6389.26.camel@ranko-fc2.spidernet.net>
	 <1183794918.30237.69.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0707071704370.1808@x2>
	 <1183984861.18656.21.camel@ranko-fc2.spidernet.net>
	 <46923DA8.9010208@trash.net>
	 <1183999420.18656.54.camel@ranko-fc2.spidernet.net>
	 <20070710073447.GA1870@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:31972 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759872AbXGJKKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 06:10:21 -0400
In-Reply-To: <20070710073447.GA1870@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-10 at 09:34 +0200, Jarek Poplawski wrote:
> On Mon, Jul 09, 2007 at 07:43:40PM +0300, Ranko Zivojnovic wrote:
> > On Mon, 2007-07-09 at 15:52 +0200, Patrick McHardy wrote:
> > > Ranko Zivojnovic wrote:
> > > > Patrick, I've taken liberty to try and implement this myself. Attached
> > > > is the whole new gen_estimator-fix-locking-and-timer-related-bugs.patch
> > > > that is RCU lists based. Please be kind to review.
> ...
> 
> I've some doubts/suggestions too:
> 
> > --- a/net/core/gen_estimator.c	2007-06-25 02:21:48.000000000 +0300
> > +++ b/net/core/gen_estimator.c	2007-07-09 19:08:06.801544963 +0300
> ...
> > @@ -173,20 +172,24 @@
> >  	est->last_packets = bstats->packets;
> >  	est->avpps = rate_est->pps<<10;
> >  
> > -	est->next = elist[est->interval].list;
> > -	if (est->next == NULL) {
> > -		init_timer(&elist[est->interval].timer);
> > -		elist[est->interval].timer.data = est->interval;
> > -		elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
> > -		elist[est->interval].timer.function = est_timer;
> > -		add_timer(&elist[est->interval].timer);
> > +	if (!elist[idx].timer.function) {
> > +		INIT_LIST_HEAD(&elist[idx].list);
> > +		setup_timer(&elist[idx].timer, est_timer, est->interval);
> 
> s/est->interval/idx/ here and below.

Agree - will do by final submission.

> 
> >  	}
> > -	write_lock_bh(&est_lock);
> > -	elist[est->interval].list = est;
> > -	write_unlock_bh(&est_lock);
> > +		
> > +	if (list_empty(&elist[est->interval].list))
> > +		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
> > +
> > +	list_add_rcu(&est->list, &elist[idx].list);
> >  	return 0;
> >  }
> >  
> > +static void __gen_kill_estimator(struct rcu_head *head)
> > +{
> > +	struct gen_estimator *e = container_of(head, struct gen_estimator, e_rcu);
> > +	kfree(e);
> > +}
> > +
> >  /**
> >   * gen_kill_estimator - remove a rate estimator
> >   * @bstats: basic statistics
> > @@ -199,26 +202,21 @@
> >  	struct gnet_stats_rate_est *rate_est)
> >  {
> ...
> > +		list_for_each_entry_safe(e, n, &elist[idx].list, list) {
> 
> IMHO, at least for readability list_for_each_entry_rcu() is better here.

Should not hurt - however functionality wise not necessary as the list
is protected by rtnl_mutex from being altered - also, for correctness,
it should be list_for_each_safe_rcu() as there is a list_del_rcu in the
loop... 

However I decided not to use _rcu based iteration neither the
rcu_read_lock() after going through the RCU documentation and a bunch of
examples in kernel that iterate through the lists using non _rcu macros
and do list_del_rcu() just fine.

For readability, the reference to list_del_rcu as well as call_rcu, I
believe, should be enough of the indication. Please do correct me if I
am wrong here.

> 
> > +			if (e->rate_est != rate_est || e->bstats != bstats)
> > +				continue;
> >  
> > -			kfree(est);
> > -			killed++;
> > +			list_del_rcu(&e->list);
> > +			call_rcu(&e->e_rcu, __gen_kill_estimator);
> 
> I think a race is possible here: e.g. a timer could be running
> after return from this function yet, and trying to use *bstats,
> *rate_est and maybe even stats_lock after their destruction.
> 

That will not happen because est_timer protects the loop with
rcu_read_lock() as well as the iteration is done using
list_for_each_entry_rcu(). The destruction callback is deferred and will
happen only after the outermost rcu_read_unlock() is called. Well - that
is at least what the documentation says...

> BTW, I think, rcu_read_lock/unlock are recommended around e.g.
> rcu lists traversals, even if the current implementation doesn't
> use them now.

I am afraid I do not understand what that the current implementation is
not using right now... The whole concept and the implementation of the
RCU, as I understand it, depends on rcu_read_lock/unlock to protect the
read-side critical sections...

Please be kind to elaborate...

R.

