From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Please pull 'upstream-rtl8187' branch of wireless-2.6
Date: Wed, 9 May 2007 22:16:22 -0400
Message-ID: <200705092216.26880.flamingice@sourmilk.net>
References: <20070508173907.GH6479@tuxdriver.com> <20070508174118.GI6479@tuxdriver.com> <46425564.3040505@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2634848.ZiXQvLfLMr";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46425564.3040505-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart2634848.ZiXQvLfLMr
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 09 May 2007 19:12, Jeff Garzik wrote:
> John W. Linville wrote:
> > +static inline void eeprom_93cx6_pulse_high(struct eeprom_93cx6 *eeprom)
> > +{
> > +	eeprom->reg_data_clock =3D 1;
> > +	eeprom->register_write(eeprom);
> > +	udelay(1);
> > +}
> > +
> > +static inline void eeprom_93cx6_pulse_low(struct eeprom_93cx6 *eeprom)
> > +{
> > +	eeprom->reg_data_clock =3D 0;
> > +	eeprom->register_write(eeprom);
> > +	udelay(1);
> > +}
>
> udelay-after-write normally indicates a PCI posting bug (or USB bus
> delay bug)
>
Things may go bad if we try to bitbang the eeprom too fast.

> > +void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom, const u8 word,
> > +	u16 data)
> > +{
> > +	u16 command;
> > +
> > +	/*
> > +	 * select the ewen opcode.
> > +	 */
> > +	eeprom_93cx6_ewen(eeprom);
> > +
> > +	/*
> > +	 * Initialize the eeprom register
> > +	 */
> > +	eeprom_93cx6_startup(eeprom);
> > +
> > +	/*
> > +	 * Select the write opcode and the word to be read.
> > +	 */
> > +	command =3D (PCI_EEPROM_WRITE_OPCODE << eeprom->width) | word;
> > +	eeprom_93cx6_write_bits(eeprom, command,
> > +		PCI_EEPROM_WIDTH_OPCODE + eeprom->width);
> > +
> > +	/*
> > +	 * Write the requested 16 bits.
> > +	 */
> > +	eeprom_93cx6_write_bits(eeprom, data, 16);
> > +
> > +	/*
> > +	 * Cleanup eeprom register.
> > +	 */
> > +	eeprom_93cx6_cleanup(eeprom);
> > +
> > +	/*
> > +	 * Take a short break.
> > +	 */
> > +	msleep(10000);
>
> WTF?
>
> First of all, use ssleep()
>
> Second of all, include a non-sarcastic comment that actually describes
> the reason for the delay, and why it needs to be so long.
>
This function can be dropped entirely. (no driver bothers to write to the=20
eeprom yet)

> > +static inline u8 rtl818x_ioread8(struct rtl8187_priv *priv, u8 *addr)
> > +{
> > +	u8 val;
> > +
> > +	usb_control_msg(priv->udev, usb_rcvctrlpipe(priv->udev, 0),
> > +			RTL8187_REQ_GET_REG, RTL8187_REQT_READ,
> > +			(unsigned long)addr, 0, &val, sizeof(val), HZ / 2);
> > +
> > +	return val;
> > +}
> > +
> > +static inline u16 rtl818x_ioread16(struct rtl8187_priv *priv, __le16
> > *addr) +{
> > +	__le16 val;
> > +
> > +	usb_control_msg(priv->udev, usb_rcvctrlpipe(priv->udev, 0),
> > +			RTL8187_REQ_GET_REG, RTL8187_REQT_READ,
> > +			(unsigned long)addr, 0, &val, sizeof(val), HZ / 2);
> > +
> > +	return le16_to_cpu(val);
> > +}
> > +
> > +static inline u32 rtl818x_ioread32(struct rtl8187_priv *priv, __le32
> > *addr) +{
> > +	__le32 val;
> > +
> > +	usb_control_msg(priv->udev, usb_rcvctrlpipe(priv->udev, 0),
> > +			RTL8187_REQ_GET_REG, RTL8187_REQT_READ,
> > +			(unsigned long)addr, 0, &val, sizeof(val), HZ / 2);
> > +
> > +	return le32_to_cpu(val);
> > +}
>
> Return value should be __le32, etc.  Was this driver checked with sparse?
>
Yes, fully checked with sparse. No, it should not be __le32 because this ke=
eps=20
the behavior of the rtl8187 ioread consistent with the behavior of the PCI=
=20
ioread/iowrite functions which byteswap everything to native order.

> > +void rtl8187_write_phy(struct ieee80211_hw *dev, u8 addr, u32 data)
> > +{
> > +	struct rtl8187_priv *priv =3D dev->priv;
> > +
> > +	data <<=3D 8;
> > +	data |=3D addr | 0x80;
> > +
> > +	rtl818x_iowrite8(priv, &priv->map->PHY[3], (data >> 24) & 0xFF);
> > +	rtl818x_iowrite8(priv, &priv->map->PHY[2], (data >> 16) & 0xFF);
> > +	rtl818x_iowrite8(priv, &priv->map->PHY[1], (data >> 8) & 0xFF);
> > +	rtl818x_iowrite8(priv, &priv->map->PHY[0], data & 0xFF);
> > +
> > +	mdelay(1);
>
> unexplained delay -- write flush bug?
>
Most likely to just keep the hardware from choking or give the radio chip s=
ome=20
time to receive the information.

> > +static int rtl8187_init_hw(struct ieee80211_hw *dev)
> > +{
> > +	struct rtl8187_priv *priv =3D dev->priv;
> > +	u8 reg;
> > +	int i;
> > +
> > +	/* reset */
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_CONFIG); +	reg =3D rtl818x_ioread8(priv,
> > &priv->map->CONFIG3);
> > +	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg |
> > RTL818X_CONFIG3_ANAPARAM_WRITE); +	rtl818x_iowrite32(priv,
> > &priv->map->ANAPARAM, RTL8225_ANAPARAM_ON); +	rtl818x_iowrite32(priv,
> > &priv->map->ANAPARAM2, RTL8225_ANAPARAM2_ON); +	rtl818x_iowrite8(priv,
> > &priv->map->CONFIG3, reg & ~RTL818X_CONFIG3_ANAPARAM_WRITE);
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_NORMAL); +
> > +	rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0);
> > +
> > +	mdelay(200);
> > +	rtl818x_iowrite8(priv, (u8 *)0xFE18, 0x10);
> > +	rtl818x_iowrite8(priv, (u8 *)0xFE18, 0x11);
> > +	rtl818x_iowrite8(priv, (u8 *)0xFE18, 0x00);
> > +	mdelay(200);
>
> ditto
>
> also, kill the magic numbers
>
I have no idea what that does so I don't see the point in moving the number=
 to=20
