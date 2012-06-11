From: pablo@netfilter.org
Subject: [PATCH 19/25] netfilter: NFQUEUE: don't xor src/dst ip address for load distribution
Date: Mon, 11 Jun 2012 16:43:55 +0200
Message-ID: <1339425841-24171-20-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

because reply packets need to go to the same nfqueue, src/dst ip
address were xor'd prior to jhash().

However, this causes bad distribution for some workloads, e.g.
flows a.b.1.{1,n} -> a.b.2.{1,n} all share the same hash value.

Avoid this by hashing both. To get same hash for replies,
first argument is the smaller address.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_NFQUEUE.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 95237c8..7babe7d 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -41,26 +41,36 @@ nfqueue_tg(struct sk_buff *skb, const struct xt_action_param *par)
 static u32 hash_v4(const struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	__be32 ipaddr;
 
 	/* packets in either direction go into same queue */
-	ipaddr = iph->saddr ^ iph->daddr;
+	if (iph->saddr < iph->daddr)
+		return jhash_3words((__force u32)iph->saddr,
+			(__force u32)iph->daddr, iph->protocol, jhash_initval);
 
-	return jhash_2words((__force u32)ipaddr, iph->protocol, jhash_initval);
+	return jhash_3words((__force u32)iph->daddr,
+			(__force u32)iph->saddr, iph->protocol, jhash_initval);
 }
 
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static u32 hash_v6(const struct sk_buff *skb)
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
-	__be32 addr[4];
+	u32 a, b, c;
+
+	if (ip6h->saddr.s6_addr32[3] < ip6h->daddr.s6_addr32[3]) {
+		a = (__force u32) ip6h->saddr.s6_addr32[3];
+		b = (__force u32) ip6h->daddr.s6_addr32[3];
+	} else {
+		b = (__force u32) ip6h->saddr.s6_addr32[3];
+		a = (__force u32) ip6h->daddr.s6_addr32[3];
+	}
 
-	addr[0] = ip6h->saddr.s6_addr32[0] ^ ip6h->daddr.s6_addr32[0];
-	addr[1] = ip6h->saddr.s6_addr32[1] ^ ip6h->daddr.s6_addr32[1];
-	addr[2] = ip6h->saddr.s6_addr32[2] ^ ip6h->daddr.s6_addr32[2];
-	addr[3] = ip6h->saddr.s6_addr32[3] ^ ip6h->daddr.s6_addr32[3];
+	if (ip6h->saddr.s6_addr32[1] < ip6h->daddr.s6_addr32[1])
+		c = (__force u32) ip6h->saddr.s6_addr32[1];
+	else
+		c = (__force u32) ip6h->daddr.s6_addr32[1];
 
-	return jhash2((__force u32 *)addr, ARRAY_SIZE(addr), jhash_initval);
+	return jhash_3words(a, b, c, jhash_initval);
 }
 #endif
 
-- 
1.7.10

