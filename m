From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Wed, 26 Mar 2014 16:09:57 +0100
Message-ID: <20140326150957.GB27720@unicorn.suse.cz>
References: <20140310.010313.703650662340510015.davem@davemloft.net>
 <20140310081533.GA27052@unicorn.suse.cz>
 <20140310120016.GH5493@order.stressinduktion.org>
 <20140310.223841.953940361609160158.davem@davemloft.net>
 <20140311095309.GA3287@unicorn.suse.cz>
 <20140311150814.GB3287@unicorn.suse.cz>
 <20140311153931.GC3287@unicorn.suse.cz>
 <20140325191155.GB22086@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46935 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbaCZPJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 11:09:59 -0400
Content-Disposition: inline
In-Reply-To: <20140325191155.GB22086@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2014 at 08:11:55PM +0100, Hannes Frederic Sowa wrote:
> > > What I ended up with is below. It uses the metrics in inetpeer if there
> > > is one even if the new host metric doesn't have any metrics to set (in
> > > which case it clears them first). I tested various scenarios and the
> > > results were correct.
> > 
> > This doesn't cover all cases either:
> > 
> >   ip route add fec0::1 dev eth0 rto_min 1000
> >   ip route delete fec0::1
> >   ip route add fec0::1 dev eth0
> >   ip route change fec0::1 dev eth0 hoplimit 10
> > 
> > This way the inetpeer with rto_min 1000 persists until the fourth
> > command but neither third nor fourth see old dst_entry with writeable
> > metrics.
> > 
> > I think changing the condition for copying in ip6_cow_metrics() would
> > do the trick but I better stop now and look at it again later with
> > a fresh mind.
> 
> Do you need some help regarding this patch so that it may be included in
> net-next before it gets closed?

Sorry for the delay, I was working on some more urgent bugs.

While rethinking the problem, I realized that these metrics hidden in
old inetpeer are actually even more dangerous. Assume we create a (host)
route with metrics, delete it but the inetpeer with the metrics still
exists. If we then create a new route without metrics, this inetpeer is
(later) bound to it but metrics in it are not used. However, as soon as
ipv6_cow_metrics() is called, they are linked into struct dst_entry but
as they are not "new", they are not overwritten.

The approach I tried was to add a new flag DST_KEEP_METRICS (should
rather be something like DST_OVERRIDE_INETPEER_METRICS but that looks
awful) which is set in ip6_route_add() and makes ipv6_cow_metrics()
always rewrite metrics in attached inetpeer and then reset the flag. In
ip6_rt_copy(), this flag is not copied (but the metrics are overwritten
anyway).

I ran some tests with all scenarios I could think of and all seem to
work fine. I'll post the patch for review in a moment.

                                                       Michal Kubecek
