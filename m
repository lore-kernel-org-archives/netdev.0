From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] etherdevice: Optimize
 compare_ether_addr/ether_addr_equal
Date: Sat, 31 Aug 2013 01:54:16 -0700
Message-ID: <1377939256.2054.11.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42115 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752798Ab3HaIyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Aug 2013 04:54:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_HAS_EFFICIENT_UNALIGNED_ACCESS is set,
optimize compare_ether_addr a little by removing an
xor and or by using a u32 and u16 comparison
instead of 3 separate u16 comparisons.

Make the ether_addr_equal_64bits code a bit simpler
by adding a test for CONFIG_64BIT and calling
ether_addr_equal otherwise.

This also slightly improves ether_addr_equal_64bits
by removing the zap_last_2bytes shifts in the !64bit
case.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/etherdevice.h | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index c623861..2514d17 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -208,11 +208,19 @@ static inline void eth_hw_addr_random(struct net_device *dev)
  */
 static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	u32 fold = ((*(const u32 *)addr1) ^ (*(const u32 *)addr2));
+	fold |= ((*(const u16 *)(addr1 + 4)) ^ (*(const u16 *)(addr2 + 4)));
+
+	BUILD_BUG_ON(ETH_ALEN != 6);
+	return fold != 0;
+#else
 	const u16 *a = (const u16 *) addr1;
 	const u16 *b = (const u16 *) addr2;
 
 	BUILD_BUG_ON(ETH_ALEN != 6);
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
+#endif
 }
 
 /**
@@ -253,16 +261,11 @@ static inline unsigned long zap_last_2bytes(unsigned long value)
 static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
 					   const u8 addr2[6+2])
 {
-#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && defined(CONFIG_64BIT)
 	unsigned long fold = ((*(unsigned long *)addr1) ^
 			      (*(unsigned long *)addr2));
 
-	if (sizeof(fold) == 8)
-		return zap_last_2bytes(fold) == 0;
-
-	fold |= zap_last_2bytes((*(unsigned long *)(addr1 + 4)) ^
-				(*(unsigned long *)(addr2 + 4)));
-	return fold == 0;
+	return zap_last_2bytes(fold) == 0;
 #else
 	return ether_addr_equal(addr1, addr2);
 #endif
