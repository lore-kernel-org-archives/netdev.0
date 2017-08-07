From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next 2/7] net: ipv4: add second dif to inet socket lookups
Date: Mon,  7 Aug 2017 08:44:17 -0700
Message-ID: <1502120662-1430-3-git-send-email-dsahern@gmail.com>
References: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35515 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbdHGPoi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 11:44:38 -0400
Received: by mail-pg0-f65.google.com with SMTP id l64so704834pge.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 08:44:38 -0700 (PDT)
In-Reply-To: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a second device index, sdif, to inet socket lookups. sdif is the
index for ingress devices enslaved to an l3mdev. It allows the lookups
to consider the enslaved device as well as the L3 domain when searching
for a socket.

TCP moves the data in the cb. Prior to tcp_v4_rcv (e.g., early demux) the
ingress index is obtained from IPCB using inet_sdif and after the cb move
in  tcp_v4_rcv the tcp_v4_sdif helper is used.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/inet_hashtables.h | 31 +++++++++++++++++--------------
 include/net/tcp.h             | 10 ++++++++++
 net/dccp/ipv4.c               |  4 ++--
 net/ipv4/inet_hashtables.c    | 27 +++++++++++++++++----------
 net/ipv4/tcp_ipv4.c           | 13 ++++++++-----
 net/ipv4/udp.c                |  6 +++---
 net/netfilter/xt_TPROXY.c     |  2 +-
 7 files changed, 58 insertions(+), 35 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 5026b1f08bb8..2dbbbff5e1e3 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -221,16 +221,16 @@ struct sock *__inet_lookup_listener(struct net *net,
 				    const __be32 saddr, const __be16 sport,
 				    const __be32 daddr,
 				    const unsigned short hnum,
-				    const int dif);
+				    const int dif, const int sdif);
 
 static inline struct sock *inet_lookup_listener(struct net *net,
 		struct inet_hashinfo *hashinfo,
 		struct sk_buff *skb, int doff,
 		__be32 saddr, __be16 sport,
-		__be32 daddr, __be16 dport, int dif)
+		__be32 daddr, __be16 dport, int dif, int sdif)
 {
 	return __inet_lookup_listener(net, hashinfo, skb, doff, saddr, sport,
-				      daddr, ntohs(dport), dif);
+				      daddr, ntohs(dport), dif, sdif);
 }
 
 /* Socket demux engine toys. */
@@ -262,22 +262,24 @@ static inline struct sock *inet_lookup_listener(struct net *net,
 				   (((__force __u64)(__be32)(__daddr)) << 32) | \
 				   ((__force __u64)(__be32)(__saddr)))
 #endif /* __BIG_ENDIAN */
-#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)	\
+#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif, __sdif) \
 	(((__sk)->sk_portpair == (__ports))			&&	\
 	 ((__sk)->sk_addrpair == (__cookie))			&&	\
 	 (!(__sk)->sk_bound_dev_if	||				\
-	   ((__sk)->sk_bound_dev_if == (__dif))) 		&& 	\
+	   ((__sk)->sk_bound_dev_if == (__dif))			||	\
+	   ((__sk)->sk_bound_dev_if == (__sdif)))		&&	\
 	 net_eq(sock_net(__sk), (__net)))
 #else /* 32-bit arch */
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr) \
 	const int __name __deprecated __attribute__((unused))
 
-#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif) \
+#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif, __sdif) \
 	(((__sk)->sk_portpair == (__ports))		&&		\
 	 ((__sk)->sk_daddr	== (__saddr))		&&		\
 	 ((__sk)->sk_rcv_saddr	== (__daddr))		&&		\
 	 (!(__sk)->sk_bound_dev_if	||				\
-	   ((__sk)->sk_bound_dev_if == (__dif))) 	&&		\
+	   ((__sk)->sk_bound_dev_if == (__dif))		||		\
+	   ((__sk)->sk_bound_dev_if == (__sdif)))	&&		\
 	 net_eq(sock_net(__sk), (__net)))
 #endif /* 64-bit arch */
 
