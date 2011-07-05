From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 07:10:42 +0200
Message-ID: <1309842642.2720.36.camel@edumazet-laptop>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	 <20110629145135.5179fb0c.akpm@linux-foundation.org>
	 <BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	 <CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	 <1309707971.2523.20.camel@edumazet-laptop>
	 <CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
	 <20110704130531.37cf876e@Nokia-N900>
	 <1309787822.2247.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110704162726.4072e715@maggie> <20110704164351.338dc12e@maggie>
	 <1309792323.2247.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAB9v_DHHmeFtQ4jrtVRSGWBvB=W_=QBHCvMi-u25e0nPBQ1jAA@mail.gmail.com>
	 <CAB9v_DFFX6cHAFBSOGDJRniehJ6pYD7Z5XG6ygTGHy8j=z+U0g@mail.gmail.com>
	 <1309837443.2720.8.camel@edumazet-laptop>
	 <CAB9v_DFYGyYiXGfMCXn_WDeGTKz8BZPYBCuaDj_a+5VAG3Jn=g@mail.gmail.com>
	 <1309839068.2720.15.camel@edumazet-laptop>
	 <1309839258.2720.17.camel@edumazet-laptop>
	 <CAB9v_DGSFAG9V0jqem+tDP3G-N8v6Z+_6oKdPwL-ZwhfhCOZnw@mail.gmail.com>
	 <1309839928.2720.23.camel@edumazet-laptop>
	 <CAB9v_DEOhZh37aqx1qrLnrz5+tqjcjgBx-DP6M_0NkygZ1LjcQ@mail.gmail.com>
	 <1309840708.2720.31.camel@edumazet-laptop>
	 <CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58597 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab1GEFKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 01:10:47 -0400
Received: by wwe5 with SMTP id 5so5564557wwe.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 22:10:46 -0700 (PDT)
In-Reply-To: <CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 08:57 +0400, Alexey Zaytsev a =C3=A9cri=
t :

> Ran tcpdump. You are right, I was wrong. Sorry for the noise.

Thanks for testing ;)

It would be nice to know if the memory scribbles start after or before
one RFO triggers.

I can see this calls b44_init_rings() without really stopping the devic=
e
before. This seems very suspect to me.



diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index a69331e..b22dd4c 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -829,6 +829,7 @@ static int b44_rx(struct b44 *bp, int budget)
 	}
=20
 	bp->rx_cons =3D cons;
+	wmb();
 	bw32(bp, B44_DMARX_PTR, cons * sizeof(struct dma_desc));
=20
 	return received;
@@ -848,6 +849,7 @@ static int b44_poll(struct napi_struct *napi, int b=
udget)
 		/* spin_unlock(&bp->tx_lock); */
 	}
 	if (bp->istat & ISTAT_RFO) {	/* fast recovery, in ~20msec */
+		pr_err("b44: ISTAT_RFO !\n");
 		bp->istat &=3D ~ISTAT_RFO;
 		b44_disable_ints(bp);
 		ssb_device_enable(bp->sdev, 0); /* resets ISTAT_RFO */
=20


