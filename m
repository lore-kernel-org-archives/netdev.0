From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: tcp_synack_options() fix
Date: Mon, 17 May 2010 23:04:38 +0200
Message-ID: <1274130278.2567.10.camel@edumazet-laptop>
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
	 <1274072629.2299.58.camel@edumazet-laptop>
	 <20100517134240.1949f245@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bijay Singh <Bijay.Singh@guavus.com>,
	David Miller <davem@davemloft.net>,
	"<bhaskie@gmail.com>" <bhaskie@gmail.com>,
	"<bhutchings@solarflare.com>" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63170 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982Ab0EQVEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 17:04:42 -0400
Received: by mail-fx0-f46.google.com with SMTP id 10so347139fxm.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 14:04:41 -0700 (PDT)
In-Reply-To: <20100517134240.1949f245@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 mai 2010 =C3=A0 13:42 -0700, Stephen Hemminger a =C3=A9crit=
 :

> Since you are doing away with flag variable, why not this instead?
>=20

Sure, we can eliminate this doing_ts variable and save few bytes

Thanks

[PATCH] tcp: tcp_synack_options() fix=20

Commit 33ad798c924b4a (tcp: options clean up) introduced a problem
if MD5+SACK+timestamps were used in initial SYN message.

Some stacks (old linux for example) try to negotiate MD5+SACK+TSTAMP
sessions, but since 40 bytes of tcp options space are not enough to
store all the bits needed, we chose to disable timestamps in this case.

We send a SYN-ACK _without_ timestamp option, but socket has timestamps
enabled and all further outgoing messages contain a TS block, all with
the initial timestamp of the remote peer.

=46ix is to really disable timestamps option for the whole session.

Reported-by: Bijay Singh <Bijay.Singh@guavus.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0dda86e..44e98d9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -667,7 +667,6 @@ static unsigned tcp_synack_options(struct sock *sk,
 	u8 cookie_plus =3D (xvp !=3D NULL && !xvp->cookie_out_never) ?
 			 xvp->cookie_plus :
 			 0;
-	bool doing_ts =3D ireq->tstamp_ok;
=20
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 =3D tcp_rsk(req)->af_specific->md5_lookup(sk, req);
@@ -680,7 +679,7 @@ static unsigned tcp_synack_options(struct sock *sk,
 		 * rather than TS in order to fit in better with old,
 		 * buggy kernels, but that was deemed to be unnecessary.
 		 */
-		doing_ts &=3D !ireq->sack_ok;
+		ireq->tstamp_ok &=3D !ireq->sack_ok;
 	}
 #else
 	*md5 =3D NULL;
@@ -695,7 +694,7 @@ static unsigned tcp_synack_options(struct sock *sk,
 		opts->options |=3D OPTION_WSCALE;
 		remaining -=3D TCPOLEN_WSCALE_ALIGNED;
 	}
-	if (likely(doing_ts)) {
+	if (likely(ireq->tstamp_ok)) {
 		opts->options |=3D OPTION_TS;
 		opts->tsval =3D TCP_SKB_CB(skb)->when;
 		opts->tsecr =3D req->ts_recent;
@@ -703,7 +702,7 @@ static unsigned tcp_synack_options(struct sock *sk,
 	}
 	if (likely(ireq->sack_ok)) {
 		opts->options |=3D OPTION_SACK_ADVERTISE;
-		if (unlikely(!doing_ts))
+		if (unlikely(!ireq->tstamp_ok))
 			remaining -=3D TCPOLEN_SACKPERM_ALIGNED;
 	}
=20
@@ -711,7 +710,7 @@ static unsigned tcp_synack_options(struct sock *sk,
 	 * If the <SYN> options fit, the same options should fit now!
 	 */
 	if (*md5 =3D=3D NULL &&
-	    doing_ts &&
+	    ireq->tstamp_ok &&
 	    cookie_plus > TCPOLEN_COOKIE_BASE) {
 		int need =3D cookie_plus; /* has TCPOLEN_COOKIE_BASE */
=20


