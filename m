From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v1 net-next] inetpeer: get rid of ip_id_count
Date: Sun, 01 Jun 2014 17:18:04 -0700
Message-ID: <1401668284.3645.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:39190 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbaFBASH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 20:18:07 -0400
Received: by mail-ie0-f180.google.com with SMTP id tp5so3826170ieb.39
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 17:18:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Ideally, we would need to generate IP ID using a per destination IP
generator.

linux kernels used inet_peer cache for this purpose, but this had a huge
cost on servers disabling MTU discovery.

1) each inet_peer struct consumes 192 bytes

2) inetpeer cache uses a binary tree of inet_peer structs,
   with a nominal size of ~66000 elements under load.

3) lookups in this tree are hitting a lot of cache lines, as tree depth
   is about 20.

4) If server deals with many tcp flows, we have a high probability of
   not finding the inet_peer, allocating a fresh one, inserting it in
   the tree with same initial ip_id_count, (cf secure_ip_id())

5) We garbage collect inet_peer aggressively.

IP ID generation do not have to be 'perfect'

Goal is trying to avoid duplicates in a short period of time,
so that reassembly units have a chance to complete reassembly of
fragments belonging to one message before receiving other fragments
with a recycled ID.

We simply use an array of generators, and a Jenkin hash using the dst IP
as a key.

ipv6_select_ident() is put back into net/ipv6/ip6_output.c where it
belongs (it is only used from this file)

secure_ip_id() and secure_ipv6_id() no longer are needed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note: Based on current net-next, but needs a respin or merge resolution
after other patch [1] is merged.

[1] : http://patchwork.ozlabs.org/patch/353788/

 include/net/inetpeer.h   |   23 ++----------------
 include/net/ip.h         |    3 ++
 include/net/ipv6.h       |    2 -
 include/net/secure_seq.h |    2 -
 net/core/secure_seq.c    |   25 --------------------
 net/ipv4/inetpeer.c      |   18 --------------
 net/ipv4/route.c         |   45 +++++++++++++------------------------
 net/ipv6/ip6_output.c    |   12 +++++++++
 net/ipv6/output_core.c   |   30 ------------------------
 9 files changed, 35 insertions(+), 125 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 6efe73c79c52..823ec7bb9c67 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -41,14 +41,13 @@ struct inet_peer {
 		struct rcu_head     gc_rcu;
 	};
 	/*
-	 * Once inet_peer is queued for deletion (refcnt == -1), following fields
-	 * are not available: rid, ip_id_count
+	 * Once inet_peer is queued for deletion (refcnt == -1), following field
+	 * is not available: rid
 	 * We can share memory with rcu_head to help keep inet_peer small.
 	 */
 	union {
 		struct {
 			atomic_t			rid;		/* Frag reception counter */
-			atomic_t			ip_id_count;	/* IP ID for the next packet */
 		};
 		struct rcu_head         rcu;
 		struct inet_peer	*gc_next;
@@ -165,7 +164,7 @@ bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 void inetpeer_invalidate_tree(struct inet_peer_base *);
 
 /*
- * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
+ * temporary check to make sure we dont access rid, tcp_ts,
  * tcp_ts_stamp if no refcount is taken on inet_peer
  */
 static inline void inet_peer_refcheck(const struct inet_peer *p)
@@ -173,20 +172,4 @@ static inline void inet_peer_refcheck(const struct inet_peer *p)
 	WARN_ON_ONCE(atomic_read(&p->refcnt) <= 0);
 }
 
-
-/* can be called with or without local BH being disabled */
-static inline int inet_getid(struct inet_peer *p, int more)
-{
-	int old, new;
-	more++;
-	inet_peer_refcheck(p);
-	do {
-		old = atomic_read(&p->ip_id_count);
-		new = old + more;
-		if (!new)
-			new = 1;
-	} while (atomic_cmpxchg(&p->ip_id_count, old, new) != old);
-	return new;
-}
-
 #endif /* _NET_INETPEER_H */
