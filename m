From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH - REPOST] asix.c - Add support for AX88772A devices -
Date: Wed, 14 Jan 2009 16:53:56 +0000
Message-ID: <1231952036.3010.21.camel@achroite>
References: <1231949520.4105.97.camel@dhollis-lnx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: David Hollis <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:41535 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763043AbZANQyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 11:54:07 -0500
In-Reply-To: <1231949520.4105.97.camel@dhollis-lnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 11:12 -0500, David Hollis wrote:
> The attached patch adds support for ASIX AX88772A devices, which is u=
sed
> in some netbooks, notebooks and embedded devices.  It's largely
> compatible with the AX88772 family.
>=20
> This re-post does not include changes to the ax88772_link_reset()
> function that removed the use of the generic MII calls in favor of mo=
re
> explicit register reads.  Those changes were not required for AX88772=
A
> support.
>=20
> Thanks to Louis <louis@asix.com.tw> for the initial patch.
>=20
> Signed-off-by: David Hollis <dhollis@davehollis.com>

This patch, including the context, has had tabs converted to spaces. =20

> =EF=BB=BF--- a/drivers/net/usb/asix.c    2009-01-02 01:06:26.00000000=
0 -0500
> +++ b/drivers/net/usb/asix.c    2009-01-14 10:35:11.000000000 -0500
> @@ -35,7 +35,7 @@
>  #include <linux/crc32.h>
>  #include <linux/usb/usbnet.h>
> =20
> -#define DRIVER_VERSION "14-Jun-2006"
> +#define DRIVER_VERSION "8-Jan-2009"
>  static const char driver_name [] =3D "asix";
> =20
>  /* ASIX AX8817X based USB 2.0 Ethernet Devices */
> @@ -93,8 +93,8 @@ static const char driver_name [] =3D "asix
>  #define AX_SWRESET_IPPD                        0x40
> =20
>  #define AX88772_IPG0_DEFAULT           0x15
> -#define AX88772_IPG1_DEFAULT           0x0c
> -#define AX88772_IPG2_DEFAULT           0x12
> +#define AX88772_IPG1_DEFAULT           0x16
> +#define AX88772_IPG2_DEFAULT           0x1A

Is this change correct for the plain AX88772 as well?

