From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 02/10] net: ipv4: Convert udp socket lookups to new struct
Date: Mon, 31 Jul 2017 20:13:18 -0700
Message-ID: <1501557206-27503-3-git-send-email-dsahern@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32972 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdHADNj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:39 -0400
Received: by mail-pg0-f66.google.com with SMTP id u185so596229pgb.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:39 -0700 (PDT)
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert udp4_lib_lookup and __udp4_lib_lookup to use the new sk_lookup
struct.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/udp.h                   |   6 +-
 net/ipv4/netfilter/nf_socket_ipv4.c |  11 ++-
 net/ipv4/udp.c                      | 170 +++++++++++++++++++-----------------
 net/ipv4/udp_diag.c                 |  51 +++++++----
 net/netfilter/xt_TPROXY.c           |  11 ++-
 5 files changed, 144 insertions(+), 105 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 972ce4baab6b..5e0ff095dc6d 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -283,10 +283,8 @@ int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 		       char __user *optval, unsigned int optlen,
 		       int (*push_pending_frames)(struct sock *));
-struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
-			     __be32 daddr, __be16 dport, int dif);
-struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
-			       __be32 daddr, __be16 dport, int dif,
+struct sock *udp4_lib_lookup(struct net *net, struct sk_lookup *params);
+struct sock *__udp4_lib_lookup(struct net *net, struct sk_lookup *params,
 			       struct udp_table *tbl, struct sk_buff *skb);
 struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
