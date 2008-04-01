From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/6] IPV4: route use jhash3
Date: Mon, 31 Mar 2008 17:47:13 -0700
Message-ID: <20080401004724.752793269@vyatta.com>
References: <20080401004708.009204033@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:40014 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755349AbYDACbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 22:31:34 -0400
Content-Disposition: inline; filename=route-jhash3
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since route hash is a triple, use jhash_3words rather doing the mixing
directly. This should be as fast and give better distribution.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/route.c	2008-03-31 11:14:50.000000000 -0700
+++ b/net/ipv4/route.c	2008-03-31 11:15:20.000000000 -0700
@@ -259,16 +259,14 @@ static DEFINE_PER_CPU(struct rt_cache_st
 #define RT_CACHE_STAT_INC(field) \
 	(__raw_get_cpu_var(rt_cache_stat).field++)
 
-static unsigned int rt_hash_code(u32 daddr, u32 saddr)
+static inline unsigned int rt_hash(__be32 daddr, __be32 saddr, int idx)
 {
-	return jhash_2words(daddr, saddr, atomic_read(&rt_genid))
-		& rt_hash_mask;
+	return jhash_3words((__force u32)(__be32)(daddr),
+			    (__force u32)(__be32)(saddr),
+			    idx, atomic_read(&rt_genid))
+  		& rt_hash_mask;
 }
 
-#define rt_hash(daddr, saddr, idx) \
-	rt_hash_code((__force u32)(__be32)(daddr),\
-		     (__force u32)(__be32)(saddr) ^ ((idx) << 5))
-
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
 	struct seq_net_private p;

-- 

