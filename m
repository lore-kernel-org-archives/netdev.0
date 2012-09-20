From: Artem Bityutskiy <artem.bityutskiy@linux.intel.com>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 16:22:33 +0300
Message-ID: <1348147353.2388.19.camel@sauron.fi.intel.com>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	 <1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	 <1347631355.5263.19.camel@sauron.fi.intel.com>
	 <1347640763.5263.24.camel@sauron.fi.intel.com>
	 <1347892887.7112.9.camel@sauron.fi.intel.com>
	 <1348142775.2388.10.camel@sauron.fi.intel.com>
	 <1348144524.4161.26.camel@jlt4.sipsolutions.net>
	 <CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
	 <CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g@mail.gmail.com>
	 <1348145936.2388.18.camel@sauron.fi.intel.com>
	 <CANn89i+9Th=xVgDgoy7tHwKtLNpOC8rgJkA09nQ1Yf0zvqBw6w@mail.gmail.com>
Reply-To: artem.bityutskiy@linux.intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-wsrozeB/0LwBqIWx8Fxw"
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:47172 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807Ab2ITNRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 09:17:35 -0400
In-Reply-To: <CANn89i+9Th=xVgDgoy7tHwKtLNpOC8rgJkA09nQ1Yf0zvqBw6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wsrozeB/0LwBqIWx8Fxw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-09-20 at 15:04 +0200, Eric Dumazet wrote:
> Try to pull 40 bytes : Thats OK for tcp performance, because 40 bytes
> is the minimum size of IP+TCP headers
>=20
> pskb_may_pull(skb, 40);

OK, I've tried almost this (see below) and it solves my issue:

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 965e6ec..7f079d0 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1798,9 +1798,13 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
=20
                if (skb) {
                        /* deliver to local stack */
-                       skb->protocol =3D eth_type_trans(skb, dev);
-                       memset(skb->cb, 0, sizeof(skb->cb));
-                       netif_receive_skb(skb);
+                       if (pskb_may_pull(skb, 40)) {
+                               skb->protocol =3D eth_type_trans(skb, dev);
+                               memset(skb->cb, 0, sizeof(skb->cb));
+                               netif_receive_skb(skb);
+                       } else {
+                               kfree_skb(skb);
+                       }
                }
        }

--=20
Best Regards,
Artem Bityutskiy

--=-wsrozeB/0LwBqIWx8Fxw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJQWxiZAAoJECmIfjd9wqK0h7oP/jbXTk9uptSD1Kn6/ELPAD38
69bjWRHohBbpE0OxLVQB1emcProKgxt4pvYknJgKIEIkBFwsyl3DS62QMdbnhK/Q
RE8LvrUhTFpxG3SJxDF1bRzq2BLQr/ffRGkAHovy1n9vBSb7pMRDqi+hoNXHmjtL
mY7dOdIW8yMxzPnJAMayv27f7F6VD8eM2VrcjKr9mCXDy3QFo/sSxU0aq8AEVjkm
9N+4Obl391nBHsDeigxEsupWdWPqOe72QP2fqqXImMiAGOzu6Az1qJUyG1wPA7cD
1VIYNKmTVNwS1t3bjaBtd4rIyUrEwnAuDe9cjKF9EheSa+46WBlr1HU1VVl7LWjH
uVXc5VlSDsSkvxwpXfiqTbZfrav7xlf/QCGWlYiKaJJgy+/Q7RzwpVy9l3r9GSyN
sZGPaqs+KBJLNrc6dUviZadYK+tfRxYhs7OA+pDqlqZg0toYi0f3phZ6tTFez96/
M0LM61TiFzVuxgVYWOtXtYUpT4biXP2+g9RqwE8vNB+ibR5aGYGdFPvNuH8SNeeO
Ec49ISlZ/asnD8/YpkCkp9KrjAKJ2sN0AMKxR3lGQYTVern0Zf6l5W8LJGSnGrzh
zwETjbLI5CjHeR0GrvkCpeJDxMK8MPGNcejbNaKRfDMwKj0K/YyiXKakv1kw18TS
ssYKfRO+4+qxKvyZ++Uh
=Czxo
-----END PGP SIGNATURE-----

--=-wsrozeB/0LwBqIWx8Fxw--
