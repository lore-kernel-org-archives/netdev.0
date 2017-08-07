From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next 6/7] net: ipv6: add second dif to inet6 socket lookups
Date: Mon,  7 Aug 2017 08:44:21 -0700
Message-ID: <1502120662-1430-7-git-send-email-dsahern@gmail.com>
References: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34038 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752010AbdHGPom (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 11:44:42 -0400
Received: by mail-pf0-f193.google.com with SMTP id t86so746958pfe.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 08:44:42 -0700 (PDT)
In-Reply-To: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a second device index, sdif, to inet6 socket lookups. sdif is the
index for ingress devices enslaved to an l3mdev. It allows the lookups
to consider the enslaved device as well as the L3 domain when searching
for a socket.

TCP moves the data in the cb. Prior to tcp_v4_rcv (e.g., early demux) the
ingress index is obtained from IPCB using inet_sdif and after tcp_v4_rcv
tcp_v4_sdif is used.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/inet6_hashtables.h | 22 +++++++++++++---------
 include/net/tcp.h              | 10 ++++++++++
 net/dccp/ipv6.c                |  4 ++--
 net/ipv6/inet6_hashtables.c    | 28 +++++++++++++++++-----------
 net/ipv6/tcp_ipv6.c            | 13 ++++++++-----
 net/ipv6/udp.c                 |  7 ++++---
 net/netfilter/xt_TPROXY.c      |  4 ++--
 7 files changed, 56 insertions(+), 32 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index b87becacd9d3..6e91e38a31da 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -49,7 +49,8 @@ struct sock *__inet6_lookup_established(struct net *net,
 					const struct in6_addr *saddr,
 					const __be16 sport,
 					const struct in6_addr *daddr,
-					const u16 hnum, const int dif);
+					const u16 hnum, const int dif,
+					const int sdif);
 
 struct sock *inet6_lookup_listener(struct net *net,
 				   struct inet_hashinfo *hashinfo,
@@ -57,7 +58,8 @@ struct sock *inet6_lookup_listener(struct net *net,
 				   const struct in6_addr *saddr,
 				   const __be16 sport,
 				   const struct in6_addr *daddr,
-				   const unsigned short hnum, const int dif);
+				   const unsigned short hnum,
+				   const int dif, const int sdif);
 
 static inline struct sock *__inet6_lookup(struct net *net,
 					  struct inet_hashinfo *hashinfo,
@@ -66,24 +68,25 @@ static inline struct sock *__inet6_lookup(struct net *net,
 					  const __be16 sport,
 					  const struct in6_addr *daddr,
 					  const u16 hnum,
-					  const int dif,
+					  const int dif, const int sdif,
 					  bool *refcounted)
 {
 	struct sock *sk = __inet6_lookup_established(net, hashinfo, saddr,
-						sport, daddr, hnum, dif);
+						     sport, daddr, hnum,
+						     dif, sdif);
 	*refcounted = true;
 	if (sk)
 		return sk;
 	*refcounted = false;
 	return inet6_lookup_listener(net, hashinfo, skb, doff, saddr, sport,
-				     daddr, hnum, dif);
+				     daddr, hnum, dif, sdif);
 }
 
 static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
 					      struct sk_buff *skb, int doff,
 					      const __be16 sport,
 					      const __be16 dport,
-					      int iif,
+					      int iif, int sdif,
 					      bool *refcounted)
 {
 	struct sock *sk = skb_steal_sock(skb);
@@ -95,7 +98,7 @@ static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
 	return __inet6_lookup(dev_net(skb_dst(skb)->dev), hashinfo, skb,
 			      doff, &ipv6_hdr(skb)->saddr, sport,
 			      &ipv6_hdr(skb)->daddr, ntohs(dport),
-			      iif, refcounted);
+			      iif, sdif, refcounted);
 }
 
 struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
@@ -107,13 +110,14 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 int inet6_hash(struct sock *sk);
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
-#define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
+#define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif, __sdif) \
 	(((__sk)->sk_portpair == (__ports))			&&	\
 	 ((__sk)->sk_family == AF_INET6)			&&	\
 	 ipv6_addr_equal(&(__sk)->sk_v6_daddr, (__saddr))		&&	\
 	 ipv6_addr_equal(&(__sk)->sk_v6_rcv_saddr, (__daddr))	&&	\
 	 (!(__sk)->sk_bound_dev_if	||				\
-	   ((__sk)->sk_bound_dev_if == (__dif))) 		&&	\
+	   ((__sk)->sk_bound_dev_if == (__dif))	||			\
+	   ((__sk)->sk_bound_dev_if == (__sdif)))		&&	\
 	 net_eq(sock_net(__sk), (__net)))
 
 #endif /* _INET6_HASHTABLES_H */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2b89f1ab8552..999f3efe572b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -827,6 +827,16 @@ static inline int tcp_v6_iif(const struct sk_buff *skb)
 
 	return l3_slave ? skb->skb_iif : TCP_SKB_CB(skb)->header.h6.iif;
 }
+
+/* TCP_SKB_CB reference means this can not be used from early demux */
+static inline int tcp_v6_sdif(const struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
+	if (skb && ipv6_l3mdev_skb(TCP_SKB_CB(skb)->header.h6.flags))
+		return TCP_SKB_CB(skb)->header.h6.iif;
+#endif
+	return 0;
+}
 #endif
 
 /* TCP_SKB_CB reference means this can not be used from early demux */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 1b58eac8aad3..47a7b59b355e 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -89,7 +89,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	sk = __inet6_lookup_established(net, &dccp_hashinfo,
 					&hdr->daddr, dh->dccph_dport,
 					&hdr->saddr, ntohs(dh->dccph_sport),
-					inet6_iif(skb));
+					inet6_iif(skb), 0);
 
 	if (!sk) {
 		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
@@ -687,7 +687,7 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 lookup:
 	sk = __inet6_lookup_skb(&dccp_hashinfo, skb, __dccp_hdr_len(dh),
 			        dh->dccph_sport, dh->dccph_dport,
-				inet6_iif(skb), &refcounted);
+				inet6_iif(skb), 0, &refcounted);
 	if (!sk) {
 		dccp_pr_debug("failed to look up flow ID in table and "
 			      "get corresponding socket\n");
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index b13b8f93079d..b01858f5deb1 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -56,7 +56,7 @@ struct sock *__inet6_lookup_established(struct net *net,
 					   const __be16 sport,
 					   const struct in6_addr *daddr,
 					   const u16 hnum,
-					   const int dif)
+					   const int dif, const int sdif)
 {
 	struct sock *sk;
 	const struct hlist_nulls_node *node;
@@ -73,12 +73,12 @@ struct sock *__inet6_lookup_established(struct net *net,
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (sk->sk_hash != hash)
 			continue;
-		if (!INET6_MATCH(sk, net, saddr, daddr, ports, dif))
+		if (!INET6_MATCH(sk, net, saddr, daddr, ports, dif, sdif))
 			continue;
 		if (unlikely(!refcount_inc_not_zero(&sk->sk_refcnt)))
 			goto out;
 
-		if (unlikely(!INET6_MATCH(sk, net, saddr, daddr, ports, dif))) {
+		if (unlikely(!INET6_MATCH(sk, net, saddr, daddr, ports, dif, sdif))) {
 			sock_gen_put(sk);
 			goto begin;
 		}
@@ -96,7 +96,7 @@ EXPORT_SYMBOL(__inet6_lookup_established);
 static inline int compute_score(struct sock *sk, struct net *net,
 				const unsigned short hnum,
 				const struct in6_addr *daddr,
-				const int dif, bool exact_dif)
+				const int dif, const int sdif, bool exact_dif)
 {
 	int score = -1;
 
@@ -110,9 +110,13 @@ static inline int compute_score(struct sock *sk, struct net *net,
 			score++;
 		}
 		if (sk->sk_bound_dev_if || exact_dif) {
-			if (sk->sk_bound_dev_if != dif)
+			bool dev_match = (sk->sk_bound_dev_if == dif ||
+					  sk->sk_bound_dev_if == sdif);
+
+			if (exact_dif && !dev_match)
 				return -1;
-			score++;
+			if (sk->sk_bound_dev_if && dev_match)
+				score++;
 		}
 		if (sk->sk_incoming_cpu == raw_smp_processor_id())
 			score++;
@@ -126,7 +130,7 @@ struct sock *inet6_lookup_listener(struct net *net,
 		struct sk_buff *skb, int doff,
 		const struct in6_addr *saddr,
 		const __be16 sport, const struct in6_addr *daddr,
-		const unsigned short hnum, const int dif)
+		const unsigned short hnum, const int dif, const int sdif)
 {
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
@@ -136,7 +140,7 @@ struct sock *inet6_lookup_listener(struct net *net,
 	u32 phash = 0;
 
 	sk_for_each(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
+		score = compute_score(sk, net, hnum, daddr, dif, sdif, exact_dif);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
@@ -171,7 +175,7 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 	bool refcounted;
 
 	sk = __inet6_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
-			    ntohs(dport), dif, &refcounted);
+			    ntohs(dport), dif, 0, &refcounted);
 	if (sk && !refcounted && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
 	return sk;
@@ -187,8 +191,9 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	const struct in6_addr *daddr = &sk->sk_v6_rcv_saddr;
 	const struct in6_addr *saddr = &sk->sk_v6_daddr;
 	const int dif = sk->sk_bound_dev_if;
-	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
 	struct net *net = sock_net(sk);
+	const int sdif = l3mdev_master_ifindex_by_index(net, dif);
+	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
 	const unsigned int hash = inet6_ehashfn(net, daddr, lport, saddr,
 						inet->inet_dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
@@ -203,7 +208,8 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 		if (sk2->sk_hash != hash)
 			continue;
 
-		if (likely(INET6_MATCH(sk2, net, saddr, daddr, ports, dif))) {
+		if (likely(INET6_MATCH(sk2, net, saddr, daddr, ports,
+				       dif, sdif))) {
 			if (sk2->sk_state == TCP_TIME_WAIT) {
 				tw = inet_twsk(sk2);
 				if (twsk_unique(sk, sk2, twp))
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ced5dcf37465..f776ec4ecf6d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -350,7 +350,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	sk = __inet6_lookup_established(net, &tcp_hashinfo,
 					&hdr->daddr, th->dest,
 					&hdr->saddr, ntohs(th->source),
-					skb->dev->ifindex);
+					skb->dev->ifindex, inet6_sdif(skb));
 
 	if (!sk) {
 		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
@@ -918,7 +918,8 @@ static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 					   &tcp_hashinfo, NULL, 0,
 					   &ipv6h->saddr,
 					   th->source, &ipv6h->daddr,
-					   ntohs(th->source), tcp_v6_iif(skb));
+					   ntohs(th->source), tcp_v6_iif(skb),
+					   tcp_v6_sdif(skb));
 		if (!sk1)
 			goto out;
 
@@ -1397,6 +1398,7 @@ static void tcp_v6_fill_cb(struct sk_buff *skb, const struct ipv6hdr *hdr,
 
 static int tcp_v6_rcv(struct sk_buff *skb)
 {
+	int sdif = inet6_sdif(skb);
 	const struct tcphdr *th;
 	const struct ipv6hdr *hdr;
 	bool refcounted;
@@ -1430,7 +1432,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 
 lookup:
 	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, __tcp_hdrlen(th),
-				th->source, th->dest, inet6_iif(skb),
+				th->source, th->dest, inet6_iif(skb), sdif,
 				&refcounted);
 	if (!sk)
 		goto no_tcp_socket;
@@ -1563,7 +1565,8 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 					    skb, __tcp_hdrlen(th),
 					    &ipv6_hdr(skb)->saddr, th->source,
 					    &ipv6_hdr(skb)->daddr,
-					    ntohs(th->dest), tcp_v6_iif(skb));
+					    ntohs(th->dest), tcp_v6_iif(skb),
+					    sdif);
 		if (sk2) {
 			struct inet_timewait_sock *tw = inet_twsk(sk);
 			inet_twsk_deschedule_put(tw);
@@ -1610,7 +1613,7 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
 	sk = __inet6_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
 					&hdr->saddr, th->source,
 					&hdr->daddr, ntohs(th->dest),
-					inet6_iif(skb));
+					inet6_iif(skb), inet6_sdif(skb));
 	if (sk) {
 		skb->sk = sk;
 		skb->destructor = sock_edemux;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d96a877798a7..19afcaf4a22e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -897,7 +897,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 static struct sock *__udp6_lib_demux_lookup(struct net *net,
 			__be16 loc_port, const struct in6_addr *loc_addr,
 			__be16 rmt_port, const struct in6_addr *rmt_addr,
-			int dif)
+			int dif, int sdif)
 {
 	unsigned short hnum = ntohs(loc_port);
 	unsigned int hash2 = udp6_portaddr_hash(net, loc_addr, hnum);
@@ -908,7 +908,7 @@ static struct sock *__udp6_lib_demux_lookup(struct net *net,
 
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
 		if (sk->sk_state == TCP_ESTABLISHED &&
-		    INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, dif))
+		    INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, dif, sdif))
 			return sk;
 		/* Only check first socket in chain */
 		break;
@@ -923,6 +923,7 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 	struct sock *sk;
 	struct dst_entry *dst;
 	int dif = skb->dev->ifindex;
+	int sdif = inet6_sdif(skb);
 
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) +
 	    sizeof(struct udphdr)))
@@ -934,7 +935,7 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 		sk = __udp6_lib_demux_lookup(net, uh->dest,
 					     &ipv6_hdr(skb)->daddr,
 					     uh->source, &ipv6_hdr(skb)->saddr,
-					     dif);
+					     dif, sdif);
 	else
 		return;
 
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 94fb0fd0c667..ade4c10c28c6 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -195,7 +195,7 @@ nf_tproxy_get_sock_v6(struct net *net, struct sk_buff *skb, int thoff, void *hp,
 						   thoff + __tcp_hdrlen(tcph),
 						   saddr, sport,
 						   daddr, ntohs(dport),
-						   in->ifindex);
+						   in->ifindex, 0);
 
 			if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 				sk = NULL;
@@ -208,7 +208,7 @@ nf_tproxy_get_sock_v6(struct net *net, struct sk_buff *skb, int thoff, void *hp,
 		case NFT_LOOKUP_ESTABLISHED:
 			sk = __inet6_lookup_established(net, &tcp_hashinfo,
 							saddr, sport, daddr, ntohs(dport),
-							in->ifindex);
+							in->ifindex, 0);
 			break;
 		default:
 			BUG();
-- 
2.1.4
