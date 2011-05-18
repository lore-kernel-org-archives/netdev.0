From: Benoit Sigoure <tsunanet@gmail.com>
Subject: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Wed, 18 May 2011 03:43:04 -0700
Message-ID: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
References: <1305619677.2850.11.camel@edumazet-laptop>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Benoit Sigoure <tsunanet@gmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305619677.2850.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of hardcoding the initial RTO to 3s and requiring
the kernel to be recompiled to change it, expose it as a
sysctl that can be tuned at runtime.  Leave the default
value unchanged.

Signed-off-by: Benoit Sigoure <tsunanet@gmail.com>
---

v2 of the patch to address Eric's comments.  Of course I had to forget
to convert things back and forth between jiffies and ms -- /me n00b.
Code compiles.  It seems like no one is opposed to this change, but if
one of you guys could express explicit interest in merging this change,
I'd be happy to spend a bit more time to test it.

The new sysctl is exposed in milliseconds but internally the value remains
in jiffies to avoid having to convert back / and forth between jiffies and
ms in most places.

I'm glad to hear that the default value will be tuned down to 1s.  This
change will help people play with this value and easily revert it back at
runtime if they feel like they preferred the current value.

Thank you for your time.

 Documentation/networking/ip-sysctl.txt |    8 ++++++++
 include/net/tcp.h                      |    3 ++-
 net/ipv4/syncookies.c                  |    2 +-
 net/ipv4/sysctl_net_ipv4.c             |   11 +++++++++++
 net/ipv4/tcp.c                         |    4 ++--
 net/ipv4/tcp_input.c                   |    8 ++++----
 net/ipv4/tcp_ipv4.c                    |    6 +++---
 net/ipv4/tcp_minisocks.c               |    6 +++---
 net/ipv4/tcp_output.c                  |    2 +-
 net/ipv4/tcp_timer.c                   |    9 +++++----
 net/ipv6/syncookies.c                  |    2 +-
 net/ipv6/tcp_ipv6.c                    |    6 +++---
 12 files changed, 44 insertions(+), 23 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d3d653a..7f3c7d2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -384,6 +384,14 @@ tcp_retries2 - INTEGER
 	RFC 1122 recommends at least 100 seconds for the timeout,
 	which corresponds to a value of at least 8.
 
+tcp_initial_rto - INTEGER
+	This value sets the initial retransmit timeout (in milliseconds),
+	that is how long the kernel will wait before retransmitting the
+	initial SYN packet.
+
+	RFC 1122 says that this SHOULD be 3000 milliseconds, which is the
+	default.
+
 tcp_rfc1337 - BOOLEAN
 	If set, the TCP stack behaves conforming to RFC1337. If unset,
 	we are not conforming to RFC, but prevent TCP TIME_WAIT
diff --git a/include/net/tcp.h b/include/net/tcp.h
index cda30ea..d6d7dea 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -213,6 +213,7 @@ extern int sysctl_tcp_syn_retries;
 extern int sysctl_tcp_synack_retries;
 extern int sysctl_tcp_retries1;
 extern int sysctl_tcp_retries2;
+extern int sysctl_tcp_initial_rto;  /* in jiffies */
 extern int sysctl_tcp_orphan_retries;
 extern int sysctl_tcp_syncookies;
 extern int sysctl_tcp_retrans_collapse;
@@ -295,7 +296,7 @@ static inline void tcp_synq_overflow(struct sock *sk)
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
index 321e6e8..51c778d 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -30,6 +30,8 @@ static int tcp_adv_win_scale_min = -31;
 static int tcp_adv_win_scale_max = 31;
 static int ip_ttl_min = 1;
 static int ip_ttl_max = 255;
+static int tcp_initial_rto_min = TCP_RTO_MIN;
+static int tcp_initial_rto_max = TCP_RTO_MAX;
 
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
@@ -246,6 +248,15 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+        {
+		.procname       = "tcp_initial_rto",
+		.data           = &sysctl_tcp_initial_rto,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.extra1		= &tcp_initial_rto_min,
+		.extra2		= &tcp_initial_rto_max,
+	},
 	{
 		.procname	= "tcp_fin_timeout",
 		.data		= &sysctl_tcp_fin_timeout,
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
index bef9f04..39f6c27 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -890,7 +890,7 @@ static void tcp_init_metrics(struct sock *sk)
 	if (dst_metric(dst, RTAX_RTT) == 0)
 		goto reset;
 
-	if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (TCP_TIMEOUT_INIT << 3))
+	if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (sysctl_tcp_initial_rto << 3))
 		goto reset;
 
 	/* Initial rtt is determined from SYN,SYN-ACK.
@@ -916,7 +916,7 @@ static void tcp_init_metrics(struct sock *sk)
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 	}
 	tcp_set_rto(sk);
-	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp) {
+	if (inet_csk(sk)->icsk_rto < sysctl_tcp_initial_rto && !tp->rx_opt.saw_tstamp) {
 reset:
 		/* Play conservative. If timestamps are not
 		 * supported, TCP will fail to recalculate correct
@@ -924,8 +924,8 @@ reset:
 		 */
 		if (!tp->rx_opt.saw_tstamp && tp->srtt) {
 			tp->srtt = 0;
-			tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
-			inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+			tp->mdev = tp->mdev_max = tp->rttvar = sysctl_tcp_initial_rto;
+			inet_csk(sk)->icsk_rto = sysctl_tcp_initial_rto;
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
index ecd44b0..b9da62b 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -29,6 +29,7 @@ int sysctl_tcp_keepalive_probes __read_mostly = TCP_KEEPALIVE_PROBES;
 int sysctl_tcp_keepalive_intvl __read_mostly = TCP_KEEPALIVE_INTVL;
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
+int sysctl_tcp_initial_rto __read_mostly = TCP_TIMEOUT_INIT;
 int sysctl_tcp_orphan_retries __read_mostly;
 int sysctl_tcp_thin_linear_timeouts __read_mostly;
 
@@ -135,8 +136,8 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 
 /* This function calculates a "timeout" which is equivalent to the timeout of a
  * TCP connection after "boundary" unsuccessful, exponentially backed-off
- * retransmissions with an initial RTO of TCP_RTO_MIN or TCP_TIMEOUT_INIT if
- * syn_set flag is set.
+ * retransmissions with an initial RTO of TCP_RTO_MIN or
+ * sysctl_tcp_initial_rto if syn_set flag is set.
  */
 static bool retransmits_timed_out(struct sock *sk,
 				  unsigned int boundary,
@@ -144,7 +145,7 @@ static bool retransmits_timed_out(struct sock *sk,
 				  bool syn_set)
 {
 	unsigned int linear_backoff_thresh, start_ts;
-	unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
+	unsigned int rto_base = syn_set ? sysctl_tcp_initial_rto : TCP_RTO_MIN;
 
 	if (!inet_csk(sk)->icsk_retransmits)
 		return false;
@@ -495,7 +496,7 @@ out_unlock:
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
