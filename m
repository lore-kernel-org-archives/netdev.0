From: linux@horizon.com
Subject: Re: [PATCH 3/3] drivers/net/ipg.c: fix horrible mdio_read and _write
Date: 8 Jan 2008 18:33:49 -0500
Message-ID: <20080108233349.21615.qmail@science.horizon.com>
References: <20080108204744.GB4450@electric-eye.fr.zoreil.com>
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: linux@horizon.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:12120 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752248AbYAHXdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:33:54 -0500
In-Reply-To: <20080108204744.GB4450@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +	do {
>> +		/* IPG_PC_MGMTDATA is a power of 2; compiler knows to shift */
>> +		u8 d = ((data >> --len) & 1) * IPG_PC_MGMTDATA;
>> +		/* + rather than | lets compiler microoptimize better */
>> +		ipg_drive_phy_ctl_low_high(ioaddr, d + otherbits);
>> +	} while (len);

> Imho something is not quite right when the code needs a comment every line
> and I am mildly convinced that we really want to honk an "optimizing mdio
> methods is ok" signal around.

Oh, but those are SPACE-saving optimiztions. :-)
I know it's not time-critical; it's really pure hack value, but is it
that evil?

> "while (len--) {" is probably more akpm-ish btw.

Well spotted.

[...]
>>  static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
>>  {
>>  	void __iomem *ioaddr = ipg_ioaddr(dev);
>> +	u8 const polarity = ipg_r8(PHY_CTRL) &
>> +			(IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);

> (IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY) appears twice. I would not
> mind a #define for it.

I'm hardly going to go to war over over the matter, but actually I disagree.

There's a non-zero mental cost to keeping track of an additional name,
and when it's only used two times, and is pretty simple, I think reducing
the number of layers of #defines to understand is a positive advantage.
The above reads "the two polarity bits from the PHY_CTRL register"
to a person who's never read ipg.h.  Adding IPG_PC_POLARITY_BITS just
requires mentally dereferencing another layer of pointers.

Think of it as a function small enough that it can be inlined.

>> @@ -221,75 +240,30 @@ static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
>[...]
>> -	for (i = 0; i < p[6].len; i++) {
>> -		p[6].field |=
>> -		    (read_phy_bit(ioaddr, polarity) << (p[6].len - 1 - i));
>> -	}
>> +	send_three_state(ioaddr, polarity);	/* TA first bit */
>> +	(void)read_phy_bit(ioaddr, polarity);		/* TA second bit */
>> +
>> +	for (i = 0; i < 16; i++)
>> +		data += data + read_phy_bit(ioaddr, polarity);
                ^^^^^^^^^^^^
> Huh ?

Okay, I guess you prefer
+		data = 2*data + read_phy_bit(ioaddr, polarity);

That's only one character longer and easier to understand.
Or even four characters:
+		data = (data<<1) + read_phy_bit(ioaddr, polarity);

That's just the synonym that happened to come out of my fingers at the
time.  There's no particular meaning to it.

>> @@ -299,11 +273,13 @@ static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
>>  static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
[...]
>> +	mdio_write_bits(ioaddr, polarity, GMII_PREAMBLE, 32);
>> +	mdio_write_bits(ioaddr, polarity, GMII_ST << 14 | GMII_WRITE << 12 |
>> +	                                  phy_id << 7 | phy_reg << 2 |
>> +					  0x2, 16);

> Use the 80 cols luke:
>	                                  phy_id << 7 | phy_reg << 2 | 0x2, 16);

Good spotting, thanks.

Here's a revised patch:

    drivers/net/ipg.c: Fixed style problems that AKPM noticed.
    
    (And a few more while at it.  Including an actual bug in enabling multicast
    due to & vs. && confusion.)

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 3860fcd..fb69374 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -188,9 +188,9 @@ static void send_end(void __iomem *ioaddr, u8 phyctrlpolarity)
 		phyctrlpolarity) & IPG_PC_RSVD_MASK, PHY_CTRL);
 }
 
-static u16 read_phy_bit(void __iomem * ioaddr, u8 phyctrlpolarity)
+static unsigned read_phy_bit(void __iomem * ioaddr, u8 phyctrlpolarity)
 {
-	u16 bit_data;
+	unsigned bit_data;
 
 	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | phyctrlpolarity);
 