@@ -288,7 +290,7 @@ struct sock *__inet_lookup_established(struct net *net,
 				       struct inet_hashinfo *hashinfo,
 				       const __be32 saddr, const __be16 sport,
 				       const __be32 daddr, const u16 hnum,
-				       const int dif);
+				       const int dif, const int sdif);
 
 static inline struct sock *
 	inet_lookup_established(struct net *net, struct inet_hashinfo *hashinfo,
@@ -297,7 +299,7 @@ static inline struct sock *
 				const int dif)
 {
 	return __inet_lookup_established(net, hashinfo, saddr, sport, daddr,
-					 ntohs(dport), dif);
+					 ntohs(dport), dif, 0);
 }
 
 static inline struct sock *__inet_lookup(struct net *net,
@@ -305,20 +307,20 @@ static inline struct sock *__inet_lookup(struct net *net,
 					 struct sk_buff *skb, int doff,
 					 const __be32 saddr, const __be16 sport,
 					 const __be32 daddr, const __be16 dport,
-					 const int dif,
+					 const int dif, const int sdif,
 					 bool *refcounted)
 {
 	u16 hnum = ntohs(dport);
 	struct sock *sk;
 
 	sk = __inet_lookup_established(net, hashinfo, saddr, sport,
-				       daddr, hnum, dif);
+				       daddr, hnum, dif, sdif);
 	*refcounted = true;
 	if (sk)
 		return sk;
 	*refcounted = false;
 	return __inet_lookup_listener(net, hashinfo, skb, doff, saddr,
-				      sport, daddr, hnum, dif);
+				      sport, daddr, hnum, dif, sdif);
 }
 
 static inline struct sock *inet_lookup(struct net *net,
@@ -332,7 +334,7 @@ static inline struct sock *inet_lookup(struct net *net,
 	bool refcounted;
 
 	sk = __inet_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
-			   dport, dif, &refcounted);
+			   dport, dif, 0, &refcounted);
 
 	if (sk && !refcounted && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
@@ -344,6 +346,7 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 					     int doff,
 					     const __be16 sport,
 					     const __be16 dport,
+					     const int sdif,
 					     bool *refcounted)
 {
 	struct sock *sk = skb_steal_sock(skb);
@@ -355,7 +358,7 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 
 	return __inet_lookup(dev_net(skb_dst(skb)->dev), hashinfo, skb,
 			     doff, iph->saddr, sport,
-			     iph->daddr, dport, inet_iif(skb),
+			     iph->daddr, dport, inet_iif(skb), sdif,
 			     refcounted);
 }
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5173fecde495..2b89f1ab8552 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -840,6 +840,16 @@ static inline bool inet_exact_dif_match(struct net *net, struct sk_buff *skb)
 	return false;
 }
 
