From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net-netlink: fix diag to export IPv4 tos for dual-stack IPv6 sockets
Date: Mon, 21 Nov 2011 17:50:20 -0800
Message-ID: <1321926620-28753-1-git-send-email-zenczykowski@gmail.com>
References: <CAHo-OozYtgN9_TdOTs+40JKpSZmi2c-6yrbjFS2hViFv_QY-5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Murali Raja <muralira@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:33938 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430Ab1KVBud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 20:50:33 -0500
Received: by iage36 with SMTP id e36so8055985iag.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 17:50:33 -0800 (PST)
In-Reply-To: <CAHo-OozYtgN9_TdOTs+40JKpSZmi2c-6yrbjFS2hViFv_QY-5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
CC: Murali Raja <muralira@google.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inet_diag.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 68e8ac5..ccee270 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -108,9 +108,6 @@ static int inet_csk_diag_fill(struct sock *sk,
 		       icsk->icsk_ca_ops->name);
 	}
=20
-	if ((ext & (1 << (INET_DIAG_TOS - 1))) && (sk->sk_family !=3D AF_INET=
6))
-		RTA_PUT_U8(skb, INET_DIAG_TOS, inet->tos);
-
 	r->idiag_family =3D sk->sk_family;
 	r->idiag_state =3D sk->sk_state;
 	r->idiag_timer =3D 0;
@@ -125,16 +122,23 @@ static int inet_csk_diag_fill(struct sock *sk,
 	r->id.idiag_src[0] =3D inet->inet_rcv_saddr;
 	r->id.idiag_dst[0] =3D inet->inet_daddr;
=20
+	/* IPv6 dual-stack sockets use inet->tos for IPv4 connections,
+	 * hence this needs to be included regardless of socket family.
+	 */
+	if (ext & (1 << (INET_DIAG_TOS - 1)))
+		RTA_PUT_U8(skb, INET_DIAG_TOS, inet->tos);
+
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 	if (r->idiag_family =3D=3D AF_INET6) {
 		const struct ipv6_pinfo *np =3D inet6_sk(sk);
=20
+		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
+			RTA_PUT_U8(skb, INET_DIAG_TCLASS, np->tclass);
+
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_src,
 			       &np->rcv_saddr);
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
 			       &np->daddr);
-		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
-			RTA_PUT_U8(skb, INET_DIAG_TCLASS, np->tclass);
 	}
 #endif
=20
--=20
1.7.3.1
