From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: v3.8.5: "TCP: snd_cwnd is nul, please report this bug."
Date: Mon, 08 Apr 2013 07:30:22 -0700
Message-ID: <1365431422.3887.10.camel@edumazet-glaptop>
References: <87zjx9pf13.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:37819 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936441Ab3DHOaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 10:30:25 -0400
Received: by mail-ie0-f179.google.com with SMTP id k11so7011130iea.10
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 07:30:25 -0700 (PDT)
In-Reply-To: <87zjx9pf13.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 11:06 +0200, Bj=C3=B8rn Mork wrote:
> Hello,
>=20
> I just got this message running a Debian experimental
> linux-image-3.8-trunk-amd64 kernel, currently based on v3.8.5.
>=20
> Peeked briefly through the commit adding the message, but I couldn't
> figure out what other info you'd need so please ask if there is anyth=
ing
> I can dig up.
>=20
> I suspect the warning could be related to problems with the iwlwifi
> driver and/or access point.  The message was immediately followed  by=
 a
> few messges from iwlwifi:
>=20
>=20
> Apr  8 10:58:09 nemi kernel: [152701.980799] TCP: snd_cwnd is nul, pl=
ease report this bug.
> Apr  8 10:58:33 nemi kernel: [152725.176151] iwlwifi 0000:03:00.0: fa=
il to flush all tx fifo queues
> Apr  8 10:58:33 nemi kernel: [152725.185713] wlan0: authenticate with=
 00:22:90:f9:23:a0
> Apr  8 10:58:33 nemi kernel: [152725.185738] wlan0: capabilities/regu=
latory prevented using AP HT/VHT configuration, downgraded
> Apr  8 10:58:33 nemi kernel: [152725.190150] wlan0: send auth to 00:2=
2:90:f9:23:a0 (try 1/3)
> Apr  8 10:58:33 nemi kernel: [152725.199812] wlan0: authenticated
> Apr  8 10:58:33 nemi kernel: [152725.200020] iwlwifi 0000:03:00.0 wla=
n0: disabling HT as WMM/QoS is not supported by the AP
> Apr  8 10:58:33 nemi kernel: [152725.200027] iwlwifi 0000:03:00.0 wla=
n0: disabling VHT as WMM/QoS is not supported by the AP
> Apr  8 10:58:33 nemi kernel: [152725.204033] wlan0: associate with 00=
:22:90:f9:23:a0 (try 1/3)
> Apr  8 10:58:33 nemi kernel: [152725.207317] wlan0: RX AssocResp from=
 00:22:90:f9:23:a0 (capab=3D0x421 status=3D0 aid=3D12)
> Apr  8 10:58:33 nemi kernel: [152725.210745] wlan0: associated
>=20

Same issue was reported by Dave Jones on iwlwifi few days ago and I sen=
t
following debugging patch, could you try it ?

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4475aaf..e2e89aa 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -609,6 +609,14 @@ static inline u32 __tcp_set_rto(const struct tcp_s=
ock *tp)
=20
 extern void tcp_set_rto(struct sock *sk);
