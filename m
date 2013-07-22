From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Mon, 22 Jul 2013 13:54:02 -0700
Message-ID: <1374526442.3436.94.camel@dvhart-mobl1.amr.corp.intel.com>
References: <1374091843-1521-1-git-send-email-dvhart@linux.intel.com>
	 <dfebe34003c2ac50efbca01a86b4b0085e8c1bfa.1374091736.git.dvhart@linux.intel.com>
	 <1374135251.31118.5.camel@smile> <1374167552.4900.13.camel@envy.home>
	 <1374223712.31118.33.camel@smile>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Net Dev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joe Perches <joe@perches.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45797 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933268Ab3GVUyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 16:54:04 -0400
In-Reply-To: <1374223712.31118.33.camel@smile>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-19 at 11:48 +0300, Andy Shevchenko wrote:
> On Thu, 2013-07-18 at 10:12 -0700, Darren Hart wrote: 
> > On Thu, 2013-07-18 at 11:14 +0300, Andy Shevchenko wrote:
> > > On Wed, 2013-07-17 at 13:10 -0700, Darren Hart wrote: 
> 
> []
> 
> > > > --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> > > > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> 
> > > > +static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
> 
> []
> 
> 
> > > Here perhaps you check pdata and GPIO line number (let's say != -1)   
> > > and call GPIO request helper.
> > 
> > I was doing exactly this in local previous version, but I decided
> > against it for a few reasons:
> > 
> > o If I specify GPIO, I must also specify GPIO flags, GPIO label,
> >   GPIO assertion level, GPIO reset and rest timings (and that is
> >   assuming it's just a set, release, wait cycle).
> 
> Why so complicated? Just keep them as defaults inside function like you
> did until we will have the actual board which requires those to be
> altered.

The short answer here is that calling this a generic PHY reset routine
and passing in only the GPIO number embeds very platform specific data
and behavior as defaults which would have to abstracted if the routine
were to be used on any other board. The approach I take here is more
explicit in calling out what is platform specific data.

I do appreciate the suggestion and I did approach this as you suggest
initially, but as I worked through it, it became apparent (to me at
least) that the method presented here kept the required infrastructure
to a minimum while clearly identifying platform specific code and
behavior.

> 
> > o Setting all this in pdata makes very specific to resetting this
> >   specific PHY, while others may have any number of other methods or
> >   procedures. It also excludes other sorts of platform initialization
> >   which might necessary. Specifying GPIO here makes the interface overly
> >   specific in my opinion.
> > 
> > > Next is the name of the function, since you are resetting PHY, what if
> > > you call it like pch_gbe_reset_by_gpio ?
> > 
> > We would need to include PHY in here as we are not resetting the MAC,
> > we are resetting the PHY. I think specifying it as being by gpio is
> > also overly restrictive. If you look at my two new functions (for tx
> > clock delay and hibernate) you can see an example of how we might go
> > about such a function (which indeed I had in a previous version as
> > pch_gbe_phy_physical_reset()). I dropped this as I felt it required too
> > many fields to be added to the pdata and I was better off with platform
> > specific init routines.
> > 
> > You've presented an alternative approach, but it isn't clear to me what
> > your reservations are with the one I took here. What are the problems
> > with it?
> 
> My point is there should be no callback function like
> pch_gbe_minnow_platform_init. It may be transformed to a more generic
> helper which could be reused by an ACPI case as well.
> 
> But okay, it might be I missed the point. Are you going to provide an
> ACPI tables for this IP or you just rely on PCI forever?


For this particular driver, I don't see a lot of value in introducing
new ACPI constructs. But more importantly, the release firmware does not
do so. If the firmware is updated in the future to deal with this, or if
someone else writes their own firmware (as many have expressed interest
in doing) we may have some follow-up to do here.


> > > And most important one is the ACPI case. As far as I understand Minnow
> > > board supports / will support ACPI5 variant of device enumeration. In
> > > such case the GPIO line will come in the ACPI resources. Moreover, you
> > > will have no struct pci_dev. I highly recommend to rewrite this as a
> > > generic helper, which takes GPIO line number as an input parameter and
> > > does the job.
> > 
> > While the MinnowBoard will be expanding its use of ACPI, we do not
> > intend to rewrite existing drivers (such as this one)
> 
> Again, what is wrong with ACPI, if ACPI could manage by itself that
> stuff like specific GPIO lines. I assume ACPI will help a lot to avoid
> this legacy approach with driver_data / callbacks and such things.
> 
> What did I miss?

Nothing is wrong with ACPI. I don't disagree that this could be done
with ACPI, it just isn't currently.

> 
> > > >  static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
> > > >  	{.vendor = PCI_VENDOR_ID_INTEL,
> > > >  	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
> > > > +	 .subvendor = PCI_VENDOR_ID_CIRCUITCO,
> > > > +	 .subdevice = PCI_SUBSYSTEM_ID_CIRCUITCO_MINNOWBOARD,
> > > > +	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
> > > > +	 .class_mask = (0xFFFF00),
> > > > +	 .driver_data = (unsigned long) &pch_gbe_minnow_privdata
> > > 
> > > No need space before &.
> > 
> > Indeed. Fixed. I'll include when I resubmit after netdev opens.
> 
> And you perhaps have to use kernel_ulong_t instead of unsigned long.

Thanks for catching that and pointing me at the correct usage. Fixed in
V2.

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
