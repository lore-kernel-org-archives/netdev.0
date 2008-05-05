From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Tue, 06 May 2008 01:17:14 +0200
Message-ID: <1210029435.8012.25.camel@johannes.berg>
References: <1209972139.3655.9.camel@johannes.berg>
	 <1ba2fa240805050727r2060b0b4x3a9b3240647b66b1@mail.gmail.com>
	 <1210000923.8245.26.camel@johannes.berg>
	 <20080505.160328.203996832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ORroIaSxUEAlAmxHNDfY"
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080505.160328.203996832.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-ORroIaSxUEAlAmxHNDfY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> First, the skb_header_cloned() patch I posted in another reply will
> get rid of copying due to clones.  I've included it below for
> completeness.
>=20
> The next problem is to make sure there is enough space available.  And
> all that's needed is some help from the bridging layer and some hooks
> into netdev_alloc_skb().
>=20
> On bridge transmit, it knows the input and output devices, and the
> requirements of LL header space on the transmit side.
>=20
> If the transmit requirements are not met for the received packet, we
> can tag the difference into the input netdev.
>=20
> Using that information we can allocate extra space in
> netdev_alloc_skb(), and do an skb_reserve().
>=20
> The only requirement is that the ethernet driver serving input packets
> uses netdev_alloc_skb().  The most important drivers already do, and
> those which do not are trivially converted.
>=20
> The following along with Johannes's needed_header et al. patch should
> take care of the overhead.
>=20
> If this proves to be a working solution, we can do something similar
> for IPv4 and IPv6 forwarding.  At that point, we should make this
> "adjust input device extra space" a helper function that all of
> these spots can call.

This looks feasible, thanks for looking into it. But isn't, when the
bridge gives us a cloned skb, the complete header the complete data
since it won't be a fraglist skb? And then we copy it all anyway? That's
just for group addressed frames, of course, so still a lot better I
guess. The main point is getting enough headroom.

Also, should there be some sort of timer that resets the rx_alloc_extra
again so that when you bridge it once with p54 (needs heaps of headroom)
you don't suffer forever?

> @@ -255,11 +255,12 @@ struct sk_buff *__netdev_alloc_skb(struct net_devic=
e *dev,
>  		unsigned int length, gfp_t gfp_mask)
>  {
>  	int node =3D dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
> +	unsigned int extra =3D dev->rx_alloc_extra + NET_SKB_PAD;
>  	struct sk_buff *skb;
> =20
> -	skb =3D __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
> +	skb =3D __alloc_skb(length + extra, gfp_mask, 0, node);
>  	if (likely(skb)) {
> -		skb_reserve(skb, NET_SKB_PAD);
> +		skb_reserve(skb, extra);

Doesn't that break alignment though?

johannes

--=-ORroIaSxUEAlAmxHNDfY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB+VeaVg1VMiehFYAQLOuw//UZmSMdNWIKD1kj95ohl5xGG41HV+VsQk
DofU0CVFEMnIQUDikakpgBjOLsEry/nNILHd14zSn25yNaAvcmtM/O/WBnmjzrLt
57/1dGf9OEvXaWbI2jBwWSK7m5pe1sxoKEnuRe1UkPrlih3bugYbC4CgvqrilEmb
/URO4APSXhdcP0h9nfGuI4CI35o35MW1eWARjbLuRZhDBP4cio5wgVBMrYs0T1k3
Mp3eK0NMXJa7pLMteD/ucBkUYy5Qy0ICLaedT/ohShIFRdXOKetnc/f6QJN3l4VB
T2h4grpQk13DT42uZDVGOGV0e5rbtlK0T2viJScfTVYoj1mw//Ty2U+9SmBaXqmS
O+5We1bm6qUVc5EE2rWgsiSDK57YEjUkDhRlNFWwxfsAciLmKHEtggEgm6v40NTK
mlQWzxKbbNOyg4B/wQcjtx4fMLYF7M7eNEk4dA/tLI/BrQZElb1M+JEp6NViSL0I
+/jHDrL9zAC1X6jgXXGIKEY6v/NMhgI2W/A3Z45qaoJH8Babo+BLp72pYa0tgFfF
zRFVt+rn9Lx8g9JcetLkxM9UeJYBKgHXF5uit47eMCdQHyuusxbvek4I0wg2FwoI
ehBAinXkwQvls5r+GWhDFwYnai0Wl9NHpPS/y8tlGhi3R/b6/tQazgIwhX3YOXq2
OKvWGTioM3I=
=vkgG
-----END PGP SIGNATURE-----

--=-ORroIaSxUEAlAmxHNDfY--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
