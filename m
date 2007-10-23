From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] wan: new driver retina
Date: Tue, 23 Oct 2007 02:41:58 +0200
Message-ID: <m3640yu0fd.fsf@maximus.localdomain>
References: <720714.25776.qm@web52011.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:33919 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbXJWAmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 20:42:01 -0400
In-Reply-To: <720714.25776.qm@web52011.mail.re2.yahoo.com> (Matti Linnanvuori's message of "Mon, 22 Oct 2007 04:14:57 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A quick look only:

Matti Linnanvuori <mattilinnanvuori@yahoo.com> writes:

> +++ linux-2.6.24/drivers/net/wan/retina.c

> +	CHANGES
> +	-------
> +
> +	v1.0.0 (JK) - May 27, 2003:
> +	* Original driver.
> +
> +	v1.1.0 (JK) - June, 2003:
> +    * final Flexibilis driver
> +
> +	v1.2.0: NO_ARP option back again
> +
> +    v1.2.1: (JT) - Aug 21, 2003:
> +	* Added support for Retina C5400 card including PROC stuff.
> +
> +	v1.2.2: (Petri Ahonen) - Sep 19, 2003:

And so on - I'm not sure such logs belong here.

> +#define DRV_NAME	"retina"
> +#define DRV_VERSION	"1.2.5"
> +#define DRV_RELDATE	"November 14, 2003"

Hmm...

> +/* obsolete
> +  see retina_noarp_with_ptp
> +define FEPCI_NO_ARP */

If it's obsolete (or rather unused), just drop it.

> +#undef inb
> +#undef inw
> +#undef inl
> +#undef outb
> +#undef outw
> +#undef outl
> +#define inb nonexistent		/* force using only 32bit access */
> +#define inw nonexistent		/* force using only 32bit access */
> +#define inl(x) le32_to_cpu(readl(x))
> +#define outb nonexistent	/* force using only 32bit access */
> +#define outw nonexistent	/* force using only 32bit access */
> +#define outl(value, address) writel(cpu_to_le32(value), address)

Any code like that is write-only, why don't just use readl()/
writel() in the actual code?

Are you sure about this cpu_to_le32? readl()/writel() already
preserve the value.

> +#define VMA_OFFSET(vma)  ((vma)->vm_pgoff << PAGE_SHIFT)

Not sure about such things in a driver.

> +enum pci_id_flags_bits {
> +	/* Set PCI command register bits before calling probe */
> +	PCI_USES_IO = 1, PCI_USES_MEM = 2, PCI_USES_MASTER = 4,
> +	/* Read and map the single following PCI BAR */
> +	PCI_ADDR0 = 0 << 4, PCI_ADDR1 = 1 << 4, PCI_ADDR2 =
> +	    2 << 4, PCI_ADDR3 = 3 << 4,
> +	PCI_ADDR_64BITS = 0x100, PCI_NO_ACPI_WAKE =
> +	    0x200, PCI_NO_MIN_LATENCY = 0x400,
> +	PCI_UNUSED_IRQ = 0x800,
> +};

We already have such things in PCI headers, don't we?

> +/* Linux 2.4 appears to drop POINTOPOINT,BROADCAST and NOARP flags

Linux 2.4?

> +/* proc filesystem functions introduced: */

I'm not sure we're adding new /proc files.
Perhaps you should investigate sysfs and friends?

> +	case FEPCI_IOCTL_R_SHARED_MEM:
> +		DBG_PRINT(" %s: ioctl read shared mem commanded.\n",
> +			  fepci_NAME);
> +		fepci_copy_to_user(arg, ioaddr + FEPCI_SHARED_MEM_OFFSETT,
> +				   _IOC_SIZE(cmd), 0);
> +		break;
> +	case FEPCI_IOCTL_W_SHARED_MEM:
> +		DBG_PRINT(" %s: ioctl write shared mem commanded.\n",
> +			  fepci_NAME);
> +		fepci_copy_from_user(ioaddr + FEPCI_SHARED_MEM_OFFSETT,
> +				     arg, _IOC_SIZE(cmd), 0);
> +		break;
> +	case FEPCI_IOCTL_G_IDENTIFICATION:
> +		DBG_PRINT(" %s: IOCTL_G_IDENTIFICATION commanded.\n",
> +			  fepci_NAME);
> +		fepci_copy_to_user(arg,
> +				   ioaddr + FEPCI_IDENTIFICATION_OFFSETT,
> +				   _IOC_SIZE(cmd), 1);
> +		break;
> +	case FEPCI_IOCTL_G_FEATURES:
> +		DBG_PRINT(" %s: IOCTL_G_FEATURES commanded.\n", fepci_NAME);
> +		fepci_copy_to_user(arg, ioaddr + FEPCI_FEATURES_OFFSETT,
> +				   _IOC_SIZE(cmd), 1);
> +		break;

Are you sure these ioctls are a good idea? Perhaps sysfs attributes
would be much better?

> +			if (length == 0) {
> +				fp->rx_packets_of_size_0_stream++;
> +			} else if (length == 1) {
> +				fp->rx_packets_of_size_1_stream++;
> +			} else if (length == 2) {
> +				fp->rx_packets_of_size_2_stream++;
> +			} else if (length == 3) {
> +				fp->rx_packets_of_size_3_stream++;
> +			} else if (length < 8) {
> +				fp->rx_packets_of_size_4_7_stream++;
> +			} else if (length < 16) {
...

I think style details are really a personal thing but this would
look much better without the braces.

> +		}
> +		temp_tx = (temp_tx + 1) & (TX_RING_SIZE - 1);
> +		temp_tx_unit = (temp_tx_unit + 1);
> +		temp_tx_unit *= temp_tx_unit < fp->units;
> +	}
> +
> +	return IRQ_HANDLED;

