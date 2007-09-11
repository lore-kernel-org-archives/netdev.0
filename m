From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Add IP1000A Driver
Date: Tue, 11 Sep 2007 16:41:44 +0200
Message-ID: <20070911164144.2853bcff@oldman>
References: <1189524638.3261.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	jesse@icplus.com.tw
To: Jesse Huang <jesse@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35595 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750938AbXIKOmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 10:42:11 -0400
In-Reply-To: <1189524638.3261.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Sep 2007 11:30:38 -0400
Jesse Huang <jesse@icplus.com.tw> wrote:

> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Change Logs: Add IP1000A Driver to kernel tree.
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>

Who will be listed as maintainer of this device?
A good way to show that is to add an entry to MAINTAINERS file.


>  drivers/net/ipg.c | 2331 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/ipg.h |  856 +++++++++++++++++++
>  2 files changed, 3187 insertions(+), 0 deletions(-)
>  create mode 100755 drivers/net/ipg.c
>  create mode 100755 drivers/net/ipg.h
> 
> e804d1c265bf1d843f845457f925a1728bbfdff7
> diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
> new file mode 100755
> index 0000000..bdc2b8d
> --- /dev/null
> +++ b/drivers/net/ipg.c
> @@ -0,0 +1,2331 @@
> +/*
> + * ipg.c: Device Driver for the IP1000 Gigabit Ethernet Adapter
> + *
> + * Copyright (C) 2003, 2006  IC Plus Corp.
> + *
> + * Original Author:
> + *
> + *   Craig Rich
> + *   Sundance Technology, Inc.
> + *   1485 Saratoga Avenue
> + *   Suite 200
> + *   San Jose, CA 95129
> + *   408 873 4117
> + *   www.sundanceti.com
> + *   craig_rich@sundanceti.com
> + *
> + * Current Maintainer:
> + *
> + *   Sorbica Shieh.
> + *   10F, No.47, Lane 2, Kwang-Fu RD.
> + *   Sec. 2, Hsin-Chu, Taiwan, R.O.C.
> + *   http://www.icplus.com.tw
> + *   sorbica@icplus.com.tw
> + */

Names only, no physical addresses please.

