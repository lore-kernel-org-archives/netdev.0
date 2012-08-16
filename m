From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [PATCH] bnx2: turn off the network statck during
 initialization
Date: Thu, 16 Aug 2012 12:28:38 -0700
Message-ID: <1345145318.6916.42.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1345141295-7589-1-git-send-email-Jiang.Wang@riverbed.com>
 <1345143431.6916.36.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <CEE05A0D7856E14880AD5560634EBEA834DB2ABC@SFO1EXC-MBXP06.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Chaitanya Lala" <Chaitanya.Lala@riverbed.com>,
	"Francis St. Amant" <Francis.St.Amant@riverbed.com>
To: "Jiang Wang" <Jiang.Wang@riverbed.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CEE05A0D7856E14880AD5560634EBEA834DB2ABC@SFO1EXC-MBXP06.nbttech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-16 at 19:15 +0000, Jiang Wang wrote: 
> Hi Michael,
> 
> I just checked the code for netif_carrier_off(), and it will return if
> the dev is not initialized (registered) as follows:
> 
> void netif_carrier_off(struct net_device *dev)
> {
>         if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
>                 if (dev->reg_state == NETREG_UNINITIALIZED)
>                         return;
>                 linkwatch_fire_event(dev);
>         }
> }
> 
> So linkwatch_fire_event should not fire in this case, right? Thanks
> for the quick response.
> 
Yes, you're right.  Your patch should not cause any problem then.

But I still don't understand what problem you're trying to solve.  The
link status from ethtool is determined by bnx2_get_link() and it should
always return link down before bnx2_open() is called.  Can you please
elborate?  Thanks.

> Regards,
> 
> Jiang
> 
> -------------------------------------
> Jiang Wang
> Member of Technical Staff
> Riverbed Technology
> Tel: (408) 522-5109
> Email: Jiang.Wang@riverbed.com
> www.riverbed.com
> 
> 
> -----Original Message-----
> From: Michael Chan [mailto:mchan@broadcom.com] 
> Sent: Thursday, August 16, 2012 11:57 AM
> To: Jiang Wang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Chaitanya Lala; Francis St. Amant; Jiang Wang
> Subject: Re: [PATCH] bnx2: turn off the network statck during initialization
> 
> On Thu, 2012-08-16 at 11:21 -0700, Jiang Wang wrote: 
> > The initialization state of bnx2 driver is wrong. It does not turn of 
> > the Linux network stack using netif_carrier_off. This may lead to 
> > inconsistent report from ethtool as the link is up but speed is 
> > unknown when the cable is not plugged in.
> > 
> > E.g.
> >         Speed: Unknown! (0)<--------------------------------------
> >         Duplex: Half       <--------------------------------------
> >         MDI: Unknown! (0)
> >         Port: Twisted Pair
> >         PHYAD: 1
> >         Transceiver: internal
> >         Auto-negotiation: on
> >         Supports Wake-on: g
> >         Wake-on: d
> >         Link detected: yes <---------------------------------------
> > 
> > This patches fixed the problem by turning off the network stack during 
> > initialization.
> > 
> > Signed-off-by: Jiang Wang <jwang@riverbed.com>
> > ---
> >  drivers/net/ethernet/broadcom/bnx2.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/bnx2.c 
> > b/drivers/net/ethernet/broadcom/bnx2.c
> > index ac7b744..ce4548d 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2.c
> > +++ b/drivers/net/ethernet/broadcom/bnx2.c
> > @@ -8463,6 +8463,10 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
> >  	dev->features |= dev->hw_features;
> >  	dev->priv_flags |= IFF_UNICAST_FLT;
> >  
> > +	/* tell the stack to leave us alone until bnx2_open() is called */
> > +	netif_carrier_off(dev);
> 
> We have tried this before and this didn't work.  netif_carrier_off() calls linkwatch_fire_event() to schedule the event.  If
> register_netdev() fails for whatever reason, the netdev will be freed but the link_watch event may still be scheduled.
> 
> Calling netif_carrier_off() after register_netdev() returns successfully also may not work as it will race with bnx2_open() which enables IRQ.
> An linkup IRQ can happen at time and we may end up with the wrong carrier state because of the race condition.
> 
> > +	netif_stop_queue(dev);
> > +
> >  	if ((rc = register_netdev(dev))) {
> >  		dev_err(&pdev->dev, "Cannot register net device\n");
> >  		goto error;
> 
> 
> 
> 
