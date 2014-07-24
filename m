From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 2/9] inet: frag: remove hash size assumptions from callers
Date: Thu, 24 Jul 2014 16:50:30 +0200
Message-ID: <1406213437-6155-3-git-send-email-nikolay@redhat.com>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933322AbaGXOv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:51:59 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

hide actual hash size from individual users: The _find
function will now fold the given hash value into the required range.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ieee802154/reassembly.c             | 12 ++++--------
 net/ipv4/inet_fragment.c                | 13 ++++++++++---
 net/ipv4/ip_fragment.c                  |  2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |  7 ++-----
 net/ipv6/reassembly.c                   |  8 ++------
 5 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index a5588be18024..a707995fd4d7 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -50,15 +50,11 @@ static unsigned int lowpan_hash_frag(__be16 tag, u16 d_size,
 				     const struct ieee802154_addr *saddr,
 				     const struct ieee802154_addr *daddr)
 {
-	u32 c;
-
 	net_get_random_once(&lowpan_frags.rnd, sizeof(lowpan_frags.rnd));
-	c = jhash_3words(ieee802154_addr_hash(saddr),
-			 ieee802154_addr_hash(daddr),
-			 (__force u32)(tag + (d_size << 16)),
-			 lowpan_frags.rnd);
-
-	return c & (INETFRAGS_HASHSZ - 1);
+	return jhash_3words(ieee802154_addr_hash(saddr),
+			    ieee802154_addr_hash(daddr),
+			    (__force u32)(tag + (d_size << 16)),
+			    lowpan_frags.rnd);
 }
 
 static unsigned int lowpan_hashfn(const struct inet_frag_queue *q)
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 3b01959bf4bb..930d23870811 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -46,6 +46,12 @@ const u8 ip_frag_ecn_table[16] = {
 };
 EXPORT_SYMBOL(ip_frag_ecn_table);
 
+static unsigned int
+inet_frag_hashfn(const struct inet_frags *f, const struct inet_frag_queue *q)
+{
+	return f->hashfn(q) & (INETFRAGS_HASHSZ - 1);
+}
+
 static void inet_frag_secret_rebuild(unsigned long dummy)
 {
 	struct inet_frags *f = (struct inet_frags *)dummy;
@@ -63,7 +69,7 @@ static void inet_frag_secret_rebuild(unsigned long dummy)
 
 		hb = &f->hash[i];
 		hlist_for_each_entry_safe(q, n, &hb->chain, list) {
-			unsigned int hval = f->hashfn(q);
+			unsigned int hval = inet_frag_hashfn(f, q);
 
 			if (hval != i) {
 				struct inet_frag_bucket *hb_dest;
@@ -133,7 +139,7 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 	unsigned int hash;
 
 	read_lock(&f->lock);
-	hash = f->hashfn(fq);
+	hash = inet_frag_hashfn(f, fq);
 	hb = &f->hash[hash];
 
 	spin_lock(&hb->chain_lock);
@@ -252,7 +258,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 	 * the rnd seed, so we need to re-calculate the hash
 	 * chain. Fortunatelly the qp_in can be used to get one.
 	 */
-	hash = f->hashfn(qp_in);
+	hash = inet_frag_hashfn(f, qp_in);
 	hb = &f->hash[hash];
 	spin_lock(&hb->chain_lock);
 
@@ -326,6 +332,7 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	struct inet_frag_queue *q;
 	int depth = 0;
 
+	hash &= (INETFRAGS_HASHSZ - 1);
 	hb = &f->hash[hash];
 
 	spin_lock(&hb->chain_lock);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 586e6aaf9e6e..b769eb6c83c0 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -109,7 +109,7 @@ static unsigned int ipqhashfn(__be16 id, __be32 saddr, __be32 daddr, u8 prot)
 	net_get_random_once(&ip4_frags.rnd, sizeof(ip4_frags.rnd));
 	return jhash_3words((__force u32)id << 16 | prot,
 			    (__force u32)saddr, (__force u32)daddr,
-			    ip4_frags.rnd) & (INETFRAGS_HASHSZ - 1);
+			    ip4_frags.rnd);
 }
 
 static unsigned int ip4_hashfn(const struct inet_frag_queue *q)
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index c2c3f2116bc5..607e4a94ef41 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -147,12 +147,9 @@ static inline u8 ip6_frag_ecn(const struct ipv6hdr *ipv6h)
 static unsigned int nf_hash_frag(__be32 id, const struct in6_addr *saddr,
 				 const struct in6_addr *daddr)
 {
-	u32 c;
-
 	net_get_random_once(&nf_frags.rnd, sizeof(nf_frags.rnd));
-	c = jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
-			 (__force u32)id, nf_frags.rnd);
-	return c & (INETFRAGS_HASHSZ - 1);
+	return jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
+			    (__force u32)id, nf_frags.rnd);
 }
 
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 0c6932cc08cb..2b76549a1016 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -85,13 +85,9 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 static unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
 				    const struct in6_addr *daddr)
 {
-	u32 c;
-
 	net_get_random_once(&ip6_frags.rnd, sizeof(ip6_frags.rnd));
-	c = jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
-			 (__force u32)id, ip6_frags.rnd);
-
-	return c & (INETFRAGS_HASHSZ - 1);
+	return jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
+			    (__force u32)id, ip6_frags.rnd);
 }
 
 static unsigned int ip6_hashfn(const struct inet_frag_queue *q)
-- 
1.9.3
