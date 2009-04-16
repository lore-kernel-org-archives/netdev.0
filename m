From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: e1000 watchdog timer fails to start after ethool settings
 change
Date: Thu, 16 Apr 2009 09:43:55 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0904160921570.732@jbrandeb-desk1.amr.corp.intel.com>
References: <1239857869.31663.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, jesse.brandeburg@intel.com,
	david.graham@intel.com
To: Ed Swierk <eswierk@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41861 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755711AbZDPQn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 12:43:57 -0400
In-Reply-To: <1239857869.31663.29.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

added maintainer's list

On Wed, 15 Apr 2009, Ed Swierk wrote:
> A recent patch to e1000, intended to avoid a race in the interrupt code,
> seems to prevent the watchdog timer from resuming properly.  It neuters
> the effect of
> 
>   /* fire a link change interrupt to start the watchdog */ 
>   ew32(ICS, E1000_ICS_LSC); 
>  
> in e1000_up() when the __E1000_RESETTING flag is set, for example when
> invoked by e1000_set_settings().

Ugh, ethtool, my old nemesis.
 
> The result is that running
> 
>   ethtool -s eth0 autoneg on
> 
> in Qemu with an emulated e1000 NIC causes the kernel to stop noticing
> link status changes, leaving the link down until I prod the driver with
> ifconfig eth0 down; ifconfig eth0 up.

Wow, thanks very much for reporting this, it is a pretty subtle bug that 
I'm sure wasn't too easy to find.

I've got to think some on how to fix this and I hope to have a patch in 
the next few days.  Would you agree not very high priority?

My guess is this may be related to the people that reported vmware failing 
with this same change.

Why it doesn't occur on real physical hardware will be interesting to find 
out as well.

> Here is the patch causing the bug:
> 
> > From: Jesse Brandeburg <jesse.brandeburg@xxxxxxxxx>
> > 
> > A nasty bug was found where an MTU change (or anything else that caused a
> > reset) could race with the interrupt code.  The interrupt code was entered
> > by a shared interrupt during the MTU change.
> > 
> > This change prevents the interrupt code from running while the driver is in
> > the middle of its reset path.
> > 
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@xxxxxxxxx>
> > ---
> > 
> >  drivers/net/e1000/e1000_main.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> > index 26474c9..c986978 100644
> > --- a/drivers/net/e1000/e1000_main.c
> > +++ b/drivers/net/e1000/e1000_main.c
> > @@ -31,7 +31,7 @@
> >  
> >  char e1000_driver_name[] = "e1000";
> >  static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
> > -#define DRV_VERSION "7.3.20-k3-NAPI"
> > +#define DRV_VERSION "7.3.21-k3-NAPI"
> >  const char e1000_driver_version[] = DRV_VERSION;
> >  static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
> >  
> > @@ -3712,7 +3712,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
> >  	struct e1000_hw *hw = &adapter->hw;
> >  	u32 rctl, icr = er32(ICR);
> >  
> > -	if (unlikely(!icr))
> > +	if (unlikely((!icr) || test_bit(__E1000_RESETTING, &adapter->flags)))
> >  		return IRQ_NONE;  /* Not our interrupt */
> >  
> >  	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
> > 
> 
> Undoing the patch fixes the problem on a Qemu emulated e1000 NIC:
> 
> Index: linux-2.6.29.1/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.29.1.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6.29.1/drivers/net/e1000/e1000_main.c
> @@ -3712,7 +3712,7 @@ static irqreturn_t e1000_intr(int irq, v
>  	struct e1000_hw *hw = &adapter->hw;
>  	u32 rctl, icr = er32(ICR);
>  
> -	if (unlikely((!icr) || test_bit(__E1000_RESETTING, &adapter->flags)))
> +	if (unlikely(!icr))
>  		return IRQ_NONE;  /* Not our interrupt */
>  
>  	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
> 
> ---
> 
> Of course this leaves the original problem unfixed; hopefully someone
> can suggest a better solution.

Give us a few days, I think we can come up with something.

Jesse
