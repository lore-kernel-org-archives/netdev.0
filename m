From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 70/71] tile: Move the Tilera driver
Date: Tue, 02 Aug 2011 22:47:34 -0700
Message-ID: <1312350454.2294.86.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-71-git-send-email-jeffrey.t.kirsher@intel.com>
	 <4E36E0B2.60900@tilera.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-UCa1Ibp8KQEJc/4//tS5"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13156 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575Ab1HCFrf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 01:47:35 -0400
In-Reply-To: <4E36E0B2.60900@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-UCa1Ibp8KQEJc/4//tS5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-01 at 10:21 -0700, Chris Metcalf wrote:
> On 7/30/2011 11:27 PM, Jeff Kirsher wrote:
> > Move the Tilera driver into drivers/net/ethernet/tile and
> > make the necessary Kconfig and Makefile changes.
> >
> > CC: Chris Metcalf <cmetcalf@tilera.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > [...]
> > +++ b/drivers/net/ethernet/tile/Kconfig
> > @@ -0,0 +1,28 @@
> > +#
> > +# Tilera network device configuration
> > +#
> > +
> > +config NET_VENDOR_TILERA
> > +	bool "Tilera devices"
> > +	depends on TILE
> > +	---help---
> > +	  If you have a network (Ethernet) card belonging to this class, say =
Y
> > +	  and read the Ethernet-HOWTO, available from
> > +	  <http://www.tldp.org/docs.html#howto>.
> > +
> > +	  Note that the answer to this question doesn't directly affect the
> > +	  kernel: saying N will just cause the configurator to skip all
> > +	  the questions about Tilera cards. If you say Y, you will be asked f=
or
> > +	  your specific card in the following questions.
> > +
> > +config TILE_NET
> > +	tristate "Tilera GBE/XGBE network driver support"
> > +	depends on NET_VENDOR_TILERA && TILE
> > +	default y
> > +	select CRC32
> > +	---help---
> > +	  This is a standard Linux network device driver for the
> > +	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
> > +
> > +	  To compile this driver as a module, choose M here: the module
> > +	  will be called tile_net.
>=20
> Overall, this seems fine, since the Tilera drivers get grouped more
> appropriately as a result.  However, the drivers in question are not
> Ethernet cards (and Tilera is not an Ethernet card vendor and has no plan=
s
> to become one).  Instead, this is the driver support for the built-in
> networking hardware on the Tilera multicore CPU chip.  I'm happy to group
> this support under drivers/net/ethernet/tile/, but I think it's appropria=
te
> to default it to "Y" if you are building a TILE kernel (since you are
> guaranteed to have the networking hardware available).
>=20
> I suspect for now the cleanest thing to do is to fold the two config
> options together, using NET_VENDOR_TILERA for consistency with other
> NET_VENDOR_xxx symbols, and defaulting it to "Y" via "depends on TILE".  =
I
> don't think the Ethernet-HOWO reference is particularly helpful since it
> mostly tackles all the various card issues, kernel boot param issues, etc=
.,
> none of which are relevant to this driver.  Something like:
>=20
> +config NET_VENDOR_TILERA
> +	bool "Tilera devices"
> +	depends on TILE
> +	default y
> +	select CRC32
> +	---help---
> +	  This is a standard Linux network device driver for the arch/tile
> +	  on-chip Gigabit Ethernet and XAUI interfaces.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called tile_net.
>=20
>=20
> Obviously you'd also need to tweak the TILE_NET symbol in the Makefile to
> be VENDOR_TILERA.  If this makes sense to you, go ahead and make the
> change, and feel free to use my
>=20
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>
>=20

This definitely makes sense, I was not sure if there is ever a
possibility of another driver from Tilera for future silicon on TILE
kernels, so I would want to lean towards the Kconfig format I am using
(which got a minor tweak since I sent this out) because it provides a
easy what to add additional drivers.

I can modify the current Kconfig so that it defaults to yes on Tile
kernels by doing this:

+config NET_VENDOR_TILERA
+       bool "Tilera devices"
+       depends on TILE
+	default y if TILE
+       ---help---
+         If you have a network (Ethernet) card belonging to this class,
say Y
+         and read the Ethernet-HOWTO, available from
+         <http://www.tldp.org/docs.html#howto>.
+
+         Note that the answer to this question doesn't directly affect
the
+         kernel: saying N will just cause the configurator to skip all
+         the questions about Tilera cards. If you say Y, you will be
asked for
+         your specific card in the following questions.
+
+if NET_VENDOR_TILERA
+
+config TILE_NET
+       tristate "Tilera GBE/XGBE network driver support"
+       depends on TILE
+       default y
+       select CRC32
+       ---help---
+         This is a standard Linux network device driver for the
+         on-chip Tilera Gigabit Ethernet and XAUI interfaces.
+
+         To compile this driver as a module, choose M here: the module
+         will be called tile_net.
+
+endif # NET_VENDOR_TILERA

This Kconfig would automatically default to y for TILE kernels and would
allow you to easily add additional future drivers for Tilera silicon,
and if you expand to other architectures/systems in the future it would
also allow for that as well.  Your thoughts?

Otherwise I can have it just as this:
+config TILE_NET
+       tristate "Tilera GBE/XGBE network driver support"
+       depends on TILE
+       default y
+       select CRC32
+       ---help---
+         This is a standard Linux network device driver for the
+         on-chip Tilera Gigabit Ethernet and XAUI interfaces.
+
+         To compile this driver as a module, choose M here: the module
+         will be called tile_net.

Because you only have 1 driver, there is no large need to add the
NET_VENDOR_<blah> and it can always be added in the future if the need
arises.


--=-UCa1Ibp8KQEJc/4//tS5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOOOD2AAoJECTsCADr/EWUSPoH/j4APyrQeszkv9qrDJzkHYo1
H/FNVku7xQLjO2nXeqCnX7uzG05AW1jIO29IdPTF1FrdXesXiXHOGII+xZIsr5Ni
MMm2d2N7itrAliBXw8kvF/cRHnJHGUCQD7P7m7xWfKR27tMN9AH5LOvfLYT5df1g
bRzeOZbwXd21EWy3HpYaZXyv05ZoccVZnGO3tPk2nxL7BO611D3oqVCdZhU/tO8/
hxzd0Foan3DVZhL/Up/bMa4fINy8hEk6+AOsmga5d75C7DoGSspZtnw2M7YSuZ4Q
WRFCyw6a/VPiNN2seIbrPT+n5cgzv7jpA1rn0iYN7/jbMuZ60yBPl0V5qnkgYeA=
=Ht9V
-----END PGP SIGNATURE-----

--=-UCa1Ibp8KQEJc/4//tS5--

