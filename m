From: Manfred Schlaegl <manfred.schlaegl@gmx.at>
Subject: [PATCH] can: fix loss of frames due to wrong assumption in raw_rcv
Date: Sat, 20 Jun 2015 19:21:08 +0200
Message-ID: <5585A104.1090201@gmx.at>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="FFhAhitpnRbt2xJXxIUHd4xMT45hWODPt"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Manfred Schlaegl <manfred.schlaegl@ginzinger.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"David S. Miller" <davem@davemloft.net>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FFhAhitpnRbt2xJXxIUHd4xMT45hWODPt
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

I've detected a massive loss of can frames on i.MX6 using flexcan
driver with 4.1-rc8 and tracked this down to following commit:
514ac99c64b22d83b52dfee3b8becaa69a92bc4a - "can: fix multiple delivery
of a single CAN frame for overlapping CAN filters"

514ac99c64b22d83b52dfee3b8becaa69a92bc4a introduces a frame equality
check. Since the sk_buff pointer is not sufficient to do this (buffers
are reused), the check also compares time stamps.
In short: pointer+time stamp was assumed as unique key to a specific
frame.
The problem with this is, that the time stamp is an optional property
and not set per default.
In our case (flexcan) the time stamp is always zero, so the equality
check is reduced to equality of buffer pointers, resulting in a lot of
dropped frames.

Possible solutions I thought of:
 1. Every driver has to set a time stamp
    (possibly error prone and hard to enforce?)
 2. Change the equality check
 3. Fulfil the requirements of the equality check by setting a
    time stamp per default.

This patch fixes the problem with solution 3. A time stamp is set at
time of allocation in alloc_can_skb.
The time stamp may be overridden later, but the function of the equality
check is ensured.

I'm not really deep in linux network subsystem, so there may exists
more elegant solutions for the problem.

Signed-off-by: Manfred Schlaegl <manfred.schlaegl@gmx.at>
---
 drivers/net/can/dev.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index b0f6924..282e2e7 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -575,6 +575,7 @@ struct sk_buff *alloc_can_skb(struct net_device *dev,=
 struct can_frame **cf)
 	if (unlikely(!skb))
 		return NULL;
=20
+	__net_timestamp(skb);
 	skb->protocol =3D htons(ETH_P_CAN);
 	skb->pkt_type =3D PACKET_BROADCAST;
 	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
--=20
1.7.10.4



--FFhAhitpnRbt2xJXxIUHd4xMT45hWODPt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJVhaEEAAoJEGS1eKPM78WhkzEP/jiN23Q/TU1ehC7FFnruR5l4
PYlCKTbS4tIJgPxbugaquiysV2T2iYvcXfMjQbW+ryaVBnwCWvI6CMGoKemxcWdv
hTf+vNsGr4tq+GDIp6TegexKbofAoFWDc7ctXuPuzoalA7Se4DfvSUSTdUwlSOj2
9nCU+Z75KZSmZ0lRi7/v19JKJbU2DexwW72oQ4CH1Hfr7K7yhZvFDIOgyj4cYF6K
un3KzrAvQYKq8hZa9SOMcdklL27m8jQDtWrv7m7oedeXP6MyizuFBnN1P/tHe0cr
Z/xZW8atqLgFsUuTTG1AXpMH4g0xphwZFosdpNtqKbrAp+b3LrZvnVnE0F37vniN
Ly2RVzws05oMmHwoj/GHYvLNMZhwag378XX0fKLqdjpedPa/tQgZ2IoVXsHi7UQp
zDf/L9QmWVrSo2VAqv/9i2b8oVEhI/DRVBQ01XjVe4xdRgv1q2x1ip+tMf07juKO
4pqSFHOqw3vZfgd2sV0F/EsJudFyBvipgEAVWO0jlJ9//nEJ53ag8L07wGE/sB2Q
izyUk84jQzY0Z1AuEPTBXqI6ap8yAsNV5r2fgJDEF4lJIDwpTvAk5YoDkZNNTJnj
DRZX0QNYK/uSessbfqFayt8Q/0mLzl4BFHz0+BekLVJXpYD8waOdO94SBC3awFBC
Z0HQm/k14zxjIraaOodc
=WuOr
-----END PGP SIGNATURE-----

--FFhAhitpnRbt2xJXxIUHd4xMT45hWODPt--
--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