diff --git a/include/net/ip.h b/include/net/ip.h
index 2e4947895d75..c4d71d09a545 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -412,6 +412,9 @@ static inline void ip_ipgre_mc_map(__be32 naddr, const unsigned char *broadcast,
 #include <linux/ipv6.h>
 #endif
 
+#define IP_IDENTS_SZ 2048u
+extern atomic_t *ip_idents;
+
 static __inline__ void inet_reset_saddr(struct sock *sk)
 {
 	inet_sk(sk)->inet_rcv_saddr = inet_sk(sk)->inet_saddr = 0;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ba810d0546bc..574337fe72dd 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -668,8 +668,6 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
-void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
-
 int ip6_dst_hoplimit(struct dst_entry *dst);
 
 static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6 *fl6,
diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index f257486f17be..3f36d45b714a 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -3,8 +3,6 @@
 
 #include <linux/types.h>
 
-__u32 secure_ip_id(__be32 daddr);
-__u32 secure_ipv6_id(const __be32 daddr[4]);
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport);
 u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 			       __be16 dport);
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 897da56f3aff..ba71212f0251 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -85,31 +85,6 @@ EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
 
 #ifdef CONFIG_INET
-__u32 secure_ip_id(__be32 daddr)
-{
-	u32 hash[MD5_DIGEST_WORDS];
-
-	net_secret_init();
-	hash[0] = (__force __u32) daddr;
-	hash[1] = net_secret[13];
-	hash[2] = net_secret[14];
-	hash[3] = net_secret[15];
-
-	md5_transform(hash, net_secret);
-
-	return hash[0];
-}
-
-__u32 secure_ipv6_id(const __be32 daddr[4])
-{
-	__u32 hash[4];
-
-	net_secret_init();
-	memcpy(hash, daddr, 16);
-	md5_transform(hash, net_secret);
-
-	return hash[0];
-}
 
 __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 				 __be16 sport, __be16 dport)
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index c98cf141f4ed..4ced1b9a97f0 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -26,20 +26,7 @@
  *  Theory of operations.
  *  We keep one entry for each peer IP address.  The nodes contains long-living
  *  information about the peer which doesn't depend on routes.
- *  At this moment this information consists only of ID field for the next
- *  outgoing IP packet.  This field is incremented with each packet as encoded
- *  in inet_getid() function (include/net/inetpeer.h).
- *  At the moment of writing this notes identifier of IP packets is generated
- *  to be unpredictable using this code only for packets subjected
- *  (actually or potentially) to defragmentation.  I.e. DF packets less than
- *  PMTU in size when local fragmentation is disabled use a constant ID and do
- *  not use this code (see ip_select_ident() in include/net/ip.h).
  *
- *  Route cache entries hold references to our nodes.
- *  New cache entries get references via lookup by destination IP address in
- *  the avl tree.  The reference is grabbed only when it's needed i.e. only
- *  when we try to output IP packet which needs an unpredictable ID (see
- *  __ip_select_ident() in net/ipv4/route.c).
  *  Nodes are removed only when reference counter goes to 0.
  *  When it's happened the node may be removed when a sufficient amount of
  *  time has been passed since its last use.  The less-recently-used entry can
@@ -62,7 +49,6 @@
  *		refcnt: atomically against modifications on other CPU;
  *		   usually under some other lock to prevent node disappearing
  *		daddr: unchangeable
- *		ip_id_count: atomic value (no lock needed)
  */
 
 static struct kmem_cache *peer_cachep __read_mostly;
@@ -497,10 +483,6 @@ relookup:
 		p->daddr = *daddr;
 		atomic_set(&p->refcnt, 1);
 		atomic_set(&p->rid, 0);
