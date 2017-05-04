From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: randomize timestamps on syncookies
Date: Thu, 04 May 2017 15:02:41 -0700
Message-ID: <1493935361.7796.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33625 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751459AbdEDWCo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 18:02:44 -0400
Received: by mail-pf0-f194.google.com with SMTP id b23so3649348pfc.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 15:02:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Whole point of randomization was to hide server uptime, but an attacker
can simply start a syn flood and TCP generates 'old style' timestamps,
directly revealing server jiffies value.

Also, TSval sent by the server to a particular remote address vary depending
on syncookies being sent or not, potentially triggering PAWS drops for
innocent clients.

Lets implement proper randomization, including for SYNcookies.

Also we do not need to export sysctl_tcp_timestamps, it is not used from
a module.

Fixes: 95a22caee396c ("tcp: randomize tcp timestamp offsets for each connection")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Florian Westphal <fw@strlen.de>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/secure_seq.h |   10 ++++++----
 include/net/tcp.h        |    3 ++-
 net/core/secure_seq.c    |   31 +++++++++++++++++++------------
 net/ipv4/tcp_input.c     |    8 +++-----
 net/ipv4/tcp_ipv4.c      |   31 +++++++++++++++++++------------
 net/ipv6/tcp_ipv6.c      |   32 +++++++++++++++++++-------------
 6 files changed, 68 insertions(+), 47 deletions(-)

diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index fe236b3429f0d8caeb1adc367b5b4a20591c848b..b94006f6fbdde0d78fe33b9c2d86159e291c30cf 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -6,10 +6,12 @@
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport);
 u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 			       __be16 dport);
-u32 secure_tcp_seq_and_tsoff(__be32 saddr, __be32 daddr,
-			     __be16 sport, __be16 dport, u32 *tsoff);
-u32 secure_tcpv6_seq_and_tsoff(const __be32 *saddr, const __be32 *daddr,
-			       __be16 sport, __be16 dport, u32 *tsoff);
+u32 secure_tcp_seq(__be32 saddr, __be32 daddr,
+		   __be16 sport, __be16 dport);
+u32 secure_tcp_ts_off(__be32 saddr, __be32 daddr);
+u32 secure_tcpv6_seq(const __be32 *saddr, const __be32 *daddr,
+		     __be16 sport, __be16 dport);
+u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr);
 u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				__be16 sport, __be16 dport);
 u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 270e5cc43c99e7030e95af218095cf9f283950bc..1be353fc5cb1c313e8fec350d8a0a9ccc8f770ee 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1822,7 +1822,8 @@ struct tcp_request_sock_ops {
 #endif
 	struct dst_entry *(*route_req)(const struct sock *sk, struct flowi *fl,
 				       const struct request_sock *req);
-	__u32 (*init_seq_tsoff)(const struct sk_buff *skb, u32 *tsoff);
+	u32 (*init_seq)(const struct sk_buff *skb);
+	u32 (*init_ts_off)(const struct sk_buff *skb);
 	int (*send_synack)(const struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
 			   struct tcp_fastopen_cookie *foc,
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 6bd2f8fb0476baabf507557fc0d06b6787511c70..ae35cce3a40d70387bee815798933aa43a0e6d84 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -24,9 +24,13 @@ static siphash_key_t ts_secret __read_mostly;
 
 static __always_inline void net_secret_init(void)
 {
-	net_get_random_once(&ts_secret, sizeof(ts_secret));
 	net_get_random_once(&net_secret, sizeof(net_secret));
 }
+
+static __always_inline void ts_secret_init(void)
+{
+	net_get_random_once(&ts_secret, sizeof(ts_secret));
+}
 #endif
 
 #ifdef CONFIG_INET
@@ -47,7 +51,7 @@ static u32 seq_scale(u32 seq)
 #endif
 
 #if IS_ENABLED(CONFIG_IPV6)
-static u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr)
+u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr)
 {
 	const struct {
 		struct in6_addr saddr;
@@ -60,12 +64,14 @@ static u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr)
 	if (sysctl_tcp_timestamps != 1)
 		return 0;
 
+	ts_secret_init();
 	return siphash(&combined, offsetofend(typeof(combined), daddr),
 		       &ts_secret);
 }
+EXPORT_SYMBOL(secure_tcpv6_ts_off);
 
