From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 3/3] qdisc: catch misconfig of attaching qdisc
 to tx_queue_len zero device
Date: Fri, 4 Nov 2016 13:09:08 +0100
Message-ID: <20161104130908.1ebcaa30@redhat.com>
References: <20161103135534.28737.37657.stgit@firesoul>
        <20161103135611.28737.39840.stgit@firesoul>
        <20161104093526.GM5640@orbyte.nwl.cc>
        <20161104111042.12a361ca@redhat.com>
        <20161104105913.GN5640@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57882 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753816AbcKDMJO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 08:09:14 -0400
In-Reply-To: <20161104105913.GN5640@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Nov 2016 11:59:13 +0100
Phil Sutter <phil@nwl.cc> wrote:

> On Fri, Nov 04, 2016 at 11:10:42AM +0100, Jesper Dangaard Brouer wrote:
> > 
> > On Fri, 4 Nov 2016 10:35:26 +0100 Phil Sutter <phil@nwl.cc> wrote:
> >   
> > > Hi,
> > > 
> > > On Thu, Nov 03, 2016 at 02:56:11PM +0100, Jesper Dangaard Brouer wrote:
> > > [...]  
> > > > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > > > index 206dc24add3a..f337f1bdd1d4 100644
> > > > --- a/net/sched/sch_api.c
> > > > +++ b/net/sched/sch_api.c
> > > > @@ -960,6 +960,17 @@ static struct Qdisc *qdisc_create(struct net_device *dev,
> > > >  
> > > >  	sch->handle = handle;
> > > >  
> > > > +	/* This exist to keep backward compatible with a userspace
> > > > +	 * loophole, what allowed userspace to get IFF_NO_QUEUE
> > > > +	 * facility on older kernels by setting tx_queue_len=0 (prior
> > > > +	 * to qdisc init), and then forgot to reinit tx_queue_len
> > > > +	 * before again attaching a qdisc.
> > > > +	 */
> > > > +	if ((dev->priv_flags & IFF_NO_QUEUE) && (dev->tx_queue_len == 0)) {
> > > > +		dev->tx_queue_len = DEFAULT_TX_QUEUE_LEN;
> > > > +		netdev_info(dev, "Caught tx_queue_len zero misconfig\n");
> > > > +	}    
> > > 
> > > I wonder why this is limited to IFF_NO_QUEUE devices. Do you think there
> > > is a valid use case for physical ones?  
> > 
> > Hmmm, I cannot come up with a useful use-case for physical devices, but
> > I cannot see why we should save users that had used the loophole on
> > physical devices, as that is clearly a faulty config to begin with.
> > See net_crit_ratelimited warning here:
> >  [1] https://github.com/torvalds/linux/blob/v4.9-rc3/net/core/dev.c#L3403  
> 
> I really feel like nit-picking again,

Perhaps a follow up patch is better?  This patch does solve a real
issue.

> but what differs in between
> loophole users of virtual devices (whose broken scripts stopped working)
> and loophole users of physical devices (whose broken scripts stopped
> working as well)?

There is a difference.  We basically closed the loophole config, but
fixed that qdisc can be attached to virtual (IFF_NO_QUEUE) devices,
without needing to adjusting tx_queue_len.

Thus, running a loophole-script have no-effect, but for IFF_NO_QUEUE
devices (veth specifically) it looks like it had the desired effect,
thus Docker will/can keep doing that, to work with older kernels, and
on newer kernels it just doesn't have any effect.

The remaining problem is that a "loophole-script" leaves the interface
in a broken state with tx_queue_len==0.  Which this patch address.

So, why only catch misconfig for IFF_NO_QUEUE devices?  Because a
loophole-script on veth brought it into a valid config, thus valid
use-case, while one a physical into a invalid config (hence the
critical warn[1]).

You could (in a followup patch, please) argue that it is a lot simpler,
just to always catch the misconfig of having tx_queue_len==0 when
attaching a qdisc.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
