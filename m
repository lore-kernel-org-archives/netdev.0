From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter (was: Re:
	do_IRQ: stack overflow: 872..)
Date: Sun, 23 Jan 2005 00:22:33 +0100
Message-ID: <1106436153.20995.42.camel@tux.rsn.bth.se>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	 <p73zn0ccaee.fsf@verdi.suse.de>
	 <1105117559.11753.34.camel@baythorne.infradead.org>
	 <20050107100017.454ddadc@dxpl.pdx.osdl.net>
	 <1105133241.3375.16.camel@localhost.localdomain>
	 <20050118135735.4b77d38d.davem@davemloft.net>
	 <1106433059.4486.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-JRxNfi+FN1JWlIJKUTiK"
Cc: "David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
        dwmw2@infradead.org, ak@suse.de, snort2004@mail.ru, bridge@osdl.org,
        netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <1106433059.4486.11.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-JRxNfi+FN1JWlIJKUTiK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2005-01-22 at 23:30 +0100, Bart De Schuymer wrote:

Hi Bart

> @@ -138,23 +139,34 @@ void nf_log_packet(int pf,
>  /* This is gross, but inline doesn't cut it for avoiding the function
>     call in fast path: gcc doesn't inline (needs value tracking?). --RR *=
/
>  #ifdef CONFIG_NETFILTER_DEBUG
> -#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
> - nf_hook_slow((pf), (hook), (skb), (indev), (outdev), (okfn), INT_MIN)
> -#define NF_HOOK_THRESH nf_hook_slow
> +#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			    \
> +({int __ret =3D 0;							    \
> +if (!nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN, &__ret=
);  \
> +	__ret =3D (okfn)(skb);						    \
> +__ret;})
> +#define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	    \
> +({int __ret =3D 0;							    \
> +if (!nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, thresh, &__ret)=
;   \
> +	__ret =3D (okfn)(skb);						    \
> +__ret;})
>  #else

I guess you never testcompiled with CONFIG_NETFILTER_DEBUG set :)
The if-statements above needs to have ; replaced with )

> +			if (verdict > NF_MAX_VERDICT) {
> +				NFDEBUG("Evil return from %p(%u).\n",
> +				        elem->hook, hook);
> +				continue;
> +			}

Maybe add unlikely() around the test?

Otherwise the changes look sane.

The reoganisation of things in nf_hook_slow() shouldn't cause any
performance changes, I tried to benchmark various variations of that
code some time ago but the result of the changes were more or less in
the noise.

--=20
/Martin

--=-JRxNfi+FN1JWlIJKUTiK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBB8uA5Wm2vlfa207ERAtENAKC7lltDMufYxml4xtGpqJbU8f9xbwCeI5IR
NYu/J4GXYnePqaOWQvzds3s=
=pdyD
-----END PGP SIGNATURE-----

--=-JRxNfi+FN1JWlIJKUTiK--