> +/*
> + * Read a register from the Physical Layer device located
> + * on the IPG NIC, using the IPG PHYCTRL register.
> + */
> +static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
> +{
> +	void __iomem *ioaddr = ipg_ioaddr(dev);
> +	/*
> +	 * The GMII mangement frame structure for a read is as follows:
> +	 *
> +	 * |Preamble|st|op|phyad|regad|ta|      data      |idle|
> +	 * |< 32 1s>|01|10|AAAAA|RRRRR|z0|DDDDDDDDDDDDDDDD|z   |
> +	 *
> +	 * <32 1s> = 32 consecutive logic 1 values
> +	 * A = bit of Physical Layer device address (MSB first)
> +	 * R = bit of register address (MSB first)
> +	 * z = High impedance state
> +	 * D = bit of read data (MSB first)
> +	 *
> +	 * Transmission order is 'Preamble' field first, bits transmitted
> +	 * left to right (first to last).
> +	 */
> +	struct {
> +		u32 field;
> +		unsigned int len;
> +	} p[] = {
> +		{ GMII_PREAMBLE,	32 },	/* Preamble */
> +		{ GMII_ST,		2  },	/* ST */
> +		{ GMII_READ,		2  },	/* OP */
> +		{ phy_id,		5  },	/* PHYAD */
> +		{ phy_reg,		5  },	/* REGAD */
> +		{ 0x0000,		2  },	/* TA */
> +		{ 0x0000,		16 },	/* DATA */
> +		{ 0x0000,		1  }	/* IDLE */
> +	};

This could be declared static const, since it doesn't change.

> +	unsigned int i, j;
> +	u8 polarity, data;
> +
> +	polarity  = ipg_r8(PHY_CTRL);
> +	polarity &= (IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
> +
> +	/* Create the Preamble, ST, OP, PHYAD, and REGAD field. */
> +	for (j = 0; j < 5; j++) {
> +		for (i = 0; i < p[j].len; i++) {
> +			/* For each variable length field, the MSB must be
> +			 * transmitted first. Rotate through the field bits,
> +			 * starting with the MSB, and move each bit into the
> +			 * the 1st (2^1) bit position (this is the bit position
> +			 * corresponding to the MgmtData bit of the PhyCtrl
> +			 * register for the IPG).
> +			 *
> +			 * Example: ST = 01;
> +			 *
> +			 *          First write a '0' to bit 1 of the PhyCtrl
> +			 *          register, then write a '1' to bit 1 of the
> +			 *          PhyCtrl register.
> +			 *
> +			 * To do this, right shift the MSB of ST by the value:
> +			 * [field length - 1 - #ST bits already written]
> +			 * then left shift this result by 1.
> +			 */
> +			data  = (p[j].field >> (p[j].len - 1 - i)) << 1;
> +			data &= IPG_PC_MGMTDATA;
> +			data |= polarity | IPG_PC_MGMTDIR;
> +
> +			ipg_drive_phy_ctl_low_high(ioaddr, data);
> +		}
> +	}
> +
> +	send_three_state(ioaddr, polarity);
> +
> +	read_phy_bit(ioaddr, polarity);
> +
> +	/*
> +	 * For a read cycle, the bits for the next two fields (TA and
> +	 * DATA) are driven by the PHY (the IPG reads these bits).
> +	 */
> +	for (i = 0; i < p[6].len; i++) {
> +		p[6].field |=
> +		    (read_phy_bit(ioaddr, polarity) << (p[6].len - 1 - i));
> +	}
> +
> +	send_three_state(ioaddr, polarity);
> +	send_three_state(ioaddr, polarity);
> +	send_three_state(ioaddr, polarity);
> +	send_end(ioaddr, polarity);
> +
> +	/* Return the value of the DATA field. */
> +	return p[6].field;
> +}
> +
> +/*
> + * Write to a register from the Physical Layer device located
> + * on the IPG NIC, using the IPG PHYCTRL register.
> + */
> +static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
> +{
> +	void __iomem *ioaddr = ipg_ioaddr(dev);
> +	/*
> +	 * The GMII mangement frame structure for a read is as follows:
> +	 *
> +	 * |Preamble|st|op|phyad|regad|ta|      data      |idle|
> +	 * |< 32 1s>|01|10|AAAAA|RRRRR|z0|DDDDDDDDDDDDDDDD|z   |
> +	 *
> +	 * <32 1s> = 32 consecutive logic 1 values
> +	 * A = bit of Physical Layer device address (MSB first)
> +	 * R = bit of register address (MSB first)
> +	 * z = High impedance state
> +	 * D = bit of write data (MSB first)
> +	 *
> +	 * Transmission order is 'Preamble' field first, bits transmitted
> +	 * left to right (first to last).
> +	 */
> +	struct {
> +		u32 field;
> +		unsigned int len;
> +	} p[] = {
> +		{ GMII_PREAMBLE,	32 },	/* Preamble */
> +		{ GMII_ST,		2  },	/* ST */
> +		{ GMII_WRITE,		2  },	/* OP */
> +		{ phy_id,		5  },	/* PHYAD */
> +		{ phy_reg,		5  },	/* REGAD */
> +		{ 0x0002,		2  },	/* TA */
> +		{ val & 0xffff,		16 },	/* DATA */
> +		{ 0x0000,		1  }	/* IDLE */
> +	};
> +	unsigned int i, j;
> +	u8 polarity, data;
> +
> +	polarity  = ipg_r8(PHY_CTRL);
> +	polarity &= (IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
> +
> +	/* Create the Preamble, ST, OP, PHYAD, and REGAD field. */
> +	for (j = 0; j < 7; j++) {
> +		for (i = 0; i < p[j].len; i++) {
> +			/* For each variable length field, the MSB must be
> +			 * transmitted first. Rotate through the field bits,
> +			 * starting with the MSB, and move each bit into the
> +			 * the 1st (2^1) bit position (this is the bit position
> +			 * corresponding to the MgmtData bit of the PhyCtrl
> +			 * register for the IPG).
> +			 *
> +			 * Example: ST = 01;
> +			 *
> +			 *          First write a '0' to bit 1 of the PhyCtrl
> +			 *          register, then write a '1' to bit 1 of the
> +			 *          PhyCtrl register.
> +			 *
> +			 * To do this, right shift the MSB of ST by the value:
> +			 * [field length - 1 - #ST bits already written]
> +			 * then left shift this result by 1.
> +			 */
> +			data  = (p[j].field >> (p[j].len - 1 - i)) << 1;
> +			data &= IPG_PC_MGMTDATA;
> +			data |= polarity | IPG_PC_MGMTDIR;
> +
> +			ipg_drive_phy_ctl_low_high(ioaddr, data);
> +		}
> +	}
> +
> +	/* The last cycle is a tri-state, so read from the PHY. */
> +	for (j = 7; j < 8; j++) {
> +		for (i = 0; i < p[j].len; i++) {
> +			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
> +
> +			p[j].field |= ((ipg_r8(PHY_CTRL) &
> +				IPG_PC_MGMTDATA) >> 1) << (p[j].len - 1 - i);
> +
> +			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
> +		}
> +	}
> +}
> +
> +/* Set LED_Mode JES20040127EEPROM */
> +static void ipg_set_led_mode(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +	u32 mode;
> +
> +	mode = ipg_r32(ASIC_CTRL);
> +	mode &= ~(IPG_AC_LED_MODE_BIT_1 | IPG_AC_LED_MODE | IPG_AC_LED_SPEED);
> +
> +	if ((sp->LED_Mode & 0x03) > 1)
> +		mode |= IPG_AC_LED_MODE_BIT_1;	/* Write Asic Control Bit 29 */
> +
> +	if ((sp->LED_Mode & 0x01) == 1)
> +		mode |= IPG_AC_LED_MODE;	/* Write Asic Control Bit 14 */
> +
> +	if ((sp->LED_Mode & 0x08) == 8)
> +		mode |= IPG_AC_LED_SPEED;	/* Write Asic Control Bit 27 */
> +
> +	ipg_w32(mode, ASIC_CTRL);
> +}
> +
> +/* Set PHYSet JES20040127EEPROM */
> +static void ipg_set_phy_set(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +	int physet;
> +
> +	physet = ipg_r8(PHY_SET);
> +	physet &= ~(IPG_PS_MEM_LENB9B | IPG_PS_MEM_LEN9 | IPG_PS_NON_COMPDET);
> +	physet |= ((sp->LED_Mode & 0x70) >> 4);
> +	ipg_w8(physet, PHY_SET);
> +}
> +
> +static int ipg_reset(struct net_device *dev, u32 resetflags)
> +{
> +	/* Assert functional resets via the IPG AsicCtrl
> +	 * register as specified by the 'resetflags' input
> +	 * parameter.
> +	 */
> +	void __iomem *ioaddr = ipg_ioaddr(dev);	//JES20040127EEPROM:
> +	unsigned int timeout_count = 0;
> +
> +	IPG_DEBUG_MSG("_reset\n");
> +
> +	ipg_w32(ipg_r32(ASIC_CTRL) | resetflags, ASIC_CTRL);
> +
> +	/* Delay added to account for problem with 10Mbps reset. */
> +	mdelay(IPG_AC_RESETWAIT);
> +
> +	while (IPG_AC_RESET_BUSY & ipg_r32(ASIC_CTRL)) {
> +		mdelay(IPG_AC_RESETWAIT);
> +		if (++timeout_count > IPG_AC_RESET_TIMEOUT)
> +			return -ETIME;
> +	}
> +	/* Set LED Mode in Asic Control JES20040127EEPROM */
> +	ipg_set_led_mode(dev);
> +
> +	/* Set PHYSet Register Value JES20040127EEPROM */
> +	ipg_set_phy_set(dev);
> +	return 0;
> +}
> +
> +/* Find the GMII PHY address. */
> +static int ipg_find_phyaddr(struct net_device *dev)
> +{
> +	unsigned int phyaddr, i;
> +
> +	for (i = 0; i < 32; i++) {
> +		u32 status;
> +
> +		/* Search for the correct PHY address among 32 possible. */
> +		phyaddr = (IPG_NIC_PHY_ADDRESS + i) % 32;
> +
> +		/* 10/22/03 Grace change verify from GMII_PHY_STATUS to
> +		   GMII_PHY_ID1
> +		 */
> +
> +		status = mdio_read(dev, phyaddr, MII_BMSR);
> +
> +		if ((status != 0xFFFF) && (status != 0))
> +			return phyaddr;
> +	}
> +
> +	return 0x1f;
> +}
> +
> +/*
> + * Configure IPG based on result of IEEE 802.3 PHY
> + * auto-negotiation.
> + */
> +static int ipg_config_autoneg(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +	unsigned int txflowcontrol;
> +	unsigned int rxflowcontrol;
> +	unsigned int fullduplex;
> +	unsigned int gig;
> +	u32 mac_ctrl_val;
> +	u32 asicctrl;
> +	u8 phyctrl;
> +
> +	IPG_DEBUG_MSG("_config_autoneg\n");
> +
> +	asicctrl = ipg_r32(ASIC_CTRL);
> +	phyctrl = ipg_r8(PHY_CTRL);
> +	mac_ctrl_val = ipg_r32(MAC_CTRL);
> +
> +	/* Set flags for use in resolving auto-negotation, assuming
> +	 * non-1000Mbps, half duplex, no flow control.
> +	 */
> +	fullduplex = 0;
> +	txflowcontrol = 0;
> +	rxflowcontrol = 0;
> +	gig = 0;
> +
> +	/* To accomodate a problem in 10Mbps operation,
> +	 * set a global flag if PHY running in 10Mbps mode.
> +	 */
> +	sp->tenmbpsmode = 0;
> +
> +	printk(KERN_INFO "%s: Link speed = ", dev->name);
> +
> +	/* Determine actual speed of operation. */
> +	switch (phyctrl & IPG_PC_LINK_SPEED) {
> +	case IPG_PC_LINK_SPEED_10MBPS:
> +		printk("10Mbps.\n");
> +		printk(KERN_INFO "%s: 10Mbps operational mode enabled.\n",
> +		       dev->name);
> +		sp->tenmbpsmode = 1;
> +		break;
> +	case IPG_PC_LINK_SPEED_100MBPS:
> +		printk("100Mbps.\n");
> +		break;
> +	case IPG_PC_LINK_SPEED_1000MBPS:
> +		printk("1000Mbps.\n");
> +		gig = 1;
> +		break;
> +	default:
> +		printk("undefined!\n");
> +		return 0;
> +	}
> +
> +	if (phyctrl & IPG_PC_DUPLEX_STATUS) {
> +		fullduplex = 1;
> +		txflowcontrol = 1;
> +		rxflowcontrol = 1;
> +	}
> +
> +	/* Configure full duplex, and flow control. */
> +	if (fullduplex == 1) {
> +		/* Configure IPG for full duplex operation. */
> +		printk(KERN_INFO "%s: setting full duplex, ", dev->name);
> +
> +		mac_ctrl_val |= IPG_MC_DUPLEX_SELECT_FD;
> +
> +		if (txflowcontrol == 1) {
> +			printk("TX flow control");
> +			mac_ctrl_val |= IPG_MC_TX_FLOW_CONTROL_ENABLE;
> +		} else {
> +			printk("no TX flow control");
> +			mac_ctrl_val &= ~IPG_MC_TX_FLOW_CONTROL_ENABLE;
> +		}
> +
> +		if (rxflowcontrol == 1) {
> +			printk(", RX flow control.");
> +			mac_ctrl_val |= IPG_MC_RX_FLOW_CONTROL_ENABLE;
> +		} else {
> +			printk(", no RX flow control.");
> +			mac_ctrl_val &= ~IPG_MC_RX_FLOW_CONTROL_ENABLE;
> +		}
> +
> +		printk("\n");
> +	} else {
> +		/* Configure IPG for half duplex operation. */
> +	        printk(KERN_INFO "%s: setting half duplex, "
> +		       "no TX flow control, no RX flow control.\n", dev->name);
> +
> +		mac_ctrl_val &= ~IPG_MC_DUPLEX_SELECT_FD &
> +			~IPG_MC_TX_FLOW_CONTROL_ENABLE &
> +			~IPG_MC_RX_FLOW_CONTROL_ENABLE;
> +	}
> +	ipg_w32(mac_ctrl_val, MAC_CTRL);
> +	return 0;
> +}
> +
> +/* Determine and configure multicast operation and set
> + * receive mode for IPG.
> + */
> +static void ipg_nic_set_multicast_list(struct net_device *dev)
> +{
> +	void __iomem *ioaddr = ipg_ioaddr(dev);
> +	struct dev_mc_list *mc_list_ptr;
> +	unsigned int hashindex;
> +	u32 hashtable[2];
> +	u8 receivemode;
> +
> +	IPG_DEBUG_MSG("_nic_set_multicast_list\n");
> +
> +	receivemode = IPG_RM_RECEIVEUNICAST | IPG_RM_RECEIVEBROADCAST;
> +
> +	if (dev->flags & IFF_PROMISC) {
> +		/* NIC to be configured in promiscuous mode. */
> +		receivemode = IPG_RM_RECEIVEALLFRAMES;
> +	} else if ((dev->flags & IFF_ALLMULTI) ||
> +		   (dev->flags & IFF_MULTICAST &
> +		    (dev->mc_count > IPG_MULTICAST_HASHTABLE_SIZE))) {
> +		/* NIC to be configured to receive all multicast
> +		 * frames. */
> +		receivemode |= IPG_RM_RECEIVEMULTICAST;
> +	} else if (dev->flags & IFF_MULTICAST & (dev->mc_count > 0)) {
> +		/* NIC to be configured to receive selected
> +		 * multicast addresses. */
> +		receivemode |= IPG_RM_RECEIVEMULTICASTHASH;
> +	}
> +
> +	/* Calculate the bits to set for the 64 bit, IPG HASHTABLE.
> +	 * The IPG applies a cyclic-redundancy-check (the same CRC
> +	 * used to calculate the frame data FCS) to the destination
> +	 * address all incoming multicast frames whose destination
> +	 * address has the multicast bit set. The least significant
> +	 * 6 bits of the CRC result are used as an addressing index
> +	 * into the hash table. If the value of the bit addressed by
> +	 * this index is a 1, the frame is passed to the host system.
> +	 */
> +
> +	/* Clear hashtable. */
> +	hashtable[0] = 0x00000000;
> +	hashtable[1] = 0x00000000;
> +
> +	/* Cycle through all multicast addresses to filter. */
> +	for (mc_list_ptr = dev->mc_list;
> +	     mc_list_ptr != NULL; mc_list_ptr = mc_list_ptr->next) {
> +		/* Calculate CRC result for each multicast address. */
> +		hashindex = crc32_le(0xffffffff, mc_list_ptr->dmi_addr,
> +				     ETH_ALEN);
> +
> +		/* Use only the least significant 6 bits. */
> +		hashindex = hashindex & 0x3F;
> +
> +		/* Within "hashtable", set bit number "hashindex"
> +		 * to a logic 1.
> +		 */
> +		set_bit(hashindex, (void *)hashtable);
> +	}
> +
> +	/* Write the value of the hashtable, to the 4, 16 bit
> +	 * HASHTABLE IPG registers.
> +	 */
> +	ipg_w32(hashtable[0], HASHTABLE_0);
> +	ipg_w32(hashtable[1], HASHTABLE_1);
> +
> +	ipg_w8(IPG_RM_RSVD_MASK & receivemode, RECEIVE_MODE);
> +
> +	IPG_DEBUG_MSG("ReceiveMode = %x\n", ipg_r8(RECEIVE_MODE));
> +}
> +
> +static int ipg_io_config(struct net_device *dev)
> +{
> +	void __iomem *ioaddr = ipg_ioaddr(dev);
> +	u32 origmacctrl;
> +	u32 restoremacctrl;
> +
> +	IPG_DEBUG_MSG("_io_config\n");
> +
> +	origmacctrl = ipg_r32(MAC_CTRL);
> +
> +	restoremacctrl = origmacctrl | IPG_MC_STATISTICS_ENABLE;
> +
> +	/* Based on compilation option, determine if FCS is to be
> +	 * stripped on receive frames by IPG.
> +	 */
> +	if (!IPG_STRIP_FCS_ON_RX)
> +		restoremacctrl |= IPG_MC_RCV_FCS;
> +
> +	/* Determine if transmitter and/or receiver are
> +	 * enabled so we may restore MACCTRL correctly.
> +	 */
> +	if (origmacctrl & IPG_MC_TX_ENABLED)
> +		restoremacctrl |= IPG_MC_TX_ENABLE;
> +
> +	if (origmacctrl & IPG_MC_RX_ENABLED)
> +		restoremacctrl |= IPG_MC_RX_ENABLE;
> +
> +	/* Transmitter and receiver must be disabled before setting
> +	 * IFSSelect.
> +	 */
> +	ipg_w32((origmacctrl & (IPG_MC_RX_DISABLE | IPG_MC_TX_DISABLE)) &
> +		IPG_MC_RSVD_MASK, MAC_CTRL);
> +
> +	/* Now that transmitter and receiver are disabled, write
> +	 * to IFSSelect.
> +	 */
> +	ipg_w32((origmacctrl & IPG_MC_IFS_96BIT) & IPG_MC_RSVD_MASK, MAC_CTRL);
> +
> +	/* Set RECEIVEMODE register. */
> +	ipg_nic_set_multicast_list(dev);
> +
> +	ipg_w16(IPG_MAX_RXFRAME_SIZE, MAX_FRAME_SIZE);
> +
> +	ipg_w8(IPG_RXDMAPOLLPERIOD_VALUE,   RX_DMA_POLL_PERIOD);
> +	ipg_w8(IPG_RXDMAURGENTTHRESH_VALUE, RX_DMA_URGENT_THRESH);
> +	ipg_w8(IPG_RXDMABURSTTHRESH_VALUE,  RX_DMA_BURST_THRESH);
> +	ipg_w8(IPG_TXDMAPOLLPERIOD_VALUE,   TX_DMA_POLL_PERIOD);
> +	ipg_w8(IPG_TXDMAURGENTTHRESH_VALUE, TX_DMA_URGENT_THRESH);
> +	ipg_w8(IPG_TXDMABURSTTHRESH_VALUE,  TX_DMA_BURST_THRESH);
> +	ipg_w16((IPG_IE_HOST_ERROR | IPG_IE_TX_DMA_COMPLETE |
> +		 IPG_IE_TX_COMPLETE | IPG_IE_INT_REQUESTED |
> +		 IPG_IE_UPDATE_STATS | IPG_IE_LINK_EVENT |
> +		 IPG_IE_RX_DMA_COMPLETE | IPG_IE_RX_DMA_PRIORITY), INT_ENABLE);
> +	ipg_w16(IPG_FLOWONTHRESH_VALUE,  FLOW_ON_THRESH);
> +	ipg_w16(IPG_FLOWOFFTHRESH_VALUE, FLOW_OFF_THRESH);
> +
> +	/* IPG multi-frag frame bug workaround.
> +	 * Per silicon revision B3 eratta.
> +	 */
> +	ipg_w16(ipg_r16(DEBUG_CTRL) | 0x0200, DEBUG_CTRL);
> +
> +	/* IPG TX poll now bug workaround.
> +	 * Per silicon revision B3 eratta.
> +	 */
> +	ipg_w16(ipg_r16(DEBUG_CTRL) | 0x0010, DEBUG_CTRL);
> +
> +	/* IPG RX poll now bug workaround.
> +	 * Per silicon revision B3 eratta.
> +	 */
> +	ipg_w16(ipg_r16(DEBUG_CTRL) | 0x0020, DEBUG_CTRL);
> +
> +	/* Now restore MACCTRL to original setting. */
> +	ipg_w32(IPG_MC_RSVD_MASK & restoremacctrl, MAC_CTRL);
> +
> +	/* Disable unused RMON statistics. */
> +	ipg_w32(IPG_RZ_ALL, RMON_STATISTICS_MASK);
> +
> +	/* Disable unused MIB statistics. */
> +	ipg_w32(IPG_SM_MACCONTROLFRAMESXMTD | IPG_SM_MACCONTROLFRAMESRCVD |
> +		IPG_SM_BCSTOCTETXMTOK_BCSTFRAMESXMTDOK | IPG_SM_TXJUMBOFRAMES |
> +		IPG_SM_MCSTOCTETXMTOK_MCSTFRAMESXMTDOK | IPG_SM_RXJUMBOFRAMES |
> +		IPG_SM_BCSTOCTETRCVDOK_BCSTFRAMESRCVDOK |
> +		IPG_SM_UDPCHECKSUMERRORS | IPG_SM_TCPCHECKSUMERRORS |
> +		IPG_SM_IPCHECKSUMERRORS, STATISTICS_MASK);
> +
> +	return 0;
> +}
> +
> +/*
> + * Create a receive buffer within system memory and update
> + * NIC private structure appropriately.
> + */
> +static int ipg_get_rxbuff(struct net_device *dev, int entry)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	struct ipg_rx *rxfd = sp->rxd + entry;
> +	struct sk_buff *skb;
> +	u64 rxfragsize;
> +
> +	IPG_DEBUG_MSG("_get_rxbuff\n");
> +
> +	skb = netdev_alloc_skb(dev, IPG_RXSUPPORT_SIZE + NET_IP_ALIGN);
> +	if (!skb) {
> +		sp->RxBuff[entry] = NULL;
> +		return -ENOMEM;
> +	}
> +
> +	/* Adjust the data start location within the buffer to
> +	 * align IP address field to a 16 byte boundary.
> +	 */
> +	skb_reserve(skb, NET_IP_ALIGN);
> +
> +	/* Associate the receive buffer with the IPG NIC. */
> +	skb->dev = dev;
> +
> +	/* Save the address of the sk_buff structure. */
> +	sp->RxBuff[entry] = skb;
> +
> +	rxfd->frag_info = cpu_to_le64(pci_map_single(sp->pdev, skb->data,
> +		sp->rx_buf_sz, PCI_DMA_FROMDEVICE));
> +
> +	/* Set the RFD fragment length. */
> +	rxfragsize = IPG_RXFRAG_SIZE;
> +	rxfd->frag_info |= cpu_to_le64((rxfragsize << 48) & IPG_RFI_FRAGLEN);
> +
> +	return 0;
> +}
> +
> +static int init_rfdlist(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +	unsigned int i;
> +
> +	IPG_DEBUG_MSG("_init_rfdlist\n");
> +
> +	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
> +		struct ipg_rx *rxfd = sp->rxd + i;
> +
> +		if (sp->RxBuff[i]) {
> +			pci_unmap_single(sp->pdev,
> +				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
> +				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
> +			IPG_DEV_KFREE_SKB(sp->RxBuff[i]);
> +			sp->RxBuff[i] = NULL;
> +		}
> +
> +		/* Clear out the RFS field. */
> +		rxfd->rfs = 0x0000000000000000;
> +
> +		if (ipg_get_rxbuff(dev, i) < 0) {
> +			/*
> +			 * A receive buffer was not ready, break the
> +			 * RFD list here.
> +			 */
> +			IPG_DEBUG_MSG("Cannot allocate Rx buffer.\n");
> +
> +			/* Just in case we cannot allocate a single RFD.
> +			 * Should not occur.
> +			 */
> +			if (i == 0) {
> +				printk(KERN_ERR "%s: No memory available"
> +					" for RFD list.\n", dev->name);
> +				return -ENOMEM;
> +			}
> +		}
> +
> +		rxfd->next_desc = cpu_to_le64(sp->rxd_map +
> +			sizeof(struct ipg_rx)*(i + 1));
> +	}
> +	sp->rxd[i - 1].next_desc = cpu_to_le64(sp->rxd_map);
> +
> +	sp->rx_current = 0;
> +	sp->rx_dirty = 0;
> +
> +	/* Write the location of the RFDList to the IPG. */
> +	ipg_w32((u32) sp->rxd_map, RFD_LIST_PTR_0);
> +	ipg_w32(0x00000000, RFD_LIST_PTR_1);
> +
> +	return 0;
> +}
> +
> +static void init_tfdlist(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +	unsigned int i;
> +
> +	IPG_DEBUG_MSG("_init_tfdlist\n");
> +
> +	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
> +		struct ipg_tx *txfd = sp->txd + i;
> +
> +		txfd->tfc = cpu_to_le64(IPG_TFC_TFDDONE);
> +
> +		if (sp->TxBuff[i]) {
> +			IPG_DEV_KFREE_SKB(sp->TxBuff[i]);
> +			sp->TxBuff[i] = NULL;
> +		}
> +
> +		txfd->next_desc = cpu_to_le64(sp->txd_map +
> +			sizeof(struct ipg_tx)*(i + 1));
> +	}
> +	sp->txd[i - 1].next_desc = cpu_to_le64(sp->txd_map);
> +
> +	sp->tx_current = 0;
> +	sp->tx_dirty = 0;
> +
> +	/* Write the location of the TFDList to the IPG. */
> +	IPG_DDEBUG_MSG("Starting TFDListPtr = %8.8x\n",
> +		       (u32) sp->txd_map);
> +	ipg_w32((u32) sp->txd_map, TFD_LIST_PTR_0);
> +	ipg_w32(0x00000000, TFD_LIST_PTR_1);
> +
> +	sp->ResetCurrentTFD = 1;
> +}
> +
> +/*
> + * Free all transmit buffers which have already been transfered
> + * via DMA to the IPG.
> + */
> +static void ipg_nic_txfree(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +	const unsigned int curr = ipg_r32(TFD_LIST_PTR_0) -
> +		(sp->txd_map / sizeof(struct ipg_tx)) - 1;
> +	unsigned int released, pending;
> +
> +	IPG_DEBUG_MSG("_nic_txfree\n");
> +
> +	pending = sp->tx_current - sp->tx_dirty;
> +
> +	for (released = 0; released < pending; released++) {
> +		unsigned int dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
> +		struct sk_buff *skb = sp->TxBuff[dirty];
> +		struct ipg_tx *txfd = sp->txd + dirty;
> +
> +		IPG_DEBUG_MSG("TFC = %16.16lx\n", (unsigned long) txfd->tfc);
> +
> +		/* Look at each TFD's TFC field beginning
> +		 * at the last freed TFD up to the current TFD.
> +		 * If the TFDDone bit is set, free the associated
> +		 * buffer.
> +		 */
> +		if (dirty == curr)
> +			break;
> +
> +		/* Setup TFDDONE for compatible issue. */
> +		txfd->tfc |= cpu_to_le64(IPG_TFC_TFDDONE);
> +
> +		/* Free the transmit buffer. */
> +		if (skb) {
> +			pci_unmap_single(sp->pdev,
> +				le64_to_cpu(txfd->frag_info & ~IPG_TFI_FRAGLEN),
> +				skb->len, PCI_DMA_TODEVICE);
> +
> +			IPG_DEV_KFREE_SKB(skb);
> +
> +			sp->TxBuff[dirty] = NULL;
> +		}
> +	}
> +
> +	sp->tx_dirty += released;
> +
> +	if (netif_queue_stopped(dev) &&
> +	    (sp->tx_current != (sp->tx_dirty + IPG_TFDLIST_LENGTH))) {
> +		netif_wake_queue(dev);
> +	}
> +}
> +
> +static void ipg_tx_timeout(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +
> +	ipg_reset(dev, IPG_AC_TX_RESET | IPG_AC_DMA | IPG_AC_NETWORK |
> +		  IPG_AC_FIFO);
> +
> +	spin_lock_irq(&sp->lock);
> +
> +	/* Re-configure after DMA reset. */
> +	if (ipg_io_config(dev) < 0) {
> +		printk(KERN_INFO "%s: Error during re-configuration.\n",
> +		       dev->name);
> +	}
> +
> +	init_tfdlist(dev);
> +
> +	spin_unlock_irq(&sp->lock);
> +
> +	ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) & IPG_MC_RSVD_MASK,
> +		MAC_CTRL);
> +}
> +
> +/*
> + * For TxComplete interrupts, free all transmit
> + * buffers which have already been transfered via DMA
> + * to the IPG.
> + */
> +static void ipg_nic_txcleanup(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +	unsigned int i;
> +
> +	IPG_DEBUG_MSG("_nic_txcleanup\n");
> +
> +	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
> +		/* Reading the TXSTATUS register clears the
> +		 * TX_COMPLETE interrupt.
> +		 */
> +		u32 txstatusdword = ipg_r32(TX_STATUS);
> +
> +		IPG_DEBUG_MSG("TxStatus = %8.8x\n", txstatusdword);
> +
> +		/* Check for Transmit errors. Error bits only valid if
> +		 * TX_COMPLETE bit in the TXSTATUS register is a 1.
> +		 */
> +		if (!(txstatusdword & IPG_TS_TX_COMPLETE))
> +			break;
> +
> +		/* If in 10Mbps mode, indicate transmit is ready. */
> +		if (sp->tenmbpsmode) {
> +			netif_wake_queue(dev);
> +		}
> +
> +		/* Transmit error, increment stat counters. */
> +		if (txstatusdword & IPG_TS_TX_ERROR) {
> +			IPG_DEBUG_MSG("Transmit error.\n");
> +			sp->stats.tx_errors++;
> +		}
> +
> +		/* Late collision, re-enable transmitter. */
> +		if (txstatusdword & IPG_TS_LATE_COLLISION) {
> +			IPG_DEBUG_MSG("Late collision on transmit.\n");
> +			ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) &
> +				IPG_MC_RSVD_MASK, MAC_CTRL);
> +		}
> +
> +		/* Maximum collisions, re-enable transmitter. */
> +		if (txstatusdword & IPG_TS_TX_MAX_COLL) {
> +			IPG_DEBUG_MSG("Maximum collisions on transmit.\n");
> +			ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) &
> +				IPG_MC_RSVD_MASK, MAC_CTRL);
> +		}
> +
> +		/* Transmit underrun, reset and re-enable
> +		 * transmitter.
> +		 */
> +		if (txstatusdword & IPG_TS_TX_UNDERRUN) {
> +			IPG_DEBUG_MSG("Transmitter underrun.\n");
> +			sp->stats.tx_fifo_errors++;
> +			ipg_reset(dev, IPG_AC_TX_RESET | IPG_AC_DMA |
> +				  IPG_AC_NETWORK | IPG_AC_FIFO);
> +
> +			/* Re-configure after DMA reset. */
> +			if (ipg_io_config(dev) < 0) {
> +				printk(KERN_INFO
> +				       "%s: Error during re-configuration.\n",
> +				       dev->name);
> +			}
> +			init_tfdlist(dev);
> +
> +			ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_TX_ENABLE) &
> +				IPG_MC_RSVD_MASK, MAC_CTRL);
> +		}
> +	}
> +
> +	ipg_nic_txfree(dev);
> +}
> +
> +/* Provides statistical information about the IPG NIC. */
> +struct net_device_stats *ipg_nic_get_stats(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +	u16 temp1;
> +	u16 temp2;
> +
> +	IPG_DEBUG_MSG("_nic_get_stats\n");
> +
> +	/* Check to see if the NIC has been initialized via nic_open,
> +	 * before trying to read statistic registers.
> +	 */
> +	if (!test_bit(__LINK_STATE_START, &dev->state))
> +		return &sp->stats;

The latest kernel has a statistics struct inside the netdevice that
can be used instead of having your own.


...

> +			/* If the frame contains an IP/TCP/UDP frame,
> +			 * determine if upper layer must check IP/TCP/UDP
> +			 * checksums.
> +			 *
> +			 * NOTE: DO NOT RELY ON THE TCP/UDP CHECKSUM
> +			 *       VERIFICATION FOR SILICON REVISIONS B3
> +			 *       AND EARLIER!
> +			 *
> +			 if ((le64_to_cpu(rxfd->rfs &
> +			 (IPG_RFS_TCPDETECTED | IPG_RFS_UDPDETECTED |
> +			 IPG_RFS_IPDETECTED))) &&
> +			 !(le64_to_cpu(rxfd->rfs &
> +			 (IPG_RFS_TCPERROR | IPG_RFS_UDPERROR |
> +			 IPG_RFS_IPERROR))))
> +			 {
> +			 * Indicate IP checksums were performed
> +			 * by the IPG.
> +			 *
> +			 skb->ip_summed = CHECKSUM_UNNECESSARY;
> +			 }

Sudden loss of proper indentation style

> +			 else
> +			 */
> +			if (1 == 1) {
> +				/* The IPG encountered an error with (or
> +				 * there were no) IP/TCP/UDP checksums.
> +				 * This may or may not indicate an invalid
> +				 * IP/TCP/UDP frame was received. Let the
> +				 * upper layer decide.
> +				 */
> +				skb->ip_summed = CHECKSUM_NONE;
> +			}
> +
> +			/* Hand off frame for higher layer processing.
> +			 * The function netif_rx() releases the sk_buff
> +			 * when processing completes.
> +			 */
> +			netif_rx(skb);
> +
> +			/* Record frame receive time (jiffies = Linux
> +			 * kernel current time stamp).
> +			 */
> +			dev->last_rx = jiffies;
> +		}
> +
> +		/* Assure RX buffer is not reused by IPG. */
> +		sp->RxBuff[entry] = NULL;
> +	}
> +
> +	/*
> +	 * If there are more RFDs to proces and the allocated amount of RFD
> +	 * processing time has expired, assert Interrupt Requested to make
> +	 * sure we come back to process the remaining RFDs.
> +	 */
> +	if (i == IPG_MAXRFDPROCESS_COUNT)
> +		ipg_w32(ipg_r32(ASIC_CTRL) | IPG_AC_INT_REQUEST, ASIC_CTRL);
> +
> +#ifdef IPG_DEBUG
> +	/* Check if the RFD list contained no receive frame data. */
> +	if (!i)
> +		sp->EmptyRFDListCount++;
> +#endif
> +	while ((le64_to_cpu(rxfd->rfs & IPG_RFS_RFDDONE)) &&
> +	       !((le64_to_cpu(rxfd->rfs & IPG_RFS_FRAMESTART)) &&
> +		 (le64_to_cpu(rxfd->rfs & IPG_RFS_FRAMEEND)))) {
> +		unsigned int entry = curr++ % IPG_RFDLIST_LENGTH;
> +
> +		rxfd = sp->rxd + entry;
> +
> +		IPG_DEBUG_MSG("Frame requires multiple RFDs.\n");
> +
> +		/* An unexpected event, additional code needed to handle
> +		 * properly. So for the time being, just disregard the
> +		 * frame.
> +		 */
> +
> +		/* Free the memory associated with the RX
> +		 * buffer since it is erroneous and we will
> +		 * not pass it to higher layer processes.
> +		 */
> +		if (sp->RxBuff[entry]) {
> +			pci_unmap_single(sp->pdev,
> +				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
> +				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
> +			IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
> +		}
> +
> +		/* Assure RX buffer is not reused by IPG. */
> +		sp->RxBuff[entry] = NULL;
> +	}
> +
> +	sp->rx_current = curr;
> +
> +	/* Check to see if there are a minimum number of used
> +	 * RFDs before restoring any (should improve performance.)
> +	 */
> +	if ((curr - sp->rx_dirty) >= IPG_MINUSEDRFDSTOFREE)
> +		ipg_nic_rxrestore(dev);
> +
> +	return 0;
> +}
> +#endif
>
