From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ip : take care of last fragment in ip_append_data
Date: Tue, 21 Sep 2010 08:16:27 +0200
Message-ID: <1285049787.2323.797.camel@edumazet-laptop>
References: <20100920174443.GA5515@elliptictech.com>
	 <1285006844.2323.17.camel@edumazet-laptop>
	 <20100920195256.GA14330@elliptictech.com>
	 <1285013853.2323.148.camel@edumazet-laptop>
	 <1285018272.2323.243.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37395 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab0IUGQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 02:16:33 -0400
In-Reply-To: <1285018272.2323.243.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 septembre 2010 =C3=A0 23:31 +0200, Eric Dumazet a =C3=A9cri=
t :

> OK, I found a bug in ip_fragment() and ip6_fragment()
>=20
> In case slow_path is hit, we have a truesize mismatch
>=20
> Could you try following patch ?
>=20
> Thanks !
>=20
> [PATCH] ip : fix truesize mismatch in ip fragmentation
>=20
> We should not set frag->destructor to sock_wkfree() until we are sure=
 we
> dont hit slow path in ip_fragment(). Or we risk uncharging
> frag->truesize twice, and in the end, having negative socket
> sk_wmem_alloc counter, or even freeing socket sooner than expected.
>=20
> Many thanks to Nick Bowler, who provided a very clean bug report and
> test programs.
>=20
> While Nick bisection pointed to commit 2b85a34e911bf483 (net: No more
> expensive sock_hold()/sock_put() on each tx), underlying bug is older=
=2E
>=20
> Reported-and-bisected-by: Nick Bowler <nbowler@elliptictech.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/ip_output.c  |    8 ++++----
>  net/ipv6/ip6_output.c |   10 +++++-----
>  2 files changed, 9 insertions(+), 9 deletions(-)

This previous patch works for me. I also cooked following fix, to not
enter slow path on some lengthes (MTU + N*(MTU-20))

[PATCH] ip : take care of last fragment in ip_append_data

While investigating a bit, I found ip_fragment() slow path was taken
because ip_append_data() provides following layout for a send(MTU +
N*(MTU - 20)) syscall :

- one skb with 1500 (mtu) bytes
- N fragments of 1480 (mtu-20) bytes (before adding IP header)
last fragment gets 17 bytes of trail data because of following bit:

	if (datalen =3D=3D length + fraggap)
		alloclen +=3D rt->dst.trailer_len;

Then esp4 adds 16 bytes of data (while trailer_len is 17... hmm...
another bug ?)

In ip_fragment(), we notice last fragment is too big (1496 + 20) > mtu,
so we take slow path, building another skb chain.

In order to avoid taking slow path, we should correct ip_append_data()
to make sure last fragment has real trail space, under mtu...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_output.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 04b6989..dfd9a0d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -927,16 +927,19 @@ alloc_new_skb:
 			    !(rt->dst.dev->features&NETIF_F_SG))
 				alloclen =3D mtu;
 			else
-				alloclen =3D datalen + fragheaderlen;
+				alloclen =3D fraglen;
=20
 			/* The last fragment gets additional space at tail.
 			 * Note, with MSG_MORE we overallocate on fragments,
 			 * because we have no idea what fragment will be
 			 * the last.
 			 */
-			if (datalen =3D=3D length + fraggap)
+			if (datalen =3D=3D length + fraggap) {
 				alloclen +=3D rt->dst.trailer_len;
-
+				/* make sure mtu is not reached */
+				if (datalen > mtu - fragheaderlen - rt->dst.trailer_len)
+					datalen -=3D ALIGN(rt->dst.trailer_len, 8);
+			}
 			if (transhdrlen) {
 				skb =3D sock_alloc_send_skb(sk,
 						alloclen + hh_len + 15,


