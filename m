From: "Chocron, Jonathan" <jonnyc@amazon.com>
Subject: Re: [PATCH net-next 4/8] net: ethernet: add the Alpine Ethernet
 driver
Date: Sun, 27 Aug 2017 13:47:19 +0000
Message-ID: <1503841641816.62526@amazon.com>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
 <20170203181216.30214-5-antoine.tenart@free-electrons.com>,<20170203205823.GA22572@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        "arnd@arndb.de" <arnd@arndb.de>
To: Andrew Lunn <andrew@lunn.ch>,
        Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:5275 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751338AbdH0Nre (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 09:47:34 -0400
In-Reply-To: <20170203205823.GA22572@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a fixed version of my previous response (using proper indentation a=
nd leaving only the specific questions responded to).=0A=
=0A=
> > +/* MDIO */=0A=
> > +#define AL_ETH_MDIO_C45_DEV_MASK     0x1f0000=0A=
> > +#define AL_ETH_MDIO_C45_DEV_SHIFT    16=0A=
> > +#define AL_ETH_MDIO_C45_REG_MASK     0xffff=0A=
> > +=0A=
> > +static int al_mdio_read(struct mii_bus *bp, int mii_id, int reg)=0A=
> > +{=0A=
> > +     struct al_eth_adapter *adapter =3D bp->priv;=0A=
> > +     u16 value =3D 0;=0A=
> > +     int rc;=0A=
> > +     int timeout =3D MDIO_TIMEOUT_MSEC;=0A=
> > +=0A=
> > +     while (timeout > 0) {=0A=
> > +             if (reg & MII_ADDR_C45) {=0A=
> > +                     netdev_dbg(adapter->netdev, "[c45]: dev %x reg %x=
 val %x\n",=0A=
> > +                                ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> A=
L_ETH_MDIO_C45_DEV_SHIFT),=0A=
> > +                                (reg & AL_ETH_MDIO_C45_REG_MASK), valu=
e);=0A=
> > +                     rc =3D al_eth_mdio_read(&adapter->hw_adapter, ada=
pter->phy_addr,=0A=
> > +                             ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_E=
TH_MDIO_C45_DEV_SHIFT),=0A=
> > +                             (reg & AL_ETH_MDIO_C45_REG_MASK), &value)=
;=0A=
> > +             } else {=0A=
> > +                     rc =3D al_eth_mdio_read(&adapter->hw_adapter, ada=
pter->phy_addr,=0A=
> > +                                           MDIO_DEVAD_NONE, reg, &valu=
e);=0A=
> > +             }=0A=
> > +=0A=
> > +             if (rc =3D=3D 0)=0A=
> > +                     return value;=0A=
> > +=0A=
> > +             netdev_dbg(adapter->netdev,=0A=
> > +                        "mdio read failed. try again in 10 msec\n");=
=0A=
> > +=0A=
> > +             timeout -=3D 10;=0A=
> > +             msleep(10);=0A=
> > +     }=0A=
> =0A=
> This is rather unusual, retrying MDIO operations. Are you working=0A=
> around a hardware bug? I suspect this also opens up race conditions,=0A=
> in particular with PHY interrupts, which can be clear on read.=0A=
=0A=
The MDIO bus is shared between the ethernet units. There is a HW lock used =
to arbitrate between different interfaces trying to access the bus, =0A=
therefore there is a retry loop. The reg isn't accessed before obtaining th=
e lock, so there shouldn't be any clear on read issues.=0A=
=0A=
> > +/* al_eth_mdiobus_setup - initialize mdiobus and register to kernel */=
=0A=
> > +static int al_eth_mdiobus_setup(struct al_eth_adapter *adapter)=0A=
> > +{=0A=
> > +     struct phy_device *phydev;=0A=
> > +     int i;=0A=
> > +     int ret =3D 0;=0A=
> > +=0A=
> > +     adapter->mdio_bus =3D mdiobus_alloc();=0A=
> > +     if (!adapter->mdio_bus)=0A=
> > +             return -ENOMEM;=0A=
> > +=0A=
> > +     adapter->mdio_bus->name     =3D "al mdio bus";=0A=
> > +     snprintf(adapter->mdio_bus->id, MII_BUS_ID_SIZE, "%x",=0A=
> > +              (adapter->pdev->bus->number << 8) | adapter->pdev->devfn=
);=0A=
> > +     adapter->mdio_bus->priv     =3D adapter;=0A=
> > +     adapter->mdio_bus->parent   =3D &adapter->pdev->dev;=0A=
> > +     adapter->mdio_bus->read     =3D &al_mdio_read;=0A=
> > +     adapter->mdio_bus->write    =3D &al_mdio_write;=0A=
> > +     adapter->mdio_bus->phy_mask =3D ~BIT(adapter->phy_addr);=0A=
>=0A=
> Why do this?=0A=
=0A=
Since the MDIO bus is shared, we want each interface to probe only for the =
PHY associated with it.=0A=
=0A=
> > + * acquire mdio interface ownership=0A=
> > + * when mdio interface shared between multiple eth controllers, this f=
unction waits until the ownership granted for this controller.=0A=
> > + * this function does nothing when the mdio interface is used only by =
this controller.=0A=
> > + *=0A=
> > + * @param adapter=0A=
> > + * @return 0 on success, -ETIMEDOUT  on timeout.=0A=
> > + */=0A=
> > +static int al_eth_mdio_lock(struct al_hw_eth_adapter *adapter)=0A=
> > +{=0A=
> > +     int count =3D 0;=0A=
> > +     u32 mdio_ctrl_1;=0A=
> > +=0A=
> > +     if (!adapter->shared_mdio_if)=0A=
> > +             return 0; /* nothing to do when interface is not shared *=
/=0A=
> > +=0A=
> > +     do {=0A=
> > +             mdio_ctrl_1 =3D readl(&adapter->mac_regs_base->gen.mdio_c=
trl_1);=0A=
> > +             if (mdio_ctrl_1 & BIT(0)) {=0A=
> > +                     if (count > 0)=0A=
> > +                             netdev_dbg(adapter->netdev,=0A=
> > +                                        "eth %s mdio interface still b=
usy!\n",=0A=
> > +                                        adapter->name);=0A=
> > +             } else {=0A=
> > +                     return 0;=0A=
> > +             }=0A=
> > +             udelay(AL_ETH_MDIO_DELAY_PERIOD);=0A=
> > +     } while (count++ < (AL_ETH_MDIO_DELAY_COUNT * 4));=0A=
>=0A=
> This needs explaining. How can a read alone perform a lock? How is=0A=
> this race free?=0A=
=0A=
This is how this HW lock works: when the bit is 0 this means the lock is fr=
ee. When a read transaction arrives=0A=
to the lock, it changes its value to 1 but sends 0 as the response, basical=
ly taking ownership.=0A=
When the owner is done, it writes  a 0 which essentially "frees" the lock.=
=0A=
=0A=
> > +             if (adapter->mdio_type =3D=3D AL_ETH_MDIO_TYPE_CLAUSE_22)=
=0A=
> > +                     rc =3D al_eth_mdio_10g_mac_type22(adapter, 1, phy=
_addr,=0A=
> > +                                                     reg, val);=0A=
> > +             else=0A=
> > +                     rc =3D al_eth_mdio_10g_mac_type45(adapter, 1, phy=
_addr,=0A=
> > +                                                     device, reg, val)=
;=0A=
> =0A=
> This seems odd. My understanding is that the device on the MDIO bus,=0A=
> the PHY, is either c22 or c45. The PHY driver will tell you this, not=0A=
> the adaptor.=0A=
 =0A=
The current implementation sets mdio_type according to information which is=
 originally deduced from the=0A=
DeviceTree (the bootloader parses the ethernet node of the DeviceTree and s=
aves this data to HW registers, which are then read by this driver).=0A=
How can this information be obtained by the PHY driver?=0A=
=0A=
>    Andrew=0A=
=0A=
Jonathan=0A=
