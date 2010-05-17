From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Mon, 17 May 2010 13:42:40 -0700
Message-ID: <20100517134240.1949f245@nehalam>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bijay Singh <Bijay.Singh@guavus.com>,
	David Miller <davem@davemloft.net>,
	"<bhaskie@gmail.com>" <bhaskie@gmail.com>,
	"<bhutchings@solarflare.com>" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?B?SuRydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34598 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753003Ab0EQUmn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 16:42:43 -0400
In-Reply-To: <1274072629.2299.58.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 May 2010 07:03:49 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 17 mai 2010 =E0 03:49 +0000, Bijay Singh a =E9crit :
>=20
> > I am on quite an old kernel 2.6.27 and could not apply your patches=
=2E
> >=20
> > Then i moved on to the kernel 2.6.32.11 however since then I have n=
ot been able to bring up my card, this is something i need to fix befor=
e i can test you fix. Working on that.
> >=20
>=20
> Thanks again for the status report.
>=20
> I see bug is older than what I stated in my previous mail
>=20
> I could reproduce it in my lab and confirm following patch fixes it
>=20
> This is a stable candidate (2.6.27 kernels)
>=20
> Thanks
>=20
> [PATCH] tcp: tcp_synack_options() fix=20
>=20
> Commit 33ad798c924b4a (tcp: options clean up) introduced a problem
> if MD5+SACK+timestamps were used in initial SYN message.
>=20
> Some stacks (old linux for example) try to negotiate MD5+SACK+TSTAMP
> sessions, but since 20 bytes of tcp options space are not enough to
> store all the bits needed, we chose to disable timestamps in this cas=
e.
>=20
> We send a SYN-ACK _without_ timestamp option, but socket has timestam=
ps
> enabled and all further outgoing messages contain a TS block, all wit=
h
> the initial timestamp of the remote peer.
>=20
> Fix is to really disable timestamps option for the whole session.
>=20
> Reported-by: Bijay Singh <Bijay.Singh@guavus.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/tcp_output.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 0dda86e..b8bb226 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -667,7 +667,7 @@ static unsigned tcp_synack_options(struct sock *s=
k,
>  	u8 cookie_plus =3D (xvp !=3D NULL && !xvp->cookie_out_never) ?
>  			 xvp->cookie_plus :
>  			 0;
> -	bool doing_ts =3D ireq->tstamp_ok;
> +	bool doing_ts;
> =20
>  #ifdef CONFIG_TCP_MD5SIG
>  	*md5 =3D tcp_rsk(req)->af_specific->md5_lookup(sk, req);
> @@ -680,11 +680,12 @@ static unsigned tcp_synack_options(struct sock =
*sk,
>  		 * rather than TS in order to fit in better with old,
>  		 * buggy kernels, but that was deemed to be unnecessary.
>  		 */
> -		doing_ts &=3D !ireq->sack_ok;
> +		ireq->tstamp_ok &=3D !ireq->sack_ok;
>  	}
>  #else
>  	*md5 =3D NULL;
>  #endif
> +	doing_ts =3D ireq->tstamp_ok;
> =20
>  	/* We always send an MSS option. */
>  	opts->mss =3D mss;
>=20
>=20

Since you are doing away with flag variable, why not this instead?


--- a/net/ipv4/tcp_output.c	2010-05-17 13:38:32.822025583 -0700
+++ b/net/ipv4/tcp_output.c	2010-05-17 13:41:47.321734775 -0700
@@ -668,7 +668,6 @@ static unsigned tcp_synack_options(struc
 	u8 cookie_plus =3D (xvp !=3D NULL && !xvp->cookie_out_never) ?
 			 xvp->cookie_plus :
 			 0;
-	bool doing_ts =3D ireq->tstamp_ok;
=20
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 =3D tcp_rsk(req)->af_specific->md5_lookup(sk, req);
@@ -681,7 +680,7 @@ static unsigned tcp_synack_options(struc
 		 * rather than TS in order to fit in better with old,
 		 * buggy kernels, but that was deemed to be unnecessary.
 		 */
-		doing_ts &=3D !ireq->sack_ok;
+		ireq->tstamp_ok &=3D !ireq->sack_ok;
 	}
 #else
 	*md5 =3D NULL;
@@ -696,7 +695,7 @@ static unsigned tcp_synack_options(struc
 		opts->options |=3D OPTION_WSCALE;
 		remaining -=3D TCPOLEN_WSCALE_ALIGNED;
 	}
-	if (likely(doing_ts)) {
+	if (likely(ireq->tstamp_ok)) {
 		opts->options |=3D OPTION_TS;
 		opts->tsval =3D TCP_SKB_CB(skb)->when;
 		opts->tsecr =3D req->ts_recent;
@@ -704,7 +703,7 @@ static unsigned tcp_synack_options(struc
 	}
 	if (likely(ireq->sack_ok)) {
 		opts->options |=3D OPTION_SACK_ADVERTISE;
-		if (unlikely(!doing_ts))
+		if (unlikely(!ireq->tstamp_ok))
 			remaining -=3D TCPOLEN_SACKPERM_ALIGNED;
 	}
=20
@@ -712,7 +711,7 @@ static unsigned tcp_synack_options(struc
 	 * If the <SYN> options fit, the same options should fit now!
 	 */
 	if (*md5 =3D=3D NULL &&
-	    doing_ts &&
+	    ireq->tstamp_ok &&
 	    cookie_plus > TCPOLEN_COOKIE_BASE) {
 		int need =3D cookie_plus; /* has TCPOLEN_COOKIE_BASE */
=20


=20



--=20
