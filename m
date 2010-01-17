From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Sun, 17 Jan 2010 08:56:28 -0800
Message-ID: <C27F8246C663564A84BB7AB34397724218281B8382@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20100117003653.GA3073@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>
To: "'Jarek Poplawski'" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4479 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288Ab0AQQ4i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 11:56:38 -0500
In-Reply-To: <20100117003653.GA3073@del.dom.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote
> On Sat, Jan 16, 2010 at 02:50:48PM -0800, Michael Chan wrote:
> > The problem with the patch below is that
> > dev->real_num_tx_queues can still be reduced during bnx2_open().
> >
>
> I'm not sure I get your point, but there should be no problem with
> changing dev->real_num_tx_queues during ->open(). The main intention
> of realloc_netdev_mq() is to give drivers some official way to change
> dev->num_tx_queues until register_netdev() with the main aim: not to
> treat obviously non-mq chips as mq according to netif_is_multiqueue().
> Additional gain is memory saved in the case fixed by the patch below
> (which btw. waits for some refinement/verification).

Yes, the patch achieves what you describe.  dev->num_tx_queues will
be set more accurately during ->probe based on chip type.  In ->open(),
the dev->real_num_tx_queues will still be possibly reduced depending
on the number of CPU cores and whether we can enable and allocate the
MSI-X vectors.

>
> > Is it possible to call realloc_netdev_mq() during ->open()?
>
> No, and no such intention, since there was kind of agreement it's not
> necessary and collides with preserving qdisc state (stats). But the
> discussion isn't closed...
>
> Thanks,
> Jarek P.
>
> >
> > > OOPS! Take 2...;-)
> > >
> > > Jarek P.
> > > ---
> > >
> > >  drivers/net/bnx2.c |    5 +++++
> > >  1 files changed, 5 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> > > index 4bfc808..c1ba2b1 100644
> > > --- a/drivers/net/bnx2.c
> > > +++ b/drivers/net/bnx2.c
> > > @@ -8288,6 +8288,11 @@ bnx2_init_one(struct pci_dev
> *pdev, const struct pci_device_id *ent)
> > >           dev->features |= NETIF_F_TSO6;
> > >           vlan_features_add(dev, NETIF_F_TSO6);
> > >   }
> > > +
> > > + if (!((bp->flags & BNX2_FLAG_MSIX_CAP) ||
> > > +      (bp->flags & BNX2_FLAG_MSI_CAP)) || disable_msi)
> > > +         realloc_netdev_mq(dev, 1);
> > > +

I think we can refine this a little:

        if (!(bp->flags & BNX2_FLAG_MSIX_CAP) || disable_msi)
                realloc_netdev_mq(dev, 1);

Thanks.

> > >   if ((rc = register_netdev(dev))) {
> > >           dev_err(&pdev->dev, "Cannot register net device\n");
> > >           goto error;
> > >
> >
> >
>
>

