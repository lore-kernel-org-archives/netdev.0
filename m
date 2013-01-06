From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] tcp: make sysctl_tcp_ecn namespace aware
Date: Sun, 6 Jan 2013 03:10:48 +0100
Message-ID: <20130106021048.GA32202@order.stressinduktion.org>
References: <20130105150130.GC4031@order.stressinduktion.org> <20130105110005.2bf230eb@nehalam.linuxnetplumber.net> <20130105190508.GE4031@order.stressinduktion.org> <20130106011849.GA28545@order.stressinduktion.org> <1357435646.1678.5082.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38454 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755110Ab3AFCKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 21:10:50 -0500
Content-Disposition: inline
In-Reply-To: <1357435646.1678.5082.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per suggestion from Eric Dumazet this patch makes tcp_ecn sysctl
namespace aware.  The reason behind this patch is to ease the testing
of ecn problems on the internet and allows applications to tune their
own use of ecn.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/netns/ipv4.h   |  2 ++
 include/net/tcp.h          |  9 +++++----
 net/ipv4/syncookies.c      |  7 ++++---
 net/ipv4/sysctl_net_ipv4.c | 16 +++++++++-------
 net/ipv4/tcp_input.c       |  2 --
 net/ipv4/tcp_ipv4.c        |  3 ++-
 net/ipv4/tcp_output.c      |  2 +-
 net/ipv6/syncookies.c      |  2 +-
 net/ipv6/tcp_ipv6.c        |  2 +-
 9 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2ae2b83..9b78862 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -61,6 +61,8 @@ struct netns_ipv4 {
 	int sysctl_icmp_ratemask;
 	int sysctl_icmp_errors_use_inbound_ifaddr;
 
+	int sysctl_tcp_ecn;
+
 	kgid_t sysctl_ping_group_range[2];
 	long sysctl_tcp_mem[3];
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index aed42c7..614af8b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -266,7 +266,6 @@ extern int sysctl_tcp_abort_on_overflow;
 extern int sysctl_tcp_max_orphans;
 extern int sysctl_tcp_fack;
 extern int sysctl_tcp_reordering;
-extern int sysctl_tcp_ecn;
 extern int sysctl_tcp_dsack;
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
@@ -504,7 +503,8 @@ static inline __u32 cookie_v4_init_sequence(struct sock *sk,
 #endif
 
 extern __u32 cookie_init_timestamp(struct request_sock *req);
-extern bool cookie_check_timestamp(struct tcp_options_received *opt, bool *);
+extern bool cookie_check_timestamp(struct tcp_options_received *opt,
+				struct net *net, bool *ecn_ok);
 
 /* From net/ipv6/syncookies.c */
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
@@ -728,11 +728,12 @@ struct tcp_skb_cb {
  * notifications, we disable TCP ECN negociation.
  */
 static inline void
-TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb)
+TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
+		struct net *net)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 
-	if (sysctl_tcp_ecn && th->ece && th->cwr &&
+	if (net->ipv4.sysctl_tcp_ecn && th->ece && th->cwr &&
 	    INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield))
 		inet_rsk(req)->ecn_ok = 1;
 }
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b236ef0..ef54377 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -232,7 +232,8 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
  *
  * return false if we decode an option that should not be.
  */
-bool cookie_check_timestamp(struct tcp_options_received *tcp_opt, bool *ecn_ok)
+bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
+			struct net *net, bool *ecn_ok)
 {
 	/* echoed timestamp, lowest bits contain options */
 	u32 options = tcp_opt->rcv_tsecr & TSMASK;
@@ -247,7 +248,7 @@ bool cookie_check_timestamp(struct tcp_options_received *tcp_opt, bool *ecn_ok)
 
 	tcp_opt->sack_ok = (options & (1 << 4)) ? TCP_SACK_SEEN : 0;
 	*ecn_ok = (options >> 5) & 1;
-	if (*ecn_ok && !sysctl_tcp_ecn)
+	if (*ecn_ok && !net->ipv4.sysctl_tcp_ecn)
 		return false;
 
 	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
@@ -295,7 +296,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
+	if (!cookie_check_timestamp(&tcp_opt, sock_net(sk), &ecn_ok))
 		goto out;
 
 	ret = NULL;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d84400b..7716d40 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -538,13 +538,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_ecn",
-		.data		= &sysctl_tcp_ecn,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_dsack",
 		.data		= &sysctl_tcp_dsack,
 		.maxlen		= sizeof(int),
@@ -850,6 +843,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= ipv4_ping_group_range,
 	},
 	{
+		.procname	= "tcp_ecn",
+		.data		= &init_net.ipv4.sysctl_tcp_ecn,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "tcp_mem",
 		.maxlen		= sizeof(init_net.ipv4.sysctl_tcp_mem),
 		.mode		= 0644,
@@ -882,6 +882,8 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 			&net->ipv4.sysctl_icmp_ratemask;
 		table[6].data =
 			&net->ipv4.sysctl_ping_group_range;
+		table[7].data =
+			&net->ipv4.sysctl_tcp_ecn;
 
 		/* Don't export sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a28e4db..38e1184 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -81,8 +81,6 @@ int sysctl_tcp_sack __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly = 1;
 int sysctl_tcp_reordering __read_mostly = TCP_FASTRETRANS_THRESH;
 EXPORT_SYMBOL(sysctl_tcp_reordering);
-int sysctl_tcp_ecn __read_mostly = 2;
-EXPORT_SYMBOL(sysctl_tcp_ecn);
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 1;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 54139fa..c6ce9ca 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1568,7 +1568,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb);
+		TCP_ECN_create_request(req, skb, sock_net(sk));
 
 	if (want_cookie) {
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
@@ -2888,6 +2888,7 @@ EXPORT_SYMBOL(tcp_prot);
 
 static int __net_init tcp_sk_init(struct net *net)
 {
+	net->ipv4.sysctl_tcp_ecn = 2;
 	return 0;
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d45159..667a6ad 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -314,7 +314,7 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->ecn_flags = 0;
-	if (sysctl_tcp_ecn == 1) {
+	if (sock_net(sk)->ipv4.sysctl_tcp_ecn == 1) {
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ECE | TCPHDR_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
 	}
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 4016197..8a0848b 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -179,7 +179,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
+	if (!cookie_check_timestamp(&tcp_opt, sock_net(sk), &ecn_ok))
 		goto out;
 
 	ret = NULL;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93825dd..3164ad2 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1027,7 +1027,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	treq->rmt_addr = ipv6_hdr(skb)->saddr;
 	treq->loc_addr = ipv6_hdr(skb)->daddr;
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb);
+		TCP_ECN_create_request(req, skb, sock_net(sk));
 
 	treq->iif = sk->sk_bound_dev_if;
 
-- 
1.7.11.7
