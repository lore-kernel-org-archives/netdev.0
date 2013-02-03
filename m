From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: frto should not set snd_cwnd to 0
Date: Sun, 03 Feb 2013 11:13:05 -0800
Message-ID: <1359918785.30177.111.camel@edumazet-glaptop>
References: <20130123161238.GE8912@reaktio.net>
	 <20130123214445.GA16641@order.stressinduktion.org>
	 <20130123215151.GF8912@reaktio.net>
	 <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
	 <20130123234116.GC16641@order.stressinduktion.org>
	 <1358984831.12374.1227.camel@edumazet-glaptop>
	 <20130124135120.GD16641@order.stressinduktion.org>
	 <1359777110.30177.58.camel@edumazet-glaptop>
	 <20130202142832.GP8912@reaktio.net>
	 <1359818075.30177.78.camel@edumazet-glaptop>
	 <CADVnQykbufy-kQrEnJm0bbt=n7C8OfE1=Kr-2KfP7Mbu5Eq58w@mail.gmail.com>
	 <1359826377.30177.86.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:63617 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab3BCTNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 14:13:08 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so2022420pad.24
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 11:13:08 -0800 (PST)
In-Reply-To: <1359826377.30177.86.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Commit 9dc274151a548 (tcp: fix ABC in tcp_slow_start())
uncovered a bug in FRTO code :
tcp_process_frto() is setting snd_cwnd to 0 if the number
of in flight packets is 0.

As Neal pointed out, if no packet is in flight we lost our
chance to disambiguate whether a loss timeout was spurious.

We should assume it was a proper loss.

Reported-by: Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8aca4ee..680c422 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3484,7 +3484,8 @@ static bool tcp_process_frto(struct sock *sk, int=
 flag)
 	    ((tp->frto_counter >=3D 2) && (flag & FLAG_RETRANS_DATA_ACKED)))
 		tp->undo_marker =3D 0;
=20
-	if (!before(tp->snd_una, tp->frto_highmark)) {
+	if (!before(tp->snd_una, tp->frto_highmark) ||
+	    !tcp_packets_in_flight(tp)) {
 		tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 2 : 3), flag);
 		return true;
 	}
