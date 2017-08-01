From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 03/10] net: ipv4: Convert inet socket lookups to new struct
Date: Mon, 31 Jul 2017 20:13:19 -0700
Message-ID: <1501557206-27503-4-git-send-email-dsahern@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35059 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbdHADNl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:41 -0400
Received: by mail-pf0-f196.google.com with SMTP id q85so514582pfq.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:41 -0700 (PDT)
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the various inet_lookup functions to use the new sk_lookup
struct.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/inet_hashtables.h       | 57 ++++++++++++++--------------------
 net/dccp/ipv4.c                     | 19 +++++++++---
 net/ipv4/inet_diag.c                | 33 ++++++++++++++------
 net/ipv4/inet_hashtables.c          | 48 +++++++++++++++-------------
 net/ipv4/netfilter/nf_socket_ipv4.c |  5 ++-
 net/ipv4/tcp_ipv4.c                 | 62 +++++++++++++++++++++++++++----------
 net/ipv4/udp_diag.c                 |  3 ++
 net/netfilter/xt_TPROXY.c           | 10 +++---
 8 files changed, 142 insertions(+), 95 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 5026b1f08bb8..c5f4dc3c06e4 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -218,19 +218,16 @@ void inet_unhash(struct sock *sk);
 struct sock *__inet_lookup_listener(struct net *net,
 				    struct inet_hashinfo *hashinfo,
 				    struct sk_buff *skb, int doff,
-				    const __be32 saddr, const __be16 sport,
-				    const __be32 daddr,
-				    const unsigned short hnum,
-				    const int dif);
+				    struct sk_lookup *params);
 
 static inline struct sock *inet_lookup_listener(struct net *net,
 		struct inet_hashinfo *hashinfo,
 		struct sk_buff *skb, int doff,
-		__be32 saddr, __be16 sport,
-		__be32 daddr, __be16 dport, int dif)
+		struct sk_lookup *params)
 {
-	return __inet_lookup_listener(net, hashinfo, skb, doff, saddr, sport,
-				      daddr, ntohs(dport), dif);
+	params->hnum = ntohs(params->dport);
+
+	return __inet_lookup_listener(net, hashinfo, skb, doff, params);
 }
 
 /* Socket demux engine toys. */
@@ -286,53 +283,44 @@ static inline struct sock *inet_lookup_listener(struct net *net,
  */
 struct sock *__inet_lookup_established(struct net *net,
 				       struct inet_hashinfo *hashinfo,
-				       const __be32 saddr, const __be16 sport,
-				       const __be32 daddr, const u16 hnum,
-				       const int dif);
+				       const struct sk_lookup *params);
 
 static inline struct sock *
 	inet_lookup_established(struct net *net, struct inet_hashinfo *hashinfo,
-				const __be32 saddr, const __be16 sport,
-				const __be32 daddr, const __be16 dport,
-				const int dif)
+				struct sk_lookup *params)
 {
-	return __inet_lookup_established(net, hashinfo, saddr, sport, daddr,
-					 ntohs(dport), dif);
+	params->hnum = ntohs(params->dport);
+
+	return __inet_lookup_established(net, hashinfo, params);
 }
 
 static inline struct sock *__inet_lookup(struct net *net,
 					 struct inet_hashinfo *hashinfo,
 					 struct sk_buff *skb, int doff,
-					 const __be32 saddr, const __be16 sport,
-					 const __be32 daddr, const __be16 dport,
-					 const int dif,
+					 struct sk_lookup *params,
 					 bool *refcounted)
 {
-	u16 hnum = ntohs(dport);
 	struct sock *sk;
 
-	sk = __inet_lookup_established(net, hashinfo, saddr, sport,
-				       daddr, hnum, dif);
+	params->hnum = ntohs(params->dport);
+
+	sk = __inet_lookup_established(net, hashinfo, params);
 	*refcounted = true;
 	if (sk)
 		return sk;
 	*refcounted = false;
-	return __inet_lookup_listener(net, hashinfo, skb, doff, saddr,
-				      sport, daddr, hnum, dif);
+	return __inet_lookup_listener(net, hashinfo, skb, doff, params);
 }
 
 static inline struct sock *inet_lookup(struct net *net,
 				       struct inet_hashinfo *hashinfo,
 				       struct sk_buff *skb, int doff,
-				       const __be32 saddr, const __be16 sport,
-				       const __be32 daddr, const __be16 dport,
-				       const int dif)
+				       struct sk_lookup *params)
 {
 	struct sock *sk;
 	bool refcounted;
 
-	sk = __inet_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
-			   dport, dif, &refcounted);
+	sk = __inet_lookup(net, hashinfo, skb, doff, params, &refcounted);
 
 	if (sk && !refcounted && !refcount_inc_not_zero(&sk->sk_refcnt))
 		sk = NULL;
