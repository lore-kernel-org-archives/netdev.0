From: Andreas Petlund <apetlund@simula.no>
Subject: [PATCH 2/3] net: TCP thin linear timeouts
Date: Tue, 27 Oct 2009 17:31:53 +0100
Message-ID: <4AE72079.4030504@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:54839 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505AbZJ0QcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 12:32:01 -0400
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1N2oxp-0006EP-OA
	for netdev@vger.kernel.org; Tue, 27 Oct 2009 17:32:05 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch will make TCP use only linear timeouts if the stream is thin. This will help to avoid the very high latencies that thin stream suffer because of exponential backoff. This mechanism is only active if enabled by iocontrol or syscontrol and the stream is identified as thin.


Signed-off-by: Andreas Petlund <apetlund@simula.no>
---
 include/linux/tcp.h        |    3 +++
 include/net/tcp.h          |    1 +
 net/ipv4/sysctl_net_ipv4.c |    8 ++++++++
 net/ipv4/tcp.c             |    5 +++++
 net/ipv4/tcp_timer.c       |   17 ++++++++++++++++-
 5 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 61723a7..e64368d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -96,6 +96,7 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
+#define TCP_THIN_RM_EXPB        15      /* Remove exp. backoff for thin streams*/
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -299,6 +300,8 @@ struct tcp_sock {
 	u16	advmss;		/* Advertised MSS			*/
 	u8	frto_counter;	/* Number of new acks after RTO */
 	u8	nonagle;	/* Disable Nagle algorithm?             */
+	u8      thin_rm_expb:1, /* Remove exp. backoff for thin streams */
+		thin_undef : 7;
 
 /* RTT measurement */
 	u32	srtt;		/* smoothed round trip time << 3	*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7c4482f..412c1bd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -237,6 +237,7 @@ extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
+extern int sysctl_tcp_force_thin_rm_expb;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2dcf04d..7458f37 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -713,6 +713,14 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "tcp_force_thin_rm_expb",
+		.data           = &sysctl_tcp_force_thin_rm_expb,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec
+	},
+	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 90b2e06..b4b0931 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2134,6 +2134,11 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		}
 		break;
 
+	case TCP_THIN_RM_EXPB:
+		if (val)
+			tp->thin_rm_expb = 1;
+		break;
+
 	case TCP_CORK:
 		/* When set indicates to always queue non-full frames.
 		 * Later the user clears this option and we transmit
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index cdb2ca7..24d6dc3 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -29,6 +29,7 @@ int sysctl_tcp_keepalive_intvl __read_mostly = TCP_KEEPALIVE_INTVL;
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
 int sysctl_tcp_orphan_retries __read_mostly;
+int sysctl_tcp_force_thin_rm_expb __read_mostly;
 
 static void tcp_write_timer(unsigned long);
 static void tcp_delack_timer(unsigned long);
@@ -386,7 +387,21 @@ void tcp_retransmit_timer(struct sock *sk)
 	icsk->icsk_retransmits++;
 
 out_reset_timer:
-	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
+	if ((tp->thin_rm_expb || sysctl_tcp_force_thin_rm_expb) &&
+	    tcp_stream_is_thin(tp) && sk->sk_state == TCP_ESTABLISHED) {
+		/* If stream is thin, remove exponential backoff.
+		 * Since 'icsk_backoff' is used to reset timer, set to 0
+		 * Recalculate 'icsk_rto' as this might be increased if
+		 * stream oscillates between thin and thick, thus the old
+		 * value might already be too high compared to the value
+		 * set by 'tcp_set_rto' in tcp_input.c which resets the
+		 * rto without backoff. */
+		icsk->icsk_backoff = 0;
+		icsk->icsk_rto = min(((tp->srtt >> 3) + tp->rttvar), TCP_RTO_MAX);
+	} else {
+		/* Use normal backoff */
+		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
+	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
 	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
 		__sk_dst_reset(sk);
-- 
1.6.0.4


