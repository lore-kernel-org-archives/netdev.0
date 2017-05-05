From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] tcp: randomize timestamps on syncookies
Date: Thu, 04 May 2017 19:22:37 -0700
Message-ID: <1493950957.7796.36.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493935361.7796.29.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170505002456.GH13320@breakpoint.cc>
         <20170505003208.GI13320@breakpoint.cc>
         <1493949548.7796.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33818 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753021AbdEECWj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 22:22:39 -0400
Received: by mail-pf0-f193.google.com with SMTP id d1so4242336pfe.1
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 19:22:39 -0700 (PDT)
In-Reply-To: <1493949548.7796.32.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Whole point of randomization was to hide server uptime, but an attacker
can simply start a syn flood and TCP generates 'old style' timestamps,
directly revealing server jiffies value.

Also, TSval sent by the server to a particular remote address vary
depending on syncookies being sent or not, potentially triggering PAWS
drops for innocent clients.

Lets implement proper randomization, including for SYNcookies.

Also we do not need to export sysctl_tcp_timestamps, since it is not
used from a module.

In v2, I added Florian feedback and contribution, adding tsoff to
tcp_get_cookie_sock()

Fixes: 95a22caee396c ("tcp: randomize tcp timestamp offsets for each connection")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Florian Westphal <fw@strlen.de>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/secure_seq.h |   10 ++++++----
 include/net/tcp.h        |    5 +++--
 net/core/secure_seq.c    |   31 +++++++++++++++++++------------
 net/ipv4/syncookies.c    |   12 ++++++++++--
 net/ipv4/tcp_input.c     |    8 +++-----
 net/ipv4/tcp_ipv4.c      |   31 +++++++++++++++++++------------
 net/ipv6/syncookies.c    |   10 +++++++++-
 net/ipv6/tcp_ipv6.c      |   32 +++++++++++++++++++-------------
 8 files changed, 88 insertions(+), 51 deletions(-)

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
index 270e5cc43c99e7030e95af218095cf9f283950bc..8c0e5a901d6424fbd01233cd3adfdce52076f7a9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -470,7 +470,7 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 /* From syncookies.c */
 struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 				 struct request_sock *req,
-				 struct dst_entry *dst);
+				 struct dst_entry *dst, u32 tsoff);
 int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 		      u32 cookie);
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb);
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
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 496b97e17aaf7ed2cf41cef303cb0696927f66ac..0257d965f11119acf8c55888d6e672d171ef5f08 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -16,6 +16,7 @@
 #include <linux/siphash.h>
 #include <linux/kernel.h>
 #include <linux/export.h>
+#include <net/secure_seq.h>
 #include <net/tcp.h>
 #include <net/route.h>
 
@@ -203,7 +204,7 @@ EXPORT_SYMBOL_GPL(__cookie_v4_check);
 
 struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 				 struct request_sock *req,
-				 struct dst_entry *dst)
+				 struct dst_entry *dst, u32 tsoff)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sock *child;
@@ -213,6 +214,7 @@ struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 						 NULL, &own_req);
 	if (child) {
 		atomic_set(&req->rsk_refcnt, 1);
+		tcp_sk(child)->tsoffset = tsoff;
 		sock_rps_save_rxhash(child, skb);
 		inet_csk_reqsk_queue_add(sk, req, child);
 	} else {
@@ -292,6 +294,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	struct rtable *rt;
 	__u8 rcv_wscale;
 	struct flowi4 fl4;
+	u32 tsoff = 0;
 
 	if (!sock_net(sk)->ipv4.sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -311,6 +314,11 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
+	if (tcp_opt.saw_tstamp && tcp_opt.rcv_tsecr) {
+		tsoff = secure_tcp_ts_off(ip_hdr(skb)->daddr, ip_hdr(skb)->saddr);
+		tcp_opt.rcv_tsecr -= tsoff;
+	}
+
 	if (!cookie_timestamp_decode(&tcp_opt))
 		goto out;
 
@@ -381,7 +389,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	ireq->rcv_wscale  = rcv_wscale;
 	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), &rt->dst);
 
-	ret = tcp_get_cookie_sock(sk, skb, req, &rt->dst);
+	ret = tcp_get_cookie_sock(sk, skb, req, &rt->dst, tsoff);
 	/* ip_queue_xmit() depends on our flow being setup
 	 * Normal sockets get it right from inet_csk_route_child_sock()
 	 */
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
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 895ff650db43017ef39344679771d94ad6eaaf00..5abc3692b9011b140816dc4ce6223e79e5defddb 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -18,6 +18,7 @@
 #include <linux/random.h>
 #include <linux/siphash.h>
 #include <linux/kernel.h>
+#include <net/secure_seq.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
 
@@ -143,6 +144,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	int mss;
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
+	u32 tsoff = 0;
 
 	if (!sock_net(sk)->ipv4.sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -162,6 +164,12 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, 0, NULL);
 
+	if (tcp_opt.saw_tstamp && tcp_opt.rcv_tsecr) {
+		tsoff = secure_tcpv6_ts_off(ipv6_hdr(skb)->daddr.s6_addr32,
+					    ipv6_hdr(skb)->saddr.s6_addr32);
+		tcp_opt.rcv_tsecr -= tsoff;
+	}
+
 	if (!cookie_timestamp_decode(&tcp_opt))
 		goto out;
 
@@ -242,7 +250,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq->rcv_wscale = rcv_wscale;
 	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), dst);
 
-	ret = tcp_get_cookie_sock(sk, skb, req, dst);
+	ret = tcp_get_cookie_sock(sk, skb, req, dst, tsoff);
 out:
 	return ret;
 out_free:
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
 