-u32 secure_tcpv6_seq_and_tsoff(const __be32 *saddr, const __be32 *daddr,
-			       __be16 sport, __be16 dport, u32 *tsoff)
+u32 secure_tcpv6_seq(const __be32 *saddr, const __be32 *daddr,
+		     __be16 sport, __be16 dport)
 {
 	const struct {
 		struct in6_addr saddr;
@@ -78,14 +84,14 @@ u32 secure_tcpv6_seq_and_tsoff(const __be32 *saddr, const __be32 *daddr,
 		.sport = sport,
 		.dport = dport
 	};
-	u64 hash;
+	u32 hash;
+
 	net_secret_init();
 	hash = siphash(&combined, offsetofend(typeof(combined), dport),
 		       &net_secret);
-	*tsoff = secure_tcpv6_ts_off(saddr, daddr);
 	return seq_scale(hash);
 }
-EXPORT_SYMBOL(secure_tcpv6_seq_and_tsoff);
+EXPORT_SYMBOL(secure_tcpv6_seq);
 
 u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 			       __be16 dport)
@@ -107,11 +113,12 @@ EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
 
 #ifdef CONFIG_INET
-static u32 secure_tcp_ts_off(__be32 saddr, __be32 daddr)
+u32 secure_tcp_ts_off(__be32 saddr, __be32 daddr)
 {
 	if (sysctl_tcp_timestamps != 1)
 		return 0;
 
+	ts_secret_init();
 	return siphash_2u32((__force u32)saddr, (__force u32)daddr,
 			    &ts_secret);
 }
@@ -121,15 +128,15 @@ static u32 secure_tcp_ts_off(__be32 saddr, __be32 daddr)
  * it would be easy enough to have the former function use siphash_4u32, passing
  * the arguments as separate u32.
  */
-u32 secure_tcp_seq_and_tsoff(__be32 saddr, __be32 daddr,
-			     __be16 sport, __be16 dport, u32 *tsoff)
+u32 secure_tcp_seq(__be32 saddr, __be32 daddr,
+		   __be16 sport, __be16 dport)
 {
-	u64 hash;
+	u32 hash;
+
 	net_secret_init();
 	hash = siphash_3u32((__force u32)saddr, (__force u32)daddr,
 			    (__force u32)sport << 16 | (__force u32)dport,
 			    &net_secret);
-	*tsoff = secure_tcp_ts_off(saddr, daddr);
 	return seq_scale(hash);
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9739962bfb3fd2d39cb13f643def223f4f17fcb6..5a3ad09e2786fb41ad12681d09938c645b69866d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -85,7 +85,6 @@ int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
-EXPORT_SYMBOL(sysctl_tcp_timestamps);
 
 /* rfc5961 challenge ack rate limiting */
 int sysctl_tcp_challenge_ack_limit = 1000;
@@ -6347,8 +6346,8 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	if (isn && tmp_opt.tstamp_ok)
-		af_ops->init_seq_tsoff(skb, &tcp_rsk(req)->ts_off);
+	if (tmp_opt.tstamp_ok)
+		tcp_rsk(req)->ts_off = af_ops->init_ts_off(skb);
 
 	if (!want_cookie && !isn) {
 		/* Kill the following clause, if you dislike this way. */
@@ -6368,7 +6367,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			goto drop_and_release;
 		}
 
-		isn = af_ops->init_seq_tsoff(skb, &tcp_rsk(req)->ts_off);
+		isn = af_ops->init_seq(skb);
 	}
 	if (!dst) {
 		dst = af_ops->route_req(sk, &fl, req);
@@ -6380,7 +6379,6 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 
 	if (want_cookie) {
 		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
-		tcp_rsk(req)->ts_off = 0;
 		req->cookie_ts = tmp_opt.tstamp_ok;
 		if (!tmp_opt.tstamp_ok)
 			inet_rsk(req)->ecn_ok = 0;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cbbafe546c0f5c5f43531eaf24f5b460264785c6..e7d4e47f83ae2074b6ca602bc50a39d5defb85c5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -94,12 +94,18 @@ static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 struct inet_hashinfo tcp_hashinfo;
 EXPORT_SYMBOL(tcp_hashinfo);
 
-static u32 tcp_v4_init_seq_and_tsoff(const struct sk_buff *skb, u32 *tsoff)
+static u32 tcp_v4_init_seq(const struct sk_buff *skb)
 {
-	return secure_tcp_seq_and_tsoff(ip_hdr(skb)->daddr,
-					ip_hdr(skb)->saddr,
-					tcp_hdr(skb)->dest,
-					tcp_hdr(skb)->source, tsoff);
+	return secure_tcp_seq(ip_hdr(skb)->daddr,
+			      ip_hdr(skb)->saddr,
+			      tcp_hdr(skb)->dest,
+			      tcp_hdr(skb)->source);
+}
+
+static u32 tcp_v4_init_ts_off(const struct sk_buff *skb)
+{
+	return secure_tcp_ts_off(ip_hdr(skb)->daddr,
+				 ip_hdr(skb)->saddr);
 }
 
 int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
@@ -232,13 +238,13 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	rt = NULL;
 
 	if (likely(!tp->repair)) {
-		seq = secure_tcp_seq_and_tsoff(inet->inet_saddr,
-					       inet->inet_daddr,
-					       inet->inet_sport,
-					       usin->sin_port,
-					       &tp->tsoffset);
 		if (!tp->write_seq)
-			tp->write_seq = seq;
+			tp->write_seq = secure_tcp_seq(inet->inet_saddr,
+						       inet->inet_daddr,
+						       inet->inet_sport,
+						       usin->sin_port);
+		tp->tsoffset = secure_tcp_ts_off(inet->inet_saddr,
+						 inet->inet_daddr);
 	}
 
 	inet->inet_id = tp->write_seq ^ jiffies;
@@ -1239,7 +1245,8 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 	.cookie_init_seq =	cookie_v4_init_sequence,
 #endif
 	.route_req	=	tcp_v4_route_req,
-	.init_seq_tsoff	=	tcp_v4_init_seq_and_tsoff,
+	.init_seq	=	tcp_v4_init_seq,
+	.init_ts_off	=	tcp_v4_init_ts_off,
 	.send_synack	=	tcp_v4_send_synack,
 };
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8e42e8f54b705ed8780890c7434feeff1055599a..aeb9497b5bb754f2277dec4a4dec02bf25bdbbe5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -101,12 +101,18 @@ static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 	}
 }
 