No unhandled IRQ protection anymore?

> +#ifdef FEPCI_POINT_TO_POINT
> +static int is_ptp_interface(struct net_device *dev)
> +{
> +	char **p_ptp_if_name = retina_ptp_interfaces;
> +	unsigned int i = interfaces;
> +	while (i > 0 && *p_ptp_if_name != NULL) {
> +		if (!strncmp(dev->name, *p_ptp_if_name, sizeof(dev->name))) {
> +			return 1;
> +		} else {
> +		}
> +		p_ptp_if_name++;
> +		i--;
> +	}
> +	return 0;
> +}

A bit weird, isn't it?

> +static int __devinit fepci_init_one(struct pci_dev *pdev,
> +				    const struct pci_device_id *ent)
> +{
> +	struct net_device *dev = NULL;
> +	struct fepci_ch_private *fp = NULL;
> +	int chip_idx = ent->driver_data;
> +	int drv_flags = pci_id_tbl[chip_idx].drv_flags;
> +	int i = pci_enable_device(pdev);
> +	u32 j;
> +	resource_size_t real_ioaddr;
> +	void *ioaddr;
> +	unsigned position;
> +
> +	if (i) {
> +		printk(KERN_WARNING "%s: pci_enable_device returned %x.\n",
> +		       fepci_NAME, i);
> +		return i;
> +	}

Didn't spot that pci_enable_device() at first. I think we shouldn't
put state-changing functions in variable declarations, especially
when there are many variables.

> +	goto err_2;
> +      FOUND:

The labels can be hard to spot, too.

> +		/* dev->name[3]= j+0x30;    channel number -> ascii */
> +		/* minor number -> ascii */
> +		dev->name[4] = ((fp->minor * CHANNELS + j) % 10) + 0x30;
> +		/* minor number -> ascii */
> +		dev->name[3] = ((fp->minor * CHANNELS + j) / 10) + 0x30;

That 0x30 could be written as plain '0'.

> +		/* HW_ADDR: 00:rnd:rnd:rnd:rnd:05 */
> +		dev->dev_addr[0] = 0;
> +		get_random_bytes(&(dev->dev_addr[1]), 4);
> +		dev->dev_addr[5] = 5;

I think we already have a function for this.

> +
> +static int fepci_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	const unsigned cur_tx = fp->cur_tx;
> +
> +	fp->tx_skbuffs_in++;
> +
> +	{
> +		u32 tx_length = skb->len;
> +		u32 bus_address;
> +		struct sk_buff *old;
> +		if (unlikely(tx_length < ETH_ZLEN)) {
> +			struct sk_buff *bigger =

Why don't you just move the variables to the beginning of this function?
The extra indentation isn't good for readability.

> +	if (intr_status & IntrFrameTransmitted) {
> +		fp->tx_interrupts_since_last_timer++;
> +		if (netif_tx_trylock(dev)) {
> +			unsigned i = TX_RING_SIZE - 1;
> +			do {
> +				u32 desc_b;
> +				if ((fp->tx_skbuff[i] != NULL)
> +				    &&
> +				    (((desc_b =
> +				       inl(&fp->tx_desc[i].
> +					   desc_b)) & transfer_not_done) ==
> +				     0)) {
> +					/* has been sent */
> +					pci_unmap_single(fp->
> +							 this_card_priv->
> +							 pci_dev,
> +							 inl(&fp->
> +							     tx_desc[i].
> +							     desc_a),
> +							 desc_b &
> +							 frame_length,
> +							 PCI_DMA_TODEVICE);

The above looks like a hardcopy printout with missing CRs (carriage
returns) :-)
Why not split it?

> +			    [line]++;
> +			/* small packet counters */
> +			if (length == 0)
> +				fp->rx_packets_of_size_0++;
> +			else if (length == 1)
> +				fp->rx_packets_of_size_1++;
> +			else if (length == 2)
> +				fp->rx_packets_of_size_2++;
> +			else if (length == 3)
> +				fp->rx_packets_of_size_3++;
> +			else if (length < 8)
> +				fp->rx_packets_of_size_4_7++;
> +			else if (length < 16)
> +				fp->rx_packets_of_size_8_15++;
> +			else if (length < 32)
> +				fp->rx_packets_of_size_16_31++;

Is there a specific reason to have such detailed counters?

> +int get_line_data_rate_value(unsigned char line_rate)
> +{
> +	switch (line_rate) {
> +	case 0x00:
> +		return 0;
> +	case 0x01:
> +		return 1;
> +	case 0x05:
> +		return 8;
> +	case 0x06:
> +		return 10;
> +	case 0x14:
> +		return 256;
> +	case 0x15:
> +		return 300;
> +	case 0x20:
> +		return 1;
> +	case 0x28:
> +		return 8;
> +	case 0x29:
> +		return 10;
> +	case 0x30:
> +		return 32;
> +	case 0x34:
> +		return 56;
> +	case 0x36:
> +		return 64;
> +	case 0x60:
> +		return 1;
> +	case 0xa0:
> +		return 1;
> +	default:
> +		return -1;
> +	}
> +}
> +
> +char get_line_data_rate_unit(unsigned char line_rate)
> +{
> +	switch (line_rate) {
> +	case 0x00:
> +		return 0;
> +	case 0x01:
> +		return 0;
> +	case 0x05:
> +		return 0;
> +	case 0x06:
> +		return 0;
> +	case 0x14:
> +		return 0;
> +	case 0x15:
> +		return 0;
> +	case 0x20:
> +		return 'k';
> +	case 0x28:
> +		return 'k';
> +	case 0x29:
> +		return 'k';
> +	case 0x30:
> +		return 'k';
> +	case 0x34:
> +		return 'k';
> +	case 0x36:
> +		return 'k';
> +	case 0x60:
> +		return 'M';
> +	case 0xa0:
> +		return 'G';
> +	default:
> +		return 0;
> +	}
> +}

Are you sure you really want this?

> +int print_line_type(unsigned char type, char *buf, int pos)
> +{
> +	DBG_PRINT("print_line_type %c\n", type);
> +	switch (type) {
> +	case 0:
> +		pos += sprintf(buf + pos, "NONE");
> +		break;
> +	case 1:
> +		pos += sprintf(buf + pos, "DCombus management bus");
> +		break;
> +	case 2:
> +		pos += sprintf(buf + pos, "V.24");
> +		break;
> +	case 3:
> +		pos += sprintf(buf + pos, "X.21");
> +		break;
> +	case 4:
> +		pos += sprintf(buf + pos, "V.35");
> +		break;
> +	case 5:
> +		pos += sprintf(buf + pos, "V.11");
> +		break;
> +	case 6:
> +		pos += sprintf(buf + pos, "IDSL (ISDN Basic Rate");
> +		break;
> +	case 7:
> +		pos += sprintf(buf + pos, "E1 nonframed/framed");
> +		break;
> +	case 8:
> +		pos += sprintf(buf + pos, "E2 nonframed/framed");
> +		break;
> +	case 9:

A table would be more readable I think.

> +++ linux-2.6.24/drivers/net/wan/retina.h
> @@ -0,0 +1,164 @@

Short header file included by single .c - is it worth it?


Wow, really long.
-- 
Krzysztof Halasa
