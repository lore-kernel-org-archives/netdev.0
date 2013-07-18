From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Thu, 18 Jul 2013 11:14:11 +0300
Message-ID: <1374135251.31118.5.camel@smile>
References: <1374091843-1521-1-git-send-email-dvhart@linux.intel.com>
	 <dfebe34003c2ac50efbca01a86b4b0085e8c1bfa.1374091736.git.dvhart@linux.intel.com>
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
Received: from mga03.intel.com ([143.182.124.21]:23122 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756936Ab3GRIOX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 04:14:23 -0400
In-Reply-To: <dfebe34003c2ac50efbca01a86b4b0085e8c1bfa.1374091736.git.dvhart@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-17 at 13:10 -0700, Darren Hart wrote: 
> The MinnowBoard uses an AR803x PHY with the PCH GBE which requires
> special handling. Use the MinnowBoard PCI Subsystem ID to detect this
> and add a pci_device_id.driver_data structure and functions to handle
> platform setup.
> 
> The AR803x does not implement the RGMII 2ns TX clock delay in the trace
> routing nor via strapping. Add a detection method for the board and the
> PHY and enable the TX clock delay via the registers.
> 
> This PHY will hibernate without link for 10 seconds. Ensure the PHY is
> awake for probe and then disable hibernation. A future improvement would
> be to convert pch_gbe to using PHYLIB and making sure we can wake the
> PHY at the necessary times rather than permanently disabling it.

Few comments below.

> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> @@ -581,6 +581,18 @@ struct pch_gbe_hw_stats {
>  	u32 intr_tcpip_err_count;
>  };
>  
> +/* struct pch_gbe_privdata - PCI Device ID driver data

Perhaps
/**
* struct ...
?

> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c


> @@ -2720,9 +2730,48 @@ err_free_netdev:
>  	return ret;
>  }
>  
> +/* The AR803X PHY on the MinnowBoard requires a physical pin to be toggled to
> + * ensure it is awake for probe and init. Request the line and reset the PHY.
> + */
> +static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
> +{
> +	int flags = GPIOF_DIR_OUT | GPIOF_INIT_HIGH | GPIOF_EXPORT;
> +	int gpio = MINNOW_PHY_RESET_GPIO;
> +	int ret;
> +
> +	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
> +				    "minnow_phy_reset");
> +	if (ret) {
> +		dev_err(&pdev->dev,
> +			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
> +		return ret;
> +	}
> +
> +	gpio_set_value(gpio, 0);
> +	usleep_range(1250, 1500);
> +	gpio_set_value(gpio, 1);
> +	usleep_range(1250, 1500);
> +
> +	return ret;
> +}

You ignored couple of comments regarding this function. Why?

>  static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
>  	{.vendor = PCI_VENDOR_ID_INTEL,
>  	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
> +	 .subvendor = PCI_VENDOR_ID_CIRCUITCO,
> +	 .subdevice = PCI_SUBSYSTEM_ID_CIRCUITCO_MINNOWBOARD,
> +	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
> +	 .class_mask = (0xFFFF00),
> +	 .driver_data = (unsigned long) &pch_gbe_minnow_privdata

No need space before &.


-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
