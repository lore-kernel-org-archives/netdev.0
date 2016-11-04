From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 3/3] qdisc: catch misconfig of attaching qdisc
 to tx_queue_len zero device
Date: Fri, 4 Nov 2016 11:10:42 +0100
Message-ID: <20161104111042.12a361ca@redhat.com>
References: <20161103135534.28737.37657.stgit@firesoul>
        <20161103135611.28737.39840.stgit@firesoul>
        <20161104093526.GM5640@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760832AbcKDKKs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:10:48 -0400
In-Reply-To: <20161104093526.GM5640@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 4 Nov 2016 10:35:26 +0100 Phil Sutter <phil@nwl.cc> wrote:

> Hi,
> 
> On Thu, Nov 03, 2016 at 02:56:11PM +0100, Jesper Dangaard Brouer wrote:
> [...]
> > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > index 206dc24add3a..f337f1bdd1d4 100644
> > --- a/net/sched/sch_api.c
> > +++ b/net/sched/sch_api.c
> > @@ -960,6 +960,17 @@ static struct Qdisc *qdisc_create(struct net_device *dev,
> >  
> >  	sch->handle = handle;
> >  
> > +	/* This exist to keep backward compatible with a userspace
> > +	 * loophole, what allowed userspace to get IFF_NO_QUEUE
> > +	 * facility on older kernels by setting tx_queue_len=0 (prior
> > +	 * to qdisc init), and then forgot to reinit tx_queue_len
> > +	 * before again attaching a qdisc.
> > +	 */
> > +	if ((dev->priv_flags & IFF_NO_QUEUE) && (dev->tx_queue_len == 0)) {
> > +		dev->tx_queue_len = DEFAULT_TX_QUEUE_LEN;
> > +		netdev_info(dev, "Caught tx_queue_len zero misconfig\n");
> > +	}  
> 
> I wonder why this is limited to IFF_NO_QUEUE devices. Do you think there
> is a valid use case for physical ones?

Hmmm, I cannot come up with a useful use-case for physical devices, but
I cannot see why we should save users that had used the loophole on
physical devices, as that is clearly a faulty config to begin with.
See net_crit_ratelimited warning here:
 https://github.com/torvalds/linux/blob/v4.9-rc3/net/core/dev.c#L3403

> Also, if we sanitize here, couldn't we then just get rid of the
> sanitization you're fixing in patch 2?

Without patch 2, then some IFF_NO_QUEUE devices would have a visible
tx_queue_len 0 (e.g. the ones not calling ether_setup()), and that
would be inconsistent (visible from userspace).

> Apart from that, ACK to all the patches. Thanks for cleaning up my mess!
> :)

Thanks for the ACKs

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