=20
+extern void tcp_snd_cwnd_bad(const struct tcp_sock *tp);
+static inline void tcp_snd_cwnd_set(struct tcp_sock *tp, u32 newval)
+{
+	if (unlikely(!newval))
+		tcp_snd_cwnd_bad(tp);
+	tp->snd_cwnd =3D newval;
+}
+
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd=
)
 {
 	tp->pred_flags =3D htonl((tp->tcp_header_len << 26) |
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a96f7b5..4347e22 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3300,6 +3300,33 @@ void tcp_done(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(tcp_done);
=20
+void tcp_snd_cwnd_bad(const struct tcp_sock *tp)
+{
+	static bool warned =3D false;
+
+	if (!warned) {
+		const struct sock *sk =3D (struct sock *)tp;
+		const struct inet_sock *inet =3D inet_sk(sk);
+
+		warned =3D true;
+		if (sk->sk_family =3D=3D AF_INET)
+			pr_err("TCP: zero snd_cwnd src:%pI4.%u dst:%pI4.%u\n",
+			       &inet->inet_saddr, ntohs(inet->inet_sport),
+			       &inet->inet_daddr, ntohs(inet->inet_dport));
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (sk->sk_family =3D=3D AF_INET6) {
+			const struct ipv6_pinfo *np =3D inet6_sk(sk);
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
=20
 static __initdata unsigned long thash_entries;
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 019c238..6ddd167 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -327,7 +327,7 @@ void tcp_slow_start(struct tcp_sock *tp)
 		tp->snd_cwnd_cnt -=3D snd_cwnd;
 		delta++;
 	}
-	tp->snd_cwnd =3D min(snd_cwnd + delta, tp->snd_cwnd_clamp);
+	tcp_snd_cwnd_set(tp, min(snd_cwnd + delta, tp->snd_cwnd_clamp));
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
=20
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index 57bdd17..d236b70 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -60,7 +60,7 @@ static void hybla_init(struct sock *sk)
=20
 	/* set minimum rtt as this is the 1st ever seen */
 	ca->minrtt =3D tp->srtt;
-	tp->snd_cwnd =3D ca->rho;
+	tcp_snd_cwnd_set(tp, ca->rho);
 }
=20
 static void hybla_state(struct sock *sk, u8 ca_state)
@@ -157,9 +157,9 @@ static void hybla_cong_avoid(struct sock *sk, u32 a=
ck, u32 in_flight)
 	}
 	/* clamp down slowstart cwnd to ssthresh value. */
 	if (is_slowstart)
-		tp->snd_cwnd =3D min(tp->snd_cwnd, tp->snd_ssthresh);
+		tcp_snd_cwnd_set(tp, min(tp->snd_cwnd, tp->snd_ssthresh));
=20
-	tp->snd_cwnd =3D min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
+	tcp_snd_cwnd_set(tp, min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp));
 }
=20
 static struct tcp_congestion_ops tcp_hybla __read_mostly =3D {
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 834857f..71135e3 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -284,8 +284,9 @@ static void tcp_illinois_cong_avoid(struct sock *sk=
, u32 ack, u32 in_flight)
 		*/
 		delta =3D (tp->snd_cwnd_cnt * ca->alpha) >> ALPHA_SHIFT;
 		if (delta >=3D tp->snd_cwnd) {
-			tp->snd_cwnd =3D min(tp->snd_cwnd + delta / tp->snd_cwnd,
-					   (u32) tp->snd_cwnd_clamp);
+			tcp_snd_cwnd_set(tp,
+					 min(tp->snd_cwnd + delta / tp->snd_cwnd,
+					     (u32) tp->snd_cwnd_clamp));
 			tp->snd_cwnd_cnt =3D 0;
 		}
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6d9ca35..b972577 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2259,8 +2259,8 @@ static void tcp_update_scoreboard(struct sock *sk=
, int fast_rexmit)
  */
 static inline void tcp_moderate_cwnd(struct tcp_sock *tp)
 {
-	tp->snd_cwnd =3D min(tp->snd_cwnd,
-			   tcp_packets_in_flight(tp) + tcp_max_burst(tp));
+	tcp_snd_cwnd_set(tp, min(tp->snd_cwnd,
+				 tcp_packets_in_flight(tp) + tcp_max_burst(tp)));
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
 }
=20
@@ -2312,18 +2312,20 @@ static void tcp_undo_cwr(struct sock *sk, const=
 bool undo_ssthresh)
=20
 	if (tp->prior_ssthresh) {
 		const struct inet_connection_sock *icsk =3D inet_csk(sk);
+		u32 newval;
=20
 		if (icsk->icsk_ca_ops->undo_cwnd)
-			tp->snd_cwnd =3D icsk->icsk_ca_ops->undo_cwnd(sk);
+			newval =3D icsk->icsk_ca_ops->undo_cwnd(sk);
 		else
-			tp->snd_cwnd =3D max(tp->snd_cwnd, tp->snd_ssthresh << 1);
+			newval =3D max(tp->snd_cwnd, tp->snd_ssthresh << 1);
+		tcp_snd_cwnd_set(tp, newval);
=20
 		if (undo_ssthresh && tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh =3D tp->prior_ssthresh;
 			TCP_ECN_withdraw_cwr(tp);
 		}
 	} else {
-		tp->snd_cwnd =3D max(tp->snd_cwnd, tp->snd_ssthresh);
+		tcp_snd_cwnd_set(tp, max(tp->snd_cwnd, tp->snd_ssthresh));
 	}
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
 }
@@ -2512,7 +2514,7 @@ static void tcp_cwnd_reduction(struct sock *sk, i=
nt newly_acked_sacked,
 	}
=20
 	sndcnt =3D max(sndcnt, (fast_rexmit ? 1 : 0));
-	tp->snd_cwnd =3D tcp_packets_in_flight(tp) + sndcnt;
+	tcp_snd_cwnd_set(tp, tcp_packets_in_flight(tp) + sndcnt);
 }
