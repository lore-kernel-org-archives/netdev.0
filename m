From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] add compare_ether_addr_unaligned
Date: Fri, 23 Nov 2007 00:09:22 +0000 (GMT)
Message-ID: <20071123000922.C44009D4A1F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from queueout03-winn.ispmail.ntl.com ([81.103.221.33]:50667 "EHLO
	queueout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750984AbXKWA2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 19:28:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller found a problem in a wireless driver where I was using
compare_ether_addr() on potentially unaligned data. Document that
compare_ether_addr() is not safe for use everywhere, and add an equivalent
function that works regardless of alignment.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux-2.6.24-rc3-git1/include/linux/etherdevice.h
===================================================================
--- linux-2.6.24-rc3-git1.orig/include/linux/etherdevice.h
+++ linux-2.6.24-rc3-git1/include/linux/etherdevice.h
@@ -123,11 +123,13 @@ static inline void random_ether_addr(u8 
 }
 
 /**
- * compare_ether_addr - Compare two Ethernet addresses
+ * compare_ether_addr - Compare two 16-bit-aligned Ethernet addresses
  * @addr1: Pointer to a six-byte array containing the Ethernet address
  * @addr2: Pointer other six-byte array containing the Ethernet address
  *
- * Compare two ethernet addresses, returns 0 if equal
+ * Compare two ethernet addresses, returns 0 if equal. Both addresses must
+ * be 16-bit aligned. For unaligned or potentially unaligned address
+ * comparisons, use compare_ether_addr_unaligned() instead.
  */
 static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
 {
@@ -137,6 +139,21 @@ static inline unsigned compare_ether_add
 	BUILD_BUG_ON(ETH_ALEN != 6);
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
 }
+
+/**
+ * compare_ether_addr_unaligned - Compare two Ethernet addresses
+ * @addr1: Pointer to a six-byte array containing the Ethernet address
+ * @addr2: Pointer other six-byte array containing the Ethernet address
+ *
+ * Compare two ethernet addresses, returns 0 if equal. compare_ether_addr()
+ * is faster than this function, but unless you can ensure alignment you
+ * must use this function instead.
+ */
+static inline unsigned compare_ether_addr_unaligned(const u8 *addr1,
+						    const u8 *addr2)
+{
+	return memcmp(addr1, addr2, ETH_ALEN);
+}
 #endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_ETHERDEVICE_H */