-static u32 tcp_v6_init_seq_and_tsoff(const struct sk_buff *skb, u32 *tsoff)
+static u32 tcp_v6_init_seq(const struct sk_buff *skb)
 {
-	return secure_tcpv6_seq_and_tsoff(ipv6_hdr(skb)->daddr.s6_addr32,
-					  ipv6_hdr(skb)->saddr.s6_addr32,
-					  tcp_hdr(skb)->dest,
-					  tcp_hdr(skb)->source, tsoff);
+	return secure_tcpv6_seq(ipv6_hdr(skb)->daddr.s6_addr32,
+				ipv6_hdr(skb)->saddr.s6_addr32,
+				tcp_hdr(skb)->dest,
+				tcp_hdr(skb)->source);
+}
+
+static u32 tcp_v6_init_ts_off(const struct sk_buff *skb)
+{
+	return secure_tcpv6_ts_off(ipv6_hdr(skb)->daddr.s6_addr32,
+				   ipv6_hdr(skb)->saddr.s6_addr32);
 }
 
 static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
@@ -122,7 +128,6 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	struct flowi6 fl6;
 	struct dst_entry *dst;
 	int addr_type;
-	u32 seq;
 	int err;
 	struct inet_timewait_death_row *tcp_death_row = &sock_net(sk)->ipv4.tcp_death_row;
 
@@ -282,13 +287,13 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	sk_set_txhash(sk);
 
 	if (likely(!tp->repair)) {
-		seq = secure_tcpv6_seq_and_tsoff(np->saddr.s6_addr32,
-						 sk->sk_v6_daddr.s6_addr32,
-						 inet->inet_sport,
-						 inet->inet_dport,
-						 &tp->tsoffset);
 		if (!tp->write_seq)
-			tp->write_seq = seq;
+			tp->write_seq = secure_tcpv6_seq(np->saddr.s6_addr32,
+							 sk->sk_v6_daddr.s6_addr32,
+							 inet->inet_sport,
+							 inet->inet_dport);
+		tp->tsoffset = secure_tcpv6_ts_off(np->saddr.s6_addr32,
+						   sk->sk_v6_daddr.s6_addr32);
 	}
 
 	if (tcp_fastopen_defer_connect(sk, &err))
@@ -749,7 +754,8 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 	.cookie_init_seq =	cookie_v6_init_sequence,
 #endif
 	.route_req	=	tcp_v6_route_req,
-	.init_seq_tsoff	=	tcp_v6_init_seq_and_tsoff,
+	.init_seq	=	tcp_v6_init_seq,
+	.init_ts_off	=	tcp_v6_init_ts_off,
 	.send_synack	=	tcp_v6_send_synack,
 };
 
