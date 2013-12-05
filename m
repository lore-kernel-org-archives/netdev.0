From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] ether_addr_equal: Optimize implementation, remove unused compare_ether_addr
Date: Thu,  5 Dec 2013 14:54:38 -0800
Message-ID: <34a0bad292ab2535a3a2e757a83eca13408e55b7.1386283991.git.joe@perches.com>
Cc: Rob Landley <rob@landley.net>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new check for CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS to reduce
the number of or's used in the ether_addr_equal comparison to very
slightly improve function performance.

Simplify the ether_addr_equal_64bits implementation.
Integrate and remove the zap_last_2bytes helper as it's now
used only once.

Remove the now unused compare_ether_addr function.

Update the unaligned-memory-access documentation to remove the
compare_ether_addr description and show how unaligned accesses
could occur with ether_addr_equal.

Signed-off-by: Joe Perches <joe@perches.com>
---
 Documentation/unaligned-memory-access.txt | 28 +++++++++++------
 include/linux/etherdevice.h               | 51 +++++++++++--------------------
 2 files changed, 37 insertions(+), 42 deletions(-)

diff --git a/Documentation/unaligned-memory-access.txt b/Documentation/unaligned-memory-access.txt
index f866c72..a445da0 100644
--- a/Documentation/unaligned-memory-access.txt
+++ b/Documentation/unaligned-memory-access.txt
@@ -137,24 +137,34 @@ Code that causes unaligned access
 =================================
 
 With the above in mind, let's move onto a real life example of a function
-that can cause an unaligned memory access. The following function adapted
+that can cause an unaligned memory access. The following function taken
 from include/linux/etherdevice.h is an optimized routine to compare two
 ethernet MAC addresses for equality.
 
-unsigned int compare_ether_addr(const u8 *addr1, const u8 *addr2)
+bool ether_addr_equal(const u8 *addr1, const u8 *addr2)
 {
-	const u16 *a = (const u16 *) addr1;
-	const u16 *b = (const u16 *) addr2;
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	u32 fold = ((*(const u32 *)addr1) ^ (*(const u32 *)addr2)) |
+		   ((*(const u16 *)(addr1 + 4)) ^ (*(const u16 *)(addr2 + 4)));
+
+	return fold == 0;
+#else
+	const u16 *a = (const u16 *)addr1;
+	const u16 *b = (const u16 *)addr2;
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
+#endif
 }
 
-In the above function, the reference to a[0] causes 2 bytes (16 bits) to
-be read from memory starting at address addr1. Think about what would happen
-if addr1 was an odd address such as 0x10003. (Hint: it'd be an unaligned
-access.)
+In the above function, when the hardware has efficient unaligned access
+capability, there is no issue with this code.  But when the hardware isn't
+able to access memory on arbitrary boundaries, the reference to a[0] causes
+2 bytes (16 bits) to be read from memory starting at address addr1.
+
+Think about what would happen if addr1 was an odd address such as 0x10003.
+(Hint: it'd be an unaligned access.)
 
 Despite the potential unaligned access problems with the above function, it
-is included in the kernel anyway but is understood to only work on
+is included in the kernel anyway but is understood to only work normally on
 16-bit-aligned addresses. It is up to the caller to ensure this alignment or
 not use this function at all. This alignment-unsafe function is still useful
 as it is a decent optimization for the cases when you can ensure alignment,
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index fc4a9aa..3526e81 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/random.h>
 #include <asm/unaligned.h>
+#include <asm/bitsperlong.h>
 
 #ifdef __KERNEL__
 __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev);
@@ -211,40 +212,26 @@ static inline void eth_hw_addr_inherit(struct net_device *dst,
 }
 
 /**
- * compare_ether_addr - Compare two Ethernet addresses
- * @addr1: Pointer to a six-byte array containing the Ethernet address
- * @addr2: Pointer other six-byte array containing the Ethernet address
- *
- * Compare two Ethernet addresses, returns 0 if equal, non-zero otherwise.
- * Unlike memcmp(), it doesn't return a value suitable for sorting.
- */
-static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
-{
-	const u16 *a = (const u16 *) addr1;
-	const u16 *b = (const u16 *) addr2;
-
-	BUILD_BUG_ON(ETH_ALEN != 6);
-	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;
-}
-
-/**
  * ether_addr_equal - Compare two Ethernet addresses
  * @addr1: Pointer to a six-byte array containing the Ethernet address
  * @addr2: Pointer other six-byte array containing the Ethernet address
  *
  * Compare two Ethernet addresses, returns true if equal
+ *
+ * Please note: addr1 & addr2 must both be aligned to u16.
  */
 static inline bool ether_addr_equal(const u8 *addr1, const u8 *addr2)
 {
-	return !compare_ether_addr(addr1, addr2);
-}
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	u32 fold = ((*(const u32 *)addr1) ^ (*(const u32 *)addr2)) |
+		   ((*(const u16 *)(addr1 + 4)) ^ (*(const u16 *)(addr2 + 4)));
 
-static inline unsigned long zap_last_2bytes(unsigned long value)
-{
-#ifdef __BIG_ENDIAN
-	return value >> 16;
+	return fold == 0;
 #else
-	return value << 16;
+	const u16 *a = (const u16 *)addr1;
+	const u16 *b = (const u16 *)addr2;
+
+	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) == 0;
 #endif
 }
 
@@ -265,16 +252,14 @@ static inline unsigned long zap_last_2bytes(unsigned long value)
 static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
 					   const u8 addr2[6+2])
 {
-#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-	unsigned long fold = ((*(unsigned long *)addr1) ^
-			      (*(unsigned long *)addr2));
-
-	if (sizeof(fold) == 8)
-		return zap_last_2bytes(fold) == 0;
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	u64 fold = (*(const u64 *)addr1) ^ (*(const u64 *)addr2);
 
-	fold |= zap_last_2bytes((*(unsigned long *)(addr1 + 4)) ^
-				(*(unsigned long *)(addr2 + 4)));
-	return fold == 0;
+#ifdef __BIG_ENDIAN
+	return (fold >> 16) == 0;
+#else
+	return (fold << 16) == 0;
+#endif
 #else
 	return ether_addr_equal(addr1, addr2);
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
