From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6] ipv6 fib: Use "Sweezle" to optimize addr_bit_test().
Date: Sat, 27 Mar 2010 20:24:16 +0900
Message-ID: <201003271124.o2RBOGjT006944@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45371 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378Ab0C0LYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 07:24:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addr_bit_test() is used in various places in IPv6 routing table
subsystem.  It checks if the given fn_bit is set,
where fn_bit counts bits from MSB in words in network-order.

 fn_bit        :   0 .... 31 32 .... 64 65 .... 95 96 ....127

fn_bit >> 5 gives offset of word, and (~fn_bit & 0x1f) gives
count from LSB in the network-endian word in question.

 fn_bit >> 5   :       0          1          2          3
 ~fn_bit & 0x1f:  31 ....  0 31 ....  0 31 ....  0 31 ....  0

Thus, the mask was generated as htonl(1 << (~fn_bit & 0x1f)).
This can be optimized by "sweezle" (See include/asm-generic/bitops/le.h).

In little-endian,
  htonl(1 << bit) = 1 << (bit ^ BITOP_BE32_SWIZZLE)
where
  BITOP_BE32_SWIZZLE is (0x1f & ~7)
So,
  htonl(1 << (~fn_bit & 0x1f)) = 1 << ((~fn_bit & 0x1f) ^ (0x1f & ~7))
                               = 1 << ((~fn_bit ^ ~7) & 0x1f)
                               = 1 << ((~fn_bit ^ BITOP_BE32_SWIZZLE) & 0x1f)

In big-endian, BITOP_BE32_SWIZZLE is equal to 0.
  1 << ((~fn_bit ^ BITOP_BE32_SWIZZLE) & 0x1f)
                               = 1 << ((~fn_bit) & 0x1f)
                               = htonl(1 << (~fn_bit & 0x1f))

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ip6_fib.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 2f98479..68119ef 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -127,12 +127,23 @@ static __inline__ u32 fib6_new_sernum(void)
 /*
  *	test bit
  */
+#if defined(__LITTLE_ENDIAN)
+# define BITOP_BE32_SWIZZLE	(0x1F & ~7)
+#else
+# define BITOP_BE32_SWIZZLE	0
+#endif
 
 static __inline__ __be32 addr_bit_set(void *token, int fn_bit)
 {
 	__be32 *addr = token;
-
-	return htonl(1 << ((~fn_bit)&0x1F)) & addr[fn_bit>>5];
+	/*
+	 * Here,
+	 * 	1 << ((~fn_bit ^ BITOP_BE32_SWIZZLE) & 0x1f)
+	 * is optimized version of
+	 *	htonl(1 << ((~fn_bit)&0x1F))
+	 * See include/asm-generic/bitops/le.h.
+	 */
+	return (1 << ((~fn_bit ^ BITOP_BE32_SWIZZLE) & 0x1f)) & addr[fn_bit >> 5];
 }
 
 static __inline__ struct fib6_node * node_alloc(void)
-- 
1.5.6.5