diff --git a/net/ipv4/netfilter/nf_socket_ipv4.c b/net/ipv4/netfilter/nf_socket_ipv4.c
index e9293bdebba0..121767b36763 100644
--- a/net/ipv4/netfilter/nf_socket_ipv4.c
+++ b/net/ipv4/netfilter/nf_socket_ipv4.c
@@ -81,14 +81,21 @@ nf_socket_get_sock_v4(struct net *net, struct sk_buff *skb, const int doff,
 		      const __be16 sport, const __be16 dport,
 		      const struct net_device *in)
 {
+	struct sk_lookup params = {
+		.saddr.ipv4 = saddr,
+		.daddr.ipv4 = daddr,
+		.sport = sport,
+		.dport = dport,
+		.dif = in->ifindex,
+	};
+
 	switch (protocol) {
 	case IPPROTO_TCP:
 		return inet_lookup(net, &tcp_hashinfo, skb, doff,
 				   saddr, sport, daddr, dport,
 				   in->ifindex);
 	case IPPROTO_UDP:
-		return udp4_lib_lookup(net, saddr, sport, daddr, dport,
-				       in->ifindex);
+		return udp4_lib_lookup(net, &params);
 	}
 	return NULL;
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b057653ceca9..132a8f070d16 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -379,15 +379,13 @@ int udp_v4_get_port(struct sock *sk, unsigned short snum)
 }
 
 static int compute_score(struct sock *sk, struct net *net,
-			 __be32 saddr, __be16 sport,
-			 __be32 daddr, unsigned short hnum, int dif,
-			 bool exact_dif)
+			 const struct sk_lookup *params)
 {
-	int score;
 	struct inet_sock *inet;
+	int score, rc;
 
 	if (!net_eq(sock_net(sk), net) ||
-	    udp_sk(sk)->udp_port_hash != hnum ||
+	    udp_sk(sk)->udp_port_hash != params->hnum ||
 	    ipv6_only_sock(sk))
 		return -1;
 
@@ -395,28 +393,28 @@ static int compute_score(struct sock *sk, struct net *net,
 	inet = inet_sk(sk);
 
 	if (inet->inet_rcv_saddr) {
-		if (inet->inet_rcv_saddr != daddr)
+		if (inet->inet_rcv_saddr != params->daddr.ipv4)
 			return -1;
 		score += 4;
 	}
 
 	if (inet->inet_daddr) {
-		if (inet->inet_daddr != saddr)
+		if (inet->inet_daddr != params->saddr.ipv4)
 			return -1;
 		score += 4;
 	}
 
 	if (inet->inet_dport) {
-		if (inet->inet_dport != sport)
+		if (inet->inet_dport != params->sport)
 			return -1;
 		score += 4;
 	}
 
-	if (sk->sk_bound_dev_if || exact_dif) {
-		if (sk->sk_bound_dev_if != dif)
-			return -1;
+	rc = sk_lookup_device_cmp(sk, params);
+	if (rc < 0)
+		return -1;
+	if (rc > 0)
 		score += 4;
-	}
 	if (sk->sk_incoming_cpu == raw_smp_processor_id())
 		score++;
 	return score;
@@ -436,10 +434,9 @@ static u32 udp_ehashfn(const struct net *net, const __be32 laddr,
 
 /* called with rcu_read_lock() */
 static struct sock *udp4_lib_lookup2(struct net *net,
-		__be32 saddr, __be16 sport,
-		__be32 daddr, unsigned int hnum, int dif, bool exact_dif,
-		struct udp_hslot *hslot2,
-		struct sk_buff *skb)
+				     const struct sk_lookup *params,
+				     struct udp_hslot *hslot2,
+				     struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	int score, badness, matches = 0, reuseport = 0;
@@ -448,13 +445,14 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 	result = NULL;
 	badness = 0;
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		score = compute_score(sk, net, saddr, sport,
-				      daddr, hnum, dif, exact_dif);
+		score = compute_score(sk, net, params);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				hash = udp_ehashfn(net, daddr, hnum,
-						   saddr, sport);
+				hash = udp_ehashfn(net, params->daddr.ipv4,
+						   params->hnum,
+						   params->saddr.ipv4,
+						   params->sport);
 				result = reuseport_select_sock(sk, hash, skb,
 							sizeof(struct udphdr));
 				if (result)
@@ -476,28 +474,27 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
-		__be16 sport, __be32 daddr, __be16 dport,
-		int dif, struct udp_table *udptable, struct sk_buff *skb)
+struct sock *__udp4_lib_lookup(struct net *net, struct sk_lookup *params,
+			       struct udp_table *udptable, struct sk_buff *skb)
 {
 	struct sock *sk, *result;
-	unsigned short hnum = ntohs(dport);
+	unsigned short hnum = ntohs(params->dport);
 	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
-	bool exact_dif = udp_lib_exact_dif_match(net, skb);
 	int score, badness, matches = 0, reuseport = 0;
 	u32 hash = 0;
 
+	params->hnum = hnum;
+	params->exact_dif = udp_lib_exact_dif_match(net, skb);
+
 	if (hslot->count > 10) {
-		hash2 = udp4_portaddr_hash(net, daddr, hnum);
+		hash2 = udp4_portaddr_hash(net, params->daddr.ipv4, hnum);
 		slot2 = hash2 & udptable->mask;
 		hslot2 = &udptable->hash2[slot2];
 		if (hslot->count < hslot2->count)
 			goto begin;
 
-		result = udp4_lib_lookup2(net, saddr, sport,
-					  daddr, hnum, dif,
-					  exact_dif, hslot2, skb);
+		result = udp4_lib_lookup2(net, params, hslot2, skb);
 		if (!result) {
 			unsigned int old_slot2 = slot2;
 			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
@@ -510,9 +507,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 			if (hslot->count < hslot2->count)
 				goto begin;
 
-			result = udp4_lib_lookup2(net, saddr, sport,
-						  daddr, hnum, dif,
-						  exact_dif, hslot2, skb);
+			result = udp4_lib_lookup2(net, params, hslot2, skb);
 		}
 		return result;
 	}
@@ -520,13 +515,14 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	result = NULL;
 	badness = 0;
 	sk_for_each_rcu(sk, &hslot->head) {
-		score = compute_score(sk, net, saddr, sport,
-				      daddr, hnum, dif, exact_dif);
+		score = compute_score(sk, net, params);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				hash = udp_ehashfn(net, daddr, hnum,
-						   saddr, sport);
+				hash = udp_ehashfn(net, params->daddr.ipv4,
+						   params->hnum,
+						   params->saddr.ipv4,
+						   params->sport);
 				result = reuseport_select_sock(sk, hash, skb,
 							sizeof(struct udphdr));
 				if (result)
@@ -551,10 +547,16 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 						 struct udp_table *udptable)
 {
 	const struct iphdr *iph = ip_hdr(skb);
+	struct net *net = dev_net(skb->dev);
+	struct sk_lookup params = {
+		.saddr.ipv4 = iph->saddr,
+		.daddr.ipv4 = iph->daddr,
+		.sport = sport,
+		.dport = dport,
+		.dif   = inet_iif(skb),
+	};
 
-	return __udp4_lib_lookup(dev_net(skb->dev), iph->saddr, sport,
-				 iph->daddr, dport, inet_iif(skb),
-				 udptable, skb);
+	return __udp4_lib_lookup(net, &params, udptable, skb);
 }
 
 struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
@@ -570,13 +572,11 @@ EXPORT_SYMBOL_GPL(udp4_lib_lookup_skb);
 #if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
     IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY) || \
     IS_ENABLED(CONFIG_NF_SOCKET_IPV4)
-struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
-			     __be32 daddr, __be16 dport, int dif)
+struct sock *udp4_lib_lookup(struct net *net, struct sk_lookup *params)
 {
 	struct sock *sk;
 
-	sk = __udp4_lib_lookup(net, saddr, sport, daddr, dport,
-			       dif, &udp_table, NULL);
+	sk = __udp4_lib_lookup(net, params, &udp_table, NULL);
 	if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
 	return sk;
@@ -585,21 +585,21 @@ EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 #endif
 
 static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
-				       __be16 loc_port, __be32 loc_addr,
-				       __be16 rmt_port, __be32 rmt_addr,
-				       int dif, unsigned short hnum)
+				       const struct sk_lookup *params)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	__be32 loc_addr = params->daddr.ipv4;
+	__be32 rmt_addr = params->saddr.ipv4;
 
 	if (!net_eq(sock_net(sk), net) ||
-	    udp_sk(sk)->udp_port_hash != hnum ||
+	    udp_sk(sk)->udp_port_hash != params->hnum ||
 	    (inet->inet_daddr && inet->inet_daddr != rmt_addr) ||
-	    (inet->inet_dport != rmt_port && inet->inet_dport) ||
+	    (inet->inet_dport != params->sport && inet->inet_dport) ||
 	    (inet->inet_rcv_saddr && inet->inet_rcv_saddr != loc_addr) ||
 	    ipv6_only_sock(sk) ||
-	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != params->dif))
 		return false;