>  /* AX88772 & AX88178 Medium Mode Register */
>  #define AX_MEDIUM_PF           0x0080
> @@ -136,6 +136,13 @@ static const char driver_name [] =3D "asix
>  #define AX_DEFAULT_RX_CTL      \
>         (AX_RX_CTL_SO | AX_RX_CTL_AB )
> =20
> +#define AX_PHYSELECT_PSEL      0x01
> +#define AX_PHYSELECT_ASEL      0x02
> +#define AX_PHYSELECT_SSMII     0x04
> +#define AX_PHYSELECT_SSRMII    0x08
> +#define AX_PHYSELECT_SSRRMII   0x0C
> +#define AX_PHYSELECT_SSEN      0x10
> +
>  /* GPIO 0 .. 2 toggles */
>  #define AX_GPIO_GPO0EN         0x01    /* GPIO0 Output enable */
>  #define AX_GPIO_GPO_0          0x02    /* GPIO0 Output value */
> @@ -891,7 +898,11 @@ static int ax88772_link_reset(struct usb
>         if (ecmd.duplex !=3D DUPLEX_FULL)
>                 mode &=3D ~AX_MEDIUM_FD;
> =20
> -       devdbg(dev, "ax88772_link_reset() speed: %d duplex: %d settin=
g mode to 0x%04x", ecmd.speed, ecmd.duplex, mode);
> +       devdbg(dev,
> +       "ax88772_link_reset() speed: %d duplex: %d setting mode to 0x=
%04x",
> +               ecmd.speed,
> +               ecmd.duplex,
> +               mode);

This is just a formatting change so it belongs in a separate patch.  An=
d
if you're going to change it, the format string should be indented
consistently with the other arguments.

>         asix_write_medium_mode(dev, mode);
> =20
> @@ -1018,6 +1029,121 @@ out:
>         return ret;
>  }
> =20
> +static int ax88772a_bind(struct usbnet *dev, struct usb_interface *i=
ntf)
> +{
> +       int ret;
> +       u16 rx_ctl;
> +       struct asix_data *data =3D (struct asix_data *)&dev->data;
> +       u8 buf[ETH_ALEN];
> +       u32 phyid;
> +
> +       data->eeprom_len =3D AX88772_EEPROM_LEN;
> +
> +       usbnet_get_endpoints(dev,intf);
> +
> +       /* Power up the embedded PHY */
> +       if ((ret =3D asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
> +               goto out;

Please separate the assignment and the test.  I know the existing code
combines them and you don't need to fix that, but new code should not d=
o
this.

> +       /* Select the embedded PHY as the active PHY */
> +       if ((ret =3D asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT,
> +                               AX_PHYSELECT_SSEN | AX_PHYSELECT_PSEL=
,
> +                               0, 0, NULL)) < 0) {
> +               dbg("Select PHY #1 failed: %d", ret);
> +               goto out;
> +       }
> +
> +       /* Reload the EEPROM and configure the GPIO pins */
> +       if ((ret =3D asix_write_gpio(dev,
> +               AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_GPIO_GPO2EN, 5)) < 0=
)
> +       goto out;

"goto out;" should be indented.

> +       /* Set embedded PHY in power down state */
> +       if ((ret =3D asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_=
IPPD)) < 0)
> +               goto out;
> +
> +       msleep(10);
> +
> +       /* Set embedded PHY in power up state */
> +       if ((ret =3D asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
> +               goto out;
> +
> +       msleep(60);
> +
> +       /* Set embedded PHY in reset state */
> +       if ((ret =3D asix_sw_reset(dev, AX_SWRESET_CLEAR)) < 0)
> +               goto out;
> +
> +       /* Set embedded PHY in operating state */
> +       if ((ret =3D asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
> +               goto out;
> +
> +       /* Stop RX operation */
> +       if ((ret =3D asix_write_rx_ctl(dev, 0)) < 0)
> +               goto out;      =20
> +
> +       /* Get the MAC address */
> +       if ((ret =3D asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
> +                               0, 0, ETH_ALEN, buf)) < 0) {
> +               dbg("Failed to read MAC address: %d", ret);
> +               goto out;
> +       }
> +       memcpy(dev->net->dev_addr, buf, ETH_ALEN);
> +
> +       /* Initialize MII structure */
> +       dev->mii.dev =3D dev->net;
> +       dev->mii.mdio_read =3D asix_mdio_read;
> +       dev->mii.mdio_write =3D asix_mdio_write;
> +       dev->mii.phy_id_mask =3D 0x1f;
> +       dev->mii.reg_num_mask =3D 0x1f;
> +       dev->net->do_ioctl =3D asix_ioctl;
> +       dev->mii.phy_id =3D asix_get_phy_addr(dev);
> +
> +       phyid =3D asix_get_phyid(dev);
> +       dbg("PHYID=3D0x%08x", phyid);
> +
> +       dev->net->set_multicast_list =3D asix_set_multicast;
> +       dev->net->ethtool_ops =3D &ax88772_ethtool_ops;
> +
> +       asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RES=
ET);
> +       asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
> +                       ADVERTISE_ALL | ADVERTISE_CSMA);
> +       mii_nway_restart(&dev->mii);
> +
> +       if ((ret =3D asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAU=
LT)) < 0)
> +               goto out;
> +
> +       if ((ret =3D asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
> +                               AX88772_IPG0_DEFAULT | AX88772_IPG1_D=
EFAULT,
> +                               AX88772_IPG2_DEFAULT, 0, NULL)) < 0) =
{
> +               dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
> +               goto out;
> +       }
> +
> +       msleep(1);
> +
> +       /* Set RX_CTL to default values with 2k buffer, and enable ca=
ctus */
> +       if ((ret =3D asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
> +               goto out;
> +
> +       rx_ctl =3D asix_read_rx_ctl(dev);
> +       dbg("RX_CTL is 0x%04x after all initializations", rx_ctl);
> +
> +       rx_ctl =3D asix_read_medium_status(dev);
> +       dbg("Medium Status is 0x%04x after all initializations", rx_c=
tl);
> +
> +       /* Asix framing packs multiple eth frames into a 2K usb bulk =
transfer */
> +       if (dev->driver_info->flags & FLAG_FRAMING_AX) {
> +               /* hard_mtu  is still the default - the device does n=
ot support
> +                  jumbo eth frames */
> +               dev->rx_urb_size =3D 2048;
> +       }
> +       return 0;
> +
> +out:
> +       return ret;
> +}
> +
>  static struct ethtool_ops ax88178_ethtool_ops =3D {
>         .get_drvinfo            =3D asix_get_drvinfo,
>         .get_link               =3D asix_get_link,
> @@ -1339,6 +1465,17 @@ static const struct driver_info ax88772_
>         .tx_fixup =3D asix_tx_fixup,
>  };
> =20
> +static const struct driver_info ax88772a_info =3D {
> +       .description =3D "ASIX AX88772A USB 2.0 Ethernet",
> +       .bind =3D ax88772a_bind,
> +       .status =3D asix_status,
> +       .link_reset =3D ax88772_link_reset,
> +       .reset =3D ax88772_link_reset,
> +       .flags =3D FLAG_ETHER | FLAG_FRAMING_AX,
> +       .rx_fixup =3D asix_rx_fixup,
> +       .tx_fixup =3D asix_tx_fixup,
> +};
> +
>  static const struct driver_info ax88178_info =3D {
>         .description =3D "ASIX AX88178 USB 2.0 Ethernet",
>         .bind =3D ax88178_bind,
> @@ -1451,6 +1588,10 @@ static const struct usb_device_id        produ=
c
>         // Cables-to-Go USB Ethernet Adapter
>         USB_DEVICE(0x0b95, 0x772a),
>         .driver_info =3D (unsigned long) &ax88772_info,
> +}, {
> +       // ASIX AX88772A
> +       USB_DEVICE(0x0b95, 0x772a),
> +       .driver_info =3D (unsigned long) &ax88772a_info,

This is matching the same id as the entry above, so how will it ever be
used?  Do the bind operations distinguish them somehow?

=EF=BB=BFPlease also run checkpatch.pl and fix the errors it finds.

Ben.

>  },
>         { },            // END
>  };

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

