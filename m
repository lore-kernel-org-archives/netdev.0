From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Sun, 17 Jan 2010 01:36:53 +0100
Message-ID: <20100117003653.GA3073@del.dom.local>
References: <4B17EFE3.4080301@gmail.com>
 <20091203202937.GA11436@ami.dom.local>
 <4B182DC6.5030800@gmail.com>
 <20091203.133108.254093305.davem@davemloft.net>
 <4B1832DD.1070805@gmail.com>
 <20091203224742.GA16646@ami.dom.local>
 <4B18440A.2080507@gmail.com>
 <20091204130134.GA9336@ff.dom.local>
 <20091204134951.GA9711@ff.dom.local>
 <1263682248.9026.7.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:51072 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab0AQAhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 19:37:00 -0500
Received: by fxm25 with SMTP id 25so103613fxm.21
        for <netdev@vger.kernel.org>; Sat, 16 Jan 2010 16:36:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1263682248.9026.7.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 16, 2010 at 02:50:48PM -0800, Michael Chan wrote:
> 
> On Fri, 2009-12-04 at 05:49 -0800, Jarek Poplawski wrote:
> > On Fri, Dec 04, 2009 at 01:01:34PM +0000, Jarek Poplawski wrote:
> > > Eric, if didn't miss something in the example you gave at the
> > > beginning of this thread, it seems a change like below (not compiled)
> > > should fix your problem (without even testing MSI exactly)?
> > 
> 
> Bringing back an older thread.  Are we still planning to use
> realloc_netdev_mq()?

I hope so, except it seems we lost Eric's interest in (t)his idea,
and got Peter's kind opinion.

> The problem with the patch below is that
> dev->real_num_tx_queues can still be reduced during bnx2_open().
> 

I'm not sure I get your point, but there should be no problem with
changing dev->real_num_tx_queues during ->open(). The main intention
of realloc_netdev_mq() is to give drivers some official way to change
dev->num_tx_queues until register_netdev() with the main aim: not to
treat obviously non-mq chips as mq according to netif_is_multiqueue().
Additional gain is memory saved in the case fixed by the patch below
(which btw. waits for some refinement/verification).

> Is it possible to call realloc_netdev_mq() during ->open()?

No, and no such intention, since there was kind of agreement it's not
necessary and collides with preserving qdisc state (stats). But the
discussion isn't closed...

Thanks,
Jarek P.

> 
> > OOPS! Take 2...;-)
> >  
> > Jarek P.
> > ---
> > 
> >  drivers/net/bnx2.c |    5 +++++
> >  1 files changed, 5 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> > index 4bfc808..c1ba2b1 100644
> > --- a/drivers/net/bnx2.c
> > +++ b/drivers/net/bnx2.c
> > @@ -8288,6 +8288,11 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
> >  		dev->features |= NETIF_F_TSO6;
> >  		vlan_features_add(dev, NETIF_F_TSO6);
> >  	}
> > +
> > +	if (!((bp->flags & BNX2_FLAG_MSIX_CAP) ||
> > +	     (bp->flags & BNX2_FLAG_MSI_CAP)) || disable_msi)
> > +		realloc_netdev_mq(dev, 1);
> > +
> >  	if ((rc = register_netdev(dev))) {
> >  		dev_err(&pdev->dev, "Cannot register net device\n");
> >  		goto error;
> > 
> 
> 
