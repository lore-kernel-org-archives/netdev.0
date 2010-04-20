From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Fix various endianness glitches
Date: Tue, 20 Apr 2010 15:18:24 +0200
Message-ID: <1271769504.7895.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:61198 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab0DTNSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 09:18:36 -0400
Received: by bwz19 with SMTP id 19so12602bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 06:18:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse can help us find endianness bugs, but we need to make some
cleanups to be able to more easily spot real bugs.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
net/bridge/br_multicast.c |    2 +-
net/bridge/br_private.h   |   15 ++++++++-------
net/ethernet/eth.c        |    2 +-
net/ipv4/af_inet.c        |    8 ++++----
net/ipv4/ipmr.c           |   10 +++++-----
net/ipv4/route.c          |   29 ++++++++++++++---------------
net/ipv4/tcp.c            |   15 ++++++++-------
net/ipv4/tcp_ipv4.c       |    4 ++--
net/ipv4/tcp_output.c     |    4 ++--
net/ipv4/udp.c            |    8 ++++----
net/ipv6/addrconf.c       |    3 ++-
net/ipv6/ip6_fib.c        |    3 ++-
net/ipv6/tcp_ipv6.c       |    4 ++--
net/ipv6/udp.c            |    4 ++--
net/sched/sch_sfq.c       |   10 +++++-----
net/sunrpc/xprt.c         |    2 +-
net/xfrm/xfrm_hash.h      |    3 ++-
17 files changed, 65 insertions(+), 61 deletions(-) 

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 3fe86ff..61e1d10 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -29,7 +29,7 @@
 
 static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
 {
-	return jhash_1word(mdb->secret, (u32)ip) & (mdb->max - 1);
+	return jhash_1word(mdb->secret, (__force u32)ip) & (mdb->max - 1);
 }
 
 static struct net_bridge_mdb_entry *__br_mdb_ip_get(
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 791d4ab..63181e4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -130,19 +130,20 @@ struct net_bridge_port
 #endif
 };
 
+struct br_cpu_netstats {
+	unsigned long	rx_packets;
+	unsigned long	rx_bytes;
+	unsigned long	tx_packets;
+	unsigned long	tx_bytes;
+};
+
 struct net_bridge
 {
 	spinlock_t			lock;
 	struct list_head		port_list;
 	struct net_device		*dev;
 
-	struct br_cpu_netstats __percpu {
-		unsigned long	rx_packets;
-		unsigned long	rx_bytes;
-		unsigned long	tx_packets;
-		unsigned long	tx_bytes;
-	} *stats;
-
+	struct br_cpu_netstats __percpu *stats;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 	unsigned long			feature_mask;
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 205a1c1..3584696 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -136,7 +136,7 @@ int eth_rebuild_header(struct sk_buff *skb)
 	default:
 		printk(KERN_DEBUG
 		       "%s: unable to resolve type %X addresses.\n",
-		       dev->name, (int)eth->h_proto);
+		       dev->name, (__force int)eth->h_proto);
 
 		memcpy(eth->h_source, dev->dev_addr, ETH_ALEN);
 		break;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c5376c7..cb0de78 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1323,8 +1323,8 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
 		goto out_unlock;
 
