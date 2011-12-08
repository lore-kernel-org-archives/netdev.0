From: Milan Kocian <milon@wq.cz>
Subject: Re: [RFT] sky2: 32 bit DMA quirk
Date: Thu, 8 Dec 2011 20:58:33 +0100
Message-ID: <20111208195833.GA13613@ntm.wq.cz>
References: <20111120232118.GA29748@ntm.wq.cz>
 <20111121160543.2ae9c04c@nehalam.linuxnetplumber.net>
 <20111122094234.GA28500@ntm.wq.cz>
 <20111126161513.GA5299@ntm.wq.cz>
 <20111126170331.744025f1@s6510.linuxnetplumber.net>
 <20111205124725.GA19385@ntm.wq.cz>
 <20111205081611.52ec0664@nehalam.linuxnetplumber.net>
 <20111206095919.GA6726@ntm.wq.cz>
 <20111207150205.3fad9290@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wq.cz ([82.202.95.52]:33776 "EHLO rd.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750988Ab1LHUUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 15:20:53 -0500
Content-Disposition: inline
In-Reply-To: <20111207150205.3fad9290@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

On Wed, Dec 07, 2011 at 03:02:05PM -0800, Stephen Hemminger wrote:
> This a patch to force 32 bit DMA. Not sure if the DMI values
> are right for the Gigabyte motherboard with the problem.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 

Unfortunately it didn't help. I tried parameter
only_32bit_dma=1 alone and then with parameter disable_msi=1
with the same result.


> --- a/drivers/net/ethernet/marvell/sky2.c	2011-12-07 10:54:18.816279159 -0800
> +++ b/drivers/net/ethernet/marvell/sky2.c	2011-12-07 14:59:47.737381388 -0800
> @@ -41,6 +41,7 @@
>  #include <linux/delay.h>
>  #include <linux/workqueue.h>
>  #include <linux/if_vlan.h>
> +#include <linux/dmi.h>
>  #include <linux/prefetch.h>
>  #include <linux/debugfs.h>
>  #include <linux/mii.h>
> @@ -95,6 +96,10 @@ static int disable_msi = 0;
>  module_param(disable_msi, int, 0);
>  MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
>  
> +static int only_32bit_dma;
> +module_param(only_32bit_dma, int, 0);
> +MODULE_PARM_DESC(only_32bit_dma, "Limit device to 32 bit DMA access");
> +
>  static DEFINE_PCI_DEVICE_TABLE(sky2_id_table) = {
>  	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
>  	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
> @@ -4889,7 +4894,7 @@ static int __devinit sky2_probe(struct p
>  
>  	pci_set_master(pdev);
>  
> -	if (sizeof(dma_addr_t) > sizeof(u32) &&
> +	if (sizeof(dma_addr_t) > sizeof(u32) && !only_32bit_dma &&
>  	    !(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64)))) {
>  		using_dac = 1;
>  		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
> @@ -5163,10 +5168,24 @@ static struct pci_driver sky2_driver = {
>  	.driver.pm = SKY2_PM_OPS,
>  };
>  
> +static struct dmi_system_id sky2_32bit_dma_boards[] = {
> +	{
> +		.ident = "Gigabyte GA-965GM-S2 boards",
> +		.matches = {
> +			DMI_MATCH(DMI_BOARD_VENDOR, "Gigabyte Technology Co"),
> +			DMI_MATCH(DMI_BOARD_NAME, "GA-965GM-S2"),
> +		},
> +	},
> +	{}
> +};
> +
>  static int __init sky2_init_module(void)
>  {
>  	pr_info("driver version " DRV_VERSION "\n");
>  
> +	if (dmi_check_system(sky2_32bit_dma_boards))
> +		only_32bit_dma = 1;
> +
>  	sky2_debug_init();
>  	return pci_register_driver(&sky2_driver);
>  }
> 
> 

-- 
Milan Kocian
