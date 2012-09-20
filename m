From: Artem Bityutskiy <artem.bityutskiy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 15:58:56 +0300
Message-ID: <1348145936.2388.18.camel@sauron.fi.intel.com>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	 <1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	 <1347631355.5263.19.camel@sauron.fi.intel.com>
	 <1347640763.5263.24.camel@sauron.fi.intel.com>
	 <1347892887.7112.9.camel@sauron.fi.intel.com>
	 <1348142775.2388.10.camel@sauron.fi.intel.com>
	 <1348144524.4161.26.camel@jlt4.sipsolutions.net>
	 <CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
	 <CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g@mail.gmail.com>
Reply-To: artem.bityutskiy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-fd3/oc6CqIxG4ZHpH+1A"
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-fd3/oc6CqIxG4ZHpH+1A
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-09-20 at 14:45 +0200, Eric Dumazet wrote:
> I guess you only need to make sure 14 bytes of ethernet header are
> available before eth_type_trans(skb, dev);
>=20
> diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
> index 61c621e..ffe5f84 100644
> --- a/net/mac80211/rx.c
> +++ b/net/mac80211/rx.c
> @@ -1795,9 +1795,13 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx=
)
>=20
>                 if (skb) {
>                         /* deliver to local stack */
> -                       skb->protocol =3D eth_type_trans(skb, dev);
> -                       memset(skb->cb, 0, sizeof(skb->cb));
> -                       netif_receive_skb(skb);
> +                       if (pskb_may_pull(skb, sizeof(struct ethhdr))) {
> +                               skb->protocol =3D eth_type_trans(skb, dev=
);
> +                               memset(skb->cb, 0, sizeof(skb->cb));
> +                               netif_receive_skb(skb);
> +                       } else {
> +                               kfree_skb(skb);
> +                       }
>                 }
>         }

Does not help, this one does:

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 61c621e..6888586 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1797,6 +1797,7 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 			/* deliver to local stack */
 			skb->protocol =3D eth_type_trans(skb, dev);
 			memset(skb->cb, 0, sizeof(skb->cb));
+			skb_linearize(skb);
 			netif_receive_skb(skb);
 		}

--=20
Best Regards,
Artem Bityutskiy

--=-fd3/oc6CqIxG4ZHpH+1A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJQWxMQAAoJECmIfjd9wqK08RMP/jQA1hfFLfFArC9ZhfhdTEgs
tWRlwOs9xHI5FKQkE4t9U0k1n6S3Nb+8rNBdWq6N4ngwatpUb1VDUM5MjCQoqMce
DMIgthwH8vs3x+09AnsbH3XTybcniX4jxRSQ4bi6kaHahgFV7koJnraA0luM9Z8Q
Dabhwj1N427Wvd22P84zSPQ0xaDyfG4jyVwEJEYbBVd/yXTxd2twjc43OXai9BFZ
/NqB/f6qGK73izRHOo98ktTZ1+1AE1u6z5cfaRfIa1uhRxzpFGUslejDrevior8Q
4z3EFhYPZPFE299YYrq2MYgpHpYsnbEzLeM4Y39ZH7fecAsjCD0lo0KrSFxX/vHq
GtZBrbFW05eLP7nNrMXHrCWvVGh42vPR6IE57vW1X+4lYdm8oqQen6J4XybiieHf
7uV/g6Ul96H2fR50pIerOm8Ftnaal/dlT9BXMXIKTGBSOHTQ/qpIPsFuFYM8iKMS
QXv3DgPPlp/kzDoktzrPc7NhcX6W/NppA/BcoaTi6ZF4+gwZYdkWidlw6hjKTsAI
anEEL3VRj6Ev3fTsr0auqF8quQns9UKYX1YGy9Ox5fpw2MPfF8/Pse2JCAemvzzN
3tKruNlArQ2tUsaKeV6cJ4Tw9XIFRvBF6FDGCODy5h8oKQNZDOjIfL0Clz0VNSOT
Q9RB+A6+b7O1SSTjovx6
=fdTD
-----END PGP SIGNATURE-----

--=-fd3/oc6CqIxG4ZHpH+1A--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
