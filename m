From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Fri, 19 Jul 2013 11:48:32 +0300
Message-ID: <1374223712.31118.33.camel@smile>
References: <1374091843-1521-1-git-send-email-dvhart@linux.intel.com>
	 <dfebe34003c2ac50efbca01a86b4b0085e8c1bfa.1374091736.git.dvhart@linux.intel.com>
	 <1374135251.31118.5.camel@smile> <1374167552.4900.13.camel@envy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Linux Net Dev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joe Perches <joe@perches.com>
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:47282 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760047Ab3GSIsr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 04:48:47 -0400
In-Reply-To: <1374167552.4900.13.camel@envy.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-18 at 10:12 -0700, Darren Hart wrote: 
> On Thu, 2013-07-18 at 11:14 +0300, Andy Shevchenko wrote:
> > On Wed, 2013-07-17 at 13:10 -0700, Darren Hart wrote: 

[]

> > > --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> > > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c

> > > +static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)

[]


> > Here perhaps you check pdata and GPIO line number (let's say != -1)   
> > and call GPIO request helper.
> 
> I was doing exactly this in local previous version, but I decided
> against it for a few reasons:
> 
> o If I specify GPIO, I must also specify GPIO flags, GPIO label,
>   GPIO assertion level, GPIO reset and rest timings (and that is
>   assuming it's just a set, release, wait cycle).

Why so complicated? Just keep them as defaults inside function like you
did until we will have the actual board which requires those to be
altered.

> o Setting all this in pdata makes very specific to resetting this
>   specific PHY, while others may have any number of other methods or
>   procedures. It also excludes other sorts of platform initialization
>   which might necessary. Specifying GPIO here makes the interface overly
>   specific in my opinion.
> 
> > Next is the name of the function, since you are resetting PHY, what if
> > you call it like pch_gbe_reset_by_gpio ?
> 
> We would need to include PHY in here as we are not resetting the MAC,
> we are resetting the PHY. I think specifying it as being by gpio is
> also overly restrictive. If you look at my two new functions (for tx
> clock delay and hibernate) you can see an example of how we might go
> about such a function (which indeed I had in a previous version as
> pch_gbe_phy_physical_reset()). I dropped this as I felt it required too
> many fields to be added to the pdata and I was better off with platform
> specific init routines.
> 
> You've presented an alternative approach, but it isn't clear to me what
> your reservations are with the one I took here. What are the problems
> with it?

My point is there should be no callback function like
pch_gbe_minnow_platform_init. It may be transformed to a more generic
helper which could be reused by an ACPI case as well.

But okay, it might be I missed the point. Are you going to provide an
ACPI tables for this IP or you just rely on PCI forever?

> > And most important one is the ACPI case. As far as I understand Minnow
> > board supports / will support ACPI5 variant of device enumeration. In
> > such case the GPIO line will come in the ACPI resources. Moreover, you
> > will have no struct pci_dev. I highly recommend to rewrite this as a
> > generic helper, which takes GPIO line number as an input parameter and
> > does the job.
> 
> While the MinnowBoard will be expanding its use of ACPI, we do not
> intend to rewrite existing drivers (such as this one)

Again, what is wrong with ACPI, if ACPI could manage by itself that
stuff like specific GPIO lines. I assume ACPI will help a lot to avoid
this legacy approach with driver_data / callbacks and such things.

What did I miss?

> > >  static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
> > >  	{.vendor = PCI_VENDOR_ID_INTEL,
> > >  	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
> > > +	 .subvendor = PCI_VENDOR_ID_CIRCUITCO,
> > > +	 .subdevice = PCI_SUBSYSTEM_ID_CIRCUITCO_MINNOWBOARD,
> > > +	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
> > > +	 .class_mask = (0xFFFF00),
> > > +	 .driver_data = (unsigned long) &pch_gbe_minnow_privdata
> > 
> > No need space before &.
> 
> Indeed. Fixed. I'll include when I resubmit after netdev opens.

And you perhaps have to use kernel_ulong_t instead of unsigned long.


-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
