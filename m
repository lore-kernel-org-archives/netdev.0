From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP: snd_cwnd is nul, please report this bug.
Date: Wed, 03 Apr 2013 17:08:12 -0700
Message-ID: <1365034092.13853.42.camel@edumazet-glaptop>
References: <20130403035428.GA31709@redhat.com>
	 <1364965967.5113.195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:64212 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760450Ab3DDAIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 20:08:15 -0400
Received: by mail-pb0-f54.google.com with SMTP id xa7so1125891pbc.13
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 17:08:15 -0700 (PDT)
In-Reply-To: <1364965967.5113.195.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-02 at 22:12 -0700, Eric Dumazet wrote:
> On Tue, 2013-04-02 at 23:54 -0400, Dave Jones wrote:
> > Just had this warning on 3.9-rc5
> > 
> > Not sure what else to report.  Nothing really odd going on,
> > just some ssh traffic and firefox over wifi (iwlwifi)
> > 
> > anything else I can provide ?
> 
> Thanks for the report.
> 
> I guess we'll need to resurrect a patch I did to track the (buggy)
> setting to 0.

Any chance you can use David net-next tree + following patch ?

(it also applies to Linus tree with some fuzz)

Thanks !

 include/net/tcp.h       |    8 ++++++++
 net/ipv4/tcp.c          |   27 +++++++++++++++++++++++++++
 net/ipv4/tcp_cong.c     |    2 +-
 net/ipv4/tcp_hybla.c    |    6 +++---
 net/ipv4/tcp_illinois.c |    5 +++--
 net/ipv4/tcp_input.c    |   24 +++++++++++++-----------
 net/ipv4/tcp_lp.c       |    2 +-
 net/ipv4/tcp_metrics.c  |    2 +-
 net/ipv4/tcp_output.c   |    2 +-
 net/ipv4/tcp_vegas.c    |    5 +++--
 net/ipv4/tcp_veno.c     |    2 +-
 net/ipv4/tcp_westwood.c |    3 ++-
 net/ipv4/tcp_yeah.c     |    6 ++----
 13 files changed, 66 insertions(+), 28 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4475aaf..e2e89aa 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -609,6 +609,14 @@ static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 
 extern void tcp_set_rto(struct sock *sk);
 
+extern void tcp_snd_cwnd_bad(const struct tcp_sock *tp);
+static inline void tcp_snd_cwnd_set(struct tcp_sock *tp, u32 newval)
+{
+	if (unlikely(!newval))
+		tcp_snd_cwnd_bad(tp);
+	tp->snd_cwnd = newval;
+}
+
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
 {
 	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a96f7b5..4347e22 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3300,6 +3300,33 @@ void tcp_done(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(tcp_done);
 
+void tcp_snd_cwnd_bad(const struct tcp_sock *tp)
+{
+	static bool warned = false;
+
+	if (!warned) {
+		const struct sock *sk = (struct sock *)tp;
+		const struct inet_sock *inet = inet_sk(sk);
+
+		warned = true;
+		if (sk->sk_family == AF_INET)
+			pr_err("TCP: zero snd_cwnd src:%pI4.%u dst:%pI4.%u\n",
+			       &inet->inet_saddr, ntohs(inet->inet_sport),
+			       &inet->inet_daddr, ntohs(inet->inet_dport));
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (sk->sk_family == AF_INET6) {
+			const struct ipv6_pinfo *np = inet6_sk(sk);
+
+			pr_err("TCP: zero snd_cwnd src:%pI6.%u dst:%pI6.%u\n",
+			       &np->saddr, ntohs(inet->inet_sport),
+			       &np->daddr, ntohs(inet->inet_dport));
+		}
+#endif
+		WARN_ON_ONCE(1);
+	}
+}
+EXPORT_SYMBOL(tcp_snd_cwnd_bad);
+
 extern struct tcp_congestion_ops tcp_reno;
 
 static __initdata unsigned long thash_entries;
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 019c238..6ddd167 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -327,7 +327,7 @@ void tcp_slow_start(struct tcp_sock *tp)
 		tp->snd_cwnd_cnt -= snd_cwnd;
 		delta++;
 	}
-	tp->snd_cwnd = min(snd_cwnd + delta, tp->snd_cwnd_clamp);
+	tcp_snd_cwnd_set(tp, min(snd_cwnd + delta, tp->snd_cwnd_clamp));
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index 57bdd17..d236b70 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -60,7 +60,7 @@ static void hybla_init(struct sock *sk)
 
 	/* set minimum rtt as this is the 1st ever seen */
 	ca->minrtt = tp->srtt;
-	tp->snd_cwnd = ca->rho;
+	tcp_snd_cwnd_set(tp, ca->rho);
 }
 
 static void hybla_state(struct sock *sk, u8 ca_state)
