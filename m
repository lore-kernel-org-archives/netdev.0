From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Tue, 11 May 2010 22:50:36 +0200
Message-ID: <1273611036.2512.18.camel@edumazet-laptop>
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
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45308 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097Ab0EKU6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 16:58:22 -0400
Received: by fxm15 with SMTP id 15so79660fxm.19
        for <netdev@vger.kernel.org>; Tue, 11 May 2010 13:58:21 -0700 (PDT)
In-Reply-To: <AAFABD0F-C66F-44C2-8BDC-FB489EA8655F@guavus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 11 mai 2010 =C3=A0 04:08 +0000, Bijay Singh a =C3=A9crit :
> Hi Eric,
>=20
> I guess that makes me the enviable one. So I am keen to test out this=
 feature completely, as long as I know what to do as a next step, direc=
tions, patches.
>=20
> Thanks


I believe third problem comes from commit 4957faad
(TCPCT part 1g: Responder Cookie =3D> Initiator), from William Allen
Simpson.

When a SYN-ACK packet is built (in tcp_synack_options()),
it specifically forbids a TIMESTAMP option to be included if SACK is
also selected :

doing_ts &=3D !ireq->sack_ok;

Problem is this mask is done on a local variable. socket is still marke=
d
as being timestamp enabled.


Later, when we build tcp options for data packets, we _include_ a
timestamp, while our SYNACK didnt mention the option. =20

So the following trafic can happen (and fails) :

18:38:29.041966 IP 192.168.0.33.58906 > 192.168.0.56.22226: Flags [S], =
seq 4014064674, win 8860, options [mss 4430,sackOK,TS val 519041 ecr 0,=
nop,wscale 7,nop,nop,md5can't check - 9b44126367effcf3247fcbf6da76b24d]=
, length 0
18:38:29.042072 IP 192.168.0.56.22226 > 192.168.0.33.58906: Flags [S.],=
 seq 586328714, ack 4014064675, win 5792, options [nop,nop,md5can't che=
ck - badd847799ded46f39642c341cc7e92b,mss 1460,nop,nop,sackOK,nop,wscal=
e 7], length 0
18:38:29.042093 IP 192.168.0.33.58906 > 192.168.0.56.22226: Flags [.], =
ack 1, win 70, options [nop,nop,md5can't check - 3994ef6987df02a592963f=
ba04c5d313], length 0
18:38:29.043217 IP 192.168.0.33.58906 > 192.168.0.56.22226: Flags [.], =
seq 1:1441, ack 1, win 70, options [nop,nop,md5can't check - 8399f7ccab=
3a6b8c5a3027ed58bba314], length 1440
18:38:29.043226 IP 192.168.0.33.58906 > 192.168.0.56.22226: Flags [P.],=
 seq 1441:2501, ack 1, win 70, options [nop,nop,md5can't check - 701ebf=
65b1894a6bed4cefbf7a56596a], length 1060
18:38:29.043374 IP 192.168.0.56.22226 > 192.168.0.33.58906: Flags [.], =
ack 1441, win 68, options [nop,nop,md5can't check - 1badb315ba436ab59bf=
f5b37daa871be,nop,nop,TS val 113051377 ecr 519041], length 0
18:38:29.043383 IP 192.168.0.56.22226 > 192.168.0.33.58906: Flags [.], =
ack 2501, win 91, options [nop,nop,md5can't check - 120564dcb99f822f3b7=
0910282a6ed9d,nop,nop,TS val 113051377 ecr 519041], length 0
18:38:29.043673 IP 192.168.0.56.22226 > 192.168.0.33.58906: Flags [.], =
seq 1:1429, ack 2501, win 91, options [nop,nop,md5can't check - fe5dfb4=
38065373b52ba85bf800876a8,nop,nop,TS val 113051377 ecr 519041], length =
1428
18:38:29.043681 IP 192.168.0.56.22226 > 192.168.0.33.58906: Flags [P.],=
 seq 1429:2500, ack 2501, win 91, options [nop,nop,md5can't check - 7a9=
10cd5ff357bf0e2c8d3489aafaa86,nop,nop,TS val 113051377 ecr 519041], len=
gth 1071
18:38:32.037786 IP 192.168.0.56.22226 > 192.168.0.33.58906: Flags [.], =
seq 1:1429, ack 2501, win 91, options [nop,nop,md5can't check - fe5dfb4=
38065373b52ba85bf800876a8,nop,nop,TS val 113051677 ecr 519041], length =
1428
18:38:38.037708 IP 192.168.0.56.22226 > 192.168.0.33.58906: Flags [.], =
seq 1:1429, ack 2501, win 91, options [nop,nop,md5can't check - fe5dfb4=
38065373b52ba85bf800876a8,nop,nop,TS val 113052277 ecr 519041], length =
1428
18:38:50.037524 IP 192.168.0.56.22226 > 192.168.0.33.58906: Flags [.], =
seq 1:1429, ack 2501, win 91, options [nop,nop,md5can't check - fe5dfb4=
38065373b52ba85bf800876a8,nop,nop,TS val 113053477 ecr 519041], length =
1428


Could you try following patch ?

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5db3a2c..0be21cd 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -668,7 +668,7 @@ static unsigned tcp_synack_options(struct sock *sk,
 	u8 cookie_plus =3D (xvp !=3D NULL && !xvp->cookie_out_never) ?
 			 xvp->cookie_plus :
 			 0;
-	bool doing_ts =3D ireq->tstamp_ok;
+	bool doing_ts;
=20
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 =3D tcp_rsk(req)->af_specific->md5_lookup(sk, req);
@@ -681,11 +681,12 @@ static unsigned tcp_synack_options(struct sock *s=
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





