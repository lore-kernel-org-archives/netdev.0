From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 4/4] [powerpc] Implement a p1010rdb clock source.
Date: Sat, 06 Aug 2011 15:58:13 +0200
Message-ID: <4E3D4875.30707@pengutronix.de>
References: <1312603504-30282-1-git-send-email-holt@sgi.com>
	<1312603504-30282-5-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5842309978338157097=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312603504-30282-5-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============5842309978338157097==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFF24CF20A245A018F3E78F33"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFF24CF20A245A018F3E78F33
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/06/2011 06:05 AM, Robin Holt wrote:
> flexcan driver needs the clk_get, clk_get_rate, etc functions
> to work.  This patch provides the minimum functionality.

This patch has to go via the powerpc git tree. Added
linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org on CC.

> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  arch/powerpc/platforms/85xx/p1010rdb.c |   78 ++++++++++++++++++++++++=
++++++++
>  1 files changed, 78 insertions(+), 0 deletions(-)
>=20
> diff --git a/arch/powerpc/platforms/85xx/p1010rdb.c b/arch/powerpc/plat=
forms/85xx/p1010rdb.c
> index 3540a88..8f78ddd 100644
> --- a/arch/powerpc/platforms/85xx/p1010rdb.c
> +++ b/arch/powerpc/platforms/85xx/p1010rdb.c
> @@ -28,6 +28,7 @@
>  #include <asm/udbg.h>
>  #include <asm/mpic.h>
>  #include <asm/swiotlb.h>
> +#include <asm/clk_interface.h>
> =20
>  #include <sysdev/fsl_soc.h>
>  #include <sysdev/fsl_pci.h>
> @@ -164,6 +165,82 @@ static void __init p1010_rdb_setup_arch(void)
>  	printk(KERN_INFO "P1010 RDB board from Freescale Semiconductor\n");
>  }
> =20
> +/*
> + * p1010rdb needs to provide a clock source for the flexcan driver.
> + */
> +struct clk {
> +	unsigned long rate;
> +} p1010rdb_system_clk;
> +
> +static struct clk *p1010_rdb_clk_get(struct device *dev, const char *i=
d)
> +{
> +	struct clk *clk;
> +	u32 *of_property;
> +	unsigned long clock_freq, clock_divider;
> +	const char *dev_init_name;
> +
> +	if (!dev)
> +		return ERR_PTR(-ENOENT);
> +
> +	/*
> +	 * The can devices are named ffe1c000.can0 and ffe1d000.can1 on
> +	 * the p1010rdb.  Check for the "can" portion of that name before
> +	 * returning a clock source.
> +	 */
> +	dev_init_name =3D dev_name(dev);
> +	if (strlen(dev_init_name) !=3D 13)
> +		return ERR_PTR(-ENOENT);
> +	dev_init_name +=3D 9;
> +	if (strncmp(dev_init_name, "can", 3))
> +		return ERR_PTR(-ENOENT);
> +
> +	of_property =3D (u32 *)of_get_property(dev->of_node, "clock_freq", NU=
LL);
> +	if (!of_property)
> +		return ERR_PTR(-ENOENT);
> +	clock_freq =3D *of_property;
> +
> +	of_property =3D (u32 *)of_get_property(dev->of_node,
> +					     "fsl,flexcan-clock-divider", NULL);
> +	if (!of_property)
> +		return ERR_PTR(-ENOENT);
> +	clock_divider =3D *of_property;
> +
> +	clk =3D kmalloc(sizeof(struct clk), GFP_KERNEL);
> +	if (!clk)
> +		return ERR_PTR(-ENOMEM);
> +
> +	clk->rate =3D DIV_ROUND_CLOSEST(clock_freq / clock_divider, 1000);
> +	clk->rate *=3D 1000;
> +
> +	return clk;
> +}
> +
> +static void p1010_rdb_clk_put(struct clk *clk)
> +{
> +	kfree(clk);
> +}
> +
> +static unsigned long p1010_rdb_clk_get_rate(struct clk *clk)
> +{
> +	return clk->rate;
> +}
> +
> +static struct clk_interface p1010_rdb_clk_functions =3D {
> +	.clk_get		=3D p1010_rdb_clk_get,
> +	.clk_get_rate		=3D p1010_rdb_clk_get_rate,
> +	.clk_put		=3D p1010_rdb_clk_put,
> +};
> +
> +static void __init p1010_rdb_clk_init(void)
> +{
> +	clk_functions =3D p1010_rdb_clk_functions;
> +}
> +
> +static void __init p1010_rdb_init(void)
> +{
> +	p1010_rdb_clk_init();
> +}
> +
>  static struct of_device_id __initdata p1010rdb_ids[] =3D {
>  	{ .type =3D "soc", },
>  	{ .compatible =3D "soc", },
> @@ -195,6 +272,7 @@ define_machine(p1010_rdb) {
>  	.name			=3D "P1010 RDB",
>  	.probe			=3D p1010_rdb_probe,
>  	.setup_arch		=3D p1010_rdb_setup_arch,
> +	.init			=3D p1010_rdb_init,
>  	.init_IRQ		=3D p1010_rdb_pic_init,
>  #ifdef CONFIG_PCI
>  	.pcibios_fixup_bus	=3D fsl_pcibios_fixup_bus,

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigFF24CF20A245A018F3E78F33
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk49SIUACgkQjTAFq1RaXHNIUwCgiwivDPV9DRB/awHOjuH6/6tS
nc4An200w4N/fDyaCkkA6AuTeYNfcsSJ
=u1B2
-----END PGP SIGNATURE-----

--------------enigFF24CF20A245A018F3E78F33--

--===============5842309978338157097==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============5842309978338157097==--