@@ -342,21 +330,22 @@ static inline struct sock *inet_lookup(struct net *net,
 static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 					     struct sk_buff *skb,
 					     int doff,
-					     const __be16 sport,
-					     const __be16 dport,
+					     struct sk_lookup *params,
 					     bool *refcounted)
 {
 	struct sock *sk = skb_steal_sock(skb);
 	const struct iphdr *iph = ip_hdr(skb);
 
+	params->dif = inet_iif(skb);
+	params->saddr.ipv4 = iph->saddr;
+	params->daddr.ipv4 = iph->daddr;
+
 	*refcounted = true;
 	if (sk)
 		return sk;
 
 	return __inet_lookup(dev_net(skb_dst(skb)->dev), hashinfo, skb,
-			     doff, iph->saddr, sport,
-			     iph->daddr, dport, inet_iif(skb),
-			     refcounted);
+			     doff, params, refcounted);
 }
 
 u32 inet6_ehashfn(const struct net *net,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f85d901f4e3f..f98a65fa5f5e 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -244,6 +244,11 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	__u64 seq;
 	int err;
 	struct net *net = dev_net(skb->dev);
+	struct sk_lookup params = {
+		.saddr.ipv4 = iph->daddr,
+		.daddr.ipv4 = iph->saddr,
+		.dif = inet_iif(skb),
+	};
 
 	/* Only need dccph_dport & dccph_sport which are the first
 	 * 4 bytes in dccp header.
@@ -253,10 +258,11 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_dport) > 8);
 	dh = (struct dccp_hdr *)(skb->data + offset);
 
-	sk = __inet_lookup_established(net, &dccp_hashinfo,
-				       iph->daddr, dh->dccph_dport,
-				       iph->saddr, ntohs(dh->dccph_sport),
-				       inet_iif(skb));
+	params.sport = dh->dccph_dport;
+	params.dport = dh->dccph_sport;
+	params.hnum = ntohs(dh->dccph_sport);
+
+	sk = inet_lookup_established(net, &dccp_hashinfo, &params);
 	if (!sk) {
 		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;
@@ -763,6 +769,7 @@ EXPORT_SYMBOL_GPL(dccp_invalid_packet);
 /* this is called when real data arrives */
 static int dccp_v4_rcv(struct sk_buff *skb)
 {
+	struct sk_lookup params = {};
 	const struct dccp_hdr *dh;
 	const struct iphdr *iph;
 	bool refcounted;
@@ -801,9 +808,11 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 				  DCCP_SKB_CB(skb)->dccpd_ack_seq);
 	}
 
