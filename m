From: Benoit Sigoure <tsunanet@gmail.com>
Subject: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC 2988bis-02.
Date: Wed, 18 May 2011 19:22:24 -0700
Message-ID: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
References: <20110518.155200.801089483916944725.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Benoit Sigoure <tsunanet@gmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	hagen@jauu.net, eric.dumazet@gmail.com,
	alexander.zimmermann
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:35040 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755553Ab1ESCXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 22:23:15 -0400
In-Reply-To: <20110518.155200.801089483916944725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch, Linux would always use 3 seconds (compile-time
constant) as the initial RTO.  Draft RFC 2988bis-02 proposes to tune
this down to 1 second and, in case of a timeout during the TCP 3WHS,
revert the RTO back up to 3 seconds when data transmission begins.

This patch implements this behavior but retains default values for
the initial RTO of 3 seconds, instead of 1 second as is suggested
in the draft RFC.  This way, in a default configuration, the behavior
of Linux's TCP is unchanged.

This patch also adds 2 knobs to tweak the initial RTO:
  - tcp_initial_rto: initial RTO used during the 3WHS (default remains
    unchanged: 3 seconds).  This was previously a compile-time constant.
  - tcp_initial_fallback_rto: the RTO to fallback to if a timeout occurs
    during the 3WHS, with a default value of 3 seconds too, as per the
    draft RFC.

Signed-off-by: Benoit Sigoure <tsunanet@gmail.com>
---

On Wed, May 18, 2011 at 12:52 PM, David Miller <davem@davemloft.net> wrote:
> I'll just as easily accept right now a patch right now which lowers
> the initial RTO to 1 second and adds the 3 second RTO fallback.

Here's a first attempt at a patch that implements the behavior described in
the draft RFC.  I only compiled it so far, if you would like to move forward
with this approach, I'll go ahead and test it on a real server.

I'm not sure whether COUNTER_TRIES in syncookies.c should be based off
sysctl_tcp_initial_rto or sysctl_tcp_initial_fallback_rto, if we're going
to take the first one down to 1s...

 Documentation/networking/ip-sysctl.txt |   19 +++++++++++++++++++
 include/net/tcp.h                      |    4 +++-
 net/ipv4/syncookies.c                  |    2 +-
 net/ipv4/sysctl_net_ipv4.c             |   20 ++++++++++++++++++++
 net/ipv4/tcp.c                         |    4 ++--
 net/ipv4/tcp_input.c                   |   13 +++++++++----
 net/ipv4/tcp_ipv4.c                    |    6 +++---
 net/ipv4/tcp_minisocks.c               |    6 +++---
 net/ipv4/tcp_output.c                  |    2 +-
 net/ipv4/tcp_timer.c                   |   10 ++++++----
 net/ipv6/syncookies.c                  |    2 +-
 net/ipv6/tcp_ipv6.c                    |    6 +++---
 12 files changed, 71 insertions(+), 23 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d3d653a..590042c 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -384,6 +384,25 @@ tcp_retries2 - INTEGER
 	RFC 1122 recommends at least 100 seconds for the timeout,
 	which corresponds to a value of at least 8.
 
+tcp_initial_rto - INTEGER
+	This value sets the initial retransmit timeout (in milliseconds),
+	that is how long the kernel will wait before retransmitting the
+	initial SYN packet.
+
+	RFC 1122 says that this SHOULD be 3000 milliseconds, which is the
+	default.  Note that draft RFC 2988bis-02 says that this SHOULD be
+	1000 milliseconds, which might become the default value in future
+	versions.
+
+tcp_initial_fallback_rto - INTEGER
+	This value sets the initial retransmit timeout (in milliseconds)
+	to use after completing a three-way handshake during which the
+	initial SYN packet had to be retransmitted after waiting for
+	tcp_initial_rto milliseconds.
+
+	Draft RFC 2988bis-02 says that this MUST be 3000 milliseconds,
+	which is the default.
+
 tcp_rfc1337 - BOOLEAN
 	If set, the TCP stack behaves conforming to RFC1337. If unset,
 	we are not conforming to RFC, but prevent TCP TIME_WAIT
diff --git a/include/net/tcp.h b/include/net/tcp.h
index cda30ea..c974242 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -213,6 +213,8 @@ extern int sysctl_tcp_syn_retries;
 extern int sysctl_tcp_synack_retries;
 extern int sysctl_tcp_retries1;
 extern int sysctl_tcp_retries2;
+extern int sysctl_tcp_initial_rto;           /* in jiffies */
+extern int sysctl_tcp_initial_fallback_rto;  /* in jiffies */
 extern int sysctl_tcp_orphan_retries;
 extern int sysctl_tcp_syncookies;
 extern int sysctl_tcp_retrans_collapse;