some define. However, the hardware does seem to work okay without this part=
=20
so I can remove it if you bothers you so much.

> > +	reg =3D rtl818x_ioread8(priv, &priv->map->CMD);
> > +	reg &=3D (1 << 1);
> > +	reg |=3D RTL818X_CMD_RESET;
> > +	rtl818x_iowrite8(priv, &priv->map->CMD, reg);
> > +
> > +	i =3D 10;
> > +	do {
> > +		mdelay(2);
> > +		if (!(rtl818x_ioread8(priv, &priv->map->CMD) &
> > +		      RTL818X_CMD_RESET))
> > +			break;
> > +	} while (--i);
> > +
> > +	if (!i) {
> > +		printk(KERN_ERR "%s: Reset timeout!\n", wiphy_name(dev->wiphy));
> > +		return -ETIMEDOUT;
> > +	}
> > +
> > +	/* reload registers from eeprom */
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_LOAD); +
> > +	i =3D 10;
> > +	do {
> > +		mdelay(4);
> > +		if (!(rtl818x_ioread8(priv, &priv->map->EEPROM_CMD) &
> > +		      RTL818X_EEPROM_CMD_CONFIG))
> > +			break;
> > +	} while (--i);
> > +
> > +	if (!i) {
> > +		printk(KERN_ERR "%s: eeprom reset timeout!\n",
> > +		       wiphy_name(dev->wiphy));
> > +		return -ETIMEDOUT;
> > +	}
> > +
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_CONFIG); +	reg =3D rtl818x_ioread8(priv,
> > &priv->map->CONFIG3);
> > +	rtl818x_iowrite8(priv, &priv->map->CONFIG3, reg |
> > RTL818X_CONFIG3_ANAPARAM_WRITE); +	rtl818x_iowrite32(priv,
> > &priv->map->ANAPARAM, RTL8225_ANAPARAM_ON); +	rtl818x_iowrite32(priv,
> > &priv->map->ANAPARAM2, RTL8225_ANAPARAM2_ON); +	rtl818x_iowrite8(priv,
> > &priv->map->CONFIG3, reg & ~RTL818X_CONFIG3_ANAPARAM_WRITE);
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_NORMAL); +
> > +	/* setup card */
> > +	rtl818x_iowrite8(priv, (u8 *)0xFF85, 0);
> > +	rtl818x_iowrite8(priv, &priv->map->GPIO, 0);
> > +
> > +	rtl818x_iowrite8(priv, (u8 *)0xFF85, 4);
> > +	rtl818x_iowrite8(priv, &priv->map->GPIO, 1);
> > +	rtl818x_iowrite8(priv, &priv->map->GP_ENABLE, 0);
> > +
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_CONFIG); +	for (i =3D 0; i < ETH_ALEN; i++)
> > +		rtl818x_iowrite8(priv, &priv->map->MAC[i], priv->hwaddr[i]);
> > +
> > +	rtl818x_iowrite16(priv, (__le16 *)0xFFF4, 0xFFFF);
> > +	reg =3D rtl818x_ioread8(priv, &priv->map->CONFIG1);
> > +	reg &=3D 0x3F;
> > +	reg |=3D 0x80;
> > +	rtl818x_iowrite8(priv, &priv->map->CONFIG1, reg);
> > +
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_NORMAL); +
> > +	rtl818x_iowrite32(priv, &priv->map->INT_TIMEOUT, 0);
> > +	rtl818x_iowrite8(priv, &priv->map->WPA_CONF, 0);
> > +	rtl818x_iowrite8(priv, &priv->map->RATE_FALLBACK, 0x81);
> > +
> > +	// TODO: set RESP_RATE and BRSR properly
> > +	rtl818x_iowrite8(priv, &priv->map->RESP_RATE, (8 << 4) | 0);
> > +	rtl818x_iowrite16(priv, &priv->map->BRSR, 0x01F3);
> > +
> > +	/* host_usb_init */
> > +	rtl818x_iowrite8(priv, (u8 *)0xFF85, 0);
> > +	rtl818x_iowrite8(priv, &priv->map->GPIO, 0);
> > +	reg =3D rtl818x_ioread8(priv, (u8 *)0xFE53);
> > +	rtl818x_iowrite8(priv, (u8 *)0xFE53, reg | (1 << 7));
> > +	rtl818x_iowrite8(priv, (u8 *)0xFF85, 4);
> > +	rtl818x_iowrite8(priv, &priv->map->GPIO, 0x20);
> > +	rtl818x_iowrite8(priv, &priv->map->GP_ENABLE, 0);
> > +	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, 0x80);
> > +	rtl818x_iowrite16(priv, &priv->map->RFPinsSelect, 0x80);
> > +	rtl818x_iowrite16(priv, &priv->map->RFPinsEnable, 0x80);
> > +	mdelay(100);
> > +
> > +	rtl818x_iowrite32(priv, &priv->map->RF_TIMING, 0x000a8008);
> > +	rtl818x_iowrite16(priv, &priv->map->BRSR, 0xFFFF);
> > +	rtl818x_iowrite32(priv, &priv->map->RF_PARA, 0x00100044);
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_CONFIG); +	rtl818x_iowrite8(priv, &priv->map->CONFIG=
3,
> > 0x44);
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_NORMAL); +	rtl818x_iowrite16(priv,
> > &priv->map->RFPinsEnable, 0x1FF7);
> > +	mdelay(100);
> > +
> > +	priv->rf_init(dev);
> > +
> > +	rtl818x_iowrite16(priv, &priv->map->BRSR, 0x01F3);
> > +	reg =3D rtl818x_ioread16(priv, &priv->map->PGSELECT) & 0xfffe;
> > +	rtl818x_iowrite16(priv, &priv->map->PGSELECT, reg | 0x1);
> > +	rtl818x_iowrite16(priv, (__le16 *)0xFFFE, 0x10);
> > +	rtl818x_iowrite8(priv, &priv->map->TALLY_SEL, 0x80);
> > +	rtl818x_iowrite8(priv, (u8 *)0xFFFF, 0x60);
> > +	rtl818x_iowrite16(priv, &priv->map->PGSELECT, reg);
>
> this entire function can run for a very long time, without scheduling
>
All the mdelays can be converted to msleep AFAICT.

