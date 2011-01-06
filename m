From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH]netdev: add driver for enc424j600 ethernet chip on SPI bus
Date: Thu, 6 Jan 2011 15:56:47 +0100
Message-ID: <AANLkTinosxXKgfkqGKqCLGi8tWeP4xnT1P3kMRu51CvS@mail.gmail.com>
References: <AANLkTi=cJuDX7RZCFD4ovgGQi7gBXchoMLx8BeuiGz8G@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mohan@thotakaa.com, blue.cube@seznam.cz,
	lanconelli.claudio@eptar.com,
	Sriram Subramanian <sriram@thotakaa.com>
To: Balaji Venkatachalam <balaji.v@thotakaa.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:57298 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036Ab1AFO4s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 09:56:48 -0500
Received: by qwa26 with SMTP id 26so16811531qwa.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 06:56:48 -0800 (PST)
In-Reply-To: <AANLkTi=cJuDX7RZCFD4ovgGQi7gBXchoMLx8BeuiGz8G@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A quick look follows.

2011/1/6 Balaji Venkatachalam <balaji.v@thotakaa.com>:
> From: Balaji Venkatachalam <balaji.v@thotakaa.com>
>
> These patches add support for Microchip enc424j600 ethernet chip
> controlled via SPI.
>
> I tested it on my custom board with ARM9 (Freescale i.MX233) with
> Kernel 2.6.31.14.
> Any comments are welcome.
>
> Signed-off-by: Balaji Venkatachalam <balaji.v@thotakaa.com>
> ---
>
> diff -uprN -X a/Documentation/dontdiff a/drivers/net/enc424j600.c
> b/drivers/net/enc424j600.c
> --- a/drivers/net/enc424j600.c =A01970-01-01 05:30:00.000000000 +0530
> +++ b/drivers/net/enc424j600.c =A02011-01-06 09:39:17.000000000 +0530
> @@ -0,0 +1,1694 @@
[...]
> +static int enc424j600_spi_trans(struct enc424j600_net *priv, int len=
)
> +{
> + =A0 =A0 =A0 /*modified to suit half duplexed spi */
> + =A0 =A0 =A0 struct spi_transfer tt =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .tx_buf =3D priv->spi_tx_buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .len =3D SPI_OPLEN,
> + =A0 =A0 =A0 };
> + =A0 =A0 =A0 struct spi_transfer tr =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .rx_buf =3D priv->spi_rx_buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .len =3D len,
> + =A0 =A0 =A0 };
> + =A0 =A0 =A0 struct spi_message m;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 spi_message_init(&m);
> +
> + =A0 =A0 =A0 spi_message_add_tail(&tt, &m);
> + =A0 =A0 =A0 spi_message_add_tail(&tr, &m);
> +
> + =A0 =A0 =A0 ret =3D spi_sync(priv->spi, &m);
> +
> + =A0 =A0 =A0 if (ret =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(priv->spi_rx_buf, tr.rx_buf, len=
);
> +
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&priv->spi->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "spi transfer failed: r=
et =3D %d\n", ret);
> + =A0 =A0 =A0 return ret;
> +}
> +
> +/*
> + * Read data from chip SRAM.
> + * window =3D 0 for Receive Buffer
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D =A0 =A0 1 for User Defined area
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D =A0 =A0 2 for General Purpose are=
a
> + */

This could use an enum. And the comment does not match the code, BTW.

