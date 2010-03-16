From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Tue, 16 Mar 2010 19:48:04 +0100
Message-ID: <1268765284.2932.17.camel@edumazet-laptop>
References: <20100307192305.GA598@elte.hu>
	 <20100308125122.GA11242@redhat.com>
	 <1268686865.2824.4.camel@edumazet-laptop>
	 <1268699602.2824.14.camel@edumazet-laptop>
	 <20100316145914.GB3332@swordfish.minsk.epam.com>
	 <1268751933.3094.45.camel@edumazet-laptop>
	 <20100316151023.GC3332@swordfish.minsk.epam.com>
	 <1268752826.3094.48.camel@edumazet-laptop>
	 <20100316182619.GA3451@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100316182619.GA3451@swordfish>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 16 mars 2010 =C3=A0 20:26 +0200, Sergey Senozhatsky a =C3=A9cr=
it :
> Hello,
> Got it right now.
>=20
> System completely froze. Even SysRq didn't work.
> /*spin_lock deadlock?*/
>=20
> NOTE: I'm losing network constantly with pktgen tests

yes, every 12 seconds there is a reset because of fifo overflow

> [24208.010980] r8169 0000:02:00.0: eth0: link up
> [24220.010980] r8169 0000:02:00.0: eth0: link up
> [24232.011030] r8169 0000:02:00.0: eth0: link up
> [24340.010980] r8169 0000:02:00.0: eth0: link up
> [24352.010966] r8169 0000:02:00.0: eth0: link up
> [24364.010966] r8169 0000:02:00.0: eth0: link up
> [24376.010964] r8169 0000:02:00.0: eth0: link up
> [24388.010961] r8169 0000:02:00.0: eth0: link up
> [24400.010959] r8169 0000:02:00.0: eth0: link up
> [24412.010963] r8169 0000:02:00.0: eth0: link up
>=20
>=20
> Traces:
> [24600.625078] INFO: task events/0:9 blocked for more than 120 second=
s.
> [24600.625083] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" dis=
ables this message.
> [24600.625087] events/0      D 00001636     0     9      2 0x00000000
> [24600.625096]  f7085ebc 00000046 a87e9490 00001636 c1617cc0 c1617cc0=
 c1617cc0 c1617cc0
> [24600.625109]  f707c250 c1617cc0 c1617cc0 00000000 00000000 00000000=
 00000000 f707bfc0
> [24600.625122]  c14745c8 c14745c8 f707bfc0 00000202 f7085efc c12c6449=
 00000000 00085edc
> [24600.625135] Call Trace:
> [24600.625148]  [<c12c6449>] __mutex_lock_common+0x233/0x3af
> [24600.625155]  [<c12c65ff>] mutex_lock_nested+0x12/0x15
> [24600.625163]  [<c1265e0f>] ? rtnl_lock+0xf/0x11
> [24600.625168]  [<c1265e0f>] rtnl_lock+0xf/0x11
> [24600.625183]  [<f9174acd>] rtl8169_reset_task+0x16/0xee [r8169]
> [24600.625191]  [<c103c887>] worker_thread+0x161/0x233
> [24600.625196]  [<c103c845>] ? worker_thread+0x11f/0x233
> [24600.625205]  [<f9174ab7>] ? rtl8169_reset_task+0x0/0xee [r8169]
> [24600.625214]  [<c103f9f1>] ? autoremove_wake_function+0x0/0x2f
> [24600.625220]  [<c103c726>] ? worker_thread+0x0/0x233
> [24600.625225]  [<c103f6ce>] kthread+0x6a/0x6f
> [24600.625232]  [<c103f664>] ? kthread+0x0/0x6f
> [24600.625238]  [<c1002e42>] kernel_thread_helper+0x6/0x1a
> [24600.625242] INFO: lockdep is turned off.
> [24600.625259] INFO: task X:3176 blocked for more than 120 seconds.
> [24600.625262] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" dis=
ables this message.
> [24600.625266] X             D 00000000     0  3176   3175 0x00400004
> [24600.625273]  f6435a10 00003046 00025709 00000000 c1617cc0 c1617cc0=
 c1617cc0 c1617cc0
> [24600.625286]  f60897d0 c1617c  ...=20
> /*THE REST IS LOST*/
>=20
>=20

OK thanks for the report, this rtl8169_reset_task() seems pretty buggy,
or multiple invocation...

Did you tried removing the rtl8169_schedule_work() call from
rtl8169_rx_interrupt() ?

Maybe the reset is not necessary at all in case of fifo overflow..

Cumulative patch :

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9d3ebf3..d6ef4dd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1038,14 +1038,14 @@ static void rtl8169_vlan_rx_register(struct net=
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
@@ -1062,7 +1062,7 @@ static inline u32 rtl8169_tx_vlan_tag(struct rtl8=
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
@@ -4429,12 +4429,20 @@ out:
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
@@ -4459,7 +4467,6 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
 			if (status & RxCRC)
 				dev->stats.rx_crc_errors++;
 			if (status & RxFOVF) {
-				rtl8169_schedule_work(dev, rtl8169_reset_task);
 				dev->stats.rx_fifo_errors++;
 			}
 			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
@@ -4496,8 +4503,12 @@ static int rtl8169_rx_interrupt(struct net_devic=
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
