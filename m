From: Andreas Petlund <apetlund@simula.no>
Subject: [net-next PATCH v5 2/3] net: TCP thin linear timeouts
Date: Thu, 18 Feb 2010 13:47:01 +0100
Message-ID: <4B7D36C5.3020304@simula.no>
References: <4B7D35A5.10106@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de,
	ebiederm@xmission.com, David Miller <davem@davemloft.net>,
	Franco Fichtner <franco@lastsummer.de>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:41198 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab0BRMrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 07:47:09 -0500
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1Ni5md-0004Lr-GC
	for netdev@vger.kernel.org; Thu, 18 Feb 2010 13:47:07 +0100
In-Reply-To: <4B7D35A5.10106@simula.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch will make TCP use only linear timeouts if the
stream is thin. This will help to avoid the very high latencies
that thin stream suffer because of exponential backoff. This
mechanism is only active if enabled by iocontrol or syscontrol
and the stream is identified as thin. A maximum of 6 linear
timeouts is tried before exponential backoff is resumed. 

Signed-off-by: Andreas Petlund <apetlund@simula.no>
---
 Documentation/networking/ip-sysctl.txt |   12 ++++++++++++
 include/linux/tcp.h                    |    5 ++++-
 include/net/tcp.h                      |    4 ++++
 net/ipv4/sysctl_net_ipv4.c             |    7 +++++++
 net/ipv4/tcp.c                         |    7 +++++++
 net/ipv4/tcp_timer.c                   |   21 ++++++++++++++++++++-
 6 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 2dc7a1d..f147310 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -487,6 +487,18 @@ tcp_dma_copybreak - INTEGER
 	and CONFIG_NET_DMA is enabled.
 	Default: 4096
 
+tcp_thin_linear_timeouts - BOOLEAN
+	Enable dynamic triggering of linear timeouts for thin streams.
+	If set, a check is performed upon retransmission by timeout to
+	determine if the stream is thin (less than 4 packets in flight).
+	As long as the stream is found to be thin, up to 6 linear
+	timeouts may be performed before exponential backoff mode is
+	initiated. This improves retransmission latency for
+	non-aggressive thin streams, often found to be time-dependent.
+	For more information on thin streams, see
+	Documentation/networking/tcp-thin.txt
+	Default: 0
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7fee8a4..3ba8b07 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -103,6 +103,7 @@ enum {
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
 #define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
+#define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
@@ -340,7 +341,9 @@ struct tcp_sock {
 	u32	frto_highmark;	/* snd_nxt when RTO occurred */
 	u16	advmss;		/* Advertised MSS			*/
 	u8	frto_counter;	/* Number of new acks after RTO */
-	u8	nonagle;	/* Disable Nagle algorithm?             */
+	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
+		thin_lto    : 1,/* Use linear timeouts for thin streams */
+		unused      : 3;
 
 /* RTT measurement */
 	u32	srtt;		/* smoothed round trip time << 3	*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0bdc3f6..6278fc7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -196,6 +196,9 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCP_NAGLE_CORK		2	/* Socket is corked	    */
 #define TCP_NAGLE_PUSH		4	/* Cork is overridden for already queued data */
 
+/* TCP thin-stream limits */
+#define TCP_THIN_LINEAR_RETRIES 6       /* After 6 linear retries, do exp. backoff */
+
 extern struct inet_timewait_death_row tcp_death_row;
 
 /* sysctl variables for tcp */
@@ -241,6 +244,7 @@ extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
 extern int sysctl_tcp_cookie_size;
+extern int sysctl_tcp_thin_linear_timeouts;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 7e3712c..e6a2460 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -576,6 +576,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname       = "tcp_thin_linear_timeouts",
+		.data           = &sysctl_tcp_thin_linear_timeouts,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec
+	},
+	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e471d03..21bae9a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2229,6 +2229,13 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		}
 		break;
 
+	case TCP_THIN_LINEAR_TIMEOUTS:
+		if (val < 0 || val > 1)
+			err = -EINVAL;
+		else
+			tp->thin_lto = val;
+		break;
+
 	case TCP_CORK:
 		/* When set indicates to always queue non-full frames.
 		 * Later the user clears this option and we transmit
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index de7d1bf..a17629b 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -29,6 +29,7 @@ int sysctl_tcp_keepalive_intvl __read_mostly = TCP_KEEPALIVE_INTVL;
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
 int sysctl_tcp_orphan_retries __read_mostly;
+int sysctl_tcp_thin_linear_timeouts __read_mostly;
 
 static void tcp_write_timer(unsigned long);
 static void tcp_delack_timer(unsigned long);
@@ -415,7 +416,25 @@ void tcp_retransmit_timer(struct sock *sk)
 	icsk->icsk_retransmits++;
 
 out_reset_timer:
-	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
+	/* If stream is thin, use linear timeouts. Since 'icsk_backoff' is
+	 * used to reset timer, set to 0. Recalculate 'icsk_rto' as this
+	 * might be increased if the stream oscillates between thin and thick,
+	 * thus the old value might already be too high compared to the value
+	 * set by 'tcp_set_rto' in tcp_input.c which resets the rto without
+	 * backoff. Limit to TCP_THIN_LINEAR_RETRIES before initiating
+	 * exponential backoff behaviour to avoid continue hammering
+	 * linear-timeout retransmissions into a black hole
+	 */
+	if (sk->sk_state == TCP_ESTABLISHED &&
+	    (tp->thin_lto || sysctl_tcp_thin_linear_timeouts) &&
+	    tcp_stream_is_thin(tp) &&
+	    icsk->icsk_retransmits <= TCP_THIN_LINEAR_RETRIES) {
+		icsk->icsk_backoff = 0;
+		icsk->icsk_rto = min(__tcp_set_rto(tp), TCP_RTO_MAX);
+	} else {
+		/* Use normal (exponential) backoff */
+		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
+	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
 	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
 		__sk_dst_reset(sk);
-- 
1.6.3.3
