From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH 3/3] pch_gbe: Add MinnowBoard support
Date: Thu, 18 Jul 2013 10:05:56 -0700
Message-ID: <1374167156.4900.8.camel@envy.home>
References: <1373677087-7747-1-git-send-email-dvhart@linux.intel.com>
	 <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
	 <1373877289.24799.242.camel@smile>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1373877289.24799.242.camel@smile>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(resending as the original appears not to have made it past my sent box)

On Mon, 2013-07-15 at 11:34 +0300, Andy Shevchenko wrote:
> On Fri, 2013-07-12 at 17:58 -0700, Darren Hart wrote: 
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

Hi Andy,

Thank you for taking the time to review...

> 
> > --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> > @@ -582,6 +582,19 @@ struct pch_gbe_hw_stats {
> >  };
> >  
> >  /**
> > + * struct pch_gbe_privdata - PCI Device ID driver data
> > + * @phy_tx_clk_delay:		Bool, configure the PHY TX delay in software
> > + * @phy_disable_hibernate:	Bool, disable PHY hibernation
> > + * @platform_init:		Platform initialization callback, called from
> > + *				probe, prio to PHY initialization.
> > + */
> > +struct pch_gbe_privdata {
> > +	bool phy_tx_clk_delay;
> > +	bool phy_disable_hibernate;
> > +	int(*platform_init)(struct pci_dev *pdev);
> 
> I don't like the platform_init() approach here. 
> I think here should be plain GPIO line number.


I went around and around on this myself. I originally added several
callback functions to this privdata, but ultimately felt it was more
infrastructure than was necessary now, and if it became necessary (a
big "if" in my opinion) I could always augment that as a follow-on
patch.


> I'll explain below why.
> 
> > @@ -604,6 +617,7 @@ struct pch_gbe_hw_stats {
> >   * @rx_buffer_len:	Receive buffer length
> >   * @tx_queue_len:	Transmit queue length
> >   * @have_msi:		PCI MSI mode flag
> > + * @pch_gbe_privdata	PCI Device ID driver_data
> 
> Missed colon.


Ack, thanks.


> > --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> 
> 
> > @@ -2635,6 +2638,9 @@ static int pch_gbe_probe(struct pci_dev *pdev,
> >  	adapter->pdev = pdev;
> >  	adapter->hw.back = adapter;
> >  	adapter->hw.reg = pcim_iomap_table(pdev)[PCH_GBE_PCI_BAR];
> > +	adapter->pdata = (struct pch_gbe_privdata *)pci_id->driver_data;
> > +	if (adapter->pdata && adapter->pdata->platform_init)
> > +		adapter->pdata->platform_init(pdev);
> 
> Here perhaps you check pdata and GPIO line number (let's say != -1) and
> call GPIO request helper.


I was doing exactly this in local previous version, but I decided
against it for a few reasons:

o If I specific GPIO, I should also specify GPIO flags, GPIO label,
GPIO assertion level, GPIO reset and rest timings (and that is assuming
it's just a set, release, wait cycle).

o Setting all this in pdata makes very specific to resetting this
specific PHY, while others may have any number of other methods or
procedures. It also excludes other sorts of platform initialization
which might necessary. Specifying GPIO here makes the interface overly
specific in my opinion.


> > @@ -2720,9 +2730,47 @@ err_free_netdev:
> >  	return ret;
> >  }
> >  
> > +/* The AR803X PHY on the MinnowBoard requires a physical pin to be toggled to
> > + * ensure it is awake for probe and init. Request the line and reset the PHY.
> > + */
> > +static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
> > +{
> > +	int ret = 0;
> > +	int flags = GPIOF_DIR_OUT | GPIOF_INIT_HIGH | GPIOF_EXPORT;
> > +	int gpio = MINNOW_PHY_RESET_GPIO;
> > +
> > +	ret = gpio_request_one(gpio, flags, "minnow_phy_reset");
> > +	if (ret){
> > +		dev_err(&pdev->dev,
> > +			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
> > +		return ret;
> > +	}
> > +
> > +	gpio_set_value(gpio, 0);
> > +	usleep_range(1250, 1500);
> > +	gpio_set_value(gpio, 1);
> > +	usleep_range(1250, 1500);
> 
> First of all, who is going to release gpio? Perhaps
> devm_gpio_request_one?


Oh right, thanks for catching that. I'll need to think on that, there
is no direct way to know I need to release it on module exit in this
implementation.


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

> 
> > +
> > +	return ret;
> > +}
> 
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

...

> > +int pch_gbe_phy_tx_clk_delay(struct pch_gbe_hw *hw)
> > +{
> > +	/* The RGMII interface requires a ~2ns TX clock delay. This is typically
> > +	 * done in layout with a longer trace or via PHY strapping, but can also
> > +	 * be done via PHY configuration registers.
> > +	 */
> > +	struct pch_gbe_adapter *adapter = pch_gbe_hw_to_adapter(hw);
> > +	u16 mii_reg;
> > +	int ret = 0;
> 
> No need to assign. Are you trying to shut (sparse?) warning?


Personal preference I guess. When it comes to return codes I prefer an
explicit assignment.


Thank you for taking the time to review!

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
