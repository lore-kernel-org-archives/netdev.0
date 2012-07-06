From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH 4/4] asix: Add a new driver for the AX88172A
Date: Fri, 6 Jul 2012 14:20:26 -0700
Message-ID: <CANEJEGu3iTDYJD+ZpcwgRCZTF8a_bi9kWSuKK4eaHzS1uL+ZxA@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	<1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:55233 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758265Ab2GFVU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 17:20:27 -0400
Received: by obbuo13 with SMTP id uo13so15702236obb.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 14:20:27 -0700 (PDT)
In-Reply-To: <1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 6, 2012 at 4:33 AM, Christian Riesch
<christian.riesch@omicron.at> wrote:
> The Asix AX88172A is a USB 2.0 Ethernet interface that supports both an
> internal PHY as well as an external PHY (connected via MII).
>
> This patch adds a driver for the AX88172A and provides support for
> both modes and supports phylib.

Christian,
In general this looks fine to me...but I wouldn't know about "bus
identifier life times" (Ben Hutchings comment).

My nit pick is the declaration and of use_embdphy. An alternative
coding _suggestion_ below.  I'm not substantially altering the
functionality.

thanks,
grant

>
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
> ---
>  drivers/net/usb/Makefile       |    2 +-
>  drivers/net/usb/asix_devices.c |    6 +
>  drivers/net/usb/ax88172a.c     |  407 ++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 414 insertions(+), 1 deletions(-)
>  create mode 100644 drivers/net/usb/ax88172a.c
>
> diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
> index a9490d9..bf06300 100644
> --- a/drivers/net/usb/Makefile
> +++ b/drivers/net/usb/Makefile
> @@ -8,7 +8,7 @@ obj-$(CONFIG_USB_PEGASUS)       += pegasus.o
>  obj-$(CONFIG_USB_RTL8150)      += rtl8150.o
>  obj-$(CONFIG_USB_HSO)          += hso.o
>  obj-$(CONFIG_USB_NET_AX8817X)  += asix.o
> -asix-y := asix_devices.o asix_common.o
> +asix-y := asix_devices.o asix_common.o ax88172a.o
>  obj-$(CONFIG_USB_NET_CDCETHER) += cdc_ether.o
>  obj-$(CONFIG_USB_NET_CDC_EEM)  += cdc_eem.o
>  obj-$(CONFIG_USB_NET_DM9601)   += dm9601.o
> diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
> index c8682a5..02b8c21 100644
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -877,6 +877,8 @@ static const struct driver_info ax88178_info = {
>         .tx_fixup = asix_tx_fixup,
>  };
>
> +extern const struct driver_info ax88172a_info;
> +
>  static const struct usb_device_id      products[] = {
>  {
>         /* Linksys USB200M */
> @@ -1002,6 +1004,10 @@ static const struct usb_device_id        products[] = {
>         /* Asus USB Ethernet Adapter */
>         USB_DEVICE(0x0b95, 0x7e2b),
>         .driver_info = (unsigned long) &ax88772_info,
> +}, {
> +       /* ASIX 88172a demo board */
> +       USB_DEVICE(0x0b95, 0x172a),
> +       .driver_info = (unsigned long) &ax88172a_info,
>  },
>         { },            /* END */
>  };
> diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
> new file mode 100644
> index 0000000..9f2d1fd
> --- /dev/null
> +++ b/drivers/net/usb/ax88172a.c
> @@ -0,0 +1,407 @@
> +/*
> + * ASIX AX88172A based USB 2.0 Ethernet Devices
> + * Copyright (C) 2012 OMICRON electronics GmbH
> + *
> + * Supports external PHYs via phylib. Based on the driver for the
> + * AX88772. Original copyrights follow:
> + *
> + * Copyright (C) 2003-2006 David Hollis <dhollis@davehollis.com>
> + * Copyright (C) 2005 Phil Chang <pchang23@sbcglobal.net>
> + * Copyright (C) 2006 James Painter <jamie.painter@iname.com>
> + * Copyright (c) 2002-2003 TiVo Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + */
> +
> +#include "asix.h"
> +#include <linux/phy.h>
> +
> +struct ax88172a_private {
> +       int use_embdphy;

Can you move the "int" to the end of the struct?
It's cleaner to have fields "natively align". ie pointers should start
at 8 byte alignments when compiled for 64-bit.

> +       struct mii_bus *mdio;
> +       struct phy_device *phydev;
> +       char phy_name[20];
> +       u16 phy_addr;
> +       u16 oldmode;
> +};
> +
> +static inline int asix_read_phy_addr(struct usbnet *dev, int internal)
> +{
> +       int offset = (internal ? 1 : 0);

One could use "internal" parameter directly for indexing if
use_embdphy were renamed to use_extphy and the logic inverted..

> +       u8 buf[2];
> +       int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
> +
> +       netdev_dbg(dev->net, "asix_get_phy_addr()\n");
> +
> +       if (ret < 0) {
> +               netdev_err(dev->net, "Error reading PHYID register: %02x\n",
> +                          ret);
> +               goto out;
> +       }
> +       netdev_dbg(dev->net, "asix_get_phy_addr() returning 0x%04x\n",
> +                  *((__le16 *)buf));
> +       ret = buf[offset];
> +
> +out:
> +       return ret;
> +}
> +
> +static int ax88172a_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
> +{
> +       return phy_mii_ioctl(net->phydev, rq, cmd);
> +}
> +
> +/* MDIO read and write wrappers for phylib */
> +static int asix_mdio_bus_read(struct mii_bus *bus, int phy_id, int regnum)
> +{
> +       return asix_mdio_read(((struct usbnet *)bus->priv)->net, phy_id,
> +                             regnum);
> +}
> +
> +static int asix_mdio_bus_write(struct mii_bus *bus, int phy_id, int regnum,
> +                              u16 val)
> +{
> +       asix_mdio_write(((struct usbnet *)bus->priv)->net, phy_id, regnum,
> +                       val);
> +       return 0;
> +}
> +
> +/* set MAC link settings according to information from phylib */
> +static void asix_adjust_link(struct net_device *netdev)
> +{
> +       struct phy_device *phydev = netdev->phydev;
> +       struct usbnet *dev = netdev_priv(netdev);
> +       struct ax88172a_private *priv =
> +               (struct ax88172a_private *)dev->driver_priv;
> +       u16 mode = 0;
> +
> +       dbg("asix_adjust_link called\n");
> +
> +       if (phydev->link) {
> +               mode = AX88772_MEDIUM_DEFAULT;
> +
> +               if (phydev->duplex == DUPLEX_HALF)
> +                       mode &= ~AX_MEDIUM_FD;
> +
> +               if (phydev->speed != SPEED_100)
> +                       mode &= ~AX_MEDIUM_PS;
> +       }
> +
> +       if (mode != priv->oldmode) {
> +               asix_write_medium_mode(dev, mode);
> +               priv->oldmode = mode;
> +               dbg("asix_adjust_link  speed: %u duplex: %d setting mode to 0x%04x\n",
> +                   phydev->speed, phydev->duplex, mode);
> +               phy_print_status(phydev);
> +       }
> +}
> +
> +static void ax88172a_status(struct usbnet *dev, struct urb *urb)
> +{
> +}
> +
> +/* use phylib infrastructure */
> +static int ax88172a_init_mdio(struct usbnet *dev)
> +{
> +       struct ax88172a_private *priv =
> +               (struct ax88172a_private *)dev->driver_priv;
> +       int ret, i;
> +
> +       priv->mdio = mdiobus_alloc();
> +       if (!priv->mdio) {
> +               dbg("Could not allocate MDIO bus");
> +               return -1;
> +       }
> +
> +       priv->mdio->priv = (void *)dev;
> +       priv->mdio->read = &asix_mdio_bus_read;
> +       priv->mdio->write = &asix_mdio_bus_write;
> +       priv->mdio->name = "Asix MDIO Bus";
> +       snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%s",
> +                dev_name(dev->net->dev.parent));
> +
> +       priv->mdio->irq = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> +       if (!priv->mdio->irq) {
> +               dbg("Could not allocate MDIO->IRQ");
> +               ret = -ENOMEM;
> +               goto mfree;
> +       }
> +       for (i = 0; i < PHY_MAX_ADDR; i++)
> +               priv->mdio->irq[i] = PHY_POLL;
> +
> +       ret = mdiobus_register(priv->mdio);
> +       if (ret) {
> +               dbg("Could not register MDIO bus");
> +               goto ifree;
> +       }
> +       snprintf(priv->phy_name, 20, PHY_ID_FMT,
> +                priv->mdio->id, priv->phy_addr);
> +
> +       priv->phydev = phy_connect(dev->net, priv->phy_name, &asix_adjust_link,
> +                                  0, PHY_INTERFACE_MODE_MII);
> +       if (IS_ERR(priv->phydev)) {
> +               dbg("Could not connect to PHY device");
> +               ret = PTR_ERR(priv->phydev);
> +               goto munreg;
> +       }
> +       dbg("dev->net->phydev (%s) is now 0x%p", priv->phy_name,
> +           dev->net->phydev);
> +
> +       /* During power-up, the AX88172A set the power down (BMCR_PDOWN)
> +        *   bit of the PHY. Bring the PHY up again.
> +        */
> +       genphy_resume(priv->phydev);
> +
> +       phy_start(priv->phydev);
> +
> +       return 0;
> +munreg:
> +       mdiobus_unregister(priv->mdio);
> +ifree:
> +       kfree(priv->mdio->irq);
> +mfree:
> +       mdiobus_free(priv->mdio);
> +       return ret;
> +}
> +
> +static void ax88172a_remove_mdio(struct usbnet *dev)
> +{
> +       struct ax88172a_private *priv =
> +               (struct ax88172a_private *)dev->driver_priv;
> +
> +       phy_stop(priv->phydev);
> +       phy_disconnect(priv->phydev);
> +       mdiobus_unregister(priv->mdio);
> +       kfree(priv->mdio->irq);
> +       mdiobus_free(priv->mdio);
> +}
> +
> +static const struct net_device_ops ax88172a_netdev_ops = {
> +       .ndo_open               = usbnet_open,
> +       .ndo_stop               = usbnet_stop,
> +       .ndo_start_xmit         = usbnet_start_xmit,
> +       .ndo_tx_timeout         = usbnet_tx_timeout,
> +       .ndo_change_mtu         = usbnet_change_mtu,
> +       .ndo_set_mac_address    = asix_set_mac_address,
> +       .ndo_validate_addr      = eth_validate_addr,
> +       .ndo_do_ioctl           = ax88172a_ioctl,
> +       .ndo_set_rx_mode        = asix_set_multicast,
> +};
> +
> +int ax88172a_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
> +{
> +       return phy_ethtool_gset(net->phydev, cmd);
> +}
> +
> +int ax88172a_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
> +{
> +       return phy_ethtool_sset(net->phydev, cmd);
> +}
> +
> +int ax88172a_nway_reset(struct net_device *net)
> +{
> +       return phy_start_aneg(net->phydev);
> +}
> +
> +static const struct ethtool_ops ax88172a_ethtool_ops = {
> +       .get_drvinfo            = asix_get_drvinfo,
> +       .get_link               = usbnet_get_link,
> +       .get_msglevel           = usbnet_get_msglevel,
> +       .set_msglevel           = usbnet_set_msglevel,
> +       .get_wol                = asix_get_wol,
> +       .set_wol                = asix_set_wol,
> +       .get_eeprom_len         = asix_get_eeprom_len,
> +       .get_eeprom             = asix_get_eeprom,
> +       .get_settings           = ax88172a_get_settings,
> +       .set_settings           = ax88172a_set_settings,
> +       .nway_reset             = ax88172a_nway_reset,
> +};
> +
> +static int ax88172a_reset_phy(struct usbnet *dev, int embd_phy)
> +{
> +       int ret;
> +
> +       ret = asix_sw_reset(dev, AX_SWRESET_IPPD);
> +       if (ret < 0)
> +               goto err;
> +
> +       msleep(150);
> +       ret = asix_sw_reset(dev, AX_SWRESET_CLEAR);
> +       if (ret < 0)
> +               goto err;
> +
> +       msleep(150);
> +
> +       ret = asix_sw_reset(dev, embd_phy ? AX_SWRESET_IPRL : AX_SWRESET_IPPD);

(would have to swap things here if adopting my suggestions.)

> +       if (ret < 0)
> +               goto err;
> +
> +       return 0;
> +
> +err:
> +       return ret;
> +}
> +
> +
> +static int ax88172a_bind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +       int ret;
> +       struct asix_data *data = (struct asix_data *)&dev->data;
> +       u8 buf[ETH_ALEN];
> +       struct ax88172a_private *priv;
> +
> +       data->eeprom_len = AX88772_EEPROM_LEN;
> +
> +       usbnet_get_endpoints(dev, intf);
> +
> +       priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> +       if (!priv) {
> +               dbg("Could not allocate memory for private data");
> +               return -ENOMEM;
> +       }
> +       dev->driver_priv = priv;
> +
> +       /* Get the MAC address */
> +       ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
> +       if (ret < 0) {
> +               dbg("Failed to read MAC address: %d", ret);
> +               goto free;
> +       }
> +       memcpy(dev->net->dev_addr, buf, ETH_ALEN);
> +
> +       dev->net->netdev_ops = &ax88172a_netdev_ops;
> +       dev->net->ethtool_ops = &ax88172a_ethtool_ops;
> +
> +       /* are we using the internal or the external phy? */
> +       ret = asix_read_cmd(dev, AX_CMD_SW_PHY_STATUS, 0, 0, 1, buf);
> +       if (ret < 0) {
> +               dbg("Failed to read software interface selection register: %d",
> +                   ret);
> +               goto free;
> +       }
> +       dbg("AX_CMD_SW_PHY_STATUS = 0x%02x\n", buf[0]);
> +       switch ((buf[0] & 0x0c) >> 2) {
> +       case 0:
> +               dbg("use internal phy\n");
> +               priv->use_embdphy = 1;
> +               break;
> +       case 1:
> +               dbg("use external phy\n");
> +               priv->use_embdphy = 0;
> +               break;
> +       default:
> +               dbg("Interface mode not supported by driver\n");
> +               goto free;
> +       }

