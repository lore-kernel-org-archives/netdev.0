From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Tue, 10 Jan 2012 00:11:29 +0100
Message-ID: <4F0B7421.6050203@pengutronix.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF31@saturn3.aculab.com> <4F0B608D.6090309@essax.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9106B10D8A779BE75DD19DE3"
Cc: David Laight <David.Laight@ACULAB.COM>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: info@essax.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F0B608D.6090309@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9106B10D8A779BE75DD19DE3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/09/2012 10:47 PM, Wolfgang Zarre wrote:
[...]

>>> OK. My concern: Can we be sure that 16bit accesses are always
>> supported
>>> by the hardware? Does a spinlock_irqsave/spinlock_irqrestore around
>> the
>>> 8bit accesses already help?
>>
>> Hmmm... are there any register reads that need the
>> same 'double cycle' sequence ??
>> If so you need to stop reads being interleaved (with
>> themselves and writes) so requesting a 16bit access
>> doesn't help.
>>
>> Which means you need a spinlock...
>>
>>     David
>>
>>
>=20
> @David: Thank You very much for that hint. You are right and to
> implement correct we need a spinlock.
>=20
> @Wolfgang: I was thinking about Your question regarding 8/16 bit and
> in fact it wouldn't work at all on a clean 8 bit cards.
>=20
> Further it wouldn't work on 16 bit cards where the MSB is not equal
> to base port +1 and anyway, it's depending always on how the chip is
> interfaced to the ISA bus and in which mode the chip is configured.
>=20
>=20
> And therefore I was giving David's hint a try in using a spinlock in
> function cc770_isa_port_write_reg_indirect() and patched as follows:
>=20
> ---------------------------------------------------------------------
> diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc77=
0.c
> index 2d12f89..dad6707 100644
> --- a/drivers/net/can/cc770/cc770.c
> +++ b/drivers/net/can/cc770/cc770.c
> @@ -460,15 +460,6 @@ static netdev_tx_t cc770_start_xmit(struct sk_buff=

> *skb, struct net_device *dev)
>=20
>      stats->tx_bytes +=3D dlc;
>=20
> -
> -    /*
> -     * HM: We had some cases of repeated IRQs so make sure the
> -     * INT is acknowledged I know it's already further up, but
> -     * doing again fixed the issue
> -     */
> -    cc770_write_reg(priv, msgobj[mo].ctrl0,
> -            MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
> -
>      return NETDEV_TX_OK;
>  }
>=20
> @@ -689,12 +680,6 @@ static void cc770_tx_interrupt(struct net_device
> *dev, unsigned int o)
>      /* Nothing more to send, switch off interrupts */
>      cc770_write_reg(priv, msgobj[mo].ctrl0,
>              MSGVAL_RES | TXIE_RES | RXIE_RES | INTPND_RES);
> -    /*
> -     * We had some cases of repeated IRQ so make sure the
> -     * INT is acknowledged
> -     */
> -    cc770_write_reg(priv, msgobj[mo].ctrl0,
> -            MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
>=20
>      stats->tx_packets++;
>      can_get_echo_skb(dev, 0);
> diff --git a/drivers/net/can/cc770/cc770_isa.c
> b/drivers/net/can/cc770/cc770_isa.c
> index 4be5fe2..fe39eed 100644
> --- a/drivers/net/can/cc770/cc770_isa.c
> +++ b/drivers/net/can/cc770/cc770_isa.c
> @@ -110,6 +110,9 @@ MODULE_PARM_DESC(bcr, "Bus configuration register
> (default=3D0x40 [CBY])");
>  #define CC770_IOSIZE          0x20
>  #define CC770_IOSIZE_INDIRECT 0x02
>=20
> +/* Spinlock for cc770_isa_port_write_reg_indirect */
> +static DEFINE_SPINLOCK( outb_lock);
> +

Do we need a global or a per device spin lock? If this should be a per
device one, please introduce a cc770_isa_priv and put the spinlock
there. Don't forget to initialize the spinlock.

>  static struct platform_device *cc770_isa_devs[MAXDEV];
>=20
>  static u8 cc770_isa_mem_read_reg(const struct cc770_priv *priv, int re=
g)
> @@ -147,9 +150,12 @@ static void cc770_isa_port_write_reg_indirect(cons=
t
> struct cc770_priv *priv,
>                          int reg, u8 val)
>  {
>      unsigned long base =3D (unsigned long)priv->reg_base;
> +    unsigned long flags;

please indent with tab, not space (your mailer probably converts tabs to
space)

>=20
> +    spin_lock_irqsave( &outb_lock, flags);
                         ^

please remove the whitespace.

>      outb(reg, base);
>      outb(val, base + 1);
> +    spin_unlock_irqrestore( &outb_lock, flags);  =20
                              ^                   ^^^
please remove this and trailing whitespace.

>  }
>=20
>  static int __devinit cc770_isa_probe(struct platform_device *pdev)
> ----------------------------------------------------------------------

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig9106B10D8A779BE75DD19DE3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk8LdCQACgkQjTAFq1RaXHOCNQCghNfHQRBjDtc4qH1n/n665eXs
IoUAn11HCC8IFotCfFRegC5GdubBTcqQ
=37ok
-----END PGP SIGNATURE-----

--------------enig9106B10D8A779BE75DD19DE3--
