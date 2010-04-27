From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bnx2x: Remove two prefetch()
Date: Wed, 28 Apr 2010 00:18:13 +0200
Message-ID: <1272406693.2343.26.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44720 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757258Ab0D0WSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:18:18 -0400
Received: by bwz19 with SMTP id 19so67359bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 15:18:16 -0700 (PDT)
In-Reply-To: <20100427.150817.84390202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 15:08 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 23 Apr 2010 12:26:06 +0200
>=20
> > Le vendredi 23 avril 2010 =C3=A0 16:12 +0800, Changli Gao a =C3=A9c=
rit :
> >> batch skb dequeueing from softnet input_pkt_queue.
> >>=20
> >> batch skb dequeueing from softnet input_pkt_queue to reduce potent=
ial lock
> >> contention when RPS is enabled.
> >>=20
> >> Note: in the worst case, the number of packets in a softnet_data m=
ay be double
> >> of netdev_max_backlog.
> >>=20
> >> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> >> ----
> >=20
> > Oops, reading it again, I found process_backlog() was still taking =
the
> > lock twice, if only one packet is waiting in input_pkt_queue.
> >=20
> > Possible fix, on top of your patch :
>=20
> I've applied Changli's patch with this fixup added to it.
>=20
> If there are any follow-on changes necessary after further analysis,
> please send patches on top of this work.
>=20

Thanks David, I was about to resubmit the cumulative patch ;)

On my 'old' dev machine (two quad core), RPS is able to get a 300%
increase on udpsink test on 20 flows.

I yet have to make routing/firewalling tests as well.

I also noticed bnx2x driver has some strange prefetch() calls.

[PATCH net-next-2.6] bnx2x: Remove two prefetch()

1) Even on 64bit arches, sizeof(struct sk_buff) < 256
2) No need to prefetch same pointer twice.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Eilon Greenstein <eilong@broadcom.com>
---

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 613f727..f706ed1 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1617,7 +1617,6 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp=
, int budget)
 			rx_buf =3D &fp->rx_buf_ring[bd_cons];
 			skb =3D rx_buf->skb;
 			prefetch(skb);
-			prefetch((u8 *)skb + 256);
 			len =3D le16_to_cpu(cqe->fast_path_cqe.pkt_len);
 			pad =3D cqe->fast_path_cqe.placement_offset;
=20
@@ -1668,7 +1667,6 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp=
, int budget)
 					dma_unmap_addr(rx_buf, mapping),
 						   pad + RX_COPY_THRESH,
 						   DMA_FROM_DEVICE);
-			prefetch(skb);
 			prefetch(((char *)(skb)) + 128);
=20
 			/* is this an error packet? */