=20
 static inline void tcp_end_cwnd_reduction(struct sock *sk)
@@ -2522,7 +2524,7 @@ static inline void tcp_end_cwnd_reduction(struct =
sock *sk)
 	/* Reset cwnd to ssthresh in CWR or Recovery (unless it's undone) */
 	if (inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_CWR ||
 	    (tp->undo_marker && tp->snd_ssthresh < TCP_INFINITE_SSTHRESH)) {
-		tp->snd_cwnd =3D tp->snd_ssthresh;
+		tcp_snd_cwnd_set(tp, tp->snd_ssthresh);
 		tp->snd_cwnd_stamp =3D tcp_time_stamp;
 	}
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
@@ -2591,9 +2593,9 @@ static void tcp_mtup_probe_success(struct sock *s=
k)
=20
 	/* FIXME: breaks with very large cwnd */
 	tp->prior_ssthresh =3D tcp_current_ssthresh(sk);
-	tp->snd_cwnd =3D tp->snd_cwnd *
-		       tcp_mss_to_mtu(sk, tp->mss_cache) /
-		       icsk->icsk_mtup.probe_size;
+	tcp_snd_cwnd_set(tp, tp->snd_cwnd *
+			     tcp_mss_to_mtu(sk, tp->mss_cache) /
+			     icsk->icsk_mtup.probe_size);
 	tp->snd_cwnd_cnt =3D 0;
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
 	tp->snd_ssthresh =3D tcp_current_ssthresh(sk);
@@ -4665,7 +4667,7 @@ void tcp_cwnd_application_limited(struct sock *sk=
)
 		u32 win_used =3D max(tp->snd_cwnd_used, init_win);
 		if (win_used < tp->snd_cwnd) {
 			tp->snd_ssthresh =3D tcp_current_ssthresh(sk);
-			tp->snd_cwnd =3D (tp->snd_cwnd + win_used) >> 1;
+			tcp_snd_cwnd_set(tp, (tp->snd_cwnd + win_used) >> 1);
 		}
 		tp->snd_cwnd_used =3D 0;
 	}
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index 72f7218..09bf418 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -307,7 +307,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 =
num_acked, s32 rtt_us)
 	/* happened after inference
 	 * cut snd_cwnd into half */
 	else
-		tp->snd_cwnd =3D max(tp->snd_cwnd >> 1U, 1U);
+		tcp_snd_cwnd_set(tp, max(tp->snd_cwnd >> 1U, 1U));
=20
 	/* record this drop time */
 	lp->last_drop =3D tcp_time_stamp;
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index f696d7c..d5a6608 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -526,7 +526,7 @@ reset:
 	if (tp->total_retrans > 1)
 		tp->snd_cwnd =3D 1;
 	else