This switch statement inverts the existing logic. Much simpler code would be:
    /* buf[0] & 0xc describes phy interface mode */
    if (buf[0] &  8) {
         dbg("Interface mode not supported by driver\n");
         goto free;
    }
    priv->use_extphy = (buf[0] & 4) >> 2;

> +
> +       priv->phy_addr = asix_read_phy_addr(dev, priv->use_embdphy);
> +       ax88172a_reset_phy(dev, priv->use_embdphy);
> +
> +       /* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
> +       if (dev->driver_info->flags & FLAG_FRAMING_AX) {
> +               /* hard_mtu  is still the default - the device does not support
> +                  jumbo eth frames */
> +               dev->rx_urb_size = 2048;
> +       }
> +
> +       /* init MDIO bus */
> +       ret = ax88172a_init_mdio(dev);
> +       if (ret)
> +               goto free;
> +
> +       return 0;
> +
> +free:
> +       kfree(priv);
> +       return ret;
> +}
> +
> +static void ax88172a_unbind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +       struct ax88172a_private *priv =
> +               (struct ax88172a_private *)dev->driver_priv;
> +
> +       ax88172a_remove_mdio(dev);
> +       kfree(priv);
> +}
> +
> +static int ax88172a_reset(struct usbnet *dev)
> +{
> +       struct asix_data *data = (struct asix_data *)&dev->data;
> +       struct ax88172a_private *priv =
> +               (struct ax88172a_private *)dev->driver_priv;
> +       int ret;
> +       u16 rx_ctl;
> +
> +       ax88172a_reset_phy(dev, priv->use_embdphy);
> +
> +       msleep(150);
> +       rx_ctl = asix_read_rx_ctl(dev);
> +       dbg("RX_CTL is 0x%04x after software reset", rx_ctl);
> +       ret = asix_write_rx_ctl(dev, 0x0000);
> +       if (ret < 0)
> +               goto out;
> +
> +       rx_ctl = asix_read_rx_ctl(dev);
> +       dbg("RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
> +
> +       msleep(150);
> +
> +       ax88172a_nway_reset(dev->net);
> +
> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
> +                               AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
> +                               AX88772_IPG2_DEFAULT, 0, NULL);
> +       if (ret < 0) {
> +               dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
> +               goto out;
> +       }
> +
> +       /* Rewrite MAC address */
> +       memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
> +       ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
> +                                                       data->mac_addr);
> +       if (ret < 0)
> +               goto out;
> +
> +       /* Set RX_CTL to default values with 2k buffer, and enable cactus */
> +       ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
> +       if (ret < 0)
> +               goto out;
> +
> +       rx_ctl = asix_read_rx_ctl(dev);
> +       dbg("RX_CTL is 0x%04x after all initializations", rx_ctl);
> +
> +       rx_ctl = asix_read_medium_status(dev);
> +       dbg("Medium Status is 0x%04x after all initializations", rx_ctl);
> +
> +       return 0;
> +
> +out:
> +       return ret;
> +
> +}
> +
> +const struct driver_info ax88172a_info = {
> +       .description = "ASIX AX88172A USB 2.0 Ethernet",
> +       .bind = ax88172a_bind,
> +       .unbind = ax88172a_unbind,
> +       .status = ax88172a_status,
> +       .reset = ax88172a_reset,
> +       .flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
> +                FLAG_MULTI_PACKET,
> +       .rx_fixup = asix_rx_fixup,
> +       .tx_fixup = asix_tx_fixup,
> +};
> --
> 1.7.0.4
>
