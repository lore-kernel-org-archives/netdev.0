From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 07:59:33 +0200
Message-ID: <1309845573.2720.41.camel@edumazet-laptop>
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
	 <1309842642.2720.36.camel@edumazet-laptop>
	 <CAB9v_DEiPFzQt-TgeVC3r3Y7YFwApLK_NHkDahFOKpibtABrZg@mail.gmail.com>
	 <1309844009.2720.39.camel@edumazet-laptop>
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
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64862 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab1GEF7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 01:59:39 -0400
Received: by wyg8 with SMTP id 8so3754480wyg.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 22:59:38 -0700 (PDT)
In-Reply-To: <1309844009.2720.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 07:33 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 05 juillet 2011 =C3=A0 09:18 +0400, Alexey Zaytsev a =C3=A9c=
rit :
>=20
> > Actually, I've added a trace to show b44_init_rings and b44_free_ri=
ngs
> > calls, and they are only called once, right after the driver is
> > loaded. So it can't be related to START_RFO. Will attach the diff a=
nd
> > dmesg.
>=20
> Thanks
>=20
> I was wondering if DMA could be faster if providing word aligned
> addresses, could you try :
>=20
> -#define RX_PKT_OFFSET          (RX_HEADER_LEN + 2)
> +#define RX_PKT_OFFSET          (RX_HEADER_LEN + NET_IP_ALIGN)
>=20
> (On x86, we now have NET_IP_ALIGN =3D 0 since commit ea812ca1)
>=20

I suspect a hardware bug.

You could force copybreak, so that b44 only touch kind of private
memory.

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index a69331e..62a0599 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -75,7 +75,7 @@
 	  (BP)->tx_cons - (BP)->tx_prod - TX_RING_GAP(BP))
 #define NEXT_TX(N)		(((N) + 1) & (B44_TX_RING_SIZE - 1))
=20
-#define RX_PKT_OFFSET		(RX_HEADER_LEN + 2)
+#define RX_PKT_OFFSET		(RX_HEADER_LEN + NET_IP_ALIGN)
 #define RX_PKT_BUF_SZ		(1536 + RX_PKT_OFFSET)
=20
 /* minimum number of free TX descriptors required to wake up TX proces=
s */
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
@@ -2155,7 +2157,7 @@ static int __devinit b44_init_one(struct ssb_devi=
ce *sdev,
 	bp =3D netdev_priv(dev);
 	bp->sdev =3D sdev;
 	bp->dev =3D dev;
-	bp->force_copybreak =3D 0;
+	bp->force_copybreak =3D 1;
=20
 	bp->msg_enable =3D netif_msg_init(b44_debug, B44_DEF_MSG_ENABLE);
=20


