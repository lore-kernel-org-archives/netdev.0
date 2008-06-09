From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: DM9000 issue with mem resource management
Date: Mon, 9 Jun 2008 15:41:41 +0200
Message-ID: <200806091541.44258.laurentp@cse-semaphore.com>
References: <200806051743.00614.laurentp@cse-semaphore.com> <200806061101.44638.laurentp@cse-semaphore.com> <20080607213504.GA31817@trinity.fluff.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1321937.cJ0KaEIxNj";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org
To: Ben Dooks <ben-linux@fluff.org>, g@trinity.fluff.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:32315 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752150AbYFINls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 09:41:48 -0400
In-Reply-To: <20080607213504.GA31817@trinity.fluff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1321937.cJ0KaEIxNj
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Ben,

On Saturday 07 June 2008 23:35, Ben Dooks, g@trinity.fluff.org wrote:
> On Fri, Jun 06, 2008 at 11:01:42AM +0200, Laurent Pinchart wrote:
> > Hi Ben,
> >=20
> > On Thursday 05 June 2008 19:40, Ben Dooks wrote:
> > > On Thu, Jun 05, 2008 at 05:42:58PM +0200, Laurent Pinchart wrote:
> > > > Hi everybody,
> > > >=20
> > > > I ran into a resource-related bug in the DM9000 driver.
> > > >=20
> > > > When the platform device has only 2 resources, dm9000_probe() doesn=
't
> > > > set db->irq_res, which results in a segfault when the pointer gets
> > > > dereferenced in dm9000_open().
> > > >=20
> > > > I tried to fix the issue, and found out that the resource management
> > > > code is quite broken.
> > >=20
> > > Personally, I'm thinking about just removing the case for 2, and maki=
ng
> > > it three resources only. The following in-kernel machines use the
> > > following resources:
> > >=20
> > > arch/arm/mach-at91/board-sam9261ek.c			3
> > > arch/arm/mach-pxa/cm-x270.c				3
> > > arch/arm/mach-pxa/em-x270.c				3
> > > arch/arm/mach-pxa/trizeps4.c				3
> > > arch/arm/mach-pxa/colibri.c				3
> > > arch/arm/mach-s3c2410/mach-bast.c			3
> > > arch/arm/mach-s3c2410/mach-vr1000.c			3
> > > arch/blackfin/mach-bf527/boards/ezkit.c			2
> > > arch/blackfin/mach-bf533/boards/H8606.c			2
> > > arch/blackfin/mach-bf533/boards/ip0x.c			3
> > > arch/blackfin/mach-bf537/boards/generic_board.c		2
> > > arch/blackfin/mach-bf537/boards/stamp.c			2
> > >=20
> > > As you can see, the #3 outweigh the #2. Unless anyone else objects, I
> > > will add a patch to reduce this to the case where the driver expects
> > > 3 resources, and ask the users of #2 to submit changes for their
> > > bots.
> > > =20
> > > > If I understand things correctly, specifying 3 resources makes the
> > > > DM9000 driver ioremap() the memory, while specifying 2 resources
> > > > implies that the platform code already ioremap()ed the memory. Is t=
hat
> > > > right ?=20
> > > >=20
> > > > If so, why does dm9000_probe() call request_mem_region() on
> > > > ioremap()ed memory ?
> > >=20
> > > Hmm, dunno. I really have no idea why this happened. I don't think th=
is
> > > was my fault!
> > > =20
> > > > Wouldn't it also be simpler to use release_mem_region() in=20
> > > > dm9000_release_board() instead of release_resource() + kfree() ?
> > >=20
> > > If you already have the resource, this is a reasonably simple way of
> > > ensuring you're disposing of the right resource.
> > > =20
> > > > I'd be grateful if someone could confirm my assumptions. I'll then
> > > > submit a patch to fix those issues.
> > >=20
> > > My recommendation is that we remove the 2 case completely, so I'd not
> > > bother trying to fix this.
> >=20
> > I'm not too sure on that one.
>=20
> Well, having thought about it some more, the 2 address case is also an
> abuse of the IORESOURCE mechanism with platform devices, as the core
> driver code uses the .start and .end to register with the relevant
> iomem reservation code.

Agreed.

> I'm going more strongly on removing the #2 case unless anyone can come up
> with a really compelling reason to keep it.

Ok. I'll submit a patch.

BTW, why do the some boards declare the data resource as more than 4 bytes=
=20
long ?

> > I have DM9000 chips on a custom bus. The bus code remaps the whole addr=
ess=20
> > range (32 bytes per card x 32 slots) in one go and initializes the
> > resource with a subset of the remapped range.
> >
> > Converting that to per-slot ioremaps would create many more mappings. Is
> > that an issue (performance-wise, or in term of a maximum number of
> > mappings if there is a limit) ? I will still need a global mapping, as =
the
> > bus code needs to access configuration registers on the individual card=
s,
> > so I won't be able to request_mem_region both the global mapping and the
> > individual mappings.
> > I'm not sure if that's an issue.=20
>=20
> That sounds like a problem with the bus code mapping too much of the memo=
ry
> and thus causing a problem for any subsequent drivers.

That's right. It had been done that way to save mappings. Without a global=
=20
mapping I'll need 64 mappings instead of 1.

> Having an extra mapping in is only a minor problem compared with the other
> travesty the 2 region case is currently causing.

What about 63 extra mappings ?

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1321937.cJ0KaEIxNj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBITTMY8y9gWxC9vpcRAh5bAJ4oZxJn+OATh4YEZfhyHDBigDAxMwCfY+mv
tZprAeZM529hOJYMxobMM+E=
=iERf
-----END PGP SIGNATURE-----

--nextPart1321937.cJ0KaEIxNj--
