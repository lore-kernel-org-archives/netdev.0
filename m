From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH iproute2 2/2] ss: print new tcp_info fields: busy, rwnd-limited, sndbuf-limited times
Date: Thu,  1 Dec 2016 13:21:40 -0500
Message-ID: <1480616500-16919-2-git-send-email-ncardwell@google.com>
References: <1480616500-16919-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36735 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754960AbcLASV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 13:21:57 -0500
Received: by mail-qk0-f180.google.com with SMTP id n21so253893744qka.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 10:21:57 -0800 (PST)
In-Reply-To: <1480616500-16919-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>

Dump some new fields added to tcp_info in v4.10: tcpi_busy_time,
tcpi_rwnd_limited, tcpi_sndbuf_limited.

Example output for a flow busy for 110ms but never measurably limited by
receive window or send buffer:
   busy:110ms

Example output for a flow usually limited by receive window:
   busy:111ms rwnd_limited:101ms(91.0%)

Example output for a flow sometimes limited by send buffer:
   busy:50ms sndbuf_limited:10ms(20.0%)

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 misc/ss.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index 18cfa93..392dbf7 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -784,6 +784,9 @@ struct tcpstat {
 	double		    rcv_rtt;
 	double		    min_rtt;
 	int		    rcv_space;
+	unsigned long long  busy_time;
+	unsigned long long  rwnd_limited;
+	unsigned long long  sndbuf_limited;
 	bool		    has_ts_opt;
 	bool		    has_sack_opt;
 	bool		    has_ecn_opt;
@@ -1875,6 +1878,18 @@ static void tcp_stats_print(struct tcpstat *s)
 	if (s->app_limited)
 		printf(" app_limited");
 
+	if (s->busy_time) {
+		printf(" busy:%llums", s->busy_time / 1000);
+		if (s->rwnd_limited)
+			printf(" rwnd_limited:%llums(%.1f%%)",
+			       s->rwnd_limited / 1000,
+			       100.0 * s->rwnd_limited / s->busy_time);
+		if (s->sndbuf_limited)
+			printf(" sndbuf_limited:%llums(%.1f%%)",
+			       s->sndbuf_limited / 1000,
+			       100.0 * s->sndbuf_limited / s->busy_time);
+	}
+
 	if (s->unacked)
 		printf(" unacked:%u", s->unacked);
 	if (s->retrans || s->retrans_total)
@@ -2171,6 +2186,9 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 			s.min_rtt = (double) info->tcpi_min_rtt / 1000;
 		s.delivery_rate = info->tcpi_delivery_rate * 8.;
 		s.app_limited = info->tcpi_delivery_rate_app_limited;
+		s.busy_time = info->tcpi_busy_time;
+		s.rwnd_limited = info->tcpi_rwnd_limited;
+		s.sndbuf_limited = info->tcpi_sndbuf_limited;
 		tcp_stats_print(&s);
 		free(s.dctcp);
 		free(s.bbr_info);
-- 
2.8.0.rc3.226.g39d4020
