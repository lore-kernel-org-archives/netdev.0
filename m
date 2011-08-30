From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42012] New: regression on 2.6.39.3 with socket/bind;
 still there in 3.0.4
Date: Tue, 30 Aug 2011 22:19:22 +0200
Message-ID: <1314735562.2556.20.camel@edumazet-laptop>
References: <20110830.140733.146208373221522199.davem@davemloft.net>
	 <1314731803.2556.4.camel@edumazet-laptop>
	 <1314733459.2556.10.camel@edumazet-laptop>
	 <20110830.155219.431579142669857208.davem@davemloft.net>
	 <1314734452.2556.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Marcus Meissner <meissner@suse.de>, r_meier@freenet.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65287 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756567Ab1H3UT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 16:19:27 -0400
Received: by wwf5 with SMTP id 5so22475wwf.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 13:19:25 -0700 (PDT)
In-Reply-To: <1314734452.2556.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 22:00 +0200, Eric Dumazet a =C3=A9cri=
t :

> Sure, I will send a patch in a couple of minutes.
>=20
>=20

[PATCH] net: ipv4: relax AF_INET check in bind()

commit d0733d2e29b65 (Check for mistakenly passed in non-IPv4 address)
added regression on legacy apps that use bind() with AF_UNSPEC family.

Relax the check, but make sure the bind() is done on INADDR_ANY
addresses, as AF_UNSPEC has probably no sane meaning for other
addresses.

Bugzilla reference : https://bugzilla.kernel.org/show_bug.cgi?id=3D4201=
2

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Reported-and-bisected-by: Rene Meier <r_meier@freenet.de>
CC: Marcus Meissner <meissner@suse.de>
---
 net/ipv4/af_inet.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1b745d4..dd2b947 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -466,8 +466,13 @@ int inet_bind(struct socket *sock, struct sockaddr=
 *uaddr, int addr_len)
 		goto out;
=20
 	if (addr->sin_family !=3D AF_INET) {
+		/* Compatibility games : accept AF_UNSPEC (mapped to AF_INET)
+		 * only if s_addr is INADDR_ANY.
+		 */
 		err =3D -EAFNOSUPPORT;
-		goto out;
+		if (addr->sin_family !=3D AF_UNSPEC ||
+		    addr->sin_addr.s_addr !=3D htonl(INADDR_ANY))
+			goto out;
 	}
=20
 	chk_addr_ret =3D inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