-	if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, dif))
+	if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, params->dif))
 		return false;
 	return true;
 }
@@ -626,10 +626,15 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 	int harderr;
 	int err;
 	struct net *net = dev_net(skb->dev);
-
-	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
-			iph->saddr, uh->source, skb->dev->ifindex, udptable,
-			NULL);
+	struct sk_lookup params = {
+		.saddr.ipv4 = iph->daddr,
+		.daddr.ipv4 = iph->saddr,
+		.sport = uh->dest,
+		.dport = uh->source,
+		.dif = skb->dev->ifindex,
+	};
+
+	sk = __udp4_lib_lookup(net, &params, udptable, NULL);
 	if (!sk) {
 		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
@@ -1956,9 +1961,16 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
 	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
 	unsigned int offset = offsetof(typeof(*sk), sk_node);
-	int dif = skb->dev->ifindex;
 	struct hlist_node *node;
 	struct sk_buff *nskb;
+	struct sk_lookup params = {
+		.saddr.ipv4 = saddr,
+		.daddr.ipv4 = daddr,
+		.sport = uh->source,
+		.dport = uh->dest,
+		.hnum = hnum,
+		.dif = skb->dev->ifindex,
+	};
 
 	if (use_hash2) {
 		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
@@ -1970,8 +1982,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	}
 
 	sk_for_each_entry_offset_rcu(sk, node, &hslot->head, offset) {
-		if (!__udp_is_mcast_sock(net, sk, uh->dest, daddr,
-					 uh->source, saddr, dif, hnum))
+		if (!__udp_is_mcast_sock(net, sk, &params))
 			continue;
 
 		if (!first) {
@@ -2159,13 +2170,10 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
  * If more than one socket found returns NULL
  */
 static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
-						  __be16 loc_port, __be32 loc_addr,
-						  __be16 rmt_port, __be32 rmt_addr,
-						  int dif)
+						  const struct sk_lookup *params)
 {
 	struct sock *sk, *result;
-	unsigned short hnum = ntohs(loc_port);
-	unsigned int slot = udp_hashfn(net, hnum, udp_table.mask);
+	unsigned int slot = udp_hashfn(net, params->hnum, udp_table.mask);
 	struct udp_hslot *hslot = &udp_table.hash[slot];
 
 	/* Do not bother scanning a too big list */
@@ -2174,8 +2182,7 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
 
 	result = NULL;
 	sk_for_each_rcu(sk, &hslot->head) {
-		if (__udp_is_mcast_sock(net, sk, loc_port, loc_addr,
-					rmt_port, rmt_addr, dif, hnum)) {
+		if (__udp_is_mcast_sock(net, sk, params)) {
 			if (result)
 				return NULL;
 			result = sk;
@@ -2190,21 +2197,20 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
  * if the first socket is an exact match and if not move on.
  */
 static struct sock *__udp4_lib_demux_lookup(struct net *net,
-					    __be16 loc_port, __be32 loc_addr,
-					    __be16 rmt_port, __be32 rmt_addr,
-					    int dif)
+					    const struct sk_lookup *params)
 {
-	unsigned short hnum = ntohs(loc_port);
-	unsigned int hash2 = udp4_portaddr_hash(net, loc_addr, hnum);
+	unsigned int hash2 = udp4_portaddr_hash(net, params->daddr.ipv4,
+						params->hnum);
 	unsigned int slot2 = hash2 & udp_table.mask;
 	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
-	INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr);
-	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
+	INET_ADDR_COOKIE(acookie, params->saddr.ipv4, params->daddr.ipv4);
+	const __portpair ports = INET_COMBINED_PORTS(params->sport,
+						     params->hnum);
 	struct sock *sk;
 
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		if (INET_MATCH(sk, net, acookie, rmt_addr,
-			       loc_addr, ports, dif))
+		if (INET_MATCH(sk, net, acookie, params->saddr.ipv4,
+			       params->daddr.ipv4, ports, params->dif))
 			return sk;
 		/* Only check first socket in chain */
 		break;
@@ -2215,11 +2221,13 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 void udp_v4_early_demux(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
+	struct sk_lookup params = {
+		.dif = skb->dev->ifindex,
+	};
 	const struct iphdr *iph;
 	const struct udphdr *uh;
 	struct sock *sk = NULL;
 	struct dst_entry *dst;
-	int dif = skb->dev->ifindex;
 	int ours;
 
 	/* validate the packet */
@@ -2228,6 +2236,11 @@ void udp_v4_early_demux(struct sk_buff *skb)
 
 	iph = ip_hdr(skb);
 	uh = udp_hdr(skb);
+	params.saddr.ipv4 = iph->saddr;
+	params.daddr.ipv4 = iph->daddr;
+	params.sport = uh->source;
+	params.dport = uh->dest;
+	params.hnum = ntohs(uh->dest);
 
 	if (skb->pkt_type == PACKET_BROADCAST ||
 	    skb->pkt_type == PACKET_MULTICAST) {
@@ -2244,12 +2257,9 @@ void udp_v4_early_demux(struct sk_buff *skb)
 				return;
 		}
 
-		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
-						   uh->source, iph->saddr, dif);
-	} else if (skb->pkt_type == PACKET_HOST) {
-		sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
-					     uh->source, iph->saddr, dif);
-	}
+		sk = __udp4_lib_mcast_demux_lookup(net, &params);
+	} else if (skb->pkt_type == PACKET_HOST)
+		sk = __udp4_lib_demux_lookup(net, &params);
 
 	if (!sk || !refcount_inc_not_zero(&sk->sk_refcnt))
 		return;
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 4515836d2a3a..5e0640877536 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -41,11 +41,17 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 	struct net *net = sock_net(in_skb->sk);
 
 	rcu_read_lock();
-	if (req->sdiag_family == AF_INET)
-		sk = __udp4_lib_lookup(net,
-				req->id.idiag_src[0], req->id.idiag_sport,
-				req->id.idiag_dst[0], req->id.idiag_dport,
-				req->id.idiag_if, tbl, NULL);
+	if (req->sdiag_family == AF_INET) {
+		struct sk_lookup params = {
+			.saddr.ipv4 = req->id.idiag_src[0],
+			.daddr.ipv4 = req->id.idiag_dst[0],
+			.sport = req->id.idiag_sport,
+			.dport = req->id.idiag_dport,
+			.dif   =  req->id.idiag_if,
+		};
+
+		sk = __udp4_lib_lookup(net, &params, tbl, NULL);
+	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6)
 		sk = __udp6_lib_lookup(net,
@@ -178,27 +184,38 @@ static int __udp_diag_destroy(struct sk_buff *in_skb,
 
 	rcu_read_lock();
 
-	if (req->sdiag_family == AF_INET)
-		sk = __udp4_lib_lookup(net,
-				req->id.idiag_dst[0], req->id.idiag_dport,
-				req->id.idiag_src[0], req->id.idiag_sport,
-				req->id.idiag_if, tbl, NULL);
+	if (req->sdiag_family == AF_INET) {
+		struct sk_lookup params = {
+			.saddr.ipv4 = req->id.idiag_dst[0],
+			.daddr.ipv4 = req->id.idiag_src[0],
+			.sport = req->id.idiag_dport,
+			.dport = req->id.idiag_sport,
+			.dif   = req->id.idiag_if,
+		};
+
+		sk = __udp4_lib_lookup(net, &params, tbl, NULL);
+	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6) {
 		if (ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_dst) &&
-		    ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_src))
-			sk = __udp4_lib_lookup(net,
-					req->id.idiag_dst[3], req->id.idiag_dport,
-					req->id.idiag_src[3], req->id.idiag_sport,
-					req->id.idiag_if, tbl, NULL);
-
-		else
+		    ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_src)) {
+			struct sk_lookup params = {
+				.saddr.ipv4 = req->id.idiag_dst[3],
+				.daddr.ipv4 = req->id.idiag_src[3],
+				.sport = req->id.idiag_dport,
+				.dport = req->id.idiag_sport,
+				.dif   = req->id.idiag_if,
+			};
+
+			sk = __udp4_lib_lookup(net, &params, tbl, NULL);
+		} else {
 			sk = __udp6_lib_lookup(net,
 					(struct in6_addr *)req->id.idiag_dst,
 					req->id.idiag_dport,
 					(struct in6_addr *)req->id.idiag_src,
 					req->id.idiag_sport,
 					req->id.idiag_if, tbl, NULL);
+		}
 	}
 #endif
 	else {
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index d767e35fff6b..972a0e40c59a 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -112,6 +112,14 @@ nf_tproxy_get_sock_v4(struct net *net, struct sk_buff *skb, void *hp,
 		      const struct net_device *in,
 		      const enum nf_tproxy_lookup_t lookup_type)
 {
+	struct sk_lookup params = {
+		.saddr.ipv4 = saddr,
+		.daddr.ipv4 = daddr,
+		.sport = sport,
+		.dport = dport,
+		.dif   = in->ifindex,
+	};
+
 	struct sock *sk;
 	struct tcphdr *tcph;
 
@@ -145,8 +153,7 @@ nf_tproxy_get_sock_v4(struct net *net, struct sk_buff *skb, void *hp,
 		}
 		break;
 	case IPPROTO_UDP:
-		sk = udp4_lib_lookup(net, saddr, sport, daddr, dport,
-				     in->ifindex);
+		sk = udp4_lib_lookup(net, &params);
 		if (sk) {
 			int connected = (sk->sk_state == TCP_ESTABLISHED);
 			int wildcard = (inet_sk(sk)->inet_rcv_saddr == 0);
-- 
2.1.4
