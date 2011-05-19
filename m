From: Sven Eckelmann <sven@narfation.org>
Subject: Re: net: add seq_before/seq_after functions
Date: Thu, 19 May 2011 10:54:32 +0200
Message-ID: <201105191054.34912.sven@narfation.org>
References: <1305722319-8315-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1581044.BhJUx0NJpY";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Paul Mackerras <paulus@samba.org>,
	linux-ppp@vger.kernel.org
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305722319-8315-1-git-send-email-ordex@autistici.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1581044.BhJUx0NJpY
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Wednesday 18 May 2011 14:38:39 Antonio Quartulli wrote:
> Introduce two operations to handle comparison between packet sequence
> numbers taking into account overflow/wraparound. Batman-adv uses
> these functions already to check for successor packet even in case of
> overflow.

Thanks for your efforts to bring that to the kernel. But when you prepare a=
=20
patch then you have to add a signoff. And also David S. Miller is the=20
maintainer for this header - it would be interesting to ask him first when =
we=20
want to change that file.

> ---
> I added this two functions in net.h because I didn't really know where
> best placement is. I saw several modules that redefine their own functions
> for the same purpose.
>=20
>  include/linux/net.h |   17 +++++++++++++++++
>  1 files changed, 17 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/net.h b/include/linux/net.h
> index 94de83c..c7bc9bf 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -295,4 +295,21 @@ extern struct ratelimit_state net_ratelimit_state;
>  #endif
>=20
>  #endif /* __KERNEL__ */
> +
> +/* Returns the smallest signed integer in two's complement with the size=
of
> x */ +#define smallest_signed_int(x) (1u << (7u + 8u * (sizeof(x) - 1u)))
> +
> +/* Checks if a sequence number x is a predecessor/successor of y.
> + * they handle overflows/underflows and can correctly check for a
> + * predecessor/successor unless the variable sequence number has grown by
> + * more then 2**(bitwidth(x)-1)-1.
> + * This means that for a uint8_t with the maximum value 255, it would
> think: + *  - when adding nothing - it is neither a predecessor nor a
> successor + *  - before adding more than 127 to the starting value - it is
> a predecessor, + *  - when adding 128 - it is neither a predecessor nor a
> successor, + *  - after adding more than 127 to the starting value - it is
> a successor */ +#define seq_before(x, y) ({typeof(x) _dummy =3D (x - y); \
> +			_dummy > smallest_signed_int(_dummy); })
> +#define seq_after(x, y) seq_before(y, x)
> +
>  #endif	/* _LINUX_NET_H */

I suggested yesterday (probably too late) that it would be good to check the
type of both parameters (similar to the min and max functions in
include/linux/kernel.h

#define seq_before(x, y) ({typeof(x) _d1 =3D (x); \
			  typeof(y) _d2 =3D (y); \
			  (void) (&_d1 =3D=3D &_d2); \
			  typeof(x) _dummy =3D (_d1 - _d2); \
			  _dummy > smallest_signed_int(_dummy); })


And your seq_before/after conflicts with the one defined in ppp_generic.c

drivers/net/ppp_generic.c:232:0: warning: "seq_before" redefined [enabled b=
y=20
default]
include/linux/net.h:312:0: note: this is the location of the previous=20
definition
drivers/net/ppp_generic.c:233:0: warning: "seq_after" redefined [enabled by=
=20
default]
include/linux/net.h:314:0: note: this is the location of the previous=20
definition

The definition there is only for u32 - thus you would have to remove it and=
=20
check that it always gives the same result:
#define seq_before(a, b)        ((s32)((a) - (b)) < 0)
#define seq_after(a, b)         ((s32)((a) - (b)) > 0)

But I would say that they have a different definition of seq_before. Changi=
ng=20
that behaviour for batman-adv would not be that problematic, but maybe for=
=20
ppp.

A defintion which should fulfil the requirements for ppp could be:

#define seq_after(x, y) ({typeof(x) _d1 =3D (x); \
			  typeof(y) _d2 =3D (y); \
			  (void) (&_d1 =3D=3D &_d2); \
			  typeof(x) _dummy =3D (_d2 - _d1); \
			  _dummy > smallest_signed_int(_dummy); })
#define seq_before(x, y) ({typeof(x) _d1 =3D (x); \
			  typeof(y) _d2 =3D (y); \
			  (void) (&_d1 =3D=3D &_d2); \
			  typeof(x) _dummy =3D (_d1 - _d2); \
			  _dummy >=3D smallest_signed_int(_dummy); })

Of course the comment above the seq_before/seq_after would be wrong.

/* Checks if a sequence number x is a predecessor/successor of y.
 * they handle overflows/underflows and can correctly check for a
 * predecessor/successor unless the variable sequence number has grown by
 * more then 2**(bitwidth(x)-1).
 * This means that for a uint8_t with the maximum value 255, it would think:
 *  - when adding nothing - it is neither a predecessor nor a successor
 *  - before adding more than 128 to the starting value - it is a predecess=
or,
 *  - after adding more than 127 to the starting value - it is a successor =
*/

I think there could be more candidates which would like to use this abstrac=
t=20
functionality. Maybe some one else on linux-kernel or netdev has a suggesti=
on.

Kind regards,
	Sven

--nextPart1581044.BhJUx0NJpY
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJN1NrIAAoJEF2HCgfBJntGjl8P/1RLU/dFt/G933cjo8rlDwuy
7q0cUAjVneysotz4moe5R514WC1HbDu6iDegncPS+ZpZO5uOw1s0qQehsjxl+XgV
15w9ELNbryuIAyEMa44EXhLnCY3Ae5upcf5uefMSPxk7pALxVGO1uqOkWPLSJWiD
br6MaJbJ5moxOVlNDLm9Q5FIJyxRXRcQJOpWVf7/hVsPEMXR9zdpl1WOGellPYGG
iez1HcqMzLIkSg0HcGDn/dBLbykpDzh5QZi+YquD1YPfrzXt74UAwrHfBzOaS8Vu
RmCLQzmAjgoeBbQzPptc7eESwLlF7kMWlg2xOz3Z/kkf1AvA0irzVMTHbXU2xkW+
oO8Vf6TKH/aiznEtwB2ll6HlGU9WXUqUWEVPIt6rLZUaURXyBCbum5AkFA3rMu6d
tWeSnaOBrEj1nJegYiajaTv5kEsA1bZswc3N+5r84xkJN+8L6X4vkEVyWUH8U9T8
RtcIaAAN8MlAvGtzj+IA6W1Gx94p39TeVJI4C3V3zca6vjypdM9JicVCbhjHw+BP
zfEfYT8F3KsgvN3JhM4AWwdWLRnzIXK5tWDGlOvYDa5UWGLGj6B+z8y4n95MvEVO
MVWINWrhv+kfBVZzps2StxCPG6DRkQl7qD8Ar9gP0LTOLxYpMcldZ1prVuz7Uj+t
0e8amN2PN0oWCM0rpQEC
=ztLq
-----END PGP SIGNATURE-----

--nextPart1581044.BhJUx0NJpY--
