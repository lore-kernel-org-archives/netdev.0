From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 5/5] net: phy: add Marvell Alaska X 88X3310 10Gigabit PHY
 support
Date: Thu, 1 Jun 2017 18:57:13 +0100
Message-ID: <20170601175712.GG22219@n2100.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJc-000442-8H@rmk-PC.armlinux.org.uk>
 <ddf5b409-43fb-5045-ebfc-9a20d1ca1aec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:58326 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdFAR5W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 13:57:22 -0400
Content-Disposition: inline
In-Reply-To: <ddf5b409-43fb-5045-ebfc-9a20d1ca1aec@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 10:28:04AM -0700, Florian Fainelli wrote:
> On 06/01/2017 03:26 AM, Russell King wrote:
> > Add phylib support for the Marvell Alaska X 10 Gigabit PHY (MV88X3310).
> > This phy is able to operate at 10G, 1G, 100M and 10M speeds, and only
> > supports Clause 45 accesses.
> > 
> > The PHY appears (based on the vendor IDs) to be two different vendors
> > IP, with each devad containing several instances.
> > 
> > This PHY driver has only been tested with the RJ45 copper port, fiber
> > port and a Marvell Armada 8040-based ethernet interface.
> > 
> > It should be noted that to use the full range of speeds, MAC drivers
> > need to also reconfigure the link mode as per phydev->interface, since
> > the PHY automatically changes its interface mode depending on the
> > negotiated speed.
> > 
> > Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> > ---
> 
> >  MARVELL MVNETA ETHERNET DRIVER
> >  M:	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> >  L:	netdev@vger.kernel.org
> > diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> > index 19eddf758c88..905990fece28 100644
> > --- a/drivers/net/phy/Makefile
> > +++ b/drivers/net/phy/Makefile
> > @@ -55,7 +55,7 @@ obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
> >  obj-$(CONFIG_INTEL_XWAY_PHY)	+= intel-xway.o
> >  obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
> >  obj-$(CONFIG_LXT_PHY)		+= lxt.o
> > -obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
> > +obj-$(CONFIG_MARVELL_PHY)	+= marvell.o marvell10g.o
> 
> Could we introduce a CONFIG_MARVELL_10G_PHY symbol?

Thanks, I'll do that.

> > +enum {
> > +	MV_PCS_BASE_T		= 0x0000,
> > +	MV_PCS_BASE_R		= 0x1000,
> > +	MV_PCS_1000BASEX	= 0x2000,
> > +
> > +	/* These registers appear at 0x800X and 0xa00X - the 0xa00X control
> > +	 * registers appear to set themselves to the 0x800X when AN is
> > +	 * restarted, but status registers appear readable from either.
> > +	 */
> > +	MV_AN_CTRL1000		= 0x8000, /* 1000base-T control register */
> > +	MV_AN_STAT1000		= 0x8001, /* 1000base-T status register */
> > +
> > +	/* This register appears to reflect the copper status */
> > +	MV_AN_RESULT		= 0xa016,
> > +	MV_AN_RESULT_SPD_10	= BIT(12),
> > +	MV_AN_RESULT_SPD_100	= BIT(13),
> > +	MV_AN_RESULT_SPD_1000	= BIT(14),
> > +	MV_AN_RESULT_SPD_10000	= BIT(15),
> > +};
> 
> Personal preference is not to use enums but jut plain #define, but
> whatever works, really.

I've come to prefer them as it avoids hiding them from the compiler
itself.

> > +
> > +static int mv3310_soft_reset(struct phy_device *phydev)
> > +{
> > +	return 0;
> > +}
> 
> You could use genphy_no_soft_reset(), although genphy sort of implies
> C22 now, or we could export genphy10g_soft_reset() which also does nothing.

The reason 88x3310 has no reset function is that setting the reset bit
appears to cause the PHY to become completely inaccessible over MDIO.
I'll add a comment here to that effect - but that would need the function
to remain here, otherwise the comment is rather lost amongst the code.