@@ -295,7 +297,7 @@ static inline void tcp_synq_overflow(struct sock *sk)
 static inline int tcp_synq_no_recent_overflow(const struct sock *sk)
 {
 	unsigned long last_overflow = tcp_sk(sk)->rx_opt.ts_recent_stamp;
-	return time_after(jiffies, last_overflow + TCP_TIMEOUT_INIT);
+	return time_after(jiffies, last_overflow + sysctl_tcp_initial_rto);
 }
 
 extern struct proto tcp_prot;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 8b44c6d..b035968 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -186,7 +186,7 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
  * sysctl_tcp_retries1. It's a rather complicated formula (exponential
  * backoff) to compute at runtime so it's currently hardcoded here.
  */
-#define COUNTER_TRIES 4
+#define COUNTER_TRIES (sysctl_tcp_initial_rto/HZ + 1)
 /*
  * Check if a ack sequence number is a valid syncookie.
  * Return the decoded mss if it is, or 0 if not.
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 321e6e8..abe8cfc 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -30,6 +30,8 @@ static int tcp_adv_win_scale_min = -31;
 static int tcp_adv_win_scale_max = 31;
 static int ip_ttl_min = 1;
 static int ip_ttl_max = 255;
+static int tcp_min_rto = TCP_RTO_MIN;
+static int tcp_max_rto = TCP_RTO_MAX;
 
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
@@ -247,6 +249,24 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname       = "tcp_initial_rto",
+		.data           = &sysctl_tcp_initial_rto,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.extra1		= &tcp_min_rto,
+		.extra2		= &tcp_max_rto,
+	},
+	{
+		.procname       = "tcp_initial_fallback_rto",
+		.data           = &sysctl_tcp_initial_fallback_rto,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.extra1		= &tcp_min_rto,
+		.extra2		= &tcp_max_rto,
+	},
+	{
 		.procname	= "tcp_fin_timeout",
 		.data		= &sysctl_tcp_fin_timeout,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b22d450..e9e7c3f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2352,7 +2352,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_DEFER_ACCEPT:
 		/* Translate value in seconds to number of retransmits */
 		icsk->icsk_accept_queue.rskq_defer_accept =
-			secs_to_retrans(val, TCP_TIMEOUT_INIT / HZ,
+			secs_to_retrans(val, sysctl_tcp_initial_rto / HZ,
 					TCP_RTO_MAX / HZ);
 		break;
 
@@ -2539,7 +2539,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		break;
 	case TCP_DEFER_ACCEPT:
 		val = retrans_to_secs(icsk->icsk_accept_queue.rskq_defer_accept,
-				      TCP_TIMEOUT_INIT / HZ, TCP_RTO_MAX / HZ);
+				      sysctl_tcp_initial_rto / HZ, TCP_RTO_MAX / HZ);
 		break;
 	case TCP_WINDOW_CLAMP:
 		val = tp->window_clamp;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bef9f04..513cf7a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -868,6 +868,11 @@ static void tcp_init_metrics(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
+	/* If we had to retransmit anything during the 3WHS,
+	 * use the initial fallback RTO.
+	 */
+	int init_rto = inet_csk(sk)->icsk_retransmits ?
+		sysctl_tcp_initial_fallback_rto : sysctl_tcp_initial_rto;
 
 	if (dst == NULL)
 		goto reset;
@@ -890,7 +895,7 @@ static void tcp_init_metrics(struct sock *sk)
 	if (dst_metric(dst, RTAX_RTT) == 0)
 		goto reset;
 
-	if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (TCP_TIMEOUT_INIT << 3))
+	if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (init_rto << 3))
 		goto reset;
 
 	/* Initial rtt is determined from SYN,SYN-ACK.
@@ -916,7 +921,7 @@ static void tcp_init_metrics(struct sock *sk)
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 	}
 	tcp_set_rto(sk);
-	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp) {
+	if (inet_csk(sk)->icsk_rto < init_rto && !tp->rx_opt.saw_tstamp) {
 reset:
 		/* Play conservative. If timestamps are not
 		 * supported, TCP will fail to recalculate correct
@@ -924,8 +929,8 @@ reset:
 		 */
 		if (!tp->rx_opt.saw_tstamp && tp->srtt) {
 			tp->srtt = 0;
-			tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
-			inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+			tp->mdev = tp->mdev_max = tp->rttvar = init_rto;
+			inet_csk(sk)->icsk_rto = init_rto;
 		}
 	}
 	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f7e6c2c..21920e6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1383,7 +1383,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	    want_cookie)
 		goto drop_and_free;
 
-	inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+	inet_csk_reqsk_queue_hash_add(sk, req, sysctl_tcp_initial_rto);
 	return 0;
 
 drop_and_release:
@@ -1834,8 +1834,8 @@ static int tcp_v4_init_sock(struct sock *sk)
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
 
