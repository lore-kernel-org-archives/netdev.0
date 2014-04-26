From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 5/9 v2] net: Generalize checksum_init functions
Date: Sat, 26 Apr 2014 22:42:04 +0100
Message-ID: <1398548524.16049.6.camel@deadeye.wl.decadent.org.uk>
References: <alpine.DEB.2.02.1404261400430.26913@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4O6vMliHZVubkDlpVmqt"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39346 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751243AbaDZVmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 17:42:19 -0400
In-Reply-To: <alpine.DEB.2.02.1404261400430.26913@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4O6vMliHZVubkDlpVmqt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-04-26 at 14:25 -0700, Tom Herbert wrote:
> Create a general __skb_checksum_validate function (actually a
> macro) to subsume the various checksum_init functions. This
> function can either init the checksum, or do the full validation
> (logically checksum_init+skb_check_complete)-- a flag specifies
> if full vaidation is performed. Also, there is a flag to the function
> to indicate that zero checksums are allowed (to support optional
> UDP checksums).
>=20
> Added several stub functions for calling __skb_checksum_validate.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/skbuff.h | 87 ++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  1 file changed, 87 insertions(+)
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 08074a8..3b14acc 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2741,6 +2741,93 @@ static inline __sum16 skb_checksum_complete(struct=
 sk_buff *skb)
>                0 : __skb_checksum_complete(skb);
>  }
> =20
> +/*
> + * Try to validate checksum based on unnecessary or zero checksum
> + * received.
> + *
> + * Return values:
> + * 0: checksum unnecessary validated, no further checks needed
> + * 1: checksum complete needed
> + */
> +static inline __sum16 __skb_checksum_validate_unnecessary(struct sk_buff=
 *skb,
> +                                                         bool zero_okay,
> +                                                         __sum16 check)
> +{
> +       if (skb_csum_unnecessary(skb)) {
> +               return 0;
> +       } else if (zero_okay && !check) {
> +               skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> +               return 0;
> +       }
> +
> +       return 1;
> +}

Why is this returning __sum16 and not bool?

> +/*
> + * Validate (init) checksum based on checksum complete.
> + *
> + * Return values:
> + * 0: checksum is validated or try to in skb_checksum_complete
> + * non-zero: value of invalid computed checksum
> + */
> +static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *s=
kb,
> +                                                      bool complete,
> +                                                      __wsum psum)
> +{
> +       if (skb->ip_summed =3D=3D CHECKSUM_COMPLETE) {
> +               if (!csum_fold(csum_add(psum, skb->csum))) {
> +                       skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> +                       return 0;
> +               }
> +       }
> +
> +       skb->csum =3D psum;
> +
> +       if (complete || skb->len <=3D 76)
> +               return __skb_checksum_complete(skb);
> +
> +       return 0;
> +}
> +
> +static inline __wsum null_compute_pseudo(struct sk_buff *skb, int proto)
> +{
> +       return 0;
> +}
> +
> +/*
> + * Perform checksum validate (init). Note that this is a macro since we =
only
> + * want to calculate the pseudo header which is an input function if nec=
essary.
> + * First we try to validate without any computation (checksum unnecessar=
y) and
> + * then calculate based on checksum complete calling the function to com=
pute
> + * pseudo header.
> + */
> +#define __skb_checksum_validate(skb, proto, complete,                  \
> +                               zero_okay, check, compute_pseudo)       \
> +({                                                                     \
> +       __sum16 __ret =3D __skb_checksum_validate_unnecessary(skb,       =
 \
> +                               zero_okay, check);                      \
> +       if (__ret)                                                      \
> +               __ret =3D __skb_checksum_validate_complete(skb,          =
 \
> +                               complete, compute_pseudo(skb, proto));  \
> +       __ret;                                                          \
> +})

This may or may not yield an actual checksum, which is not obvious from
the comment.

> +#define skb_checksum_init(skb, proto, compute_pseudo)                  \
> +       __skb_checksum_validate(skb, proto, false, false, 0, compute_pseu=
do)
> +
> +#define skb_checksum_init_zero_check(skb, proto, check, compute_pseudo) =
       \
> +       __skb_checksum_validate(skb, proto, false, true, check, compute_p=
seudo)
> +
> +#define skb_checksum_validate(skb, proto, compute_pseudo)              \
> +       __skb_checksum_validate(skb, proto, true, false, 0, compute_pseud=
o)
> +
> +#define skb_checksum_validate_zero_check(skb, proto, check,            \
> +                                        compute_pseudo)                \
> +       __skb_checksum_validate_(skb, proto, true, true, check, compute_p=
seudo)
> +
> +#define skb_checksum_simple_validate(skb)                              \
> +       __skb_checksum_validate(skb, 0, true, false, 0, null_compute_pseu=
do)

Don't these deserve comments too?

Ben.

>  #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
>  void nf_conntrack_destroy(struct nf_conntrack *nfct);
>  static inline void nf_conntrack_put(struct nf_conntrack *nfct)

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g

--=-4O6vMliHZVubkDlpVmqt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1woLOe/yOyVhhEJAQrH0xAAl8QzL/udMuhAluGmS+LB7T4d6YoE8ZOL
JFxmyloYslaQEV5Rp36bef/U4+wQtrZ7YlgBKb8rdG3MXV7dz0C8hk2mrff+wRw3
jvzHtKGTSZPZzYriVQrPO8yrquJvxa4vXwXItwnECWTNZ8/++NRwjHBrWMJJPtVt
WyTuxsadoQQWGC9Re8QJhuIuUAsOVjbCZJUVXIF8TDvXmBgaOW1POkTDPYIZPeDA
CRA2FIwD3hBb29yerAe6k+46MJONv0uqd3iVl4I61TQWSlq6ZobSCSs1goPOc2Yo
yyhhTUobgwBtHP9it+ajqi17/X8ri3mB4K7yjXf9R9DdDKg9AO8tX84kqp644sVb
nwf8eI4x+7kPUWOn5yJe5n3e5I1ehqmMcaOrCBChZyVGMdct1raTc31OfI8XypgF
199h788Mw1jVQOcv1wV+teO8jypdKzCrdn8Md+9qDo43JXDLhXnWNOsWQDZeSS53
IOolQygLlKHPVFB6Y030wA0+uT5DjLhhYA/tuH6CpZ+ZZ8JB4JXZ+BEsufMexLEx
foILiaGh27K0cEgZy/BmaYEN9Cmac0YY9w1bTg70kqp2ur3n0/ZW1rq/A8hxRx9W
L97T1lgNeAZM68OeAR0ouPlyfrWGT3+0TI5AfSmlOh+7FCP5SGCxpHUy4dlXKrZY
f08ag+oLIXE=
=jW4/
-----END PGP SIGNATURE-----

--=-4O6vMliHZVubkDlpVmqt--
