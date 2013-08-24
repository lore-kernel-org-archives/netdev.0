From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: TSO packets automatic sizing
Date: Fri, 23 Aug 2013 17:29:52 -0700
Message-ID: <1377304192.8828.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:64005 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754492Ab3HXA3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 20:29:54 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so1269212pdi.19
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 17:29:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After hearing many people over past years complaining against TSO being
bursty or even buggy, we are proud to present automatic sizing of TSO
packets.

One part of the problem is that tcp_tso_should_defer() uses an heuristic
relying on upcoming ACKS instead of a timer, but more generally, having
big TSO packets makes little sense for low rates, as it tends to create
micro bursts on the network, and general consensus is to reduce the
buffering amount.

This patch introduces a per socket sk_pacing_rate, that approximates
the current sending rate, and allows us to size the TSO packets so
that we try to send one packet every ms.

This field could be set by other transports.

Patch has no impact for high speed flows, where having large TSO packets
makes sense to reach line rate.

For other flows, this helps better packet scheduling and ACK clocking.

This patch increases performance of TCP flows in lossy environments.

A new sysctl (tcp_min_tso_segs) is added, to specify the
minimal size of a TSO packet (default being 2).

A follow-up patch will provide a new packet scheduler (FQ), using
sk_pacing_rate as an input to perform optional per flow pacing.

This explains why we chose to set sk_pacing_rate to twice the current
rate, allowing 'slow start' ramp up.

sk_pacing_rate = 2 * cwnd * mss / srtt
 
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Van Jacobson <vanj@google.com>
Cc: Tom Herbert <therbert@google.com>
---
Google-Bug-Id: 8662219

 Documentation/networking/ip-sysctl.txt |    9 +++++++
 include/net/sock.h                     |    2 +
 include/net/tcp.h                      |    1 
 net/ipv4/sysctl_net_ipv4.c             |   10 ++++++++
 net/ipv4/tcp.c                         |   28 ++++++++++++++++++-----
 net/ipv4/tcp_input.c                   |   17 +++++++++++++
 6 files changed, 62 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index debfe85..ce5bb43 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -482,6 +482,15 @@ tcp_syn_retries - INTEGER
 tcp_timestamps - BOOLEAN
 	Enable timestamps as defined in RFC1323.
 
+tcp_min_tso_segs - INTEGER
+	Minimal number of segments per TCP TSO frame.
+	Since linux-3.12, TCP does an automatic sizing of TSO frames,
+	depending on flow rate, instead of filling 64Kbytes packets.
+	For specific usages, it's possible to force TCP to build big
+	TSO frames. Note that TCP stack might split too big TSO packets
+	if available congestion window is too small.
+	Default: 2
+
 tcp_tso_win_divisor - INTEGER
 	This allows control over what percentage of the congestion window
 	can be consumed by a single TSO frame.
diff --git a/include/net/sock.h b/include/net/sock.h
index e4bbcbf..6ba2e7b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -232,6 +232,7 @@ struct cg_proto;
   *	@sk_napi_id: id of the last napi context to receive data for sk
   *	@sk_ll_usec: usecs to busypoll when there is no data
   *	@sk_allocation: allocation mode
+  *	@sk_pacing_rate: Pacing rate (if supported by transport/packet scheduler)
   *	@sk_sndbuf: size of send buffer in bytes
   *	@sk_flags: %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
   *		   %SO_OOBINLINE settings, %SO_TIMESTAMPING settings
@@ -361,6 +362,7 @@ struct sock {
 	kmemcheck_bitfield_end(flags);
 	int			sk_wmem_queued;
 	gfp_t			sk_allocation;
+	u32			sk_pacing_rate; /* bytes per second */
 	netdev_features_t	sk_route_caps;
 	netdev_features_t	sk_route_nocaps;
 	int			sk_gso_type;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 09cb5c1..73fcd7c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -281,6 +281,7 @@ extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
 extern unsigned int sysctl_tcp_notsent_lowat;
+extern int sysctl_tcp_min_tso_segs;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 8ed7c32..540279f 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -29,6 +29,7 @@
 static int zero;
 static int one = 1;
 static int four = 4;
+static int gso_max_segs = GSO_MAX_SEGS;
 static int tcp_retr1_max = 255;
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
@@ -761,6 +762,15 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &four,
 	},
 	{
+		.procname	= "tcp_min_tso_segs",
+		.data		= &sysctl_tcp_min_tso_segs,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &gso_max_segs,
+	},
+	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ab64eea..e1714ee 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -283,6 +283,8 @@
 
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
+int sysctl_tcp_min_tso_segs __read_mostly = 2;
+
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
@@ -785,12 +787,28 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 	xmit_size_goal = mss_now;
 
 	if (large_allowed && sk_can_gso(sk)) {
-		xmit_size_goal = ((sk->sk_gso_max_size - 1) -
-				  inet_csk(sk)->icsk_af_ops->net_header_len -
-				  inet_csk(sk)->icsk_ext_hdr_len -
-				  tp->tcp_header_len);
+		u32 gso_size, hlen;
+
+		/* Maybe we should/could use sk->sk_prot->max_header here ? */
+		hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
+		       inet_csk(sk)->icsk_ext_hdr_len +
+		       tp->tcp_header_len;
+
+		/* Goal is to send at least one packet per ms,
+		 * not one big TSO packet every 100 ms.
+		 * This preserves ACK clocking and is consistent
+		 * with tcp_tso_should_defer() heuristic.
+		 */
+		gso_size = sk->sk_pacing_rate / (2 * MSEC_PER_SEC);
+		gso_size = max_t(u32, gso_size,
+				 sysctl_tcp_min_tso_segs * mss_now);
+
+		xmit_size_goal = min_t(u32, gso_size,
+				       sk->sk_gso_max_size - 1 - hlen);
 
-		/* TSQ : try to have two TSO segments in flight */
+		/* TSQ : try to have at least two segments in flight
+		 * (one in NIC TX ring, another in Qdisc)
+		 */
 		xmit_size_goal = min_t(u32, xmit_size_goal,
 				       sysctl_tcp_limit_output_bytes >> 1);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ec492ea..0885502 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -629,6 +629,7 @@ static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	long m = mrtt; /* RTT */
+	u64 rate;
 
 	/*	The following amusing code comes from Jacobson's
 	 *	article in SIGCOMM '88.  Note that rtt and mdev
@@ -686,6 +687,22 @@ static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 		tp->rtt_seq = tp->snd_nxt;
 	}
+
+	/* Pacing: -> set sk_pacing_rate to 200 % of current rate */
+	rate = (u64)tp->mss_cache * 8 * 2 * USEC_PER_SEC;
+	rate *= max(tp->snd_cwnd, tp->packets_out);
+
+	do_div(rate, jiffies_to_usecs(tp->srtt));
+	/* Correction for small srtt : minimum srtt being 8 (1 ms),
+	 * be conservative and assume rtt = 125 us instead of 1 ms
+	 * We probably need usec resolution in the future.
+	 */
+	if (tp->srtt <= 8 + 2)
+		rate <<= 3;
+	sk->sk_pacing_rate = min_t(u64, rate, ~0U);
+	pr_debug("cwnd %u packets_out %u srtt %u -> rate = %llu bits\n",
+		 tp->snd_cwnd, tp->packets_out,
+		 jiffies_to_usecs(tp->srtt) >> 3, rate << 3);
 }
 
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
