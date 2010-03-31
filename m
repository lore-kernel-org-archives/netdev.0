From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Wed, 31 Mar 2010 14:08:31 +0200
Message-ID: <1270037311.2103.17.camel@edumazet-laptop>
References: <20100307192305.GA598@elte.hu>
	 <20100308125122.GA11242@redhat.com>
	 <1268686865.2824.4.camel@edumazet-laptop>
	 <1268699602.2824.14.camel@edumazet-laptop>
	 <20100316145914.GB3332@swordfish.minsk.epam.com>
	 <1268751933.3094.45.camel@edumazet-laptop>
	 <20100316151023.GC3332@swordfish.minsk.epam.com>
	 <1268752826.3094.48.camel@edumazet-laptop>
	 <20100316182619.GA3451@swordfish>
	 <1268765284.2932.17.camel@edumazet-laptop>
	 <20100325113038.GA3471@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:33312 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757037Ab0CaMIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 08:08:40 -0400
Received: by bwz1 with SMTP id 1so7287bwz.21
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 05:08:37 -0700 (PDT)
In-Reply-To: <20100325113038.GA3471@swordfish.minsk.epam.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 mars 2010 =C3=A0 13:30 +0200, Sergey Senozhatsky a =C3=A9cr=
it :
> Hello,
>=20
> On (03/16/10 19:48), Eric Dumazet wrote:
> [..]
> > OK thanks for the report, this rtl8169_reset_task() seems pretty bu=
ggy,
> > or multiple invocation...
> >=20
> > Did you tried removing the rtl8169_schedule_work() call from
> > rtl8169_rx_interrupt() ?
> >=20
> > Maybe the reset is not necessary at all in case of fifo overflow..
> >=20
> > Cumulative patch :
> >=20
> [..]
>=20
> Eric, I think you can put Tested-by: Sergey Senozhatsky <sergey.senoz=
hatsky@gmail.com>
> on the cumulative patch as I don't see any errors with pktgen over LA=
N testing.
>=20

OK thanks, here is the patch then, but I prefer let the
rtl8169_schedule_work() from rtl8169_rx_interrupt() for now, its remova=
l
might be the subject of another patch.

Lets be very conservative for now.

[PATCH net-next-2.6] r8169: Fix rtl8169_rx_interrupt()

In case a reset is performed, rtl8169_rx_interrupt() is called from
process context instead of softirq context. Special care must be taken
to call appropriate network core services (netif_rx() instead of
netif_receive_skb()). VLAN handling also corrected.

Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Diagnosed-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/r8169.c |   22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 964305c..1dffe29 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1054,14 +1054,14 @@ static void rtl8169_vlan_rx_register(struct net=
_device *dev,
 }
=20
 static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDe=
sc *desc,
-			       struct sk_buff *skb)
+			       struct sk_buff *skb, int polling)
 {
 	u32 opts2 =3D le32_to_cpu(desc->opts2);
 	struct vlan_group *vlgrp =3D tp->vlgrp;
 	int ret;
=20
 	if (vlgrp && (opts2 & RxVlanTag)) {
-		vlan_hwaccel_receive_skb(skb, vlgrp, swab16(opts2 & 0xffff));
+		__vlan_hwaccel_rx(skb, vlgrp, swab16(opts2 & 0xffff), polling);
 		ret =3D 0;
 	} else
 		ret =3D -1;
@@ -1078,7 +1078,7 @@ static inline u32 rtl8169_tx_vlan_tag(struct rtl8=
169_private *tp,
 }
=20
 static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDe=
sc *desc,
-			       struct sk_buff *skb)
+			       struct sk_buff *skb, int polling)
 {
 	return -1;
 }
@@ -4467,12 +4467,20 @@ out:
 	return done;
 }
=20
+/*
+ * Warning : rtl8169_rx_interrupt() might be called :
+ * 1) from NAPI (softirq) context
+ *	(polling =3D 1 : we should call netif_receive_skb())
+ * 2) from process context (rtl8169_reset_task())
+ *	(polling =3D 0 : we must call netif_rx() instead)
+ */	=09
 static int rtl8169_rx_interrupt(struct net_device *dev,
 				struct rtl8169_private *tp,
 				void __iomem *ioaddr, u32 budget)
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int delta, count;
+	int polling =3D (budget !=3D ~(u32)0) ? 1 : 0;
=20
 	cur_rx =3D tp->cur_rx;
 	rx_left =3D NUM_RX_DESC + tp->dirty_rx - cur_rx;
@@ -4534,8 +4542,12 @@ static int rtl8169_rx_interrupt(struct net_devic=
e *dev,
 			skb_put(skb, pkt_size);
 			skb->protocol =3D eth_type_trans(skb, dev);
=20
-			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
-				netif_receive_skb(skb);
+			if (rtl8169_rx_vlan_skb(tp, desc, skb, polling) < 0) {
+				if (likely(polling))
+					netif_receive_skb(skb);
+				else
+					netif_rx(skb);
+			}
=20
 			dev->stats.rx_bytes +=3D pkt_size;
 			dev->stats.rx_packets++;


