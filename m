From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Thu, 18 Jul 2013 10:12:32 -0700
Message-ID: <1374167552.4900.13.camel@envy.home>
References: <1374091843-1521-1-git-send-email-dvhart@linux.intel.com>
	 <dfebe34003c2ac50efbca01a86b4b0085e8c1bfa.1374091736.git.dvhart@linux.intel.com>
	 <1374135251.31118.5.camel@smile>
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
Received: from mga14.intel.com ([143.182.124.37]:52939 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758705Ab3GRRMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jul 2013 13:12:41 -0400
In-Reply-To: <1374135251.31118.5.camel@smile>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-18 at 11:14 +0300, Andy Shevchenko wrote:
> On Wed, 2013-07-17 at 13:10 -0700, Darren Hart wrote: 
> > The MinnowBoard uses an AR803x PHY with the PCH GBE which requires
> > special handling. Use the MinnowBoard PCI Subsystem ID to detect this
> > and add a pci_device_id.driver_data structure and functions to handle
> > platform setup.
> > 
> > The AR803x does not implement the RGMII 2ns TX clock delay in the trace
> > routing nor via strapping. Add a detection method for the board and the
> > PHY and enable the TX clock delay via the registers.
> > 
> > This PHY will hibernate without link for 10 seconds. Ensure the PHY is
> > awake for probe and then disable hibernation. A future improvement would
> > be to convert pch_gbe to using PHYLIB and making sure we can wake the
> > PHY at the necessary times rather than permanently disabling it.
> 
> Few comments below.
> 
> > --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> > @@ -581,6 +581,18 @@ struct pch_gbe_hw_stats {
> >  	u32 intr_tcpip_err_count;
> >  };
> >  
> > +/* struct pch_gbe_privdata - PCI Device ID driver data
> 
> Perhaps
> /**
> * struct ...
> ?

This is a /net patch and multiline comments are to be formatted as I did
here. checkpatch catches this and it was also added to the under-review
netdev FAQ.

> 
> > --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> 
> 
> > @@ -2720,9 +2730,48 @@ err_free_netdev:
> >  	return ret;
> >  }
> >  
> > +/* The AR803X PHY on the MinnowBoard requires a physical pin to be toggled to
> > + * ensure it is awake for probe and init. Request the line and reset the PHY.
> > + */
> > +static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
> > +{
> > +	int flags = GPIOF_DIR_OUT | GPIOF_INIT_HIGH | GPIOF_EXPORT;
> > +	int gpio = MINNOW_PHY_RESET_GPIO;
> > +	int ret;
> > +
> > +	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
> > +				    "minnow_phy_reset");
> > +	if (ret) {
> > +		dev_err(&pdev->dev,
> > +			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
> > +		return ret;
> > +	}
> > +
> > +	gpio_set_value(gpio, 0);
> > +	usleep_range(1250, 1500);
> > +	gpio_set_value(gpio, 1);
> > +	usleep_range(1250, 1500);
> > +
> > +	return ret;
> > +}
> 
> You ignored couple of comments regarding this function. Why?


Hrm? I either incorporated or justified why I didn't for each bit of
feedback.... And looking through the archive on lkml.org, I only see my
second response to you and not the first which has all the detail....
which would explain why you didn't respond then. I have it in my sent
mail, but it doesn't appear to have gone out. I've resent and I'll
summarize here.

> I don't like the platform_init() approach here. 
> I think here should be plain GPIO line number.

I went around and around on this myself. I originally added several
callback functions to this privdata, but ultimately felt it was more
infrastructure than was necessary now, and if it became necessary (a
big "if" in my opinion) I could always augment that as a follow-on
patch.

> Here perhaps you check pdata and GPIO line number (let's say != -1)   
> and call GPIO request helper.

I was doing exactly this in local previous version, but I decided
against it for a few reasons:

o If I specify GPIO, I must also specify GPIO flags, GPIO label,
  GPIO assertion level, GPIO reset and rest timings (and that is
  assuming it's just a set, release, wait cycle).

o Setting all this in pdata makes very specific to resetting this
  specific PHY, while others may have any number of other methods or
  procedures. It also excludes other sorts of platform initialization
  which might necessary. Specifying GPIO here makes the interface overly
  specific in my opinion.

> Next is the name of the function, since you are resetting PHY, what if
> you call it like pch_gbe_reset_by_gpio ?

We would need to include PHY in here as we are not resetting the MAC,
we are resetting the PHY. I think specifying it as being by gpio is
also overly restrictive. If you look at my two new functions (for tx
clock delay and hibernate) you can see an example of how we might go
about such a function (which indeed I had in a previous version as
pch_gbe_phy_physical_reset()). I dropped this as I felt it required too
many fields to be added to the pdata and I was better off with platform
specific init routines.

You've presented an alternative approach, but it isn't clear to me what
your reservations are with the one I took here. What are the problems
with it?

> And most important one is the ACPI case. As far as I understand Minnow
> board supports / will support ACPI5 variant of device enumeration. In
> such case the GPIO line will come in the ACPI resources. Moreover, you
> will have no struct pci_dev. I highly recommend to rewrite this as a
> generic helper, which takes GPIO line number as an input parameter and
> does the job.

While the MinnowBoard will be expanding its use of ACPI, we do not
intend to rewrite existing drivers (such as this one) or firmware
platform code. We are looking only to describe the Lure's (daughter
cards) with additional tables.


> 
> >  static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
> >  	{.vendor = PCI_VENDOR_ID_INTEL,
> >  	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
> > +	 .subvendor = PCI_VENDOR_ID_CIRCUITCO,
> > +	 .subdevice = PCI_SUBSYSTEM_ID_CIRCUITCO_MINNOWBOARD,
> > +	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
> > +	 .class_mask = (0xFFFF00),
> > +	 .driver_data = (unsigned long) &pch_gbe_minnow_privdata
> 
> No need space before &.

Indeed. Fixed. I'll include when I resubmit after netdev opens.

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