> > +static int rtl8187_stop(struct ieee80211_hw *dev)
> > +{
> > +	struct rtl8187_priv *priv =3D dev->priv;
> > +	struct rtl8187_rx_info *info;
> > +	struct sk_buff *skb;
> > +	u32 reg;
> > +
> > +	rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0);
> > +
> > +	reg =3D rtl818x_ioread8(priv, &priv->map->CMD);
> > +	reg &=3D ~RTL818X_CMD_TX_ENABLE;
> > +	reg &=3D ~RTL818X_CMD_RX_ENABLE;
> > +	rtl818x_iowrite8(priv, &priv->map->CMD, reg);
> > +
> > +	rtl8225_rf_stop(dev);
> > +
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_CONFIG); +	reg =3D rtl818x_ioread8(priv,
> > &priv->map->CONFIG4);
> > +	rtl818x_iowrite8(priv, &priv->map->CONFIG4, reg |
> > RTL818X_CONFIG4_VCOOFF); +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CM=
D,
> > RTL818X_EEPROM_CMD_NORMAL); +
> > +	while ((skb =3D skb_dequeue(&priv->rx_queue))) {
> > +		info =3D (struct rtl8187_rx_info *)skb->cb;
> > +		if (!info->urb)
> > +			continue;
>
> This seems an invalid use of skb->cb.  Don't use skb->cb.
>
The driver owns these rx skbs, so it owns skb->cb. Why not?

The line checking if info->urb is set or not is invalid though.. it will=20
always be set.

> > +static void rtl8187_register_write(struct eeprom_93cx6 *eeprom)
> > +{
> > +	struct ieee80211_hw *dev =3D eeprom->data;
> > +	struct rtl8187_priv *priv =3D dev->priv;
> > +	u8 reg =3D RTL818X_EEPROM_CMD_PROGRAM;
> > +
> > +	if (eeprom->reg_data_in)
> > +		reg |=3D RTL818X_EEPROM_CMD_WRITE;
> > +	if (eeprom->reg_data_out)
> > +		reg |=3D RTL818X_EEPROM_CMD_READ;
> > +	if (eeprom->reg_data_clock)
> > +		reg |=3D RTL818X_EEPROM_CMD_CK;
> > +	if (eeprom->reg_chip_select)
> > +		reg |=3D RTL818X_EEPROM_CMD_CS;
> > +
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, reg);
> > +	udelay(10);
>
> questionable delay
>
Most likely to prevent hitting the eeprom too fast.

> > +	eeprom.data =3D dev;
> > +	eeprom.register_read =3D rtl8187_register_read;
> > +	eeprom.register_write =3D rtl8187_register_write;
> > +	if (rtl818x_ioread32(priv, &priv->map->RX_CONF) & (1 << 6))
> > +		eeprom.width =3D PCI_EEPROM_WIDTH_93C66;
> > +	else
> > +		eeprom.width =3D PCI_EEPROM_WIDTH_93C46;
> > +
> > +	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD,
> > RTL818X_EEPROM_CMD_CONFIG); +	udelay(10);
>
> ditto
>
> > + * Radio tuning for RTL8225 on RTL8187
>
> this file is full of questionable delays -- these sorts of things tend
> to not be as accurate as you think, across all platforms, due to PCI
> posting and/or USB bus delays
>
They're not about being accurate as they are about giving the hardware enou=
gh=20
time to adjust. I suspect a number of them are arbitrary, but there's also=
=20
many necessary ones.