> > +	/* Ethtool does not support the WAN mode bits */
> > +	if (val & (MDIO_PMA_STAT2_10GBSR | MDIO_PMA_STAT2_10GBLR |
> > +		   MDIO_PMA_STAT2_10GBER | MDIO_PMA_STAT2_10GBLX4 |
> > +		   MDIO_PMA_STAT2_10GBSW | MDIO_PMA_STAT2_10GBLW |
> > +		   MDIO_PMA_STAT2_10GBEW))
> > +		__set_bit(ETHTOOL_LINK_MODE_FIBRE_BIT, supported);
> > +	if (val & MDIO_PMA_STAT2_10GBSR)
> > +		__set_bit(ETHTOOL_LINK_MODE_10000baseSR_Full_BIT, supported);
> > +	if (val & MDIO_PMA_STAT2_10GBLR)
> > +		__set_bit(ETHTOOL_LINK_MODE_10000baseLR_Full_BIT, supported);
> > +	if (val & MDIO_PMA_STAT2_10GBER)
> > +		__set_bit(ETHTOOL_LINK_MODE_10000baseER_Full_BIT, supported);
> > +
> > +	if (val & MDIO_PMA_STAT2_EXTABLE) {
> > +		val = phy_read_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_EXTABLE);
> > +		if (val < 0)
> > +			return val;
> > +
> > +		if (val & (MDIO_PMA_EXTABLE_10GBT | MDIO_PMA_EXTABLE_1000BT |
> > +			   MDIO_PMA_EXTABLE_100BTX | MDIO_PMA_EXTABLE_10BT))
> > +			__set_bit(ETHTOOL_LINK_MODE_TP_BIT, supported);
> > +		if (val & MDIO_PMA_EXTABLE_10GBLRM)
> > +			__set_bit(ETHTOOL_LINK_MODE_FIBRE_BIT, supported);
> > +		if (val & (MDIO_PMA_EXTABLE_10GBKX4 | MDIO_PMA_EXTABLE_10GBKR |
> > +			   MDIO_PMA_EXTABLE_1000BKX))
> > +			__set_bit(ETHTOOL_LINK_MODE_Backplane_BIT, supported);
> > +		if (val & MDIO_PMA_EXTABLE_10GBLRM)
> > +			__set_bit(ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT,
> > +				  supported);
> > +		if (val & MDIO_PMA_EXTABLE_10GBT)
> > +			__set_bit(ETHTOOL_LINK_MODE_10000baseT_Full_BIT,
> > +				  supported);
> > +		if (val & MDIO_PMA_EXTABLE_10GBKX4)
> > +			__set_bit(ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT,
> > +				  supported);
> > +		if (val & MDIO_PMA_EXTABLE_10GBKR)
> > +			__set_bit(ETHTOOL_LINK_MODE_10000baseKR_Full_BIT,
> > +				  supported);
> > +		if (val & MDIO_PMA_EXTABLE_1000BT)
> > +			__set_bit(ETHTOOL_LINK_MODE_1000baseT_Full_BIT,
> > +				  supported);
> > +		if (val & MDIO_PMA_EXTABLE_1000BKX)
> > +			__set_bit(ETHTOOL_LINK_MODE_1000baseKX_Full_BIT,
> > +				  supported);
> > +		if (val & MDIO_PMA_EXTABLE_100BTX)
> > +			__set_bit(ETHTOOL_LINK_MODE_100baseT_Full_BIT,
> > +				  supported);
> > +		if (val & MDIO_PMA_EXTABLE_10BT)
> > +			__set_bit(ETHTOOL_LINK_MODE_10baseT_Full_BIT,
> > +				  supported);
> > +	}
> > +
> > +	if (!ethtool_convert_link_mode_to_legacy_u32(&mask, supported))
> > +		dev_warn(&phydev->mdio.dev,
> > +			 "PHY supports (%*pb) more modes than phylib supports, some modes not supported.\n",
> > +			 __ETHTOOL_LINK_MODE_MASK_NBITS, supported);
> > +
> > +	phydev->supported &= mask;
> > +	phydev->advertising &= phydev->supported;
> 
> Is not this a candidate for being moved into drivers/net/phy/phy-10g.c?
> Past the phy interface mode check, the rest does not appear to be
> particularly Marvell specific here.

