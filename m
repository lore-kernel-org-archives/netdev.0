From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Wed, 01 Oct 2008 12:14:13 +0100
Message-ID: <1222859653.3984.45.camel@achroite>
References: <1222698624-3689-1-git-send-email-steve.glendinning@smsc.com>
	 <1222698624-3689-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Jeff Garzik <jeff@garzik.org>,
	David Brownell <dbrownell@users.sourceforge.net>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:44181 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752117AbYJALO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 07:14:27 -0400
In-Reply-To: <1222698624-3689-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-09-29 at 15:30 +0100, Steve Glendinning wrote:
[...]=20
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> new file mode 100644
> index 0000000..b7c5fd4
> --- /dev/null
> +++ b/drivers/net/usb/smsc95xx.c
[...]=20
> +u32 debug_mode;
> +module_param(debug_mode, uint, 0);
> +MODULE_PARM_DESC(debug_mode, "enable/disable debug messages");

This parameter doesn't appear to be used.

> +int turbo_mode =3D true;
> +module_param(turbo_mode, bool, 0);
> +MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transact=
ion");

Why is this parameter not exposed through sysfs (perm =3D 0)?

[...]
> =EF=BB=BF+/* Loop until the read is completed with timeout
> + * called with phy_mutex held */
> +static int smsc95xx_phy_wait_not_busy(struct usbnet *dev)
> +{
> +       int i;
> +       u32 val;
> +
> +       for (i =3D 0; i < 100; i++) {
> +               smsc95xx_read_reg(dev, MII_ADDR, &val);
> +               if (!(val & MII_BUSY_))
> +                       return 0;
> +               udelay(1);
> +       }
> +
> +       return -EIO;
> +}

Doesn't a register read over USB normally take much longer than 1 us,
meaning that this can wait much longer than 100 us?  If so, please
consider setting and checking a timeout based on jiffies.

There may be a similar issue with EEPROM access.

[...]
> +static int smsc95xx_link_reset(struct usbnet *dev)
> +{
> +	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[=
0]);
> +	struct ethtool_cmd ecmd;
> +	unsigned long flags;
> +	u32 intdata;
> +
> +	/* clear interrupt status */
> +	smsc95xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
> +	intdata =3D 0xFFFFFFFF;
> +	smsc95xx_write_reg(dev, INT_STS, intdata);
> +
> +	mii_check_media(&dev->mii, 1, 1);
> +	mii_ethtool_gset(&dev->mii, &ecmd);
> +
> +	if (netif_msg_link(dev))
> +		devdbg(dev, "speed: %d duplex: %d", ecmd.speed, ecmd.duplex);
> +
> +	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
> +	if (ecmd.duplex !=3D DUPLEX_FULL) {
> +		pdata->mac_cr &=3D ~MAC_CR_FDPX_;
> +		pdata->mac_cr |=3D MAC_CR_RCVOWN_;
> +	} else {
> +		pdata->mac_cr &=3D ~MAC_CR_RCVOWN_;
> +		pdata->mac_cr |=3D MAC_CR_FDPX_;
> +	}
> +	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
> +
> +	smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
> +
> +	smsc95xx_phy_update_flowcontrol(dev, &ecmd);

Doesn't this force flow control settings to be whatever we were
advertising, regardless of link partner abilities?

[...]
> +static u32 smsc95xx_ethtool_get_rx_csum(struct net_device *netdev)
> +{
> +	struct usbnet *dev =3D netdev_priv(netdev);
> +	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[=
0]);
> +
> +	return pdata->use_rx_csum ? true : false;
> +}

Delete "? true : false"; it's just silly.

> +static int smsc95xx_ethtool_set_rx_csum(struct net_device *netdev, u=
32 val)
> +{
> +	struct usbnet *dev =3D netdev_priv(netdev);
> +	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[=
0]);
> +
> +	pdata->use_rx_csum =3D val ? true : false;

The idiomatic way to write this is !!val.

> +	return smsc95xx_set_rx_csum(dev, pdata->use_rx_csum);
> +}
[...]

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

