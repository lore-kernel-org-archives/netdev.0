From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Wed, 06 Jul 2011 18:56:19 +0200
Message-ID: <1309971379.2292.64.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45233 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342Ab1GFQ4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 12:56:33 -0400
Received: by wwe5 with SMTP id 5so128030wwe.1
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 09:56:32 -0700 (PDT)
In-Reply-To: <20110706173243.404d8599@maggie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 juillet 2011 =C3=A0 17:32 +0200, Michael B=C3=BCsch a =C3=
=A9crit :

> You guys are mixing up quite a bit of stuff here...

Well

>=20
> The EOT bit has _nothing_ to do with the descriptor pointers.
> It simply marks the last descriptor in the (linear) descriptor
> page, so that it becomes an actual ring:
>=20
>    DDDDDDDDDDDDDDDDDDDDDDDDDDDE
>    |                          O
>    |                          T
>    ^--------------------------|
>=20
> It doesn't say anything about the read and write pointers
> to the ring.
>=20
> The B44_DMARX_PTR is the write-end pointer. It points one entry
> beyond the end of the write area. Then there's the software pointer
> where we keep track of the read position.
>=20


Thats not how b44_rx() works :

It writes on DMARX_PTR the last slot that driver _dequeued_ in its NAPI
run. Its not the end of the window that device is allowed to use.

bw32(bp, B44_DMARX_PTR, cons * sizeof(struct dma_desc));

The end of the 'allocated buffers' is in rx_prod. Problem is NIC have n=
o
idea of where is the end of window. We never give rx_prod to NIC.

So NIC actually read old descriptors value. We need to clear them to
avoid memory corruption.


diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 6c4ef96..ec9773b 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -725,6 +725,7 @@ static void b44_recycle_rx(struct b44 *bp, int src_=
idx, u32 dest_idx_unmasked)
 			                 DMA_BIDIRECTIONAL);
=20
 	ctrl =3D src_desc->ctrl;
+	src_desc->ctrl =3D ctrl & cpu_to_le32(DESC_CTRL_EOT);
 	if (dest_idx =3D=3D (B44_RX_RING_SIZE - 1))
 		ctrl |=3D cpu_to_le32(DESC_CTRL_EOT);
 	else
@@ -732,6 +733,7 @@ static void b44_recycle_rx(struct b44 *bp, int src_=
idx, u32 dest_idx_unmasked)
=20
 	dest_desc->ctrl =3D ctrl;
 	dest_desc->addr =3D src_desc->addr;
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



