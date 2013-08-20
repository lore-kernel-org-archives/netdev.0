From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH-SR9700] Merge USB 1.1 Ethernet Adapter SR9700 Device
 Driver into the Linux Kernel
Date: Tue, 20 Aug 2013 22:46:06 +0200
Message-ID: <20130820204606.GB26241@electric-eye.fr.zoreil.com>
References: <201308201841116403992@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh <gregkh@suse.de>, sunhecheng <sunhecheng@vip.126.com>,
	linux-usb <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: liujunliang_ljl <liujunliang_ljl@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201308201841116403992@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

liujunliang_ljl <liujunliang_ljl@163.com> :
[...]
> We want to merge SR9700 device driver into the Linux Kernel. The following
> is the Linux 3.10.7 version patch for SR9700, Please give us the assessment
> and support.

Welcome. Go ahead.

[...]
> diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
> new file mode 100644
> index 0000000..6a6429a
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

> +	if(err != length && err >= 0)
         ^^ missing space
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

See above.

> +	if (err >= 0 && err < length)
> +		err = -EINVAL;
> +	
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
> +			       value, reg, NULL, 0);

Sic.

> +}
> +
> +static void sr_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
> +{
> +	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
> +					0, reg, data, length);

Sic.

> +}
> +
> +static void sr_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
> +{
> +	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
> +					value, reg, NULL, 0);

Sic.

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
> +			goto out;

			goto out_unlock;

> +
> +		/* ready */
> +		if ((tmp & 1) == 0)

		if ((tmp & EPCR_ERRE) == 0)

> +			break;
> +	}
> +
> +	if (i >= SR_SHARE_TIMEOUT) {
> +		netdev_err(dev->net, "%s read timed out!", phy ? "phy" : "eeprom");
> +		ret = -EIO;
> +		goto out;
> +	}
> +
> +	sr_write_reg(dev, EPCR, 0x0);
> +	ret = sr_read(dev, EPDR, 2, value);
> +
> +	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d",
> +	       phy, reg, *value, ret);
> +
> + out:
   ^ please remove space.

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
> +		goto out;
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
> +			goto out;
> +
> +		/* ready */
> +		if ((tmp & 1) == 0)
> +			break;
> +	}

The 11 lines above are identical in sr_share_read_word. Please refactor.

