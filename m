From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH 3/3] qdisc: catch misconfig of attaching qdisc
 to tx_queue_len zero device
Date: Fri, 4 Nov 2016 11:59:13 +0100
Message-ID: <20161104105913.GN5640@orbyte.nwl.cc>
References: <20161103135534.28737.37657.stgit@firesoul>
 <20161103135611.28737.39840.stgit@firesoul>
 <20161104093526.GM5640@orbyte.nwl.cc>
 <20161104111042.12a361ca@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37635 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760618AbcKDK7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:59:16 -0400
Content-Disposition: inline
In-Reply-To: <20161104111042.12a361ca@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2016 at 11:10:42AM +0100, Jesper Dangaard Brouer wrote:
> 
> On Fri, 4 Nov 2016 10:35:26 +0100 Phil Sutter <phil@nwl.cc> wrote:
> 
> > Hi,
> > 
> > On Thu, Nov 03, 2016 at 02:56:11PM +0100, Jesper Dangaard Brouer wrote:
> > [...]
> > > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > > index 206dc24add3a..f337f1bdd1d4 100644
> > > --- a/net/sched/sch_api.c
> > > +++ b/net/sched/sch_api.c
> > > @@ -960,6 +960,17 @@ static struct Qdisc *qdisc_create(struct net_device *dev,
> > >  
> > >  	sch->handle = handle;
> > >  
> > > +	/* This exist to keep backward compatible with a userspace
> > > +	 * loophole, what allowed userspace to get IFF_NO_QUEUE
> > > +	 * facility on older kernels by setting tx_queue_len=0 (prior
> > > +	 * to qdisc init), and then forgot to reinit tx_queue_len
> > > +	 * before again attaching a qdisc.
> > > +	 */
> > > +	if ((dev->priv_flags & IFF_NO_QUEUE) && (dev->tx_queue_len == 0)) {
> > > +		dev->tx_queue_len = DEFAULT_TX_QUEUE_LEN;
> > > +		netdev_info(dev, "Caught tx_queue_len zero misconfig\n");
> > > +	}  
> > 
> > I wonder why this is limited to IFF_NO_QUEUE devices. Do you think there
> > is a valid use case for physical ones?
> 
> Hmmm, I cannot come up with a useful use-case for physical devices, but
> I cannot see why we should save users that had used the loophole on
> physical devices, as that is clearly a faulty config to begin with.
> See net_crit_ratelimited warning here:
>  https://github.com/torvalds/linux/blob/v4.9-rc3/net/core/dev.c#L3403

I really feel like nit-picking again, but what differs in between
loophole users of virtual devices (whose broken scripts stopped working)
and loophole users of physical devices (whose broken scripts stopped
working as well)?

I we really take exposing broken userspace scripts as kernel bugs, don't
we have to take this one for the same as well?

> > Also, if we sanitize here, couldn't we then just get rid of the
> > sanitization you're fixing in patch 2?
> 
> Without patch 2, then some IFF_NO_QUEUE devices would have a visible
> tx_queue_len 0 (e.g. the ones not calling ether_setup()), and that
> would be inconsistent (visible from userspace).

Ah, indeed. Although there's no functional difference, I guess it might
confuse people seeing an interface with 0 qlen performing properly.

Thanks, Phil
