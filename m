From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Mon, 28 Aug 2017 08:40:20 +0200
Message-ID: <20170828064020.GA7721@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827164434.GH13622@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170827164434.GH13622@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > No, tag_ksz part probably is not acceptable. Do you see solution
> > better than just copying it into tag_ksz1 file?
>=20
> How about something like this, which needs further work to actually
> compile, but should give you the idea.

If that's acceptable, yes, I can do something similar. I don't think
CONFIG_NET_DSA_TAG_KSZ_8K / CONFIG_NET_DSA_TAG_KSZ_9K is suitable
naming (these will probably differ according to number of ports), what
about keeping CONFIG_NET_DSA_TAG_KSZ and adding
CONFIG_NET_DSA_TAG_KSZ_1B (for one byte)?

Thanks,
								Pavel

> 	 Andrew
>=20
> index 99e38af85fc5..843e77b7c270 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -49,8 +49,11 @@ const struct dsa_device_ops *dsa_device_ops[DSA_TAG_LA=
ST] =3D {
>  #ifdef CONFIG_NET_DSA_TAG_EDSA
>         [DSA_TAG_PROTO_EDSA] =3D &edsa_netdev_ops,
>  #endif
> -#ifdef CONFIG_NET_DSA_TAG_KSZ
> -       [DSA_TAG_PROTO_KSZ] =3D &ksz_netdev_ops,
> +#ifdef CONFIG_NET_DSA_TAG_KSZ_8K
> +       [DSA_TAG_PROTO_KSZ8K] =3D &ksz8k_netdev_ops,
> +#endif
> +#ifdef CONFIG_NET_DSA_TAG_KSZ_9K
> +       [DSA_TAG_PROTO_KSZ9K] =3D &ksz9k_netdev_ops,
>  #endif
>  #ifdef CONFIG_NET_DSA_TAG_LAN9303
>         [DSA_TAG_PROTO_LAN9303] =3D &lan9303_netdev_ops,
> diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
> index de66ca8e6201..398b833889f1 100644
> --- a/net/dsa/tag_ksz.c
> +++ b/net/dsa/tag_ksz.c
> @@ -35,6 +35,9 @@
>  static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *=
dev)
>  {
>         struct dsa_slave_priv *p =3D netdev_priv(dev);
> +       struct dsa_port *dp =3D p->dp;
> +       struct dsa_switch *ds =3D dp->ds;
> +       struct dsa_switch_tree *dst =3D ds->dst;
>         struct sk_buff *nskb;
>         int padlen;
>         u8 *tag;
> @@ -69,8 +72,14 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, s=
truct net_device *dev)
>         }
> =20
>         tag =3D skb_put(nskb, KSZ_INGRESS_TAG_LEN);
> -       tag[0] =3D 0;
> -       tag[1] =3D 1 << p->dp->index; /* destination port */
> +       if (dst->tag_ops =3D=3D ksz8k_netdev_ops) {
> +               tag[0] =3D 1 << p->dp->index; /* destination port */0;
> +               tag[1] =3D 0;
> +       }
> +
> +       if (dst->tag_ops =3D=3D ksz9k_netdev_ops) {
> +               tag[0] =3D 0;
> +               tag[1] =3D 1 << p->dp->index; /* destination port */
> =20
>         return nskb;
>  }
> @@ -98,7 +107,12 @@ static struct sk_buff *ksz_rcv(struct sk_buff *skb, s=
truct net_device *dev,
>         return skb;
>  }
> =20
> -const struct dsa_device_ops ksz_netdev_ops =3D {
> +const struct dsa_device_ops ksz8k_netdev_ops =3D {
> +       .xmit   =3D ksz_xmit,
> +       .rcv    =3D ksz_rcv,
> +};
> +
> +const struct dsa_device_ops ksz9k_netdev_ops =3D {
>         .xmit   =3D ksz_xmit,
>         .rcv    =3D ksz_rcv,
>  };

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmjutQACgkQMOfwapXb+vLY8wCeNldoryu8vrTUfrMF19+3fwVk
TpQAn0yME+EnhUxJ/gwt01ZpcQD47UxV
=l8tX
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