+/* TCP_SKB_CB reference means this can not be used from early demux */
+static inline int tcp_v4_sdif(struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
+	if (skb && ipv4_l3mdev_skb(TCP_SKB_CB(skb)->header.h4.flags))
+		return TCP_SKB_CB(skb)->header.h4.iif;
+#endif
+	return 0;
+}
+
 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
  */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 1b202f16531f..001c08696334 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -256,7 +256,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	sk = __inet_lookup_established(net, &dccp_hashinfo,
 				       iph->daddr, dh->dccph_dport,
 				       iph->saddr, ntohs(dh->dccph_sport),
-				       inet_iif(skb));
+				       inet_iif(skb), 0);
 	if (!sk) {
 		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;
@@ -804,7 +804,7 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 
 lookup:
 	sk = __inet_lookup_skb(&dccp_hashinfo, skb, __dccp_hdr_len(dh),
-			       dh->dccph_sport, dh->dccph_dport, &refcounted);
+			       dh->dccph_sport, dh->dccph_dport, 0, &refcounted);
 	if (!sk) {
 		dccp_pr_debug("failed to look up flow ID in table and "
 			      "get corresponding socket\n");
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 2e3389d614d1..597bb4cfe805 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -170,7 +170,7 @@ EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
 static inline int compute_score(struct sock *sk, struct net *net,
 				const unsigned short hnum, const __be32 daddr,
-				const int dif, bool exact_dif)
+				const int dif, const int sdif, bool exact_dif)
 {
 	int score = -1;
 	struct inet_sock *inet = inet_sk(sk);
@@ -185,9 +185,13 @@ static inline int compute_score(struct sock *sk, struct net *net,
 			score += 4;
 		}
 		if (sk->sk_bound_dev_if || exact_dif) {
-			if (sk->sk_bound_dev_if != dif)
+			bool dev_match = (sk->sk_bound_dev_if == dif ||
+					  sk->sk_bound_dev_if == sdif);
+
+			if (exact_dif && !dev_match)
 				return -1;
-			score += 4;
+			if (sk->sk_bound_dev_if && dev_match)
+				score += 4;
 		}
 		if (sk->sk_incoming_cpu == raw_smp_processor_id())
 			score++;
@@ -208,7 +212,7 @@ struct sock *__inet_lookup_listener(struct net *net,
 				    struct sk_buff *skb, int doff,
 				    const __be32 saddr, __be16 sport,
 				    const __be32 daddr, const unsigned short hnum,
-				    const int dif)
+				    const int dif, const int sdif)
 {
 	unsigned int hash = inet_lhashfn(net, hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
@@ -218,7 +222,8 @@ struct sock *__inet_lookup_listener(struct net *net,
 	u32 phash = 0;
 
 	sk_for_each_rcu(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
+		score = compute_score(sk, net, hnum, daddr,
+				      dif, sdif, exact_dif);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
@@ -268,7 +273,7 @@ struct sock *__inet_lookup_established(struct net *net,
 				  struct inet_hashinfo *hashinfo,
 				  const __be32 saddr, const __be16 sport,
 				  const __be32 daddr, const u16 hnum,
-				  const int dif)
+				  const int dif, const int sdif)
 {
 	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
@@ -286,11 +291,12 @@ struct sock *__inet_lookup_established(struct net *net,
 		if (sk->sk_hash != hash)
 			continue;
 		if (likely(INET_MATCH(sk, net, acookie,
-				      saddr, daddr, ports, dif))) {
+				      saddr, daddr, ports, dif, sdif))) {
 			if (unlikely(!refcount_inc_not_zero(&sk->sk_refcnt)))
 				goto out;
 			if (unlikely(!INET_MATCH(sk, net, acookie,
-						 saddr, daddr, ports, dif))) {
+						 saddr, daddr, ports,
+						 dif, sdif))) {
 				sock_gen_put(sk);
 				goto begin;
 			}
@@ -321,9 +327,10 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	__be32 daddr = inet->inet_rcv_saddr;
 	__be32 saddr = inet->inet_daddr;
 	int dif = sk->sk_bound_dev_if;
+	struct net *net = sock_net(sk);
+	int sdif = l3mdev_master_ifindex_by_index(net, dif);
 	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
-	struct net *net = sock_net(sk);
 	unsigned int hash = inet_ehashfn(net, daddr, lport,
 					 saddr, inet->inet_dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
@@ -339,7 +346,7 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 			continue;
 
 		if (likely(INET_MATCH(sk2, net, acookie,
-					 saddr, daddr, ports, dif))) {
+					 saddr, daddr, ports, dif, sdif))) {
 			if (sk2->sk_state == TCP_TIME_WAIT) {
 				tw = inet_twsk(sk2);
 				if (twsk_unique(sk, sk2, twp))
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5f708c85110e..c8784ab37852 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -383,7 +383,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 
 	sk = __inet_lookup_established(net, &tcp_hashinfo, iph->daddr,
 				       th->dest, iph->saddr, ntohs(th->source),
-				       inet_iif(icmp_skb));
+				       inet_iif(icmp_skb), 0);
 	if (!sk) {
 		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;
@@ -659,7 +659,8 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 		sk1 = __inet_lookup_listener(net, &tcp_hashinfo, NULL, 0,
 					     ip_hdr(skb)->saddr,
 					     th->source, ip_hdr(skb)->daddr,
-					     ntohs(th->source), inet_iif(skb));
+					     ntohs(th->source), inet_iif(skb),
+					     tcp_v4_sdif(skb));
 		/* don't send rst if it can't find key */
 		if (!sk1)
 			goto out;
@@ -1523,7 +1524,7 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	sk = __inet_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
 				       iph->saddr, th->source,
 				       iph->daddr, ntohs(th->dest),
-				       skb->skb_iif);
+				       skb->skb_iif, inet_sdif(skb));
 	if (sk) {
 		skb->sk = sk;
 		skb->destructor = sock_edemux;
@@ -1588,6 +1589,7 @@ EXPORT_SYMBOL(tcp_filter);
 int tcp_v4_rcv(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
+	int sdif = inet_sdif(skb);
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	bool refcounted;
@@ -1638,7 +1640,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 
 lookup:
 	sk = __inet_lookup_skb(&tcp_hashinfo, skb, __tcp_hdrlen(th), th->source,
-			       th->dest, &refcounted);
+			       th->dest, sdif, &refcounted);
 	if (!sk)
 		goto no_tcp_socket;
 
@@ -1766,7 +1768,8 @@ int tcp_v4_rcv(struct sk_buff *skb)
 							__tcp_hdrlen(th),
 							iph->saddr, th->source,
 							iph->daddr, th->dest,
-							inet_iif(skb));
+							inet_iif(skb),
+							sdif);
 		if (sk2) {
 			inet_twsk_deschedule_put(inet_twsk(sk));
 			sk = sk2;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fe14429e4a6c..99f25bfec606 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2196,7 +2196,7 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
 static struct sock *__udp4_lib_demux_lookup(struct net *net,
 					    __be16 loc_port, __be32 loc_addr,
 					    __be16 rmt_port, __be32 rmt_addr,
-					    int dif)
+					    int dif, int sdif)
 {
 	unsigned short hnum = ntohs(loc_port);
 	unsigned int hash2 = udp4_portaddr_hash(net, loc_addr, hnum);
@@ -2208,7 +2208,7 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
 		if (INET_MATCH(sk, net, acookie, rmt_addr,
-			       loc_addr, ports, dif))
+			       loc_addr, ports, dif, sdif))
 			return sk;
 		/* Only check first socket in chain */
 		break;
@@ -2254,7 +2254,7 @@ void udp_v4_early_demux(struct sk_buff *skb)
 						   dif, sdif);
 	} else if (skb->pkt_type == PACKET_HOST) {
 		sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
-					     uh->source, iph->saddr, dif);
+					     uh->source, iph->saddr, dif, sdif);
 	}
 
 	if (!sk || !refcount_inc_not_zero(&sk->sk_refcnt))
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index d767e35fff6b..94fb0fd0c667 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -125,7 +125,7 @@ nf_tproxy_get_sock_v4(struct net *net, struct sk_buff *skb, void *hp,
 						      __tcp_hdrlen(tcph),
 						    saddr, sport,
 						    daddr, dport,
-						    in->ifindex);
+						    in->ifindex, 0);
 
 			if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 				sk = NULL;
-- 
2.1.4