@@ -202,12 +202,31 @@ static u16 read_phy_bit(void __iomem * ioaddr, u8 phyctrlpolarity)
 }
 
 /*
+ * Transmit the given bits, MSB-first, through the MgmtData bit (bit 1)
+ * of the PhyCtrl register. 1 <= len <= 32.  "ioaddr" is the register
+ * address, and "otherbits" are the values of the other bits.
+ */
+static void mdio_write_bits(void __iomem *ioaddr, u8 otherbits, u32 data, unsigned len)
+{
+	otherbits |= IPG_PC_MGMTDIR;
+	while (len--) {
+		/* IPG_PC_MGMTDATA is a power of 2; compiler knows to shift */
+		u8 d = ((data >> len) & 1) * IPG_PC_MGMTDATA;
+		/* + rather than | allows slight code size microoptimization */
+		ipg_drive_phy_ctl_low_high(ioaddr, d + otherbits);
+	}
+}
+
+/*
  * Read a register from the Physical Layer device located
  * on the IPG NIC, using the IPG PHYCTRL register.
  */
 static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
+	u8 const polarity = ipg_r8(PHY_CTRL) &
+			(IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
+	unsigned i, data = 0;
 	/*
 	 * The GMII mangement frame structure for a read is as follows:
 	 *
@@ -218,78 +237,34 @@ static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
 	 * A = bit of Physical Layer device address (MSB first)
 	 * R = bit of register address (MSB first)
 	 * z = High impedance state
-	 * D = bit of read data (MSB first)
+	 * 0 = preamble bit sent by PHY
+	 * D = bit of read data (MSB first), sent by PHY
 	 *
 	 * Transmission order is 'Preamble' field first, bits transmitted
-	 * left to right (first to last).
+	 * left to right (msbit-first).
 	 */
-	struct {
-		u32 field;
-		unsigned int len;
-	} p[] = {
-		{ GMII_PREAMBLE,	32 },	/* Preamble */
-		{ GMII_ST,		2  },	/* ST */
-		{ GMII_READ,		2  },	/* OP */
-		{ phy_id,		5  },	/* PHYAD */
-		{ phy_reg,		5  },	/* REGAD */
-		{ 0x0000,		2  },	/* TA */
-		{ 0x0000,		16 },	/* DATA */
-		{ 0x0000,		1  }	/* IDLE */
-	};
-	unsigned int i, j;
-	u8 polarity, data;
-
-	polarity  = ipg_r8(PHY_CTRL);
-	polarity &= (IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
-
-	/* Create the Preamble, ST, OP, PHYAD, and REGAD field. */
-	for (j = 0; j < 5; j++) {
-		for (i = 0; i < p[j].len; i++) {
-			/* For each variable length field, the MSB must be
-			 * transmitted first. Rotate through the field bits,
-			 * starting with the MSB, and move each bit into the
-			 * the 1st (2^1) bit position (this is the bit position
-			 * corresponding to the MgmtData bit of the PhyCtrl
-			 * register for the IPG).
-			 *
-			 * Example: ST = 01;
-			 *
-			 *          First write a '0' to bit 1 of the PhyCtrl
-			 *          register, then write a '1' to bit 1 of the
-			 *          PhyCtrl register.
-			 *
-			 * To do this, right shift the MSB of ST by the value:
-			 * [field length - 1 - #ST bits already written]
-			 * then left shift this result by 1.
-			 */
-			data  = (p[j].field >> (p[j].len - 1 - i)) << 1;
-			data &= IPG_PC_MGMTDATA;
-			data |= polarity | IPG_PC_MGMTDIR;
-
-			ipg_drive_phy_ctl_low_high(ioaddr, data);
-		}
-	}
-
-	send_three_state(ioaddr, polarity);
-
-	read_phy_bit(ioaddr, polarity);
+	mdio_write_bits(ioaddr, polarity, GMII_PREAMBLE, 32);
+	mdio_write_bits(ioaddr, polarity, GMII_ST<<12 | GMII_READ << 10 |
+	                                  phy_id << 5 | phy_reg, 14);
 
 	/*
 	 * For a read cycle, the bits for the next two fields (TA and
 	 * DATA) are driven by the PHY (the IPG reads these bits).
 	 */
-	for (i = 0; i < p[6].len; i++) {
-		p[6].field |=
-		    (read_phy_bit(ioaddr, polarity) << (p[6].len - 1 - i));
-	}
+	send_three_state(ioaddr, polarity);	/* TA first bit */
+	(void)read_phy_bit(ioaddr, polarity);		/* TA second bit */
+
+	for (i = 0; i < 16; i++)
+		data = 2*data + read_phy_bit(ioaddr, polarity);
 
+	/* Trailing idle */
 	send_three_state(ioaddr, polarity);
 	send_three_state(ioaddr, polarity);
 	send_three_state(ioaddr, polarity);
 	send_end(ioaddr, polarity);
 
 	/* Return the value of the DATA field. */
-	return p[6].field;
+	return data;
 }
 
 /*
@@ -299,11 +274,13 @@ static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
 static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
+	u8 const polarity = ipg_r8(PHY_CTRL) &
+			(IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
 	/*
-	 * The GMII mangement frame structure for a read is as follows:
+	 * The GMII mangement frame structure for a write is as follows:
 	 *
 	 * |Preamble|st|op|phyad|regad|ta|      data      |idle|
-	 * |< 32 1s>|01|10|AAAAA|RRRRR|z0|DDDDDDDDDDDDDDDD|z   |
+	 * |< 32 1s>|01|01|AAAAA|RRRRR|10|DDDDDDDDDDDDDDDD|z   |
 	 *
 	 * <32 1s> = 32 consecutive logic 1 values
 	 * A = bit of Physical Layer device address (MSB first)
@@ -312,66 +289,17 @@ static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
 	 * D = bit of write data (MSB first)
 	 *
 	 * Transmission order is 'Preamble' field first, bits transmitted
-	 * left to right (first to last).
+	 * left to right (msbit-first).
 	 */
-	struct {
-		u32 field;
-		unsigned int len;
-	} p[] = {
-		{ GMII_PREAMBLE,	32 },	/* Preamble */
-		{ GMII_ST,		2  },	/* ST */
-		{ GMII_WRITE,		2  },	/* OP */
-		{ phy_id,		5  },	/* PHYAD */
-		{ phy_reg,		5  },	/* REGAD */
-		{ 0x0002,		2  },	/* TA */
-		{ val & 0xffff,		16 },	/* DATA */
-		{ 0x0000,		1  }	/* IDLE */
-	};
-	unsigned int i, j;
-	u8 polarity, data;
-
-	polarity  = ipg_r8(PHY_CTRL);
-	polarity &= (IPG_PC_DUPLEX_POLARITY | IPG_PC_LINK_POLARITY);
-
-	/* Create the Preamble, ST, OP, PHYAD, and REGAD field. */
-	for (j = 0; j < 7; j++) {
-		for (i = 0; i < p[j].len; i++) {
-			/* For each variable length field, the MSB must be
-			 * transmitted first. Rotate through the field bits,
-			 * starting with the MSB, and move each bit into the
-			 * the 1st (2^1) bit position (this is the bit position
-			 * corresponding to the MgmtData bit of the PhyCtrl
-			 * register for the IPG).
-			 *
-			 * Example: ST = 01;
-			 *
-			 *          First write a '0' to bit 1 of the PhyCtrl
-			 *          register, then write a '1' to bit 1 of the
-			 *          PhyCtrl register.
-			 *
-			 * To do this, right shift the MSB of ST by the value:
-			 * [field length - 1 - #ST bits already written]
-			 * then left shift this result by 1.
-			 */
-			data  = (p[j].field >> (p[j].len - 1 - i)) << 1;
-			data &= IPG_PC_MGMTDATA;
-			data |= polarity | IPG_PC_MGMTDIR;
-
-			ipg_drive_phy_ctl_low_high(ioaddr, data);
-		}
-	}
+	mdio_write_bits(ioaddr, polarity, GMII_PREAMBLE, 32);
+	mdio_write_bits(ioaddr, polarity, GMII_ST << 14 | GMII_WRITE << 12 |
+	                                  phy_id << 7 | phy_reg << 2 | 0x2, 16);
+	mdio_write_bits(ioaddr, polarity, val, 16);	/* DATA */
 
 	/* The last cycle is a tri-state, so read from the PHY. */
-	for (j = 7; j < 8; j++) {
-		for (i = 0; i < p[j].len; i++) {
-			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
-
-			p[j].field |= ((ipg_r8(PHY_CTRL) &
-				IPG_PC_MGMTDATA) >> 1) << (p[j].len - 1 - i);
-
-			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
-		}
-	}
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
+	(void)ipg_r8(PHY_CTRL);
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
 }
 
 /* Set LED_Mode JES20040127EEPROM */
