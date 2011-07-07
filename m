From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Thu, 07 Jul 2011 11:20:39 +0200
Message-ID: <1310030439.2127.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705164202.GD2959@hmsreliant.think-freely.org>
	 <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705180650.GF2959@hmsreliant.think-freely.org>
	 <1309889634.2545.2.camel@edumazet-laptop>
	 <1309890775.2545.17.camel@edumazet-laptop>
	 <1309891516.2545.23.camel@edumazet-laptop>
	 <20110705195353.GG2959@hmsreliant.think-freely.org>
	 <1309896147.2545.28.camel@edumazet-laptop>
	 <1309896940.2545.34.camel@edumazet-laptop>
	 <20110705220644.GB12118@hmsreliant.think-freely.org>
	 <20110706173243.404d8599@maggie>
	 <1309971379.2292.64.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAB9v_DFmXS7_0Sx7VgVzViMSqOTtpaqiKrBABcfARigZabr5fA@mail.gmail.com>
	 <1310021286.2481.36.camel@edumazet-laptop>
	 <CAB9v_DF1-q31Y57CUzinXOfGtNejoCAEJVc7u2ECWNLDj97ZPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50970 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000Ab1GGJUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 05:20:53 -0400
Received: by wwe5 with SMTP id 5so749702wwe.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 02:20:51 -0700 (PDT)
In-Reply-To: <CAB9v_DF1-q31Y57CUzinXOfGtNejoCAEJVc7u2ECWNLDj97ZPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 juillet 2011 =C3=A0 11:45 +0400, Alexey Zaytsev a =C3=A9cri=
t :
> On Thu, Jul 7, 2011 at 10:48, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> > Le jeudi 07 juillet 2011 =C3=A0 10:32 +0400, Alexey Zaytsev a =C3=A9=
crit :
> >> Sorry, been busy for the last couple days. Any patches I should te=
st?
> >
> > Please try :
> >
>=20
> Thanks. Seems to fail to initialize, getting this in dmesg:
>=20
> [  103.421577] b44 0000:02:0e.0: PCI INT A -> GSI 16 (level, low) -> =
IRQ 16
> [  103.440139] ssb: Core 0 found: Fast Ethernet (cc 0x806, rev 0x07,
> vendor 0x4243)
> [  103.440159] ssb: Core 1 found: V90 (cc 0x807, rev 0x03, vendor 0x4=
243)
> [  103.440177] ssb: Core 2 found: PCI (cc 0x804, rev 0x0A, vendor 0x4=
243)
> [  103.481128] ssb: Sonics Silicon Backplane found on PCI device 0000=
:02:0e.0
> [  103.481532] b44: b44.c:v2.0
> [  103.502185] b44 ssb1:0: eth0: Broadcom 44xx/47xx 10/100BaseT
> Ethernet 00:17:a4:dd:4e:93
> [  109.405071] b44 ssb1:0: eth0: powering down PHY
> [  112.816456] b44 ssb1:0: eth0: Link is up at 100 Mbps, full duplex
> [  112.816470] b44 ssb1:0: eth0: Flow control is off for TX and off f=
or RX
> [  112.952073] b44 ssb1:0: eth0: powering down PHY
> [  113.816148] b44 ssb1:0: eth0: Link is down
> [  114.953717] b44 ssb1:0: eth0: powering down PHY
> [  117.816246] b44 ssb1:0: eth0: Link is up at 100 Mbps, full duplex
> [  117.816260] b44 ssb1:0: eth0: Flow control is off for TX and off f=
or RX
> [  117.963238] b44 ssb1:0: eth0: powering down PHY
> [  118.816128] b44 ssb1:0: eth0: Link is down
> [  119.962817] b44 ssb1:0: eth0: powering down PHY

Maybe this is the b44_init_hw() change :

bw32(bp, B44_DMARX_PTR, 0);

So please change this part=20

Updated patch :

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 6c4ef96..555a8ce 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -688,8 +688,8 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src=
_idx, u32 dest_idx_unmasked)
 		ctrl |=3D DESC_CTRL_EOT;
=20
 	dp =3D &bp->rx_ring[dest_idx];
-	dp->ctrl =3D cpu_to_le32(ctrl);
 	dp->addr =3D cpu_to_le32((u32) mapping + bp->dma_offset);
+	dp->ctrl =3D cpu_to_le32(ctrl);
=20
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
 		b44_sync_dma_desc_for_device(bp->sdev, bp->rx_ring_dma,
@@ -725,13 +725,15 @@ static void b44_recycle_rx(struct b44 *bp, int sr=
c_idx, u32 dest_idx_unmasked)
 			                 DMA_BIDIRECTIONAL);
=20
 	ctrl =3D src_desc->ctrl;
+	src_desc->ctrl =3D (ctrl & cpu_to_le32(DESC_CTRL_EOT));
 	if (dest_idx =3D=3D (B44_RX_RING_SIZE - 1))
 		ctrl |=3D cpu_to_le32(DESC_CTRL_EOT);
 	else
 		ctrl &=3D cpu_to_le32(~DESC_CTRL_EOT);
=20
-	dest_desc->ctrl =3D ctrl;
 	dest_desc->addr =3D src_desc->addr;
+	dest_desc->ctrl =3D ctrl;
+	src_desc->addr =3D 0;
=20
 	src_map->skb =3D NULL;
=20
@@ -1118,6 +1120,7 @@ static void b44_init_rings(struct b44 *bp)
 		if (b44_alloc_rx_skb(bp, -1, i) < 0)
 			break;
 	}
+	bp->rx_prod =3D i;
 }
=20
 /*
@@ -1406,7 +1409,6 @@ static void b44_init_hw(struct b44 *bp, int reset=
_kind)
 		bw32(bp, B44_DMARX_ADDR, bp->rx_ring_dma + bp->dma_offset);
=20
 		bw32(bp, B44_DMARX_PTR, bp->rx_pending);
-		bp->rx_prod =3D bp->rx_pending;
=20
 		bw32(bp, B44_MIB_CTRL, MIB_CTRL_CLR_ON_READ);
 	}


