From: Johannes Berg <johannes@sipsolutions.net>
Subject: S/G operation, skb checksums, data copying
Date: Sun, 04 May 2008 20:28:45 +0200
Message-ID: <1209925725.3655.15.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-jcANJZ6dPL89bXOgtnoP"
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:56180 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010AbYEDS24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 14:28:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jcANJZ6dPL89bXOgtnoP
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

Another thought I had while looking into this: many wireless devices are
actually able to do s/g operation but are not able to checksum IP (they
already have to checksum 802.11.)

Right now, we don't announce S/G support to the netstack, but as far as
I know it wouldn't help us anyway since we cannot checksum packets, cf.
register_netdevice:

        /* Fix illegal SG+CSUM combinations. */
        if ((dev->features & NETIF_F_SG) &&
            !(dev->features & NETIF_F_ALL_CSUM)) {
                printk(KERN_NOTICE "%s: Dropping NETIF_F_SG since no checks=
um feature.\n",
                       dev->name);
                dev->features &=3D ~NETIF_F_SG;


However, mac80211 needs to change the skb header before the skb is
handed to the hardware. Often enough, the skb it will get is cloned, so
it has to copy the header. Hence, it would benefit from having the
actual skb data not be in the header, but that is unavoidable currently
since we have no checksum features.


Should we do IP checksumming in software within mac80211, announce s/g
support and hardware checksumming to the rest of the networking layer
and hope that we only have to copy the header instead of the data for
many packets then, if the underlying hardware is capable enough?

johannes

--=-jcANJZ6dPL89bXOgtnoP
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB4AXKVg1VMiehFYAQICyxAAoSMZqlD9Cs+kBrEAxWZFqPWyJ8q9Kujs
7gwTKTcTRvaEo2fuwrczrkZGcf2/mqz57thO0YNXmyqtX5w56dqFa6JtL08w05l7
3BqtXcIp3Z3ABfea3xBsmfdLDz7qC2/LVMYgxLn2T/+hYYoYyFL4C6Weg/+3jwQz
epGy+9As+JICMvqW3jE+epjNmCw3cajfOT0PEFQpH7903+z8S139zHu/O8mqQJyg
cBNcTf3xvXcTtlwFpQ7GWwebLkFp4Fo/fnIuQzegkFcL4b0f8T/i2FBhh2lZPsAp
HmxcVe5fMAJ47cRQhvfoK+aBZkaJ9DtfGudK8xidena0Qm8XvAZCRJhf9ikodBwd
PxWyCKvjN8fEvjbz662oV5FvMQp91mShtnUceL/9PpcskHMLkAT8KCwkJ/zdAMP1
Yfbn1j4f8gPiXuHCL4rSCGsWYbJk0dmZWtBuFsD3rfE3zO51xqxOVVdoodS/ZEUY
grxzm+KodQax/UzvF0peWW1rh4IvKSIIwJBbSd4zUz90/WxUjuGgv6xrGBNbM0Xk
WMvl+luWyhwETD5MPqF+b7hGI04sfewfnAzn1Zp1CML8KqtxP3vuSSiZ1jyVbRUf
rvu868XAkkFdFlPDGJ37VAreVSYATg518eoeVZQWNViEtwhJtqT7F9Keizjc6gb9
ZVie5ZSAHEg=
=BX49
-----END PGP SIGNATURE-----

--=-jcANJZ6dPL89bXOgtnoP--

