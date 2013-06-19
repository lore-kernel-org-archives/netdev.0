From: Andi Shyti <andi@etezian.org>
Subject: Re: [PATCH 1/1] net: add dm9620 net usb driver
Date: Wed, 19 Jun 2013 15:20:28 +0200
Message-ID: <20130619132028.GC13898@jack.whiskey>
References: <1371645407-31387-1-git-send-email-josright123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, joseph_chang@davicom.com.tw,
	josright@hotmail.com
To: Joseph CHANG <josright123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1371645407-31387-1-git-send-email-josright123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joseph,

had a fast look...

[ ... ]

> +static int dm9620_set_eeprom(struct net_device *net,
> +		struct ethtool_eeprom *eeprom, u8 *data)
> +{
> +	struct usbnet *dev = netdev_priv(net);
> +	int offset = eeprom->offset;
> +	int len = eeprom->len;
> +	int done;
> +
> +	if (eeprom->magic != MD96XX_EEPROM_MAGIC) {
> +		netdev_err(dev->net, "EEPROM: magic value mismatch, magic = 0x%x\n",
> +			eeprom->magic);
> +		return -EINVAL;
> +	}
> +
> +	while (len > 0) {
> +		if (len & 1 || offset & 1) {
> +			int which = offset & 1;
> +			u8 tmp[2];
> +			dm_read_eeprom_word(dev, offset / 2, tmp);
> +			tmp[which] = *data;
> +			dm_write_eeprom_word(dev, offset / 2, tmp);
> +			mdelay(10);

Please don't use mdelay, use msleep or possibly
msleep_interruptable

> +			done = 1;
> +		} else {
> +			dm_write_eeprom_word(dev, offset / 2, data);
> +			done = 2;
> +		}
> +		data += done;
> +		offset += done;
> +		len -= done;
> +	}
> +	return 0;
> +}

[ ... ]

> +static int dm9620_bind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +	int ret;
> +	u8 mac[ETH_ALEN], id;
> +	u16 value;
> +
> +	ret = usbnet_get_endpoints(dev, intf);
> +	if (ret)
> +		goto out;

maybe here is better

	if (ret)
		return ret;

> +
> +	dev->net->netdev_ops = &dm9620_netdev_ops;
> +	dev->net->ethtool_ops = &dm9620_ethtool_ops;
> +	dev->net->hard_header_len += DM_TX_OVERHEAD;
> +	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
> +
> +	/* ftp fail fixed */
> +	dev->rx_urb_size = dev->net->mtu + ETH_HLEN + DM_RX_OVERHEAD+1;
> +
> +	dev->mii.dev = dev->net;
> +	dev->mii.mdio_read = dm9620_mdio_read;
> +	dev->mii.mdio_write = dm9620_mdio_write;
> +	dev->mii.phy_id_mask = 0x1f;
> +	dev->mii.reg_num_mask = 0x1f;
> +	dev->mii.phy_id = DM9620_PHY_ID;
> +
> +	/* reset */
> +	dm_write_reg(dev, DM_NET_CTRL, 1);
> +	udelay(20);

from Documentation/timers/timers-howto.txt:

        SLEEPING FOR "A FEW" USECS ( < ~10us? ):
                * Use udelay

use udelay if you want to sleep for less than 10us, otherwise use
usleep_range

> +
> +	/* read MAC */
> +	if (dm_read(dev, DM_PHY_ADDR, ETH_ALEN, mac) < 0) {
> +		netdev_err(dev->net, "Error reading MAC address\n");
> +		ret = -ENODEV;
> +		goto out;
> +	}

you can get read of the 'out' label if in all the goto you use
you just 'return -ENODEV;' instead of 'goto out;'

> +
> +	/* Overwrite the auto-generated address only with good ones */
> +	if (is_valid_ether_addr(mac))
> +		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
> +	else {
> +		netdev_warn(dev->net,
> +			"dm9620: No valid MAC address in EEPROM, using %pM\n",
> +			dev->net->dev_addr);
> +		__dm9620_set_mac_address(dev);
> +	}
> +
> +	if (dm_read_reg(dev, DM_CHIP_ID, &id) < 0) {
> +		netdev_err(dev->net, "Error reading chip ID\n");
> +		ret = -ENODEV;
> +		goto out;

same here

> +	}
> +
> +	dm_read(dev, DM_PID, 2, &value);
> +
> +	/* Add for check Product dm9620a/21a */
> +	if (value == 0x1269 || value == 0x0269)
> +		dm_write_reg(dev, DM_MODE_CTRL, DM_MODE9620 | DM_MODE_CDC_DES);
> +	else
> +		dm_write_reg(dev, DM_MODE_CTRL, DM_MODE9620);
> +
> +	dm_write_reg(dev, DM_RX_CRC_CTRL, DM_RX_RCSEN);
> +
> +	/* power up phy */
> +	dm_write_reg(dev, DM_GPR_CTRL, 1);
> +	dm_write_reg(dev, DM_GPR_DATA, 0);
> +
> +	/* receive broadcast packets */
> +	dm9620_set_multicast(dev->net);
> +
> +	dm9620_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
> +
> +	/* TX Pause Packet Enable */
> +	dm_write_reg(dev, DM_FCR, DM_FCR_TXPEN | DM_FCR_BKPM | DM_FCR_FLCE);
> +
> +	/* ADVERTISE_PAUSE_CAP */
> +	dm9620_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
> +		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
> +
> +	dm_write_reg(dev, DM_USB_CTRL, DM_USB_EP3ACK);
> +
> +	mii_nway_restart(&dev->mii);
> +
> +out:
> +	return ret;

