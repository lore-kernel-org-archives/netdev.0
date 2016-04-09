From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: fix inet6_lookup_listener()
Date: Sat, 09 Apr 2016 08:01:13 -0700
Message-ID: <1460214073.6473.491.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:35461 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbcDIPBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 11:01:17 -0400
Received: by mail-qg0-f49.google.com with SMTP id f105so89202925qge.2
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 08:01:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

A stupid refactoring bug in inet6_lookup_listener() needs to be fixed
in order to get proper SO_REUSEPORT behavior.

=46ixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under=
 synflood")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv6/inet6_hashtables.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 607da088344d..f1678388fb0d 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -137,7 +137,7 @@ struct sock *inet6_lookup_listener(struct net *net,
 	sk_for_each(sk, &ilb->head) {
 		score =3D compute_score(sk, net, hnum, daddr, dif);
 		if (score > hiscore) {
-			hiscore =3D score;
+			reuseport =3D sk->sk_reuseport;
 			if (reuseport) {
 				phash =3D inet6_ehashfn(net, daddr, hnum,
 						      saddr, sport);
@@ -148,7 +148,7 @@ struct sock *inet6_lookup_listener(struct net *net,
 				matches =3D 1;
 			}
 			result =3D sk;
-			reuseport =3D sk->sk_reuseport;
+			hiscore =3D score;
 		} else if (score =3D=3D hiscore && reuseport) {
 			matches++;
 			if (reciprocal_scale(phash, matches) =3D=3D 0)
