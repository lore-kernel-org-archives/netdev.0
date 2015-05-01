From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: speedup ip_idents_reserve()
Date: Fri, 01 May 2015 10:37:49 -0700
Message-ID: <1430501869.3711.131.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36157 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbbEARhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 13:37:51 -0400
Received: by igblo3 with SMTP id lo3so43693352igb.1
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 10:37:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Under stress, ip_idents_reserve() is accessing a contended
cache line twice, with non optimal MESI transactions.

If we place timestamps in separate location, we reduce this
pressure by ~50% and allow atomic_add_return() to issue
a Request for Ownership.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/route.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a78540f28276..f7559cba4343 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -457,12 +457,9 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
 }
 
 #define IP_IDENTS_SZ 2048u
-struct ip_ident_bucket {
-	atomic_t	id;
-	u32		stamp32;
-};
 
-static struct ip_ident_bucket *ip_idents __read_mostly;
+static atomic_t *ip_idents __read_mostly;
+static u32 *ip_tstamps __read_mostly;
 
 /* In order to protect privacy, we add a perturbation to identifiers
  * if one generator is seldom used. This makes hard for an attacker
@@ -470,15 +467,16 @@ static struct ip_ident_bucket *ip_idents __read_mostly;
  */
 u32 ip_idents_reserve(u32 hash, int segs)
 {
-	struct ip_ident_bucket *bucket = ip_idents + hash % IP_IDENTS_SZ;
-	u32 old = ACCESS_ONCE(bucket->stamp32);
+	u32 *p_tstamp = ip_tstamps + hash % IP_IDENTS_SZ;
+	atomic_t *p_id = ip_idents + hash % IP_IDENTS_SZ;
+	u32 old = ACCESS_ONCE(*p_tstamp);
 	u32 now = (u32)jiffies;
 	u32 delta = 0;
 
-	if (old != now && cmpxchg(&bucket->stamp32, old, now) == old)
+	if (old != now && cmpxchg(p_tstamp, old, now) == old)
 		delta = prandom_u32_max(now - old);
 
-	return atomic_add_return(segs + delta, &bucket->id) - segs;
+	return atomic_add_return(segs + delta, p_id) - segs;
 }
 EXPORT_SYMBOL(ip_idents_reserve);
 
@@ -2741,6 +2739,10 @@ int __init ip_rt_init(void)
 
 	prandom_bytes(ip_idents, IP_IDENTS_SZ * sizeof(*ip_idents));
 
+	ip_tstamps = kcalloc(IP_IDENTS_SZ, sizeof(*ip_tstamps), GFP_KERNEL);
+	if (!ip_tstamps)
+		panic("IP: failed to allocate ip_tstamps\n");
+
 	for_each_possible_cpu(cpu) {
 		struct uncached_list *ul = &per_cpu(rt_uncached_list, cpu);
 
