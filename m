From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: fix ssthresh u16 leftover
Date: Mon, 14 Sep 2009 17:09:08 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0909141705500.7424@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-17586308-1252937349=:7424"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39491 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754660AbZINOJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 10:09:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-17586308-1252937349=:7424
Content-Type: TEXT/PLAIN; format=flowed; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

It was once upon time so that snd_sthresh was a 16-bit quantity.
...That has not been true for long period of time. I run across
some ancient compares which still seem to trust such legacy.
Put all that magic into a single place, I hopefully found all
of them.

Compile tested, though linking of allyesconfig is ridiculous
nowadays it seems.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

---
  include/net/tcp.h        |    7 +++++++
  net/ipv4/tcp.c           |    2 +-
  net/ipv4/tcp_input.c     |    2 +-
  net/ipv4/tcp_ipv4.c      |    4 ++--
  net/ipv4/tcp_minisocks.c |    2 +-
  net/ipv6/tcp_ipv6.c      |    5 +++--
  6 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b71a446..56b7602 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -793,6 +793,13 @@ static inline unsigned int tcp_packets_in_flight(const struct tcp_sock *tp)
  	return tp->packets_out - tcp_left_out(tp) + tp->retrans_out;
  }

+#define TCP_INFINITE_SSTHRESH	0x7fffffff
+
+static inline bool tcp_in_initial_slowstart(const struct tcp_sock *tp)
+{
+	return tp->snd_ssthresh >= TCP_INFINITE_SSTHRESH;
+}
+
  /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
   * The exception is rate halving phase, when cwnd is decreasing towards
   * ssthresh.
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index edeea06..19a0612 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2012,7 +2012,7 @@ int tcp_disconnect(struct sock *sk, int flags)
  	tp->snd_cwnd = 2;
  	icsk->icsk_probes_out = 0;
  	tp->packets_out = 0;
-	tp->snd_ssthresh = 0x7fffffff;
+	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
  	tp->snd_cwnd_cnt = 0;
  	tp->bytes_acked = 0;
  	tcp_set_ca_state(sk, TCP_CA_Open);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index af6d6fa..d86784b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -761,7 +761,7 @@ void tcp_update_metrics(struct sock *sk)
  			set_dst_metric_rtt(dst, RTAX_RTTVAR, var);
  		}

-		if (tp->snd_ssthresh >= 0xFFFF) {
+		if (tcp_in_initial_slowstart(tp)) {
  			/* Slow start still did not finish. */
  			if (dst_metric(dst, RTAX_SSTHRESH) &&
  			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0543561..7cda24b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1808,7 +1808,7 @@ static int tcp_v4_init_sock(struct sock *sk)
  	/* See draft-stevens-tcpca-spec-01 for discussion of the
  	 * initialization of these values.
  	 */
-	tp->snd_ssthresh = 0x7fffffff;	/* Infinity */
+	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
  	tp->snd_cwnd_clamp = ~0;
  	tp->mss_cache = 536;

@@ -2284,7 +2284,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
  		jiffies_to_clock_t(icsk->icsk_ack.ato),
  		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
  		tp->snd_cwnd,
-		tp->snd_ssthresh >= 0xFFFF ? -1 : tp->snd_ssthresh,
+		tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh,
  		len);
  }

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index e48c37d..045bcfd 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -410,7 +410,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
  		newtp->retrans_out = 0;
  		newtp->sacked_out = 0;
  		newtp->fackets_out = 0;
-		newtp->snd_ssthresh = 0x7fffffff;
+		newtp->snd_ssthresh = TCP_INFINITE_SSTHRESH;

  		/* So many TCP implementations out there (incorrectly) count the
  		 * initial SYN frame in their delayed-ACK and congestion control
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3aae0f2..6e3f0dc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1846,7 +1846,7 @@ static int tcp_v6_init_sock(struct sock *sk)
  	/* See draft-stevens-tcpca-spec-01 for discussion of the
  	 * initialization of these values.
  	 */
-	tp->snd_ssthresh = 0x7fffffff;
+	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
  	tp->snd_cwnd_clamp = ~0;
  	tp->mss_cache = 536;

@@ -1969,7 +1969,8 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
  		   jiffies_to_clock_t(icsk->icsk_rto),
  		   jiffies_to_clock_t(icsk->icsk_ack.ato),
  		   (icsk->icsk_ack.quick << 1 ) | icsk->icsk_ack.pingpong,
-		   tp->snd_cwnd, tp->snd_ssthresh>=0xFFFF?-1:tp->snd_ssthresh
+		   tp->snd_cwnd,
+		   tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh
  		   );
  }

-- 
tg: (13af7a6..) fix/ssthresh (depends on: origin/master)
--8323329-17586308-1252937349=:7424--
