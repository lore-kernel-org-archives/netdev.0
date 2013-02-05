From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] tcp: remove Appropriate Byte Count support
Date: Tue, 5 Feb 2013 09:25:17 -0800
Message-ID: <20130205092517.58d11171@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:43267 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529Ab3BERZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 12:25:31 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so262540pad.7
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 09:25:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP Appropriate Byte Count was added by me, but later disabled.
There is no point in maintaining it since it is a potential source
of bugs and Linux already implements other better window protection
heuristics.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/Documentation/networking/ip-sysctl.txt	2013-02-05 09:22:44.379791669 -0800
+++ b/Documentation/networking/ip-sysctl.txt	2013-02-05 09:23:13.035421064 -0800
@@ -130,17 +130,6 @@ somaxconn - INTEGER
 	Defaults to 128.  See also tcp_max_syn_backlog for additional tuning
 	for TCP sockets.
 
-tcp_abc - INTEGER
-	Controls Appropriate Byte Count (ABC) defined in RFC3465.
-	ABC is a way of increasing congestion window (cwnd) more slowly
-	in response to partial acknowledgments.
-	Possible values are:
-		0 increase cwnd once per acknowledgment (no ABC)
-		1 increase cwnd once per acknowledgment of full sized segment
-		2 allow increase cwnd by two if acknowledgment is
-		  of two segments to compensate for delayed acknowledgments.
-	Default: 0 (off)
-
 tcp_abort_on_overflow - BOOLEAN
 	If listening service is too slow to accept new connections,
 	reset them. Default state is FALSE. It means that if overflow
--- a/include/net/tcp.h	2013-02-05 09:22:44.379791669 -0800
+++ b/include/net/tcp.h	2013-02-05 09:23:13.035421064 -0800
@@ -279,7 +279,6 @@ extern int sysctl_tcp_dma_copybreak;
 extern int sysctl_tcp_nometrics_save;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
-extern int sysctl_tcp_abc;
 extern int sysctl_tcp_mtu_probing;
 extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
--- a/kernel/sysctl_binary.c	2013-02-05 09:22:44.379791669 -0800
+++ b/kernel/sysctl_binary.c	2013-02-05 09:23:13.035421064 -0800
@@ -387,7 +387,6 @@ static const struct bin_table bin_net_ip
 	{ CTL_INT,	NET_TCP_MODERATE_RCVBUF,		"tcp_moderate_rcvbuf" },
 	{ CTL_INT,	NET_TCP_TSO_WIN_DIVISOR,		"tcp_tso_win_divisor" },
 	{ CTL_STR,	NET_TCP_CONG_CONTROL,			"tcp_congestion_control" },
-	{ CTL_INT,	NET_TCP_ABC,				"tcp_abc" },
 	{ CTL_INT,	NET_TCP_MTU_PROBING,			"tcp_mtu_probing" },
 	{ CTL_INT,	NET_TCP_BASE_MSS,			"tcp_base_mss" },
 	{ CTL_INT,	NET_IPV4_TCP_WORKAROUND_SIGNED_WINDOWS,	"tcp_workaround_signed_windows" },
--- a/net/ipv4/sysctl_net_ipv4.c	2013-02-05 09:22:49.035731453 -0800
+++ b/net/ipv4/sysctl_net_ipv4.c	2013-02-05 09:23:13.035421064 -0800
@@ -633,13 +633,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_tcp_congestion_control,
 	},
 	{
-		.procname	= "tcp_abc",
-		.data		= &sysctl_tcp_abc,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
 		.procname	= "tcp_mtu_probing",
 		.data		= &sysctl_tcp_mtu_probing,
 		.maxlen		= sizeof(int),
--- a/net/ipv4/tcp_cong.c	2013-02-05 09:22:44.379791669 -0800
+++ b/net/ipv4/tcp_cong.c	2013-02-05 09:23:13.035421064 -0800
@@ -311,26 +311,10 @@ void tcp_slow_start(struct tcp_sock *tp)
 	int cnt; /* increase in packets */
 	unsigned int delta = 0;
 
-	/* RFC3465: ABC Slow start
-	 * Increase only after a full MSS of bytes is acked
-	 *
-	 * TCP sender SHOULD increase cwnd by the number of
-	 * previously unacknowledged bytes ACKed by each incoming
-	 * acknowledgment, provided the increase is not more than L
-	 */
-	if (sysctl_tcp_abc && tp->bytes_acked < tp->mss_cache)
-		return;
-
 	if (sysctl_tcp_max_ssthresh > 0 && tp->snd_cwnd > sysctl_tcp_max_ssthresh)
 		cnt = sysctl_tcp_max_ssthresh >> 1;	/* limited slow start */
 	else
 		cnt = tp->snd_cwnd;			/* exponential increase */
-
-	/* RFC3465: ABC
-	 * We MAY increase by 2 if discovered delayed ack
-	 */
-	if (sysctl_tcp_abc > 1 && tp->bytes_acked >= 2*tp->mss_cache)
-		cnt <<= 1;
 	tp->bytes_acked = 0;
 
 	tp->snd_cwnd_cnt += cnt;
@@ -372,20 +356,9 @@ void tcp_reno_cong_avoid(struct sock *sk
 	/* In "safe" area, increase. */
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
 		tcp_slow_start(tp);
-
 	/* In dangerous area, increase slowly. */
-	else if (sysctl_tcp_abc) {
-		/* RFC3465: Appropriate Byte Count
-		 * increase once for each full cwnd acked
-		 */
-		if (tp->bytes_acked >= tp->snd_cwnd*tp->mss_cache) {
-			tp->bytes_acked -= tp->snd_cwnd*tp->mss_cache;
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-		}
-	} else {
+	else
 		tcp_cong_avoid_ai(tp, tp->snd_cwnd);
-	}
 }
 EXPORT_SYMBOL_GPL(tcp_reno_cong_avoid);
 
--- a/net/ipv4/tcp_input.c	2013-02-05 09:22:49.035731453 -0800
+++ b/net/ipv4/tcp_input.c	2013-02-05 09:23:13.039421013 -0800
@@ -98,7 +98,6 @@ int sysctl_tcp_frto_response __read_most
 int sysctl_tcp_thin_dupack __read_mostly;
 
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
-int sysctl_tcp_abc __read_mostly;
 int sysctl_tcp_early_retrans __read_mostly = 2;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
@@ -3608,15 +3607,6 @@ static int tcp_ack(struct sock *sk, cons
 	if (after(ack, prior_snd_una))
 		flag |= FLAG_SND_UNA_ADVANCED;
 
-	if (sysctl_tcp_abc) {
-		if (icsk->icsk_ca_state < TCP_CA_CWR)
-			tp->bytes_acked += ack - prior_snd_una;
-		else if (icsk->icsk_ca_state == TCP_CA_Loss)
-			/* we assume just one segment left network */
-			tp->bytes_acked += min(ack - prior_snd_una,
-					       tp->mss_cache);
-	}
-
 	prior_fackets = tp->fackets_out;
 	prior_in_flight = tcp_packets_in_flight(tp);
 