-	id = ntohl(*(u32 *)&iph->id);
-	flush = (u16)((ntohl(*(u32 *)iph) ^ skb_gro_len(skb)) | (id ^ IP_DF));
+	id = ntohl(*(__be32 *)&iph->id);
+	flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id ^ IP_DF));
 	id >>= 16;
 
 	for (p = *head; p; p = p->next) {
@@ -1337,8 +1337,8 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 
 		if ((iph->protocol ^ iph2->protocol) |
 		    (iph->tos ^ iph2->tos) |
-		    (iph->saddr ^ iph2->saddr) |
-		    (iph->daddr ^ iph2->daddr)) {
+		    ((__force u32)iph->saddr ^ (__force u32)iph2->saddr) |
+		    ((__force u32)iph->daddr ^ (__force u32)iph2->daddr)) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 7d8a2bc..a2df501 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1772,10 +1772,10 @@ int ip_mr_input(struct sk_buff *skb)
 
 		vif = ipmr_find_vif(mrt, skb->dev);
 		if (vif >= 0) {
-			int err = ipmr_cache_unresolved(mrt, vif, skb);
+			int err2 = ipmr_cache_unresolved(mrt, vif, skb);
 			read_unlock(&mrt_lock);
 
-			return err;
+			return err2;
 		}
 		read_unlock(&mrt_lock);
 		kfree_skb(skb);
@@ -2227,9 +2227,9 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 		const struct ipmr_mfc_iter *it = seq->private;
 		const struct mr_table *mrt = it->mrt;
 
-		seq_printf(seq, "%08lX %08lX %-3hd",
-			   (unsigned long) mfc->mfc_mcastgrp,
-			   (unsigned long) mfc->mfc_origin,
+		seq_printf(seq, "%08X %08X %-3hd",
+			   (__force u32) mfc->mfc_mcastgrp,
+			   (__force u32) mfc->mfc_origin,
 			   mfc->mfc_parent);
 
 		if (it->cache != &mrt->mfc_unres_queue) {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cb562fd..a947428 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -258,10 +258,9 @@ static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
 	(__raw_get_cpu_var(rt_cache_stat).field++)
 
 static inline unsigned int rt_hash(__be32 daddr, __be32 saddr, int idx,
-		int genid)
+				   int genid)
 {
-	return jhash_3words((__force u32)(__be32)(daddr),
-			    (__force u32)(__be32)(saddr),
+	return jhash_3words((__force u32)daddr, (__force u32)saddr,
 			    idx, genid)
 		& rt_hash_mask;
 }
@@ -378,12 +377,13 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 		struct rtable *r = v;
 		int len;
 
-		seq_printf(seq, "%s\t%08lX\t%08lX\t%8X\t%d\t%u\t%d\t"
-			      "%08lX\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
+		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
+			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
 			r->u.dst.dev ? r->u.dst.dev->name : "*",
-			(unsigned long)r->rt_dst, (unsigned long)r->rt_gateway,
+			(__force u32)r->rt_dst,
+			(__force u32)r->rt_gateway,
 			r->rt_flags, atomic_read(&r->u.dst.__refcnt),
-			r->u.dst.__use, 0, (unsigned long)r->rt_src,
+			r->u.dst.__use, 0, (__force u32)r->rt_src,
 			(dst_metric(&r->u.dst, RTAX_ADVMSS) ?
 			     (int)dst_metric(&r->u.dst, RTAX_ADVMSS) + 40 : 0),
 			dst_metric(&r->u.dst, RTAX_WINDOW),
@@ -685,18 +685,17 @@ static inline bool rt_caching(const struct net *net)
 static inline bool compare_hash_inputs(const struct flowi *fl1,
 					const struct flowi *fl2)
 {
-	return (__force u32)(((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
-		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |
+	return ((((__force u32)fl1->nl_u.ip4_u.daddr ^ (__force u32)fl2->nl_u.ip4_u.daddr) |
+		((__force u32)fl1->nl_u.ip4_u.saddr ^ (__force u32)fl2->nl_u.ip4_u.saddr) |
 		(fl1->iif ^ fl2->iif)) == 0);
 }
 
 static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 {
-	return ((__force u32)((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
-		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr)) |
+	return (((__force u32)fl1->nl_u.ip4_u.daddr ^ (__force u32)fl2->nl_u.ip4_u.daddr) |
+		((__force u32)fl1->nl_u.ip4_u.saddr ^ (__force u32)fl2->nl_u.ip4_u.saddr) |
 		(fl1->mark ^ fl2->mark) |
-		(*(u16 *)&fl1->nl_u.ip4_u.tos ^
-		 *(u16 *)&fl2->nl_u.ip4_u.tos) |
+		(*(u16 *)&fl1->nl_u.ip4_u.tos ^ *(u16 *)&fl2->nl_u.ip4_u.tos) |
 		(fl1->oif ^ fl2->oif) |
 		(fl1->iif ^ fl2->iif)) == 0;
 }
@@ -2319,8 +2318,8 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rcu_read_lock();
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
 	     rth = rcu_dereference(rth->u.dst.rt_next)) {
-		if (((rth->fl.fl4_dst ^ daddr) |
-		     (rth->fl.fl4_src ^ saddr) |
+		if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)daddr) |
+		     ((__force u32)rth->fl.fl4_src ^ (__force u32)saddr) |
 		     (rth->fl.iif ^ iif) |
 		     rth->fl.oif |
 		     (rth->fl.fl4_tos ^ tos)) == 0 &&
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0f8caf6..d3ad2fa 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2721,7 +2721,7 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	struct tcphdr *th2;
 	unsigned int len;
 	unsigned int thlen;
-	unsigned int flags;
+	__be32 flags;
 	unsigned int mss = 1;
 	unsigned int hlen;
 	unsigned int off;
@@ -2771,10 +2771,10 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 found:
 	flush = NAPI_GRO_CB(p)->flush;
-	flush |= flags & TCP_FLAG_CWR;
-	flush |= (flags ^ tcp_flag_word(th2)) &
-		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
-	flush |= th->ack_seq ^ th2->ack_seq;
+	flush |= (__force int)(flags & TCP_FLAG_CWR);
+	flush |= (__force int)((flags ^ tcp_flag_word(th2)) &
+		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH));
+	flush |= (__force int)(th->ack_seq ^ th2->ack_seq);
 	for (i = sizeof(*th); i < thlen; i += 4)
 		flush |= *(u32 *)((u8 *)th + i) ^
 			 *(u32 *)((u8 *)th2 + i);
@@ -2795,8 +2795,9 @@ found:
 
 out_check_final:
 	flush = len < mss;
-	flush |= flags & (TCP_FLAG_URG | TCP_FLAG_PSH | TCP_FLAG_RST |
-			  TCP_FLAG_SYN | TCP_FLAG_FIN);
+	flush |= (__force int)(flags & (TCP_FLAG_URG | TCP_FLAG_PSH |
+					TCP_FLAG_RST | TCP_FLAG_SYN |
+					TCP_FLAG_FIN));
 
 	if (p && (!NAPI_GRO_CB(skb)->same_flow || flush))
 		pp = head;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ad08392..4d6717d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1286,8 +1286,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 			goto drop_and_release;
 
 		/* Secret recipe starts with IP addresses */
-		*mess++ ^= daddr;
-		*mess++ ^= saddr;
+		*mess++ ^= (__force u32)daddr;
+		*mess++ ^= (__force u32)saddr;
 
 		/* plus variable length Initiator Cookie */
 		c = (u8 *)mess;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2b7d71f..429ad92 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -861,7 +861,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 			th->urg_ptr = htons(tp->snd_up - tcb->seq);
 			th->urg = 1;
 		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
-			th->urg_ptr = 0xFFFF;
+			th->urg_ptr = htons(0xFFFF);
 			th->urg = 1;
 		}
 	}
@@ -2485,7 +2485,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 			*tail-- ^= TCP_SKB_CB(skb)->seq + 1;
 
 			/* recommended */
-			*tail-- ^= ((th->dest << 16) | th->source);
+			*tail-- ^= (((__force u32)th->dest << 16) | (__force u32)th->source);
 			*tail-- ^= (u32)(unsigned long)cvp; /* per sockopt */
 
 			sha_transform((__u32 *)&xvp->cookie_bakery[0],
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 666b963..1e18f9c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -307,13 +307,13 @@ static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 static unsigned int udp4_portaddr_hash(struct net *net, __be32 saddr,
 				       unsigned int port)
 {
-	return jhash_1word(saddr, net_hash_mix(net)) ^ port;
+	return jhash_1word((__force u32)saddr, net_hash_mix(net)) ^ port;
 }
 
 int udp_v4_get_port(struct sock *sk, unsigned short snum)
 {
 	unsigned int hash2_nulladdr =
-		udp4_portaddr_hash(sock_net(sk), INADDR_ANY, snum);
+		udp4_portaddr_hash(sock_net(sk), htonl(INADDR_ANY), snum);
 	unsigned int hash2_partial =
 		udp4_portaddr_hash(sock_net(sk), inet_sk(sk)->inet_rcv_saddr, 0);
 
@@ -466,14 +466,14 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 					  daddr, hnum, dif,
 					  hslot2, slot2);
 		if (!result) {
-			hash2 = udp4_portaddr_hash(net, INADDR_ANY, hnum);
+			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
 			slot2 = hash2 & udptable->mask;
 			hslot2 = &udptable->hash2[slot2];
 			if (hslot->count < hslot2->count)
 				goto begin;
 
 			result = udp4_lib_lookup2(net, saddr, sport,
-						  INADDR_ANY, hnum, dif,
+						  htonl(INADDR_ANY), hnum, dif,
 						  hslot2, slot2);
 		}
 		rcu_read_unlock();
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7cba884..34d2d64 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -588,7 +588,8 @@ static u32 ipv6_addr_hash(const struct in6_addr *addr)
 	 * We perform the hash function over the last 64 bits of the address
 	 * This will include the IEEE address token on links that support it.
 	 */
-	return jhash_2words(addr->s6_addr32[2],  addr->s6_addr32[3], 0)
+	return jhash_2words((__force u32)addr->s6_addr32[2],
+			    (__force u32)addr->s6_addr32[3], 0)
 		& (IN6_ADDR_HSIZE - 1);
 }
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index dc6e0b8..92a122b 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -144,7 +144,8 @@ static __inline__ __be32 addr_bit_set(void *token, int fn_bit)
 	 *	htonl(1 << ((~fn_bit)&0x1F))
 	 * See include/asm-generic/bitops/le.h.
 	 */
-	return (1 << ((~fn_bit ^ BITOP_BE32_SWIZZLE) & 0x1f)) & addr[fn_bit >> 5];
+	return (__force __be32)(1 << ((~fn_bit ^ BITOP_BE32_SWIZZLE) & 0x1f)) &
+	       addr[fn_bit >> 5];
 }
 
 static __inline__ struct fib6_node * node_alloc(void)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index bd5ef7b..a92b4a5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1234,12 +1234,12 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 			goto drop_and_free;
 
 		/* Secret recipe starts with IP addresses */
-		d = &ipv6_hdr(skb)->daddr.s6_addr32[0];
+		d = (__force u32 *)&ipv6_hdr(skb)->daddr.s6_addr32[0];
 		*mess++ ^= *d++;
 		*mess++ ^= *d++;
 		*mess++ ^= *d++;
 		*mess++ ^= *d++;
-		d = &ipv6_hdr(skb)->saddr.s6_addr32[0];
+		d = (__force u32 *)&ipv6_hdr(skb)->saddr.s6_addr32[0];
 		*mess++ ^= *d++;
 		*mess++ ^= *d++;
 		*mess++ ^= *d++;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9082485..92bf903 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -91,9 +91,9 @@ static unsigned int udp6_portaddr_hash(struct net *net,
 	if (ipv6_addr_any(addr6))
 		hash = jhash_1word(0, mix);
 	else if (ipv6_addr_v4mapped(addr6))
-		hash = jhash_1word(addr6->s6_addr32[3], mix);
+		hash = jhash_1word((__force u32)addr6->s6_addr32[3], mix);
 	else
-		hash = jhash2(addr6->s6_addr32, 4, mix);
+		hash = jhash2((__force u32 *)addr6->s6_addr32, 4, mix);
 
 	return hash ^ port;
 }
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index c5a9ac5..c657628 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -123,8 +123,8 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 	case htons(ETH_P_IP):
 	{
 		const struct iphdr *iph = ip_hdr(skb);
-		h = iph->daddr;
-		h2 = iph->saddr ^ iph->protocol;
+		h = (__force u32)iph->daddr;
+		h2 = (__force u32)iph->saddr ^ iph->protocol;
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
 		    (iph->protocol == IPPROTO_TCP ||
 		     iph->protocol == IPPROTO_UDP ||
@@ -138,8 +138,8 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 	case htons(ETH_P_IPV6):
 	{
 		struct ipv6hdr *iph = ipv6_hdr(skb);
-		h = iph->daddr.s6_addr32[3];
-		h2 = iph->saddr.s6_addr32[3] ^ iph->nexthdr;
+		h = (__force u32)iph->daddr.s6_addr32[3];
+		h2 = (__force u32)iph->saddr.s6_addr32[3] ^ iph->nexthdr;
 		if (iph->nexthdr == IPPROTO_TCP ||
 		    iph->nexthdr == IPPROTO_UDP ||
 		    iph->nexthdr == IPPROTO_UDPLITE ||
@@ -150,7 +150,7 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 		break;
 	}
 	default:
-		h = (unsigned long)skb_dst(skb) ^ skb->protocol;
+		h = (unsigned long)skb_dst(skb) ^ (__force u32)skb->protocol;
 		h2 = (unsigned long)skb->sk;
 	}
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 42f09ad..699ade6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -974,7 +974,7 @@ void xprt_reserve(struct rpc_task *task)
 
 static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
 {
-	return xprt->xid++;
+	return (__force __be32)xprt->xid++;
 }
 
 static inline void xprt_init_xid(struct rpc_xprt *xprt)
diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index e5195c9..1396572 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -16,7 +16,8 @@ static inline unsigned int __xfrm6_addr_hash(xfrm_address_t *addr)
 
 static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
 {
-	return ntohl(daddr->a4 + saddr->a4);
+	u32 sum = (__force u32)daddr->a4 + (__force u32)saddr->a4;
+	return ntohl((__force __be32)sum);
 }
 
 static inline unsigned int __xfrm6_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)



