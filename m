From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 4/9] ipv4: Namespaceify tcp reordering sysctl knob
Date: Mon, 11 Jan 2016 11:51:50 +0200
Message-ID: <1452505915-19912-5-git-send-email-kernel@kyup.com>
References: <1452505915-19912-1-git-send-email-kernel@kyup.com>
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, kaber@trash.net, ebiederm@xmission.com,
	operations@siteground.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452505915-19912-1-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h   |  2 +-
 include/net/tcp.h          |  4 +++-
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp.c             |  2 +-
 net/ipv4/tcp_input.c       | 12 ++++++------
 net/ipv4/tcp_ipv4.c        |  2 +-
 net/ipv4/tcp_metrics.c     |  3 ++-
 7 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 80da0d095eaf..dff8879e02fe 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -97,8 +97,8 @@ struct netns_ipv4 {
 
 	int sysctl_tcp_syn_retries;
 	int sysctl_tcp_synack_retries;
-
 	int sysctl_tcp_syncookies;
+	int sysctl_tcp_reordering;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5497cc809601..64d01d289441 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -959,9 +959,11 @@ static inline void tcp_enable_fack(struct tcp_sock *tp)
  */
 static inline void tcp_enable_early_retrans(struct tcp_sock *tp)
 {
+	struct net *net = sock_net((struct sock *)tp);
+
 	tp->do_early_retrans = sysctl_tcp_early_retrans &&
 		sysctl_tcp_early_retrans < 4 && !sysctl_tcp_thin_dupack &&
-		sysctl_tcp_reordering == 3;
+		net->ipv4.sysctl_tcp_reordering == 3;
 }
 
 static inline void tcp_disable_early_retrans(struct tcp_sock *tp)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 007b9f8f7a2a..12d752e6380b 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -457,13 +457,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "tcp_reordering",
-		.data		= &sysctl_tcp_reordering,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_max_reordering",
 		.data		= &sysctl_tcp_max_reordering,
 		.maxlen		= sizeof(int),
@@ -950,6 +943,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 #endif
+	{
+		.procname	= "tcp_reordering",
+		.data		= &init_net.ipv4.sysctl_tcp_reordering,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bb36a39b5685..d0547395d81d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -405,7 +405,7 @@ void tcp_init_sock(struct sock *sk)
 	tp->mss_cache = TCP_MSS_DEFAULT;
 	u64_stats_init(&tp->syncp);
 
-	tp->reordering = sysctl_tcp_reordering;
+	tp->reordering = sock_net(sk)->ipv4.sysctl_tcp_reordering;
 	tcp_enable_early_retrans(tp);
 	tcp_assign_congestion_control(sk);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index dc8fe6c8a2e0..3f08bba46147 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -80,9 +80,7 @@ int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
 int sysctl_tcp_sack __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly = 1;
-int sysctl_tcp_reordering __read_mostly = TCP_FASTRETRANS_THRESH;
 int sysctl_tcp_max_reordering __read_mostly = 300;
-EXPORT_SYMBOL(sysctl_tcp_reordering);
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 1;
@@ -1873,6 +1871,7 @@ void tcp_enter_loss(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct net *net = sock_net(sk);
 	struct sk_buff *skb;
 	bool new_recovery = icsk->icsk_ca_state < TCP_CA_Recovery;
 	bool is_reneg;			/* is receiver reneging on SACKs? */
@@ -1923,9 +1922,9 @@ void tcp_enter_loss(struct sock *sk)
 	 * suggests that the degree of reordering is over-estimated.
 	 */
 	if (icsk->icsk_ca_state <= TCP_CA_Disorder &&
-	    tp->sacked_out >= sysctl_tcp_reordering)
+	    tp->sacked_out >= net->ipv4.sysctl_tcp_reordering)
 		tp->reordering = min_t(unsigned int, tp->reordering,
-				       sysctl_tcp_reordering);
+				       net->ipv4.sysctl_tcp_reordering);
 	tcp_set_ca_state(sk, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
 	tcp_ecn_queue_cwr(tp);
@@ -2109,6 +2108,7 @@ static bool tcp_time_to_recover(struct sock *sk, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 packets_out;
+	int tcp_reordering = sock_net(sk)->ipv4.sysctl_tcp_reordering;
 
 	/* Trick#1: The loss is proven. */
 	if (tp->lost_out)
@@ -2123,7 +2123,7 @@ static bool tcp_time_to_recover(struct sock *sk, int flag)
 	 */
 	packets_out = tp->packets_out;
 	if (packets_out <= tp->reordering &&
-	    tp->sacked_out >= max_t(__u32, packets_out/2, sysctl_tcp_reordering) &&
+	    tp->sacked_out >= max_t(__u32, packets_out/2, tcp_reordering) &&
 	    !tcp_may_send_now(sk)) {
 		/* We have nothing to send. This connection is limited
 		 * either by receiver window or by application.
@@ -3304,7 +3304,7 @@ static inline bool tcp_may_raise_cwnd(const struct sock *sk, const int flag)
 	 * new SACK or ECE mark may first advance cwnd here and later reduce
 	 * cwnd in tcp_fastretrans_alert() based on more states.
 	 */
-	if (tcp_sk(sk)->reordering > sysctl_tcp_reordering)
+	if (tcp_sk(sk)->reordering > sock_net(sk)->ipv4.sysctl_tcp_reordering)
 		return flag & FLAG_FORWARD_PROGRESS;
 
 	return flag & FLAG_DATA_ACKED;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ee3566377717..785bbebd6768 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2383,8 +2383,8 @@ static int __net_init tcp_sk_init(struct net *net)
 
 	net->ipv4.sysctl_tcp_syn_retries = TCP_SYN_RETRIES;
 	net->ipv4.sysctl_tcp_synack_retries = TCP_SYNACK_RETRIES;
-
 	net->ipv4.sysctl_tcp_syncookies = 0;
+	net->ipv4.sysctl_tcp_reordering = TCP_FASTRETRANS_THRESH;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index c8cbc2b4b792..c26241f3057b 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -369,6 +369,7 @@ void tcp_update_metrics(struct sock *sk)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct net *net = sock_net(sk);
 	struct tcp_metrics_block *tm;
 	unsigned long rtt;
 	u32 val;
@@ -473,7 +474,7 @@ void tcp_update_metrics(struct sock *sk)
 		if (!tcp_metric_locked(tm, TCP_METRIC_REORDERING)) {
 			val = tcp_metric_get(tm, TCP_METRIC_REORDERING);
 			if (val < tp->reordering &&
-			    tp->reordering != sysctl_tcp_reordering)
+			    tp->reordering != net->ipv4.sysctl_tcp_reordering)
 				tcp_metric_set(tm, TCP_METRIC_REORDERING,
 					       tp->reordering);
 		}
-- 
2.5.0