-		tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);
+		tcp_snd_cwnd_set(tp, tcp_init_cwnd(tp, dst));
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
 }
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index af354c98..2b80083 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -148,7 +148,7 @@ static void tcp_cwnd_restart(struct sock *sk, const=
 struct dst_entry *dst)
=20
 	while ((delta -=3D inet_csk(sk)->icsk_rto) > 0 && cwnd > restart_cwnd=
)
 		cwnd >>=3D 1;
-	tp->snd_cwnd =3D max(cwnd, restart_cwnd);
+	tcp_snd_cwnd_set(tp, max(cwnd, restart_cwnd));
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
 	tp->snd_cwnd_used =3D 0;
 }
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 80fa2bf..a270cf9 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -238,7 +238,8 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u=
32 ack, u32 in_flight)
 				 * truncation robs us of full link
 				 * utilization.
 				 */
-				tp->snd_cwnd =3D min(tp->snd_cwnd, (u32)target_cwnd+1);
+				tcp_snd_cwnd_set(tp, min(tp->snd_cwnd,
+							 (u32)target_cwnd + 1));
 				tp->snd_ssthresh =3D tcp_vegas_ssthresh(tp);
=20
 			} else if (tp->snd_cwnd <=3D tp->snd_ssthresh) {
@@ -272,7 +273,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u=
32 ack, u32 in_flight)
 			if (tp->snd_cwnd < 2)
 				tp->snd_cwnd =3D 2;
 			else if (tp->snd_cwnd > tp->snd_cwnd_clamp)
-				tp->snd_cwnd =3D tp->snd_cwnd_clamp;
+				tcp_snd_cwnd_set(tp, tp->snd_cwnd_clamp);
=20
 			tp->snd_ssthresh =3D tcp_current_ssthresh(sk);
 		}
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index ac43cd7..d1fa5c1 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -180,7 +180,7 @@ static void tcp_veno_cong_avoid(struct sock *sk, u3=
2 ack, u32 in_flight)
 		if (tp->snd_cwnd < 2)
 			tp->snd_cwnd =3D 2;
 		else if (tp->snd_cwnd > tp->snd_cwnd_clamp)
-			tp->snd_cwnd =3D tp->snd_cwnd_clamp;
+			tcp_snd_cwnd_set(tp, tp->snd_cwnd_clamp);
 	}
 	/* Wipe the slate clean for the next rtt. */
 	/* veno->cntrtt =3D 0; */
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 76a1e23..060fbb5 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -233,7 +233,8 @@ static void tcp_westwood_event(struct sock *sk, enu=
m tcp_ca_event event)
 		break;
=20
 	case CA_EVENT_COMPLETE_CWR:
-		tp->snd_cwnd =3D tp->snd_ssthresh =3D tcp_westwood_bw_rttmin(sk);
+		tp->snd_ssthresh =3D tcp_westwood_bw_rttmin(sk);
+		tcp_snd_cwnd_set(tp, tp->snd_ssthresh);
 		break;
=20
 	case CA_EVENT_LOSS:
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 05c3b6f..3ad1dbb 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -161,11 +161,9 @@ static void tcp_yeah_cong_avoid(struct sock *sk, u=
32 ack, u32 in_flight)
 				    tp->snd_cwnd > yeah->reno_count) {
 					u32 reduction =3D min(queue / TCP_YEAH_GAMMA ,
 							    tp->snd_cwnd >> TCP_YEAH_EPSILON);
+					u32 tmp =3D tp->snd_cwnd - reduction;
=20
-					tp->snd_cwnd -=3D reduction;
-
-					tp->snd_cwnd =3D max(tp->snd_cwnd,
-							   yeah->reno_count);
+					tcp_snd_cwnd_set(tp, max(tmp, yeah->reno_count));
=20
 					tp->snd_ssthresh =3D tp->snd_cwnd;
 				}
