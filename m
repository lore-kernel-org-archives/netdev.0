From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] ip: find correct route for socket which is not bound (v2)
Date: Fri, 25 Sep 2015 09:52:40 +0800
Message-ID: <1443145960-20514-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wen.gang.wang@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45924 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbbIYBvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 21:51:21 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t8P1pK6D021177
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 01:51:20 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t8P1pKkR017772
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 01:51:20 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0121.oracle.com (8.13.8/8.13.8) with ESMTP id t8P1pJ6B026060
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 01:51:20 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the v2, comparing the v1, the changes is:
 * for loopback outbound device, it continue skipping cached route;
   for others, it goes through the cached route.

=46or multicast, we should find valid route(thus get the meaniful pmtu)=
 for
the packet on the socket which is not bound to a device(sk_bound_dev_if
being 0) too.

=46rom man page of socket(7)

       SO_BINDTODEVICE
		Bind this socket to a particular device like =E2=80=9Ceth0=E2=80=9D, =
as
		specified in the passed interface name.  If the name is an
		empty string or the option length is zero, the socket
		device binding is removed. The  passed  option is  a
		variable-length null-terminated interface name string with
		the maximum size of IFNAMSIZ.  If a socket is bound to an
		interface, only packets received from that particular
		interface are processed by the socket. Note that this works
		only for some socket types, particularly AF_INET sockets.
		It is not supported for packet sockets (use normal bind(2)
		there).

The man page doesn't say when socket not bound packets won't be routed.

A problem is hit that all multicast packets dropped by kernel(from send=
er
host). The lower layer is IPoIB with MTU being 7000. And I was sending =
4096
length multicast  packets. Inside IPoIB the first send is dropped becau=
se
is exeeding the internal packet size limitation mcast_mtu which is 2044=
=2E
So IPoIB calls ip_rt_update_pmtu (indirectly) trying to set path mtu. A
correct route is configured for the multicast, so the setting of pmtu
cucceeded and the next multicast packet(to the same target) is expected
to succeed(it would be well fragmented accroding to the pmtu I just set=
).
But actually the second and later multicast packets got dropped too. An=
d
the reason is that the neighor looking up(fib_lookup) is skipped becaus=
e of
the socket is not bound to device(sk_bound_dev_if being 0). After appli=
ed
the patch I proposed here, it works fine.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
---
 net/ipv4/route.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5f4a556..c0534c2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2097,7 +2097,10 @@ struct rtable *__ip_route_output_key(struct net =
*net, struct flowi4 *fl4)
 			 */
=20
 			fl4->flowi4_oif =3D dev_out->ifindex;
-			goto make_route;
+			if (dev_out->flags & IFF_LOOPBACK)
+				goto make_route;
+			else
+				goto lookup;
 		}
=20
 		if (!(fl4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
@@ -2153,6 +2156,7 @@ struct rtable *__ip_route_output_key(struct net *=
net, struct flowi4 *fl4)
 		goto make_route;
 	}
=20
+lookup:
 	if (fib_lookup(net, fl4, &res, 0)) {
 		res.fi =3D NULL;
 		res.table =3D NULL;
--=20
2.1.0
