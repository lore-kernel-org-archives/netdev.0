From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] ip: make IP identifiers less predictable
Date: Fri, 25 Jul 2014 21:50:40 +0200
Message-ID: <1406317840.3363.106.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeffrey Knockel <jeffk@cs.unm.edu>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:46871 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488AbaGYTuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 15:50:51 -0400
Received: by mail-we0-f176.google.com with SMTP id q58so4735832wes.21
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 12:50:49 -0700 (PDT)
In-Reply-To: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In "Counting Packets Sent Between Arbitrary Internet Hosts", Jeffrey and
Jedidiah describe ways exploiting linux IP identifier generation to
infer whether two machines are exchanging packets.

With commit 73f156a6e8c1 ("inetpeer: get rid of ip_id_count"), we
changed IP id generation, but this does not really prevent this
side-channel technique.

This patch adds a random amount of perturbation so that IP identifiers
for a given destination [1] are no longer monotonically increasing after
an idle period.

Note that prandom_u32_max(1) returns 0, so if generator is used at most
once per jiffy, this patch inserts no hole in the ID suite and do not
increase collision probability.

This is jiffies based, so in the worst case (HZ=1000), the id can
rollover after ~65 seconds of idle time, which should be fine.

We also change the hash used in __ip_select_ident() to not only hash
on daddr, but also saddr and protocol, so that ICMP probes can not be
used to infer information for other protocols.

If I ping the patched target, we can see ID are now hard to predict.

21:57:11.008086 IP (...)
    A > target: ICMP echo request, seq 1, length 64
21:57:11.010752 IP (... id 2081 ...)
    target > A: ICMP echo reply, seq 1, length 64

21:57:12.013133 IP (...)
    A > target: ICMP echo request, seq 2, length 64
21:57:12.015737 IP (... id 3039 ...)
    target > A: ICMP echo reply, seq 2, length 64

21:57:13.016580 IP (...)
    A > target: ICMP echo request, seq 3, length 64
21:57:13.019251 IP (... id 3437 ...)
    target > A: ICMP echo reply, seq 3, length 64

[1] TCP sessions uses a per flow ID generator not changed by this patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Jeffrey Knockel <jeffk@cs.unm.edu>
Reported-by: Jedidiah R. Crandall <crandall@cs.unm.edu>
Cc: Willy Tarreau <w@1wt.eu>
---
v2: add saddr & protocol to hash used in __ip_select_ident()
    add saddr & nexthdr to ipv6_select_ident()

 include/net/ip.h      |   11 +----------
 net/ipv4/route.c      |   32 +++++++++++++++++++++++++++++---
 net/ipv6/ip6_output.c |    4 +++-
 3 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0e795df05ec9..7596eb22e1ce 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -309,16 +309,7 @@ static inline unsigned int ip_skb_dst_mtu(const struct sk_buff *skb)
 	}
 }
 
-#define IP_IDENTS_SZ 2048u
-extern atomic_t *ip_idents;
-
-static inline u32 ip_idents_reserve(u32 hash, int segs)
-{
-	atomic_t *id_ptr = ip_idents + hash % IP_IDENTS_SZ;
-
-	return atomic_add_return(segs, id_ptr) - segs;
-}
-
+u32 ip_idents_reserve(u32 hash, int segs);
 void __ip_select_ident(struct iphdr *iph, int segs);
 
 static inline void ip_select_ident_segs(struct sk_buff *skb, struct sock *sk, int segs)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3162ea923ded..190199851c9a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -457,8 +457,31 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
 	return neigh_create(&arp_tbl, pkey, dev);
 }
 
-atomic_t *ip_idents __read_mostly;
-EXPORT_SYMBOL(ip_idents);
+#define IP_IDENTS_SZ 2048u
+struct ip_ident_bucket {
+	atomic_t	id;
+	u32		stamp32;
+};
+
+static struct ip_ident_bucket *ip_idents __read_mostly;
+
+/* In order to protect privacy, we add a perturbation to identifiers
+ * if one generator is seldom used. This makes hard for an attacker
+ * to infer how many packets were sent between two points in time.
+ */
+u32 ip_idents_reserve(u32 hash, int segs)
+{
+	struct ip_ident_bucket *bucket = ip_idents + hash % IP_IDENTS_SZ;
+	u32 old = ACCESS_ONCE(bucket->stamp32);
+	u32 now = (u32)jiffies;
+	u32 delta = 0;
+
+	if (old != now && cmpxchg(&bucket->stamp32, old, now) == old)
+		delta = prandom_u32_max(now - old);
+
+	return atomic_add_return(segs + delta, &bucket->id) - segs;
+}
+EXPORT_SYMBOL(ip_idents_reserve);
 
 void __ip_select_ident(struct iphdr *iph, int segs)
 {
@@ -467,7 +490,10 @@ void __ip_select_ident(struct iphdr *iph, int segs)
 
 	net_get_random_once(&ip_idents_hashrnd, sizeof(ip_idents_hashrnd));
 
-	hash = jhash_1word((__force u32)iph->daddr, ip_idents_hashrnd);
+	hash = jhash_3words((__force u32)iph->daddr,
+			    (__force u32)iph->saddr,
+			    iph->protocol,
+			    ip_idents_hashrnd);
 	id = ip_idents_reserve(hash, segs);
 	iph->id = htons(id);
 }
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cb9df0eb4023..73372e8016b9 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -545,6 +545,7 @@ static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
 
 	hash = __ipv6_addr_jhash(&rt->rt6i_dst.addr, ip6_idents_hashrnd);
+	hash ^= __ipv6_addr_jhash(&rt->rt6i_src.addr, fhdr->nexthdr);
 	id = ip_idents_reserve(hash, 1);
 	fhdr->identification = htonl(id);
 }
@@ -639,10 +640,10 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		skb_reset_network_header(skb);
 		memcpy(skb_network_header(skb), tmp_hdr, hlen);
 
-		ipv6_select_ident(fh, rt);
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
 		fh->frag_off = htons(IP6_MF);
+		ipv6_select_ident(fh, rt);
 		frag_id = fh->identification;
 
 		first_len = skb_pagelen(skb);
@@ -1092,6 +1093,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
 				     sizeof(struct frag_hdr)) & ~7;
 	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+	fhdr.nexthdr = IPPROTO_UDP;
 	ipv6_select_ident(&fhdr, rt);
 	skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
 
