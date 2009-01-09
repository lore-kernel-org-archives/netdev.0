From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: mal_probe crash
Date: Fri, 9 Jan 2009 15:42:25 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0901091533000.13230__28810.4178537198$1231512268$gmane$org@vixen.sonytel.be>
References: <20090107154434.0c9437ef@lappy.seanm.ca>
 <20090108204634.GB2337@yoda.jdub.homelinux.org> <1231368610.2142.27.camel@pasglop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Boyer <jwboyer@gmail.com>,
	linuxppc-dev <linuxppc-dev@ozlabs.org>,
	Sean MacLennan <smaclennan@pikatech.com>,
	netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:37114 "EHLO
	vervifontaine.sonycom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753626AbZAIOmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 09:42:32 -0500
In-Reply-To: <1231368610.2142.27.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Jan 2009, Benjamin Herrenschmidt wrote:
> On Thu, 2009-01-08 at 15:46 -0500, Josh Boyer wrote:
> > On Wed, Jan 07, 2009 at 03:44:34PM -0500, Sean MacLennan wrote:
> > >With Linus' latest git, mal_probe crashes. It calls netif_napi_add=
 with
> > >the first parameter NULL. This was ok since the parameter, a net
> > >device, was only used if CONFIG_NETPOLL was set.
> > >
> > >Now it is always de-referenced. A quick check shows that ibm_newem=
ac is
> > >the only driver that passed NULL as the first parameter to this ca=
ll in
> > >2.6.28.
> > >
> > >I don't really follow ibm_newemac changes, so the patch may be wai=
ting
> > >to be applied. This is really just a heads up.
> >=20
> > I haven't heard of that, so I doubt there's a patch pending.  *Sigh=
*
>=20
> There isn't that I know of. The EMAC code creates a single NAPI insta=
nce
> for all EMACs and I think used to completely disconnect things. The o=
ld
> code created a fake netdev just for NAPI, that became unnecessary wit=
h
> the new NAPI stuff.... but it looks like the way we do things now
> displeases some changes in the network stack. I'll have to dig.

Verified on my Sequoia (which now lost its network :-(

The regression/problem (requiring a valid net_device in netif_napi_add(=
), even
if CONFIG_NETPOLL=3Dn) seems to be introduced by commit
d565b0a1a9b6ee7dff46e1f68b26b526ac11ae50 ("net: Add Generic Receive Off=
load
infrastructure").

However, it was broken before, in case CONFIG_NETPOLL=3Dy.

So mal_probe() (triggered by mal_init()) needs to know about the net_de=
vice
before it has been allocated by emac_probe() (triggered by
of_register_platform_driver(&emac_driver)):

| static int __init emac_init(void)
| {
| 	int rc;
|=20
| 	printk(KERN_INFO DRV_DESC ", version " DRV_VERSION "\n");
|=20
| 	/* Init debug stuff */
| 	emac_init_debug();
|=20
| 	/* Build EMAC boot list */
| 	emac_make_bootlist();
|=20
| 	/* Init submodules */
| 	rc =3D mal_init();
| 	if (rc)
| 		goto err;
| 	rc =3D zmii_init();
| 	if (rc)
| 		goto err_mal;
| 	rc =3D rgmii_init();
| 	if (rc)
| 		goto err_zmii;
| 	rc =3D tah_init();
| 	if (rc)
| 		goto err_rgmii;
| 	rc =3D of_register_platform_driver(&emac_driver);
| 	if (rc)
| 		goto err_tah;
|=20
| 	return 0;
|=20
|  err_tah:
| 	tah_exit();
|  err_rgmii:
| 	rgmii_exit();
|  err_zmii:
| 	zmii_exit();
|  err_mal:
| 	mal_exit();
|  err:
| 	return rc;
| }

Can the order of mal_init() and of_register_platform_driver(&emac_drive=
r) be
reversed? If yes, there still has some link to be made between the mal =
and the
emac devices.

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre Europe
The Corporate Village =C2=B7 Da Vincilaan 7-D1 =C2=B7 B-1935 Zaventem =C2=
=B7 Belgium

Phone:    +32 (0)2 700 8453
=46ax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 =C2=B7 RPR Brussels
=46ortis =C2=B7 BIC GEBABEBB =C2=B7 IBAN BE41293037680010