> > +void rtl8225z2_rf_init(struct ieee80211_hw *dev)
> > +{
> > +	struct rtl8187_priv *priv =3D dev->priv;
> > +	int i;
> > +
> > +	rtl8225_write(dev, 0x0, 0x2BF); mdelay(1);
> > +	rtl8225_write(dev, 0x1, 0xEE0); mdelay(1);
> > +	rtl8225_write(dev, 0x2, 0x44D); mdelay(1);
> > +	rtl8225_write(dev, 0x3, 0x441); mdelay(1);
> > +	rtl8225_write(dev, 0x4, 0x8C3); mdelay(1);
> > +	rtl8225_write(dev, 0x5, 0xC72); mdelay(1);
> > +	rtl8225_write(dev, 0x6, 0x0E6); mdelay(1);
> > +	rtl8225_write(dev, 0x7, 0x82A); mdelay(1);
> > +	rtl8225_write(dev, 0x8, 0x03F); mdelay(1);
> > +	rtl8225_write(dev, 0x9, 0x335); mdelay(1);
> > +	rtl8225_write(dev, 0xa, 0x9D4); mdelay(1);
> > +	rtl8225_write(dev, 0xb, 0x7BB); mdelay(1);
> > +	rtl8225_write(dev, 0xc, 0x850); mdelay(1);
> > +	rtl8225_write(dev, 0xd, 0xCDF); mdelay(1);
> > +	rtl8225_write(dev, 0xe, 0x02B); mdelay(1);
> > +	rtl8225_write(dev, 0xf, 0x114); mdelay(100);
> > +
> > +	rtl8225_write(dev, 0x0, 0x1B7);
> > +
> > +	for (i =3D 0; i < ARRAY_SIZE(rtl8225z2_rxgain); i++) {
> > +		rtl8225_write(dev, 0x1, i + 1);
> > +		rtl8225_write(dev, 0x2, rtl8225z2_rxgain[i]);
> > +	}
> > +
> > +	rtl8225_write(dev, 0x3, 0x080);
> > +	rtl8225_write(dev, 0x5, 0x004);
> > +	rtl8225_write(dev, 0x0, 0x0B7);
> > +	rtl8225_write(dev, 0x2, 0xc4D);
> > +
> > +	mdelay(200);
> > +	rtl8225_write(dev, 0x2, 0x44D);
> > +	mdelay(100);
> > +
> > +	if (!(rtl8225_read(dev, 6) & (1 << 7))) {
> > +		rtl8225_write(dev, 0x02, 0x0C4D);
> > +		mdelay(200);
> > +		rtl8225_write(dev, 0x02, 0x044D);
> > +		mdelay(100);
> > +		if (!(rtl8225_read(dev, 6) & (1 << 7)))
> > +			printk(KERN_WARNING "%s: RF Calibration Failed! %x\n",
> > +			       wiphy_name(dev->wiphy), rtl8225_read(dev, 6));
> > +	}
> > +
> > +	mdelay(200);
> > +
> > +	rtl8225_write(dev, 0x0, 0x2BF);
> > +
> > +	for (i =3D 0; i < ARRAY_SIZE(rtl8225_agc); i++) {
> > +		rtl8225_write_phy_ofdm(dev, 0xB, rtl8225_agc[i]);
> > +		mdelay(1);
> > +		rtl8225_write_phy_ofdm(dev, 0xA, 0x80 + i);
> > +		mdelay(1);
> > +	}
> > +
> > +	mdelay(1);
> > +
> > +	rtl8225_write_phy_ofdm(dev, 0x00, 0x01); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x01, 0x02); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x02, 0x42); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x03, 0x00); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x04, 0x00); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x05, 0x00); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x06, 0x40); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x07, 0x00); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x08, 0x40); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x09, 0xfe); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x0a, 0x08); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x0b, 0x80); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x0c, 0x01); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x0d, 0x43);
> > +	rtl8225_write_phy_ofdm(dev, 0x0e, 0xd3); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x0f, 0x38); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x10, 0x84); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x11, 0x07); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x12, 0x20); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x13, 0x20); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x14, 0x00); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x15, 0x40); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x16, 0x00); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x17, 0x40); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x18, 0xef); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x19, 0x19); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x1a, 0x20); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x1b, 0x15); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x1c, 0x04); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x1d, 0xc5); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x1e, 0x95); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x1f, 0x75); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x20, 0x1f); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x21, 0x17); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x22, 0x16); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x23, 0x80); mdelay(1); //FIXME: not
> > needed? +	rtl8225_write_phy_ofdm(dev, 0x24, 0x46); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x25, 0x00); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x26, 0x90); mdelay(1);
> > +	rtl8225_write_phy_ofdm(dev, 0x27, 0x88); mdelay(1);
> > +
> > +	rtl8225_write_phy_ofdm(dev, 0x0b, rtl8225z2_gain_bg[4 * 3]);
> > +	rtl8225_write_phy_ofdm(dev, 0x1b, rtl8225z2_gain_bg[4 * 3 + 1]);
> > +	rtl8225_write_phy_ofdm(dev, 0x1d, rtl8225z2_gain_bg[4 * 3 + 2]);
> > +	rtl8225_write_phy_ofdm(dev, 0x21, 0x37);
> > +
> > +	rtl8225_write_phy_cck(dev, 0x00, 0x98); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x03, 0x20); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x04, 0x7e); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x05, 0x12); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x06, 0xfc); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x07, 0x78); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x08, 0x2e); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x10, 0x9b); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x11, 0x88); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x12, 0x47); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x13, 0xd0);
> > +	rtl8225_write_phy_cck(dev, 0x19, 0x00);
> > +	rtl8225_write_phy_cck(dev, 0x1a, 0xa0);
> > +	rtl8225_write_phy_cck(dev, 0x1b, 0x08);
> > +	rtl8225_write_phy_cck(dev, 0x40, 0x86);
> > +	rtl8225_write_phy_cck(dev, 0x41, 0x8d); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x42, 0x15); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x43, 0x18); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x44, 0x36); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x45, 0x35); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x46, 0x2e); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x47, 0x25); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x48, 0x1c); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x49, 0x12); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x4a, 0x09); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x4b, 0x04); mdelay(1);
> > +	rtl8225_write_phy_cck(dev, 0x4c, 0x05); mdelay(1);
> > +
> > +	rtl818x_iowrite8(priv, (u8 *)0xFF5B, 0x0D); mdelay(1);
> > +
> > +	rtl8225z2_rf_set_tx_power(dev, 1);
> > +
> > +	/* RX antenna default to A */
> > +	rtl8225_write_phy_cck(dev, 0x10, 0x9b); mdelay(1);	/* B: 0xDB */
> > +	rtl8225_write_phy_ofdm(dev, 0x26, 0x90); mdelay(1);	/* B: 0x10 */
> > +
> > +	rtl818x_iowrite8(priv, &priv->map->TX_ANTENNA, 0x03);	/* B: 0x00 */
> > +	mdelay(1);
> > +	rtl818x_iowrite32(priv, (__le32 *)0xFF94, 0x3dc00002);
>
> completely insane, unacceptable amount of "freezing the kernel" in mdelay=
()
>
This is also only called at open time. I suspect most of the delays which a=
re=20
100 ms and over can be reduced if you wish. I haven't had time to figure ou=
t=20
which delays are really necessary. Converting everything to msleep is also=
=20
probably fine.

