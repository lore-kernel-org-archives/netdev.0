From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Re: [PATCH-SR9700] Merge USB 1.1 Ethernet Adapter SR9700
 DeviceDriver into the Linux Kernel
Date: Wed, 21 Aug 2013 22:33:11 +0200
Message-ID: <20130821203311.GA23527@electric-eye.fr.zoreil.com>
References: <201308201841116403992@163.com>
 <20130820204606.GB26241@electric-eye.fr.zoreil.com>
 <201308211805574844059@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh <gregkh@suse.de>, sunhecheng <sunhecheng@vip.126.com>,
	linux-usb <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: liujunliang_ljl <liujunliang_ljl@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201308211805574844059@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

liujunliang_ljl <liujunliang_ljl@163.com> :
[...]
> diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
> new file mode 100644
> index 0000000..9c8f167
> --- /dev/null
> +++ b/drivers/net/usb/sr9700.c
[...]
> +static int sr_read(struct usbnet *dev, u8 reg, u16 length, void *data)
> +{
> +	int err;
> +
> +	err = usbnet_read_cmd(dev, SR_RD_REGS, SR_REQ_RD_REG,
> +					0, reg, data, length);

	err = usbnet_read_cmd(dev, SR_RD_REGS, SR_REQ_RD_REG, 0, reg, data,
			      length);

(I already outlined it in my first review)

> +	if ((err != length) && (err >= 0))
> +		err = -EINVAL;
> +	return err;
> +}
> +
> +static int sr_write(struct usbnet *dev, u8 reg, u16 length, void *data)
> +{
> +	int err;
> +
> +	err = usbnet_write_cmd(dev, SR_WR_REGS, SR_REQ_WR_REG,
> +					0, reg, data, length);

See my first review as well.

> +	if ((err >= 0) && (err < length))
> +		err = -EINVAL;
> +	return err;
> +}
> +
> +static int sr_read_reg(struct usbnet *dev, u8 reg, u8 *value)
> +{
> +	return sr_read(dev, reg, 1, value);
> +}
> +
> +static int sr_write_reg(struct usbnet *dev, u8 reg, u8 value)
> +{
> +	return usbnet_write_cmd(dev, SR_WR_REGS, SR_REQ_WR_REG,
> +					value, reg, NULL, 0);

See my first review as well.

> +}
> +
> +static void sr_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
> +{
> +	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
> +					0, reg, data, length);

See my first review as well.

> +}
> +
> +static void sr_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
> +{
> +	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
> +					value, reg, NULL, 0);

See my first review as well.

> +}
> +
> +static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg, __le16 *value)
> +{
> +	int ret, i;
> +
> +	mutex_lock(&dev->phy_mutex);
> +
> +	sr_write_reg(dev, EPAR, phy ? (reg | 0x40) : reg);
> +	sr_write_reg(dev, EPCR, phy ? 0xc : 0x4);
> +
> +	for (i = 0; i < SR_SHARE_TIMEOUT; i++) {
> +		u8 tmp = 0;
> +
> +		udelay(1);
> +		ret = sr_read_reg(dev, EPCR, &tmp);
> +		if (ret < 0)
> +			goto out_unlock;
> +
> +		/* ready */
> +		if ((tmp & EPCR_ERRE) == 0)
> +			break;
> +	}
> +
> +	if (i >= SR_SHARE_TIMEOUT) {
> +		netdev_err(dev->net, "%s read timed out!\n", phy ? "phy" : "eeprom");
> +		ret = -EIO;
> +		goto out_unlock;
> +	}
> +
> +	sr_write_reg(dev, EPCR, 0x0);
> +	ret = sr_read(dev, EPDR, 2, value);
> +
> +	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d\n",
> +	       phy, reg, *value, ret);
> +
> + out_unlock:
   ^ please remove space.

(you renamed it but the "no space before label" part has been ignored)

