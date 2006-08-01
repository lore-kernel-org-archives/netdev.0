From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Tue, 1 Aug 2006 23:40:55 +0200
Message-ID: <20060801214055.GA27595@electric-eye.fr.zoreil.com>
References: <20060728213841.GA14235@electric-eye.fr.zoreil.com> <11544451353553-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36737 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751042AbWHAVmw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:42:52 -0400
To: Steve Glendinning <steve.glendinning@smsc.com>
Content-Disposition: inline
In-Reply-To: <11544451353553-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[...]
> /* Writes a packet to the TX_DATA_FIFO */
> static inline void
> smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
> 		      unsigned int wordcount)
> {
> 	while (wordcount--) {
> 		smsc911x_reg_write(*buf++, pdata, TX_DATA_FIFO);
> 	}

Curly braces are not needed around single line blocks.

[...]
> /* waits for MAC not busy, with timeout.  Assumes MacPhyAccessLock has
>  * already been acquired */
> static int smsc911x_mac_notbusy(struct smsc911x_data *pdata)
> {
> 	int i;
> 
> 	for (i = 0; i < 40; i++) {
> 		if ((smsc911x_reg_read(pdata, MAC_CSR_CMD)
> 		     & MAC_CSR_CMD_CSR_BUSY_) == 0) {
> 			return 1;
> 		}
> 	}
> 	SMSC_WARNING("Timed out waiting for MAC not BUSY. "
> 		     "MAC_CSR_CMD: 0x%08X", smsc911x_reg_read(pdata,
> 							      MAC_CSR_CMD));
> 	return 0;

	u32 val;

 	for (i = 0; i < 40; i++) {
 		val = smsc911x_reg_read(pdata, MAC_CSR_CMD);
		if (!(val & MAC_CSR_CMD_CSR_BUSY_))
 			return 1;
 	}
 	SMSC_WARNING("Timed out waiting for MAC not BUSY. "
 		     "MAC_CSR_CMD: 0x%08X", val);

-> no painful line-breaking (s/val/{reg/cmd}/ at will).

> }
> 
> /* Fetches a MAC register value. Assumes phy_lock is acquired */
> static unsigned int
> smsc911x_mac_read(struct smsc911x_data *pdata, unsigned int offset)
> {
> 	unsigned int result = 0xFFFFFFFF;
> 	unsigned int temp;
> 
> 	/* Wait until not busy */
> 	if (unlikely
> 	    (smsc911x_reg_read(pdata, MAC_CSR_CMD) & MAC_CSR_CMD_CSR_BUSY_)) {
> 		SMSC_WARNING("smsc911x_mac_read failed, "
> 			     "MAC already busy at entry");
> 		return result;
> 	}
> 
> 	/* Send the MAC cmd */
> 	smsc911x_reg_write(((offset & 0x000000FF) | MAC_CSR_CMD_CSR_BUSY_
> 			    | MAC_CSR_CMD_R_NOT_W_), pdata, MAC_CSR_CMD);
> 
> 	/* Workaround for hardware read-after-write restriction */
> 	temp = smsc911x_reg_read(pdata, BYTE_TEST);
> 
> 	/* Wait for the read to happen */
> 	if (unlikely(!smsc911x_mac_notbusy(pdata)))

Double negation (at least :o) ).

[...]
> /* Gets a phy register, phy_lock must be acquired before calling */
> static unsigned int
> smsc911x_phy_read(struct smsc911x_data *pdata, unsigned int index)
> {
> 	unsigned int addr;
> 	unsigned int result = 0xFFFF;
> 	int i;
> 
> 	/* Confirm MII not busy */
> 	if (unlikely
> 	    ((smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_) != 0)) {
> 		SMSC_WARNING("MII is busy in smsc911x_phy_read???");
> 		return 0;
> 	}
> 
> 	/* Set the address, index & direction (read from PHY) */
> 	addr = (((pdata->phy_address) & 0x1F) << 11)
> 	    | ((index & 0x1F) << 6);
> 	smsc911x_mac_write(pdata, MII_ACC, addr);
> 
> 	/* Wait for read to complete w/ timeout */
> 	for (i = 0; i < 100; i++) {
> 		/* See if MII is finished yet */
> 		if ((smsc911x_mac_read(pdata, MII_ACC)
> 		     & MII_ACC_MII_BUSY_) == 0) {
> 			result = smsc911x_mac_read(pdata, MII_DATA);
> 			return result;
> 		}

 		if (!(smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_))
 			return smsc911x_mac_read(pdata, MII_DATA);

> 	}
> 	SMSC_WARNING("Timed out waiting for MII write to finish");
> 
> 	return result;

I'd go with return 0xffff; here and remove 'result' altogether.

> }
> 
> /* Sets a phy register, phy_lock must be acquired before calling */
> static void smsc911x_phy_write(struct smsc911x_data *pdata,
> 			       unsigned int index, unsigned int val)
> {
> 	unsigned int addr;
> 	int i;
> 
> 	/* Confirm MII not busy */
> 	if (unlikely
> 	    ((smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_) != 0)) {

Factor through a smsc911x_mac_busy(pdata) helper ?

[...]
> static int smsc911x_phy_initialise_external(struct smsc911x_data *pdata)
> {
> 	unsigned int address;
> 	unsigned int hwcfg;
> 	unsigned int phyid1;
> 	unsigned int phyid2;
> 
> 	hwcfg = smsc911x_reg_read(pdata, HW_CFG);
> 
> 	/* External phy is requested, supported, and detected */
> 	if (hwcfg & HW_CFG_EXT_PHY_DET_) {
> 
> 		/* Attempt to switch to external phy for auto-detecting
> 		 * its address. Assuming tx and rx are stopped because
> 		 * smsc911x_phy_initialise is called before
> 		 * smsc911x_rx_initialise and tx_initialise.
> 		 */
> 
> 		/* Disable phy clocks to the MAC */
> 		hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
> 		hwcfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
> 		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> 		udelay(10);	/* Enough time for clocks to stop */
> 
> 		/* Switch to external phy */
> 		hwcfg |= HW_CFG_EXT_PHY_EN_;
> 		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> 
> 		/* Enable phy clocks to the MAC */
> 		hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
> 		hwcfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
> 		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> 		udelay(10);	/* Enough time for clocks to restart */

(back to my original question that I should have reworded in a different
thread)

Does the platform guarantees that the register write has actually reached
the real register when the udelay is issued ?

> 
> 		hwcfg |= HW_CFG_SMI_SEL_;
> 		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> 
> 		/* Auto-detect PHY */
> 		for (address = 0; address <= 31; address++) {
> 			pdata->phy_address = address;
> 			phyid1 = smsc911x_phy_read(pdata, MII_PHYSID1);
> 			phyid2 = smsc911x_phy_read(pdata, MII_PHYSID2);
> 			if ((phyid1 != 0xFFFFU) || (phyid2 != 0xFFFFU)) {
> 				SMSC_TRACE("Detected PHY at address = "
> 					   "0x%02X = %d", address, address);
> 				break;
> 			}
> 		}
> 
> 		if ((phyid1 == 0xFFFFU) && (phyid2 == 0xFFFFU)) {
> 			SMSC_WARNING("External PHY is not accessable, "
> 				     "using internal PHY instead");
> 			/* Revert back to interal phy settings. */

s/interal/internal/

[...]
> static int smsc911x_phy_reset(struct smsc911x_data *pdata)
> {
> 	unsigned int temp;
> 	unsigned int lcount = 100000;
> 
> 	SMSC_TRACE("Performing PHY BCR Reset");
> 	smsc911x_phy_write(pdata, MII_BMCR, BMCR_RESET);
> 	do {
> 		udelay(10);
> 		temp = smsc911x_phy_read(pdata, MII_BMCR);
> 		lcount--;
> 	} while ((lcount > 0) && (temp & BMCR_RESET));
> 
> 	if (temp & BMCR_RESET) {
> 		SMSC_WARNING("PHY reset failed to complete.");
> 		return 0;
> 	}
> 	/* Extra delay required because the phy may not be completed with
> 	 * its reset when BMCR_RESET is cleared. Specs say 256 uS is
> 	 * enough delay but using 500 here to be safe
> 	 */
> 	udelay(500);

It would be nice to turn the udelay() into msleep() but this code is issued
from at least one spnlock-protected section.

[...]
> #ifdef USE_PHY_WORK_AROUND
> static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
> {
> 	unsigned int tries = 0;
> 	unsigned int lcount = 0;
> 	u32 wrsz;
> 	u32 rdsz;
> 	u32 bufp;
> 
> 	for (tries = 0; tries < 10; tries++) {

Wrong visibility whence an useless initialization of 'lcount'.

[...]
> /* Update link mode if any thing has changed */
> static void smsc911x_phy_update_linkmode(struct net_device *dev)
> {
> 	struct smsc911x_data *pdata = netdev_priv(dev);
> 	unsigned int old_link_speed = pdata->link_speed;
> 	unsigned int temp;
> 	unsigned long flags;
> 
> 	spin_lock_irqsave(&pdata->phy_lock, flags);
> 	smsc911x_phy_getlinkmode(pdata);
> 
> 	if (old_link_speed != pdata->link_speed) {
> 		if (pdata->link_speed != LINK_OFF) {
> 			unsigned int phy_reg = 0;
> 			switch (pdata->link_speed) {
> 			case LINK_SPEED_10HD:
> 				SMSC_TRACE("Link is now UP at 10Mbps HD");
> 				break;
> 			case LINK_SPEED_10FD:
> 				SMSC_TRACE("Link is now UP at 10Mbps FD");
> 				break;
> 			case LINK_SPEED_100HD:
> 				SMSC_TRACE("Link is now UP at 100Mbps HD");
> 				break;
> 			case LINK_SPEED_100FD:
> 				SMSC_TRACE("Link is now UP at 100Mbps FD");
> 				break;
> 			default:
> 				SMSC_WARNING("Link is now UP at unknown link "
> 					     "speed: 0x%08X",
> 					     pdata->link_speed);
> 				break;
> 			}
> 			phy_reg = smsc911x_mac_read(pdata, MAC_CR);
> 			phy_reg &= ~(MAC_CR_FDPX_ | MAC_CR_RCVOWN_);
> 
> 			switch (pdata->link_speed) {
> 			case LINK_SPEED_10HD:
> 			case LINK_SPEED_100HD:
> 				phy_reg |= MAC_CR_RCVOWN_;
> 				break;
> 
> 			case LINK_SPEED_10FD:
> 			case LINK_SPEED_100FD:
> 				phy_reg |= MAC_CR_FDPX_;
> 				break;
> 
> 			default:
> 				SMSC_WARNING("Unknown link speed: 0x%08X",
> 					     pdata->link_speed);
> 				break;
> 			}
> 
> 			smsc911x_mac_write(pdata, MAC_CR, phy_reg);
> 
> 			if (pdata->link_settings & LINK_AUTO_NEGOTIATE) {
> 				unsigned int linkpartner = 0;
> 				unsigned int locallink = 0;
> 				locallink = smsc911x_phy_read(pdata, 4);
> 				linkpartner = smsc911x_phy_read(pdata, 5);
> 				switch (pdata->link_speed) {
> 				case LINK_SPEED_10FD:
> 				case LINK_SPEED_100FD:
> 					if (((locallink & linkpartner) &
> 					     LPA_PAUSE_CAP) != 0) {
> 						/* Enable PAUSE receive and transmit */
> 						smsc911x_mac_write(pdata, FLOW,
> 								   0xFFFF0002);
> 						temp =
> 						    smsc911x_reg_read(pdata,
> 								      AFC_CFG);
> 						temp |= 0xF;
> 						smsc911x_reg_write(temp, pdata,
> 								   AFC_CFG);
> 					} else if (((locallink &
> 						     (ADVERTISE_PAUSE_CAP |
> 						      ADVERTISE_PAUSE_ASYM)) ==
> 						    (ADVERTISE_PAUSE_CAP |
> 						     ADVERTISE_PAUSE_ASYM)) &&
> 						   ((linkpartner &
> 						     (LPA_PAUSE_CAP |
> 						      LPA_PAUSE_ASYM)) ==
> 						    LPA_PAUSE_ASYM)) {

Wow...

[...]
> /* Increments the Rx error counters */
> static void
> smsc911x_rx_counterrors(struct smsc911x_data *pdata, unsigned int rxstat)
> {
> 	int crc_err;
> 
> 	crc_err = 0;

Merge declaration/initialization.

[...]
> /* Quickly dumps bad packets */
> static void
> smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int count)
> {
> 	if (likely(count >= 4)) {
> 		unsigned int timeout = 500;
> 		smsc911x_reg_write(RX_DP_CTRL_RX_FFWD_, pdata, RX_DP_CTRL);
> 		while (timeout && (smsc911x_reg_read(pdata, RX_DP_CTRL)
> 				   & RX_DP_CTRL_RX_FFWD_)) {
> 			udelay(1);
> 			timeout--;
> 		}
> 		if (unlikely(timeout == 0)) {
> 			SMSC_WARNING("Timed out waiting for RX FFWD "
> 				     "to finish, RX_DP_CTRL: 0x%08X",
> 				     smsc911x_reg_read(pdata, RX_DP_CTRL));
> 		}
> 	} else {
> 		while (count) {
> 			volatile unsigned int temp;
> 			temp = smsc911x_reg_read(pdata, RX_DATA_FIFO);

Kill the volatile: there is an implicit readl().

> /* NAPI poll function */
> static int smsc911x_poll(struct net_device *dev, int *budget)
> {
> 	struct smsc911x_data *pdata = netdev_priv(dev);
> 	int npackets = 0;
> 	int quota = min(dev->quota, *budget);
> 
> 	while (npackets < quota) {
> 		unsigned int pktlength;
> 		unsigned int rxstat;
> 		rxstat = smsc911x_rx_get_rxstatus(pdata);
> 
> 		/* break out of while loop if there are no more packets waiting */
> 		if (rxstat == 0)
> 			break;
> 
> 		pktlength = ((rxstat & 0x3FFF0000) >> 16);
> 		smsc911x_rx_counterrors(pdata, rxstat);
> 
> 		if (likely((rxstat & RX_STS_ES_) == 0)) {
> 			struct sk_buff *skb = NULL;

Useless initialization.

> 			skb = dev_alloc_skb(pktlength + 2);

s/2/NET_IP_ALIGN/

> 			if (likely(skb)) {
> 				skb->data = skb->head;
> 				skb->tail = skb->head;
> 				/* Align IP on 16B boundary */
> 				skb_reserve(skb, 2);

s/2/NET_IP_ALIGN/

[...]
> static int smsc911x_open(struct net_device *dev)
> {
> 	struct smsc911x_data *pdata = netdev_priv(dev);
> 	unsigned int mac_high16;
> 	unsigned int mac_low32;
> 	unsigned int timeout;
> 	unsigned int temp;
> 	unsigned long flags;
> 
> 	spin_lock_init(&pdata->phy_lock);
> 
> 	/* Reset the LAN911x */
> 	smsc911x_reg_write(HW_CFG_SRST_, pdata, HW_CFG);
> 	timeout = 10;
> 	do {
> 		udelay(10);
> 		temp = smsc911x_reg_read(pdata, HW_CFG);
> 	} while ((--timeout) && (temp & HW_CFG_SRST_));
> 
> 	if (unlikely(temp & HW_CFG_SRST_)) {
> 		SMSC_WARNING("Failed to complete reset");
> 		return -ENODEV;
> 	}
> 
> 	smsc911x_reg_write(0x00050000, pdata, HW_CFG);
> 	smsc911x_reg_write(0x006E3740, pdata, AFC_CFG);
> 
> 	/* Make sure EEPROM has finished loading before setting GPIO_CFG */
> 	timeout = 50;
> 	while ((timeout--) &&
> 	       (smsc911x_reg_read(pdata, E2P_CMD) & E2P_CMD_EPC_BUSY_)) {
> 		udelay(10);
> 	}
> 
> 	if (unlikely(timeout == 0)) {
> 		SMSC_WARNING("Timed out waiting for EEPROM "
> 			     "busy bit to clear\n");
> 	}
> #if USE_DEBUG >= 1
> 	smsc911x_reg_write(0x00670700, pdata, GPIO_CFG);
> #else
> 	smsc911x_reg_write(0x70070000, pdata, GPIO_CFG);
> #endif
> 
> 	/* Initialise irqs, but leave all sources disabled */
> 	smsc911x_reg_write(0, pdata, INT_EN);
> 	smsc911x_reg_write(0xFFFFFFFF, pdata, INT_STS);
> 	/* Set interrupt deassertion to 100uS */
> 	smsc911x_reg_write(((10 << 24) | INT_CFG_IRQ_EN_), pdata, INT_CFG);
> 
> 	/*
> 	 * intcfg |= INT_CFG_IRQ_POL_;  use this to set IRQ_POL bit
> 	 * intcfg |= INT_CFG_IRQ_TYPE_;  use this to set IRQ_TYPE bit
> 	 */
> 
> 	SMSC_TRACE("Testing irq handler using IRQ %d", dev->irq);
> 	pdata->request_irq_disable = 0;
> 	pdata->software_irq_signal = 0;
> 	temp = smsc911x_reg_read(pdata, INT_EN);
> 	temp |= INT_EN_SW_INT_EN_;
> 	smsc911x_reg_write(temp, pdata, INT_EN);
> 	timeout = 1000;
> 	do {
> 		udelay(10);
> 	} while ((--timeout) && (!pdata->software_irq_signal));

	while (timeout--) {
		smp_rmb();
		if (pdata->software_irq_signal)
			break;
		msleep(1);
	}

	+ smp_wmb() in the irq handler.

> 
> 	if (!pdata->software_irq_signal) {
> 		printk(KERN_WARNING "%s: ISR failed signaling test (IRQ %d)\n",
> 		       dev->name, dev->irq);
> 		return -ENODEV;
> 	}
> 	SMSC_TRACE("IRQ handler passed test using IRQ %d", dev->irq);
> 
> 	printk(KERN_INFO "%s: SMSC911x/921x identified at %#08lx, IRQ: %d\n",
> 	       dev->name, (unsigned long)pdata->ioaddr, dev->irq);
> 
> 	spin_lock_irqsave(&pdata->phy_lock, flags);

flags useless: ->open() is issued in irq-enabled context.

> 
> 	/* Read mac address from EEPROM */
> 	mac_high16 = smsc911x_mac_read(pdata, ADDRH);
> 	mac_low32 = smsc911x_mac_read(pdata, ADDRL);
> 
> 	/* Generate random MAC address if eeprom values are invalid */
> 	if ((mac_high16 == 0x0000FFFF) && (mac_low32 == 0xFFFFFFFF)) {
> 		u8 random_mac[6];
> 		random_ether_addr(random_mac);
> 		mac_high16 = (random_mac[5] << 8) | random_mac[4];
> 		mac_low32 = (random_mac[3] << 24) | (random_mac[2] << 16) |
> 		    (random_mac[1] << 8) | random_mac[0];
> 
> 		smsc911x_mac_write(pdata, ADDRH, mac_high16);
> 		smsc911x_mac_write(pdata, ADDRL, mac_low32);
> 		SMSC_TRACE("MAC Address is set to random_ether_addr");
> 	} else {
> 		SMSC_TRACE("Mac Address is read from LAN911x EEPROM");
> 	}
> 
> 	dev->dev_addr[0] = (u8)(mac_low32);
> 	dev->dev_addr[1] = (u8)(mac_low32 >> 8);
> 	dev->dev_addr[2] = (u8)(mac_low32 >> 16);
> 	dev->dev_addr[3] = (u8)(mac_low32 >> 24);
> 	dev->dev_addr[4] = (u8)(mac_high16);
> 	dev->dev_addr[5] = (u8)(mac_high16 >> 8);
> 	printk(KERN_INFO
> 	       "%s: SMSC911x MAC Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
> 	       dev->name, dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
> 	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
> 
> 	netif_carrier_off(dev);
> 	if (!smsc911x_phy_initialise(dev)) {
> 		SMSC_WARNING("Failed to initialize PHY");
> 		return -ENODEV;

return with spinlock held (mantra: use goto).

Any chance you could avoid the spinlock ? It would help turning udelay
into sleep (namely smsc911x_phy_reset).

[...]
> #ifdef CONFIG_NET_POLL_CONTROLLER
> void smsc911x_poll_controller(struct net_device *dev)
> {
> 	disable_irq(dev->irq);
> 	smsc911x_irqhandler(0, (void *)dev, NULL);

No need to cast to (void *)

> 	enable_irq(dev->irq);
> }
> #endif				/* CONFIG_NET_POLL_CONTROLLER */
> 
> /* Standard ioctls for mii-tool */
> int smsc911x_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)

static int

> {
> 	struct smsc911x_data *pdata = netdev_priv(dev);
> 	struct mii_ioctl_data *const data =
> 	    (struct mii_ioctl_data *)&ifr->ifr_data;

Use if_mii()

> 	unsigned long flags;
> 
> 	SMSC_TRACE("ioctl cmd 0x%x", cmd);
> 	switch (cmd) {
> 	case SIOCGMIIPHY:
> 	case SIOCDEVPRIVATE:

The SIOCDEVPRIVATE can/should be removed.

[...]
> static int smsc911x_drv_probe(struct platform_device *pdev)
> {
> 	struct net_device *dev;
> 	struct smsc911x_data *pdata;
> 	struct resource *res;
> 	int res_size;
> 	int retval;
> 
> 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
> 					   "smsc911x-memory");
> 	if (!res)
> 		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> 	if (!res) {
> 		retval = -ENODEV;
> 		goto out;
> 	}
> 	res_size = res->end - res->start;
> 
> 	if (!request_mem_region(res->start, res_size, SMSC_CHIPNAME)) {
> 		retval = -EBUSY;
> 		goto out;
> 	}
> 
> 	dev = alloc_etherdev(sizeof(struct smsc911x_data));
> 	if (!dev) {
> 		printk(KERN_WARNING "%s: Could not allocate device.\n",
> 		       SMSC_CHIPNAME);
> 		retval = -ENOMEM;
> 		goto out_release_io;
> 	}
> 	SET_MODULE_OWNER(dev);
> 	SET_NETDEV_DEV(dev, &pdev->dev);
> 
> 	pdata = netdev_priv(dev);
> 	memset(pdata, 0, sizeof(struct smsc911x_data));
> 
> 	dev->irq = platform_get_irq(pdev, 0);
> 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
> 
> 	if (pdata->ioaddr == NULL) {
> 		SMSC_WARNING("Error smsc911x base address invalid");
> 		retval = -ENOMEM;
> 		goto out_free_netdev;
> 	}
> 
> 	if ((retval = smsc911x_init(dev)) < 0)
> 		goto out_unmap_io;
> 
> 	if (request_irq(dev->irq, smsc911x_irqhandler,
> 			SA_INTERRUPT, SMSC_CHIPNAME, dev) != 0) {
> 		SMSC_WARNING("Unable to claim requested irq: %d", dev->irq);
> 		retval = -ENODEV;

Should be retval = request_irq(...)

> 		goto out_unmap_io;
> 	}
> 
> 	platform_set_drvdata(pdev, dev);
> 	retval = register_netdev(dev);
> 
> 	if (retval) {
> 		SMSC_WARNING("Error %i registering device", retval);
> 		retval = -ENODEV;

No need to overwrite retval.

> 		goto out_unset_drvdata;
> 	} else {
> 		SMSC_TRACE("Network interface: \"%s\"", dev->name);
> 	}
> 
> 	return 0;
> 
> out_unset_drvdata:
> 	platform_set_drvdata(pdev, NULL);

Missing free_irq().

Please number the label: out_0, out_release_io_1, etc... It's easier to check.

> out_unmap_io:
> 	iounmap(pdata->ioaddr);
> out_free_netdev:
> 	free_netdev(dev);
> out_release_io:
> 	release_mem_region(res->start, res->end - res->start);
> out:
> 	return retval;
> }

[...]
> /* Entry point for loading the module */
> static int __init smsc911x_init_module(void)
> {
> 	platform_driver_register(&smsc911x_driver);
> 	return 0;

return platform_driver_register(...);

> --- /dev/null
> ++ b/drivers/net/smsc911x.h
|...]
> static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
> {
> 	u32 reg_val;
> 	unsigned long flags;
> 
> 	/* these two 16-bit reads must be performed consecutively, so must
> 	 * not be interrupted by our own ISR (which would start another
> 	 * read operation) */
> 	local_irq_save(flags);
> 	reg_val =
> 	    ((readw((u16 *)(((unsigned int)pdata->ioaddr) + reg)) & 0xFFFF) |

pdata->ioaddr is void * now. Please simplify.

