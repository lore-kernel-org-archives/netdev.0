From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH][Take3] PCI legacy I/O port free driver - Making Intel
 e1000 driver legacy I/O port free
Date: Mon, 10 Dec 2007 16:03:32 -0800
Message-ID: <475DD3D4.9050203@intel.com>
References: <474CCEAD.1060702@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28716 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbXLKAEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 19:04:15 -0500
In-Reply-To: <474CCEAD.1060702@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tomohiro Kusumi wrote:
> Dear Auke and e1000 maintainers
> 
> Hi, this is the patch which makes the e1000 driver legacy I/O port free.
> 
> I've received some advice from Auke quite long time ago, and submitted
> a patch (http://lkml.org/lkml/2007/8/10/11) which I think meets what Auke
> had told me. Since the patch has not received any reaction from the e1000
> community, let me submit it once again (plus, the previous one had a bug
> regarding module parameter).


this opens up an interesting discussion -

e1000 is going to be the driver for 8254x hardware only from 2.6.25 and on. e1000e
will be the driver that powers 8257x hardware (and ich8/9 and es2lan NICs) and
those are all the pci-e hardware devices.

This means that the current e1000 driver will not power the pci-e hardware anymore
and thus those io-port free devices are removed from e1000.

considering the fact that only 82542, 82543 and 82547 devices are (from 2.6.25) on
the only devices that can be ioport free in this new e1000 driver, I think that it
almost makes no sense to code this functionality up for that.

so, I'm wondering if we should not drop this effort alltogether, since it's just a
lot of code and none of the pci-e hardware should use ioport anymore.

Can you screen e1000e in jeff garzik's netdev-2.6#upstream tree and see if that is
correctly not using ioport? I think that would be worth the time.

Cheers,

Auke



> 
> If the module parameter enable_legacy_ioport_free is set to 0, it does
> not differ from the existing e1000 driver, otherwise legacy I/O port free
> function is enabled. I may have done something wrong, so any comments
> would be helpful.
> 
> Tomohiro Kusumi
> Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
> 
> ---
> diff -Nur linux-2.6.23.org/drivers/net/e1000/e1000.h linux-2.6.23/drivers/net/e1000/e1000.h
> --- linux-2.6.23.org/drivers/net/e1000/e1000.h	2007-10-16 11:30:37.000000000 +0900
> +++ linux-2.6.23/drivers/net/e1000/e1000.h	2007-10-16 11:32:55.000000000 +0900
> @@ -342,6 +342,9 @@
>  	boolean_t quad_port_a;
>  	unsigned long flags;
>  	uint32_t eeprom_wol;
> +
> +	int use_ioport;
> +	int bars;
>  };
> 
>  enum e1000_state_t {
> diff -Nur linux-2.6.23.org/drivers/net/e1000/e1000_main.c linux-2.6.23/drivers/net/e1000/e1000_main.c
> --- linux-2.6.23.org/drivers/net/e1000/e1000_main.c	2007-10-16 11:30:38.000000000 +0900
> +++ linux-2.6.23/drivers/net/e1000/e1000_main.c	2007-10-16 14:48:16.390575464 +0900
> @@ -226,6 +226,11 @@
>  static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev);
>  static void e1000_io_resume(struct pci_dev *pdev);
> 
> +static unsigned int enable_legacy_ioport_free = 0;
> +module_param(enable_legacy_ioport_free, uint, 0644);
> +MODULE_PARM_DESC(enable_legacy_ioport_free, "Enable legacy I/O port free (default:0)");
> +static int e1000_test_legacy_ioport(struct pci_dev *pdev);
> +
>  static struct pci_error_handlers e1000_err_handler = {
>  	.error_detected = e1000_io_error_detected,
>  	.slot_reset = e1000_io_slot_reset,
> @@ -872,8 +877,24 @@
>  	int i, err, pci_using_dac;
>  	uint16_t eeprom_data = 0;
>  	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
> -	if ((err = pci_enable_device(pdev)))
> +	int bars = 0;
> +	int use_ioport = 0;
> +
> +	if (enable_legacy_ioport_free) {
> +		if ((use_ioport = e1000_test_legacy_ioport(pdev)) < 0) {
> +			E1000_ERR("e1000_test_legacy_ioport failed, aborting\n");
> +			return -1;
> +		}
> +		if (use_ioport)
> +			bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
> +		else
> +			bars = pci_select_bars(pdev, IORESOURCE_MEM);
> +		if ((err = pci_enable_device_bars(pdev, bars)) != 0)
> +			return err;
> +	}
> +	else if ((err = pci_enable_device(pdev)) != 0) {
>  		return err;
> +	}
> 
>  	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
>  	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
> @@ -887,7 +908,11 @@
>  		pci_using_dac = 0;
>  	}
> 
> -	if ((err = pci_request_regions(pdev, e1000_driver_name)))
> +	if (enable_legacy_ioport_free)
> +		err = pci_request_selected_regions(pdev, bars, e1000_driver_name);
> +	else
> +		err = pci_request_regions(pdev, e1000_driver_name);
> +	if (err)
>  		goto err_pci_reg;
> 
>  	pci_set_master(pdev);
> @@ -906,6 +931,10 @@
>  	adapter->pdev = pdev;
>  	adapter->hw.back = adapter;
>  	adapter->msg_enable = (1 << debug) - 1;
> +	if (enable_legacy_ioport_free) {
> +		adapter->use_ioport = use_ioport;
> +		adapter->bars = bars;
> +	}
> 
>  	mmio_start = pci_resource_start(pdev, BAR_0);
>  	mmio_len = pci_resource_len(pdev, BAR_0);
> @@ -915,12 +944,14 @@
>  	if (!adapter->hw.hw_addr)
>  		goto err_ioremap;
> 
> -	for (i = BAR_1; i <= BAR_5; i++) {
> -		if (pci_resource_len(pdev, i) == 0)
> -			continue;
> -		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
> -			adapter->hw.io_base = pci_resource_start(pdev, i);
> -			break;
> +	if (!enable_legacy_ioport_free || adapter->use_ioport) {
> +		for (i = BAR_1; i <= BAR_5; i++) {
> +			if (pci_resource_len(pdev, i) == 0)
> +				continue;
> +			if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
> +				adapter->hw.io_base = pci_resource_start(pdev, i);
> +				break;
> +			}
>  		}
>  	}
> 
> @@ -1188,7 +1219,10 @@
>  err_ioremap:
>  	free_netdev(netdev);
>  err_alloc_etherdev:
> -	pci_release_regions(pdev);
> +	if (enable_legacy_ioport_free)
> +		pci_release_selected_regions(pdev, bars);
> +	else
> +		pci_release_regions(pdev);
>  err_pci_reg:
>  err_dma:
>  	pci_disable_device(pdev);
> @@ -1240,7 +1274,10 @@
>  	iounmap(adapter->hw.hw_addr);
>  	if (adapter->hw.flash_address)
>  		iounmap(adapter->hw.flash_address);
> -	pci_release_regions(pdev);
> +	if (enable_legacy_ioport_free)
> +		pci_release_selected_regions(pdev, adapter->bars);
> +	else
> +		pci_release_regions(pdev);
> 
>  	free_netdev(netdev);
> 
> @@ -5180,7 +5217,11 @@
> 
>  	pci_set_power_state(pdev, PCI_D0);
>  	pci_restore_state(pdev);
> -	if ((err = pci_enable_device(pdev))) {
> +	if (enable_legacy_ioport_free)
> +		err = pci_enable_device_bars(pdev, adapter->bars);
> +	else
> +		err = pci_enable_device(pdev);
> +	if (err) {
>  		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
>  		return err;
>  	}
> @@ -5325,4 +5366,42 @@
> 
>  }
> 
> +/*
> + * e1000_test_legacy_ioport - see if the device uses legacy I/O port
> + * @pdev: Pointer to PCI device
> + *
> + * This function tests if the PCI device uses I/O port.
> + * If yes the function returns 1, if no the function returns 0.
> + * The function returns -1 if there is an error.
> + */
> +static int e1000_test_legacy_ioport(struct pci_dev *pdev)
> +{
> +	int ret;
> +	struct e1000_hw hw;
> +	memset(&hw, 0, sizeof(hw));
> +	
> +	hw.mac_type = e1000_undefined;
> +	hw.device_id = pdev->device;
> +	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw.revision_id);
> +
> +	if (e1000_set_mac_type(&hw) < 0)
> +		return -1;
> +
> +	switch (hw.mac_type) {
> +	case e1000_82540:
> +	case e1000_82541:
> +	case e1000_82541_rev_2:
> +	case e1000_82544:
> +	case e1000_82545:
> +	case e1000_82546:
> +		ret = 1;
> +		break;
> +	default:
> +		ret = 0;
> +		break;
> +	}
> +	
> +	return ret;
> +}
> +
>  /* e1000_main.c */
