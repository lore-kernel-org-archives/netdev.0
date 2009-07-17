From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2 v4] MPC52xx FEC: be more conservative when setting
	MII_SPEED register
Date: Fri, 17 Jul 2009 08:45:08 -0600
Message-ID: <fa686aa40907170745h6c5fae6bia0cff0926c93393c@mail.gmail.com>
References: <1247833628-15952-2-git-send-email-wd@denx.de>
	<1247835545-18650-1-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f197.google.com ([209.85.222.197]:41808 "EHLO
	mail-pz0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933752AbZGQOp3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 10:45:29 -0400
Received: by pzk35 with SMTP id 35so647259pzk.33
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 07:45:28 -0700 (PDT)
In-Reply-To: <1247835545-18650-1-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2009 at 6:59 AM, Wolfgang Denk<wd@denx.de> wrote:
> This patch adds error checking and prevents clobbering unrelated bits
> (reserved bits or the DIS_PREAMBLE bit) when writing the MII_SPEED
> register on MPC52xx systems.
>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> Cc: <netdev@vger.kernel.org>
> ---
> v3: - use maximum divider in case MPC512x IPS clock is unknown
> v4: - use the same code in the probe-function, too
>
> =A0drivers/net/fec_mpc52xx.c =A0 =A0 | =A0 25 ++++++++++++++++++++++-=
--
> =A0drivers/net/fec_mpc52xx_phy.c | =A0 23 ++++++++++++++++++++---

Blech.  now this block of duplicated code I don't like.  This is all
one device, so surely the mdio speed can be calculated once and used
for both drivers.... let me think about this for a bit.  'course this
problem is all rolled up in the nastiness of having two drivers
working on the same device.  I suspect is was a mistake to split up
all the powerpc ethernet drivers into separate of_platform drivers.

g.

> =A02 files changed, 42 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index cc78633..eed8d2b 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -639,7 +639,7 @@ static void mpc52xx_fec_hw_init(struct net_device=
 *dev)
> =A0 =A0 =A0 =A0/* set phy speed.
> =A0 =A0 =A0 =A0 * this can't be done in phy driver, since it needs to=
 be called
> =A0 =A0 =A0 =A0 * before fec stuff (even on resume) */
> - =A0 =A0 =A0 out_be32(&fec->mii_speed, priv->mdio_speed);
> + =A0 =A0 =A0 clrsetbits_be32(&fec->mii_speed, 0x7E, priv->mdio_speed=
);
> =A0}
>
> =A0/**
> @@ -863,7 +863,7 @@ mpc52xx_fec_probe(struct of_device *op, const str=
uct of_device_id *match)
> =A0 =A0 =A0 =A0struct mpc52xx_fec_priv *priv =3D NULL;
> =A0 =A0 =A0 =A0struct resource mem;
> =A0 =A0 =A0 =A0const u32 *prop;
> - =A0 =A0 =A0 int prop_size;
> + =A0 =A0 =A0 int prop_size, clock, speed;
>
> =A0 =A0 =A0 =A0phys_addr_t rx_fifo;
> =A0 =A0 =A0 =A0phys_addr_t tx_fifo;
> @@ -948,7 +948,26 @@ mpc52xx_fec_probe(struct of_device *op, const st=
ruct of_device_id *match)
> =A0 =A0 =A0 =A0/* Start with safe defaults for link connection */
> =A0 =A0 =A0 =A0priv->speed =3D 100;
> =A0 =A0 =A0 =A0priv->duplex =3D DUPLEX_HALF;
> - =A0 =A0 =A0 priv->mdio_speed =3D ((mpc5xxx_get_bus_frequency(op->no=
de) >> 20) / 5) << 1;
> +
> + =A0 =A0 =A0 /* MII speed */
> + =A0 =A0 =A0 clock =3D mpc5xxx_get_bus_frequency(op->node);
> + =A0 =A0 =A0 if (!clock) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Use maximum divider if clock is unkn=
own */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not determine =
IPB clock\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock =3D 0x3F * 5000000;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Scale for a MII clock <=3D 2.5 MHz
> + =A0 =A0 =A0 =A0* Note that only 6 bits (25:30) are available for MI=
I speed.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 speed =3D (clock + 4999999) / 5000000;
> + =A0 =A0 =A0 if (speed > 0x3F) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 speed =3D 0x3F;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "MII clock (%d Hz) ex=
ceeds max (2.5 MHz)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock / speed);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 priv->mdio_speed =3D speed << 1;
>
> =A0 =A0 =A0 =A0/* The current speed preconfigures the speed of the MI=
I link */
> =A0 =A0 =A0 =A0prop =3D of_get_property(op->node, "current-speed", &p=
rop_size);
> diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_=
phy.c
> index 31e6d62..d3537e1 100644
> --- a/drivers/net/fec_mpc52xx_phy.c
> +++ b/drivers/net/fec_mpc52xx_phy.c
> @@ -70,7 +70,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device =
*of,
> =A0 =A0 =A0 =A0struct mpc52xx_fec_mdio_priv *priv;
> =A0 =A0 =A0 =A0struct resource res =3D {};
> =A0 =A0 =A0 =A0int err;
> - =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 int i, clock, speed;
>
> =A0 =A0 =A0 =A0bus =3D mdiobus_alloc();
> =A0 =A0 =A0 =A0if (bus =3D=3D NULL)
> @@ -105,8 +105,25 @@ static int mpc52xx_fec_mdio_probe(struct of_devi=
ce *of,
> =A0 =A0 =A0 =A0dev_set_drvdata(dev, bus);
>
> =A0 =A0 =A0 =A0/* set MII speed */
> - =A0 =A0 =A0 out_be32(&priv->regs->mii_speed,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((mpc5xxx_get_bus_frequency(of->node) >=
> 20) / 5) << 1);
> + =A0 =A0 =A0 clock =3D mpc5xxx_get_bus_frequency(of->node);
> + =A0 =A0 =A0 if (!clock) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Use maximum divider if clock is unkn=
own */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&of->dev, "could not determine =
IPB clock\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock =3D 0x3F * 5000000;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Scale for a MII clock <=3D 2.5 MHz
> + =A0 =A0 =A0 =A0* Note that only 6 bits (25:30) are available for MI=
I speed.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 speed =3D (clock + 4999999) / 5000000;
> + =A0 =A0 =A0 if (speed > 0x3F) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 speed =3D 0x3F;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&of->dev, "MII clock (%d Hz) ex=
ceeds max (2.5 MHz)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock / speed);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 clrsetbits_be32(&priv->regs->mii_speed, 0x7E, speed << =
1);
>
> =A0 =A0 =A0 =A0err =3D of_mdiobus_register(bus, np);
> =A0 =A0 =A0 =A0if (err)
> --
> 1.6.0.6
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
