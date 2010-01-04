From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH net-next 2/3] can: mscan-mpc5xxx: add support for the
	MPC521x processor
Date: Mon, 4 Jan 2010 17:24:41 +0100
Message-ID: <20100104162441.GA4665@pengutronix.de>
References: <1262420274-16586-1-git-send-email-wg@grandegger.com> <1262420274-16586-2-git-send-email-wg@grandegger.com> <1262420274-16586-3-git-send-email-wg@grandegger.com> <20100102135734.GC2239@pengutronix.de> <4B3F6F6B.5070004@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Cc: Socketcan-core@lists.berlios.de, Netdev@vger.kernel.org,
	Devicetree-discuss@lists.ozlabs.org, Linuxppc-dev@lists.ozlabs.org,
	Wolfgang Grandegger <wg@denx.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:32891 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833Ab0ADQYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 11:24:43 -0500
Content-Disposition: inline
In-Reply-To: <4B3F6F6B.5070004@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Wolfgang,

first the good news: Your patches also work with our MPC5121-board.

> >> +#else /* !CONFIG_PPC_MPC5200 */
> >> +static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
> >> +					   const char *clock_name,
> >> +					   int *mscan_clksrc)
> >> +{
> >> +	return 0;
> >> +}
> >> +#endif /* CONFIG_PPC_MPC5200 */
> >=20
> > Hmmm, I don't really like those empty functions. I once used the data-f=
ield of
> > struct of_device_id, which carried a function pointer to a specific
> > init-function for the matched device. What do you think about such an a=
pproach?
>=20
> Often the problem is that the function will not compile on the other MPC
> arch. This is not true here. So, the main reason for the #ifdefs is
> space saving. Your approach will not help in both cases.

My idea was: it might be nice to save both #else-branches and the if-clause=
 in
probe() which calls this get_clock() or the other (and then another in case
there will be a new mpc5xyz-user in the future). And replace it with some
mpc5xxx_custom_init() which is taken from of_device_id->data. No big issue,
though; no show-stopper.

> >> +
> >> +#ifdef CONFIG_PPC_MPC512x
> >> +struct mpc512x_clockctl {
> >> +	u32 spmr;		/* System PLL Mode Reg */
> >> +	u32 sccr[2];		/* System Clk Ctrl Reg 1 & 2 */
> >> +	u32 scfr1;		/* System Clk Freq Reg 1 */
> >> +	u32 scfr2;		/* System Clk Freq Reg 2 */
> >> +	u32 reserved;
> >> +	u32 bcr;		/* Bread Crumb Reg */
> >> +	u32 pccr[12];		/* PSC Clk Ctrl Reg 0-11 */
> >> +	u32 spccr;		/* SPDIF Clk Ctrl Reg */
> >> +	u32 cccr;		/* CFM Clk Ctrl Reg */
> >> +	u32 dccr;		/* DIU Clk Cnfg Reg */
> >> +	u32 mccr[4];		/* MSCAN Clk Ctrl Reg 1-3 */
> >> +};

I wonder if this (and the occurence in clock.c) should be factored out and
moved to asm/mpc5xxx.h?

> >> +
> >> +static struct of_device_id mpc512x_clock_ids[] __devinitdata =3D {
> >> +	{ .compatible =3D "fsl,mpc5121-clock", },
> >> +	{}
> >> +};
> >> +
> >> +static u32  __devinit mpc512x_can_get_clock(struct of_device *ofdev,
> >> +					    const char *clock_name,
> >> +					    int *mscan_clksrc,
> >> +					    ssize_t mscan_addr)
> >> +{
> >> +	struct mpc512x_clockctl __iomem *clockctl;
> >> +	struct device_node *np_clock;
> >> +	struct clk *sys_clk, *ref_clk;
> >> +	int plen, clockidx, clocksrc =3D -1;
> >> +	u32 sys_freq, val, clockdiv =3D 1, freq =3D 0;
> >> +	const u32 *pval;
> >> +
> >> +	np_clock =3D of_find_matching_node(NULL, mpc512x_clock_ids);
> >> +	if (!np_clock) {
> >> +		dev_err(&ofdev->dev, "couldn't find clock node\n");
> >> +		return -ENODEV;
> >> +	}
> >> +	clockctl =3D of_iomap(np_clock, 0);
> >> +	if (!clockctl) {
> >> +		dev_err(&ofdev->dev, "couldn't map clock registers\n");
> >> +		return 0;
> >> +	}
> >> +
> >> +	/* Determine the MSCAN device index from the physical address */
> >> +	clockidx =3D (mscan_addr & 0x80) ? 1 : 0;
> >> +	if (mscan_addr & 0x2000)
> >> +		clockidx +=3D 2;
> >=20
> > The PSCs use 'cell-index', here we use mscan_addr to derive the index. =
This is
> > not consistent, but should be IMHO. Now, which is the preferred way? I =
think
> > I'd go for 'cell-index', as other processors might have mscan_addr shuf=
fled.
> > Also, we could use 'of_iomap' again in the probe_routine.
>=20
> I understood that "cell-index" is deprecated and it has been removed
> from many nodes. That's why I used the address to derive the index.

Well, the arguments in your other mail make sense to me, so keep it this wa=
y.
As not only the index-issue, but also the clock-handling is different for t=
he
PSCs, it is at least consistently inconsistent :D

One further note: I couldn't spot any code handling Rev1 of the MPC5121? Do=
 you
plan to add such code? If not, we should at least put a comment that it is
missing. The binding documentation should be updated as well, as you can't =
use
all options on such revisions.

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAktCFkkACgkQD27XaX1/VRuo7wCdHIpzMXt5e19SoPavgUADo+6g
NpYAn3pQG3D2coex8knJwkuych0cotUK
=ks9F
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
