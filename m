From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/6] hash: Introduce ptr_hash_mix routine
Date: Mon, 06 Aug 2012 18:13:47 +0400
Message-ID: <501FD11B.6000006@parallels.com>
References: <501FD0F2.4040609@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5771 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756074Ab2HFONx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 10:13:53 -0400
In-Reply-To: <501FD0F2.4040609@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one is used to make a salt out of a pointer to be mixed to some
hash function later. Idea and implementation are proposed by Eric Dumazet.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 include/linux/hash.h     |   10 ++++++++++
 include/net/netns/hash.h |    9 ++-------
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/hash.h b/include/linux/hash.h
index b80506b..1bd0ab1 100644
--- a/include/linux/hash.h
+++ b/include/linux/hash.h
@@ -14,6 +14,7 @@
  * machines where multiplications are slow.
  */
 
+#include <linux/cache.h>
 #include <asm/types.h>
 
 /* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
@@ -67,4 +68,13 @@ static inline unsigned long hash_ptr(const void *ptr, unsigned int bits)
 {
 	return hash_long((unsigned long)ptr, bits);
 }
+
+static inline u32 ptr_hash_mix(const void *ptr)
+{
+#if BITS_PER_LONG == 32
+	return (u32)(unsigned long)ptr;
+#else
+	return (u32)((unsigned long)ptr >> L1_CACHE_SHIFT);
+#endif
+}
 #endif /* _LINUX_HASH_H */
diff --git a/include/net/netns/hash.h b/include/net/netns/hash.h
index c06ac58..bcdabe0 100644
--- a/include/net/netns/hash.h
+++ b/include/net/netns/hash.h
@@ -1,19 +1,14 @@
 #ifndef __NET_NS_HASH_H__
 #define __NET_NS_HASH_H__
 
-#include <asm/cache.h>
+#include <linux/hash.h>
 
 struct net;
 
 static inline unsigned int net_hash_mix(struct net *net)
 {
 #ifdef CONFIG_NET_NS
-	/*
-	 * shift this right to eliminate bits, that are
-	 * always zeroed
-	 */
-
-	return (unsigned)(((unsigned long)net) >> L1_CACHE_SHIFT);
+	return ptr_hash_mix(net);
 #else
 	return 0;
 #endif
-- 
1.7.6.5
