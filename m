From: Su Xuemin <suxm@chinanetcenter.com>
Subject: [PATCH v2] udp reuseport: fix packet of same flow hashed to different socket
Date: Wed,  8 Jun 2016 11:40:19 +0800
Message-ID: <1465357219-34240-1-git-send-email-suxm@chinanetcenter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, suxm@chinanetcenter.com
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.chinanetcenter.com ([123.103.13.31]:39297 "EHLO
	chinanetcenter.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161190AbcFHDlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 23:41:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Su, Xuemin" <suxm@chinanetcenter.com>

There is a corner case in which udp packets belonging to a same
flow are hashed to different socket when hslot->count changes from 10
to 11:

1) When hslot->count <=3D 10, __udp_lib_lookup() searches udp_table->ha=
sh,
and always passes 'daddr' to udp_ehashfn().

2) When hslot->count > 10, __udp_lib_lookup() searches udp_table->hash2=
,
but may pass 'INADDR_ANY' to udp_ehashfn() if the sockets are bound to
INADDR_ANY instead of some specific addr.

That means when hslot->count changes from 10 to 11, the hash calculated=
 by
udp_ehashfn() is also changed, and the udp packets belonging to a same
flow will be hashed to different socket.

This is easily reproduced:
1) Create 10 udp sockets and bind all of them to 0.0.0.0:40000.
2) From the same host send udp packets to 127.0.0.1:40000, record the
socket index which receives the packets.
3) Create 1 more udp socket and bind it to 0.0.0.0:44096. The number 44=
096
is 40000 + UDP_HASH_SIZE(4096), this makes the new socket put into the
same hslot as the aformentioned 10 sockets, and makes the hslot->count
change from 10 to 11.
4) From the same host send udp packets to 127.0.0.1:40000, and the sock=
et
index which receives the packets will be different from the one receive=
d
in step 2.
This should not happen as the socket bound to 0.0.0.0:44096 should not
change the behavior of the sockets bound to 0.0.0.0:40000.

The fix here is that when searching udp_table->hash, if the socket
supports reuseport, pass inet_sk(sk)->inet_rcv_saddr to udp_ehashfn()
instead of daddr. When the sockets are bound to some specific addr,
inet_sk(sk)->inet_rcv_saddr should equal to daddr, and when the sockets
are bould to INADDR_ANY, this will pass INADDR_ANY to udp_ehashfn() as
what is done when searching udp_table->hash2.

It's the same case for IPv6, and this patch also fixes that.

Signed-off-by: Su, Xuemin <suxm@chinanetcenter.com>
---
The patch v1 does not fix the code in IPv6. Thank Eric=C2=A0Dumazet for
pointing that.
And I use this tree to generate this patch, hope it's correct:
  git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

 net/ipv4/udp.c | 4 +++-
 net/ipv6/udp.c | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d56c055..57c38f6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -577,7 +577,9 @@ begin:
 		if (score > badness) {
 			reuseport =3D sk->sk_reuseport;
 			if (reuseport) {
-				hash =3D udp_ehashfn(net, daddr, hnum,
+				hash =3D udp_ehashfn(net,
+						   inet_sk(sk)->inet_rcv_saddr,
+						   hnum,
 						   saddr, sport);
 				result =3D reuseport_select_sock(sk, hash, skb,
 							sizeof(struct udphdr));
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2da1896..41ca493 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -290,7 +290,9 @@ begin:
 		if (score > badness) {
 			reuseport =3D sk->sk_reuseport;
 			if (reuseport) {
-				hash =3D udp6_ehashfn(net, daddr, hnum,
+				hash =3D udp6_ehashfn(net,
+						    &sk->sk_v6_rcv_saddr,
+						    hnum,
 						    saddr, sport);
 				result =3D reuseport_select_sock(sk, hash, skb,
 							sizeof(struct udphdr));
--=20
1.8.3.1
