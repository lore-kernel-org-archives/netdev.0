From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] smsc95xx: support ethtool get_regs
Date: Sat, 7 Jul 2012 01:24:11 +0100
Message-ID: <1341620651.2923.49.camel@bwh-desktop.uk.solarflarecom.com>
References: <1847398984.224080.1341598531284.JavaMail.root@mail.savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve@shawell.net>,
	steve glendinning <steve.glendinning@smsc.com>,
	<netdev@vger.kernel.org>, Nancy Lin <nancy.lin@smsc.com>
To: =?ISO-8859-1?Q?=C9meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16048 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751694Ab2GGAYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 20:24:14 -0400
In-Reply-To: <1847398984.224080.1341598531284.JavaMail.root@mail.savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 14:15 -0400, =C3=89meric Vigier wrote:
> From: Emeric Vigier <emeric.vigier@savoirfairelinux.com>
>=20
> Inspired by implementation in smsc911x.c and smsc9420.c
> Tested on ARM/pandaboard rev A3
>=20
> Signed-off-by: Emeric Vigier <emeric.vigier@savoirfairelinux.com>
> ---
>  drivers/net/usb/smsc95xx.c |   37 ++++++++++++++++++++++++++++++++++=
+++
>  1 files changed, 37 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index b1112e7..bce14f6 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -578,6 +578,41 @@ static int smsc95xx_ethtool_set_eeprom(struct ne=
t_device *netdev,
>  	return smsc95xx_write_eeprom(dev, ee->offset, ee->len, data);
>  }
> =20
> +
> +static int smsc95xx_ethtool_getregslen(struct net_device *dev)
> +{
> +	/* all smsc95xx registers plus all phy registers */
> +	return COE_CR - ID_REV + 1 + 32 * sizeof(u32);
> +}
> +
> +static void
> +smsc95xx_ethtool_getregs(struct net_device *netdev, struct ethtool_r=
egs *regs,
> +			 void *buf)
> +{
> +	struct usbnet *dev =3D netdev_priv(netdev);
> +	unsigned int i, j =3D 0, retval;
> +	u32 *data =3D buf;
> +
> +	netif_dbg(dev, hw, dev->net, "ethtool_getregs\n");
> +
> +	retval =3D smsc95xx_read_reg(dev, ID_REV, &regs->version);
> +	if (retval < 0) {
> +		netdev_warn(dev->net, "REGS: cannot read ID_REV\n");
> +		return;
> +	}
> +
> +	for (i =3D 0; i <=3D COE_CR; i +=3D (sizeof(u32))) {
> +		retval =3D smsc95xx_read_reg(dev, i, &data[j++]);
> +		if (retval < 0) {
> +			netdev_warn(dev->net, "REGS: cannot read reg[%x]\n", i);
> +			return;
> +		}
> +	}

Why does this start with i =3D 0 whereas the calculation of the length
uses ID_REV as the starting point?  Maybe ID_REV =3D=3D 0, but you shou=
ld be
consistent in whether you use the name or literal number.

> +	for (i =3D 0; i <=3D PHY_SPECIAL; i++)
> +		data[j++] =3D smsc95xx_mdio_read(netdev, dev->mii.phy_id, i);
> +}

Again, why use PHY_SPECIAL (+ 1) here as opposed to 32 in the
calculation of the length?

Ben.

>  static const struct ethtool_ops smsc95xx_ethtool_ops =3D {
>  	.get_link	=3D usbnet_get_link,
>  	.nway_reset	=3D usbnet_nway_reset,
> @@ -589,6 +624,8 @@ static const struct ethtool_ops smsc95xx_ethtool_=
ops =3D {
>  	.get_eeprom_len	=3D smsc95xx_ethtool_get_eeprom_len,
>  	.get_eeprom	=3D smsc95xx_ethtool_get_eeprom,
>  	.set_eeprom	=3D smsc95xx_ethtool_set_eeprom,
> +	.get_regs_len	=3D smsc95xx_ethtool_getregslen,
> +	.get_regs	=3D smsc95xx_ethtool_getregs,
>  };
> =20
>  static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *r=
q, int cmd)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