[...]
> +static int sr_mdio_read(struct net_device *netdev, int phy_id, int loc)
> +{
> +	struct usbnet *dev = netdev_priv(netdev);
> +
> +	__le16 res;

Excess empty line.

> +	int rc = 0;
> +
> +	if (phy_id) {
> +		netdev_dbg(dev->net, "Only internal phy supported");
> +		return 0;
> +	}
> +
> +	/* Access NSR_LINKST bit for link status instead of MII_BMSR */
> +	if(loc == MII_BMSR){
         ^^               ^^
Missing spaces.

> +			u8 value;

Excess tabs and missing empty line.

> +			sr_read_reg(dev, NSR, &value);
> +			if(value & NSR_LINKST) {

Excess tabs, missing spaces, useless "{".

> +				rc = 1;
> +			}
> +	}
> +	sr_share_read_word(dev, 1, loc, &res);
> +	if(rc == 1)
> +			return (le16_to_cpu(res) | BMSR_LSTATUS);
> +	else
> +			return (le16_to_cpu(res) & ~BMSR_LSTATUS);

Excess "(" (aka "return is not a function").

[...]
> +/*-------------------------------------------------------------------------------------------*/

Just say no.

[...]
> +static void sr9700_set_multicast(struct net_device *net)
> +{
> +	struct usbnet *dev = netdev_priv(net);
> +	/* We use the 20 byte dev->data for our 8 byte filter buffer
> +	 * to avoid allocating memory that is tricky to free later */
> +	u8 *hashes = (u8 *) & dev->data;
                             ^extraneous space
> +	u8 rx_ctl = 0x31;	// enable, disable_long, disable_crc

	u8 rx_ctl = RCR_ALL | RCR_DIS_CRC | RCR_DIS_LONG;

> +
> +	memset(hashes, 0x00, SR_MCAST_SIZE);
> +	hashes[SR_MCAST_SIZE - 1] |= 0x80;	/* broadcast address */

Use #define.

> +
> +        if (net->flags & IFF_PROMISC) {
   ^^^^^^^^ should use tab, not space
> +                rx_ctl |= 0x02;
   ^^^... sic
> +        } else if (net->flags & IFF_ALLMULTI ||
> +                   netdev_mc_count(net) > SR_MCAST_MAX) {
> +                rx_ctl |= 0x04;
> +        } else if (!netdev_mc_empty(net)) {
> +                struct netdev_hw_addr *ha;
> + 
> +                netdev_for_each_mc_addr(ha, net) {
> +                        u32 crc = ether_crc(ETH_ALEN, ha->addr) >> 26;
> +                        hashes[crc >> 3] |= 1 << (crc & 0x7);
> +                }
> +        }
   ^^^... etc.
> +
> +	sr_write_async(dev, MAR, SR_MCAST_SIZE, hashes);
> +	sr_write_reg_async(dev, RCR, rx_ctl);
> +}
> +
> +static int sr9700_set_mac_address(struct net_device *net, void *p)
> +{
> +	struct sockaddr *addr = p;
> +	struct usbnet *dev = netdev_priv(net);

Long declaration lines first please.

> +
> +	if (!is_valid_ether_addr(addr->sa_data)) {
> +		dev_err(&net->dev, "not setting invalid mac address %pM\n",
> +								addr->sa_data);

		dev_err(&net->dev, "not setting invalid mac address %pM\n",
			addr->sa_data);

[...]
> +static int sr9700_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> +{
> +	int len;
> +	struct sk_buff *sr_skb;
> +
> +	/* format:
> +	   b0: rx status
> +	   b1: packet length (incl crc) low
> +	   b2: packet length (incl crc) high
> +	   b3..n-4: packet data
> +	   bn-3..bn: ethernet crc
> +	 */
> +
> +	if (unlikely(skb->len < SR_RX_OVERHEAD)) {
> +		dev_err(&dev->udev->dev, "unexpected tiny rx frame\n");
> +		return 0;
> +	}
> +
> +	/*
> +	 * Each packet contains multiple skbs
> +	 */
> +	while (skb->len > SR_RX_OVERHEAD)
> +	{

K&R please.

[...]
> +static struct usb_driver sr9700_usb_driver = {
> +	.name = "sr9700",
> +	.id_table = products,
> +	.probe = usbnet_probe,
> +	.disconnect = usbnet_disconnect,
> +	.suspend = usbnet_suspend,
> +	.resume = usbnet_resume,
> +	.disable_hub_initiated_lpm = 1,

Use <tab>=.

[...]
> diff --git a/drivers/net/usb/sr9700.h b/drivers/net/usb/sr9700.h
> new file mode 100644
> index 0000000..d9fe82d
> --- /dev/null
> +++ b/drivers/net/usb/sr9700.h
> @@ -0,0 +1,152 @@
> +/*
> + * CoreChip-sz SR9700 one chip USB 1.1 Ethernet Devices
> + *
> + * Author : liujl <liujunliang_ljl@163.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + */
> +
> +/* sr9700 spec. register table on android platform */
> +/* Registers */
> +#define	NCR			0x00
> +#define	NSR			0x01
[...]
> +/* Bit definition for registers */
> +// Network Control Reg
> +#define	NCR_RST			(1 << 0)
> +#define	NCR_LBK			(3 << 1)
> +#define	NCR_FDX			(1 << 3)
> +#define	NCR_WAKEEN		(1 << 6)

You may group these with the register declarations above. Use an
offset to improve readability and separate registers from fields.

See drivers/net/ethernet/broadcom/tg3.h for instance.

-- 
Ueimor
