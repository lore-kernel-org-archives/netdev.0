From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/6] net: Dont use ifindices in hash fns
Date: Mon, 06 Aug 2012 18:14:07 +0400
Message-ID: <501FD12F.9080706@parallels.com>
References: <501FD0F2.4040609@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:13854 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756325Ab2HFOON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 10:14:13 -0400
In-Reply-To: <501FD0F2.4040609@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric noticed, that when there will be devices with equal indices, some
hash functions that use them will become less effective as they could.

Fix this in advance by taking the net_device address into calculations
instead of the device index. Since the net_device is always aligned in
memory, shift the pointer to eliminate always zero bits (like we do it
in net_hash_mix).

This is true for arp and ndisc hash fns. The netlabel, can and llc ones
are also ifindex-based, but that three are init_net-only, thus will not
be affected.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 include/net/arp.h   |    3 ++-
 include/net/ndisc.h |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 7f7df93..b9ce3a9 100644
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
+	u32 val = key ^ ptr_hash_mix(dev);
 
 	return val * hash_rnd;
 }
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 96a3b5c..a9b55b2 100644
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
+	return (((p32[0] ^ ptr_hash_mix(dev)) * hash_rnd[0]) +
 		(p32[1] * hash_rnd[1]) +
 		(p32[2] * hash_rnd[2]) +
 		(p32[3] * hash_rnd[3]));
-- 
1.7.6.5
