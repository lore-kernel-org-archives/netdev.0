From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Sat, 16 May 2009 16:14:30 +0200
Message-ID: <20090516141430.GB3013@ami.dom.local>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com> <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:59455 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbZEPOQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 10:16:10 -0400
Received: by fxm2 with SMTP id 2so2416790fxm.37
        for <netdev@vger.kernel.org>; Sat, 16 May 2009 07:16:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 03:49:31PM +0100, Antonio Almeida wrote:
=2E..
> I also note that, for HTB rate configurations over 500Mbit/s on leaf
> class, when I stop the traffic, in the output of "tc -s -d class ls
> dev eth1" command, I see that leaf's rate (in bits/s) is growing
> instead of decreasing (as expected since I've stopped the traffic).
> Rate in pps is ok and decreases until 0pps. Rate in bits/s increases
> above 1000Mbit and stays there for a few minutes. After two or three
> minutes it becomes 0bit. The same happens for it's ancestors (also fo=
r
> root class).Here's tc output of my leaf class for this situation:
>=20
> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
> 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
> 70901b/8 mpu 0b overhead 0b level 0
> =A0Sent 120267768144 bytes 242475339 pkt (dropped 62272599, overlimit=
s 0
> requeues 0)
> =A0rate 1074Mbit 0pps backlog 0b 0p requeues 0
> =A0lended: 242475339 borrowed: 0 giants: 0
> =A0tokens: 8 ctokens: 8

This looks like a regular bug. I guess it's an overflow in
gen_estimator(), but I'm not sure there is nothing more. Could you
try the patch below? (An offset warning when patching 2.6.25 is OK)

Thanks,
Jarek P.
---

 net/core/gen_estimator.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 9cc9f95..87f0ced 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -127,7 +127,11 @@ static void est_timer(unsigned long arg)
 		npackets =3D e->bstats->packets;
 		rate =3D (nbytes - e->last_bytes)<<(7 - idx);
 		e->last_bytes =3D nbytes;
-		e->avbps +=3D ((long)rate - (long)e->avbps) >> e->ewma_log;
+		if (rate > e->avbps)
+			e->avbps +=3D (rate - e->avbps) >> e->ewma_log;
+		else
+			e->avbps -=3D (e->avbps - rate) >> e->ewma_log;
+
 		e->rate_est->bps =3D (e->avbps+0xF)>>5;
=20
 		rate =3D (npackets - e->last_packets)<<(12 - idx);
