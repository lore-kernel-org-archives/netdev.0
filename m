From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: DM9000 issue with mem resource management
Date: Fri, 6 Jun 2008 11:01:42 +0200
Message-ID: <200806061101.44638.laurentp@cse-semaphore.com>
References: <200806051743.00614.laurentp@cse-semaphore.com> <20080605174030.GM11277@trinity.fluff.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1260187.bApS36Ej6r";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:48785 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752989AbYFFJBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 05:01:48 -0400
In-Reply-To: <20080605174030.GM11277@trinity.fluff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1260187.bApS36Ej6r
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Ben,

On Thursday 05 June 2008 19:40, Ben Dooks wrote:
> On Thu, Jun 05, 2008 at 05:42:58PM +0200, Laurent Pinchart wrote:
> > Hi everybody,
> >=20
> > I ran into a resource-related bug in the DM9000 driver.
> >=20
> > When the platform device has only 2 resources, dm9000_probe() doesn't s=
et=20
> > db->irq_res, which results in a segfault when the pointer gets
> > dereferenced in dm9000_open().
> >=20
> > I tried to fix the issue, and found out that the resource management co=
de
> > is quite broken.
>=20
> Personally, I'm thinking about just removing the case for 2, and making it
> three resources only. The following in-kernel machines use the following
> resources:
>=20
> arch/arm/mach-at91/board-sam9261ek.c			3
> arch/arm/mach-pxa/cm-x270.c				3
> arch/arm/mach-pxa/em-x270.c				3
> arch/arm/mach-pxa/trizeps4.c				3
> arch/arm/mach-pxa/colibri.c				3
> arch/arm/mach-s3c2410/mach-bast.c			3
> arch/arm/mach-s3c2410/mach-vr1000.c			3
> arch/blackfin/mach-bf527/boards/ezkit.c			2
> arch/blackfin/mach-bf533/boards/H8606.c			2
> arch/blackfin/mach-bf533/boards/ip0x.c			3
> arch/blackfin/mach-bf537/boards/generic_board.c		2
> arch/blackfin/mach-bf537/boards/stamp.c			2
>=20
> As you can see, the #3 outweigh the #2. Unless anyone else objects, I
> will add a patch to reduce this to the case where the driver expects
> 3 resources, and ask the users of #2 to submit changes for their
> bots.
> =20
> > If I understand things correctly, specifying 3 resources makes the DM90=
00=20
> > driver ioremap() the memory, while specifying 2 resources implies that =
the=20
> > platform code already ioremap()ed the memory. Is that right ?
> >=20
> > If so, why does dm9000_probe() call request_mem_region() on ioremap()ed=
=20
> > memory ?
>=20
> Hmm, dunno. I really have no idea why this happened. I don't think this
> was my fault!
> =20
> > Wouldn't it also be simpler to use release_mem_region() in=20
> > dm9000_release_board() instead of release_resource() + kfree() ?
>=20
> If you already have the resource, this is a reasonably simple way of
> ensuring you're disposing of the right resource.
> =20
> > I'd be grateful if someone could confirm my assumptions. I'll then subm=
it
> > a patch to fix those issues.
>=20
> My recommendation is that we remove the 2 case completely, so I'd not bot=
her
> trying to fix this.

I'm not too sure on that one.

I have DM9000 chips on a custom bus. The bus code remaps the whole address=
=20
range (32 bytes per card x 32 slots) in one go and initializes the resource=
=20
with a subset of the remapped range.

Converting that to per-slot ioremaps would create many more mappings. Is th=
at=20
an issue (performance-wise, or in term of a maximum number of mappings if=20
there is a limit) ? I will still need a global mapping, as the bus code nee=
ds=20
to access configuration registers on the individual cards, so I won't be ab=
le=20
to request_mem_region both the global mapping and the individual mappings.=
=20
I'm not sure if that's an issue.

Best regards,

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1260187.bApS36Ej6r
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBISPz48y9gWxC9vpcRAn6IAJ9BOPtiWtJm69WjQYrdOsinAnqb/wCfamfe
e/cchfIiv2Yaw94gj5onxvE=
=ZoBu
-----END PGP SIGNATURE-----

--nextPart1260187.bApS36Ej6r--