> > +++ b/drivers/net/wireless/rtl818x.h
> > @@ -0,0 +1,212 @@
> > +#ifndef RTL818X_H
> > +#define RTL818X_H
> > +
> > +struct rtl818x_csr {
> > +	u8	MAC[6];
> > +	u8	reserved_0[2];
> > +	__le32	MAR[2];
> > +	u8	RX_FIFO_COUNT;
> > +	u8	reserved_1;
> > +	u8	TX_FIFO_COUNT;
> > +	u8	BQREQ;
> > +	u8	reserved_2[4];
> > +	__le32	TSFT[2];
> > +	__le32	TLPDA;
> > +	__le32	TNPDA;
> > +	__le32	THPDA;
> > +	__le16	BRSR;
> > +	u8	BSSID[6];
> > +	u8	RESP_RATE;
> > +	u8	EIFS;
> > +	u8	reserved_3[1];
> > +	u8	CMD;
> > +#define RTL818X_CMD_TX_ENABLE		(1 << 2)
> > +#define RTL818X_CMD_RX_ENABLE		(1 << 3)
> > +#define RTL818X_CMD_RESET		(1 << 4)
> > +	u8	reserved_4[4];
> > +	__le16	INT_MASK;
> > +	__le16	INT_STATUS;
> > +#define RTL818X_INT_RX_OK		(1 <<  0)
> > +#define RTL818X_INT_RX_ERR		(1 <<  1)
> > +#define RTL818X_INT_TXL_OK		(1 <<  2)
> > +#define RTL818X_INT_TXL_ERR		(1 <<  3)
> > +#define RTL818X_INT_RX_DU		(1 <<  4)
> > +#define RTL818X_INT_RX_FO		(1 <<  5)
> > +#define RTL818X_INT_TXN_OK		(1 <<  6)
> > +#define RTL818X_INT_TXN_ERR		(1 <<  7)
> > +#define RTL818X_INT_TXH_OK		(1 <<  8)
> > +#define RTL818X_INT_TXH_ERR		(1 <<  9)
> > +#define RTL818X_INT_TXB_OK		(1 << 10)
> > +#define RTL818X_INT_TXB_ERR		(1 << 11)
> > +#define RTL818X_INT_ATIM		(1 << 12)
> > +#define RTL818X_INT_BEACON		(1 << 13)
> > +#define RTL818X_INT_TIME_OUT		(1 << 14)
> > +#define RTL818X_INT_TX_FO		(1 << 15)
> > +	__le32	TX_CONF;
> > +#define RTL818X_TX_CONF_LOOPBACK_MAC	(1 << 17)
> > +#define RTL818X_TX_CONF_NO_ICV		(1 << 19)
> > +#define RTL818X_TX_CONF_DISCW		(1 << 20)
> > +#define RTL818X_TX_CONF_R8180_ABCD	(2 << 25)
> > +#define RTL818X_TX_CONF_R8180_F		(3 << 25)
> > +#define RTL818X_TX_CONF_R8185_ABC	(4 << 25)
> > +#define RTL818X_TX_CONF_R8185_D		(5 << 25)
> > +#define RTL818X_TX_CONF_HWVER_MASK	(7 << 25)
> > +#define RTL818X_TX_CONF_CW_MIN		(1 << 31)
> > +	__le32	RX_CONF;
> > +#define RTL818X_RX_CONF_MONITOR		(1 <<  0)
> > +#define RTL818X_RX_CONF_NICMAC		(1 <<  1)
> > +#define RTL818X_RX_CONF_MULTICAST	(1 <<  2)
> > +#define RTL818X_RX_CONF_BROADCAST	(1 <<  3)
> > +#define RTL818X_RX_CONF_DATA		(1 << 18)
> > +#define RTL818X_RX_CONF_CTRL		(1 << 19)
> > +#define RTL818X_RX_CONF_MGMT		(1 << 20)
> > +#define RTL818X_RX_CONF_BSSID		(1 << 23)
> > +#define RTL818X_RX_CONF_RX_AUTORESETPHY	(1 << 28)
> > +#define RTL818X_RX_CONF_ONLYERLPKT	(1 << 31)
> > +	__le32	INT_TIMEOUT;
> > +	__le32	TBDA;
> > +	u8	EEPROM_CMD;
> > +#define RTL818X_EEPROM_CMD_READ		(1 << 0)
> > +#define RTL818X_EEPROM_CMD_WRITE	(1 << 1)
> > +#define RTL818X_EEPROM_CMD_CK		(1 << 2)
> > +#define RTL818X_EEPROM_CMD_CS		(1 << 3)
> > +#define RTL818X_EEPROM_CMD_NORMAL	(0 << 6)
> > +#define RTL818X_EEPROM_CMD_LOAD		(1 << 6)
> > +#define RTL818X_EEPROM_CMD_PROGRAM	(2 << 6)
> > +#define RTL818X_EEPROM_CMD_CONFIG	(3 << 6)
> > +	u8	CONFIG0;
> > +	u8	CONFIG1;
> > +	u8	CONFIG2;
> > +	__le32	ANAPARAM;
> > +	u8	MSR;
> > +#define RTL818X_MSR_NO_LINK		(0 << 2)
> > +#define RTL818X_MSR_ADHOC		(1 << 2)
> > +#define RTL818X_MSR_INFRA		(2 << 2)
> > +	u8	CONFIG3;
> > +#define RTL818X_CONFIG3_ANAPARAM_WRITE	(1 << 6)
> > +	u8	CONFIG4;
> > +#define RTL818X_CONFIG4_POWEROFF	(1 << 6)
> > +#define RTL818X_CONFIG4_VCOOFF		(1 << 7)
> > +	u8	TESTR;
> > +	u8	reserved_9[2];
> > +	__le16	PGSELECT;
> > +	__le32	ANAPARAM2;
> > +	u8	reserved_10[12];
> > +	__le16	BEACON_INTERVAL;
> > +	__le16	ATIM_WND;
> > +	__le16	BEACON_INTERVAL_TIME;
> > +	__le16	ATIMTR_INTERVAL;
> > +	u8	reserved_11[4];
> > +	u8	PHY[4];
> > +	__le16	RFPinsOutput;
> > +	__le16	RFPinsEnable;
> > +	__le16	RFPinsSelect;
> > +	__le16	RFPinsInput;
> > +	__le32	RF_PARA;
> > +	__le32	RF_TIMING;
> > +	u8	GP_ENABLE;
> > +	u8	GPIO;
> > +	u8	reserved_12[10];
> > +	u8	TX_AGC_CTL;
> > +#define RTL818X_TX_AGC_CTL_PERPACKET_GAIN_SHIFT		(1 << 0)
> > +#define RTL818X_TX_AGC_CTL_PERPACKET_ANTSEL_SHIFT	(1 << 1)
> > +#define RTL818X_TX_AGC_CTL_FEEDBACK_ANT			(1 << 2)
> > +	u8	TX_GAIN_CCK;
> > +	u8	TX_GAIN_OFDM;
> > +	u8	TX_ANTENNA;
> > +	u8	reserved_13[16];
> > +	u8	WPA_CONF;
> > +	u8	reserved_14[3];
> > +	u8	SIFS;
> > +	u8	DIFS;
> > +	u8	SLOT;
> > +	u8	reserved_15[5];
> > +	u8	CW_CONF;
> > +#define RTL818X_CW_CONF_PERPACKET_CW_SHIFT	(1 << 0)
> > +#define RTL818X_CW_CONF_PERPACKET_RETRY_SHIFT	(1 << 1)
> > +	u8	CW_VAL;
> > +	u8	RATE_FALLBACK;
> > +	u8	reserved_16[25];
> > +	u8	CONFIG5;
> > +	u8	TX_DMA_POLLING;
> > +	u8	reserved_17[2];
> > +	__le16	CWR;
> > +	u8	RETRY_CTR;
> > +	u8	reserved_18[5];
> > +	__le32	RDSAR;
> > +	u8	reserved_19[18];
> > +	u16	TALLY_CNT;
> > +	u8	TALLY_SEL;
> > +} __attribute__((packed));
>
> enums have more visibility to the compiler and debugging tools
>
enums don't have the same kind of typechecking this has.

=2DMichael Wu

--nextPart2634848.ZiXQvLfLMr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGQoB6T3Oqt9AH4aERAjdPAKCNMJnkfcuhbrS5oaY2Y+aFLi4FfQCfbvC6
MPAOwrUw2za9lnndghCnugw=
=Puy5
-----END PGP SIGNATURE-----

--nextPart2634848.ZiXQvLfLMr--
