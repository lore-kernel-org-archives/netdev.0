From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: remove TCP_OFF and TCP_PAGE macros
Date: Mon, 05 Dec 2011 12:07:15 +0100
Message-ID: <1323083235.2670.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323018317.2762.143.camel@edumazet-laptop>
	 <1323019253.1785.7.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56854 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755836Ab1LELHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 06:07:18 -0500
Received: by vbbfc26 with SMTP id fc26so3759569vbb.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 03:07:17 -0800 (PST)
In-Reply-To: <1323019253.1785.7.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 04 d=C3=A9cembre 2011 =C3=A0 09:20 -0800, Joe Perches a =C3=
=A9crit :
> And maybe the TCP_OFF and TCP_PAGE macros should be removed.
>=20

Agreed, thanks.

[PATCH net-next] tcp: remove TCP_OFF and TCP_PAGE macros

As mentioned by Joe Perches, TCP_OFF() and TCP_PAGE() macros are
useless.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp.c |   23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a09fe25..43dfccc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -888,9 +888,6 @@ int tcp_sendpage(struct sock *sk, struct page *page=
, int offset,
 }
 EXPORT_SYMBOL(tcp_sendpage);
=20
-#define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
-#define TCP_OFF(sk)	(sk->sk_sndmsg_off)
-
 static inline int select_size(const struct sock *sk, bool sg)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1008,13 +1005,13 @@ new_segment:
 			} else {
 				int merge =3D 0;
 				int i =3D skb_shinfo(skb)->nr_frags;
-				struct page *page =3D TCP_PAGE(sk);
+				struct page *page =3D sk->sk_sndmsg_page;
 				int off;
=20
 				if (page && page_count(page) =3D=3D 1)
-					TCP_OFF(sk) =3D 0;
+					sk->sk_sndmsg_off =3D 0;
=20
-				off =3D TCP_OFF(sk);
+				off =3D sk->sk_sndmsg_off;
=20
 				if (skb_can_coalesce(skb, i, page, off) &&
 				    off !=3D PAGE_SIZE) {
@@ -1031,7 +1028,7 @@ new_segment:
 				} else if (page) {
 					if (off =3D=3D PAGE_SIZE) {
 						put_page(page);
-						TCP_PAGE(sk) =3D page =3D NULL;
+						sk->sk_sndmsg_page =3D page =3D NULL;
 						off =3D 0;
 					}
 				} else
@@ -1057,9 +1054,9 @@ new_segment:
 					/* If this page was new, give it to the
 					 * socket so it does not get leaked.
 					 */
-					if (!TCP_PAGE(sk)) {
-						TCP_PAGE(sk) =3D page;
-						TCP_OFF(sk) =3D 0;
+					if (!sk->sk_sndmsg_page) {
+						sk->sk_sndmsg_page =3D page;
+						sk->sk_sndmsg_off =3D 0;
 					}
 					goto do_error;
 				}
@@ -1069,15 +1066,15 @@ new_segment:
 					skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
 				} else {
 					skb_fill_page_desc(skb, i, page, off, copy);
-					if (TCP_PAGE(sk)) {
+					if (sk->sk_sndmsg_page) {
 						get_page(page);
 					} else if (off + copy < PAGE_SIZE) {
 						get_page(page);
-						TCP_PAGE(sk) =3D page;
+						sk->sk_sndmsg_page =3D page;
 					}
 				}
=20
-				TCP_OFF(sk) =3D off + copy;
+				sk->sk_sndmsg_off =3D off + copy;
 			}
=20
 			if (!copied)
