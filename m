From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Please pull 'upstream-rtl8187' branch of wireless-2.6
Date: Thu, 10 May 2007 00:47:59 -0400
Message-ID: <200705100048.04483.flamingice@sourmilk.net>
References: <20070508173907.GH6479@tuxdriver.com> <200705092216.26880.flamingice@sourmilk.net> <46429DC8.3090401@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1607452.o10NqKrtuJ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46429DC8.3090401-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1607452.o10NqKrtuJ
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 10 May 2007 00:21, Jeff Garzik wrote:
> Michael Wu wrote:
> > On Wednesday 09 May 2007 19:12, Jeff Garzik wrote:
> >> John W. Linville wrote:
> >>> +static inline void eeprom_93cx6_pulse_high(struct eeprom_93cx6
> >>> *eeprom) +{
> >>> +	eeprom->reg_data_clock =3D 1;
> >>> +	eeprom->register_write(eeprom);
> >>> +	udelay(1);
> >>> +}
> >>> +
> >>> +static inline void eeprom_93cx6_pulse_low(struct eeprom_93cx6 *eepro=
m)
> >>> +{
> >>> +	eeprom->reg_data_clock =3D 0;
> >>> +	eeprom->register_write(eeprom);
> >>> +	udelay(1);
> >>> +}
> >>
> >> udelay-after-write normally indicates a PCI posting bug (or USB bus
> >> delay bug)
> >
> > Things may go bad if we try to bitbang the eeprom too fast.
>
> You are misunderstanding the point here.
>
> I was not asking why you needed the delay.  I was making an assertion
> about the unreliable nature of such delays.
>
> Sending a register write to a device is vastly different from knowing
> that the write has been received and processed by the device.
>
> On a PCI bus, this is called PCI write posting, where writes can be
> delayed and/or combined with other writes.  There is a similar concept
> with USB, because you are dealing with packets going to and from a USB
> device.
>
> You fundamentally cannot assume that the write has arrived at the device
> by the time the CPU is executing the next C statement (udelay) on the hos=
t.
>
> The normal procedure for PCI is to issue a read, which thereby
> guarantees that any writes have been flushed to the device.  I presume
> the same technique works with USB, but do not know for certain.
>
Ah, I see what you're talking about.

All register writes on rtl8187 are blocking. We know they've reached the=20
device once the function returns.

I suppose there is a problem with the eeprom code not documenting the=20
assumption that the write posted before returning.

> Regardless of any symbol issues, if it works without it, then remove it,
> because it is pointless code.  All pointless code should be removed.
>
> But nonetheless, for any "magic number" registers that remain, give them
> named constants that approximate their use as best as you can tell.
>
Well, I really don't know what this stuff does, so the best names would end=
 up=20
being something like RTL818X_INIT_MAGIC_REGISTER_1 and so on.

I'll ask Realtek instead.

> >> This seems an invalid use of skb->cb.  Don't use skb->cb.
> >
> > The driver owns these rx skbs, so it owns skb->cb. Why not?
>
> Wrong.  It no longer owns the skbs once it passes them to the stack.
>
Those skbs have not been passed up to the stack. They're empty skbs waiting=
=20
for incoming frames. Any skbs that are passed up to the stack are unlinked=
=20
from this list first.

