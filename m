From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2] MPC52xx FEC: be more conservative when setting
	MII_SPEED register
Date: Wed, 15 Jul 2009 11:18:59 -0600
Message-ID: <fa686aa40907151018n194a154cmb8549c98c673d2bb@mail.gmail.com>
References: <1247578966-9847-1-git-send-email-wd@denx.de> <1247671133-12148-2-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:45251 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755654AbZGORTU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 13:19:20 -0400
Received: by gxk9 with SMTP id 9so2430342gxk.13
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2009 10:19:19 -0700 (PDT)
In-Reply-To: <1247671133-12148-2-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2009 at 9:18 AM, Wolfgang Denk<wd@denx.de> wrote:
> This patch adds error checking and prevents clobbering unrelated bits
> (reserved bits or the DIS_PREAMBLE bit) when writing the MII_SPEED
> register on MPC52xx systems.
>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> Cc: <netdev@vger.kernel.org>

As I mentioned in the other patch, I don't want the 5121 and 5200 FEC
devices using common code for this.  It is a tiny block of code and
they are different devices.  Just open code the needed calculation
into this driver.

g.

> ---
> =A0drivers/net/fec_mpc52xx.c =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/fec_mpc52xx_phy.c | =A0 =A06 ++++--
> =A02 files changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index cc78633..b69d440 100644
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
> diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_=
phy.c
> index 31e6d62..f733d43 100644
> --- a/drivers/net/fec_mpc52xx_phy.c
> +++ b/drivers/net/fec_mpc52xx_phy.c
> @@ -105,8 +105,10 @@ static int mpc52xx_fec_mdio_probe(struct of_devi=
ce *of,
> =A0 =A0 =A0 =A0dev_set_drvdata(dev, bus);
>
> =A0 =A0 =A0 =A0/* set MII speed */
> - =A0 =A0 =A0 out_be32(&priv->regs->mii_speed,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((mpc5xxx_get_bus_frequency(of->node) >=
> 20) / 5) << 1);
> + =A0 =A0 =A0 i =3D mpc5xxx_get_mii_speed(of);
> + =A0 =A0 =A0 if (i<0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unmap;
> + =A0 =A0 =A0 clrsetbits_be32(&priv->regs->mii_speed, 0x7E, i);
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
