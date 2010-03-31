From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: Add esd board support to plx_pci CAN driver
Date: Wed, 31 Mar 2010 20:25:13 +0200
Message-ID: <4BB39389.9050909@grandegger.com>
References: <201003311732.59921.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Socketcan-core@lists.berlios.de
To: Matthias Fuchs <matthias.fuchs@esd.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:55530 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285Ab0CaS0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 14:26:53 -0400
In-Reply-To: <201003311732.59921.matthias.fuchs@esd.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matthias,

Matthias Fuchs wrote:
> This patch adds support for SJA1000 based PCI CAN interface cards
> from electronic system design gmbh.
> 
> Two changes have been done on the common code:
>  - esd boards must not have the 2nd local interupt enabled (PLX9030/9050)
>  - a new path for PLX9056/PEX8311 chips has been added
> 
> In detail the following additional boards are now supported:
> 
>         CAN-PCI/200 (PCI)
>         CAN-PCI/266 (PCI)
>         CAN-PMC266 (PMC module)
>         CAN-PCIe/2000 (PCI Express)
>         CAN-CPCI/200 (Compact PCI, 3U)
>         CAN-PCI104 (PCI104)
> 
> Signed-off-by: Matthias Fuchs <matthias.fuchs@esd.eu>

Could you also please update the corresponding Kconfig entry. Apart
from that, the patch looks good.

Thanks,

Wolfgang.

