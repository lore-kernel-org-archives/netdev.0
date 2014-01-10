From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Fri, 10 Jan 2014 08:43:25 +0100
Message-ID: <20140110074325.GC17866@order.stressinduktion.org>
References: <20140109201411.317040@gmx.com> <20140110063638.GA17866@order.stressinduktion.org> <1389337306.31367.94.camel@edumazet-glaptop2.roam.corp.google.com> <20140110071049.GB17866@order.stressinduktion.org> <1389339179.31367.98.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53405 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbaAJHn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 02:43:26 -0500
Content-Disposition: inline
In-Reply-To: <1389339179.31367.98.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 11:32:59PM -0800, Eric Dumazet wrote:
> On Fri, 2014-01-10 at 08:10 +0100, Hannes Frederic Sowa wrote:
> > On Thu, Jan 09, 2014 at 11:01:46PM -0800, Eric Dumazet wrote:
> > > Its not clear to me why you expand ipmr_fib_lookup()
> > > 
> > > Is there something wrong with existing code ?
> > 
> > There are three users of ipmr_fib_lookup, two of them are in rcu_read_lock
> > section, one is not.
> > 
> > ipmr_fib_lookup does not pass down arg.rule reference, so I don't have a
> > chance to call fib_rule_put(arg.rule) on it. Thus I left ipmr_fib_lookup,
> > just adding FIB_LOOKUP_NOREF and expanding ipmr_fib_lookup into the
> > other function so I still have access to arg.rule to decrement the
> > reference counter.
> > 
> > Do you agree?
> 
> Hmm, I see the problem now.
> 
> What about adding a parameter to ipmr_fib_lookup(),
> to keep its spirit ?
> 
> ipmr_fib_lookup(net, &fl4, &mrt);
> ->
> ipmr_fib_lookup(net, &fl4, &mrt, &rule);
> 
> Since ipmr_rt_fib_lookup() has the same rule leak, no ?

No, ipmr_rt_fib_lookup is fine. This function gets called only from
rcu read locked section and we don't take table reference because of
FIB_LOOKUP_NOREF, so we don't need to put reference counter on arg.table.

We could add the additional argument, just ignoring it in ipmr_rt_fib_lookup.

> 
> Its a bit late here, so maybe following is just stupid :
> Cant we do the fib_rule_put() inside ipmr_fib_lookup() ?

We could add bool noref to ipmr_fib_lookup indicating we want to drop
reference to rule just after lookup.

I'll check if freeing a rule has additional side-effects on dependencies
in reg_vif_xmit. That would be a nice solution actually, thanks!
