From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 3.1-rc9
Date: Wed, 02 Nov 2011 18:49:17 +0100
Message-ID: <1320256157.2292.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318874090.4172.84.camel@twins>
	 <CA+55aFwCBy=4YK6amE=H-BYu9-boj4Po2Zkgf4V261mCx0DC4A@mail.gmail.com>
	 <1318879396.4172.92.camel@twins> <alpine.LFD.2.02.1110172237030.3240@ionos>
	 <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins>
	 <20111018182046.GF1309@hostway.ca>
	 <alpine.LFD.2.02.1110182146440.3240@ionos>
	 <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca>
	 <20111031173246.GA10614@hostway.ca>
	 <alpine.LFD.2.02.1111021725550.2829@ionos>
	 <1320254854.2292.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Kirby <sim@hostway.ca>, David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38699 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097Ab1KBRtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 13:49:24 -0400
In-Reply-To: <1320254854.2292.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 novembre 2011 =C3=A0 18:27 +0100, Eric Dumazet a =C3=A9c=
rit :

> I believe it might come from commit 0e734419
> (ipv4: Use inet_csk_route_child_sock() in DCCP and TCP.)
>=20
> In case inet_csk_route_child_sock() returns NULL, we dont release soc=
ket
> lock.
>=20
>=20

Yes, thats the problem. I am testing following patch :

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ea10ee..683d97a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1510,6 +1510,7 @@ exit:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return NULL;
 put_and_exit:
+	bh_unlock_sock(newsk);
 	sock_put(newsk);
 	goto exit;
 }
