From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Tue, 09 Sep 2008 14:19:47 +0100
Message-ID: <1220966387.2381.42.camel@achroite>
References: <1220960196-4209-1-git-send-email-steve.glendinning@smsc.com>
	 <1220960196-4209-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-usb@vger.kernel.org
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:48109 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756615AbYIINUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 09:20:00 -0400
In-Reply-To: <1220960196-4209-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-09-09 at 12:36 +0100, Steve Glendinning wrote:
[...]
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> new file mode 100644
> index 0000000..60ffd90
> --- /dev/null
> +++ b/drivers/net/usb/smsc95xx.c
[...]
> +static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *dat=
a)
> +{
> +	u32 *buf =3D kmalloc(4, GFP_KERNEL);
> +	int ret;
> +
> +	BUG_ON(!dev);
> +
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	ret =3D usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> +		USB_VENDOR_REQUEST_READ_REGISTER,
> +		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
> +		00, index, buf, 4, USB_CTRL_GET_TIMEOUT);
> +
> +	if (unlikely(ret < 0))
> +		SMSC_WARNING("Failed to read register index 0x%08x", index);
> +
> +	le32_to_cpus(buf);
> +	*data =3D *buf;
> +	kfree(buf);
> +
> +	return ret;
> +}

Why are you allocating a buffer on the heap?  What's wrong with

static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
{
	int ret;

	BUG_ON(!dev);

	ret =3D usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
		USB_VENDOR_REQUEST_READ_REGISTER,
		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
		00, index, data, 4, USB_CTRL_GET_TIMEOUT);

	if (unlikely(ret < 0))
		SMSC_WARNING("Failed to read register index 0x%08x", index);

	le32_to_cpus(data);

	return ret;
}

?

Similarly for smsc95xx_write_reg().

> +static void smsc95xx_mdio_write(struct net_device *netdev, int phy_i=
d, int idx,
> +				int regval)
> +{
[...]
> +	return;
> +}

Don't put an explicit "return" at the end of a void function.

> +static int smsc95xx_eeprom_is_busy(struct usbnet *dev)
> +{
> +	u32 val;
> +	int i;
> +
> +	for (i =3D 0; i < 1000; i++) {
> +		smsc95xx_read_reg(dev, E2P_CMD, &val);
> +		if (!(val & E2P_CMD_BUSY_) || (val & E2P_CMD_TIMEOUT_))
> +			break;
> +		udelay(40);
> +	}
> +
> +	if (val & (E2P_CMD_TIMEOUT_ | E2P_CMD_BUSY_)) {
> +		SMSC_WARNING(KERN_WARNING "EEPROM read operation timeout");
> +		return -EIO;
> +	}
> +
> +	return 0;
> +}

This function name implies that the function tests once and returns a
boolean.  It should be named something like smsc95xx_wait_eeprom().

[...]
> +static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32=
 length,
> +				 u8 *data)
> +{
> +	u32 val;
> +	int i, ret;
> +
> +	BUG_ON(!dev);
> +	BUG_ON(!data);
> +
> +	/* confirm eeprom not busy */
> +	for (i =3D 0; i < 1000; i++) {
> +		smsc95xx_read_reg(dev, E2P_CMD, &val);
> +		if (!(val & E2P_CMD_BUSY_))
> +			break;
> +		udelay(40);
> +	}
> +
> +	if (val & E2P_CMD_BUSY_) {
> +		SMSC_WARNING("EEPROM is busy");
> +		return -EIO;
> +	}

Do you not want to check E2P_CMD_LOADED_ here, as in
smsc95xx_read_eeprom()?

> +	/* Issue write/erase enable command */
> +	val =3D E2P_CMD_BUSY_ | E2P_CMD_EWEN_;
> +	smsc95xx_write_reg(dev, E2P_CMD, val);
> +
> +	ret =3D smsc95xx_eeprom_is_busy(dev);
> +	if (ret < 0)
> +		return ret;
> +
> +	for (i =3D 0; i < length; i++) {
> +
> +		/* Fill data register */
> +		val =3D data[i];
> +		smsc95xx_write_reg(dev, E2P_DATA, val);
> +
> +		/* Send "write" command */
> +		val =3D E2P_CMD_BUSY_ | E2P_CMD_WRITE_ | (offset & E2P_CMD_ADDR_);
> +		smsc95xx_write_reg(dev, E2P_CMD, val);
> +
> +		ret =3D smsc95xx_eeprom_is_busy(dev);
> +		if (ret < 0)
> +			return ret;
> +
> +		offset++;
> +	}
> +
> +	return 0;
> +}
[...]
> +static void smsc95xx_validate_mac(struct usbnet *dev)
> +{
> +	/* try reading mac address from EEPROM */
> +	if (smsc95xx_read_eeprom(dev, EEPROM_MAC_OFFSET, ETH_ALEN,
> +			dev->net->dev_addr) =3D=3D 0) {
> +		if (is_valid_ether_addr(dev->net->dev_addr)) {
> +			/* eeprom values are valid so use them */
> +			SMSC_TRACE(DBG_INIT, "Mac Address read from EEPROM");
> +			return;
> +		}
> +	}
> +
> +	/* no eeprom, or eeprom values are invalid. generate random MAC */
> +	random_ether_addr(dev->net->dev_addr);
> +	SMSC_TRACE(DBG_INIT, "MAC Address set to random_ether_addr");
> +}

This function doesn't just validate a MAC address - it reads, validates
and potentially replaces it.  It should be named something like
smsc95xx_init_mac_address().

> +static int smsc95xx_reset(struct usbnet *dev)
> +{
[...]
> +	smsc95xx_start_tx_path(dev);

=EF=BB=BFIf there's an error after this point the TX path is left enabl=
ed.  Is that safe?

> +	/* Init Rx */
> +	/* Set Vlan */
> +	write_buf =3D (u32)ETH_P_8021Q;
> +	ret =3D smsc95xx_write_reg(dev, VLAN1, write_buf);
> +	if (ret < 0) {
> +		SMSC_WARNING("Failed to write VAN1: %d", ret);
> +		return ret;
> +	}
> +
> +	/* Enable or disable Rx checksum offload engine */
> +	ret =3D smsc95xx_set_rx_csum(dev, pdata->use_rx_csum);
> +	if (ret < 0) {
> +		SMSC_WARNING("Failed to set Rx csum offload: %d", ret);
> +		return ret;
> +	}
> +
> +	smsc95xx_start_rx_path(dev);
=EF=BB=BF[...]

Similarly the RX path is left enabled if there's an error after this
point.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

