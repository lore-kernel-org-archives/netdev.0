From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/4] net: dsa: add new DSA switch driver for the
 SMSC-LAN9303
Date: Thu, 6 Apr 2017 13:59:00 +0200
Message-ID: <20170406115900.GA13219@lunn.ch>
References: <20170405092024.16048-1-jbe@pengutronix.de>
 <20170405092024.16048-3-jbe@pengutronix.de>
 <20170405181232.GE21965@lunn.ch>
 <201704061218.57438.jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel@pengutronix.de, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47534 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753424AbdDFL7L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 07:59:11 -0400
Content-Disposition: inline
In-Reply-To: <201704061218.57438.jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > +static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
> > > +			          u16 val) 
> > > +{
> > > +	struct lan9303 *chip = ds_to_lan9303(ds);
> > > +	int phy_base = chip->phy_addr_sel_strap;
> > > +
> > > +	if (phy == phy_base)
> > > +		return lan9303_virt_phy_reg_write(chip, regnum, val);
> > > +	if (phy > phy_base + 2)
> > > +		return -ENODEV;
> > > +
> > > +	return lan9303_phy_reg_write(chip, phy, regnum, val);
> >
> > Does the MDIO bus go to the outside world? Could there be external
> > PHYs?
> 
> ???? This device includes two phys (at port 1 and 2) and these functions are
> called to detect their state.

Some switches have the MDIO bus available on pins. It is then possible
to connect additional PHYs on the MDIO bus. If their is an external
MDIO bus, you should remove the test for phy > phy_base + 2, and allow
the full range of 32. 

> > > +static void lan9303_port_disable(struct dsa_switch *ds, int port,
> > > +				 struct phy_device *phy)
> > > +{
> > > +	struct lan9303 *chip = ds_to_lan9303(ds);
> > > +	int rc;
> > > +
> > > +	/* disable internal data handling */
> > > +	switch (port) {
> > > +	case 1:
> > > +		rc = lan9303_phy_reg_write(chip, chip->phy_addr_sel_strap + 1,
> > > +					   0, BIT(14) | BIT(11));
> > > +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_1,
> > > +					       0x02);
> > > +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_1,
> > > +					       0x56);
> >
> > It seems odd that port_enable does not touch the PHY, but port_disable
> > does. What is this doing?
> 
> My experience is, the framework powers up the phys by its own in conjunction
> with calling lan9303_port_enable(), but do not power down them in conjunction
> with calling lan9303_port_disable(). In v2 I do not touch the phy anymore.

So this is touching the BMCR_PDOWN bit? Using the #define would of
helped explain this.

       Andrew
