From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] igmp: fix new sparse errors
Date: Wed, 12 Jun 2013 14:11:16 -0700
Message-ID: <1371071476.3252.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:44661 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756198Ab3FLVLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 17:11:21 -0400
Received: by mail-ee0-f47.google.com with SMTP id e49so4613503eek.6
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 14:11:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fix following sparse errors :

net/ipv4/igmp.c:1222:25: warning: cast from restricted __be32
net/ipv4/igmp.c:1234:31: warning: incorrect type in assignment (different address spaces)
net/ipv4/igmp.c:1234:31:    expected struct ip_mc_list [noderef] <asn:4>*next_hash
net/ipv4/igmp.c:1234:31:    got struct ip_mc_list *<noident>
net/ipv4/igmp.c:1250:31: warning: incorrect type in assignment (different address spaces)
net/ipv4/igmp.c:1250:31:    expected struct ip_mc_list [noderef] <asn:4>*next_hash
net/ipv4/igmp.c:1250:31:    got struct ip_mc_list *<noident>
net/ipv4/igmp.c:2380:37: warning: cast from restricted __be32

These were added by commit e9897071350bd9
("igmp: hash a hash table to speedup ip_check_mc_rcu()")

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/igmp.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index a09190d..cd71190 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1219,7 +1219,7 @@ static void igmp_group_added(struct ip_mc_list *im)
 
 static u32 ip_mc_hash(const struct ip_mc_list *im)
 {
-	return hash_32((u32)im->multiaddr, MC_HASH_SZ_LOG);
+	return hash_32((__force u32)im->multiaddr, MC_HASH_SZ_LOG);
 }
 
 static void ip_mc_hash_add(struct in_device *in_dev,
@@ -1231,7 +1231,7 @@ static void ip_mc_hash_add(struct in_device *in_dev,
 	mc_hash = rtnl_dereference(in_dev->mc_hash);
 	if (mc_hash) {
 		hash = ip_mc_hash(im);
-		im->next_hash = rtnl_dereference(mc_hash[hash]);
+		im->next_hash = mc_hash[hash];
 		rcu_assign_pointer(mc_hash[hash], im);
 		return;
 	}
@@ -1247,7 +1247,7 @@ static void ip_mc_hash_add(struct in_device *in_dev,
 
 	for_each_pmc_rtnl(in_dev, im) {
 		hash = ip_mc_hash(im);
-		im->next_hash = rtnl_dereference(mc_hash[hash]);
+		im->next_hash = mc_hash[hash];
 		RCU_INIT_POINTER(mc_hash[hash], im);
 	}
 
@@ -2377,7 +2377,7 @@ int ip_check_mc_rcu(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u
 
 	mc_hash = rcu_dereference(in_dev->mc_hash);
 	if (mc_hash) {
-		u32 hash = hash_32((u32)mc_addr, MC_HASH_SZ_LOG);
+		u32 hash = hash_32((__force u32)mc_addr, MC_HASH_SZ_LOG);
 
 		for (im = rcu_dereference(mc_hash[hash]);
 		     im != NULL;
