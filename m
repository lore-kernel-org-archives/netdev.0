From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH iproute2 1/2] ss: print new tcp_info fields: delivery_rate and app_limited
Date: Thu,  1 Dec 2016 13:21:39 -0500
Message-ID: <1480616500-16919-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:34454 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753150AbcLASVx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 13:21:53 -0500
Received: by mail-qt0-f180.google.com with SMTP id n6so229211960qtd.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 10:21:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump the new delivery_rate and delivery_rate_app_limited fields that
were added to tcp_info in Linux v4.9.

Example output:
  pacing_rate 65.7Mbps delivery_rate 62.9Mbps

And for the application-limited case this looks like:
  pacing_rate 1031.1Mbps delivery_rate 87.4Mbps app_limited

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 misc/ss.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index dd77b81..18cfa93 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -766,6 +766,7 @@ struct tcpstat {
 	unsigned int	    lastack;
 	double		    pacing_rate;
 	double		    pacing_rate_max;
+	double		    delivery_rate;
 	unsigned long long  bytes_acked;
 	unsigned long long  bytes_received;
 	unsigned int	    segs_out;
@@ -789,6 +790,7 @@ struct tcpstat {
 	bool		    has_ecnseen_opt;
 	bool		    has_fastopen_opt;
 	bool		    has_wscale_opt;
+	bool		    app_limited;
 	struct dctcpstat    *dctcp;
 	struct tcp_bbr_info *bbr_info;
 };
@@ -1868,6 +1870,11 @@ static void tcp_stats_print(struct tcpstat *s)
 							s->pacing_rate_max));
 	}
 
+	if (s->delivery_rate)
+		printf(" delivery_rate %sbps", sprint_bw(b1, s->delivery_rate));
+	if (s->app_limited)
+		printf(" app_limited");
+
 	if (s->unacked)
 		printf(" unacked:%u", s->unacked);
 	if (s->retrans || s->retrans_total)
@@ -2162,6 +2169,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.not_sent = info->tcpi_notsent_bytes;
 		if (info->tcpi_min_rtt && info->tcpi_min_rtt != ~0U)
 			s.min_rtt = (double) info->tcpi_min_rtt / 1000;
+		s.delivery_rate = info->tcpi_delivery_rate * 8.;
+		s.app_limited = info->tcpi_delivery_rate_app_limited;
 		tcp_stats_print(&s);
 		free(s.dctcp);
 		free(s.bbr_info);
-- 
2.8.0.rc3.226.g39d4020
