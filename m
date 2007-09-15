From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ipg: add IP1000A driver to kernel tree
Date: Fri, 14 Sep 2007 19:21:40 -0700
Message-ID: <20070914192140.15b18ecb.akpm@linux-foundation.org>
References: <1189774938.3353.1.camel@localhost.localdomain>
	<20070914211108.GB22975@electric-eye.fr.zoreil.com>
	<20070914212105.GA28233@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Jesse Huang <jesse@icplus.com.tw>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	s.l-h@gmx.de
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40849 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751842AbXIOCW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 22:22:27 -0400
In-Reply-To: <20070914212105.GA28233@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Sep 2007 23:21:05 +0200 Francois Romieu <romieu@fr.zoreil.com> wrote:

> ...
>
> +
> +static void ipg_dump_tfdlist(struct net_device *dev)
> +{
> +	struct ipg_nic_private *sp = netdev_priv(dev);
> +	void __iomem *ioaddr = sp->ioaddr;
> +	unsigned int i;
> +	u32 offset;
> +
> +	IPG_DEBUG_MSG("_dump_tfdlist\n");
> +
> +	printk(KERN_INFO "tx_current         = %2.2x\n", sp->tx_current);
> +	printk(KERN_INFO "tx_dirty = %2.2x\n", sp->tx_dirty);
> +	printk(KERN_INFO "TFDList start address = %16.16lx\n",
> +	       (unsigned long) sp->txd_map);
> +	printk(KERN_INFO "TFDListPtr register   = %8.8x%8.8x\n",
> +	       ipg_r32(IPG_TFDLISTPTR1), ipg_r32(IPG_TFDLISTPTR0));
> +
> +	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
> +		offset = (u32) &sp->txd[i].next_desc - (u32) sp->txd;
> +		printk(KERN_INFO "%2.2x %4.4x TFDNextPtr = %16.16lx\n", i,
> +		       offset, (unsigned long) sp->txd[i].next_desc);
> +
> +		offset = (u32) &sp->txd[i].tfc - (u32) sp->txd;

Is the u32 cast safe here on all architectures?

> +		printk(KERN_INFO "%2.2x %4.4x TFC        = %16.16lx\n", i,
> +		       offset, (unsigned long) sp->txd[i].tfc);
> +		offset = (u32) &sp->txd[i].frag_info - (u32) sp->txd;
> +		printk(KERN_INFO "%2.2x %4.4x frag_info   = %16.16lx\n", i,
> +		       offset, (unsigned long) sp->txd[i].frag_info);
> +	}
> +}
>
> ...
>
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

This will be built on the stack at runtime.

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

Simply because we're using p[6] as a temporary variable.

This can be tightened up.

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

similar here

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

although it might be tricky to avoid

> +}
> +
>
> ...
>
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

Is ETIME an appropriate errno here?  Zillions of drivers use it, but I
think it's for posix timers or something like that?

> +	}
> +	/* Set LED Mode in Asic Control JES20040127EEPROM */
> +	ipg_set_led_mode(dev);
> +
> +	/* Set PHYSet Register Value JES20040127EEPROM */
> +	ipg_set_phy_set(dev);
> +	return 0;
> +}
> +
> 
> [vast amounts trimmed]
>

Attention span expired, sorry.  ETIME.
