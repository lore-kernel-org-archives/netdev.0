From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/8] net: ethernet: add the Alpine Ethernet
 driver
Date: Mon, 28 Aug 2017 20:09:32 +0200
Message-ID: <20170828180932.GG10418@lunn.ch>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
 <20170203181216.30214-5-antoine.tenart@free-electrons.com>
 <20170203205823.GA22572@lunn.ch>
 <1503841641816.62526@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        "arnd@arndb.de" <arnd@arndb.de>
To: "Chocron, Jonathan" <jonnyc@amazon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46601 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751213AbdH1SJh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 14:09:37 -0400
Content-Disposition: inline
In-Reply-To: <1503841641816.62526@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 27, 2017 at 01:47:19PM +0000, Chocron, Jonathan wrote:
> This is a fixed version of my previous response (using proper indentation and leaving only the specific questions responded to).

Wow, this is old.  3 Feb 2017. I had to go dig into the archive to
refresh my memory.

> > > +/* MDIO */
> > > +#define AL_ETH_MDIO_C45_DEV_MASK     0x1f0000
> > > +#define AL_ETH_MDIO_C45_DEV_SHIFT    16
> > > +#define AL_ETH_MDIO_C45_REG_MASK     0xffff
> > > +
> > > +static int al_mdio_read(struct mii_bus *bp, int mii_id, int reg)
> > > +{
> > > +     struct al_eth_adapter *adapter = bp->priv;
> > > +     u16 value = 0;
> > > +     int rc;
> > > +     int timeout = MDIO_TIMEOUT_MSEC;
> > > +
> > > +     while (timeout > 0) {
> > > +             if (reg & MII_ADDR_C45) {
> > > +                     netdev_dbg(adapter->netdev, "[c45]: dev %x reg %x val %x\n",
> > > +                                ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_ETH_MDIO_C45_DEV_SHIFT),
> > > +                                (reg & AL_ETH_MDIO_C45_REG_MASK), value);
> > > +                     rc = al_eth_mdio_read(&adapter->hw_adapter, adapter->phy_addr,
> > > +                             ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_ETH_MDIO_C45_DEV_SHIFT),
> > > +                             (reg & AL_ETH_MDIO_C45_REG_MASK), &value);
> > > +             } else {
> > > +                     rc = al_eth_mdio_read(&adapter->hw_adapter, adapter->phy_addr,
> > > +                                           MDIO_DEVAD_NONE, reg, &value);
> > > +             }
> > > +
> > > +             if (rc == 0)
> > > +                     return value;
> > > +
> > > +             netdev_dbg(adapter->netdev,
> > > +                        "mdio read failed. try again in 10 msec\n");
> > > +
> > > +             timeout -= 10;
> > > +             msleep(10);
> > > +     }
> > 
> > This is rather unusual, retrying MDIO operations. Are you working
> > around a hardware bug? I suspect this also opens up race conditions,
> > in particular with PHY interrupts, which can be clear on read.
> 
> The MDIO bus is shared between the ethernet units. There is a HW
> lock used to arbitrate between different interfaces trying to access
> the bus, therefore there is a retry loop. The reg isn't accessed
> before obtaining the lock, so there shouldn't be any clear on read
> issues.
> 
> > > +/* al_eth_mdiobus_setup - initialize mdiobus and register to kernel */
> > > +static int al_eth_mdiobus_setup(struct al_eth_adapter *adapter)
> > > +{
> > > +     struct phy_device *phydev;
> > > +     int i;
> > > +     int ret = 0;
> > > +
> > > +     adapter->mdio_bus = mdiobus_alloc();
> > > +     if (!adapter->mdio_bus)
> > > +             return -ENOMEM;
> > > +
> > > +     adapter->mdio_bus->name     = "al mdio bus";
> > > +     snprintf(adapter->mdio_bus->id, MII_BUS_ID_SIZE, "%x",
> > > +              (adapter->pdev->bus->number << 8) | adapter->pdev->devfn);
> > > +     adapter->mdio_bus->priv     = adapter;
> > > +     adapter->mdio_bus->parent   = &adapter->pdev->dev;
> > > +     adapter->mdio_bus->read     = &al_mdio_read;
> > > +     adapter->mdio_bus->write    = &al_mdio_write;
> > > +     adapter->mdio_bus->phy_mask = ~BIT(adapter->phy_addr);
> >
> > Why do this?
> 
> Since the MDIO bus is shared, we want each interface to probe only for the PHY associated with it.

So i think this is the core of the problem. You have one physical MDIO
bus, yet you register it twice with the MDIO framework.

How about you only register it once? A lot of the complexity then goes
away. The mutex in the mdio core per bus means you don't need your
hardware locking. All that code goes away. All the retry code goes
away. Life is simple.

	Andrew
