From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 01:50:04 +0200
Message-ID: <20080730235004.GC21999@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ashish Karkare <akarkare@marvell.com>, Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44071 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912AbYG3XuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:50:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been doing some network throughput tests with a NIC (mv643xx_eth)
that does not support TSO/GSO in hardware.  The host CPU is an ARM CPU
that is pretty fast as far as ARM CPUs go (1.2 GHz), but not so fast
when compared to x86s.

When using sendfile() to send a GiB worth of zeroes over a single TCP
connection to another host on a 100 Mb/s network, with a vanilla
2.6.27-rc1 kernel, this runs as expected at wire speed, taking the
following amount of CPU time per test:

	sys     0m5.410s
	sys     0m5.380s
	sys     0m5.620s
	sys     0m5.360s


With this patch:

	Index: linux-2.6.27-rc1/include/net/sock.h
	===================================================================
	--- linux-2.6.27-rc1.orig/include/net/sock.h
	+++ linux-2.6.27-rc1/include/net/sock.h
	@@ -1085,7 +1085,8 @@ extern struct dst_entry *sk_dst_check(st
	 
	 static inline int sk_can_gso(const struct sock *sk)
	 {
	-	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
	+//	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
	+	return 1;
	 }
	 
	 extern void sk_setup_caps(struct sock *sk, struct dst_entry *dst);

The CPU utilisation numbers drop to:

	sys     0m3.280s
	sys     0m3.230s
	sys     0m3.220s
	sys     0m3.350s

Putting some debug code in net/core/dev.c:dev_hard_start_xmit(), I can
see that pretty much all of the segments that enter there to be GSOd in
software are full-sized (64 KiB-ish).


When the ethernet link is in 1000 Mb/s mode, the test seems CPU-bound,
and things look a little different.  With vanilla 2.6.27-rc1, I get
these numbers for the same 1 GiB sendfile() test, where real time ~=
sys time:

	sys     0m18.200s
	sys     0m18.260s
	sys     0m17.830s
	sys     0m17.670s
	sys     0m17.840s
	sys     0m17.670s
	sys     0m17.300s
	sys     0m17.860s
	sys     0m18.260s
	sys     0m17.150s
	sys     0m17.950s

With the patch above applied once again, I get:

	real    0m16.319s       sys     0m13.930s
	real    0m15.680s       sys     0m14.900s
	real    0m15.538s       sys     0m10.410s
	real    0m15.325s       sys     0m8.440s
	real    0m16.147s       sys     0m12.680s
	real    0m15.549s       sys     0m12.840s
	real    0m15.667s       sys     0m13.860s
	real    0m15.509s       sys     0m14.980s
	real    0m15.237s       sys     0m10.850s

While the wall clock time isn't much improved (hitting some kind of
internal bus bandwidth or DMA latency limitation in the hardware?),
the system time is improved, although the improvement is jittery.


In general, when the link is at 1000 Mb/s, skb_shinfo(skb)->gso_segs
of 99.99% of the skbs sent to net/core/dev.c:dev_hard_start_xmit()
is either 2 or 3 in dev_hard_start_xmit() (which seems to be cwnd
limited), unlike the 44 I see when the link is in 100 Mb/s mode.

I.e. with the patch below, 100 Mb/s, the output during steady state
is always something like this, i.e. skb_shinfo(skb)->gso_segs is
always 44:

	Jul 31 00:12:59 kw kernel: 10k seg: 44:10000
	Jul 31 00:12:59 kw kernel: 10k size: 127:10000
	Jul 31 00:13:00 kw kernel: 10k seg: 44:10000
	Jul 31 00:13:00 kw kernel: 10k size: 127:10000
	Jul 31 00:13:02 kw kernel: 10k seg: 44:10000
	Jul 31 00:13:02 kw kernel: 10k size: 127:10000
	Jul 31 00:13:04 kw kernel: 10k seg: 44:10000
	Jul 31 00:13:04 kw kernel: 10k size: 127:10000
	Jul 31 00:13:05 kw kernel: 10k seg: 44:10000
	Jul 31 00:13:05 kw kernel: 10k size: 127:10000

With the same patch, 1000 Mb/s, the output is something like this (the
2-seg:3-seg ratio varies between runs but is typically pretty constant
within the same run, this is from one particular run):

	Jul 31 00:57:56 kw kernel: 10k seg: 2:4592 3:5408 
	Jul 31 00:57:56 kw kernel: 10k size: 5:4592 8:5408 
	Jul 31 00:57:56 kw kernel: 10k seg: 2:4513 3:5487 
	Jul 31 00:57:56 kw kernel: 10k size: 5:4513 8:5487 
	Jul 31 00:57:57 kw kernel: 10k seg: 2:4575 3:5425 
	Jul 31 00:57:57 kw kernel: 10k size: 5:4575 8:5425 
	Jul 31 00:57:58 kw kernel: 10k seg: 2:4569 3:5431 
	Jul 31 00:57:58 kw kernel: 10k size: 5:4569 8:5431 
	Jul 31 00:57:58 kw kernel: 10k seg: 2:4581 3:5419 
	Jul 31 00:57:58 kw kernel: 10k size: 5:4581 8:5419
	Jul 31 00:57:59 kw kernel: 10k seg: 2:4583 3:5417
	Jul 31 00:57:59 kw kernel: 10k size: 5:4583 8:5417


Given this, I'm wondering about the following:

1. Considering the drop in CPU utilisation, are there reasons not
   to use software GSO on non-hardware-GSO-capable netdevices (apart
   from GSO possibly confusing tcpdump/iptables/qdiscs/etc)?

2. Why is the number of cycles necessary to send 1 GiB of data so
   much higher (~3.5x higher) in 1000 Mb/s mode than in 100 Mb/s mode?
   (Is this maybe just because time(1) is inaccurate w.r.t. time spent
   in interrupts and such?)

3. Why does dev_hard_start_xmit() get sent 64 KiB segments when the
   link is in 100 Mb/s mode but gso_segs never grows beyond 3 when
   the link is in 1000 Mb/s mode?


Any more thoughts about this or things I can try?  Any other ideas
to speed up the 1000 Mb/s case?


thanks,
Lennert




Index: linux-2.6.27-rc1/net/core/dev.c
===================================================================
--- linux-2.6.27-rc1.orig/net/core/dev.c
+++ linux-2.6.27-rc1/net/core/dev.c
@@ -1633,6 +1633,58 @@ int dev_hard_start_xmit(struct sk_buff *
 	}
 
 gso:
+	if (1) {
+		static int samples;
+		static int segment_histo[45];
+		int segments = 0;
+
+		segments = skb_shinfo(skb)->gso_segs;
+		if (segments > 44)
+			segments = 44;
+		segment_histo[segments]++;
+
+		if (++samples == 10000) {
+			int i;
+
+			samples = 0;
+
+			printk(KERN_CRIT "10k seg: ");
+			for (i = 0; i < 45; i++) {
+				if (segment_histo[i]) {
+					printk("%d:%d ", i, segment_histo[i]);
+					segment_histo[i] = 0;
+				}
+			}
+			printk("\n");
+		}
+	}
+
+	if (1) {
+		static int samples;
+		static int size_histo[150];
+		int len = 0;
+
+		len = skb->len >> 9;
+		if (len > 149)
+			len = 149;
+		size_histo[len]++;
+
+		if (++samples == 10000) {
+			int i;
+
+			samples = 0;
+
+			printk(KERN_CRIT "10k size: ");
+			for (i = 0; i < 150; i++) {
+				if (size_histo[i]) {
+					printk("%d:%d ", i, size_histo[i]);
+					size_histo[i] = 0;
+				}
+			}
+			printk("\n");
+		}
+	}
+
 	do {
 		struct sk_buff *nskb = skb->next;
 		int rc;
