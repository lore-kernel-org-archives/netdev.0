From: "Chocron, Jonathan" <jonnyc@amazon.com>
Subject: Re: [PATCH net-next 4/8] net: ethernet: add the Alpine Ethernet
 driver
Date: Mon, 7 Aug 2017 07:39:59 +0000
Message-ID: <1502091598623.10609@amazon.com>
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
        "arnd@arndb.de" <arnd@arndb.de>, "BSHARA, Said" <saeedb@amazon.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6001.amazon.com ([52.95.48.154]:64607 "EHLO
        smtp-fw-6001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbdHGHkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 03:40:14 -0400
In-Reply-To: <20170203205823.GA22572@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=0A=
________________________________________=0A=
From: Andrew Lunn <andrew@lunn.ch>=0A=
Sent: Friday, February 3, 2017 22:58=0A=
To: Antoine Tenart=0A=
Cc: netdev@vger.kernel.org; davem@davemloft.net; linux-arm-kernel@lists.inf=
radead.org; tsahee@annapurnalabs.com; rshitrit@annapurnalabs.com; saeed@ann=
apurnalabs.com; barak@annapurnalabs.com; talz@annapurnalabs.com; thomas.pet=
azzoni@free-electrons.com; arnd@arndb.de=0A=
Subject: Re: [PATCH net-next 4/8] net: ethernet: add the Alpine Ethernet dr=
iver=0A=
=0A=
> +/* MDIO */=0A=
> +#define AL_ETH_MDIO_C45_DEV_MASK     0x1f0000=0A=
> +#define AL_ETH_MDIO_C45_DEV_SHIFT    16=0A=
> +#define AL_ETH_MDIO_C45_REG_MASK     0xffff=0A=
> +=0A=
> +static int al_mdio_read(struct mii_bus *bp, int mii_id, int reg)=0A=
> +{=0A=
> +     struct al_eth_adapter *adapter =3D bp->priv;=0A=
> +     u16 value =3D 0;=0A=
> +     int rc;=0A=
> +     int timeout =3D MDIO_TIMEOUT_MSEC;=0A=
> +=0A=
> +     while (timeout > 0) {=0A=
> +             if (reg & MII_ADDR_C45) {=0A=
> +                     netdev_dbg(adapter->netdev, "[c45]: dev %x reg %x v=
al %x\n",=0A=
> +                                ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_=
ETH_MDIO_C45_DEV_SHIFT),=0A=
> +                                (reg & AL_ETH_MDIO_C45_REG_MASK), value)=
;=0A=
> +                     rc =3D al_eth_mdio_read(&adapter->hw_adapter, adapt=
er->phy_addr,=0A=
> +                             ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_ETH=
_MDIO_C45_DEV_SHIFT),=0A=
> +                             (reg & AL_ETH_MDIO_C45_REG_MASK), &value);=
=0A=
> +             } else {=0A=
> +                     rc =3D al_eth_mdio_read(&adapter->hw_adapter, adapt=
er->phy_addr,=0A=
> +                                           MDIO_DEVAD_NONE, reg, &value)=
;=0A=
> +             }=0A=
> +=0A=
> +             if (rc =3D=3D 0)=0A=
> +                     return value;=0A=
> +=0A=
> +             netdev_dbg(adapter->netdev,=0A=
> +                        "mdio read failed. try again in 10 msec\n");=0A=
> +=0A=
> +             timeout -=3D 10;=0A=
> +             msleep(10);=0A=
> +     }=0A=
=0A=
This is rather unusual, retrying MDIO operations. Are you working=0A=
around a hardware bug? I suspect this also opens up race conditions,=0A=
in particular with PHY interrupts, which can be clear on read.=0A=
=0A=
The MDIO bus is shared between the ethernet units. There is a HW lock used =
to arbitrate between different interfaces trying to access the bus, =0A=
therefore there is a retry loop. The reg isn't accessed before obtaining th=
e lock, so there shouldn't be any clear on read issues.=0A=
=0A=
> +=0A=
> +static int al_eth_ioctl(struct net_device *netdev, struct ifreq *ifr, in=
t cmd)=0A=
> +{=0A=
> +     struct al_eth_adapter *adapter =3D netdev_priv(netdev);=0A=
> +     struct mii_ioctl_data *mdio =3D if_mii(ifr);=0A=
> +     struct phy_device *phydev;=0A=
> +=0A=
> +     netdev_info(adapter->netdev, "ioctl: phy id 0x%x, reg 0x%x, val_in =
0x%x\n",=0A=
> +                 mdio->phy_id, mdio->reg_num, mdio->val_in);=0A=
=0A=
netdev_info() for an ioctl?=0A=
=0A=
> +static int al_eth_flow_ctrl_config(struct al_eth_adapter *adapter);=0A=
> +static u8 al_eth_flow_ctrl_mutual_cap_get(struct al_eth_adapter *adapter=
);=0A=
> +static void al_eth_down(struct al_eth_adapter *adapter);=0A=
> +static int al_eth_up(struct al_eth_adapter *adapter);=0A=
=0A=
Forward declarations are generally not liked. Can you move the code=0A=
around to remove them?=0A=
=0A=
> +=0A=
> +static void al_eth_adjust_link(struct net_device *dev)=0A=
> +{=0A=
> +     struct al_eth_adapter *adapter =3D netdev_priv(dev);=0A=
> +     struct al_eth_link_config *link_config =3D &adapter->link_config;=
=0A=
> +     struct phy_device *phydev =3D adapter->phydev;=0A=
> +     enum al_eth_mac_mode mac_mode_needed =3D AL_ETH_MAC_MODE_RGMII;=0A=
> +     int new_state =3D 0;=0A=
> +     bool force_1000_base_x =3D false;=0A=
> +=0A=
> +     if (phydev->link) {=0A=
> +             if (phydev->duplex !=3D link_config->active_duplex) {=0A=
> +                     new_state =3D 1;=0A=
> +                     link_config->active_duplex =3D phydev->duplex;=0A=
> +             }=0A=
> +=0A=
> +             if (phydev->speed !=3D link_config->active_speed) {=0A=
> +                     new_state =3D 1;=0A=
> +                     switch (phydev->speed) {=0A=
> +                     case SPEED_1000:=0A=
> +                     case SPEED_100:=0A=
> +                     case SPEED_10:=0A=
> +                             mac_mode_needed =3D (adapter->mac_mode =3D=
=3D AL_ETH_MAC_MODE_RGMII) ?=0A=
> +                                     AL_ETH_MAC_MODE_RGMII : AL_ETH_MAC_=
MODE_SGMII;=0A=
> +                             break;=0A=
> +                     case SPEED_10000:=0A=
> +                     case SPEED_2500:=0A=
> +                             mac_mode_needed =3D AL_ETH_MAC_MODE_10GbE_S=
erial;=0A=
> +                             break;=0A=
> +                     default:=0A=
> +                             if (netif_msg_link(adapter))=0A=
> +                                     netdev_warn(adapter->netdev,=0A=
> +                                                 "Ack!  Speed (%d) is no=
t 10/100/1000!",=0A=
=0A=
Not particularly accurate, since 2.5G and 10G is supported.=0A=
=0A=
> +                                                 phydev->speed);=0A=
> +static int al_eth_phy_init(struct al_eth_adapter *adapter)=0A=
> +{=0A=
> +     struct phy_device *phydev =3D mdiobus_get_phy(adapter->mdio_bus, ad=
apter->phy_addr);=0A=
> +=0A=
> +     adapter->link_config.old_link =3D 0;=0A=
> +     adapter->link_config.active_duplex =3D DUPLEX_UNKNOWN;=0A=
> +     adapter->link_config.active_speed =3D SPEED_UNKNOWN;=0A=
> +=0A=
> +     /* Attach the MAC to the PHY. */=0A=
> +     phydev =3D phy_connect(adapter->netdev, dev_name(&phydev->mdio.dev)=
, al_eth_adjust_link,=0A=
> +                          PHY_INTERFACE_MODE_RGMII);=0A=
> +     if (IS_ERR(phydev)) {=0A=
> +             netdev_err(adapter->netdev, "Could not attach to PHY\n");=
=0A=
> +             return PTR_ERR(phydev);=0A=
> +     }=0A=
> +=0A=
> +     netdev_info(adapter->netdev, "phy[%d]: device %s, driver %s\n",=0A=
> +                 phydev->mdio.addr, dev_name(&phydev->mdio.dev),=0A=
> +                 phydev->drv ? phydev->drv->name : "unknown");=0A=
> +=0A=
=0A=
phy_attached_info()?=0A=
=0A=
> +     /* Mask with MAC supported features. */=0A=
> +     phydev->supported &=3D (PHY_GBIT_FEATURES |=0A=
> +                             SUPPORTED_Pause |=0A=
> +                             SUPPORTED_Asym_Pause);=0A=
> +=0A=
> +     phydev->advertising =3D phydev->supported;=0A=
> +=0A=
> +     netdev_info(adapter->netdev, "phy[%d]:supported %x adv %x\n",=0A=
> +                 phydev->mdio.addr, phydev->supported, phydev->advertisi=
ng);=0A=
> +=0A=
=0A=
More output?=0A=
=0A=
> +     adapter->phydev =3D phydev;=0A=
> +     /* Bring the PHY up */=0A=
> +     phy_start(adapter->phydev);=0A=
=0A=
This is normally done in the open() call.=0A=
=0A=
> +/* al_eth_mdiobus_setup - initialize mdiobus and register to kernel */=
=0A=
> +static int al_eth_mdiobus_setup(struct al_eth_adapter *adapter)=0A=
> +{=0A=
> +     struct phy_device *phydev;=0A=
> +     int i;=0A=
> +     int ret =3D 0;=0A=
> +=0A=
> +     adapter->mdio_bus =3D mdiobus_alloc();=0A=
> +     if (!adapter->mdio_bus)=0A=
> +             return -ENOMEM;=0A=
> +=0A=
> +     adapter->mdio_bus->name     =3D "al mdio bus";=0A=
> +     snprintf(adapter->mdio_bus->id, MII_BUS_ID_SIZE, "%x",=0A=
> +              (adapter->pdev->bus->number << 8) | adapter->pdev->devfn);=
=0A=
> +     adapter->mdio_bus->priv     =3D adapter;=0A=
> +     adapter->mdio_bus->parent   =3D &adapter->pdev->dev;=0A=
> +     adapter->mdio_bus->read     =3D &al_mdio_read;=0A=
> +     adapter->mdio_bus->write    =3D &al_mdio_write;=0A=
> +     adapter->mdio_bus->phy_mask =3D ~BIT(adapter->phy_addr);=0A=
=0A=
Why do this?=0A=
=0A=
Since the MDIO bus is shared, we want each interface to probe only for the =
PHY associated with it.=0A=
=0A=
=0A=
> +     for (i =3D 0; i < PHY_MAX_ADDR; i++)=0A=
> +             adapter->mdio_bus->irq[i] =3D PHY_POLL;=0A=
=0A=
Not needed. The core will do this.=0A=
=0A=
> +=0A=
> +     if (adapter->phy_if !=3D AL_ETH_BOARD_PHY_IF_XMDIO) {=0A=
> +             i =3D mdiobus_register(adapter->mdio_bus);=0A=
> +             if (i) {=0A=
> +                     netdev_warn(adapter->netdev,=0A=
> +                                 "mdiobus_reg failed (0x%x)\n", i);=0A=
> +                     mdiobus_free(adapter->mdio_bus);=0A=
> +                     return i;=0A=
> +             }=0A=
> +=0A=
> +             phydev =3D mdiobus_get_phy(adapter->mdio_bus, adapter->phy_=
addr);=0A=
> +     } else {=0A=
> +             adapter->mdio_bus->phy_mask =3D 0xffffffff;=0A=
> +             i =3D mdiobus_register(adapter->mdio_bus);=0A=
> +             if (i) {=0A=
> +                     netdev_warn(adapter->netdev,=0A=
> +                                 "mdiobus_reg failed (0x%x)\n", i);=0A=
> +                     mdiobus_free(adapter->mdio_bus);=0A=
> +                     return i;=0A=
> +             }=0A=
> +=0A=
> +             phydev =3D get_phy_device(adapter->mdio_bus, adapter->phy_a=
ddr,=0A=
> +                                     true);=0A=
> +             if (!phydev) {=0A=
> +                     netdev_err(adapter->netdev, "phy device get failed\=
n");=0A=
> +                     goto error;=0A=
> +             }=0A=
> +=0A=
> +             ret =3D phy_device_register(phydev);=0A=
> +             if (ret) {=0A=
> +                     netdev_err(adapter->netdev,=0A=
> +                                "phy device register failed\n");=0A=
> +                     goto error;=0A=
> +             }=0A=
> +     }=0A=
=0A=
It seems like this should be split up into two. One function to=0A=
register the MDIO bus, and a second to handle the PHY on the mdio bus.=0A=
=0A=
> +=0A=
> +     if (!phydev || !phydev->drv)=0A=
> +             goto error;=0A=
> +=0A=
> +     return 0;=0A=
> +=0A=
> +error:=0A=
> +     netdev_warn(adapter->netdev, "No PHY devices\n");=0A=
=0A=
Yet more warnings....=0A=
=0A=
> +     mdiobus_unregister(adapter->mdio_bus);=0A=
> +     mdiobus_free(adapter->mdio_bus);=0A=
> +     return -ENODEV;=0A=
> +}=0A=
> +=0A=
> +/* al_eth_mdiobus_teardown - mdiobus unregister */=0A=
> +static void al_eth_mdiobus_teardown(struct al_eth_adapter *adapter)=0A=
> +{=0A=
> +     if (!adapter->mdio_bus)=0A=
> +             return;=0A=
> +=0A=
> +     mdiobus_unregister(adapter->mdio_bus);=0A=
> +     mdiobus_free(adapter->mdio_bus);=0A=
> +     phy_device_free(adapter->phydev);=0A=
=0A=
Humm, you might want to think about the ordering here.=0A=
=0A=
> +}=0A=
> +=0A=
> +static void al_eth_tx_timeout(struct net_device *dev)=0A=
> +{=0A=
> +     struct al_eth_adapter *adapter =3D netdev_priv(dev);=0A=
> +=0A=
> +     if (netif_msg_tx_err(adapter))=0A=
> +             netdev_err(dev, "transmit timed out!!!!\n");=0A=
> +}=0A=
> +=0A=
> +static int al_eth_change_mtu(struct net_device *dev, int new_mtu)=0A=
> +{=0A=
> +     struct al_eth_adapter *adapter =3D netdev_priv(dev);=0A=
> +     int max_frame =3D new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;=0A=
> +=0A=
> +     if ((new_mtu < AL_ETH_MIN_FRAME_LEN) || (new_mtu > AL_ETH_MAX_MTU) =
||=0A=
> +         (max_frame > AL_ETH_MAX_FRAME_LEN)) {=0A=
> +             netdev_err(dev, "Invalid MTU setting\n");=0A=
> +             return -EINVAL;=0A=
> +     }=0A=
=0A=
The core will do this check for you, if you tell it to.=0A=
=0A=
> +             switch (params.speed) {=0A=
> +             default:=0A=
> +                     dev_warn(&adapter->pdev->dev,=0A=
> +                              "invalid speed (%d)\n", params.speed);=0A=
=0A=
It is a bit unusual having the default first. And that leads me to a C=0A=
question. Can it fall through into the next case statement if there is no b=
reak?=0A=
=0A=
> +static int al_eth_nway_reset(struct net_device *netdev)=0A=
> +{=0A=
> +     struct al_eth_adapter *adapter =3D netdev_priv(netdev);=0A=
> +     struct phy_device *phydev =3D adapter->phydev;=0A=
> +=0A=
> +     if (!phydev)=0A=
> +             return -ENODEV;=0A=
> +=0A=
> +     return phy_start_aneg(phydev);=0A=
> +}=0A=
=0A=
phy_ethtool_nway_reset() should be used.=0A=
=0A=
> +static int al_eth_set_mac_addr(struct net_device *dev, void *p)=0A=
> +{=0A=
> +     struct al_eth_adapter *adapter =3D netdev_priv(dev);=0A=
> +     struct sockaddr *addr =3D p;=0A=
> +     int err =3D 0;=0A=
> +=0A=
> +     if (!is_valid_ether_addr(addr->sa_data))=0A=
> +             return -EADDRNOTAVAIL;=0A=
=0A=
Seems like the core should be doing that for you. Not checked though.=0A=
If it does not, i suggest you do add it to the core.=0A=
=0A=
> +static void al_eth_mdio_1g_mac_read(struct al_hw_eth_adapter *adapter,=
=0A=
> +                                 u32 phy_addr, u32 reg, u16 *val)=0A=
> +{=0A=
> +     *val =3D readl(&adapter->mac_regs_base->mac_1g.phy_regs_base + reg)=
;=0A=
> +}=0A=
> +=0A=
> +static void al_eth_mdio_1g_mac_write(struct al_hw_eth_adapter *adapter,=
=0A=
> +                                  u32 phy_addr, u32 reg, u16 val)=0A=
> +{=0A=
> +     writel(val, &adapter->mac_regs_base->mac_1g.phy_regs_base + reg);=
=0A=
> +}=0A=
=0A=
Are there range checks made on reg before these functions are called?=0A=
Just thinking about SIOCSMIIREG ioctl.=0A=
=0A=
> +=0A=
> +static int al_eth_mdio_10g_mac_wait_busy(struct al_hw_eth_adapter *adapt=
er)=0A=
> +{=0A=
> +     int count =3D 0;=0A=
> +     u32 mdio_cfg_status;=0A=
> +=0A=
> +     do {=0A=
> +             mdio_cfg_status =3D readl(&adapter->mac_regs_base->mac_10g.=
mdio_cfg_status);=0A=
> +             if (mdio_cfg_status & BIT(0)) {=0A=
=0A=
Would be nice to have a #define for this 0 bit, and it seems bit 1 is an er=
ror?=0A=
=0A=
> +                     if (count > 0)=0A=
> +                             netdev_dbg(adapter->netdev,=0A=
> +                                        "eth [%s] mdio: still busy!\n",=
=0A=
> +                                        adapter->name);=0A=
> +             } else {=0A=
> +                     return 0;=0A=
> +             }=0A=
> +             udelay(AL_ETH_MDIO_DELAY_PERIOD);=0A=
> +     } while (count++ < AL_ETH_MDIO_DELAY_COUNT);=0A=
> +=0A=
> +     return -ETIMEDOUT;=0A=
> +}=0A=
> +=0A=
> +static int al_eth_mdio_10g_mac_type22(struct al_hw_eth_adapter *adapter,=
=0A=
> +                                   int read, u32 phy_addr, u32 reg, u16 =
*val)=0A=
> +{=0A=
> +     int rc;=0A=
> +     const char *op =3D (read =3D=3D 1) ? "read" : "write";=0A=
> +     u32 mdio_cfg_status;=0A=
> +     u16 mdio_cmd;=0A=
> +=0A=
> +     /* wait if the HW is busy */=0A=
> +     rc =3D al_eth_mdio_10g_mac_wait_busy(adapter);=0A=
> +     if (rc) {=0A=
> +             netdev_err(adapter->netdev,=0A=
> +                        " eth [%s] mdio %s failed. HW is busy\n",=0A=
> +                        adapter->name, op);=0A=
=0A=
How about moving this netdev_err() inside=0A=
al_eth_mdio_10g_mac_wait_busy() so you only need it once?=0A=
=0A=
> +             return rc;=0A=
> +     }=0A=
> +=0A=
> +     mdio_cmd =3D (u16)(0x1F & reg);=0A=
> +     mdio_cmd |=3D (0x1F & phy_addr) << 5;=0A=
> +=0A=
> +     if (read)=0A=
> +             mdio_cmd |=3D BIT(15); /* READ command */=0A=
=0A=
Another #define please.=0A=
=0A=
> + * acquire mdio interface ownership=0A=
> + * when mdio interface shared between multiple eth controllers, this fun=
ction waits until the ownership granted for this controller.=0A=
> + * this function does nothing when the mdio interface is used only by th=
is controller.=0A=
> + *=0A=
> + * @param adapter=0A=
> + * @return 0 on success, -ETIMEDOUT  on timeout.=0A=
> + */=0A=
> +static int al_eth_mdio_lock(struct al_hw_eth_adapter *adapter)=0A=
> +{=0A=
> +     int count =3D 0;=0A=
> +     u32 mdio_ctrl_1;=0A=
> +=0A=
> +     if (!adapter->shared_mdio_if)=0A=
> +             return 0; /* nothing to do when interface is not shared */=
=0A=
> +=0A=
> +     do {=0A=
> +             mdio_ctrl_1 =3D readl(&adapter->mac_regs_base->gen.mdio_ctr=
l_1);=0A=
> +             if (mdio_ctrl_1 & BIT(0)) {=0A=
> +                     if (count > 0)=0A=
> +                             netdev_dbg(adapter->netdev,=0A=
> +                                        "eth %s mdio interface still bus=
y!\n",=0A=
> +                                        adapter->name);=0A=
> +             } else {=0A=
> +                     return 0;=0A=
> +             }=0A=
> +             udelay(AL_ETH_MDIO_DELAY_PERIOD);=0A=
> +     } while (count++ < (AL_ETH_MDIO_DELAY_COUNT * 4));=0A=
=0A=
This needs explaining. How can a read alone perform a lock? How is=0A=
this race free?=0A=
=0A=
This is how this HW lock works: when the bit is 0 this means the lock is fr=
ee. When a read transaction arrives  to the lock, it changes its value to 1=
 but sends 0 as the response,=0A=
basically taking ownership. When the owner is done, it writes  a 0 which es=
sentially "frees" the lock.=0A=
=0A=
> +             if (adapter->mdio_type =3D=3D AL_ETH_MDIO_TYPE_CLAUSE_22)=
=0A=
> +                     rc =3D al_eth_mdio_10g_mac_type22(adapter, 1, phy_a=
ddr,=0A=
> +                                                     reg, val);=0A=
> +             else=0A=
> +                     rc =3D al_eth_mdio_10g_mac_type45(adapter, 1, phy_a=
ddr,=0A=
> +                                                     device, reg, val);=
=0A=
=0A=
This seems odd. My understanding is that the device on the MDIO bus,=0A=
the PHY, is either c22 or c45. The PHY driver will tell you this, not=0A=
the adaptor.=0A=
=0A=
The current implementation sets mdio_type according to information which is=
 originally deduced from the DeviceTree (the bootloader parses the ethernet=
 node of the DeviceTree and saves this data to HW registers, which are then=
 read by this driver).=0A=
How can this information be obtained by the PHY driver?=0A=
=0A=
    Andrew=0A=
=0A=
Jonathan=0A=
