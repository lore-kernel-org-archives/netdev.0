From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.10-rc1 7/15] wireless/orinoco: Update card reset/init
 code and add card-specific data structures
Date: Tue, 26 Oct 2004 15:43:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417EA8D8.3060403@pobox.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098816980.3663.62.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1098816980.3663.62.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> +/* Orinoco PCI specific data */
> +struct orinoco_pci_card {
> +	u32 pci_state[16];	/* PCI suspend/resume state */
> +};

no need with GregKH's latest upstream changes



> -	printk(KERN_NOTICE "Reset done");
>  	timeout = jiffies + (HERMES_PCI_COR_ONT * HZ / 1000);
> -	while(time_before(jiffies, timeout)) {
> -		printk(".");
> +	while(time_before(jiffies, timeout))
>  		mdelay(1);


the loop is non-sensical... at this point use msleep() or actually 
mdelay() for the correct period, rather than looping on mdelay(1)


> -	printk(KERN_NOTICE "Clear Reset");
>  	timeout = jiffies + (HERMES_PCI_COR_OFFT * HZ / 1000);
> -	while(time_before(jiffies, timeout)) {
> -		printk(".");
> +	while(time_before(jiffies, timeout))
>  		mdelay(1);
> -	}
> -	printk(";\n");
> -	//mdelay(HERMES_PCI_COR_OFFT);

ditto


> @@ -199,61 +194,68 @@
>  	u16 *pci_ioaddr = NULL;
>  	unsigned long pci_iolen;
>  	struct orinoco_private *priv = NULL;
> +	struct orinoco_pci_card *card;
>  	struct net_device *dev = NULL;
>  
>  	err = pci_enable_device(pdev);
> -	if (err)
> -		return -EIO;
> +	if (err) {
> +		printk(KERN_ERR PFX "Cannot enable PCI device\n");
> +		return -err;
> +	}

incorrect...  err is already negative.


> @@ -325,6 +327,9 @@
>  	
>  	orinoco_unlock(priv, &flags);
>  
> +	pci_save_state(pdev, card->pci_state);
> +	pci_set_power_state(pdev, 3);
> +
>  	return 0;
>  }
>  
> @@ -332,11 +337,15 @@
>  {
>  	struct net_device *dev = pci_get_drvdata(pdev);
>  	struct orinoco_private *priv = netdev_priv(dev);
> +	struct orinoco_pci_card *card = priv->card;
>  	unsigned long flags;
>  	int err;
>  
>  	printk(KERN_DEBUG "%s: Orinoco-PCI waking up\n", dev->name);
>  
> +	pci_set_power_state(pdev, 0);
> +	pci_restore_state(pdev, card->pci_state);
> +
>  	err = orinoco_reinit_firmware(dev);
>  	if (err) {
>  		printk(KERN_ERR "%s: Error %d re-initializing firmware on orinoco_pci_resume()\n",

These two don't build in the latest 2.6.x kernel.



> --- a/drivers/net/wireless/orinoco_plx.c.7-card-data	2004-10-26 09:52:13.354269904 -0400
> +++ b/drivers/net/wireless/orinoco_plx.c	2004-10-26 10:07:51.854596168 -0400
> @@ -142,146 +142,189 @@
>  #include "hermes.h"
>  #include "orinoco.h"
>  
> -#define COR_OFFSET	(0x3e0/2) /* COR attribute offset of Prism2 PC card */
> +#define COR_OFFSET	(0x3e0)	/* COR attribute offset of Prism2 PC card */
>  #define COR_VALUE	(COR_LEVEL_REQ | COR_FUNC_ENA) /* Enable PC card with interrupt in level trigger */
> +#define COR_RESET     (0x80)	/* reset bit in the COR register */
> +#define PLX_RESET_TIME	(500)	/* milliseconds */
>  
>  #define PLX_INTCSR		0x4c /* Interrupt Control & Status Register */
>  #define PLX_INTCSR_INTEN	(1<<6) /* Interrupt Enable bit */
>  
> -static const u16 cis_magic[] = {
> -	0x0001, 0x0003, 0x0000, 0x0000, 0x00ff, 0x0017, 0x0004, 0x0067
> +static const u8 cis_magic[] = {
> +	0x01, 0x03, 0x00, 0x00, 0xff, 0x17, 0x04, 0x67
>  };
>  
> +/* Orinoco PLX specific data */
> +struct orinoco_plx_card {
> +	u8 *attr_mem;
> +};
> +
> +/*
> + * Do a soft reset of the card using the Configuration Option Register
> + */
> +static int orinoco_plx_cor_reset(struct orinoco_private *priv)
> +{
> +	hermes_t *hw = &priv->hw;
> +	struct orinoco_plx_card *card = priv->card;
> +	u8 *attr_mem = card->attr_mem;
> +	unsigned long timeout;
> +	u16 reg;
> +
> +	attr_mem[COR_OFFSET] = COR_VALUE | COR_RESET;
> +	mdelay(1);
> +
> +	attr_mem[COR_OFFSET] = COR_VALUE;
> +	mdelay(1);
> +
> +	/* Just in case, wait more until the card is no longer busy */
> +	timeout = jiffies + (PLX_RESET_TIME * HZ / 1000);
> +	reg = hermes_read_regn(hw, CMD);
> +	while (time_before(jiffies, timeout) && (reg & HERMES_CMD_BUSY)) {
> +		mdelay(1);
> +		reg = hermes_read_regn(hw, CMD);
> +	}
> +
> +	/* Did we timeout ? */
> +	if (reg & HERMES_CMD_BUSY) {
> +		printk(KERN_ERR PFX "Busy timeout\n");
> +		return -ETIMEDOUT;
> +	}
> +
> +	return 0;
> +}
> +
> +
>  static int orinoco_plx_init_one(struct pci_dev *pdev,
>  				const struct pci_device_id *ent)
>  {
>  	int err = 0;
> -	u16 *attr_mem = NULL;
> -	u32 reg, addr;
> +	u8 *attr_mem = NULL;
> +	u32 csr_reg, plx_addr;
>  	struct orinoco_private *priv = NULL;
> +	struct orinoco_plx_card *card;
>  	unsigned long pccard_ioaddr = 0;
>  	unsigned long pccard_iolen = 0;
>  	struct net_device *dev = NULL;
>  	int i;
>  
>  	err = pci_enable_device(pdev);
> -	if (err)
> -		return -EIO;
> -
> -	/* Resource 2 is mapped to the PCMCIA space */
> -	attr_mem = ioremap(pci_resource_start(pdev, 2), PAGE_SIZE);
> -	if (! attr_mem)
> -		goto fail;
> -
> -	printk(KERN_DEBUG "orinoco_plx: CIS: ");
> -	for (i = 0; i < 16; i++) {
> -		printk("%02X:", (int)attr_mem[i]);
> +	if (err) {
> +		printk(KERN_ERR PFX "Cannot enable PCI device\n");
> +		return -err;

ditto earlier comment, same bug here


> @@ -332,6 +374,8 @@
>  	.id_table	= orinoco_plx_pci_id_table,
>  	.probe		= orinoco_plx_init_one,
>  	.remove		= __devexit_p(orinoco_plx_remove_one),
> +	.suspend	= 0,
> +	.resume		= 0,
>  };

superfluous change


> + * Do a soft reset of the card using the Configuration Option Register
> + */
> +static int orinoco_tmd_cor_reset(struct orinoco_private *priv)
> +{
> +	hermes_t *hw = &priv->hw;
> +	struct orinoco_tmd_card *card = priv->card;
> +	u32 addr = card->tmd_io;
> +	unsigned long timeout;
> +	u16 reg;
> +
> +	outb(COR_VALUE | COR_RESET, addr);
> +	mdelay(1);
> +
> +	outb(COR_VALUE, addr);
> +	mdelay(1);

PCI posting bugs?


> +	/* Just in case, wait more until the card is no longer busy */
> +	timeout = jiffies + (TMD_RESET_TIME * HZ / 1000);
> +	reg = hermes_read_regn(hw, CMD);
> +	while (time_before(jiffies, timeout) && (reg & HERMES_CMD_BUSY)) {
> +		mdelay(1);
> +		reg = hermes_read_regn(hw, CMD);
> +	}

max delay without sleep way too long



>  	err = pci_enable_device(pdev);
> -	if (err)
> -		return -EIO;
> -
> -	printk(KERN_DEBUG PFX "TMD setup\n");
> -	pccard_ioaddr = pci_resource_start(pdev, 2);
> -	pccard_iolen = pci_resource_len(pdev, 2);
> -	if (! request_region(pccard_ioaddr, pccard_iolen, DRIVER_NAME)) {
> -		printk(KERN_ERR PFX "I/O resource at 0x%lx len 0x%lx busy\n",
> -			pccard_ioaddr, pccard_iolen);
> -		pccard_ioaddr = 0;
> -		err = -EBUSY;
> -		goto fail;
> +	if (err) {
> +		printk(KERN_ERR PFX "Cannot enable PCI device\n");
> +		return -err;

same bug yet again



> @@ -200,6 +232,8 @@
>  	.id_table	= orinoco_tmd_pci_id_table,
>  	.probe		= orinoco_tmd_init_one,
>  	.remove		= __devexit_p(orinoco_tmd_remove_one),
> +	.suspend	= 0,
> +	.resume		= 0,

superfluous
