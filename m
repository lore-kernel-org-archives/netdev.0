From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH 3/3] pch_gbe: Add MinnowBoard support
Date: Mon, 15 Jul 2013 13:41:10 -0700
Message-ID: <1373920870.3475.200.camel@envy.home>
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

On Mon, 2013-07-15 at 11:34 +0300, Andy Shevchenko wrote:
> On Fri, 2013-07-12 at 17:58 -0700, Darren Hart wrote: 

... 
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

Thanks for the pointer, this works and appears to be the best way to
handle this.

...
> > + */
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

On this point, I did find one instance where I initialized init only to
have my first line of executable code assign to ret, that's obviously
silly, so I fixed that one.

Here, where the first assignment is nested inside case statements or
skipped altogether with explicit returns of error codes, I prefer to
assign it explicitly. A quick survey lists 4k initialized "int ret;"
lines and 16k uninitialized.  The latter appears to be the more common,
but there is certainly precedent for the former.

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel
