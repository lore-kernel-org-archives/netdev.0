From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: speedup dst_release()
Date: Fri, 14 Nov 2008 09:09:31 +0100
Message-ID: <491D323B.9030802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010803000309050203030902"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46840 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbYKNIJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 03:09:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010803000309050203030902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

During tbench/oprofile sessions, I found that dst_release() was in third position.

CPU: Core 2, speed 2999.68 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        symbol name
483726    9.0185  __copy_user_zeroing_intel
191466    3.5697  __copy_user_intel
185475    3.4580  dst_release
175114    3.2648  ip_queue_xmit
153447    2.8608  tcp_sendmsg
108775    2.0280  tcp_recvmsg
102659    1.9140  sysenter_past_esp
101450    1.8914  tcp_current_mss
95067     1.7724  __copy_from_user_ll
86531     1.6133  tcp_transmit_skb

Of course, all CPUS fight on the dst_entry associated with 127.0.0.1 

Instead of first checking the refcount value, then decrement it,
we use atomic_dec_return() to help CPU to make the right memory transaction
(ie getting the cache line in exclusive mode)

dst_release() is now at the fifth position, and tbench a litle bit faster ;)

CPU: Core 2, speed 3000.1 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        symbol name
647107    8.8072  __copy_user_zeroing_intel
258840    3.5229  ip_queue_xmit
258302    3.5155  __copy_user_intel
209629    2.8531  tcp_sendmsg
165632    2.2543  dst_release
149232    2.0311  tcp_current_mss
147821    2.0119  tcp_recvmsg
137893    1.8767  sysenter_past_esp
127473    1.7349  __copy_from_user_ll
121308    1.6510  ip_finish_output
118510    1.6129  tcp_transmit_skb
109295    1.4875  tcp_v4_rcv

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------010803000309050203030902
Content-Type: text/plain;
 name="dst_release.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dst_release.patch"

diff --git a/net/core/dst.c b/net/core/dst.c
index 09c1530..07e5ad2 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -263,9 +263,11 @@ again:
 void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
-		WARN_ON(atomic_read(&dst->__refcnt) < 1);
+               int newrefcnt;
+
 		smp_mb__before_atomic_dec();
-		atomic_dec(&dst->__refcnt);
+               newrefcnt = atomic_dec_return(&dst->__refcnt);
+               WARN_ON(newrefcnt < 0);
 	}
 }
 EXPORT_SYMBOL(dst_release);

--------------010803000309050203030902--