> +	mutex_unlock(&dev->phy_mutex);
> +	return ret;
> +}
> +
> +static int sr_share_write_word(struct usbnet *dev, int phy, u8 reg, __le16 value)
> +{
> +	int ret, i;
> +
> +	mutex_lock(&dev->phy_mutex);
> +
> +	ret = sr_write(dev, EPDR, 2, &value);
> +	if (ret < 0)
> +		goto out_unlock;
> +
> +	sr_write_reg(dev, EPAR, phy ? (reg | 0x40) : reg);
> +	sr_write_reg(dev, EPCR, phy ? 0x1a : 0x12);
> +
> +	for (i = 0; i < SR_SHARE_TIMEOUT; i++) {
> +		u8 tmp = 0;
> +
> +		udelay(1);
> +		ret = sr_read_reg(dev, EPCR, &tmp);
> +		if (ret < 0)
> +			goto out_unlock;
> +
> +		/* ready */
> +		if ((tmp & EPCR_ERRE) == 0)
> +			break;
> +	}

I made a remark about the 11 lines above in my first review. May I politely
ask you to read it again ?

[...]
> +static const struct ethtool_ops sr9700_ethtool_ops = {
> +	.get_drvinfo	= usbnet_get_drvinfo,
> +	.get_link		= sr9700_get_link,
> +	.get_msglevel	= usbnet_get_msglevel,
> +	.set_msglevel	= usbnet_set_msglevel,
> +	.get_eeprom_len	= sr9700_get_eeprom_len,
> +	.get_eeprom		= sr9700_get_eeprom,
> +	.get_settings	= usbnet_get_settings,
> +	.set_settings	= usbnet_set_settings,
> +	.nway_reset		= usbnet_nway_reset,

The fields above line up nicely with a 4 spaces tabulation but the
standard kernel one is 8 spaces wide.

[...]
> +static const struct net_device_ops sr9700_netdev_ops = {
> +	.ndo_open			= usbnet_open,
> +	.ndo_stop			= usbnet_stop,
> +	.ndo_start_xmit		= usbnet_start_xmit,
> +	.ndo_tx_timeout		= usbnet_tx_timeout,
> +	.ndo_change_mtu		= usbnet_change_mtu,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_do_ioctl		= sr9700_ioctl,
> +	.ndo_set_rx_mode	= sr9700_set_multicast,
> +	.ndo_set_mac_address	= sr9700_set_mac_address,

Same 4 vs 8 spaces tabs problem as above.

[...]
> +static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +	int ret;
> +
> +	ret = usbnet_get_endpoints(dev, intf);
> +	if (ret)
> +		goto out;
> +
> +	dev->net->netdev_ops = &sr9700_netdev_ops;
> +	dev->net->ethtool_ops = &sr9700_ethtool_ops;
> +	dev->net->hard_header_len += SR_TX_OVERHEAD;
> +	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
> +	dev->rx_urb_size = 3072;	/* bulkin buffer is preferably not less than 3K */
> +
> +	dev->mii.dev = dev->net;
> +	dev->mii.mdio_read = sr_mdio_read;
> +	dev->mii.mdio_write = sr_mdio_write;
> +	dev->mii.phy_id_mask = 0x1f;
> +	dev->mii.reg_num_mask = 0x1f;

Please add local dev->net and dev->mii variables.

[...]
> +	/* power up and reset phy */
> +	sr_write_reg(dev, PRR, 1);

Please replace '1' with appropriate #define.

> +	mdelay(20);		/* at least 10ms, here 20ms for safe */
> +	sr_write_reg(dev, PRR, 0);

Please replace '0' with appropriate #define.

[...]
> +static int sr9700_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> +{
> +	int len;
> +	struct sk_buff *sr_skb;

	struct sk_buff *sr_skb;
	int len;

(long lines first)

[...]
> +	/* Each packet contains multiple skbs */
> +	while (skb->len > SR_RX_OVERHEAD) {
> +		if (skb->data[0] != 0x40)
> +			return 0;
> +
> +		/* ignore the CRC length */
> +		len = (skb->data[1] | (skb->data[2] << 8)) - 4;
> +
> +		if (len > ETH_FRAME_LEN)
> +			return 0;
> +
> +		/* the last skb of current packet */
> +		if (skb->len == (len + SR_RX_OVERHEAD))	{
> +			skb_pull(skb, 3);
> +			skb->len = len;
> +			skb->tail = skb->data + len;
> +			skb->truesize = len + sizeof(struct sk_buff);
> +			return 2;
> +		}
> +
> +		/* skb_clone is used for address align */
> +		sr_skb = skb_clone(skb, GFP_ATOMIC);
> +		if (sr_skb) {

		if (!sr_skb)
			return 0;

> +			sr_skb->len = len;
> +			sr_skb->data = skb->data + 3;
> +			sr_skb->tail = skb->data + len;
> +			sr_skb->truesize = len + sizeof(struct sk_buff);
> +			usbnet_skb_return(dev, sr_skb);
> +		} else {
> +			return 0;
> +		}
> +
> +		skb_pull(skb, len + SR_RX_OVERHEAD);
> +	};
> +
> +	return 0;
> +}
[...]
> +static struct usb_driver sr9700_usb_driver = {
> +	.name = "sr9700",
> +	.id_table = products,
> +	.probe = usbnet_probe,
> +	.disconnect = usbnet_disconnect,
> +	.suspend = usbnet_suspend,
> +	.resume = usbnet_resume,
> +	.disable_hub_initiated_lpm = 1,
> +};

Please line things up (see my first review).

[...]
> ???????? Francois Romieu 
> ?????????? 2013-08-21  04:46:12 
> ???????? liujunliang_ljl 
> ?????? gregkh; sunhecheng; linux-usb; netdev; linux-kernel 
> ?????? Re: [PATCH-SR9700] Merge USB 1.1 Ethernet Adapter SR9700 DeviceDriver into the Linux Kernel 

Please avoid full quote and top posting.

-- 
Ueimor
