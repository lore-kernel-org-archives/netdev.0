From: Craig Gallek <kraig@google.com>
Subject: [PATCH iproute2] ss: add support for segs_in and segs_out
Date: Tue, 26 May 2015 14:54:41 -0400
Message-ID: <1432666481-1582-1-git-send-email-kraig@google.com>
Cc: edumazet@google.com, mleitner@redhat.com, netdev@vger.kernel.org,
	Craig Gallek <kraig@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:34686 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbbEZSyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 14:54:51 -0400
Received: by yhom41 with SMTP id m41so33394415yho.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 11:54:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two new tcp_info fields: tcpi_segs_in and tcpi_segs_out.
(2efd055c53c06b7e89c167c98069bab9afce7e59)

~: ss -ti src :22
	 cubic wscale:7,6 rto:201 rtt:0.244/0.012 ato:40 mss:1418 cwnd:21 bytes_acked:80605 bytes_received:20491 segs_out:414 segs_in:600 send 976.3Mbps lastsnd:23 lastrcv:23 lastack:22 pacing_rate 1952.7Mbps rcv_rtt:98 rcv_space:28960

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/linux/tcp.h | 4 +++-
 misc/ss.c           | 8 ++++++++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 8b17cff..1e9b4a6 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -192,8 +192,10 @@ struct tcp_info {
 
 	__u64	tcpi_pacing_rate;
 	__u64	tcpi_max_pacing_rate;
-	__u64	tcpi_bytes_acked; /* RFC4898 tcpEStatsAppHCThruOctetsAcked */
+	__u64	tcpi_bytes_acked;    /* RFC4898 tcpEStatsAppHCThruOctetsAcked */
 	__u64	tcpi_bytes_received; /* RFC4898 tcpEStatsAppHCThruOctetsReceived */
+	__u32	tcpi_segs_out;	     /* RFC4898 tcpEStatsPerfSegsOut */
+	__u32	tcpi_segs_in;	     /* RFC4898 tcpEStatsPerfSegsIn */
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/misc/ss.c b/misc/ss.c
index dba0901..3e01f88 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -769,6 +769,8 @@ struct tcpstat
 	double		    pacing_rate_max;
 	unsigned long long  bytes_acked;
 	unsigned long long  bytes_received;
+	unsigned int	    segs_out;
+	unsigned int	    segs_in;
 	unsigned int	    unacked;
 	unsigned int	    retrans;
 	unsigned int	    retrans_total;
@@ -1695,6 +1697,10 @@ static void tcp_stats_print(struct tcpstat *s)
 		printf(" bytes_acked:%llu", s->bytes_acked);
 	if (s->bytes_received)
 		printf(" bytes_received:%llu", s->bytes_received);
+	if (s->segs_out)
+		printf(" segs_out:%u", s->segs_out);
+	if (s->segs_in)
+		printf(" segs_in:%u", s->segs_in);
 
 	if (s->dctcp && s->dctcp->enabled) {
 		struct dctcpstat *dctcp = s->dctcp;
@@ -1990,6 +1996,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		}
 		s.bytes_acked = info->tcpi_bytes_acked;
 		s.bytes_received = info->tcpi_bytes_received;
+		s.segs_out = info->tcpi_segs_out;
+		s.segs_in = info->tcpi_segs_in;
 		tcp_stats_print(&s);
 		if (s.dctcp)
 			free(s.dctcp);
-- 
2.2.0.rc0.207.ga3a616c