yeah... you wouldn't need this anymore

> +}
> +
> +void dm9620_unbind(struct usbnet *dev, struct usb_interface *intf)

Should this be static?

> +{
> +	netdev_warn(dev->net, "[dm962] Linux Driver = V2.6 - unbind\n");
> +}
> +
> +static int dm9620_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> +{
> +	u8 status;
> +	int len;
> +
> +	/* format:
> +	   b0: rx_flag
> +	   b1: rx status
> +	   b2: packet length (incl crc) low
> +	   b3: packet length (incl crc) high
> +	   b4..n-4: packet data
> +	   bn-3..bn: ethernet crc
> +	 */

Allow me this nitpick please check the coding style for comments
in Documentation/CodyngStyle:

For files in net/ and drivers/net/ the preferred style for long (multi-line)
comments is a little different.

	/* The preferred comment style for files in net/ and
	 * drivers/net
	 * looks like this.
	 *
	 * It is nearly the same as the generally preferred
	 * comment style,
	 * but there is no initial almost-blank line.
	 */

> +	if (unlikely(skb->len < DM_RX_OVERHEAD)) {
> +		dev_err(&dev->udev->dev, "unexpected tiny rx frame\n");
> +		return 0;
> +	}
> +
> +	status = skb->data[1];
> +	len = (skb->data[2] | (skb->data[3] << 8)) - 4;
> +
> +	if (unlikely(status & 0xbf)) {
> +		if (status & 0x01)
> +			dev->net->stats.rx_fifo_errors++;
> +		if (status & 0x02)
> +			dev->net->stats.rx_crc_errors++;
> +		if (status & 0x04)
> +			dev->net->stats.rx_frame_errors++;
> +		if (status & 0x20)
> +			dev->net->stats.rx_missed_errors++;
> +		if (status & 0x90)
> +			dev->net->stats.rx_length_errors++;
> +		return 0;
> +	}
> +
> +	skb_pull(skb, 4);
> +	skb_trim(skb, len);
> +
> +	return 1;
> +}
> +
> +static bool davicom_bulkout_fix(int len, unsigned fullp)
> +{
> +	len = ((len+1)/2)*2;
> +	len += 2;
> +	if ((len % fullp) == 0)
> +		return true;
> +	return false;

personally here I like more the form

	return !(len % fullp) ? true : false;

But this is more a nitpick, you don't really need to change

> +}
> +
> +static int dm9620_tx_oddadd_len(int len)
> +{
> +	if (len & 1)
> +		return 1;
> +	return 0;

(len & 1) is the same as (len == 1), personally I find it a bit
ugly, I would rather write it differently:

	return (len == 1) ? 1 : 0;

or if you like the '&'

	return len & 1;

> +}
> +
> +static const struct usb_device_id products[] = {
> +	{
> +	 USB_DEVICE(0x0a46, 0x9620),	/* dm9620 */
> +	 .driver_info = (unsigned long)&dm9620_info,
> +	 },
> +	{
> +	 USB_DEVICE(0x0a46, 0x9621),	/* dm9621 */
> +	 .driver_info = (unsigned long)&dm9620_info,
> +	 },
> +	{
> +	 USB_DEVICE(0x0a46, 0x9622),	/* dm9622 */
> +	 .driver_info = (unsigned long)&dm9620_info,
> +	 },
> +	{
> +	 USB_DEVICE(0x0a46, 0x0269),	/* dm9620a */
> +	 .driver_info = (unsigned long)&dm9620_info,
> +	 },
> +	{
> +	 USB_DEVICE(0x0a46, 0x1269),	/* dm9621a */
> +	 .driver_info = (unsigned long)&dm9620_info,
> +	 },
> +	{},
> +};

It would be cool if in the code we could have some logical
defines for all the hexadecimal values you are using all around
the code ;)

Andi
