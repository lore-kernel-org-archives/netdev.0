From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/4] tcp: Namespaceify sysctl_tcp_timestamps
Date: Wed,  7 Jun 2017 10:34:39 -0700
Message-ID: <20170607173439.17092-5-edumazet@google.com>
References: <20170607173439.17092-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36063 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdFGRey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 13:34:54 -0400
Received: by mail-pf0-f172.google.com with SMTP id x63so7994017pff.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 10:34:54 -0700 (PDT)
In-Reply-To: <20170607173439.17092-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/secure_seq.h   |  5 +++--
 include/net/tcp.h          |  3 +--
 net/core/secure_seq.c      |  9 +++++----
 net/ipv4/syncookies.c      |  6 ++++--
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  5 ++---
 net/ipv4/tcp_ipv4.c        |  9 +++++----
 net/ipv4/tcp_output.c      |  7 ++++---
 net/ipv6/syncookies.c      |  3 ++-
 net/ipv6/tcp_ipv6.c        |  7 ++++---
 11 files changed, 38 insertions(+), 31 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 1a2ae74a108510a49466a08fd2c2d84c3940a3a9..9a14a0850b0e3601194479b4e1a433dc817e088e 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -124,6 +124,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_tw_reuse;
 	int sysctl_tcp_sack;
 	int sysctl_tcp_window_scaling;
+	int sysctl_tcp_timestamps;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 
diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index b94006f6fbdde0d78fe33b9c2d86159e291c30cf..031bf16d15218329be98b1fb8c3f3e891a6f86e3 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -8,10 +8,11 @@ u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 			       __be16 dport);
 u32 secure_tcp_seq(__be32 saddr, __be32 daddr,
 		   __be16 sport, __be16 dport);
-u32 secure_tcp_ts_off(__be32 saddr, __be32 daddr);
+u32 secure_tcp_ts_off(const struct net *net, __be32 saddr, __be32 daddr);
 u32 secure_tcpv6_seq(const __be32 *saddr, const __be32 *daddr,
 		     __be16 sport, __be16 dport);
-u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr);
+u32 secure_tcpv6_ts_off(const struct net *net,
+			const __be32 *saddr, const __be32 *daddr);
 u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				__be16 sport, __be16 dport);
 u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f41ed5bac49312e2bd9b7bfd54b59a95d9888ec9..aec092560d9bd60d4323fa6d9ced74f17026b5a7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -237,7 +237,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 
 /* sysctl variables for tcp */
-extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_fastopen;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
@@ -1869,7 +1868,7 @@ struct tcp_request_sock_ops {
 	struct dst_entry *(*route_req)(const struct sock *sk, struct flowi *fl,
 				       const struct request_sock *req);
 	u32 (*init_seq)(const struct sk_buff *skb);
-	u32 (*init_ts_off)(const struct sk_buff *skb);
+	u32 (*init_ts_off)(const struct net *net, const struct sk_buff *skb);
 	int (*send_synack)(const struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
 			   struct tcp_fastopen_cookie *foc,
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index ae35cce3a40d70387bee815798933aa43a0e6d84..7232274de334bbd0852b80fc286ee316e22946d7 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -51,7 +51,8 @@ static u32 seq_scale(u32 seq)
 #endif
 
 #if IS_ENABLED(CONFIG_IPV6)
-u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr)
+u32 secure_tcpv6_ts_off(const struct net *net,
+			const __be32 *saddr, const __be32 *daddr)
 {
 	const struct {
 		struct in6_addr saddr;
@@ -61,7 +62,7 @@ u32 secure_tcpv6_ts_off(const __be32 *saddr, const __be32 *daddr)
 		.daddr = *(struct in6_addr *)daddr,
 	};
 
-	if (sysctl_tcp_timestamps != 1)
+	if (net->ipv4.sysctl_tcp_timestamps != 1)
 		return 0;
 
 	ts_secret_init();
@@ -113,9 +114,9 @@ EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
 
 #ifdef CONFIG_INET
-u32 secure_tcp_ts_off(__be32 saddr, __be32 daddr)
+u32 secure_tcp_ts_off(const struct net *net, __be32 saddr, __be32 daddr)
 {
-	if (sysctl_tcp_timestamps != 1)
+	if (net->ipv4.sysctl_tcp_timestamps != 1)
 		return 0;
 
 	ts_secret_init();
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 3d74a45773f1f7adf430885fe46096a498b4e489..7835bb4a1fab2b335c65001cc3c9233ffb4fd5cc 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -243,7 +243,7 @@ bool cookie_timestamp_decode(const struct net *net,
 		return true;
 	}
 
-	if (!sysctl_tcp_timestamps)
+	if (!net->ipv4.sysctl_tcp_timestamps)
 		return false;
 
 	tcp_opt->sack_ok = (options & TS_OPT_SACK) ? TCP_SACK_SEEN : 0;
@@ -316,7 +316,9 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	tcp_parse_options(sock_net(sk), skb, &tcp_opt, 0, NULL);
 
 	if (tcp_opt.saw_tstamp && tcp_opt.rcv_tsecr) {
-		tsoff = secure_tcp_ts_off(ip_hdr(skb)->daddr, ip_hdr(skb)->saddr);
+		tsoff = secure_tcp_ts_off(sock_net(sk),
+					  ip_hdr(skb)->daddr,
+					  ip_hdr(skb)->saddr);
 		tcp_opt.rcv_tsecr -= tsoff;
 	}
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c30ac2ba0e140698d310b4d84e1bbd8f37e650a5..7065234a89a50ae977f2de1c2ec7ca867ac2e6e2 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -364,13 +364,6 @@ static int proc_tfo_blackhole_detect_timeout(struct ctl_table *table,
 }
 
 static struct ctl_table ipv4_table[] = {
-	{
-		.procname	= "tcp_timestamps",
-		.data		= &sysctl_tcp_timestamps,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_retrans_collapse",
 		.data		= &sysctl_tcp_retrans_collapse,
@@ -1116,6 +1109,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_timestamps",
+		.data		= &init_net.ipv4.sysctl_tcp_timestamps,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 675ee903370ffd983109a2651235d627cad6eaa5..2ab7e2fa9bb9727a6d22552f851d6254ea074481 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -76,7 +76,6 @@
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
 
-int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly;
 int sysctl_tcp_max_reordering __read_mostly = 300;
 int sysctl_tcp_dsack __read_mostly = 1;
@@ -3780,7 +3779,7 @@ void tcp_parse_options(const struct net *net,
 			case TCPOPT_TIMESTAMP:
 				if ((opsize == TCPOLEN_TIMESTAMP) &&
 				    ((estab && opt_rx->tstamp_ok) ||
-				     (!estab && sysctl_tcp_timestamps))) {
+				     (!estab && net->ipv4.sysctl_tcp_timestamps))) {
 					opt_rx->saw_tstamp = 1;
 					opt_rx->rcv_tsval = get_unaligned_be32(ptr);
 					opt_rx->rcv_tsecr = get_unaligned_be32(ptr + 4);
@@ -6352,7 +6351,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		goto drop_and_free;
 
 	if (tmp_opt.tstamp_ok)
-		tcp_rsk(req)->ts_off = af_ops->init_ts_off(skb);
+		tcp_rsk(req)->ts_off = af_ops->init_ts_off(net, skb);
 
 	if (!want_cookie && !isn) {
 		/* Kill the following clause, if you dislike this way. */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e07ef5b14aaf4bd46253775b649cd77b58af5a2f..13c7ae7d4504500466ecfe77ceff673546fe4b0b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -102,10 +102,9 @@ static u32 tcp_v4_init_seq(const struct sk_buff *skb)
 			      tcp_hdr(skb)->source);
 }
 
-static u32 tcp_v4_init_ts_off(const struct sk_buff *skb)
+static u32 tcp_v4_init_ts_off(const struct net *net, const struct sk_buff *skb)
 {
-	return secure_tcp_ts_off(ip_hdr(skb)->daddr,
-				 ip_hdr(skb)->saddr);
+	return secure_tcp_ts_off(net, ip_hdr(skb)->daddr, ip_hdr(skb)->saddr);
 }
 
 int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
@@ -242,7 +241,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 						       inet->inet_daddr,
 						       inet->inet_sport,
 						       usin->sin_port);
-		tp->tsoffset = secure_tcp_ts_off(inet->inet_saddr,
+		tp->tsoffset = secure_tcp_ts_off(sock_net(sk),
+						 inet->inet_saddr,
 						 inet->inet_daddr);
 	}
 
@@ -2467,6 +2467,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_max_syn_backlog = max(128, cnt / 256);
 	net->ipv4.sysctl_tcp_sack = 1;
 	net->ipv4.sysctl_tcp_window_scaling = 1;
+	net->ipv4.sysctl_tcp_timestamps = 1;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3f40950107857b2984e858bf6d9e48e6f87a3259..9a9c395b62352513a42b3353434be8134ac9cdd7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -569,7 +569,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	opts->mss = tcp_advertise_mss(sk);
 	remaining -= TCPOLEN_MSS_ALIGNED;
 
-	if (likely(sysctl_tcp_timestamps && !*md5)) {
+	if (likely(sock_net(sk)->ipv4.sysctl_tcp_timestamps && !*md5)) {
 		opts->options |= OPTION_TS;
 		opts->tsval = tcp_skb_timestamp(skb) + tp->tsoffset;
 		opts->tsecr = tp->rx_opt.ts_recent;
@@ -3271,8 +3271,9 @@ static void tcp_connect_init(struct sock *sk)
 	/* We'll fix this up when we get a response from the other end.
 	 * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
 	 */
-	tp->tcp_header_len = sizeof(struct tcphdr) +
-		(sysctl_tcp_timestamps ? TCPOLEN_TSTAMP_ALIGNED : 0);
+	tp->tcp_header_len = sizeof(struct tcphdr);
+	if (sock_net(sk)->ipv4.sysctl_tcp_timestamps)
+		tp->tcp_header_len += TCPOLEN_TSTAMP_ALIGNED;
 
 #ifdef CONFIG_TCP_MD5SIG
 	if (tp->af_specific->md5_lookup(sk, sk))
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index aa6443c6da19055ced1094d2afc7c114028acc35..2f7e99af67dbfd2324d39086881b9475045d7e1f 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -165,7 +165,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	tcp_parse_options(sock_net(sk), skb, &tcp_opt, 0, NULL);
 
 	if (tcp_opt.saw_tstamp && tcp_opt.rcv_tsecr) {
-		tsoff = secure_tcpv6_ts_off(ipv6_hdr(skb)->daddr.s6_addr32,
+		tsoff = secure_tcpv6_ts_off(sock_net(sk),
+					    ipv6_hdr(skb)->daddr.s6_addr32,
 					    ipv6_hdr(skb)->saddr.s6_addr32);
 		tcp_opt.rcv_tsecr -= tsoff;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 233edfabe1dbceaeb6cdd42a2bb379072aeee361..5a525426fe93e580adef3342486f0f130ee6ef7e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -109,9 +109,9 @@ static u32 tcp_v6_init_seq(const struct sk_buff *skb)
 				tcp_hdr(skb)->source);
 }
 
-static u32 tcp_v6_init_ts_off(const struct sk_buff *skb)
+static u32 tcp_v6_init_ts_off(const struct net *net, const struct sk_buff *skb)
 {
-	return secure_tcpv6_ts_off(ipv6_hdr(skb)->daddr.s6_addr32,
+	return secure_tcpv6_ts_off(net, ipv6_hdr(skb)->daddr.s6_addr32,
 				   ipv6_hdr(skb)->saddr.s6_addr32);
 }
 
@@ -292,7 +292,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 							 sk->sk_v6_daddr.s6_addr32,
 							 inet->inet_sport,
 							 inet->inet_dport);
-		tp->tsoffset = secure_tcpv6_ts_off(np->saddr.s6_addr32,
+		tp->tsoffset = secure_tcpv6_ts_off(sock_net(sk),
+						   np->saddr.s6_addr32,
 						   sk->sk_v6_daddr.s6_addr32);
 	}
 
-- 
2.13.0.506.g27d5fe0cd-goog
