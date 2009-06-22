From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Mon, 22 Jun 2009 07:08:19 -0400
Message-ID: <20090622110819.GB13043@hmsreliant.think-freely.org>
References: <20090621171141.GA2893@localhost.localdomain> <20090622054315.GA4928@ff.dom.local> <20090622085950.GA26598@ms2.inr.ac.ru> <20090622110023.GA6994@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mbizon@freebox.fr, dada1@cosmosbay.com, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41653 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788AbZFVLI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 07:08:29 -0400
Content-Disposition: inline
In-Reply-To: <20090622110023.GA6994@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 11:00:23AM +0000, Jarek Poplawski wrote:
> On Mon, Jun 22, 2009 at 12:59:50PM +0400, Alexey Kuznetsov wrote:
> > On Mon, Jun 22, 2009 at 05:43:15AM +0000, Jarek Poplawski wrote:
> > > Maybe it can work, but it needs a thorough checking now and adds a new
> > > code path to track later while looking for bugs. So, I wonder if it's
> > > not better to link such dsts in rt_intern_hash anyway, probably as a
> > > separate list, scanned only for expired entries.
> > 
> > Such a list already exists, it is gc list in core/dst.c.
> > 
> > The fix to the problem could be replacing rt_drop() with rt_free()
> > (adding rt_free() after the patch, which deleted rt_drop()), something like:
> > 
> > 	if (!rt_caching(dev_net(rt->u.dst.dev))) {
> > 		/* ..... */
> > +		rt_free(rt);
> > 		goto report_and_exit;
> > 	}
> > 
> > rt_free() will put the route on that gc list and it will be releases
> > as soon as refcnt becomes 0.
> 
> One little doubt would be RCU: if it's currently used in rt_free, and
> some code depends on it, there would be a change: rt could be freed
> just after atomic dec, without waiting for RCU yet. The second one is

Not sure that I see the concern.  How are we going to call dst_rcu_free without
waiting for a quiesence of the use of this route?  When it enters rt_intern_hash
is use count is one, and if we call rt_free in this case, we are guaranteeing
that this path is the only user (no one else will be able to get a reference to
it as they can't look it up in the cache).  Once the route is dropped at the end
of this route lookup, its use is over and the garbage collector will reap it.

> about timing: freeing this always from a workqueue could probably
> make a problem if softirqs are often disabled.
> 
You mean often, or permanently?  If softirqs are often disabled, thats no big
deal, as long as they are enabled at least sometimes, the garbage colelctor will
run, and we'll be ok.  If softirqs are disabled permanently (or for sufficiently
long periods that we gather huge number of routes waiting to be reaped), I think
we have larger problems on our hands

Neil

> Jarek P.
> 
