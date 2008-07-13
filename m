From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [bisected] kernel panic 2.6.22 -> 2.6.26-rc9+
Date: Sun, 13 Jul 2008 02:28:13 +0200
Message-ID: <m3d4lisk4i.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753905AbYGMA23@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Bisected the panic. It seems it occurs on my ARM IXP4xx big-endian
system with USB ADSL PPP over ATM connection (Thomson/Alcatel
Speedtouch). It doesn't seem to occur on the same IXP4xx with Ethernet
or V.35 WAN, and it doesn't occur on i386 + the same Speedtouch ADSL.
The kernel is basically unpatched, the only extra patch applied is the
platform support (nothing magic).

Generally to trigger the panic one has to request a TCP data stream
over that PPPoATM connection.

Reverting the commit on top of 2.6.25.10 fixes the problem.

Now what's wrong with that?

7e58886b45bc4a309aeaa8178ef89ff767daaf7f:
author Stephen Hemminger <shemminger@linux-foundation.org>
[TCP]: cubic optimization

Use willy's work in optimizing cube root by having table for small values.

--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -91,23 +91,51 @@ static void bictcp_init(struct sock *sk)
 		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
 }
 
-/*
- * calculate the cubic root of x using Newton-Raphson
+/* calculate the cubic root of x using a table lookup followed by one
+ * Newton-Raphson iteration.
+ * Avg err ~= 0.195%
  */
 static u32 cubic_root(u64 a)
 {
-	u32 x;
-
-	/* Initial estimate is based on:
-	 * cbrt(x) = exp(log(x) / 3)
+	u32 x, b, shift;
+	/*
+	 * cbrt(x) MSB values for x MSB values in [0..63].
+	 * Precomputed then refined by hand - Willy Tarreau
+	 *
+	 * For x in [0..63],
+	 *   v = cbrt(x << 18) - 1
+	 *   cbrt(x) = (v[x] + 10) >> 6
 	 */
-	x = 1u << (fls64(a)/3);
+	static const u8 v[] = {
+		/* 0x00 */    0,   54,   54,   54,  118,  118,  118,  118,
+		/* 0x08 */  123,  129,  134,  138,  143,  147,  151,  156,
+		/* 0x10 */  157,  161,  164,  168,  170,  173,  176,  179,
+		/* 0x18 */  181,  185,  187,  190,  192,  194,  197,  199,
+		/* 0x20 */  200,  202,  204,  206,  209,  211,  213,  215,
+		/* 0x28 */  217,  219,  221,  222,  224,  225,  227,  229,
+		/* 0x30 */  231,  232,  234,  236,  237,  239,  240,  242,
+		/* 0x38 */  244,  245,  246,  248,  250,  251,  252,  254,
+	};
+
+	b = fls64(a);
+	if (b < 7) {
+		/* a in [0..63] */
+		return ((u32)v[(u32)a] + 35) >> 6;
+	}
+
+	b = ((b * 84) >> 8) - 1;
+	shift = (a >> (b * 3));
 
-	/* converges to 32 bits in 3 iterations */
-	x = (2 * x + (u32)div64_64(a, (u64)x*(u64)x)) / 3;
-	x = (2 * x + (u32)div64_64(a, (u64)x*(u64)x)) / 3;
-	x = (2 * x + (u32)div64_64(a, (u64)x*(u64)x)) / 3;
+	x = ((u32)(((u32)v[shift] + 10) << b)) >> 6;
 
+	/*
+	 * Newton-Raphson iteration
+	 *                         2
+	 * x    = ( 2 * x  +  a / x  ) / 3
+	 *  k+1          k         k
+	 */
+	x = (2 * x + (u32)div64_64(a, (u64)x * (u64)(x - 1)));
+	x = ((x * 341) >> 10);
 	return x;
 }
 
PC is at bictcp_cong_avoid+0x33c/0x454

Backtrace:

bictcp_cong_avoid+0x0/0x454		from tcp_cong_avoid+0x1c/0x30
tcp_cong_avoid+0x0/0x30			from tcp_ack+0x156c/0x1c6c
	r4:00000000
tcp_ack+0x0/0x1c6c			from tcp_rcv_established+0x4a8/0x76c
tcp_rcv_established+0x0/0x76c		from tcp_v4_do_rcv+0x25c/0x458
tcp_v4_do_rcv+0x0/0x458			from tcp_v4_rcv+0x6c4/0x7ec
tcp_v4_rcv+0x0/0x7ec			from ip_local_deliver_finish+0xe4/0x24c
ip_local_deliver_finish+0x0/0x24c	from ip_local_deliver+0x4c/0xac
	r7:c043817c r6:c6818612 r5:c6a6a3c0 r4:c6a6a3c0
ip_local_deliver+0x0/0xac		from ip_rcv_finish+0x114/0x378
	r4:80000000
ip_rcv_finish+0x0/0x378			from ip_rcv+0x1f8/0x2a8
ip_rcv+0x0/0x2a8			from netif_receive_skb+0x36c/0x4a4
	r7:00000800 r6:c0405e80 r5:c6a6a3c0 r4:c0436d54
netif_receive_skb+0x0/0x4a4		from process_backlog+0x88/0x14c
	r8:00000040 r7:c0436d24 r6:00000000 r5:c0436d0c r4:c6912c00
process_backlog+0x0/0x14c		from net_rx_action+0xb4/0x1c4
net_rx_action+0x0/0x1c4			from __do_softirq+0x68/0xe0
_do_softirq+0x0/0xe0			from irq_exit+0x48/0x50
	r7:00000000 r6:c04344d0 r5:c040ae24 r4:00000014
irq_exit+0x0/0x50			from asm_do_IRQ+0x48/0x5c
asm_do_IRQ+0x0/0x5c			from __irq_svc+0x24/0x60
...
-- 
Krzysztof Halasa
