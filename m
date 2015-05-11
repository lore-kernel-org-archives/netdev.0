From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: add support for bytes_acked & bytes_received
Date: Mon, 11 May 2015 10:03:49 -0700
Message-ID: <1431363829.566.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35873 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbbEKRDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:03:52 -0400
Received: by iecmd7 with SMTP id md7so35600939iec.3
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 10:03:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_info has 2 new fields : bytes_acked & bytes_received

$ ss -ti src :22
...
	 cubic wscale:7,6 rto:234 rtt:33.199/17.225 ato:17.225 mss:1418 cwnd:9
ssthresh:9 send 3.1Mbps lastsnd:3 lastrcv:4 lastack:193
bytes_acked:188396 bytes_received:13639 pacing_rate 6.2Mbps unacked:1
retrans:0/4 reordering:4 rcv_rtt:47.25 rcv_space:28960


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h |    5 +++++
 misc/ss.c           |    9 +++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f96e015..8b17cff 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -112,6 +112,9 @@ enum {
 #define TCP_FASTOPEN		23	/* Enable FastOpen on listeners */
 #define TCP_TIMESTAMP		24
 #define TCP_NOTSENT_LOWAT	25	/* limit number of unsent bytes in write queue */
+#define TCP_CC_INFO		26	/* Get Congestion Control (optional) info */
+#define TCP_SAVE_SYN		27	/* Record SYN headers for new connections */
+#define TCP_SAVED_SYN		28	/* Get SYN headers recorded for connection */
 
 struct tcp_repair_opt {
 	__u32	opt_code;
@@ -189,6 +192,8 @@ struct tcp_info {
 
 	__u64	tcpi_pacing_rate;
 	__u64	tcpi_max_pacing_rate;
+	__u64	tcpi_bytes_acked; /* RFC4898 tcpEStatsAppHCThruOctetsAcked */
+	__u64	tcpi_bytes_received; /* RFC4898 tcpEStatsAppHCThruOctetsReceived */
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/misc/ss.c b/misc/ss.c
index 870cad1..8ee654a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -767,6 +767,8 @@ struct tcpstat
 	unsigned int	    lastack;
 	double		    pacing_rate;
 	double		    pacing_rate_max;
+	unsigned long long  bytes_acked;
+	unsigned long long  bytes_received;
 	unsigned int	    unacked;
 	unsigned int	    retrans;
 	unsigned int	    retrans_total;
@@ -1689,6 +1691,11 @@ static void tcp_stats_print(struct tcpstat *s)
 	if (s->ssthresh)
 		printf(" ssthresh:%d", s->ssthresh);
 
+	if (s->bytes_acked)
+		printf(" bytes_acked:%llu", s->bytes_acked);
+	if (s->bytes_received)
+		printf(" bytes_received:%llu", s->bytes_received);
+
 	if (s->dctcp && s->dctcp->enabled) {
 		struct dctcpstat *dctcp = s->dctcp;
 
@@ -1981,6 +1988,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 					info->tcpi_max_pacing_rate != ~0ULL)
 				s.pacing_rate_max = info->tcpi_max_pacing_rate * 8.;
 		}
+		s.bytes_acked = info->tcpi_bytes_acked;
+		s.bytes_received = info->tcpi_bytes_received;
 		tcp_stats_print(&s);
 		if (s.dctcp)
 			free(s.dctcp);