-	icsk->icsk_rto = TCP_TIMEOUT_INIT;
-	tp->mdev = TCP_TIMEOUT_INIT;
+	icsk->icsk_rto = sysctl_tcp_initial_rto;
+	tp->mdev = sysctl_tcp_initial_rto;
 
 	/* So many TCP implementations out there (incorrectly) count the
 	 * initial SYN frame in their delayed-ACK and congestion control
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 80b1f80..c63ffa0 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -472,8 +472,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		tcp_init_wl(newtp, treq->rcv_isn);
 
 		newtp->srtt = 0;
-		newtp->mdev = TCP_TIMEOUT_INIT;
-		newicsk->icsk_rto = TCP_TIMEOUT_INIT;
+		newtp->mdev = sysctl_tcp_initial_rto;
+		newicsk->icsk_rto = sysctl_tcp_initial_rto;
 
 		newtp->packets_out = 0;
 		newtp->retrans_out = 0;
@@ -582,7 +582,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			 * it can be estimated (approximately)
 			 * from another data.
 			 */
-			tmp_opt.ts_recent_stamp = get_seconds() - ((TCP_TIMEOUT_INIT/HZ)<<req->retrans);
+			tmp_opt.ts_recent_stamp = get_seconds() - ((sysctl_tcp_initial_rto/HZ)<<req->retrans);
 			paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
 		}
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 17388c7..e34b0f6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2599,7 +2599,7 @@ static void tcp_connect_init(struct sock *sk)
 	tp->rcv_wup = 0;
 	tp->copied_seq = 0;
 
-	inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+	inet_csk(sk)->icsk_rto = sysctl_tcp_initial_rto;
 	inet_csk(sk)->icsk_retransmits = 0;
 	tcp_clear_retrans(tp);
 }
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index ecd44b0..47fa600 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -29,6 +29,8 @@ int sysctl_tcp_keepalive_probes __read_mostly = TCP_KEEPALIVE_PROBES;
 int sysctl_tcp_keepalive_intvl __read_mostly = TCP_KEEPALIVE_INTVL;
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
+int sysctl_tcp_initial_rto __read_mostly = TCP_TIMEOUT_INIT;
+int sysctl_tcp_initial_fallback_rto __read_mostly = TCP_TIMEOUT_INIT;
 int sysctl_tcp_orphan_retries __read_mostly;
 int sysctl_tcp_thin_linear_timeouts __read_mostly;
 
@@ -135,8 +137,8 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 
 /* This function calculates a "timeout" which is equivalent to the timeout of a
  * TCP connection after "boundary" unsuccessful, exponentially backed-off
- * retransmissions with an initial RTO of TCP_RTO_MIN or TCP_TIMEOUT_INIT if
- * syn_set flag is set.
+ * retransmissions with an initial RTO of TCP_RTO_MIN or
+ * sysctl_tcp_initial_rto if syn_set flag is set.
  */
 static bool retransmits_timed_out(struct sock *sk,
 				  unsigned int boundary,
@@ -144,7 +146,7 @@ static bool retransmits_timed_out(struct sock *sk,
 				  bool syn_set)
 {
 	unsigned int linear_backoff_thresh, start_ts;
-	unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
+	unsigned int rto_base = syn_set ? sysctl_tcp_initial_rto : TCP_RTO_MIN;
 
 	if (!inet_csk(sk)->icsk_retransmits)
 		return false;
@@ -495,7 +497,7 @@ out_unlock:
 static void tcp_synack_timer(struct sock *sk)
 {
 	inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL,
-				   TCP_TIMEOUT_INIT, TCP_RTO_MAX);
+				   sysctl_tcp_initial_rto, TCP_RTO_MAX);
 }
 
 void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req)
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 352c260..f8a07a8 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -45,7 +45,7 @@ static __u16 const msstab[] = {
  * sysctl_tcp_retries1. It's a rather complicated formula (exponential
  * backoff) to compute at runtime so it's currently hardcoded here.
  */
-#define COUNTER_TRIES 4
+#define COUNTER_TRIES (sysctl_tcp_initial_rto/HZ + 1)
 
 static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 					   struct request_sock *req,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4f49e5d..7e791e6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1349,7 +1349,7 @@ have_isn:
 	    want_cookie)
 		goto drop_and_free;
 
-	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+	inet6_csk_reqsk_queue_hash_add(sk, req, sysctl_tcp_initial_rto);
 	return 0;
 
 drop_and_release:
@@ -1957,8 +1957,8 @@ static int tcp_v6_init_sock(struct sock *sk)
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
 
-	icsk->icsk_rto = TCP_TIMEOUT_INIT;
-	tp->mdev = TCP_TIMEOUT_INIT;
+	icsk->icsk_rto = sysctl_tcp_initial_rto;
+	tp->mdev = sysctl_tcp_initial_rto;
 
 	/* So many TCP implementations out there (incorrectly) count the
 	 * initial SYN frame in their delayed-ACK and congestion control
-- 
1.7.0.4

