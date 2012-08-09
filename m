From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/5] net: Dont use ifindices in hash fns
Date: Thu, 09 Aug 2012 11:52:28 +0400
Message-ID: <50236C3C.3040305@parallels.com>
References: <50236C20.4050108@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1868 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755366Ab2HIHwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 03:52:40 -0400
In-Reply-To: <50236C20.4050108@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric noticed, that when there will be devices with equal indices, some
hash functions that use them will become less effective as they could.
Fix this in advance by mixing the net_device address into the hash value
instead of the device index.

This is true for arp and ndisc hash fns. The netlabel, can and llc ones
are also ifindex-based, but that three are init_net-only, thus will not
be affected.

Many thanks to David and Eric for the hash32_ptr implementation!

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/hash.h |   10 ++++++++++
 include/net/arp.h    |    3 ++-
 include/net/ndisc.h  |    3 ++-
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/hash.h b/include/linux/hash.h
index b80506b..24df9e7 100644
--- a/include/linux/hash.h
+++ b/include/linux/hash.h
@@ -67,4 +67,14 @@ static inline unsigned long hash_ptr(const void *ptr, unsigned int bits)
 {
 	return hash_long((unsigned long)ptr, bits);
 }
+
+static inline u32 hash32_ptr(const void *ptr)
+{
+	unsigned long val = (unsigned long)ptr;
+
+#if BITS_PER_LONG == 64
+	val ^= (val >> 32);
+#endif
+	return (u32)val;
+}
 #endif /* _LINUX_HASH_H */
diff --git a/include/net/arp.h b/include/net/arp.h
index 7f7df93..b630dae 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -3,6 +3,7 @@
 #define _ARP_H
 
 #include <linux/if_arp.h>
+#include <linux/hash.h>
 #include <net/neighbour.h>
 
 
@@ -10,7 +11,7 @@ extern struct neigh_table arp_tbl;
 
 static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd)
 {
-	u32 val = key ^ dev->ifindex;
+	u32 val = key ^ hash32_ptr(dev);
 
 	return val * hash_rnd;
 }
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 96a3b5c..980d263 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -49,6 +49,7 @@ enum {
 #include <linux/types.h>
 #include <linux/if_arp.h>
 #include <linux/netdevice.h>
+#include <linux/hash.h>
 
 #include <net/neighbour.h>
 
@@ -134,7 +135,7 @@ static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, _
 {
 	const u32 *p32 = pkey;
 
-	return (((p32[0] ^ dev->ifindex) * hash_rnd[0]) +
+	return (((p32[0] ^ hash32_ptr(dev)) * hash_rnd[0]) +
 		(p32[1] * hash_rnd[1]) +
 		(p32[2] * hash_rnd[2]) +
 		(p32[3] * hash_rnd[3]));
-- 
1.7.6.5