>  drivers/net/can/sja1000/plx_pci.c |  110 ++++++++++++++++++++++++++++++++++---
>  1 files changed, 101 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
> index 6b46a63..42602e9 100644
> --- a/drivers/net/can/sja1000/plx_pci.c
> +++ b/drivers/net/can/sja1000/plx_pci.c
> @@ -40,7 +40,10 @@ MODULE_DESCRIPTION("Socket-CAN driver for PLX90xx PCI-bridge cards with "
>  MODULE_SUPPORTED_DEVICE("Adlink PCI-7841/cPCI-7841, "
>  			"Adlink PCI-7841/cPCI-7841 SE, "
>  			"Marathon CAN-bus-PCI, "
> -			"TEWS TECHNOLOGIES TPMC810");
> +			"TEWS TECHNOLOGIES TPMC810, "
> +			"esd CAN-PCI/CPCI/PCI104/200, "
> +			"esd CAN-PCI/PMC/266, "
> +			"esd CAN-PCIe/2000")
>  MODULE_LICENSE("GPL v2");
>  
>  #define PLX_PCI_MAX_CHAN 2
> @@ -53,7 +56,7 @@ struct plx_pci_card {
>  
>  #define PLX_PCI_CAN_CLOCK (16000000 / 2)
>  
> -/* PLX90xx registers */
> +/* PLX9030/9050/9052 registers */
>  #define PLX_INTCSR	0x4c		/* Interrupt Control/Status */
>  #define PLX_CNTRL	0x50		/* User I/O, Direct Slave Response,
>  					 * Serial EEPROM, and Initialization
> @@ -65,6 +68,12 @@ struct plx_pci_card {
>  #define PLX_PCI_INT_EN	(1 << 6)	/* PCI Interrupt Enable */
>  #define PLX_PCI_RESET	(1 << 30)	/* PCI Adapter Software Reset */
>  
> +/* PLX9056 registers */
> +#define PLX9056_INTCSR	0x68		/* Interrupt Control/Status */
> +
> +#define PLX9056_LINTI	(1 << 11)
> +#define PLX9056_PCI_INT_EN (1 << 8)
> +
>  /*
>   * The board configuration is probably following:
>   * RX1 is connected to ground.
> @@ -100,6 +109,13 @@ struct plx_pci_card {
>  #define ADLINK_PCI_VENDOR_ID		0x144A
>  #define ADLINK_PCI_DEVICE_ID		0x7841
>  
> +#define ESD_PCI_SUB_SYS_ID_PCI200	0x0004
> +#define ESD_PCI_SUB_SYS_ID_PCI266	0x0009
> +#define ESD_PCI_SUB_SYS_ID_PMC266	0x000e
> +#define ESD_PCI_SUB_SYS_ID_CPCI200	0x010b
> +#define ESD_PCI_SUB_SYS_ID_PCIE2000	0x0200
> +#define ESD_PCI_SUB_SYS_ID_PCI104200	0x0501
> +
>  #define MARATHON_PCI_DEVICE_ID		0x2715
>  
>  #define TEWS_PCI_VENDOR_ID		0x1498
> @@ -147,6 +163,30 @@ static struct plx_pci_card_info plx_pci_card_info_adlink_se __devinitdata = {
>  	/* based on PLX9052 */
>  };
>  
> +static struct plx_pci_card_info plx_pci_card_info_esd200 __devinitdata = {
> +	"esd CAN-PCI/CPCI/PCI104/200", 2,
> +	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
> +	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x100, 0x80} },
> +	&plx_pci_reset_common
> +	/* based on PLX9030/9050 */
> +};
> +
> +static struct plx_pci_card_info plx_pci_card_info_esd266 __devinitdata = {
> +	"esd CAN-PCI/PMC/266", 2,
> +	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
> +	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x100, 0x80} },
> +	&plx_pci_reset_common
> +	/* based on PLX9056 */
> +};
> +
> +static struct plx_pci_card_info plx_pci_card_info_esd2000 __devinitdata = {
> +	"esd CAN-PCIe/2000", 2,
> +	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
> +	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x100, 0x80} },
> +	&plx_pci_reset_common
> +	/* based on PEX8311 */
> +};
> +
>  static struct plx_pci_card_info plx_pci_card_info_marathon __devinitdata = {
>  	"Marathon CAN-bus-PCI", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
> @@ -179,6 +219,48 @@ static DEFINE_PCI_DEVICE_TABLE(plx_pci_tbl) = {
>  		(kernel_ulong_t)&plx_pci_card_info_adlink_se
>  	},
>  	{
> +		/* esd CAN-PCI/200 */
> +		PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9050,
> +		PCI_VENDOR_ID_ESDGMBH, ESD_PCI_SUB_SYS_ID_PCI200,
> +		0, 0,
> +		(kernel_ulong_t)&plx_pci_card_info_esd200
> +	},
> +	{
> +		/* esd CAN-CPCI/200 */
> +		PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9030,
> +		PCI_VENDOR_ID_ESDGMBH, ESD_PCI_SUB_SYS_ID_CPCI200,
> +		0, 0,
> +		(kernel_ulong_t)&plx_pci_card_info_esd200
> +	},
> +	{
> +		/* esd CAN-PCI104/200 */
> +		PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9030,
> +		PCI_VENDOR_ID_ESDGMBH, ESD_PCI_SUB_SYS_ID_PCI104200,
> +		0, 0,
> +		(kernel_ulong_t)&plx_pci_card_info_esd200
> +	},
> +	{
> +		/* esd CAN-PCI/266 */
> +		PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9056,
> +		PCI_VENDOR_ID_ESDGMBH, ESD_PCI_SUB_SYS_ID_PCI266,
> +		0, 0,
> +		(kernel_ulong_t)&plx_pci_card_info_esd266
> +	},
> +	{
> +		/* esd CAN-PMC/266 */
> +		PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9056,
> +		PCI_VENDOR_ID_ESDGMBH, ESD_PCI_SUB_SYS_ID_PMC266,
> +		0, 0,
> +		(kernel_ulong_t)&plx_pci_card_info_esd266
> +	},
> +	{
> +		/* esd CAN-PCIE/2000 */
> +		PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9056,
> +		PCI_VENDOR_ID_ESDGMBH, ESD_PCI_SUB_SYS_ID_PCIE2000,
> +		0, 0,
> +		(kernel_ulong_t)&plx_pci_card_info_esd2000
> +	},
> +	{
>  		/* Marathon CAN-bus-PCI card */
>  		PCI_VENDOR_ID_PLX, MARATHON_PCI_DEVICE_ID,
>  		PCI_ANY_ID, PCI_ANY_ID,
> @@ -304,10 +386,13 @@ static void plx_pci_del_card(struct pci_dev *pdev)
>  	plx_pci_reset_common(pdev);
>  
>  	/*
> -	 * Disable interrupts from PCI-card (PLX90xx) and disable Local_1,
> -	 * Local_2 interrupts
> +	 * Disable interrupts from PCI-card and disable local
> +	 * interrupts
>  	 */
> -	iowrite32(0x0, card->conf_addr + PLX_INTCSR);
> +	if (pdev->device != PCI_DEVICE_ID_PLX_9056)
> +		iowrite32(0x0, card->conf_addr + PLX_INTCSR);
> +	else
> +		iowrite32(0x0, card->conf_addr + PLX9056_INTCSR);
>  
>  	if (card->conf_addr)
>  		pci_iounmap(pdev, card->conf_addr);
> @@ -437,10 +522,17 @@ static int __devinit plx_pci_add_card(struct pci_dev *pdev,
>  	 * Enable interrupts from PCI-card (PLX90xx) and enable Local_1,
>  	 * Local_2 interrupts from the SJA1000 chips
>  	 */
> -	val = ioread32(card->conf_addr + PLX_INTCSR);
> -	val |= PLX_LINT1_EN | PLX_LINT2_EN | PLX_PCI_INT_EN;
> -	iowrite32(val, card->conf_addr + PLX_INTCSR);
> -
> +	if (pdev->device != PCI_DEVICE_ID_PLX_9056) {
> +		val = ioread32(card->conf_addr + PLX_INTCSR);
> +		if (pdev->subsystem_vendor == PCI_VENDOR_ID_ESDGMBH)
> +			val |= PLX_LINT1_EN | PLX_PCI_INT_EN;
> +		else
> +			val |= PLX_LINT1_EN | PLX_LINT2_EN | PLX_PCI_INT_EN;
> +		iowrite32(val, card->conf_addr + PLX_INTCSR);
> +	} else {
> +		iowrite32(PLX9056_LINTI | PLX9056_PCI_INT_EN,
> +			  card->conf_addr + PLX9056_INTCSR);
> +	}
>  	return 0;
>  
>  failure_cleanup:


