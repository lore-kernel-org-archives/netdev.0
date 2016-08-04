From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: Microsemi VSC 8531/41 PHY Driver
Date: Thu, 4 Aug 2016 15:01:27 +0530
Message-ID: <20160804093125.GA3827@microsemi.com>
References: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
 <20160726115556.GC11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A145329E97@avsrvexchmbx1.microsemi.net>
 <20160726124347.GD11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A14532A1E3@avsrvexchmbx1.microsemi.net>
 <ed7f291d-200f-0ba3-953d-cc4abf53b8c1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Lunn <andrew@lunn.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0081.outbound.protection.outlook.com ([104.47.32.81]:51736
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754860AbcHDJsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 05:48:04 -0400
Content-Disposition: inline
In-Reply-To: <ed7f291d-200f-0ba3-953d-cc4abf53b8c1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2016 at 10:35:05AM -0700, Florian Fainelli wrote:
> EXTERNAL EMAIL
> 
> 
> On 07/27/2016 11:44 PM, Raju Lakkaraju wrote:
> > Hello Andrew,
> >
> > Thank you for given valuable comments.
> > Please see the my responses inline.
> >
> > Thanks,
> > Raju
> >
> > -----Original Message-----
> > From: Andrew Lunn [mailto:andrew@lunn.ch]
> > Sent: Tuesday, July 26, 2016 6:14 PM
> > To: Raju Lakkaraju
> > Cc: netdev@vger.kernel.org; f.fainelli@gmail.com; Allan Nielsen
> > Subject: Re: Microsemi VSC 8531/41 PHY Driver
> >
> > EXTERNAL EMAIL
> >
> >
> >> +/* RGMII Rx Clock delay value change with board lay-out */ static u8
> >> +rgmii_rx_clk_delay = RGMII_RX_CLK_DELAY_1_1_NS;
> >
> > Doesn't this stop you from having a board with two PHYs with different layouts? You should be getting this value from the device tree.
> >
> > Raju: As of now, RGMII Rx clock delay value should be 1.1 nsec as optimized/recommended value.
> > We tested on Beaglebone Black with VSC 8531 PHY.
> 
> That is true, until the next design with a PHY that does not need this
> value and then, it will have to be adjusted.
> 

I accepted your review comment. I do hard code it as the default value.

> > We would like to provide new function to configure correct/require value based on PHY layouts
> > alone with other RGMII configuration parameters as part of our next implementation.
> 
> You can either introduce a Device Tree property to allow boards to
> specify what the correct delay(s) should be, or if the platform does not
> use Device Tree, using phy_register_fixup_for_id would be acceptable for
> that.
> 

I do hard code this value as the default value.

> >
> >> +     phydev->supported = (SUPPORTED_1000baseT_Full |
> >> +                          SUPPORTED_1000baseT_Half |
> >> +                          SUPPORTED_100baseT_Full  |
> >> +                          SUPPORTED_100baseT_Half  |
> >> +                          SUPPORTED_10baseT_Full   |
> >> +                          SUPPORTED_10baseT_Half   |
> >> +                          SUPPORTED_Autoneg        |
> >> +                          SUPPORTED_Pause          |
> >> +                          SUPPORTED_Asym_Pause     |
> >> +                          SUPPORTED_TP);
> 
> This is not necessary, your driver should advertise what the PHY is
> capable of in phy_driver::features. The Ethernet MAC driver later should
> be adjusting phydev->supported with what it actually support, there are
> cases where you connect a 10/100Mbits MAC to a 1Gbits PHY, and you want
> to properly restrict unsupported speeds.
> 

I accepted your reveiw comment. I delete initialization.

> >> +
> >> +     phydev->speed = SPEED_1000;
> >> +     phydev->duplex = DUPLEX_FULL;
> >> +     phydev->pause = 0;
> >> +     phydev->asym_pause = 0;
> >> +     phydev->interface = PHY_INTERFACE_MODE_RGMII;
> >> +     phydev->mdix = ETH_TP_MDI_AUTO;
> >
> > Why are you setting all these? This is not normal, if you look at other drivers.
> >
> > Raju: I would like to update the default values in software data structure (phydev).
> > Our PHY is 1G speed support device and RGMII supported device.
> 
> Whether RGMII is used as an interface/connection type between the MAC
> and PHY is something that is within the consumer of the PHYLIB API
> (typically Ethernet MAC/Switch driver), your PHY cannot enforce
> anything, but the driver can check that the connection interface is sensble.
> 
> All of these default values that you are setting here will need to be
> potentially changed by the state machine (link, duplex, pause) upon
> reaction to link state changes, this change needs to be dropped.
> 

I accepted your reveiw comment. I delete initialization.

> >
> >> +
> >> +     mutex_lock(&phydev->lock);
> >
> > What are you locking against?
> >
> > Raju: VSC 8531 has different PAGEs. Whenever MDC/MDIO access the PHY control registers,
> > first set the page number then read/write the register address. Default page should be Page 0.
> > When I want to access not default page register, I have to lock phy device access and change
> > the page number and register access as atomic operation.
> 
> Based on the execution context of this function, acquiring the mutex is
> not necessary, the state machine has not started yet, so there cannot be
> a conflicting PHY read which would end up changing the page selection.
> 
> [snip]
> 

This is Read Modify Write (RMW) operation on register MSCC_PHY_RGMII_CNTL. This register in different page i.e. EXTENDED-2. I would like to execute all these operations in atomic operation.

> >> +
> >> +static int vsc85xx_ack_interrupt(struct phy_device *phydev) {
> >> +     int rc = 0;
> >> +
> >> +     if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
> >> +             rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
> >> +
> >> +     return (rc < 0) ? rc : 0;
> >> +}
> >> +
> >> +static int vsc85xx_config_intr(struct phy_device *phydev) {
> >> +     int rc;
> >> +
> >> +     if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
> >> +             rc = phy_write(phydev, MII_VSC85XX_INT_MASK,
> >> +                            MII_VSC85XX_INT_MASK_MASK);
> >> +     } else {
> >> +             rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
> >> +             if (rc < 0)
> >> +                     return rc;
> >
> > And the purpose of this read is? I assume it clears an outstanding interrupt? If so, shouldn't you do it after disabling interrupts, not before? Otherwise you have a race condition.
> >
> > Raju: The Interrupt status register is read on clean. When, PHY_INTERRUPT_DISABLE case,
> > I should make sure that status should be clear. If I read the Interrupt status registers, it clears all preexisting interrupts.
> 
> Should not you clear the interrupt status irrespective of whether PHY
> interrupts will be enabled or not as a first operation? Then later on,
> if the PHY needs to enable interrupt or not, this can be based on
> PHY_INTERRUPT_ENABLED.

In PHY_INTERRUPT_DISABLE case, after disable the interrupts, I would like to clear the interrupt status.

> --
> Florian
