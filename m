From: Jakub =?UTF-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace
 and a system freeze
Date: Tue, 11 Mar 2014 15:30:29 +0100
Message-ID: <20140311153029.1de9d6e9@north>
References: <20140310014452.144b0491@north>
	<1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140310131909.33a3042c@north>
	<1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311014649.1716bde1@north>
	<20140311120059.GB32371@secunet.com>
	<1394541626.21721.24.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311132030.GD32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	Fan Du <fan.du@windriver.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:7372 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176AbaCKOae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 10:30:34 -0400
In-Reply-To: <20140311132030.GD32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Mar 2014 14:20:30 +0100, Steffen Klassert wrote:
> On Tue, Mar 11, 2014 at 05:40:26AM -0700, Eric Dumazet wrote:
> > On Tue, 2014-03-11 at 13:00 +0100, Steffen Klassert wrote:
> > 
> > > I was unable to reproduce this here, but it looks like the flowcache
> > > namespace changes are still not complete. We leak an active timer
> > > and all the allocated resources when we exit a namespace.
> > > 
> > > Could you please try the patch below?
> > > 
> > > Also, please send your config if the patch does not fix your problem.
> > > 
> > > Thanks!
> > > 
> > > ---
> > >  include/net/flow.h     |    1 +
> > >  net/core/flow.c        |   18 ++++++++++++++++++
> > >  net/xfrm/xfrm_policy.c |    7 ++++++-
> > >  3 files changed, 25 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/include/net/flow.h b/include/net/flow.h
> > > index bee3741..64fd248 100644
> > > --- a/include/net/flow.h
> > > +++ b/include/net/flow.h
> > > @@ -219,6 +219,7 @@ struct flow_cache_object *flow_cache_lookup(struct net *net,
> > >  					    u8 dir, flow_resolve_t resolver,
> > >  					    void *ctx);
> > >  int flow_cache_init(struct net *net);
> > > +void flow_cache_fini(struct net *net);
> > >  
> > >  void flow_cache_flush(struct net *net);
> > >  void flow_cache_flush_deferred(struct net *net);
> > > diff --git a/net/core/flow.c b/net/core/flow.c
> > > index 102f8ea..d31c3c4 100644
> > > --- a/net/core/flow.c
> > > +++ b/net/core/flow.c
> > > @@ -484,3 +484,21 @@ err:
> > >  	return -ENOMEM;
> > >  }
> > >  EXPORT_SYMBOL(flow_cache_init);
> > > +
> > > +void flow_cache_fini(struct net *net)
> > > +{
> > > +	int i;
> > > +	struct flow_cache *fc = &net->xfrm.flow_cache_global;
> > > +
> > > +	del_timer(&fc->rnd_timer);
> > 
> > 
> > del_timer_sync() I guess is better.
> > 
> 
> Right.
> 
> I've just noticed that I also forgot to do a
> unregister_hotcpu_notifier(&fc->hotcpu_notifier).
> 
> Will update the next version according to that.

Tested with del_timer_sync and unregister_hotcpu_notifier:

void flow_cache_fini(struct net *net)
{
	int i;
	struct flow_cache *fc = &net->xfrm.flow_cache_global;

	unregister_hotcpu_notifier(&fc->hotcpu_notifier);
	del_timer_sync(&fc->rnd_timer);

	for_each_possible_cpu(i) {
		struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, i);
		kfree(fcp->hash_table);
		fcp->hash_table = NULL;
	}

	free_percpu(fc->percpu);
	fc->percpu = NULL;
}
EXPORT_SYMBOL(flow_cache_fini);


Seems to solve both the freeze and the bug on restarting libvirtd/rtkit!

	-- kuba