I'm not entirely sure.  This is decoding what the PMA/PMD supports,
which may not be solely appropriate for a generic case.  Clause 45
is full of different blocks, each advertising their own capabilities.
(Eg, see the highly modified mii-diag output below.)  The blocks
that are in use for the copper connection shown are the first PMA 0:1,
first PCS 0:3, second PHYXS 0:4, first AN 0:7 (for copper side) and
third AN (for MAC facing side).

Eg, the PCS says it supports 10GbaseR, 10GbaseX and 40GbaseR, but
the PMA says it doesn't support any 40G modes.

So, I wouldn't like to push code into a generic file which isn't the
correct approach.

Does anyone have a view on how Clause 45 PHYs should be handled wrt
what ethtool modes they support?  Do we (eg) need to scan all
implemented MMDs and come up with a common subset of features?


mii-diag.c:v2.11 3/21/2005 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
  Using the new SIOCGMIIPHY value on PHY 8 (BMCR 0x2040).
Using the specified MII PHY index 32768.
  No MII transceiver present!.
  Use '--force' to view the information anyway.
libmii.c:v2.11 2/28/2005  Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html

 MII PHY #0:1 transceiver registers:
   2040 0006 002b 09aa 0071 009a c000 0009
   9301 0000 0000 01a4 0000 0000 002b 09aa
   0000 0000 0000 0000 0000 0003 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:0a:c2:--:--:--, model 26 rev. 10.
   Vendor/Part: Marvell Semiconductor 88x3310.
 PMA/PMD Control 1 register 2040: Speed determined by auto-negotiation.
 PMA/PMD Status register 0006 ... 0006.
   Receive link status: established.
 PMA/PMD Speed capability 0071: 10G, 100M, 10M, 10G/1G, 10G.
 PMA/PMD Control 2 register 0009: Type determined by auto-negotiation.
 PMA/PMD Status 2 register 9301 ... 9301
   Abilities: Local loopback, Transmit disable, Receive fault.
 PMA/PMD Extended Ability register 01a4
   Abilities: 10GBASE-T, 1000BASE-T, 100BASE-TX, 10BASE-T.
 Pair swap 0003: MDI no crossover, A normal, B normal, C normal, D normal.
 TX backoff b400: LP TX backoff 10dB TX backoff 10dB.
 Operating SNR: A:   7.8dB  B:   2.2dB  C:   4.5dB  D:   4.4dB.
 Minimum SNR  : A:   7.8dB  B:   2.2dB  C:   4.5dB  D:   4.4dB.
 Skew A>B -75.00ns A>C -80.00ns A>D -80.00ns
 Fast retrain 0012.

 MII PHY #0:3 transceiver registers:
   2040 0006 002b 09aa 0001 009a c000 0003
   8008 0000 0000 0000 0000 0000 002b 09aa
   0000 0000 0000 0000 000e 0003 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   1001 8000 0000 0000 0000 0000 0000 0000
   0000 0be3 0b83 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:0a:c2:--:--:--, model 26 rev. 10.
   Vendor/Part: Marvell Semiconductor 88x3310.
 PCS Control 1 register 2040: Speed 10Gb/s.
 PCS Status register 0006 ... 0006.
   Receive link status: established.
 PCS Speed capability 0001: 10G.
 PCS Control 2 register 0003: Type 10GBASE-T.
 PCS Status 2 register 8008 ... 8008
   Abilities: 10GBASE-T.
 PCS BASE-R or 10GBASE-T status 1001 8000
   PCS receive link up
   Block lock
   Block lock (latched).

 MII PHY #0:3 Subdevice #2 transceiver registers
   2040 0082 002b 09aa 0005 009e c000 0000
   8c13 0000 0000 0000 0000 0000 002b 09aa
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   000c 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:0a:c2:--:--:--, model 26 rev. 10.
   Vendor/Part: Marvell Semiconductor 88x3310.
 PCS Control 1 register 2040: Speed 10Gb/s.
 PCS Status register 0082 ... 0082.
   Receive link status: not established.
   *Fault condition detected*
 PCS Speed capability 0005: 10G, 40G.
 PCS Control 2 register 0000: Type 10GBASE-R.
 PCS Status 2 register 8c13 ... 8c13
   Abilities: 10GBASE-R, 10GBASE-X, 40GBASE-R.
   *Transmit fault reported*.
   *Receive fault reported*.
 PCS BASE-R or 10GBASE-T status 000c 0000
   PRBS9 pattern testing
   PRBS31 pattern testing.

 MII PHY #0:3 Subdevice #3 transceiver registers
   1140 0149 0141 0daa 0020 0000 0004 2001
   0000 0000 0000 0000 0000 0000 0000 8000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   000c 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:50:43:--:--:--, model 26 rev. 10.
   Vendor/Part: Marvell Semiconductor 88x3310.
 Basic mode control register 1140: Auto-negotiation enabled.
 Basic mode status register 0149 ... 0149.
   With extended status register 8000.
   Link status: not established.
   Capable of 1000baseX-FD.
   Able to perform Auto-negotiation, negotiation not complete.
 I'm advertising 0020: 1000baseX-FD.

 MII PHY #0:4 transceiver registers:
   2040 0082 0141 0daa 0001 001a 4000 0001
   8403 0000 0000 0000 0000 0000 0141 0daa
   0000 0000 0000 0000 0000 0000 0000 0000
   0c00 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:50:43:--:--:--, model 26 rev. 10.
   Vendor/Part: Marvell Semiconductor 88x3310.
 PHYXS Control 1 register 2040: Speed 10Gb/s.
 PHYXS Status register 0082 ... 0082.
   Receive link status: not established.
   *Fault condition detected*
 PHYXS Speed capability 0001: 10G.

 MII PHY #0:4 Subdevice #2 transceiver registers
   2040 0006 002b 09aa 0005 009e c000 0000
   8013 0000 0000 0000 0000 0000 002b 09aa
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   100d 8000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:0a:c2:--:--:--, model 26 rev. 10.
   Vendor/Part: Marvell Semiconductor 88x3310.
 PHYXS Control 1 register 2040: Speed 10Gb/s.
 PHYXS Status register 0006 ... 0006.
   Receive link status: established.
 PHYXS Speed capability 0005: 10G.

 MII PHY #0:4 Subdevice #3 transceiver registers
   1140 0149 0141 0daa 0020 0000 0004 2001
   0000 0000 0000 0000 0000 0000 0000 8000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:50:43:--:--:--, model 26 rev. 10.
   Vendor/Part: Marvell Semiconductor 88x3310.
 Basic mode control register 1140: Auto-negotiation enabled.
 Basic mode status register 0149 ... 0149.
   With extended status register 8000.
   Link status: not established.
   Capable of 1000baseX-FD.
   Able to perform Auto-negotiation, negotiation not complete.
 SGMII Link status 0020: Link down, reserved bits are set
 SGMII MAC acknowledgement 0000: 

 MII PHY #0:7 transceiver registers:
   3000 00ad 002b 09aa 0000 009a c000 0000
   0000 0000 0000 0000 0000 0000 002b 09aa
   1d41 0000 0000 dd41 0000 0000 2001 0000
   0000 4c00 0003 0000 0000 0000 0000 0000
   1181 7c60 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:0a:c2:--:--:--, model 26 rev. 10.
   Vendor/Part: Marvell Semiconductor 88x3310.
 AN Control 1 register 3000.
 AN Status register 00ad ... 00ad.
   Link status: established.
   Able to perform Auto-negotiation, negotiation complete.
   LP Auto-negotiation, Ext Next Pg.
 I'm advertising 1d41 1181.
   10Gbase-T AsymPause Pause 100baseTx-FD 10baseT-FD 
   I'm part of a single-port device.
   LD loop timing.
   Advertising no additional info pages.
   IEEE 802.3 CSMA/CD protocol.
 Link partner advertisment is dd41.
   Advertising AsymPause Pause 100baseTx-FD 10baseT-FD.
   Negotiation completed.
 XNP advert is 2001: message page 1
 XNP link partner is 4c00: unformatted code 400
 10GBASE-T status 7c60: Local PHY master LP 10GBASE-T LP loop timing.

 MII PHY #0:7 Subdevice #2 transceiver registers
   0000 000c 0141 0d90 0000 009e c000 0000
   0000 0000 0000 0000 0000 0000 0141 0d90
   0001 008d 0000 0000 0000 0000 2001 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0009 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:50:43:--:--:--, model 25 rev. 0.
   Vendor/Part: Marvell Semiconductor (unknown).
 AN Control 1 register 0000.
 AN Status register 000c ... 000c.
   Link status: established.
   Able to perform Auto-negotiation, negotiation not complete.
 I'm advertising 0000008d0001.
   Advertising 10GBASE-KR.
   IEEE 802.3 CSMA/CD protocol.
 BASE-R Status: 10GBASE-KR.

 MII PHY #0:7 Subdevice #3 transceiver registers
   3000 00ad 0141 0c00 0000 008a 0000 0000
   0000 0000 0000 0000 0000 0000 0141 0c00
   1d41 0000 0000 dd41 0000 0000 2001 0000
   0000 4c00 0003 0000 0000 0000 0000 0000
   1181 4c60 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Vendor ID is 00:50:43:--:--:--, model 0 rev. 0.
   Vendor/Part: Marvell Semiconductor (unknown).
 AN Control 1 register 3000.
 AN Status register 00ad ... 00ad.
   Link status: established.
   Able to perform Auto-negotiation, negotiation complete.
   LP Auto-negotiation, Ext Next Pg.
 I'm advertising 1d41 1181.
   10Gbase-T AsymPause Pause 100baseTx-FD 10baseT-FD 
   I'm part of a single-port device.
   LD loop timing.
   Advertising no additional info pages.
   IEEE 802.3 CSMA/CD protocol.
 Link partner advertisment is dd41.
   Advertising AsymPause Pause 100baseTx-FD 10baseT-FD.
   Negotiation completed.
 XNP advert is 2001: message page 1
 XNP link partner is 4c00: unformatted code 400
 10GBASE-T status 4c60: Local PHY master Local RX not ok Remote RX not ok LP 10GBASE-T LP loop timing.

 Other registers
  8000: 0210 0b00 7973 0000 0404 0000 0000 800c
  8008: 0000 1000 0000 0000 0101 2909 0000 0077

  9000: 0010 014a 0000 0000 0000 0000 0000 0000
  9008: 0000 0000 0000 0002 0001 0000 0000 0000

  9800: 0010 014a 0000 0000 0000 0000 0000 0000
  9808: 0000 0000 0000 0002 0001 0000 0000 0000

  a000: 0210 0b00 7973 0000 0404 0000 0000 800c
  a008: 0000 1000 0000 0000 0101 2909 2000 0010
  a010: 0010 0000 0000 0000 0000 0000 8056 e009
  a018: 402c 1803 0000 0000 0000 0000 0000 0000
  a020: a400 0000 0000 0521 0200 0001 8521 0200
  a028: 2901 8415 e02c 8000 1000 0000 0000 0000
  a030: 073e 00fa 0000 0000 0000 0000 0000 0000

This produces:

root@mcbin:~# /shared/git/ethtool/build-arm64/ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Full
                                100baseT/Full
                                1000baseT/Full
                                10000baseT/Full
        Supported pause frame use: Symmetric Receive-only
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Full
                                100baseT/Full
                                1000baseT/Full
                                10000baseT/Full
        Advertised pause frame use: Symmetric Receive-only
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Full
                                             100baseT/Full
                                             1000baseT/Full
                                             10000baseT/Full
        Link partner advertised pause frame use: Symmetric Receive-only
        Link partner advertised auto-negotiation: Yes
        Speed: 10000Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Link detected: yes

Note the lack of fiber modes - the PMA doesn't appear to be used for
fiber, and indicates that it doesn't support fiber.

So, with all this uncertainty, I'd rather not push the above block of
code as a generic helper just yet - at least not until we see more
10G PHYs, so we can get an idea of the correct direction for this.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
