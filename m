From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Tue, 18 Oct 2011 16:47:44 +0200
Message-ID: <1318949264.2657.97.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E9D5E1B.3080704@gmail.com>
	 <1318939007.2657.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318946401.23980.6.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Turull <daniel.turull@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Voravit Tanyingyong <voravit@kth.se>,
	Jens Laas <jens.laas@uadm.uu.se>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42179 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab1JROr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 10:47:26 -0400
Received: by bkbzt19 with SMTP id zt19so870432bkb.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 07:47:24 -0700 (PDT)
In-Reply-To: <1318946401.23980.6.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 15:00 +0100, Ben Hutchings a =C3=A9crit=
 :

> AIUI, the reason for limits on delays is not that it's bad practice t=
o
> spin for so long, but that the delay calculations may overflow or
> otherwise become inaccurate.

OK, I can understand that, then a more appropriate patch would be :


diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 796044a..28bbf5b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2145,9 +2145,12 @@ static void spin(struct pktgen_dev *pkt_dev, kti=
me_t spin_until)
 	}
=20
 	start_time =3D ktime_now();
-	if (remaining < 100000)
-		ndelay(remaining);	/* really small just spin */
-	else {
+	if (remaining < 100000) {
+		if (remaining >=3D 10000)
+			udelay(remaining/1000);
+		else
+			ndelay(remaining);
+	} else {
 		/* see do_nanosleep */
 		hrtimer_init_sleeper(&t, current);
 		do {
