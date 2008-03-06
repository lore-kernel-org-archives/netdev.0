From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [Pasemi-linux] [patch 1/6] pasemi_mac: Move RX/TX section
	enablement to dma_lib
Date: Thu, 06 Mar 2008 11:47:50 +1100
Message-ID: <1204764470.7499.6.camel@concordia.ozlabs.ibm.com>
References: <20080221025753.903665000@lixom.net>
	 <20080221025929.082348000@lixom.net> <1204026366.7203.9.camel@concordia>
	 <20080226141420.GA22572@lixom.net>  <20080305182100.GA8411@lixom.net>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XKOYpaU47Xl0Jr9e665+"
Cc: netdev@vger.kernel.org, pasemi-linux@ozlabs.org, jgarzik@pobox.com,
	linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45015 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755581AbYCFArw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 19:47:52 -0500
In-Reply-To: <20080305182100.GA8411@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XKOYpaU47Xl0Jr9e665+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-03-05 at 12:21 -0600, Olof Johansson wrote:
> On Tue, Feb 26, 2008 at 08:14:20AM -0600, Olof Johansson wrote:
> > Hi,
> >=20
> > On Tue, Feb 26, 2008 at 10:46:06PM +1100, Michael Ellerman wrote:
> > > On Wed, 2008-02-20 at 20:57 -0600, Olof Johansson wrote:
> > > > +	i =3D 1000;
> > > > +	pasemi_write_dma_reg(PAS_DMA_COM_RXCMD, 0);
> > > > +	while ((i > 0) && (pasemi_read_dma_reg(PAS_DMA_COM_RXSTA) & 1))
> > > > +		i--;
> > > > +	if (i < 0)
> > > > +		printk(KERN_INFO "Warning: Could not disable RX section\n");
> > > > +
> > > > +	i =3D 1000;
> > > > +	pasemi_write_dma_reg(PAS_DMA_COM_TXCMD, 0);
> > > > +	while ((i > 0) && (pasemi_read_dma_reg(PAS_DMA_COM_TXSTA) & 1))
> > > > +		i--;
> > >=20
> > > This kind of caught my eye, is it still going to work when the next c=
ore
> > > is twice as fast?
>=20
> FYI; I've commited in this change, rest of the patch is identical.
>=20
> diff --git a/arch/powerpc/platforms/pasemi/dma_lib.c b/arch/powerpc/platf=
orms/pasemi/dma_lib.c
> index c529d8d..48cb7c9 100644
> --- a/arch/powerpc/platforms/pasemi/dma_lib.c
> +++ b/arch/powerpc/platforms/pasemi/dma_lib.c
> @@ -17,6 +17,7 @@
>   * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 =
USA
>   */
> =20
> +#include <linux/kernel.h>
>  #include <linux/init.h>
>  #include <linux/module.h>
>  #include <linux/pci.h>
> @@ -410,6 +411,7 @@ int pasemi_dma_init(void)
>  	struct resource res;
>  	struct device_node *dn;
>  	int i, intf, err =3D 0;
> +	unsigned long timeout;
>  	u32 tmp;
> =20
>  	if (!machine_is(pasemi))
> @@ -478,6 +480,34 @@ int pasemi_dma_init(void)
>  	for (i =3D 0; i < MAX_RXCH; i++)
>  		__set_bit(i, rxch_free);
> =20
> +	timeout =3D jiffies + HZ;
> +	pasemi_write_dma_reg(PAS_DMA_COM_RXCMD, 0);
> +	while (pasemi_read_dma_reg(PAS_DMA_COM_RXSTA) & 1) {
> +		if (time_after(jiffies, timeout)) {
> +			pr_warning("Warning: Could not disable RX section\n");
> +			break;
> +		}
> +	}
> +
> +	timeout =3D jiffies + HZ;
> +	pasemi_write_dma_reg(PAS_DMA_COM_TXCMD, 0);
> +	while (pasemi_read_dma_reg(PAS_DMA_COM_TXSTA) & 1) {
> +		if (time_after(jiffies, timeout)) {
> +			pr_warning("Warning: Could not disable TX section\n");
> +			break;
> +		}
> +	}

I like that a lot better :)

Ooo, someone beat me to adding pr_warning() - nice.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-XKOYpaU47Xl0Jr9e665+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHzz82dSjSd0sB4dIRAki9AJ4ymL4QuoUreSOMce+5+pchOojr+QCghVXb
wmKGuXHrzntWRaGx/CjA67U=
=eDVL
-----END PGP SIGNATURE-----

--=-XKOYpaU47Xl0Jr9e665+--