-		atomic_set(&p->ip_id_count,
-				(daddr->family == AF_INET) ?
-					secure_ip_id(daddr->addr.a4) :
-					secure_ipv6_id(daddr->addr.a6));
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
 		/* 60*HZ is arbitrary, but chosen enough high so that the first
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4154eb76b0ad..f5c06587f3b5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -89,6 +89,7 @@
 #include <linux/rcupdate.h>
 #include <linux/times.h>
 #include <linux/slab.h>
+#include <linux/jhash.h>
 #include <net/dst.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
@@ -456,39 +457,21 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
 	return neigh_create(&arp_tbl, pkey, dev);
 }
 
-/*
- * Peer allocation may fail only in serious out-of-memory conditions.  However
- * we still can generate some output.
- * Random ID selection looks a bit dangerous because we have no chances to
- * select ID being unique in a reasonable period of time.
- * But broken packet identifier may be better than no packet at all.
- */
-static void ip_select_fb_ident(struct iphdr *iph)
-{
-	static DEFINE_SPINLOCK(ip_fb_id_lock);
-	static u32 ip_fallback_id;
-	u32 salt;
-
-	spin_lock_bh(&ip_fb_id_lock);
-	salt = secure_ip_id((__force __be32)ip_fallback_id ^ iph->daddr);
-	iph->id = htons(salt & 0xFFFF);
-	ip_fallback_id = salt;
-	spin_unlock_bh(&ip_fb_id_lock);
-}
+atomic_t *ip_idents __read_mostly;
+EXPORT_SYMBOL(ip_idents);
 
 void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more)
 {
-	struct net *net = dev_net(dst->dev);
-	struct inet_peer *peer;
+	static u32 ip_idents_hashrnd __read_mostly;
+	atomic_t *id_ptr;
+	u32 hash;
 
-	peer = inet_getpeer_v4(net->ipv4.peers, iph->daddr, 1);
-	if (peer) {
-		iph->id = htons(inet_getid(peer, more));
-		inet_putpeer(peer);
-		return;
-	}
+	net_get_random_once(&ip_idents_hashrnd, sizeof(ip_idents_hashrnd));
 
-	ip_select_fb_ident(iph);
+	hash = jhash_1word((__force u32)iph->daddr, ip_idents_hashrnd);
+	id_ptr = ip_idents + hash % IP_IDENTS_SZ;
+	more++;
+	iph->id = htons(atomic_add_return(more, id_ptr) - more);
 }
 EXPORT_SYMBOL(__ip_select_ident);
 
@@ -2711,6 +2694,12 @@ int __init ip_rt_init(void)
 {
 	int rc = 0;
 
+	ip_idents = kmalloc(IP_IDENTS_SZ * sizeof(*ip_idents), GFP_KERNEL);
+	if (!ip_idents)
+		panic("IP: failed to allocate ip_idents\n");
+
+	prandom_bytes(ip_idents, IP_IDENTS_SZ * sizeof(*ip_idents));
+
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	ip_rt_acct = __alloc_percpu(256 * sizeof(struct ip_rt_acct), __alignof__(struct ip_rt_acct));
 	if (!ip_rt_acct)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 85aaeca1f7f3..87075addae53 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -537,6 +537,18 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
+static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
+{
+	static u32 ip6_idents_hashrnd __read_mostly;
+	atomic_t *id_ptr;
+	u32 hash;
+
+	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
+	hash = __ipv6_addr_jhash(&rt->rt6i_dst.addr, ip6_idents_hashrnd);
+	id_ptr = ip_idents + hash % IP_IDENTS_SZ;
+	fhdr->identification = htonl(atomic_inc_return(id_ptr) - 1);
+}
+
 int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct sk_buff *frag;
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 6313abd53c9d..6179ac186ab9 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -8,36 +8,6 @@
 #include <net/addrconf.h>
 #include <net/secure_seq.h>
 
-void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
-{
-	static atomic_t ipv6_fragmentation_id;
-	struct in6_addr addr;
-	int old, new;
-
-#if IS_ENABLED(CONFIG_IPV6)
-	struct inet_peer *peer;
-	struct net *net;
-
-	net = dev_net(rt->dst.dev);
-	peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
-	if (peer) {
-		fhdr->identification = htonl(inet_getid(peer, 0));
-		inet_putpeer(peer);
-		return;
-	}
-#endif
-	do {
-		old = atomic_read(&ipv6_fragmentation_id);
-		new = old + 1;
-		if (!new)
-			new = 1;
-	} while (atomic_cmpxchg(&ipv6_fragmentation_id, old, new) != old);
-
-	addr = rt->rt6i_dst.addr;
-	addr.s6_addr32[0] ^= (__force __be32)new;
-	fhdr->identification = htonl(secure_ipv6_id(addr.s6_addr32));
-}
-EXPORT_SYMBOL(ipv6_select_ident);
 
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 {
