From: David Miller <davem@davemloft.net>
Subject: ipv4: Simplify ARP hash function.
Date: Fri, 08 Jul 2011 10:10:56 -0700 (PDT)
Message-ID: <20110708.101056.89960389404725087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab1GHRLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 13:11:01 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p68HAuVe022065
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 8 Jul 2011 10:10:57 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Using Jenkins is over the top.

If the premise is that the hash_rnd is a random unpredictable key,
then:

	key ^ dev->ifindex ^ hash_rnd

results in an unpredictable hash result, even if an attacker
controls 'key' and 'dev->ifindex' completely.

Therefore, if this hash result is unpredictable, then the
final fold phase of:

	(val >> 8) ^ (val >> 16) ^ (val >> 24)

is unpredictable as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Someone please check my logic :-) This sames ~100 cycles during a
neigh_lookup() on my Niagara2 box.

diff --git a/include/net/arp.h b/include/net/arp.h
index 91f0568..d570747 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -8,6 +8,13 @@
 
 extern struct neigh_table arp_tbl;
 
+static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd)
+{
+	u32 val = key ^ dev->ifindex ^ hash_rnd;
+
+	return (val >> 8) ^ (val >> 16) ^ (val >> 24);
+}
+
 extern void	arp_init(void);
 extern int	arp_find(unsigned char *haddr, struct sk_buff *skb);
 extern int	arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
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