@@ -157,9 +157,9 @@ static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 	}
 	/* clamp down slowstart cwnd to ssthresh value. */
 	if (is_slowstart)
-		tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
+		tcp_snd_cwnd_set(tp, min(tp->snd_cwnd, tp->snd_ssthresh));
 
-	tp->snd_cwnd = min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
+	tcp_snd_cwnd_set(tp, min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp));
 }
 
 static struct tcp_congestion_ops tcp_hybla __read_mostly = {
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 834857f..71135e3 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -284,8 +284,9 @@ static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 		*/
 		delta = (tp->snd_cwnd_cnt * ca->alpha) >> ALPHA_SHIFT;
 		if (delta >= tp->snd_cwnd) {
-			tp->snd_cwnd = min(tp->snd_cwnd + delta / tp->snd_cwnd,
-					   (u32) tp->snd_cwnd_clamp);
+			tcp_snd_cwnd_set(tp,
+					 min(tp->snd_cwnd + delta / tp->snd_cwnd,
+					     (u32) tp->snd_cwnd_clamp));
 			tp->snd_cwnd_cnt = 0;
 		}
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6d9ca35..b972577 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2259,8 +2259,8 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
  */
 static inline void tcp_moderate_cwnd(struct tcp_sock *tp)
 {
-	tp->snd_cwnd = min(tp->snd_cwnd,
-			   tcp_packets_in_flight(tp) + tcp_max_burst(tp));
+	tcp_snd_cwnd_set(tp, min(tp->snd_cwnd,
+				 tcp_packets_in_flight(tp) + tcp_max_burst(tp)));
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
@@ -2312,18 +2312,20 @@ static void tcp_undo_cwr(struct sock *sk, const bool undo_ssthresh)
 
 	if (tp->prior_ssthresh) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
+		u32 newval;
 
 		if (icsk->icsk_ca_ops->undo_cwnd)
-			tp->snd_cwnd = icsk->icsk_ca_ops->undo_cwnd(sk);
+			newval = icsk->icsk_ca_ops->undo_cwnd(sk);
 		else
-			tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh << 1);
+			newval = max(tp->snd_cwnd, tp->snd_ssthresh << 1);
+		tcp_snd_cwnd_set(tp, newval);
 
 		if (undo_ssthresh && tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh = tp->prior_ssthresh;
 			TCP_ECN_withdraw_cwr(tp);
 		}
 	} else {
-		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh);
+		tcp_snd_cwnd_set(tp, max(tp->snd_cwnd, tp->snd_ssthresh));
 	}
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
@@ -2512,7 +2514,7 @@ static void tcp_cwnd_reduction(struct sock *sk, int newly_acked_sacked,
 	}
 
 	sndcnt = max(sndcnt, (fast_rexmit ? 1 : 0));
-	tp->snd_cwnd = tcp_packets_in_flight(tp) + sndcnt;
+	tcp_snd_cwnd_set(tp, tcp_packets_in_flight(tp) + sndcnt);
 }
 
 static inline void tcp_end_cwnd_reduction(struct sock *sk)
@@ -2522,7 +2524,7 @@ static inline void tcp_end_cwnd_reduction(struct sock *sk)
 	/* Reset cwnd to ssthresh in CWR or Recovery (unless it's undone) */
 	if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR ||
 	    (tp->undo_marker && tp->snd_ssthresh < TCP_INFINITE_SSTHRESH)) {
-		tp->snd_cwnd = tp->snd_ssthresh;
+		tcp_snd_cwnd_set(tp, tp->snd_ssthresh);
 		tp->snd_cwnd_stamp = tcp_time_stamp;
 	}
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
@@ -2591,9 +2593,9 @@ static void tcp_mtup_probe_success(struct sock *sk)
 
 	/* FIXME: breaks with very large cwnd */
 	tp->prior_ssthresh = tcp_current_ssthresh(sk);
