From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] tcp: split tcp_ecn sysctl knob to distinguish between IPv4 and IPv6
Date: Mon, 31 Dec 2012 18:35:33 +0100
Message-ID: <20121231173532.GA11700@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57508 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab2LaRfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 12:35:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ECN could be more reliable when used with IPv6 (I don't have proofs). For
people who want to try ECN with IPv6 but still have problems connecting
to destinations because of broken IPv4 routers this switch allows one
to enable ECN just for IPv6.

Perhaps ECN could be enabled by default in future.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h         | 1 +
 include/net/tcp.h          | 8 +++++---
 net/ipv4/syncookies.c      | 6 ++++--
 net/ipv4/sysctl_net_ipv4.c | 2 +-
 net/ipv4/tcp_input.c       | 2 --
 net/ipv4/tcp_ipv4.c        | 3 ++-
 net/ipv4/tcp_output.c      | 2 +-
 net/ipv6/syncookies.c      | 3 ++-
 net/ipv6/sysctl_net_ipv6.c | 8 ++++++++
 net/ipv6/tcp_ipv6.c        | 4 +++-
 10 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 182ca99..aa3c30e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -944,6 +944,7 @@ struct proto {
 	int			*sysctl_rmem;
 	int			max_header;
 	bool			no_autobind;
+	int			ecn;
 
 	struct kmem_cache	*slab;
 	unsigned int		obj_size;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index aed42c7..1202a6d 100644
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
@@ -351,6 +350,7 @@ static inline bool tcp_synq_no_recent_overflow(const struct sock *sk)
 }
 
 extern struct proto tcp_prot;
+extern struct proto tcpv6_prot;
 
 #define TCP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.tcp_statistics, field)
 #define TCP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.tcp_statistics, field)
@@ -504,7 +504,8 @@ static inline __u32 cookie_v4_init_sequence(struct sock *sk,
 #endif
 
 extern __u32 cookie_init_timestamp(struct request_sock *req);
-extern bool cookie_check_timestamp(struct tcp_options_received *opt, bool *);
+extern bool cookie_check_timestamp(struct tcp_options_received *opt,
+				int sysctl_tcp_ecn, bool *ecn_ok);
 
 /* From net/ipv6/syncookies.c */
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
@@ -728,7 +729,8 @@ struct tcp_skb_cb {
  * notifications, we disable TCP ECN negociation.
  */
 static inline void
-TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb)
+TCP_ECN_create_request(struct request_sock *req,
+		const struct sk_buff *skb, int sysctl_tcp_ecn)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b236ef0..64dbfc5 100644
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
@@ -278,6 +279,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	struct rtable *rt;
 	__u8 rcv_wscale;
 	bool ecn_ok = false;
+	int sysctl_tcp_ecn = sk->sk_prot->ecn;
 	struct flowi4 fl4;
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
@@ -295,7 +297,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
+	if (!cookie_check_timestamp(&tcp_opt, sysctl_tcp_ecn, &ecn_ok))
 		goto out;
 
 	ret = NULL;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d84400b..f7aac98 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -539,7 +539,7 @@ static struct ctl_table ipv4_table[] = {
 	},
 	{
 		.procname	= "tcp_ecn",
-		.data		= &sysctl_tcp_ecn,
+		.data		= &tcp_prot.ecn,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
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
index 54139fa..32e012a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1568,7 +1568,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb);
+		TCP_ECN_create_request(req, skb, tcp_prot.ecn);
 
 	if (want_cookie) {
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
@@ -2874,6 +2874,7 @@ struct proto tcp_prot = {
 	.rsk_prot		= &tcp_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
 	.no_autobind		= true,
+	.ecn			= 2,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d45159..0c75961 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -314,7 +314,7 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->ecn_flags = 0;
-	if (sysctl_tcp_ecn == 1) {
+	if (sk->sk_prot->ecn == 1) {
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ECE | TCPHDR_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
 	}
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 4016197..ce19227 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -163,6 +163,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
 	bool ecn_ok = false;
+	int sysctl_tcp_ecn = sk->sk_prot->ecn;
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -179,7 +180,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
 	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, NULL);
 
-	if (!cookie_check_timestamp(&tcp_opt, &ecn_ok))
+	if (!cookie_check_timestamp(&tcp_opt, sysctl_tcp_ecn, &ecn_ok))
 		goto out;
 
 	ret = NULL;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index e85c48b..a2e764f 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -15,6 +15,7 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
+#include <net/tcp.h>
 
 static ctl_table ipv6_table_template[] = {
 	{
@@ -24,6 +25,13 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_ecn",
+		.data		= &tcpv6_prot.ecn,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93825dd..98bd8a3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1027,7 +1027,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	treq->rmt_addr = ipv6_hdr(skb)->saddr;
 	treq->loc_addr = ipv6_hdr(skb)->daddr;
 	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb);
+		TCP_ECN_create_request(req, skb, tcpv6_prot.ecn);
 
 	treq->iif = sk->sk_bound_dev_if;
 
@@ -1955,6 +1955,7 @@ struct proto tcpv6_prot = {
 	.rsk_prot		= &tcp6_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
 	.no_autobind		= true,
+	.ecn			= 2,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
@@ -1963,6 +1964,7 @@ struct proto tcpv6_prot = {
 	.proto_cgroup		= tcp_proto_cgroup,
 #endif
 };
+EXPORT_SYMBOL(tcpv6_prot);
 
 static const struct inet6_protocol tcpv6_protocol = {
 	.early_demux	=	tcp_v6_early_demux,
