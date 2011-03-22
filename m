From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 4/4] drivers/net/fec: Don't mess with configured MAC
 addresses.
Date: Tue, 22 Mar 2011 16:55:06 +0800
Message-ID: <20110322085505.GF28098@S2100-06.ap.freescale.net>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
 <a6ba75577552abe8d5045434030c276d5f45779a.1300724245.git.LW@KARO-electronics.de>
 <20110322074336.GE28098@S2100-06.ap.freescale.net>
 <19848.21653.877174.416543@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <u.kleine-koenig@pengutronix.de>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1.bigfish.com ([213.199.180.138]:2729 "EHLO
	AM1EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750734Ab1CVIyl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 04:54:41 -0400
Content-Disposition: inline
In-Reply-To: <19848.21653.877174.416543@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 08:49:41AM +0100, Lothar Wa=DFmann wrote:
> Hi,
>=20
> Shawn Guo writes:
> > On Mon, Mar 21, 2011 at 05:37:36PM +0100, Lothar Wa=DFmann wrote:
> > > The FEC driver currently uses the MAC address assigned to the fir=
st
> > > interface incremented by one for the second interface.
> > >=20
> > > Change this to be able to configure distinct MAC addresses via
> > > platform_data.
> > >=20
> > > Signed-off-by: Lothar Wa=DFmann <LW@KARO-electronics.de>
> > > ---
> > >  drivers/net/fec.c |    9 ++-------
> > >  1 files changed, 2 insertions(+), 7 deletions(-)
> > >=20
> > > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> > > index 3666524..9d89e99 100644
> > > --- a/drivers/net/fec.c
> > > +++ b/drivers/net/fec.c
> > > @@ -750,13 +750,12 @@ static void __inline__ fec_get_mac(struct n=
et_device *ndev)
> > >  	/*
> > >  	 * 2) from flash or fuse (via platform data)
> > >  	 */
> > > +	if (pdata)
> > > +		memcpy(iap, pdata->mac, ETH_ALEN);
> > >  	if (!is_valid_ether_addr(iap)) {
> > >  #ifdef CONFIG_M5272
> > >  		if (FEC_FLASHMAC)
> > >  			iap =3D (unsigned char *)FEC_FLASHMAC;
> > > -#else
> > > -		if (pdata)
> > > -			memcpy(iap, pdata->mac, ETH_ALEN);
> > >  #endif
> > >  	}
> > > =20
> > > @@ -772,10 +771,6 @@ static void __inline__ fec_get_mac(struct ne=
t_device *ndev)
> > >  	}
> > > =20
> > >  	memcpy(ndev->dev_addr, iap, ETH_ALEN);
> > > -
> > > -	/* Adjust MAC if using macaddr */
> > > -	if (iap =3D=3D macaddr)
> > > -		 ndev->dev_addr[ETH_ALEN-1] =3D macaddr[ETH_ALEN-1] + fep->pde=
v->id;
> > >  }
> > > =20
> > >  /* -------------------------------------------------------------=
------------ */
> > > --=20
> > > 1.5.6.5
> > >=20
> > >=20
> > NAK.
> >=20
> > The 'mac' was designed as an optional member of fec
> > platform_data, as some platforms may not be able to provide it. Thi=
s
> > patch breaks the order of getting mac, and will not work on the
> > platform that does not provide an valid mac with either platform_da=
ta
> > or controller mac registers, even there may be one in the kernel
> > command line.
> >=20
> > The existing code takes mac address from kernel command line as the
> > first choice, and only falls through on other options when it's
> > invalid/unavailable.  So an valid mac from  kernel command line wil=
l
> > always get fec work anyway.
> >=20
> The problem is that you can only assign one mac address on the kernel
> cmdline and the second one will be derived from the first one.
> And even if the MAC address is set via platform_data it will not be
> used for the second interface.
>=20
Yes, these are problems.  But we can fix them like the following while
still make fec0 work with fec.macaddr.  This is useful on the platform
that neither platform code nor boot loader gives an valid mac address.

@@ -721,7 +721,7 @@ static void __inline__ fec_get_mac(struct net_devic=
e *ndev)
 {
        struct fec_enet_private *fep =3D netdev_priv(ndev);
        struct fec_platform_data *pdata =3D fep->pdev->dev.platform_dat=
a;
-       unsigned char *iap, tmpaddr[ETH_ALEN];
+       unsigned char iap[ETH_ALEN], tmpaddr[ETH_ALEN];

        /*
         * try to get mac address in following order:
@@ -729,7 +729,10 @@ static void __inline__ fec_get_mac(struct net_devi=
ce *ndev)
         * 1) module parameter via kernel command line in form
         *    fec.macaddr=3D0x00,0x04,0x9f,0x01,0x30,0xe0
         */
-       iap =3D macaddr;
+       if (fep->pdev->id =3D=3D 0)
+               memcpy(iap, macaddr, ETH_ALEN);
+       else
+               memset(iap, 0, ETH_ALEN);

        /*
         * 2) from flash or fuse (via platform data)
@@ -752,14 +755,10 @@ static void __inline__ fec_get_mac(struct net_dev=
ice *ndev)
                        be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
                *((unsigned short *) &tmpaddr[4]) =3D
                        be16_to_cpu(readl(fep->hwp + FEC_ADDR_HIGH) >> =
16);
-               iap =3D &tmpaddr[0];
+               memcpy(iap, tmpaddr, ETH_ALEN);
        }

        memcpy(ndev->dev_addr, iap, ETH_ALEN);
-
-       /* Adjust MAC if using macaddr */
-       if (iap =3D=3D macaddr)
-                ndev->dev_addr[ETH_ALEN-1] =3D macaddr[ETH_ALEN-1] + f=
ep->pdev->id;
 }

> IMO an ethernet driver has no business in inventing arbitrary MAC
> addresses. Either the MAC address is supplied by the boot loader or
> the platform code or it has to be assigned from userspace via
> ifconfig.
>=20
ifconfig will not be an option if we need to mount nfs as rootfs.
So we at lease need to have kernel command line for fec0 mac address
for the last chance, if neither platform data nor boot loader provides
mac address.  And let ifconfig provide mac for fec1 from user space.

--=20
Regards,
Shawn