+	params.sport = dh->dccph_sport;
+	params.dport = dh->dccph_dport;
 lookup:
 	sk = __inet_lookup_skb(&dccp_hashinfo, skb, __dccp_hdr_len(dh),
-			       dh->dccph_sport, dh->dccph_dport, &refcounted);
+			       &params, &refcounted);
 	if (!sk) {
 		dccp_pr_debug("failed to look up flow ID in table and "
 			      "get corresponding socket\n");
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 3828b3a805cd..6c3bc4e408d0 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -396,18 +396,33 @@ struct sock *inet_diag_find_one_icsk(struct net *net,
 	struct sock *sk;
 
 	rcu_read_lock();
-	if (req->sdiag_family == AF_INET)
-		sk = inet_lookup(net, hashinfo, NULL, 0, req->id.idiag_dst[0],
-				 req->id.idiag_dport, req->id.idiag_src[0],
-				 req->id.idiag_sport, req->id.idiag_if);
+	if (req->sdiag_family == AF_INET) {
+		struct sk_lookup params = {
+			.saddr.ipv4 = req->id.idiag_dst[0],
+			.daddr.ipv4 = req->id.idiag_src[0],
+			.sport = req->id.idiag_dport,
+			.dport = req->id.idiag_sport,
+			.hnum = ntohs(req->id.idiag_sport),
+			.dif = req->id.idiag_if,
+		};
+
+		sk = inet_lookup(net, hashinfo, NULL, 0, &params);
+	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6) {
 		if (ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_dst) &&
-		    ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_src))
-			sk = inet_lookup(net, hashinfo, NULL, 0, req->id.idiag_dst[3],
-					 req->id.idiag_dport, req->id.idiag_src[3],
-					 req->id.idiag_sport, req->id.idiag_if);
-		else
+		    ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_src)) {
+			struct sk_lookup params = {
+				.saddr.ipv4 = req->id.idiag_dst[3],
+				.daddr.ipv4 = req->id.idiag_src[3],
+				.sport = req->id.idiag_dport,
+				.dport = req->id.idiag_sport,
+				.hnum = ntohs(req->id.idiag_sport),
+				.dif = req->id.idiag_if,
+			};
+
+			sk = inet_lookup(net, hashinfo, NULL, 0, &params);
+		} else
 			sk = inet6_lookup(net, hashinfo, NULL, 0,
 					  (struct in6_addr *)req->id.idiag_dst,
 					  req->id.idiag_dport,
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 2e3389d614d1..5fe9300795b8 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -169,26 +169,28 @@ int __inet_inherit_port(const struct sock *sk, struct sock *child)
 EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
 static inline int compute_score(struct sock *sk, struct net *net,
-				const unsigned short hnum, const __be32 daddr,
-				const int dif, bool exact_dif)
+				const struct sk_lookup *params)
 {
 	int score = -1;
 	struct inet_sock *inet = inet_sk(sk);
 
-	if (net_eq(sock_net(sk), net) && inet->inet_num == hnum &&
-			!ipv6_only_sock(sk)) {
+	if (net_eq(sock_net(sk), net) &&
+	    inet->inet_num == params->hnum &&
+	    !ipv6_only_sock(sk)) {
 		__be32 rcv_saddr = inet->inet_rcv_saddr;
+		int rc;
+
 		score = sk->sk_family == PF_INET ? 2 : 1;
 		if (rcv_saddr) {
-			if (rcv_saddr != daddr)
+			if (rcv_saddr != params->daddr.ipv4)
 				return -1;
 			score += 4;
 		}
-		if (sk->sk_bound_dev_if || exact_dif) {
-			if (sk->sk_bound_dev_if != dif)
-				return -1;
+		rc = sk_lookup_device_cmp(sk, params);
+		if (rc < 0)
+			return -1;
+		if (rc > 0)
 			score += 4;
-		}
 		if (sk->sk_incoming_cpu == raw_smp_processor_id())
 			score++;
 	}
@@ -206,24 +208,25 @@ static inline int compute_score(struct sock *sk, struct net *net,
 struct sock *__inet_lookup_listener(struct net *net,
 				    struct inet_hashinfo *hashinfo,
 				    struct sk_buff *skb, int doff,
-				    const __be32 saddr, __be16 sport,
-				    const __be32 daddr, const unsigned short hnum,
-				    const int dif)
+				    struct sk_lookup *params)
 {
-	unsigned int hash = inet_lhashfn(net, hnum);
+	unsigned int hash = inet_lhashfn(net, params->hnum);
 	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
 	int score, hiscore = 0, matches = 0, reuseport = 0;
-	bool exact_dif = inet_exact_dif_match(net, skb);
 	struct sock *sk, *result = NULL;
 	u32 phash = 0;
 
+	params->exact_dif = inet_exact_dif_match(net, skb);
+
 	sk_for_each_rcu(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
+		score = compute_score(sk, net, params);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-				phash = inet_ehashfn(net, daddr, hnum,
-						     saddr, sport);
+				phash = inet_ehashfn(net, params->daddr.ipv4,
+						     params->hnum,
+						     params->saddr.ipv4,
+						     params->sport);
 				result = reuseport_select_sock(sk, phash,
 							       skb, doff);
 				if (result)
@@ -265,11 +268,14 @@ void sock_edemux(struct sk_buff *skb)
 EXPORT_SYMBOL(sock_edemux);
 
 struct sock *__inet_lookup_established(struct net *net,
-				  struct inet_hashinfo *hashinfo,
-				  const __be32 saddr, const __be16 sport,
-				  const __be32 daddr, const u16 hnum,
-				  const int dif)
+				       struct inet_hashinfo *hashinfo,
+				       const struct sk_lookup *params)
 {
+	__be32 saddr = params->saddr.ipv4;
+	__be32 daddr = params->daddr.ipv4;
+	__be16 sport = params->sport;
+	u16 hnum = params->hnum;
+	int dif = params->dif;
 	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
 	struct sock *sk;
diff --git a/net/ipv4/netfilter/nf_socket_ipv4.c b/net/ipv4/netfilter/nf_socket_ipv4.c
index 121767b36763..b0f9954712f9 100644
--- a/net/ipv4/netfilter/nf_socket_ipv4.c
+++ b/net/ipv4/netfilter/nf_socket_ipv4.c
@@ -86,14 +86,13 @@ nf_socket_get_sock_v4(struct net *net, struct sk_buff *skb, const int doff,
 		.daddr.ipv4 = daddr,
 		.sport = sport,
 		.dport = dport,
+		.hnum = ntohs(dport),
 		.dif = in->ifindex,
 	};
 
 	switch (protocol) {
 	case IPPROTO_TCP:
-		return inet_lookup(net, &tcp_hashinfo, skb, doff,
-				   saddr, sport, daddr, dport,
-				   in->ifindex);
+		return inet_lookup(net, &tcp_hashinfo, skb, doff, &params);
 	case IPPROTO_UDP:
 		return udp4_lib_lookup(net, &params);
 	}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3a19ea28339f..a83d1d437abc 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -382,10 +382,16 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	u32 delta_us;
 	int err;
 	struct net *net = dev_net(icmp_skb->dev);
-
-	sk = __inet_lookup_established(net, &tcp_hashinfo, iph->daddr,
-				       th->dest, iph->saddr, ntohs(th->source),
-				       inet_iif(icmp_skb));
+	struct sk_lookup params = {
+		.saddr.ipv4 = iph->daddr,
+		.daddr.ipv4 = iph->saddr,
+		.sport = th->dest,
+		.dport = th->source,
+		.hnum  = ntohs(th->source),
+		.dif   = inet_iif(icmp_skb),
+	};
+
+	sk = inet_lookup_established(net, &tcp_hashinfo, &params);
 	if (!sk) {
 		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;
@@ -651,6 +657,15 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 		key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)
 					&ip_hdr(skb)->saddr, AF_INET);
 	} else if (hash_location) {
+		struct sk_lookup params = {
+			.saddr.ipv4 = ip_hdr(skb)->saddr,
+			.daddr.ipv4 = ip_hdr(skb)->daddr,
+			.sport = th->source,
+			.dport = th->source,
+			.hnum  = ntohs(th->source),
+			.dif   = inet_iif(skb),
+		};
+
 		/*
 		 * active side is lost. Try to find listening socket through
 		 * source port, and then find md5 key through listening socket.
@@ -658,10 +673,8 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 		 * Incoming packet is checked with md5 hash with finding key,
 		 * no RST generated if md5 hash doesn't match.
 		 */
-		sk1 = __inet_lookup_listener(net, &tcp_hashinfo, NULL, 0,
-					     ip_hdr(skb)->saddr,
-					     th->source, ip_hdr(skb)->daddr,
-					     ntohs(th->source), inet_iif(skb));
+		sk1 = inet_lookup_listener(net, &tcp_hashinfo, NULL, 0,
+					   &params);
 		/* don't send rst if it can't find key */
 		if (!sk1)
 			goto out;
@@ -1509,6 +1522,9 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	struct sock *sk;
+	struct sk_lookup params = {
+		.dif = skb->skb_iif,
+	};
 
 	if (skb->pkt_type != PACKET_HOST)
 		return;
@@ -1522,10 +1538,13 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	if (th->doff < sizeof(struct tcphdr) / 4)
 		return;
 
-	sk = __inet_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
-				       iph->saddr, th->source,
-				       iph->daddr, ntohs(th->dest),
-				       skb->skb_iif);
+	params.saddr.ipv4 = iph->saddr;
+	params.daddr.ipv4 = iph->daddr;
+	params.sport = th->source;
+	params.dport = th->dest;
+	params.hnum  = ntohs(th->dest),
+
+	sk = inet_lookup_established(dev_net(skb->dev), &tcp_hashinfo, &params);
 	if (sk) {
 		skb->sk = sk;
 		skb->destructor = sock_edemux;
@@ -1645,6 +1664,7 @@ EXPORT_SYMBOL(tcp_filter);
 int tcp_v4_rcv(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
+	struct sk_lookup params = { };
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	bool refcounted;
@@ -1693,9 +1713,11 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->ip_dsfield = ipv4_get_dsfield(iph);
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
+	params.sport = th->source;
+	params.dport = th->dest;
 lookup:
-	sk = __inet_lookup_skb(&tcp_hashinfo, skb, __tcp_hdrlen(th), th->source,
-			       th->dest, &refcounted);
+	sk = __inet_lookup_skb(&tcp_hashinfo, skb, __tcp_hdrlen(th), &params,
+			       &refcounted);
 	if (!sk)
 		goto no_tcp_socket;
 
@@ -1819,12 +1841,18 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	}
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
+		struct sk_lookup params = {
+			.saddr.ipv4 = iph->saddr,
+			.daddr.ipv4 = iph->daddr,
+			.sport = th->source,
+			.dport = th->dest,
+			.hnum  = ntohs(th->dest),
+			.dif   = inet_iif(skb),
+		};
 		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
 							&tcp_hashinfo, skb,
 							__tcp_hdrlen(th),
-							iph->saddr, th->source,
-							iph->daddr, th->dest,
-							inet_iif(skb));
+							&params);
 		if (sk2) {
 			inet_twsk_deschedule_put(inet_twsk(sk));
 			sk = sk2;
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 5e0640877536..d7f6af42ebcc 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -47,6 +47,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 			.daddr.ipv4 = req->id.idiag_dst[0],
 			.sport = req->id.idiag_sport,
 			.dport = req->id.idiag_dport,
+			.hnum  = ntohs(req->id.idiag_dport),
 			.dif   =  req->id.idiag_if,
 		};
 
@@ -190,6 +191,7 @@ static int __udp_diag_destroy(struct sk_buff *in_skb,
 			.daddr.ipv4 = req->id.idiag_src[0],
 			.sport = req->id.idiag_dport,
 			.dport = req->id.idiag_sport,
+			.hnum  = ntohs(req->id.idiag_sport),
 			.dif   = req->id.idiag_if,
 		};
 
@@ -204,6 +206,7 @@ static int __udp_diag_destroy(struct sk_buff *in_skb,
 				.daddr.ipv4 = req->id.idiag_src[3],
 				.sport = req->id.idiag_dport,
 				.dport = req->id.idiag_sport,
+				.hnum  = ntohs(req->id.idiag_sport),
 				.dif   = req->id.idiag_if,
 			};
 
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 972a0e40c59a..5cce7eb7dea2 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -117,6 +117,7 @@ nf_tproxy_get_sock_v4(struct net *net, struct sk_buff *skb, void *hp,
 		.daddr.ipv4 = daddr,
 		.sport = sport,
 		.dport = dport,
+		.hnum  = ntohs(dport),
 		.dif   = in->ifindex,
 	};
 
@@ -129,11 +130,9 @@ nf_tproxy_get_sock_v4(struct net *net, struct sk_buff *skb, void *hp,
 		case NFT_LOOKUP_LISTENER:
 			tcph = hp;
 			sk = inet_lookup_listener(net, &tcp_hashinfo, skb,
-						    ip_hdrlen(skb) +
+						  ip_hdrlen(skb) +
 						      __tcp_hdrlen(tcph),
-						    saddr, sport,
-						    daddr, dport,
-						    in->ifindex);
+						  &params);
 
 			if (sk && !refcount_inc_not_zero(&sk->sk_refcnt))
 				sk = NULL;
@@ -145,8 +144,7 @@ nf_tproxy_get_sock_v4(struct net *net, struct sk_buff *skb, void *hp,
 			break;
 		case NFT_LOOKUP_ESTABLISHED:
 			sk = inet_lookup_established(net, &tcp_hashinfo,
-						    saddr, sport, daddr, dport,
-						    in->ifindex);
+						     &params);
 			break;
 		default:
 			BUG();
-- 
2.1.4