> +static int enc424j600_read_sram(struct enc424j600_net *priv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 *dst=
, int len, u16 srcaddr, int window)
> +{
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 if (len > SPI_TRANSFER_BUF_LEN - 1 || len <=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 /* First set the write pointer as per selected window *=
/
> + =A0 =A0 =A0 if (window =3D=3D 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WRXRDPT;
> + =A0 =A0 =A0 else if (window =3D=3D 2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WUDARDPT;
> + =A0 =A0 =A0 else if (window =3D=3D 3)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WGPRDPT;
> +
> + =A0 =A0 =A0 priv->spi_tx_buf[1] =3D srcaddr & 0xFF;
> + =A0 =A0 =A0 priv->spi_tx_buf[2] =3D srcaddr >> 8;
> + =A0 =A0 =A0 ret =3D spi_write(priv->spi, priv->spi_tx_buf, 3);
> +
> + =A0 =A0 =A0 /* Transfer the data */
> + =A0 =A0 =A0 if (window =3D=3D 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D RRXDATA;
> + =A0 =A0 =A0 else if (window =3D=3D 2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D RUDADATA;
> + =A0 =A0 =A0 else if (window =3D=3D 3)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D RGPDATA;
> +
> + =A0 =A0 =A0 ret =3D enc424j600_spi_trans(priv, len + 1); =A0 =A0 =A0=
/*READ*/
> +
> + =A0 =A0 =A0 /* Copy the data to the tx buffer */
> + =A0 =A0 =A0 memcpy(dst, &priv->spi_rx_buf[0], len);

You could avoid the copy if enc424j600_spi_trans() would get the
buffer as its arguments.

> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +/*
> + * Write data to chip SRAM.
> + * window =3D 1 for RX
> + * window =3D 2 for User Data
> + * window =3D 3 for GP
> + */

Enum.

> +static int enc424j600_write_sram(struct enc424j600_net *priv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cons=
t u8 *src, int len, u16 dstaddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =
window)
> +{
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 if (len > SPI_TRANSFER_BUF_LEN - 1 || len <=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 /* First set the general purpose write pointer */
> + =A0 =A0 =A0 if (window =3D=3D 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WRXWRPT;
> + =A0 =A0 =A0 else if (window =3D=3D 2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WUDAWRPT;
> + =A0 =A0 =A0 else if (window =3D=3D 3)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WGPWRPT;
> +
> + =A0 =A0 =A0 priv->spi_tx_buf[1] =3D dstaddr & 0xFF;
> + =A0 =A0 =A0 priv->spi_tx_buf[2] =3D dstaddr >> 8;
> + =A0 =A0 =A0 ret =3D spi_write(priv->spi, priv->spi_tx_buf, 3);
> +
> + =A0 =A0 =A0 /* Copy the data to the tx buffer */
> + =A0 =A0 =A0 memcpy(&priv->spi_tx_buf[1], src, len);
> +
> + =A0 =A0 =A0 /* Transfer the data */
> + =A0 =A0 =A0 if (window =3D=3D 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WRXDATA;
> + =A0 =A0 =A0 else if (window =3D=3D 2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WUDADATA;
> + =A0 =A0 =A0 else if (window =3D=3D 3)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WGPDATA;
> +
> + =A0 =A0 =A0 ret =3D spi_write(priv->spi, priv->spi_tx_buf, len + 1)=
;
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
[...]
> +/*
> + * Write a 16bit special function register.
> + * The @sfr parameters takes address of the low byte of the register=
=2E
> + * Takes care of the endiannes & buffers.
> + * Uses banked write instruction.
> + */
> +
> +static int enc424j600_write_16b_sfr(struct enc424j600_net *priv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 u8 sfr, u16 data)
> +{
> + =A0 =A0 =A0 int ret;
> + =A0 =A0 =A0 enc424j600_set_bank(priv, sfr);
> +
> + =A0 =A0 =A0 priv->spi_tx_buf[0] =3D WCR(sfr & ADDR_MASK);
> + =A0 =A0 =A0 priv->spi_tx_buf[1] =3D data & 0xFF;
> + =A0 =A0 =A0 priv->spi_tx_buf[2] =3D data >> 8;
> + =A0 =A0 =A0 ret =3D spi_write(priv->spi, priv->spi_tx_buf, 3);
> + =A0 =A0 =A0 if (ret && netif_msg_drv(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG DRV_NAME ": %s() fail=
ed: ret =3D %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, ret);

netif_dbg()

It's in 2.6.35 or later, though.

> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +/*
> + * Read a 16bit special function register.
> + * The @sfr parameters takes address of the low byte of the register=
=2E
> + * Takes care of the endiannes & buffers.
> + * Uses banked read instruction.
> + */
> +static int enc424j600_read_16b_sfr(struct enc424j600_net *priv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
u8 sfr, u16 *data)
> +{
> + =A0 =A0 =A0 int ret;
> + =A0 =A0 =A0 enc424j600_set_bank(priv, sfr);
> +
> + =A0 =A0 =A0 priv->spi_tx_buf[0] =3D RCR(sfr & ADDR_MASK);
> + =A0 =A0 =A0 priv->spi_tx_buf[1] =3D 0;
> + =A0 =A0 =A0 priv->spi_tx_buf[2] =3D 0;
> + =A0 =A0 =A0 priv->spi_tx_buf[3] =3D 0;
> + =A0 =A0 =A0 ret =3D enc424j600_spi_trans(priv, 3); =A0 =A0/*READ*/
> +
> + =A0 =A0 =A0 *data =3D priv->spi_rx_buf[0] | priv->spi_rx_buf[1] << =
(u16) 8;
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +/*
> + * Reset the enc424j600.
> + * TODO: What if we get stuck on non-working spi with the initial
> + * test access to EUDAST ?
> + */
> +static void enc424j600_soft_reset(struct enc424j600_net *priv)
> +{
> + =A0 =A0 =A0 u8 estath;
> + =A0 =A0 =A0 u16 eudast;
> + =A0 =A0 =A0 if (netif_msg_hw(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG DRV_NAME ": %s() ente=
r\n", __func__);
> +
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_write_16b_sfr(priv, EUDASTL,=
 EUDAST_TEST_VAL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_read_16b_sfr(priv, EUDASTL, =
&eudast);
> + =A0 =A0 =A0 } while (eudast !=3D EUDAST_TEST_VAL);
> +
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_read_8b_sfr(priv, ESTATH, &e=
stath);
> + =A0 =A0 =A0 } while (!estath & CLKRDY);

Those loops need a timeout or you risk lockup with broken hardware.

> +
> + =A0 =A0 =A0 priv->spi_tx_buf[0] =3D SETETHRST;
> + =A0 =A0 =A0 enc424j600_spi_trans(priv, 1);
> +
> + =A0 =A0 =A0 udelay(50);
> +
> + =A0 =A0 =A0 enc424j600_read_16b_sfr(priv, EUDASTL, &eudast);
> + =A0 =A0 =A0 if (netif_msg_hw(priv) && eudast !=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG DRV_NAME
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": %s() EUDASTL is not z=
ero!\n", __func__);
> +
> + =A0 =A0 =A0 udelay(500);

Long enough for usleep() if there are no locks held.

> +}
> +
> +static unsigned long msec20_to_jiffies;

=3D=3D HZ/50. It's constant AFAIR.

> +
> +/*
> + * Wait for bits in register to become equal to @readyMask, but at m=
ost 20ms.
> + */
> +static int poll_ready(struct enc424j600_net *priv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 reg, u8 mask, u8 readyMa=
sk)
> +{
> + =A0 =A0 =A0 unsigned long timeout =3D jiffies + msec20_to_jiffies;
> + =A0 =A0 =A0 u8 value;
> + =A0 =A0 =A0 /* 20 msec timeout read */
> + =A0 =A0 =A0 enc424j600_read_8b_sfr(priv, reg, &value);
> + =A0 =A0 =A0 while ((value & mask) !=3D readyMask) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (time_after(jiffies, timeout)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_drv(priv)=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg=
(&priv->spi->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "reg %02x ready timeout!\n", reg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_relax();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_read_8b_sfr(priv, reg, &valu=
e);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
[...]
> +/* Waits for autonegotiation to complete and sets FULDPX bit in maco=
n2. */
> +static void enc424j600_wait_for_autoneg(struct enc424j600_net *priv)
> +{
> + =A0 =A0 =A0 u16 phstat1;
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_phy_read(priv, PHSTAT1, &phs=
tat1);
> + =A0 =A0 =A0 } while (!(phstat1 & ANDONE));

Timeout?

[...]
> +static int
> +enc424j600_setlink(struct net_device *ndev, u8 autoneg, u16 speed, u=
8 duplex)
> +{
> + =A0 =A0 =A0 struct enc424j600_net *priv =3D netdev_priv(ndev);
> + =A0 =A0 =A0 int ret =3D 0;
> + =A0 =A0 =A0 if (!priv->hw_enable) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* link is in low power mode now; duple=
x setting
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* will take effect on next enc424j60=
0_hw_init().
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (speed =3D=3D SPEED_10 || speed =3D=3D=
 SPEED_100) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->autoneg =3D (auto=
neg =3D=3D AUTONEG_ENABLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->full_duplex =3D (=
duplex =3D=3D DUPLEX_FULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->speed100 =3D (spe=
ed =3D=3D SPEED_100);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_link(priv=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_war=
n(&ndev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"unsupported link setting\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EOPNOTSUPP;

EINVAL

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_link(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(&ndev->dev, "W=
arning: hw must be disabled "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"to =
set link mode\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EBUSY;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return ret;
> +}
[...]
> +
> +/*
> + * Hardware receive function.
> + * Read the buffer memory, update the FIFO pointer to free the buffe=
r,
> + * check the status vector and decrement the packet counter.
> + */
> +static void enc424j600_hw_rx(struct net_device *ndev)
> +{
> + =A0 =A0 =A0 struct enc424j600_net *priv =3D netdev_priv(ndev);
> + =A0 =A0 =A0 struct sk_buff *skb =3D NULL;
> + =A0 =A0 =A0 u16 erxrdpt, next_packet, rxstat;
> + =A0 =A0 =A0 u8 pkcnt;
> + =A0 =A0 =A0 u16 head, tail;
> + =A0 =A0 =A0 u8 rsv[RSV_SIZE];
> + =A0 =A0 =A0 u16 newrxtail;
> + =A0 =A0 =A0 int len;
> +
> + =A0 =A0 =A0 if (netif_msg_rx_status(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG DRV_NAME ": RX pk_add=
r:0x%04x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->next_pk_ptr);
> + =A0 =A0 =A0 if (unlikely(priv->next_pk_ptr > RXEND_INIT)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_rx_err(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ndev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%s() I=
nvalid packet address!! 0x%04x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func_=
_, priv->next_pk_ptr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&priv->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_clear_bits(priv, ECON1L, RXE=
N);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_set_bits(priv, ECON2L, RXRST=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_clear_bits(priv, ECON2L, RXR=
ST);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nolock_rxfifo_init(priv, RXSTART, RXEND=
_INIT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_clear_bits(priv, EIRL, RXABT=
IF);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_set_bits(priv, ECON1L, RXEN)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&priv->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Read next packet pointer and rx status vector */
> + =A0 =A0 =A0 enc424j600_read_sram(priv, rsv, sizeof(rsv), priv->next=
_pk_ptr, 1);
> +
> + =A0 =A0 =A0 next_packet =3D rsv[1];
> + =A0 =A0 =A0 next_packet <<=3D 8;
> + =A0 =A0 =A0 next_packet |=3D rsv[0];
> +
> + =A0 =A0 =A0 len =3D rsv[3];
> + =A0 =A0 =A0 len <<=3D 8;
> + =A0 =A0 =A0 len |=3D rsv[2];
> +
> + =A0 =A0 =A0 rxstat =3D rsv[5];
> + =A0 =A0 =A0 rxstat <<=3D 8;
> + =A0 =A0 =A0 rxstat |=3D rsv[4];
> +
> + =A0 =A0 =A0 if (netif_msg_rx_status(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_dump_rsv(priv, __func__, nex=
t_packet, len, rxstat);
> +
> + =A0 =A0 =A0 if (!RSV_GETBIT(rxstat, RSV_RXOK) || len > MAX_FRAMELEN=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_rx_err(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ndev->dev, "Rx=
 Error (%04x)\n", rxstat);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (RSV_GETBIT(rxstat, RSV_CRCERROR))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_crc_erro=
rs++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (RSV_GETBIT(rxstat, RSV_LENCHECKERR)=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_frame_er=
rors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len > MAX_FRAMELEN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_over_err=
ors++;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(len + NET_IP_ALIG=
N);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_rx_err(pr=
iv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err=
(&ndev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "out of memory for Rx'd frame\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_dropped+=
+;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->dev =3D ndev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reserve(skb, NET_IP=
_ALIGN);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* copy the packet from=
 the receive buffer */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_read_sram(pr=
iv, skb_put(skb, len), len,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0rx_packet_start(priv->next_pk_ptr),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A01);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_pktdata(p=
riv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dump_pa=
cket(__func__, skb->len, skb->data);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->protocol =3D eth_t=
ype_trans(skb, ndev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* update statistics */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_packets+=
+;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_bytes +=3D=
 len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_rx_ni(skb);

I assume that this is not an IRQ context because of (slow) SPI
accesses. So use netif_rx() or better netif_receive_skb().

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 newrxtail =3D next_packet - 2;
> + =A0 =A0 =A0 if (next_packet =3D=3D RXSTART)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 newrxtail =3D SRAMSIZE - 2;
> +
> + =A0 =A0 =A0 enc424j600_write_16b_sfr(priv, ERXTAILL, newrxtail);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Move the RX read pointer to the start of the next
> + =A0 =A0 =A0 =A0* received packet.
> + =A0 =A0 =A0 =A0* This frees the memory we just read out
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 erxrdpt =3D erxrdpt_workaround(next_packet, RXSTART, RX=
END_INIT);
> + =A0 =A0 =A0 if (netif_msg_hw(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG DRV_NAME ": %s() ERXR=
DPT:0x%04x\n", __func__,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0erxrdpt);
> +
> + =A0 =A0 =A0 mutex_lock(&priv->lock);

Why do you need the lock here, but not on previous accesses to the hard=
ware?

> + =A0 =A0 =A0 enc424j600_write_16b_sfr(priv, ERXRDPTL, erxrdpt);
> +
> +#ifdef CONFIG_ENC28J60_WRITEVERIFY
> + =A0 =A0 =A0 if (netif_msg_drv(priv)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 reg;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_read_16b_sfr(priv, ERXRDPTL,=
 &reg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (reg !=3D erxrdpt)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG DRV_N=
AME ": %s() ERXRDPT verify "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"error (=
0x%04x - 0x%04x)\n", __func__, reg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0erxrdpt)=
;
> + =A0 =A0 =A0 }
> +#endif
> +
> + =A0 =A0 =A0 priv->next_pk_ptr =3D next_packet;
> + =A0 =A0 =A0 enc424j600_read_8b_sfr(priv, ESTATL, &pkcnt);
> + =A0 =A0 =A0 enc424j600_read_16b_sfr(priv, ERXHEADL, &head);
> + =A0 =A0 =A0 enc424j600_read_16b_sfr(priv, ERXTAILL, &tail);
> + =A0 =A0 =A0 /* we are done with this packet, decrement the packet c=
ounter */
> + =A0 =A0 =A0 enc424j600_set_bits(priv, ECON1H, PKTDEC);
> +
> + =A0 =A0 =A0 mutex_unlock(&priv->lock);
> +}
[...]
> +static irqreturn_t enc424j600_irq(int irq, void *dev_id)
> +{
> + =A0 =A0 =A0 struct enc424j600_net *priv =3D dev_id;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Can't do anything in interrupt context because we =
need to
> + =A0 =A0 =A0 =A0* block (spi_sync() is blocking) so fire of the inte=
rrupt
> + =A0 =A0 =A0 =A0* handling workqueue.
> + =A0 =A0 =A0 =A0* Remember that we access enc424j600 registers throu=
gh SPI bus
> + =A0 =A0 =A0 =A0* via spi_sync() call.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 schedule_work(&priv->irq_work);
> +
> + =A0 =A0 =A0 return IRQ_HANDLED;
> +}

You can use threaded interrupts here and get rid of irq_work. And
definitely disable source interrupt before returning. And after you do
that, you have implemented most of what's necessary for NAPI rx.

[...]
> +static void enc424j600_setrx_work_handler(struct work_struct *work)
> +{
> + =A0 =A0 =A0 u16 macon1;
> + =A0 =A0 =A0 struct enc424j600_net *priv =3D
> + =A0 =A0 =A0 =A0 =A0 container_of(work, struct enc424j600_net, setrx=
_work);
> +
> + =A0 =A0 =A0 if (priv->rxfilter =3D=3D RXFILTER_PROMISC) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_drv(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG DRV_N=
AME ": promiscuous mode\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_read_16b_sfr(priv, MACON1L, =
&macon1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 macon1 =3D macon1 | PASSALL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_write_16b_sfr(priv, MACON1L,=
 macon1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 locked_regb_write(priv, ERXFCONL, UCEN =
| MCEN | NOTMEEN);
> + =A0 =A0 =A0 } else if (priv->rxfilter =3D=3D RXFILTER_MULTI) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_drv(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG DRV_N=
AME ": multicast mode\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 locked_regb_write(priv, ERXFCONL, UCEN =
| CRCEN | BCEN | MCEN);
> +
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_drv(priv))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG DRV_N=
AME ": normal mode\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 locked_regb_write(priv, ERXFCONL, UCEN =
| CRCEN | BCEN);
> +
> + =A0 =A0 =A0 }
> +}
> +
> +static void enc424j600_restart_work_handler(struct work_struct *work=
)
> +{
> + =A0 =A0 =A0 struct enc424j600_net *priv =3D
> + =A0 =A0 =A0 =A0 =A0 container_of(work, struct enc424j600_net, resta=
rt_work);
> + =A0 =A0 =A0 struct net_device *ndev =3D priv->netdev;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 rtnl_lock();
> + =A0 =A0 =A0 if (netif_running(ndev)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_net_close(ndev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D enc424j600_net_open(ndev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(ret)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&ndev->dev, " =
could not restart %d\n", ret);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_close(ndev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rtnl_unlock();
> +}

Are these work handlers guaranteed to not be scheduled concurrently?

[...]
> + =A0 =A0 =A0 /* If requested, allocate DMA buffers */
> + =A0 =A0 =A0 if (enc424j600_enable_dma) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spi->dev.coherent_dma_mask =3D ~0;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Minimum coherent DMA allocation is=
 PAGE_SIZE, so allocate
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* that much and share it between Tx =
and Rx DMA buffers.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +#if SPI_TRANSFER_BUF_LEN > PAGE_SIZE / 2
> +#error "A problem in DMA buffer allocation"
> +#endif
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_tx_buf =3D dma_alloc_coherent=
(&spi->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PAGE_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &priv->spi_tx_dma,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_DMA);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priv->spi_tx_buf) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_rx_buf =3D (u=
8 *) (priv->spi_tx_buf +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(PAGE_SIZE / 2));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_rx_dma =3D (d=
ma_addr_t) (priv->spi_tx_dma +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(PAGE_SIZE / 2));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Fall back to non-DMA=
 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enc424j600_enable_dma =3D=
 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }

You don't use DMA addresses anywhere. And don't do anything with this
flag except for freeing the buffers. You should use streaming DMA
calls for skb data to avoid copying anyway and let the arch code care
about bounce buffers if needed.

[...]

MAINTAINTERS entry would be nice also.

Best Regards,
Micha=B3 Miros=B3aw
