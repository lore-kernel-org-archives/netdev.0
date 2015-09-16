From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] ip: find correct route for socket which is not bound to a device
Date: Wed, 16 Sep 2015 14:34:15 +0800
Message-ID: <1442385255-27014-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wen.gang.wang@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43256 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbbIPGc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 02:32:56 -0400
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t8G6Wtjm028266
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 06:32:56 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.13.8/8.13.8) with ESMTP id t8G6WtZ0019225
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 06:32:55 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id t8G6Wsjb011706
	for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 06:32:55 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46or multi-cast, we should find valid route(thus get the meaniful pmtu=
) for
the package on the socket which is not bound to a device(sk_bound_dev_i=
f
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

The man page doesn't say when socket not bound packages won't be routed=
=2E

A problem is hit that all multi-cast packages dropped by kernel(from se=
nder
host). The lower layer is IPoIB with MTU being 7000. And I was sending =
4096
length multi-cast  package. In side IPoIB the first send is dropped bec=
ause
is exeeding the internal package size limitation mcast_mtu which is 204=
4.
So IPoIB calls ip_rt_update_pmtu (indirectly) trying to set path mtu. A
correct route is configured for the multi-cast, so the setting of pmtu
cucceeded and the next multi-cast package(to the same target) is expect=
ed
to succeed(it would be well fragmented accroding to the pmtu I just set=
).
But actually the second and later multi-cast packages got dropped too. =
And
the reason is that the neighor looking up(fib_lookup) is skipped becaus=
e of
the socket is not bound to device(sk_bound_dev_if being 0). After appli=
ed
the patch I proposed here, it works fine.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
---
 net/ipv4/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5f4a556..032481a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2097,7 +2097,7 @@ struct rtable *__ip_route_output_key(struct net *=
net, struct flowi4 *fl4)
 			 */
=20
 			fl4->flowi4_oif =3D dev_out->ifindex;
-			goto make_route;
+			goto lookup;
 		}
=20
 		if (!(fl4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
@@ -2153,6 +2153,7 @@ struct rtable *__ip_route_output_key(struct net *=
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
