From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: refine pacing rate determination
Date: Fri, 21 Aug 2015 17:38:02 -0700
Message-ID: <1440203882.29244.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33497 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbHVAiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 20:38:06 -0400
Received: by pacgr6 with SMTP id gr6so4466386pac.0
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 17:38:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When TCP pacing was added back in linux-3.12, we chose
to apply a fixed ratio of 200 % against current rate,
to allow probing for optimal throughput even during
slow start phase, where cwnd can be doubled every other gRTT.

At Google, we found it was better applying a different ratio
while in Congestion Avoidance phase.
This ratio was set to 120 %.

We've used the normal tcp_in_slow_start() helper for a while,
then tuned the condition to select the conservative ratio
as soon as cwnd >= ssthresh/2 :

- After cwnd reduction, it is safer to ramp up more slowly,
  as we approach optimal cwnd.
- Initial ramp up (ssthresh == INFINITY) still allows doubling
  cwnd every other RTT.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 Documentation/networking/ip-sysctl.txt |   15 +++++++++++++++
 include/net/tcp.h                      |    2 ++
 net/ipv4/sysctl_net_ipv4.c             |   19 +++++++++++++++++++
 net/ipv4/tcp_input.c                   |   18 +++++++++++++++++-
 4 files changed, 53 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 46e88ed7f41d..ac77a13d2ea2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -586,6 +586,21 @@ tcp_min_tso_segs - INTEGER
 	if available window is too small.
 	Default: 2
 
+tcp_pacing_ss_ratio - INTEGER
+	sk->sk_pacing_rate is set by TCP stack using a ratio applied
+	to current rate. (current_rate = cwnd * mss / srtt)
+	If TCP is in slow start, tcp_pacing_ss_ratio is applied
+	to let TCP probe for bigger speeds, assuming cwnd can be
+	doubled every other RTT.
+	Default: 200
+
+tcp_pacing_ca_ratio - INTEGER
+	sk->sk_pacing_rate is set by TCP stack using a ratio applied
+	to current rate. (current_rate = cwnd * mss / srtt)
+	If TCP is in congestion avoidance phase, tcp_pacing_ca_ratio
+	is applied to conservatively probe for bigger throughput.
+	Default: 120
+
 tcp_tso_win_divisor - INTEGER
 	This allows control over what percentage of the congestion window
 	can be consumed by a single TSO frame.
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 364426a2be5a..3e2b3ba43ae5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -281,6 +281,8 @@ extern unsigned int sysctl_tcp_notsent_lowat;
 extern int sysctl_tcp_min_tso_segs;
 extern int sysctl_tcp_autocorking;
 extern int sysctl_tcp_invalid_ratelimit;
+extern int sysctl_tcp_pacing_ss_ratio;
+extern int sysctl_tcp_pacing_ca_ratio;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 0330ab2e2b63..879bdc5c95b1 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -29,6 +29,7 @@
 static int zero;
 static int one = 1;
 static int four = 4;
+static int thousand = 1000;
 static int gso_max_segs = GSO_MAX_SEGS;
 static int tcp_retr1_max = 255;
 static int ip_local_port_range_min[] = { 1, 1 };
@@ -712,6 +713,24 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &gso_max_segs,
 	},
 	{
+		.procname	= "tcp_pacing_ss_ratio",
+		.data		= &sysctl_tcp_pacing_ss_ratio,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &thousand,
+	},
+	{
+		.procname	= "tcp_pacing_ca_ratio",
+		.data		= &sysctl_tcp_pacing_ca_ratio,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &thousand,
+	},
+	{
 		.procname	= "tcp_autocorking",
 		.data		= &sysctl_tcp_autocorking,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4e4d6bcd0ca9..7e1623775744 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -753,13 +753,29 @@ static void tcp_rtt_estimator(struct sock *sk, long mrtt_us)
  * TCP pacing, to smooth the burst on large writes when packets
  * in flight is significantly lower than cwnd (or rwin)
  */
+int sysctl_tcp_pacing_ss_ratio __read_mostly = 200;
+int sysctl_tcp_pacing_ca_ratio __read_mostly = 120;
+
 static void tcp_update_pacing_rate(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	u64 rate;
 
 	/* set sk_pacing_rate to 200 % of current rate (mss * cwnd / srtt) */
-	rate = (u64)tp->mss_cache * 2 * (USEC_PER_SEC << 3);
+	rate = (u64)tp->mss_cache * ((USEC_PER_SEC / 100) << 3);
+
+	/* current rate is (cwnd * mss) / srtt
+	 * In Slow Start [1], set sk_pacing_rate to 200 % the current rate.
+	 * In Congestion Avoidance phase, set it to 120 % the current rate.
+	 *
+	 * [1] : Normal Slow Start condition is (tp->snd_cwnd < tp->snd_ssthresh)
+	 *	 If snd_cwnd >= (tp->snd_ssthresh / 2), we are approaching
+	 *	 end of slow start and should slow down.
+	 */
+	if (tp->snd_cwnd < tp->snd_ssthresh / 2)
+		rate *= sysctl_tcp_pacing_ss_ratio;
+	else
+		rate *= sysctl_tcp_pacing_ca_ratio;
 
 	rate *= max(tp->snd_cwnd, tp->packets_out);
 
