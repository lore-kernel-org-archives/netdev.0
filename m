From: Andreas Petlund <apetlund@simula.no>
Subject: [net-next PATCH v4 3/3] net: TCP thin dupack
Date: Tue, 16 Feb 2010 15:40:46 +0100
Message-ID: <4B7AAE6E.7080600@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:57154 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950Ab0BPOkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:40:49 -0500
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1NhObX-0001fK-Mv
	for netdev@vger.kernel.org; Tue, 16 Feb 2010 15:40:47 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Major changes:
      -Renamed variables, ioctl and sysctl.
      -Added sysctl documentation.
      -Removed redundant allocation

Signed-off-by: Andreas Petlund <apetlund@simula.no>
---
 Documentation/networking/ip-sysctl.txt |   12 ++++++++++++
 include/linux/tcp.h                    |    4 +++-
 include/net/tcp.h                      |    1 +
 net/ipv4/sysctl_net_ipv4.c             |    7 +++++++
 net/ipv4/tcp.c                         |    7 +++++++
 net/ipv4/tcp_input.c                   |   11 +++++++++++
 6 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f147310..2571a62 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -499,6 +499,18 @@ tcp_thin_linear_timeouts - BOOLEAN
 	Documentation/networking/tcp-thin.txt
 	Default: 0
 
+tcp_thin_dupack - BOOLEAN
+	Enable dynamic triggering of retransmissions after one dupACK
+	for thin streams. If set, a check is performed upon reception
+	of a dupACK to determine if the stream is thin (less than 4
+	packets in flight). As long as the stream is found to be thin,
+	data is retransmitted on the first received dupACK. This
+	improves retransmission latency for non-aggressive thin
+	streams, often found to be time-dependent.
+	For more information on thin streams, see
+	Documentation/networking/tcp-thin.txt
+	Default: 0
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 42885af..76b5606 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -104,6 +104,7 @@ enum {
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
 #define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
+#define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
@@ -343,7 +344,8 @@ struct tcp_sock {
 	u8	frto_counter;	/* Number of new acks after RTO */
 	u8	nonagle;	/* Disable Nagle algorithm?             */
 	u8      thin_lto    : 1,/* Use linear timeouts for thin streams */
-		thin_undef  : 7;
+ 		thin_dupack : 1,/* Fast retransmit on first dupack      */
+ 		thin_undef  : 6;
 
 /* RTT measurement */
 	u32	srtt;		/* smoothed round trip time << 3	*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index be49356..9180767 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -245,6 +245,7 @@ extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
 extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_thin_linear_timeouts;
+extern int sysctl_tcp_thin_dupack;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e6a2460..c1bc074 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -582,6 +582,13 @@ static struct ctl_table ipv4_table[] = {
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec
 	},
+        {
+		.procname       = "tcp_thin_dupack",
+		.data           = &sysctl_tcp_thin_dupack,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec
+	},
 	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a159c0d..07e06dc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2236,6 +2236,13 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			tp->thin_lto = val;
 		break;
 
+	case TCP_THIN_DUPACK:
+		if (val < 0 || val > 1)
+			err = -EINVAL;
+		else
+			tp->thin_dupack = val;
+		break;
+
 	case TCP_CORK:
 		/* When set indicates to always queue non-full frames.
 		 * Later the user clears this option and we transmit
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3fddc69..0f424aa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -89,6 +89,8 @@ int sysctl_tcp_frto __read_mostly = 2;
 int sysctl_tcp_frto_response __read_mostly;
 int sysctl_tcp_nometrics_save __read_mostly;
 
+int sysctl_tcp_thin_dupack __read_mostly;
+
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_abc __read_mostly;
 
@@ -2447,6 +2449,15 @@ static int tcp_time_to_recover(struct sock *sk)
 		return 1;
 	}
 
+	/* If a thin stream is detected, retransmit after first
+	 * received dupack. Employ only if SACK is supported in order
+	 * to avoid possible corner-case series of spurious retransmissions
+	 * Use only if there are no unsent data. */
+	if ((tp->thin_dupack || sysctl_tcp_thin_dupack) &&
+	    tcp_stream_is_thin(tp) && tcp_dupack_heuristics(tp) > 1 &&
+	    tcp_is_sack(tp) && sk->sk_send_head == NULL)
+		return 1;
+
 	return 0;
 }
 
-- 
1.6.3.3

