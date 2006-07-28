From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: SMSC LAN911x and LAN921x vendor driver
Date: Fri, 28 Jul 2006 23:38:41 +0200
Message-ID: <20060728213841.GA14235@electric-eye.fr.zoreil.com>
References: <20060714115035.502d8edf@dxpl.pdx.osdl.net> <11540873333102-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35757 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1161317AbWG1VmA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 17:42:00 -0400
To: Steve Glendinning <steve.glendinning@smsc.com>
Content-Disposition: inline
In-Reply-To: <11540873333102-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[...]
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> new file mode 100644
> index 0000000..12bbe67
> --- /dev/null
> +++ b/drivers/net/smsc911x.c
[...]
> +/* Tasklet declarations */
> +static unsigned long rx_tasklet_parameter;
> +static void smsc911x_rx_tasklet(unsigned long data);
> +
> +DECLARE_TASKLET(rx_tasklet, smsc911x_rx_tasklet, 0);
> +MODULE_LICENSE("GPL");
> +
> +/* MAC */
[lots of forward declarations]

Despite Jeff claiming otherwise, I see no added value in forward
declarations. It adds bloat, it pollutes ctags and it is inferior
to real kernel docbook documentation.

[...]
> +/* Linux network device interface */
> +static int smsc911x_open(struct net_device *dev);
> +static int smsc911x_stop(struct net_device *dev);
> +static int smsc911x_hard_start_xmit(struct sk_buff *skb,
> +				    struct net_device *dev);
> +
> +static struct net_device_stats *smsc911x_get_stats(struct net_device *dev);
> +static void smsc911x_set_multicast_list(struct net_device *dev);
> +static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id,
> +				       struct pt_regs *regs);
> +
> +/* Module interface */
> +static int smsc911x_init_module(void);
> +static void smsc911x_cleanup_module(void);
> +
> +/* Driver interface */
> +static int smsc911x_drv_probe(struct platform_device *pdev);
> +static int smsc911x_drv_remove(struct platform_device *pdev);

These one are completely useless.

