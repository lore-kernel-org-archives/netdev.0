From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 7/7] [PATCH 7/8] can: SJA1000 driver for Kvaser PCI
 cards
Date: Fri, 15 May 2009 10:54:16 +0200
Message-ID: <4A0D2DB8.5010606@grandegger.com>
References: <20090512092757.048938233@denx.de>	<20090512092758.213114373@denx.de> <20090513162014.1f5c1bb1@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Per Dalen <per.dalen@cnw.se>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:58616 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760642AbZEOIyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 04:54:21 -0400
In-Reply-To: <20090513162014.1f5c1bb1@bike.lwn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Corbet wrote:
> On Tue, 12 May 2009 11:28:04 +0200
> Wolfgang Grandegger <wg@grandegger.com> wrote:
> 
>> The patch adds support for the PCI cards: PCIcan and PCIcanx
>> (1, 2 or 4 channel) from Kvaser (http://www.kvaser.com).
> 
>> +static void kvaser_pci_disable_irq(struct net_device *dev)
>> +{
>> +	struct sja1000_priv *priv = netdev_priv(dev);
>> +	struct kvaser_pci *board = priv->priv;
>> +	u32 tmp;
> 
> I've seen certain reviewers getting grumpy about variables called "tmp"
> recently.  

No problem. I'm going to change the name to something more reasonable.

>> +	/* Disable interrupts from card */
>> +	tmp = ioread32(board->conf_addr + S5920_INTCSR);
>> +	tmp &= ~INTCSR_ADDON_INTENABLE_M;
>> +	iowrite32(tmp, board->conf_addr + S5920_INTCSR);
>> +}
> 
> [...]
> 
>> +static int number_of_sja1000_chip(void __iomem *base_addr)
>> +{
>> +	u8 status;
>> +	int i;
>> +
>> +	for (i = 0; i < MAX_NO_OF_CHANNELS; i++) {
>> +		/* reset chip */
>> +		iowrite8(MOD_RM, base_addr +
>> +			 (i * KVASER_PCI_PORT_BYTES) + REG_MOD);
>> +		status = ioread8(base_addr +
>> +				 (i * KVASER_PCI_PORT_BYTES) + REG_MOD);
>> +		udelay(10);
>> +		/* check reset bit */
>> +		if (!(status & MOD_RM))
>> +			break;
> 
> Why would you delay before checking status?  It ain't gonna change.

Right.

>> +	}
>> +
>> +	return i;
>> +}
>> +
>> +static void kvaser_pci_del_chan(struct net_device *dev)
>> +{
>> +	struct sja1000_priv *priv;
>> +	struct kvaser_pci *board;
>> +	int i;
>> +
>> +	if (!dev)
>> +		return;
>> +	priv = netdev_priv(dev);
>> +	if (!priv)
>> +		return;
> 
> Can this happen?

No, it's a bug if it happens.

>> +	board = priv->priv;
>> +	if (!board)
>> +		return;
>> +
>> +	dev_info(&board->pci_dev->dev, "Removing device %s\n",
>> +		 dev->name);
>> +
>> +	for (i = 0; i < board->no_channels - 1; i++) {
>> +		if (board->slave_dev[i]) {
>> +			dev_info(&board->pci_dev->dev, "Removing device %s\n",
>> +				 board->slave_dev[i]->name);
>> +			unregister_sja1000dev(board->slave_dev[i]);
>> +			free_sja1000dev(board->slave_dev[i]);
>> +		}
>> +	}
>> +	unregister_sja1000dev(dev);
>> +
>> +	/* Disable PCI interrupts */
>> +	kvaser_pci_disable_irq(dev);
> 
> It seems to me like you might want to disable interrupts *before* tearing
> down all that structure?  What happens if it interrupts after the sja1000
> layer has forgotten about it?

Right.

>> +	pci_iounmap(board->pci_dev, (void __iomem *)dev->base_addr);
>> +	pci_iounmap(board->pci_dev, board->conf_addr);
>> +	pci_iounmap(board->pci_dev, board->res_addr);
>> +
>> +	free_sja1000dev(dev);
>> +}
>> +
>> +static int kvaser_pci_add_chan(struct pci_dev *pdev, int channel,
>> +			       struct net_device **master_dev,
>> +			       void __iomem *conf_addr,
>> +			       void __iomem *res_addr,
>> +			       unsigned long base_addr)
>> +{
>> +	struct net_device *dev;
>> +	struct sja1000_priv *priv;
>> +	struct kvaser_pci *board;
>> +	int err, init_step;
>> +
>> +	dev = alloc_sja1000dev(sizeof(struct kvaser_pci));
>> +	if (dev == NULL)
>> +		return -ENOMEM;
>> +
>> +	priv = netdev_priv(dev);
> 
> Here you don't have the !priv check.
> 
>> +	board = priv->priv;
>> +
>> +	board->pci_dev = pdev;
>> +	board->channel = channel;
>> +
>> +	/*S5920*/
>> +	board->conf_addr = conf_addr;
>> +
>> +	/*XILINX board wide address*/
>> +	board->res_addr = res_addr;
>> +
>> +	if (channel == 0) {
>> +		board->xilinx_ver =
>> +			ioread8(board->res_addr + XILINX_VERINT) >> 4;
>> +		init_step = 2;
>> +
>> +		/* Assert PTADR# - we're in passive mode so the other bits are
>> +		   not important */
>> +		iowrite32(0x80808080UL, board->conf_addr + S5920_PTCR);
>> +
>> +		/* Disable interrupts from card */
>> +		kvaser_pci_disable_irq(dev);
>> +		/* Enable interrupts from card */
>> +		kvaser_pci_enable_irq(dev);
> 
> I'm sure there's a perfectly good reason for the disable/enable dance.
> Presumably the hardware needs it or it misbehaves?  Worth commenting.

Hm, I think the hardware does not need it. I will check with original other.

>> +	} else {
>> +		struct sja1000_priv *master_priv = netdev_priv(*master_dev);
>> +		struct kvaser_pci *master_board = master_priv->priv;
>> +		master_board->slave_dev[channel - 1] = dev;
>> +		master_board->no_channels = channel + 1;
>> +		board->xilinx_ver = master_board->xilinx_ver;
>> +	}
>> +
>> +	dev->base_addr = base_addr + channel * KVASER_PCI_PORT_BYTES;
>> +
>> +	priv->read_reg = kvaser_pci_read_reg;
>> +	priv->write_reg = kvaser_pci_write_reg;
>> +
>> +	priv->can.clock.freq = KVASER_PCI_CAN_CLOCK;
>> +
>> +	priv->ocr = KVASER_PCI_OCR;
>> +	priv->cdr = KVASER_PCI_CDR;
>> +
>> +	/* Register and setup interrupt handling */
>> +	dev->irq = pdev->irq;
>> +	init_step = 4;
>> +
>> +	dev_info(&pdev->dev, "base_addr=%#lx conf_addr=%p irq=%d\n",
>> +		 dev->base_addr, board->conf_addr, dev->irq);
>> +
>> +	SET_NETDEV_DEV(dev, &pdev->dev);
>> +
>> +	/* Register SJA1000 device */
>> +	err = register_sja1000dev(dev);
>> +	if (err) {
>> +		dev_err(&pdev->dev, "Registering device failed (err=%d)\n",
>> +			err);
>> +		goto failure;
>> +	}
>> +
>> +	if (channel == 0)
>> +		*master_dev = dev;
>> +
>> +	return 0;
>> +
>> +failure:
>> +	kvaser_pci_del_chan(dev);
>> +	return err;
>> +}
>> +
>> +static int __devinit kvaser_pci_init_one(struct pci_dev *pdev,
>> +					 const struct pci_device_id *ent)
>> +{
>> +	int err;
>> +	struct net_device *master_dev = NULL;
>> +	struct sja1000_priv *priv;
>> +	struct kvaser_pci *board;
>> +	int no_channels;
>> +	void __iomem *base_addr = NULL;
>> +	void __iomem *conf_addr = NULL;
>> +	void __iomem *res_addr = NULL;
>> +	int i;
>> +
>> +	dev_info(&pdev->dev, "initializing device %04x:%04x\n",
>> +		 pdev->vendor, pdev->device);
>> +
>> +	err = pci_enable_device(pdev);
>> +	if (err)
>> +		goto failure;
>> +
>> +	err = pci_request_regions(pdev, DRV_NAME);
>> +	if (err)
>> +		goto failure_release_pci;
>> +
>> +	/*S5920*/
>> +	conf_addr = pci_iomap(pdev, 0, PCI_CONFIG_PORT_SIZE);
>> +	if (conf_addr == NULL) {
>> +		err = -ENODEV;
>> +		goto failure_iounmap;
> 
> Why go there?  You know there's nothing to unmap.

OK.

I will resend a revised patch a.s.a.p.

Thanks,

Wolfgang.



