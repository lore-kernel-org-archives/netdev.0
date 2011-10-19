From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#645589: linux-image-3.0.0-2-amd64: sky2 rx errors on 3.0,
 2.6.32 works
Date: Wed, 19 Oct 2011 05:09:25 +0100
Message-ID: <1318997365.23980.43.camel@deadeye>
References: <20111017074016.6840.77265.reportbug@thor.viidakko.fi>
	 <1318909386.3340.91.camel@deadeye>
	 <20111018111308.2c5a6580@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Knx6sXahZm09jkF+X9Rt"
Cc: 645589@bugs.debian.org, Antti Salmela <asalmela@iki.fi>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33181 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754318Ab1JSEJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 00:09:54 -0400
In-Reply-To: <20111018111308.2c5a6580@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Knx6sXahZm09jkF+X9Rt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-10-18 at 11:13 -0700, Stephen Hemminger wrote:
> On Tue, 18 Oct 2011 04:43:06 +0100
> Ben Hutchings <ben@decadent.org.uk> wrote:
>=20
> > On Mon, 2011-10-17 at 10:40 +0300, Antti Salmela wrote:
> > > Package: linux-2.6
> > > Version: 3.0.0-5
> > > Severity: normal
> > >=20
> > >=20
> > > sky2 loses packets on 3.0 (-3 and -5) and 3.1-rc7, 2.6.32-38 and
> > > setting interface to promiscuous works.
> > >=20
> > > [   60.118244] sky2 0000:02:00.0: eth0: rx error, status 0xb92100 len=
gth 185
> > > [   62.664370] sky2 0000:02:00.0: eth0: rx error, status 0x602100 len=
gth 96
> > > [   63.370051] sky2 0000:02:00.0: eth0: rx error, status 0x422100 len=
gth 66
> > > [   63.714672] sky2 0000:02:00.0: eth0: rx error, status 0x722100 len=
gth 114
> > > [   64.513458] device eth0 entered promiscuous mode
> >=20
> > It looks like this is a bug in accounting of VLAN tags, though I don't
> > see what difference promiscuous mode should make.
> >=20
> > The log messages show that status has the VLAN flag (bit 13) set and th=
e
> > length field (bits 16:28) equals the length passed into sky2_receive(),
> > but that function expects the length field to be greater by VLAN_HLEN.
> >=20
> > This device is:
> >=20
> > [...]
> > > 02:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd. 88E=
8053 PCI-E Gigabit Ethernet Controller [11ab:4362] (rev 19)
> > > 	Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet co=
ntroller PCIe (Asus) [1043:8142]
> > > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- =
Stepping- SERR- FastB2B- DisINTx+
> > > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TA=
bort- <MAbort- >SERR- <PERR- INTx-
> > > 	Latency: 0, Cache Line Size: 16 bytes
> > > 	Interrupt: pin A routed to IRQ 43
> > > 	Region 0: Memory at cdefc000 (64-bit, non-prefetchable) [size=3D16K]
> > > 	Region 2: I/O ports at c800 [size=3D256]
> > > 	Expansion ROM at cdec0000 [disabled] [size=3D128K]
> > > 	Capabilities: <access denied>
> > > 	Kernel driver in use: sky2
> > [...]
>=20
> The accounting is supposed to be:
>    MAC =3D total length of packet (including vlan)
>    DMA =3D bytes dma'd to buffer (does not include vlan)
> Looks like the code is incorrect for the case where hardware
> VLAN stripping is disabled.

But if that's true, I'd expect to see these errors in 2.6.32 (where VLAN
tag extraction is disabled until a VLAN group is created) and not in 3.0
(where it is enabled by default).  Instead it's 3.0 that is broken.

I also don't see why changing promiscuous mode would make a difference.

> What happens is that status bit
> still has the VLAN flag, but DMA engine leaves the VLAN tag
> in the DMA buffer so the check fails.
>=20
> Proper accounting would involve more state machine mechanics
> about whether VLAN tag has already been seen in current receive
> status ring.

Shouldn't you should restart the relevant queue when changing VLAN tag
extraction/insertion?

> For now probably best to do something like:
>=20
> --- net-next.orig/drivers/net/ethernet/marvell/sky2.c	2011-10-18 11:09:04=
.108683763 -0700
> +++ net-next/drivers/net/ethernet/marvell/sky2.c	2011-10-18 11:09:53.6612=
64323 -0700
> @@ -2543,7 +2543,8 @@ static struct sk_buff *sky2_receive(stru
>  	struct sk_buff *skb =3D NULL;
>  	u16 count =3D (status & GMR_FS_LEN) >> 16;
> =20
> -	if (status & GMR_FS_VLAN)
> +	if ((dev->features & NETIF_F_HW_VLAN_RX) &&
> +	    (status & GMR_FS_VLAN))
>  		count -=3D VLAN_HLEN;	/* Account for vlan tag */

It looks like this is needed to restore the workaround for broken status
flags on the FE+.  But I doubt it will fix this problem.

Ben.

>  	netif_printk(sky2, rx_status, KERN_DEBUG, dev,
>=20
>=20
>=20
>=20
>=20

--=20
Ben Hutchings
73.46% of all statistics are made up.

--=-Knx6sXahZm09jkF+X9Rt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATp5Ndue/yOyVhhEJAQojFhAAqNwaGFuHwwb29bbusxnOBMPQfbH6VVuP
RO2KgEAv0c0CeVOWK5RnLdpI92zm/G9wd6T9Ykgx9IGZ05jeAaKRcs8FJcnr7mFY
I1nh6mLdhDASwzAFRT0v5bYfTF2RpyHFk8x7jetn/BGuFHWGdzOVOUgoWprfPubf
vVW+rPA2AewZV9Wo0F3dim3YM2YQWJ63igEvcGwZk5pg3vpltI/vtak8TPwAe3MI
Y8PIElOMab09B8/eZ59I5zlCYdIeec1hvxVljWo2zakh3ZCNF/E1ZA7luokH/y0d
XtXWknc9OQZOZi9/NZNhqae6b58AzplBYHdrYi22W49qsFUno75tQ0L2hXJ/bVS+
QnT7qgKoNHf+O8PvhDkvb9EYLc46FHgageNvZRWtgnkb8T0sqNnDd9vH1mjj0xNj
yzAGOGMOMupuADa8MWCugMum1oOmfhUrYEpshoFBXM94juhbhIO1u/EkxNa1JN2c
M1cTGwwm8Wxtq89vSpOibRiM/V+g9K+w16FcIqYZxFu1bxRyG4qvJZZ4N6KWsfX9
7Gx6CQzxI3fQFgnN7nLeeglOXtIomiBX7ptEvYH3lX4qNyCQlofyRRnWhsXQ8NJE
mPWwzrQ9kGnhLZ3AC4Bw4lVoCW5UkRR96XRB+9yEAWbDcjQFFTT0auHxhGed0HAa
1hdR+qCIhR4=
=nAh2
-----END PGP SIGNATURE-----

--=-Knx6sXahZm09jkF+X9Rt--
