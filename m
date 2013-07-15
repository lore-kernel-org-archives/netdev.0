From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH 3/3] pch_gbe: Add MinnowBoard support
Date: Mon, 15 Jul 2013 11:34:49 +0300
Message-ID: <1373877289.24799.242.camel@smile>
References: <1373677087-7747-1-git-send-email-dvhart@linux.intel.com>
	 <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-12 at 17:58 -0700, Darren Hart wrote: 
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
> @@ -582,6 +582,19 @@ struct pch_gbe_hw_stats {
>  };
>  
>  /**
> + * struct pch_gbe_privdata - PCI Device ID driver data
> + * @phy_tx_clk_delay:		Bool, configure the PHY TX delay in software
> + * @phy_disable_hibernate:	Bool, disable PHY hibernation
> + * @platform_init:		Platform initialization callback, called from
> + *				probe, prio to PHY initialization.
> + */
> +struct pch_gbe_privdata {
> +	bool phy_tx_clk_delay;
> +	bool phy_disable_hibernate;
> +	int(*platform_init)(struct pci_dev *pdev);

I don't like the platform_init() approach here. 
I think here should be plain GPIO line number.

I'll explain below why.

> @@ -604,6 +617,7 @@ struct pch_gbe_hw_stats {
>   * @rx_buffer_len:	Receive buffer length
>   * @tx_queue_len:	Transmit queue length
>   * @have_msi:		PCI MSI mode flag
> + * @pch_gbe_privdata	PCI Device ID driver_data

Missed colon.

> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c


> @@ -2635,6 +2638,9 @@ static int pch_gbe_probe(struct pci_dev *pdev,
>  	adapter->pdev = pdev;
>  	adapter->hw.back = adapter;
>  	adapter->hw.reg = pcim_iomap_table(pdev)[PCH_GBE_PCI_BAR];
> +	adapter->pdata = (struct pch_gbe_privdata *)pci_id->driver_data;
> +	if (adapter->pdata && adapter->pdata->platform_init)
> +		adapter->pdata->platform_init(pdev);

Here perhaps you check pdata and GPIO line number (let's say != -1) and
call GPIO request helper.

> @@ -2720,9 +2730,47 @@ err_free_netdev:
>  	return ret;
>  }
>  
> +/* The AR803X PHY on the MinnowBoard requires a physical pin to be toggled to
> + * ensure it is awake for probe and init. Request the line and reset the PHY.
> + */
> +static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
> +{
> +	int ret = 0;
> +	int flags = GPIOF_DIR_OUT | GPIOF_INIT_HIGH | GPIOF_EXPORT;
> +	int gpio = MINNOW_PHY_RESET_GPIO;
> +
> +	ret = gpio_request_one(gpio, flags, "minnow_phy_reset");
> +	if (ret){
> +		dev_err(&pdev->dev,
> +			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
> +		return ret;
> +	}
> +
> +	gpio_set_value(gpio, 0);
> +	usleep_range(1250, 1500);
> +	gpio_set_value(gpio, 1);
> +	usleep_range(1250, 1500);

First of all, who is going to release gpio? Perhaps
devm_gpio_request_one?

Next is the name of the function, since you are resetting PHY, what if
you call it like pch_gbe_reset_by_gpio ?

> +
> +	return ret;
> +}

And most important one is the ACPI case. As far as I understand Minnow
board supports / will support ACPI5 variant of device enumeration. In
such case the GPIO line will come in the ACPI resources. Moreover, you
will have no struct pci_dev. I highly recommend to rewrite this as a
generic helper, which takes GPIO line number as an input parameter and
does the job.


> +
> +static struct pch_gbe_privdata pch_gbe_minnow_privdata = {
> +	.phy_tx_clk_delay = true,
> +	.phy_disable_hibernate = true,
> +	.platform_init = pch_gbe_minnow_platform_init,
> +};
> +
>  static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
>  	{.vendor = PCI_VENDOR_ID_INTEL,
>  	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
> +	 .subvendor = PCI_VENDOR_ID_CIRCUITCO,
> +	 .subdevice = PCI_SUBSYSTEM_ID_CIRCUITCO_MINNOWBOARD,
> +	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
> +	 .class_mask = (0xFFFF00),
> +	 .driver_data = (unsigned long) &pch_gbe_minnow_privdata
> +	 },
> +	{.vendor = PCI_VENDOR_ID_INTEL,
> +	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
>  	 .subvendor = PCI_ANY_ID,
>  	 .subdevice = PCI_ANY_ID,
>  	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),

> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c

> @@ -277,4 +286,93 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
>  	pch_gbe_phy_read_reg_miic(hw, PHY_PHYSP_CONTROL, &mii_reg);
>  	mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
>  	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
> +
> +	/* Setup a TX clock delay on certain platforms */
> +	if (adapter->pdata->phy_tx_clk_delay)
> +		pch_gbe_phy_tx_clk_delay(hw);
> +}
> +
> +/**
> + * pch_gbe_phy_tx_clk_delay - Setup TX clock delay via the PHY
> + * @hw:	            Pointer to the HW structure
> + * Returns
> + *	0:		Successful.
> + *	-EINVAL:	Invalid argument.
> + */
> +int pch_gbe_phy_tx_clk_delay(struct pch_gbe_hw *hw)
> +{
> +	/* The RGMII interface requires a ~2ns TX clock delay. This is typically
> +	 * done in layout with a longer trace or via PHY strapping, but can also
> +	 * be done via PHY configuration registers.
> +	 */
> +	struct pch_gbe_adapter *adapter = pch_gbe_hw_to_adapter(hw);
> +	u16 mii_reg;
> +	int ret = 0;

No need to assign. Are you trying to shut (sparse?) warning?

> +
> +	switch (hw->phy.id) {
> +	case PHY_AR803X_ID:
> +		netdev_dbg(adapter->netdev,
> +			   "Configuring AR803X PHY for 2ns TX clock delay\n"); 
> +		pch_gbe_phy_read_reg_miic(hw, PHY_AR8031_DBG_OFF, &mii_reg);
> +		ret = pch_gbe_phy_write_reg_miic(hw, PHY_AR8031_DBG_OFF,
> +						 PHY_AR8031_SERDES);
> +		if (ret)
> +			break;
> +
> +		pch_gbe_phy_read_reg_miic(hw, PHY_AR8031_DBG_DAT, &mii_reg);
> +		mii_reg |= PHY_AR8031_SERDES_TX_CLK_DLY;
> +		ret = pch_gbe_phy_write_reg_miic(hw, PHY_AR8031_DBG_DAT,
> +						 mii_reg);
> +		break;
> +	default:
> +		netdev_err(adapter->netdev,
> +			   "Unknown PHY (%x), could not set TX clock delay.\n",
> +			   hw->phy.id);
> +		return -EINVAL;
> +	}
> +
> +	if (ret)
> +		netdev_err(adapter->netdev,
> +			   "Could not configure tx clock delay for PHY.\n");
> +	return ret;
> +}
> +
> +/**
> + * pch_gbe_phy_disable_hibernate - Disable the PHY low power state
> + * @hw:	            Pointer to the HW structure
> + * Returns
> + *	0:		Successful.
> + *	-EINVAL:	Invalid argument.
> + */
> +int pch_gbe_phy_disable_hibernate(struct pch_gbe_hw *hw)
> +{
> +	struct pch_gbe_adapter *adapter = pch_gbe_hw_to_adapter(hw);
> +	u16 mii_reg;
> +	int ret = 0;

Ditto.

> +	switch (hw->phy.id) {
> +	case PHY_AR803X_ID:
> +		netdev_dbg(adapter->netdev,
> +			   "Disabling hibernation for AR803X PHY\n");
> +		ret = pch_gbe_phy_write_reg_miic(hw, PHY_AR8031_DBG_OFF,
> +						 PHY_AR8031_HIBERNATE);
> +		if (ret)
> +			break;
> +
> +		pch_gbe_phy_read_reg_miic(hw, PHY_AR8031_DBG_DAT, &mii_reg);
> +		mii_reg &= ~PHY_AR8031_PS_HIB_EN;
> +		ret = pch_gbe_phy_write_reg_miic(hw, PHY_AR8031_DBG_DAT,
> +						 mii_reg);
> +		break;
> +	default:
> +		netdev_err(adapter->netdev,
> +			   "Unknown PHY (%x), could not disable hibernation\n",
> +			   hw->phy.id);
> +		return -EINVAL;
> +	}
> +
> +	if (ret)
> +		netdev_err(adapter->netdev,
> +			   "Could not disable PHY hibernation.\n");
> +	return ret;
>  }


-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