-	tp->snd_cwnd = tp->snd_cwnd *
-		       tcp_mss_to_mtu(sk, tp->mss_cache) /
-		       icsk->icsk_mtup.probe_size;
+	tcp_snd_cwnd_set(tp, tp->snd_cwnd *
+			     tcp_mss_to_mtu(sk, tp->mss_cache) /
+			     icsk->icsk_mtup.probe_size);
 	tp->snd_cwnd_cnt = 0;
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 	tp->snd_ssthresh = tcp_current_ssthresh(sk);
@@ -4665,7 +4667,7 @@ void tcp_cwnd_application_limited(struct sock *sk)
 		u32 win_used = max(tp->snd_cwnd_used, init_win);
 		if (win_used < tp->snd_cwnd) {
 			tp->snd_ssthresh = tcp_current_ssthresh(sk);
-			tp->snd_cwnd = (tp->snd_cwnd + win_used) >> 1;
+			tcp_snd_cwnd_set(tp, (tp->snd_cwnd + win_used) >> 1);
 		}
 		tp->snd_cwnd_used = 0;
 	}
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index 72f7218..09bf418 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -307,7 +307,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
 	/* happened after inference
 	 * cut snd_cwnd into half */
 	else
-		tp->snd_cwnd = max(tp->snd_cwnd >> 1U, 1U);
+		tcp_snd_cwnd_set(tp, max(tp->snd_cwnd >> 1U, 1U));
 
 	/* record this drop time */
 	lp->last_drop = tcp_time_stamp;
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index f696d7c..d5a6608 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -526,7 +526,7 @@ reset:
 	if (tp->total_retrans > 1)
 		tp->snd_cwnd = 1;
 	else
-		tp->snd_cwnd = tcp_init_cwnd(tp, dst);
+		tcp_snd_cwnd_set(tp, tcp_init_cwnd(tp, dst));
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index af354c98..2b80083 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -148,7 +148,7 @@ static void tcp_cwnd_restart(struct sock *sk, const struct dst_entry *dst)
 
 	while ((delta -= inet_csk(sk)->icsk_rto) > 0 && cwnd > restart_cwnd)
 		cwnd >>= 1;
-	tp->snd_cwnd = max(cwnd, restart_cwnd);
+	tcp_snd_cwnd_set(tp, max(cwnd, restart_cwnd));
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 	tp->snd_cwnd_used = 0;
 }
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 80fa2bf..a270cf9 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -238,7 +238,8 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 				 * truncation robs us of full link
 				 * utilization.
 				 */
-				tp->snd_cwnd = min(tp->snd_cwnd, (u32)target_cwnd+1);
+				tcp_snd_cwnd_set(tp, min(tp->snd_cwnd,
+							 (u32)target_cwnd + 1));
 				tp->snd_ssthresh = tcp_vegas_ssthresh(tp);
 
 			} else if (tp->snd_cwnd <= tp->snd_ssthresh) {
@@ -272,7 +273,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 			if (tp->snd_cwnd < 2)
 				tp->snd_cwnd = 2;
 			else if (tp->snd_cwnd > tp->snd_cwnd_clamp)
-				tp->snd_cwnd = tp->snd_cwnd_clamp;
+				tcp_snd_cwnd_set(tp, tp->snd_cwnd_clamp);
 
 			tp->snd_ssthresh = tcp_current_ssthresh(sk);
 		}
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index ac43cd7..d1fa5c1 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -180,7 +180,7 @@ static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 		if (tp->snd_cwnd < 2)
 			tp->snd_cwnd = 2;
 		else if (tp->snd_cwnd > tp->snd_cwnd_clamp)
-			tp->snd_cwnd = tp->snd_cwnd_clamp;
+			tcp_snd_cwnd_set(tp, tp->snd_cwnd_clamp);
 	}
 	/* Wipe the slate clean for the next rtt. */
 	/* veno->cntrtt = 0; */
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 76a1e23..060fbb5 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -233,7 +233,8 @@ static void tcp_westwood_event(struct sock *sk, enum tcp_ca_event event)
 		break;
 
 	case CA_EVENT_COMPLETE_CWR:
-		tp->snd_cwnd = tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
+		tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
+		tcp_snd_cwnd_set(tp, tp->snd_ssthresh);
 		break;
 
 	case CA_EVENT_LOSS:
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 05c3b6f..3ad1dbb 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -161,11 +161,9 @@ static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 				    tp->snd_cwnd > yeah->reno_count) {
 					u32 reduction = min(queue / TCP_YEAH_GAMMA ,
 							    tp->snd_cwnd >> TCP_YEAH_EPSILON);
+					u32 tmp = tp->snd_cwnd - reduction;
 
-					tp->snd_cwnd -= reduction;
-
-					tp->snd_cwnd = max(tp->snd_cwnd,
-							   yeah->reno_count);
+					tcp_snd_cwnd_set(tp, max(tmp, yeah->reno_count));
 
 					tp->snd_ssthresh = tp->snd_cwnd;
 				}
