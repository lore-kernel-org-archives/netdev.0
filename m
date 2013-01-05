From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] tcp: make sysctl_tcp_ecn namespace aware
Date: Sat, 5 Jan 2013 16:01:30 +0100
Message-ID: <20130105150130.GC4031@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, davem@davemloft.net, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37626 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755686Ab3AEPBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 10:01:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per suggestion from Eric Dumazet this patch makes tcp_ecn sysctl aware.
The reason behind this patch is to ease the testing of ecn problems on
the internet and allows applications to tune their own use of ecn.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/netns/ipv4.h   |  2 ++
 include/net/tcp.h          |  7 ++++---
 net/ipv4/syncookies.c      |  6 ++++--
 net/ipv4/sysctl_net_ipv4.c | 16 +++++++++-------
 net/ipv4/tcp_input.c       |  2 --
 net/ipv4/tcp_ipv4.c        |  4 +++-
 net/ipv4/tcp_output.c      |  1 +
 net/ipv6/syncookies.c      |  3 ++-
 net/ipv6/tcp_ipv6.c        |  7 +++++--
 9 files changed, 30 insertions(+), 18 deletions(-)

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
index aed42c7..a808c59 100644
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
+				int sysctl_tcp_ecn, bool *ecn_ok);
 
 /* From net/ipv6/syncookies.c */
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
@@ -728,7 +728,8 @@ struct tcp_skb_cb {
  * notifications, we disable TCP ECN negociation.
  */
 static inline void
-TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb)
+TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
+		int sysctl_tcp_ecn)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b236ef0..f51c3f5 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -232,7 +232,8 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
  *
  * return false if we decode an option that should not be.
  */
-bool cookie_check_timestamp(struct tcp_options_received *tcp_opt, bool *ecn_ok)
+bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
+			int sysctl_tcp_ecn, bool *ecn_ok)
 {
 	/* echoed timestamp, lowest bits contain options */
 	u32 options = tcp_opt->rcv_tsecr & TSMASK;
@@ -279,6 +280,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	__u8 rcv_wscale;
 	bool ecn_ok = false;
 	struct flowi4 fl4;
+	int sysctl_tcp_ecn = sock_net(sk)->ipv4.sysctl_tcp_ecn;
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -295,7 +297,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
+	if (!cookie_check_timestamp(&tcp_opt, sysctl_tcp_ecn, &ecn_ok))
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
index 54139fa..70215e7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1568,7 +1568,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb);
+		TCP_ECN_create_request(req, skb,
+				sock_net(sk)->ipv4.sysctl_tcp_ecn);
 
 	if (want_cookie) {
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
@@ -2888,6 +2889,7 @@ EXPORT_SYMBOL(tcp_prot);
 
 static int __net_init tcp_sk_init(struct net *net)
 {
+	net->ipv4.sysctl_tcp_ecn = 2;
 	return 0;
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d45159..a407f92 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -312,6 +312,7 @@ static inline void TCP_ECN_send_synack(const struct tcp_sock *tp, struct sk_buff
 static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	int sysctl_tcp_ecn = sock_net(sk)->ipv4.sysctl_tcp_ecn;
 
 	tp->ecn_flags = 0;
 	if (sysctl_tcp_ecn == 1) {
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 4016197..2a632ed 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -163,6 +163,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
 	bool ecn_ok = false;
+	int sysctl_tcp_ecn = sock_net(sk)->ipv4.sysctl_tcp_ecn;
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -179,7 +180,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
+	if (!cookie_check_timestamp(&tcp_opt, sysctl_tcp_ecn, &ecn_ok))
 		goto out;
 
 	ret = NULL;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93825dd..932d667 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1026,8 +1026,11 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	treq = inet6_rsk(req);
 	treq->rmt_addr = ipv6_hdr(skb)->saddr;
 	treq->loc_addr = ipv6_hdr(skb)->daddr;
-	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb);
+	if (!want_cookie || tmp_opt.tstamp_ok) {
+		/* we reuse the ipv4 sysctl for ecn here */
+		TCP_ECN_create_request(req, skb,
+				sock_net(sk)->ipv4.sysctl_tcp_ecn);
+	}
 
 	treq->iif = sk->sk_bound_dev_if;
 
-- 
1.7.11.7
