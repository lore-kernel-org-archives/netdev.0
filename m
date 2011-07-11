From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Use universal hash for ARP.
Date: Mon, 11 Jul 2011 01:48:45 -0700 (PDT)
Message-ID: <20110711.014845.1009062692530385177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, mj@ucw.cz, netdev@vger.kernel.org
To: roland@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757440Ab1GKIs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 04:48:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We need to make sure the multiplier is odd.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/arp.h    |    7 +++++++
 net/core/neighbour.c |    1 +
 net/ipv4/arp.c       |    3 +--
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 91f0568..723bde5 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -8,6 +8,13 @@
 
 extern struct neigh_table arp_tbl;
 
+static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd)
+{
+	u32 val = key ^ dev->ifindex;
+
+	return val * hash_rnd;
+}
+
 extern void	arp_init(void);
 extern int	arp_find(unsigned char *haddr, struct sk_buff *skb);
 extern int	arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 4d5fc94..50bd960 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -334,6 +334,7 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int shift)
 	ret->hash_buckets = buckets;
 	ret->hash_shift = shift;
 	get_random_bytes(&ret->hash_rnd, sizeof(ret->hash_rnd));
+	ret->hash_rnd |= 1;
 	return ret;
 }
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1b74d3b..4412b57 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -97,7 +97,6 @@
 #include <linux/init.h>
 #include <linux/net.h>
 #include <linux/rcupdate.h>
-#include <linux/jhash.h>
 #include <linux/slab.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
@@ -232,7 +231,7 @@ static u32 arp_hash(const void *pkey,
 		    const struct net_device *dev,
 		    __u32 hash_rnd)
 {
-	return jhash_2words(*(u32 *)pkey, dev->ifindex, hash_rnd);
+	return arp_hashfn(*(u32 *)pkey, dev, hash_rnd);
 }
 
 static int arp_constructor(struct neighbour *neigh)
-- 
1.7.6

