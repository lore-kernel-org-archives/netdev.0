From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH 2/3 v2] net: phy: DP83822 initial driver submission
Date: Thu, 5 Oct 2017 22:16:25 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B415DE@CHN-SV-EXMX02.mchp-main.com>
References: <20171004182031.13794-1-dmurphy@ti.com>
 <20171004182031.13794-2-dmurphy@ti.com>
 <9235D6609DB808459E95D78E17F2E43D40B3F9A9@CHN-SV-EXMX02.mchp-main.com>
 <20171004235307.GD16612@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <dmurphy@ti.com>, <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <afd@ti.com>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:20385 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751369AbdJEWQ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 18:16:26 -0400
In-Reply-To: <20171004235307.GD16612@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > +static int dp83822_suspend(struct phy_device *phydev)
> > > +{
> > > +	int value;
> > > +
> > > +	mutex_lock(&phydev->lock);
> > > +	value = phy_read_mmd(phydev, DP83822_DEVADDR,
> > > MII_DP83822_WOL_CFG);
> > > +	mutex_unlock(&phydev->lock);
> 
> > Would we need mutex to access phy_read_mmd()?
> > phy_read_mmd() has mdio_lock for indirect access.
> 
> Hi Woojung
> 
> The mdio lock is not sufficient. It protects against two mdio
> accesses. But here we need to protect against two phy operations.
> There is a danger something else tries to access the phy during
> suspend.

Hi Andrew,

Thanks for comment. I have question then.
phy_read_mmd() is protected by bus->mdio_lock around mmd_indirect & mdio_read.
While these operation, other phy_read() & phy_write() will be blocked inside
mdiobus_read() & mdiobus_write().

Because this phy_read_mmd(.., DP83822_DEVADDR, MII_DP83822_WOL_CFG) is not 
read-modify-write operation, I think phydev->lock may not be necessary.

Am I missing something?

> > > +	if (!(value & DP83822_WOL_EN))
> > > +		genphy_suspend(phydev);
> 
> Releasing the lock before calling genphy_suspend() is not so nice.
> Maybe add a version which assumes the lock has already been taken?
> 
We can expand genphy_suspend() per setting by phy_driver->set_wol.
When genphy_suspend() acts per wol setting, not many phy driver needs to extra work
When WOL is enabled.
How do you think?

- Woojung
