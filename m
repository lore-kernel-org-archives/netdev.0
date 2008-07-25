From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH] dm9000: Support MAC address setting through platform data.
Date: Fri, 25 Jul 2008 11:23:01 +0200
Message-ID: <200807251123.04405.laurentp@cse-semaphore.com>
References: <200807231741.53011.laurentp@cse-semaphore.com> <20080725090530.GA4318@fluff.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1459483.hHJ0qLLn8e";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:26033 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752724AbYGYJXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 05:23:08 -0400
In-Reply-To: <20080725090530.GA4318@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1459483.hHJ0qLLn8e
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 25 July 2008, Ben Dooks wrote:
> On Wed, Jul 23, 2008 at 05:41:52PM +0200, Laurent Pinchart wrote:
> > The dm9000 driver reads the chip's MAC address from the attached EEPROM.
> > When no EEPROM is present, or when the MAC address is invalid, it falls
> > back to reading the address from the chip.
> >=20
> > This patch lets platform code set the desired MAC address through platf=
orm
> > data.
>=20
> I belive we've had discussions about this before on the subject
> as this is generally down to broken boot-loader behaviour.
>=20
> Would people have objections to passing the mac address in on the
> command line and having the driver initialise it from there? Are
> there any other ethernet drivers out there with the same problem?

That wouldn't really help here. I should have provided more background info=
rmation, let's fix this.

The system I'm working on has an ISA-like bus on which users can plug exten=
sion boards. One of those board has a DM9000 chip connected directly to the=
 bus. Having several DM9000-based extension boards in a system is a common =
situation.

The extension boards have a serial EEPROM connected to the bus, but no EEPR=
OM connected to the DM9000. The EEPROM stores, among other information, the=
 MAC address. The platform driver I wrote for the extension board reads the=
 EEPROM content, and needs to pass the MAC address when it registers a DM90=
00 device.

I don't think the boot loader is the right place to fix the issue. It would=
 involve scanning all boards on the extension bus and configuring the DM900=
0, which isn't really practical. Beside, the bus can be reset at runtime wi=
thout involving a full system reset, in which case Linux will have to repro=
gram the DM9000 with a MAC address anyway.

> I've added some notes on the patch anyway.
> =20
> > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> > ---
> >  drivers/net/dm9000.c   |    3 +++
> >  include/linux/dm9000.h |    1 +
> >  2 files changed, 4 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> > index 864295e..6bc8924 100644
> > --- a/drivers/net/dm9000.c
> > +++ b/drivers/net/dm9000.c
> > @@ -716,6 +716,11 @@ dm9000_probe(struct platform_device *pdev)
> >  	for (i =3D 0; i < 6; i +=3D 2)
> >  		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
> > =20
> > +	if (!is_valid_ether_addr(ndev->dev_addr) && pdata !=3D NULL) {
> > +		mac_src =3D "platform data";
> > +		memcpy(ndev->dev_addr, pdata->dev_addr, 6);
> > +	}
> > +
> >  	if (!is_valid_ether_addr(ndev->dev_addr)) {
> >  		/* try reading from mac */
> >  	=09
> > diff --git a/include/linux/dm9000.h b/include/linux/dm9000.h
> > index a375046..4fb49a4 100644
> > --- a/include/linux/dm9000.h
> > +++ b/include/linux/dm9000.h
> > @@ -26,6 +26,7 @@
> > =20
> >  struct dm9000_plat_data {
> >  	unsigned int	flags;
> > +	unsigned char	dev_addr[6];
>=20
> how about unsigned char *mac_addr, so that you can detect
> if the address has not been passed in easily. dev_addr is
> not really descriptive enough as a name.

mac_addr is indeed a better name. Using an unsigned char * involves extra s=
torage. What about a DM9000_PLATF_MAC_ADDR flag instead ?

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1459483.hHJ0qLLn8e
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEABECAAYFAkiJm3gACgkQ8y9gWxC9vpc1/ACfYBUAiIObXOPQUOUl3RjkC2Q2
0ugAn2dRsrshvGF7WQh/6MluHA1j4/6s
=J8lw
-----END PGP SIGNATURE-----

--nextPart1459483.hHJ0qLLn8e--