> +/* Entry point for starting/opening the interface */
> +static int smsc911x_open(struct net_device *dev)
> +{
> +	struct smsc911x_data *pdata;
> +	unsigned int mac_high16;
> +	unsigned int mac_low32;
> +	unsigned int timeout;
> +	unsigned int intcfg;
> +	int result;
> +
> +	/* Set interrupt deassertion to 220uS */
> +	intcfg = 22 << 24;
> +	timeout = 1000;
> +	result = -ENODEV;
> +
> +	pdata = netdev_priv(dev);

It is quite common to set pdata on flight, i.e.:
	struct smsc911x_data *pdata = netdev_priv(dev);

Same thing for 'result'.

> +
> +	/* Initialise smsc911x */
> +
> +	/*
> +	 * dwIntCfg|=INT_CFG_IRQ_POL_;  use this to set IRQ_POL bit
> +	 * dwIntCfg|=INT_CFG_IRQ_TYPE_;  use this to set IRQ_TYPE bit
> +	 */
> +	if (!smsc911x_lan_initialise(pdata, intcfg))
> +		goto done;
> +
> +	SMSC_TRACE("Testing irq handler using IRQ %d", dev->irq);
> +	pdata->request_irq_disable = 0;
> +	pdata->software_irq_signal = 0;
> +	smsc911x_reg_write((smsc911x_reg_read(pdata, INT_EN) |
> +			    INT_EN_SW_INT_EN_), pdata, INT_EN);
> +	do {
> +		udelay(10);
> +		timeout--;
> +	} while (timeout && (!pdata->software_irq_signal));
> +
> +	if (!pdata->software_irq_signal) {
> +		printk("<1>ISR failed signaling test.");

Should be printk(KERN_XYZ, ...
It would be nice to display the device name too.

> +		result = -ENODEV;
> +		goto done;
> +	}
> +	SMSC_TRACE("IRQ handler passed test using IRQ %d", dev->irq);
> +
> +	printk("%s: SMSC911x/921x identified at %#08x, IRQ: %d\n", dev->name,
> +	       pdata->base, dev->irq);

printk(KERN_XYZ, ...

[...]
> +static int smsc911x_stop(struct net_device *dev)
> +{
> +	unsigned long flags;
> +	unsigned long base;
> +	unsigned long idrev;
> +	struct smsc911x_data *pdata;
> +	struct net_device *pnetdev;
> +
> +	pdata = netdev_priv(dev);
> +
> +	pdata->stop_link_poll = 1;
> +	del_timer_sync(&pdata->link_poll_timer);
> +
> +	spin_lock_irqsave(&dev->_xmit_lock, flags);

If this is supposed to protect against hard_start_xmit, it is not needed.

> +	smsc911x_reg_write((smsc911x_reg_read(pdata, INT_CFG) &
> +			    (~INT_CFG_IRQ_EN_)), pdata, INT_CFG);
> +	netif_stop_queue(pdata->dev);

Any reason why 'pdata->dev' would be different from 'dev' ?
pnetdev seems redundant with dev.

> +	spin_unlock_irqrestore(&dev->_xmit_lock, flags);
> +
> +	/* At this point all Rx and Tx activity is stopped */
> +	pdata->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
> +	smsc911x_tx_update_txcounters(pdata);
> +
> +	/* Preserve important fields */
> +	base = pdata->base;
> +	idrev = pdata->idrev;
> +	pnetdev = pdata->dev;
> +
> +	/* Clear all structure */
> +	memset((void *)pdata, 0, sizeof(struct smsc911x_data));

Useless conversion to void *

> +static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
[...]
> +	return 0;

s/0/NETDEV_TX_OK/


[...]
> +/* Entry point for setting addressing modes */
> +static void smsc911x_set_multicast_list(struct net_device *dev)
> +{
> +	struct smsc911x_data *pdata;
> +	unsigned long flags;
> +
> +	pdata = netdev_priv(dev);
> +
> +	spin_lock_irqsave(&pdata->phy_lock, flags);
> +
> +	if (dev->flags & IFF_PROMISC) {
> +		/* Enabling promiscuous mode */
> +		pdata->set_bits_mask = MAC_CR_PRMS_;
> +		pdata->clear_bits_mask = (MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
> +		pdata->hashhi = 0;
> +		pdata->hashlo = 0;
> +		goto prepare;
> +	}

I really enjoy 'goto' too but what is wrong with 'if (...) else if (...)' ?

> +
> +	if (dev->flags & IFF_ALLMULTI) {
> +		/* Enabling all multicast mode */
> +		pdata->set_bits_mask = MAC_CR_MCPAS_;
> +		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_HPFILT_);
> +		pdata->hashhi = 0;
> +		pdata->hashlo = 0;
> +		goto prepare;
> +	}
> +	if (dev->mc_count > 0) {
> +		/* Enabling specific multicast addresses */
> +		unsigned int hash_high = 0;
> +		unsigned int hash_low = 0;
> +		unsigned int count = 0;
> +		struct dev_mc_list *mc_list = dev->mc_list;
> +
> +		pdata->set_bits_mask = MAC_CR_HPFILT_;
> +		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_MCPAS_);
> +
> +		while (mc_list) {
> +			count++;
> +			if ((mc_list->dmi_addrlen) == 6) {
> +				unsigned int mask = 0x01;
> +				unsigned int bitnum;
> +				bitnum = smsc911x_hash(mc_list->dmi_addr);
> +				mask <<= (bitnum & 0x1F);
> +				if (bitnum & 0x20) {
> +					hash_high |= mask;
> +				} else {
> +					hash_low |= mask;
> +				}

No brace around single statement please.

> +			} else {
> +				SMSC_WARNING("dmi_addrlen != 6");
> +			}
> +			mc_list = mc_list->next;
> +		}
> +		if (count != (unsigned int)dev->mc_count)
> +			SMSC_WARNING("mc_count != dev->mc_count");
> +
> +		pdata->hashhi = hash_high;
> +		pdata->hashlo = hash_low;
> +	} else {
> +		/* Enabling local MAC address only */
> +		pdata->set_bits_mask = 0L;
> +		pdata->clear_bits_mask =
> +		    (MAC_CR_PRMS_ | MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
> +		pdata->hashhi = 0UL;
> +		pdata->hashlo = 0UL;
> +	}
> +
> +      prepare:

Kill it :o)

[...]
> +static irqreturn_t
> +smsc911x_irqhandler(int irq, void *dev_id, struct pt_regs *regs)
> +{
> +	unsigned int intcfg;
> +	unsigned int intsts;
> +	int serviced;
> +	unsigned int reserved_bits;
> +	struct smsc911x_data *pdata;
> +
> +	intcfg = 0;
> +	intsts = 0;
> +	serviced = IRQ_NONE;
> +	reserved_bits = 0x00FFCEEE;
> +
> +	pdata = (struct smsc911x_data *)dev_id;

Useless cast from void *.

> +	BUG_ON(!pdata);

Don't worry, you'll know soon enough if it's NULL.

> +
> +	intcfg = smsc911x_reg_read(pdata, INT_CFG);
> +
> +	if (unlikely((intcfg & 0x00001100) != 0x00001100)) {
> +		SMSC_TRACE("Spurious interrupt, intcfg: 0x%08X", intcfg);
> +		goto done;
> +	}
> +
> +	/* this could mean surprise removal */
> +	if (unlikely(intcfg & reserved_bits)) {
> +		SMSC_WARNING("SMSC911x irq handler, reserved bits are high.");
> +		goto done;
> +	}
> +
> +	intsts = smsc911x_reg_read(pdata, INT_STS);
> +	if (unlikely(intsts & INT_STS_SW_INT_)) {
> +		smsc911x_reg_write((smsc911x_reg_read(pdata, INT_EN)
> +				    & (~INT_EN_SW_INT_EN_)), pdata, INT_EN);
> +		smsc911x_reg_write(INT_STS_SW_INT_, pdata, INT_STS);
> +		pdata->software_irq_signal = 1;
> +		serviced = IRQ_HANDLED;
> +		if (pdata->request_irq_disable) {
> +			smsc911x_reg_write((smsc911x_reg_read(pdata, INT_CFG)
> +					    & (~INT_CFG_IRQ_EN_)), pdata,
> +					   INT_CFG);
> +			/* Prevent irqs from being handled */
> +			intsts = 0;
> +		}
> +		if (pdata->multicast_update_pending) {
> +			smsc911x_rx_multicast_update(pdata);
> +		}
> +	}
> +
> +	if (smsc911x_tx_handleirq(pdata, intsts))
> +		serviced = IRQ_HANDLED;
> +
> +	if (likely(smsc911x_rx_handleirq(pdata, intsts)))
> +		serviced = IRQ_HANDLED;
> +
> +	if (unlikely(!serviced))
> +		SMSC_WARNING("Unserviced irq. intcfg: 0x%08X, intsts: "
> +			     "0x%08X, int_en: 0x%08X", intcfg, intsts,
> +			     smsc911x_reg_read(pdata, INT_EN));
> +      done:

Please label at the start of the line.

> +	return serviced;
> +}
> +
> +/* Autodetects and initialises external phy for SMSC9115 and SMSC9117 flavors.
> + * If something goes wrong, returns -ENODEV to revert back to internal phy. */
> +static int smsc911x_phy_initialise_external(struct smsc911x_data *pdata)
> +{
> +	unsigned int address;
> +	unsigned int hwcfg;
> +	unsigned int phyid1;
> +	unsigned int phyid2;
> +
> +	hwcfg = smsc911x_reg_read(pdata, HW_CFG);
> +
> +	/* External phy is requested, supported, and detected */
> +	if (hwcfg & HW_CFG_EXT_PHY_DET_) {
> +
> +		/* Attempt to switch to external phy for auto-detecting
> +		 * its address. Assuming tx and rx are stopped because
> +		 * smsc911x_phy_initialise is called before
> +		 * smsc911x_rx_initialise and tx_initialise.
> +		 */
> +
> +		/* Disable phy clocks to the MAC */
> +		hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
> +		hwcfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
> +		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> +		udelay(10);	/* Enough time for clocks to stop */

I assume that writes are never posted, right ?

[...]
> +#ifdef USE_PHY_WORK_AROUND
> +static int smsc911x_phy_reset(struct smsc911x_data *pdata)
> +{
> +	int result = 0;
> +	unsigned int temp = 0;
> +	unsigned int lcount = 100000;
> +
> +	SMSC_TRACE("Performing PHY BCR Reset");
> +	smsc911x_phy_write(pdata, PHY_BCR, PHY_BCR_RESET_);
> +	do {
> +		udelay(10);
> +		temp = smsc911x_phy_read(pdata, PHY_BCR);
> +		lcount--;
> +	} while ((lcount > 0) && (temp & PHY_BCR_RESET_));
> +
> +	if (temp & PHY_BCR_RESET_) {
> +		SMSC_WARNING("PHY reset failed to complete.");
> +		goto done;
> +	}
> +	/* Extra delay required because the phy may not be completed with
> +	 * its reset when PHY_BCR_RESET_ is cleared. Specs say 256 uS is
> +	 * enough delay but using 500 here to be safe
> +	 */
> +	udelay(500);

If you are in sleepable context, a msleep() may chew less cpu.

[...]
> +/* Fetches a MAC register value. Assumes phy_lock is acquired */
> +static unsigned int
> +smsc911x_mac_read(struct smsc911x_data *pdata, unsigned int offset)
> +{
> +	unsigned int result = 0xFFFFFFFF;
> +	volatile unsigned int temp = 0;
> +
> +	/* Wait until not busy */
> +	if (unlikely
> +	    (smsc911x_reg_read(pdata, MAC_CSR_CMD) & MAC_CSR_CMD_CSR_BUSY_)) {
> +		SMSC_WARNING("smsc911x_mac_read failed, "
> +			     "MAC already busy at entry");
> +		goto done;
> +	}
> +
> +	/* Send the MAC cmd */
> +	smsc911x_reg_write(((offset & 0x000000FF) | MAC_CSR_CMD_CSR_BUSY_
> +			    | MAC_CSR_CMD_R_NOT_W_), pdata, MAC_CSR_CMD);
> +
> +	temp = smsc911x_reg_read(pdata, BYTE_TEST);	/* To flush previous write */

readl() + volatile ?

[...]
> +static void smsc911x_rx_processpackets(struct smsc911x_data *pdata)
> +{
> +	unsigned int rxstat;
> +	unsigned int *bufptr;
> +
> +	pdata->rx_congested = 0;
> +	while ((rxstat = smsc911x_rx_pop_rxstatus(pdata)) != 0) {
> +		unsigned int pktlength = ((rxstat & 0x3FFF0000) >> 16);
> +		smsc911x_rx_counterrors(pdata, rxstat);
> +
> +		if (likely((rxstat & RX_STS_ES_) == 0)) {
> +			struct sk_buff *skb = NULL;
> +			skb = dev_alloc_skb(pktlength + 2);
> +			if (likely(skb)) {
> +				skb->data = skb->head;
> +				skb->tail = skb->head;
> +				/* Align IP on 16B boundary */
> +				skb_reserve(skb, 2);
> +				skb_put(skb, pktlength - 4);
> +
> +				/* Update counters */
> +				pdata->stats.rx_packets++;
> +				pdata->stats.rx_bytes += (pktlength - 4);
> +				bufptr = (unsigned int *)skb->head;
> +				smsc911x_rx_readfifo(pdata, bufptr,
> +						     (pktlength + 2 + 3) >> 2);
> +
> +				smsc911x_rx_handoffskb(pdata, skb);
> +				continue;
> +			} else {
> +				SMSC_WARNING("Unable to allocate sk_buff "
> +					     "for rx packet, in PIO path");
> +				pdata->stats.rx_dropped++;
> +			}
> +		}
> +		/* At this point, the packet is to be read out
> +		 * of the fifo and discarded */
> +		pktlength += 2 + 3;
> +		pktlength >>= 2;
> +		smsc911x_rx_fastforward(pdata, pktlength);
> +	}
> +	pdata->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
> +	smsc911x_reg_write(INT_STS_RSFL_, pdata, INT_STS);

dev->last_rx should be updated somewhere.

[...]
> +/* Receive tasklet */
> +static void smsc911x_rx_tasklet(unsigned long data)
> +{
> +	struct net_device *netdev;
> +	struct smsc911x_data *pdata;
> +
> +	netdev = (struct net_device *)rx_tasklet_parameter;

So this driver will not support more than one adapter ?

[...]
> +/* Receiver irq handler */
> +static int smsc911x_rx_handleirq(struct smsc911x_data *pdata,
> +				 unsigned int intsts)
> +{
> +	int result = 0;
> +
> +	if (unlikely(intsts & INT_STS_RXE_)) {
> +		smsc911x_reg_write(INT_STS_RXE_, pdata, INT_STS);
> +		result = 1;
> +	}
> +	if (!(intsts & INT_STS_RSFL_)) {
> +		return result;
> +	}
> +
> +	result = 1;
> +	smsc911x_reg_write(smsc911x_reg_read(pdata, INT_CFG) &
> +			   (~INT_CFG_IRQ_EN_), pdata, INT_CFG);
> +	tasklet_schedule(&rx_tasklet);

It smells like hand-crafted NAPI. What's wrong with it ?

[...]
> +/* Returns hash bit number for given MAC address
> + * Example:
> + * 01 00 5E 00 00 01 -> returns bit number 31 */
> +static unsigned int smsc911x_hash(char addr[6])
> +{
> +	int i;
> +	int bit;
> +	unsigned int crc;
> +	unsigned int poly;
> +	unsigned int result;
> +	unsigned int data;
> +
> +	crc = 0xFFFFFFFF;
> +	poly = 0xEDB88320;

$ grep -i 0xEDB88320 lib/*
lib/crc32defs.h:#define CRCPOLY_LE 0xedb88320

Any chance to reuse lib/crc32.c::crc32_le() ?

[...]
> +static void smsc911x_rx_multicast_update(struct smsc911x_data *pdata)
> +{
> +	unsigned long flags;
> +	unsigned int timeout;
> +	unsigned int mac_cr;
> +
> +	/* This function is only called for older LAN911x devices 
> +	 * (revA or revB), where MAC_CR, HASHH and HASHL should not
> +	 * be modified during Rx - newer devices immediately update the
> +	 * registers */
> +
> +	local_irq_save(flags);
> +
> +	/* Stop Rx */
> +	mac_cr = smsc911x_mac_read(pdata, MAC_CR);
> +	mac_cr &= ~(MAC_CR_RXEN_);
> +	smsc911x_mac_write(pdata, MAC_CR, mac_cr);
> +
> +	/* Poll until Rx has stopped.  If a frame is being recieved, this will
> +	 * block until the end of this frame.  (this may take a long time at
> +	 * 10Mbps) */
> +	timeout = 2000;
> +	while ((timeout--)
> +	       && (!(smsc911x_reg_read(pdata, INT_STS) & INT_STS_RXSTOP_INT_))) {
> +		udelay(1);


In a completely ideal world the driver would probably race outside of an
irq disabled section until it grabs the napi poll handler, thus preserving
the nice low latency property of the kernel.

Nevermind :o}

[...]
> +static int smsc911x_init(struct net_device *netdev)
> +{
> +	int result;
> +	unsigned long idrev;
> +	unsigned int mac_high16;
> +	unsigned int mac_low32;
> +	struct smsc911x_data *pdata;
> +
> +	idrev = 0;
> +	pdata = 0;
> +	result = -ENODEV;
> +
> +	BUG_ON(!netdev);

Useless...

> +
> +	SMSC_TRACE("Driver Parameters:");
> +	SMSC_TRACE("LAN base: 0x%08lX", netdev->base_addr);

...because you'll see a nice trace here (notwithstanding the fact that
the condition can never be satisfied).

> +	SMSC_TRACE("IRQ: %d", netdev->irq);
> +	SMSC_TRACE("PHY will be autodetected.");
> +	BUG_ON(!netdev_priv(netdev));

Sic.

[...]
> +	ether_setup(netdev);
> +	netdev->open = smsc911x_open;
> +	netdev->stop = smsc911x_stop;
> +	netdev->hard_start_xmit = smsc911x_hard_start_xmit;
> +	netdev->get_stats = smsc911x_get_stats;
> +	netdev->set_multicast_list = smsc911x_set_multicast_list;
> +	netdev->flags |= IFF_MULTICAST;

No ethtool support at all ?

[...]
> +static int smsc911x_drv_probe(struct platform_device *pdev)
> +{
> +	struct net_device *netdev;
> +	struct resource *res;
> +	unsigned int base;
> +	int res_size;
> +	int retval;
> +	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
> +					   "smsc911x-memory");
> +	if (!res)
> +		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!res) {
> +		retval = -ENODEV;
> +		goto out;
> +	}
> +	res_size = res->end - res->start;
> +
> +	if (!request_mem_region(res->start, res_size, SMSC_CHIPNAME)) {
> +		retval = -EBUSY;
> +		goto out;
> +	}
> +
> +	netdev = alloc_etherdev(sizeof(struct smsc911x_data));
> +	if (!netdev) {
> +		printk("%s: Could not allocate device.\n", SMSC_CHIPNAME);
> +		retval = -ENOMEM;
> +		goto out_release_io;
> +	}
> +	SET_MODULE_OWNER(netdev);
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +
> +	/* Global pointer to netdev, used by tasklets */
> +	rx_tasklet_parameter = (unsigned long)netdev;
> +	netdev->irq = platform_get_irq(pdev, 0);
> +	netdev->base_addr = (unsigned int)ioremap_nocache(res->start, res_size);

Converting a nice void __iomem * variable to an unsigned int from the
start is moderately nice. What about storing it in pdata like in any
modern driver ? It would help the incoming jihad for base_addr removal.

> +	base = netdev->base_addr;
> +	if (netdev->base_addr == 0) {
> +		SMSC_WARNING("Error smsc911x base address invalid");
> +		retval = -ENOMEM;
> +		goto out_free_netdev;
> +	}
> +
> +	if ((retval = smsc911x_init(netdev)) < 0)
> +		goto out_unmap_io;
> +
> +	if (request_irq(netdev->irq, smsc911x_irqhandler,

	retval = request_irq(...)
	if (retval < 0) {
		...

As a general note, the driver could surely propagate more return values
instead of relying on local set/test against 0/1.

[...]
> diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
> new file mode 100644
> index 0000000..175f6cb
> --- /dev/null
> +++ b/drivers/net/smsc911x.h
[...]
> +/*
> + * Phy register offsets and bit definitions
> + */
> +#define LAN9118_PHY_ID					0x00C0001C
> +
> +#define PHY_BCR						0

Duplicates include/linux/mii.h::MII_BMCR

> +#define PHY_BCR_RESET_					0x8000
> +#define PHY_BCR_SPEED_SELECT_				0x2000
> +#define PHY_BCR_AUTO_NEG_ENABLE_			0x1000
> +#define PHY_BCR_RESTART_AUTO_NEG_			0x0200
> +#define PHY_BCR_DUPLEX_MODE_				0x0100
> +
> +#define PHY_BSR						1

Duplicates include/linux/mii.h::MII_BMSR

etc.

-- 
Ueimor
