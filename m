From: Andreas Petlund <apetlund@simula.no>
Subject: [PATCH 3/3] net: TCP thin dupack
Date: Tue, 27 Oct 2009 17:31:57 +0100
Message-ID: <4AE7207D.8090402@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:47719 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505AbZJ0QcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 12:32:05 -0400
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1N2oxt-0006El-Ha
	for netdev@vger.kernel.org; Tue, 27 Oct 2009 17:32:09 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables fast retransmissions after one dupACK for TCP if the stream is identified as thin. This will reduce latencies for thin streams that are not able to trigger fast retransmissions due to high packet interarrival time. This mechanism is only active if enabled by iocontrol or syscontrol and the stream is identified as thin.


Signed-off-by: Andreas Petlund <apetlund@simula.no>
---
 include/linux/tcp.h        |    4 +++-
 include/net/tcp.h          |    1 +
 net/ipv4/sysctl_net_ipv4.c |    8 ++++++++
 net/ipv4/tcp.c             |    5 +++++
 net/ipv4/tcp_input.c       |    8 ++++++++
 5 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index e64368d..f4a05ff 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -97,6 +97,7 @@ enum {
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
 #define TCP_THIN_RM_EXPB        15      /* Remove exp. backoff for thin streams*/
+#define TCP_THIN_DUPACK         16      /* Fast retrans. after 1 dupack */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -301,7 +302,8 @@ struct tcp_sock {
 	u8	frto_counter;	/* Number of new acks after RTO */
 	u8	nonagle;	/* Disable Nagle algorithm?             */
 	u8      thin_rm_expb:1, /* Remove exp. backoff for thin streams */
-		thin_undef : 7;
+		thin_dupack : 1,/* Fast retransmit on first dupack      */
+		thin_undef : 6;
 
 /* RTT measurement */
 	u32	srtt;		/* smoothed round trip time << 3	*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 412c1bd..41f3a5e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -238,6 +238,7 @@ extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
 extern int sysctl_tcp_force_thin_rm_expb;
+extern int sysctl_tcp_force_thin_dupack;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 7458f37..8653867 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -721,6 +721,14 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler   = proc_dointvec
 	},
 	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "tcp_force_thin_dupack",
+		.data           = &sysctl_tcp_force_thin_dupack,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec
+	},
+	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b4b0931..de190db 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2139,6 +2139,11 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			tp->thin_rm_expb = 1;
 		break;
 
+	case TCP_THIN_DUPACK:
+		if (val)
+			tp->thin_dupack = 1;
+		break;
+
 	case TCP_CORK:
 		/* When set indicates to always queue non-full frames.
 		 * Later the user clears this option and we transmit
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d86784b..b71eb89 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -89,6 +89,8 @@ int sysctl_tcp_frto __read_mostly = 2;
 int sysctl_tcp_frto_response __read_mostly;
 int sysctl_tcp_nometrics_save __read_mostly;
 
+int sysctl_tcp_force_thin_dupack __read_mostly;
+
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_abc __read_mostly;
 
@@ -2447,6 +2449,12 @@ static int tcp_time_to_recover(struct sock *sk)
 		return 1;
 	}
 
+	/* If a thin stream is detected, retransmit after first
+	 * received dupack */
+	if ((tp->thin_dupack || sysctl_tcp_force_thin_dupack) &&
+	    tcp_dupack_heurestics(tp) > 1 && tcp_stream_is_thin(tp))
+		return 1;
+
 	return 0;
 }
 
-- 
1.6.0.4