@@ -379,18 +307,17 @@ static void ipg_set_led_mode(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->ioaddr;
-	u32 mode;
+	u32 mode = ipg_r32(ASIC_CTRL);
 
-	mode = ipg_r32(ASIC_CTRL);
 	mode &= ~(IPG_AC_LED_MODE_BIT_1 | IPG_AC_LED_MODE | IPG_AC_LED_SPEED);
 
-	if ((sp->LED_Mode & 0x03) > 1)
-		mode |= IPG_AC_LED_MODE_BIT_1;	/* Write Asic Control Bit 29 */
-
-	if ((sp->LED_Mode & 0x01) == 1)
+	if (sp->LED_Mode & 0x01)
 		mode |= IPG_AC_LED_MODE;	/* Write Asic Control Bit 14 */
 
-	if ((sp->LED_Mode & 0x08) == 8)
+	if (sp->LED_Mode & 0x02)
+		mode |= IPG_AC_LED_MODE_BIT_1;	/* Write Asic Control Bit 29 */
+
+	if (sp->LED_Mode & 0x08)
 		mode |= IPG_AC_LED_SPEED;	/* Write Asic Control Bit 27 */
 
 	ipg_w32(mode, ASIC_CTRL);
@@ -401,11 +328,13 @@ static void ipg_set_phy_set(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->ioaddr;
-	int physet;
+	u8 physet = ipg_r8(PHY_SET);
+	u8 newset = sp->LED_Mode >> 4;
 
-	physet = ipg_r8(PHY_SET);
-	physet &= ~(IPG_PS_MEM_LENB9B | IPG_PS_MEM_LEN9 | IPG_PS_NON_COMPDET);
-	physet |= ((sp->LED_Mode & 0x70) >> 4);
+	/* Change three bits of physet to values in newset */
+	newset ^= physet;
+	newset &= (IPG_PS_MEM_LENB9B | IPG_PS_MEM_LEN9 | IPG_PS_NON_COMPDET);
+	physet ^= newset;
 	ipg_w8(physet, PHY_SET);
 }
 
@@ -444,7 +373,7 @@ static int ipg_find_phyaddr(struct net_device *dev)
 	unsigned int phyaddr, i;
 
 	for (i = 0; i < 32; i++) {
-		u32 status;
+		unsigned status;
 
 		/* Search for the correct PHY address among 32 possible. */
 		phyaddr = (IPG_NIC_PHY_ADDRESS + i) % 32;
@@ -470,10 +399,7 @@ static int ipg_config_autoneg(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->ioaddr;
-	unsigned int txflowcontrol;
-	unsigned int rxflowcontrol;
-	unsigned int fullduplex;
-	unsigned int gig;
+	bool txflowcontrol, rxflowcontrol, fullduplex, gig;
 	u32 mac_ctrl_val;
 	u32 asicctrl;
 	u8 phyctrl;
@@ -487,10 +413,10 @@ static int ipg_config_autoneg(struct net_device *dev)
 	/* Set flags for use in resolving auto-negotation, assuming
 	 * non-1000Mbps, half duplex, no flow control.
 	 */
-	fullduplex = 0;
-	txflowcontrol = 0;
-	rxflowcontrol = 0;
-	gig = 0;
+	fullduplex = false;
+	txflowcontrol = false;
+	rxflowcontrol = false;
+	gig = false;
 
 	/* To accomodate a problem in 10Mbps operation,
 	 * set a global flag if PHY running in 10Mbps mode.
@@ -512,7 +438,7 @@ static int ipg_config_autoneg(struct net_device *dev)
 		break;
 	case IPG_PC_LINK_SPEED_1000MBPS:
 		printk("1000Mbps.\n");
-		gig = 1;
+		gig = true;
 		break;
 	default:
 		printk("undefined!\n");
@@ -520,19 +446,20 @@ static int ipg_config_autoneg(struct net_device *dev)
 	}
 
 	if (phyctrl & IPG_PC_DUPLEX_STATUS) {
-		fullduplex = 1;
-		txflowcontrol = 1;
-		rxflowcontrol = 1;
+		fullduplex = true;
+		txflowcontrol = true;
+		rxflowcontrol = true;
 	}
 
 	/* Configure full duplex, and flow control. */
-	if (fullduplex == 1) {
+	if (fullduplex) {
 		/* Configure IPG for full duplex operation. */
 		printk(KERN_INFO "%s: setting full duplex, ", dev->name);
 
 		mac_ctrl_val |= IPG_MC_DUPLEX_SELECT_FD;
 
-		if (txflowcontrol == 1) {
+		/* FIXME: Does this variable always equal fullduplex? */
+		if (txflowcontrol) {
 			printk("TX flow control");
 			mac_ctrl_val |= IPG_MC_TX_FLOW_CONTROL_ENABLE;
 		} else {
@@ -540,7 +467,7 @@ static int ipg_config_autoneg(struct net_device *dev)
 			mac_ctrl_val &= ~IPG_MC_TX_FLOW_CONTROL_ENABLE;
 		}
 
-		if (rxflowcontrol == 1) {
+		if (rxflowcontrol) {
 			printk(", RX flow control.");
 			mac_ctrl_val |= IPG_MC_RX_FLOW_CONTROL_ENABLE;
 		} else {
@@ -568,9 +495,8 @@ static int ipg_config_autoneg(struct net_device *dev)
 static void ipg_nic_set_multicast_list(struct net_device *dev)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
-	struct dev_mc_list *mc_list_ptr;
-	unsigned int hashindex;
-	u32 hashtable[2];
+	struct dev_mc_list *mc;
+	u32 hashtable[2] = { 0, 0 };
 	u8 receivemode;
 
 	IPG_DEBUG_MSG("_nic_set_multicast_list\n");
@@ -581,52 +507,34 @@ static void ipg_nic_set_multicast_list(struct net_device *dev)
 		/* NIC to be configured in promiscuous mode. */
 		receivemode = IPG_RM_RECEIVEALLFRAMES;
 	} else if ((dev->flags & IFF_ALLMULTI) ||
-		   (dev->flags & IFF_MULTICAST &
-		    (dev->mc_count > IPG_MULTICAST_HASHTABLE_SIZE))) {
+		   (dev->flags & IFF_MULTICAST &&
+		    (dev->mc_count > 2*IPG_MULTICAST_HASHTABLE_SIZE))) {
 		/* NIC to be configured to receive all multicast
 		 * frames. */
 		receivemode |= IPG_RM_RECEIVEMULTICAST;
-	} else if (dev->flags & IFF_MULTICAST & (dev->mc_count > 0)) {
+	} else if (dev->flags & IFF_MULTICAST && (dev->mc_count > 0)) {
 		/* NIC to be configured to receive selected
 		 * multicast addresses. */
 		receivemode |= IPG_RM_RECEIVEMULTICASTHASH;
-	}
-
-	/* Calculate the bits to set for the 64 bit, IPG HASHTABLE.
-	 * The IPG applies a cyclic-redundancy-check (the same CRC
-	 * used to calculate the frame data FCS) to the destination
-	 * address all incoming multicast frames whose destination
-	 * address has the multicast bit set. The least significant
-	 * 6 bits of the CRC result are used as an addressing index
-	 * into the hash table. If the value of the bit addressed by
-	 * this index is a 1, the frame is passed to the host system.
-	 */
-
-	/* Clear hashtable. */
-	hashtable[0] = 0x00000000;
-	hashtable[1] = 0x00000000;
-
-	/* Cycle through all multicast addresses to filter. */
-	for (mc_list_ptr = dev->mc_list;
-	     mc_list_ptr != NULL; mc_list_ptr = mc_list_ptr->next) {
-		/* Calculate CRC result for each multicast address. */
-		hashindex = crc32_le(0xffffffff, mc_list_ptr->dmi_addr,
-				     ETH_ALEN);
 
-		/* Use only the least significant 6 bits. */
-		hashindex = hashindex & 0x3F;
-
-		/* Within "hashtable", set bit number "hashindex"
-		 * to a logic 1.
+		/*
+		 * The IPG uses the standard hash table technique to filter
+		 * incoming multicast packets.  It computes the CRC of the
+		 * incoming MAC address, and uses the low 6 bits of the
+		 * result to select a hash table bit.  If set (and the address
+		 * is a multicast address), the packet is received.
 		 */
-		set_bit(hashindex, (void *)hashtable);
-	}
+		for (mc = dev->mc_list; mc; mv = mc->next) {
+			/* Calculate CRC result for each multicast address. */
+			u32 hashindex = crc32_le(0xffffffff, mc->dmi_addr,
+					ETH_ALEN);
 
-	/* Write the value of the hashtable, to the 4, 16 bit
-	 * HASHTABLE IPG registers.
-	 */
-	ipg_w32(hashtable[0], HASHTABLE_0);
-	ipg_w32(hashtable[1], HASHTABLE_1);
+			/* Use low 6 bits to select hash table bit */
+			set_bit(hashindex & 63, (void *)hashtable);
+		}
+		ipg_w32(hashtable[0], HASHTABLE_0);
+		ipg_w32(hashtable[1], HASHTABLE_1);
+	}
 
 	ipg_w8(IPG_RM_RSVD_MASK & receivemode, RECEIVE_MODE);
 

