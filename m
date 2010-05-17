From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Mon, 17 May 2010 07:03:49 +0200
Message-ID: <1274072629.2299.58.camel@edumazet-laptop>
References: <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273147586.2357.63.camel@edumazet-laptop>
	 <20100506.220443.135536330.davem@davemloft.net>
	 <1273210329.2222.42.camel@edumazet-laptop>
	 <20100507101451.1b4286b7@nehalam>
	 <1273252893.2261.84.camel@edumazet-laptop>
	 <20100507103639.4f1a51fa@nehalam>
	 <1273268446.2325.53.camel@edumazet-laptop>
	 <D1C2B1EC-ABE8-4D87-9227-6D0F1C1C8B77@guavus.com>
	 <1273504693.2221.17.camel@edumazet-laptop>
	 <AAFABD0F-C66F-44C2-8BDC-FB489EA8655F@guavus.com>
	 <1273611036.2512.18.camel@edumazet-laptop>
	 <1274042939.2299.27.camel@edumazet-laptop>
	 <B58BD160-4613-4CE8-9899-70E2D028AE5B@guavus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	"<bhaskie@gmail.com>" <bhaskie@gmail.com>,
	"<bhutchings@solarflare.com>" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Bijay Singh <Bijay.Singh@guavus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:37745 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab0EQFDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 01:03:55 -0400
Received: by wwi17 with SMTP id 17so244012wwi.19
        for <netdev@vger.kernel.org>; Sun, 16 May 2010 22:03:53 -0700 (PDT)
In-Reply-To: <B58BD160-4613-4CE8-9899-70E2D028AE5B@guavus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 mai 2010 =C3=A0 03:49 +0000, Bijay Singh a =C3=A9crit :

> I am on quite an old kernel 2.6.27 and could not apply your patches.
>=20
> Then i moved on to the kernel 2.6.32.11 however since then I have not=
 been able to bring up my card, this is something i need to fix before =
i can test you fix. Working on that.
>=20

Thanks again for the status report.

I see bug is older than what I stated in my previous mail

I could reproduce it in my lab and confirm following patch fixes it

This is a stable candidate (2.6.27 kernels)

Thanks

[PATCH] tcp: tcp_synack_options() fix=20

Commit 33ad798c924b4a (tcp: options clean up) introduced a problem
if MD5+SACK+timestamps were used in initial SYN message.

Some stacks (old linux for example) try to negotiate MD5+SACK+TSTAMP
sessions, but since 20 bytes of tcp options space are not enough to
store all the bits needed, we chose to disable timestamps in this case.

We send a SYN-ACK _without_ timestamp option, but socket has timestamps
enabled and all further outgoing messages contain a TS block, all with
the initial timestamp of the remote peer.

=46ix is to really disable timestamps option for the whole session.

Reported-by: Bijay Singh <Bijay.Singh@guavus.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_output.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0dda86e..b8bb226 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -667,7 +667,7 @@ static unsigned tcp_synack_options(struct sock *sk,
 	u8 cookie_plus =3D (xvp !=3D NULL && !xvp->cookie_out_never) ?
 			 xvp->cookie_plus :
 			 0;
-	bool doing_ts =3D ireq->tstamp_ok;
+	bool doing_ts;
=20
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 =3D tcp_rsk(req)->af_specific->md5_lookup(sk, req);
@@ -680,11 +680,12 @@ static unsigned tcp_synack_options(struct sock *s=
k,
 		 * rather than TS in order to fit in better with old,
 		 * buggy kernels, but that was deemed to be unnecessary.
 		 */
-		doing_ts &=3D !ireq->sack_ok;
+		ireq->tstamp_ok &=3D !ireq->sack_ok;
 	}
 #else
 	*md5 =3D NULL;
 #endif
+	doing_ts =3D ireq->tstamp_ok;
=20
 	/* We always send an MSS option. */
 	opts->mss =3D mss;