> >>> +++ b/drivers/net/wireless/rtl818x.h
> >>> @@ -0,0 +1,212 @@
> >>> +#ifndef RTL818X_H
> >>> +#define RTL818X_H
> >>> +
> >>> +struct rtl818x_csr {
> >>> +	u8	MAC[6];
> >>> +	u8	reserved_0[2];
> >>> +	__le32	MAR[2];
> >>> +	u8	RX_FIFO_COUNT;
> >>> +	u8	reserved_1;
> >>> +	u8	TX_FIFO_COUNT;
> >>> +	u8	BQREQ;
> >>> +	u8	reserved_2[4];
> >>> +	__le32	TSFT[2];
> >>> +	__le32	TLPDA;
> >>> +	__le32	TNPDA;
> >>> +	__le32	THPDA;
> >>> +	__le16	BRSR;
> >>> +	u8	BSSID[6];
> >>> +	u8	RESP_RATE;
> >>> +	u8	EIFS;
> >>> +	u8	reserved_3[1];
> >>> +	u8	CMD;
> >>> +#define RTL818X_CMD_TX_ENABLE		(1 << 2)
> >>> +#define RTL818X_CMD_RX_ENABLE		(1 << 3)
> >>> +#define RTL818X_CMD_RESET		(1 << 4)
> >>> +	u8	reserved_4[4];
> >>> +	__le16	INT_MASK;
> >>> +	__le16	INT_STATUS;
> >>> +#define RTL818X_INT_RX_OK		(1 <<  0)
> >>> +#define RTL818X_INT_RX_ERR		(1 <<  1)
> >>> +#define RTL818X_INT_TXL_OK		(1 <<  2)
> >>> +#define RTL818X_INT_TXL_ERR		(1 <<  3)
> >>> +#define RTL818X_INT_RX_DU		(1 <<  4)
> >>> +#define RTL818X_INT_RX_FO		(1 <<  5)
> >>> +#define RTL818X_INT_TXN_OK		(1 <<  6)
> >>> +#define RTL818X_INT_TXN_ERR		(1 <<  7)
> >>> +#define RTL818X_INT_TXH_OK		(1 <<  8)
> >>> +#define RTL818X_INT_TXH_ERR		(1 <<  9)
> >>> +#define RTL818X_INT_TXB_OK		(1 << 10)
> >>> +#define RTL818X_INT_TXB_ERR		(1 << 11)
> >>> +#define RTL818X_INT_ATIM		(1 << 12)
> >>> +#define RTL818X_INT_BEACON		(1 << 13)
> >>> +#define RTL818X_INT_TIME_OUT		(1 << 14)
> >>> +#define RTL818X_INT_TX_FO		(1 << 15)
> >>> +	__le32	TX_CONF;
> >>> +#define RTL818X_TX_CONF_LOOPBACK_MAC	(1 << 17)
> >>> +#define RTL818X_TX_CONF_NO_ICV		(1 << 19)
> >>> +#define RTL818X_TX_CONF_DISCW		(1 << 20)
> >>> +#define RTL818X_TX_CONF_R8180_ABCD	(2 << 25)
> >>> +#define RTL818X_TX_CONF_R8180_F		(3 << 25)
> >>> +#define RTL818X_TX_CONF_R8185_ABC	(4 << 25)
> >>> +#define RTL818X_TX_CONF_R8185_D		(5 << 25)
> >>> +#define RTL818X_TX_CONF_HWVER_MASK	(7 << 25)
> >>> +#define RTL818X_TX_CONF_CW_MIN		(1 << 31)
> >>> +	__le32	RX_CONF;
> >>> +#define RTL818X_RX_CONF_MONITOR		(1 <<  0)
> >>> +#define RTL818X_RX_CONF_NICMAC		(1 <<  1)
> >>> +#define RTL818X_RX_CONF_MULTICAST	(1 <<  2)
> >>> +#define RTL818X_RX_CONF_BROADCAST	(1 <<  3)
> >>> +#define RTL818X_RX_CONF_DATA		(1 << 18)
> >>> +#define RTL818X_RX_CONF_CTRL		(1 << 19)
> >>> +#define RTL818X_RX_CONF_MGMT		(1 << 20)
> >>> +#define RTL818X_RX_CONF_BSSID		(1 << 23)
> >>> +#define RTL818X_RX_CONF_RX_AUTORESETPHY	(1 << 28)
> >>> +#define RTL818X_RX_CONF_ONLYERLPKT	(1 << 31)
> >>> +	__le32	INT_TIMEOUT;
> >>> +	__le32	TBDA;
> >>> +	u8	EEPROM_CMD;
> >>> +#define RTL818X_EEPROM_CMD_READ		(1 << 0)
> >>> +#define RTL818X_EEPROM_CMD_WRITE	(1 << 1)
> >>> +#define RTL818X_EEPROM_CMD_CK		(1 << 2)
> >>> +#define RTL818X_EEPROM_CMD_CS		(1 << 3)
> >>> +#define RTL818X_EEPROM_CMD_NORMAL	(0 << 6)
> >>> +#define RTL818X_EEPROM_CMD_LOAD		(1 << 6)
> >>> +#define RTL818X_EEPROM_CMD_PROGRAM	(2 << 6)
> >>> +#define RTL818X_EEPROM_CMD_CONFIG	(3 << 6)
> >>> +	u8	CONFIG0;
> >>> +	u8	CONFIG1;
> >>> +	u8	CONFIG2;
> >>> +	__le32	ANAPARAM;
> >>> +	u8	MSR;
> >>> +#define RTL818X_MSR_NO_LINK		(0 << 2)
> >>> +#define RTL818X_MSR_ADHOC		(1 << 2)
> >>> +#define RTL818X_MSR_INFRA		(2 << 2)
> >>> +	u8	CONFIG3;
> >>> +#define RTL818X_CONFIG3_ANAPARAM_WRITE	(1 << 6)
> >>> +	u8	CONFIG4;
> >>> +#define RTL818X_CONFIG4_POWEROFF	(1 << 6)
> >>> +#define RTL818X_CONFIG4_VCOOFF		(1 << 7)
> >>> +	u8	TESTR;
> >>> +	u8	reserved_9[2];
> >>> +	__le16	PGSELECT;
> >>> +	__le32	ANAPARAM2;
> >>> +	u8	reserved_10[12];
> >>> +	__le16	BEACON_INTERVAL;
> >>> +	__le16	ATIM_WND;
> >>> +	__le16	BEACON_INTERVAL_TIME;
> >>> +	__le16	ATIMTR_INTERVAL;
> >>> +	u8	reserved_11[4];
> >>> +	u8	PHY[4];
> >>> +	__le16	RFPinsOutput;
> >>> +	__le16	RFPinsEnable;
> >>> +	__le16	RFPinsSelect;
> >>> +	__le16	RFPinsInput;
> >>> +	__le32	RF_PARA;
> >>> +	__le32	RF_TIMING;
> >>> +	u8	GP_ENABLE;
> >>> +	u8	GPIO;
> >>> +	u8	reserved_12[10];
> >>> +	u8	TX_AGC_CTL;
> >>> +#define RTL818X_TX_AGC_CTL_PERPACKET_GAIN_SHIFT		(1 << 0)
> >>> +#define RTL818X_TX_AGC_CTL_PERPACKET_ANTSEL_SHIFT	(1 << 1)
> >>> +#define RTL818X_TX_AGC_CTL_FEEDBACK_ANT			(1 << 2)
> >>> +	u8	TX_GAIN_CCK;
> >>> +	u8	TX_GAIN_OFDM;
> >>> +	u8	TX_ANTENNA;
> >>> +	u8	reserved_13[16];
> >>> +	u8	WPA_CONF;
> >>> +	u8	reserved_14[3];
> >>> +	u8	SIFS;
> >>> +	u8	DIFS;
> >>> +	u8	SLOT;
> >>> +	u8	reserved_15[5];
> >>> +	u8	CW_CONF;
> >>> +#define RTL818X_CW_CONF_PERPACKET_CW_SHIFT	(1 << 0)
> >>> +#define RTL818X_CW_CONF_PERPACKET_RETRY_SHIFT	(1 << 1)
> >>> +	u8	CW_VAL;
> >>> +	u8	RATE_FALLBACK;
> >>> +	u8	reserved_16[25];
> >>> +	u8	CONFIG5;
> >>> +	u8	TX_DMA_POLLING;
> >>> +	u8	reserved_17[2];
> >>> +	__le16	CWR;
> >>> +	u8	RETRY_CTR;
> >>> +	u8	reserved_18[5];
> >>> +	__le32	RDSAR;
> >>> +	u8	reserved_19[18];
> >>> +	u16	TALLY_CNT;
> >>> +	u8	TALLY_SEL;
> >>> +} __attribute__((packed));
> >>
> >> enums have more visibility to the compiler and debugging tools
> >
> > enums don't have the same kind of typechecking this has.
>
> You're right.  They actually HAVE typechecking, whereas cpp #defines do
> not.
>
> We like typechecking in Linux, but your #defines have none.
>
Don't most drivers use #defines?

At any rate, all the registers are fully typechecked. The #defines sprinkle=
d=20
through there are bits for individual registers.. you want those converted =
to=20
enums? (if so.. how does that help?)

=2DMichael Wu

--nextPart1607452.o10NqKrtuJ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGQqQET3Oqt9AH4aERAtqFAJ9oTCn+qQp/a79S9KnTM0NtwrC/VACgofV7
3ndMjiKIkYYQoGhM3GNPndU=
=MY+x
-----END PGP SIGNATURE-----

--nextPart1607452.o10NqKrtuJ--
