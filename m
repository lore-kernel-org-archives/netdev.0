From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2 v2] MPC52xx FEC: be more conservative when setting
	MII_SPEED register
Date: Thu, 16 Jul 2009 16:48:08 -0600
Message-ID: <fa686aa40907161548n1658afaei8dce2d893222019c@mail.gmail.com>
References: <1247671133-12148-1-git-send-email-wd@denx.de>
	<1247780546-4426-2-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1247780546-4426-2-git-send-email-wd@denx.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 16, 2009 at 3:42 PM, Wolfgang Denk<wd@denx.de> wrote:
> This patch adds error checking and prevents clobbering unrelated bits
> (reserved bits or the DIS_PREAMBLE bit) when writing the MII_SPEED
> register on MPC52xx systems.
>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> Cc: <netdev@vger.kernel.org>

Mostly good.  One comment below.  When it's resolved, feel free to add
my acked-by line.  Thanks for getting this done.

> @@ -105,8 +105,23 @@ static int mpc52xx_fec_mdio_probe(struct of_device *=
of,
> =A0 =A0 =A0 =A0dev_set_drvdata(dev, bus);
>
> =A0 =A0 =A0 =A0/* set MII speed */
> - =A0 =A0 =A0 out_be32(&priv->regs->mii_speed,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((mpc5xxx_get_bus_frequency(of->node) >> 20=
) / 5) << 1);
> + =A0 =A0 =A0 clock =3D mpc5xxx_get_bus_frequency(of->node);
> + =A0 =A0 =A0 if (!clock) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&of->dev, "could not determine IPS/=
IPB clock\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unmap;
> + =A0 =A0 =A0 }

Just thought of something.  If it cannot find the clock, then wouldn't
it be better to just use the maximum divider and print a warning
instead of bailing completely?  This goes for the other patch as well.

> +
> + =A0 =A0 =A0 /* scale for a MII clock <=3D 2.5 MHz */
> + =A0 =A0 =A0 speed =3D (clock + 2499999) / 2500000;
> +
> + =A0 =A0 =A0 /* only 6 bits (25:30) available for MII speed */
> + =A0 =A0 =A0 if (speed > 0x3F) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 speed =3D 0x3F;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&of->dev, "MII clock (%d Hz) exceed=
s max (2.5 MHz)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock / speed);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 clrsetbits_be32(&priv->regs->mii_speed, 0x7E, speed << 1);
>
> =A0 =A0 =A0 =A0err =3D of_mdiobus_register(bus, np);
> =A0 =A0 =A0 =A0if (err)
> --
> 1.6.0.6
>
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
