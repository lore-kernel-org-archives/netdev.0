From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH iproute2 3/3] ss: output TCP BBR diag information
Date: Tue, 20 Sep 2016 22:43:44 -0400
Message-ID: <1474425824-22646-3-git-send-email-ncardwell@google.com>
References: <1474425824-22646-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:34794 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754843AbcIUCoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 22:44:01 -0400
Received: by mail-qk0-f175.google.com with SMTP id n185so33948629qke.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 19:44:01 -0700 (PDT)
In-Reply-To: <1474425824-22646-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump useful TCP BBR state information from a struct tcp_bbr_info that
was grabbed using the inet_diag API.

We tolerate info that is shorter or longer than expected, in case the
kernel is older or newer than the ss binary. We simply print the
minimum of what is expected from the kernel and what is provided from
the kernel. We use the same trick as that used for struct tcp_info:
when the info from the kernel is shorter than we hoped, we pad the end
with zeroes, and don't print fields if they are zero.

The BBR output looks like:
  bbr:(bw:1.2Mbps,mrtt:18.965,pacing_gain:2.88672,cwnd_gain:2.88672)

The motivation here is to be consistent with DCTCP, which looks like:
  dctcp(ce_state:23,alpha:23,ab_ecn:23,ab_tot:23)

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 misc/ss.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index 9c456d4..14fff46 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -784,6 +784,7 @@ struct tcpstat {
 	bool		    has_fastopen_opt;
 	bool		    has_wscale_opt;
 	struct dctcpstat    *dctcp;
+	struct tcp_bbr_info *bbr_info;
 };
 
 static void sock_state_print(struct sockstat *s, const char *sock_name)
@@ -1727,6 +1728,25 @@ static void tcp_stats_print(struct tcpstat *s)
 		printf(" dctcp:fallback_mode");
 	}
 
+	if (s->bbr_info) {
+		__u64 bw;
+
+		bw = s->bbr_info->bbr_bw_hi;
+		bw <<= 32;
+		bw |= s->bbr_info->bbr_bw_lo;
+
+		printf(" bbr:(bw:%sbps,mrtt:%g",
+		       sprint_bw(b1, bw * 8.0),
+		       (double)s->bbr_info->bbr_min_rtt / 1000.0);
+		if (s->bbr_info->bbr_pacing_gain)
+			printf(",pacing_gain:%g",
+			       (double)s->bbr_info->bbr_pacing_gain / 256.0);
+		if (s->bbr_info->bbr_cwnd_gain)
+			printf(",cwnd_gain:%g",
+			       (double)s->bbr_info->bbr_cwnd_gain / 256.0);
+		printf(")");
+	}
+
 	if (s->send_bps)
 		printf(" send %sbps", sprint_bw(b1, s->send_bps));
 	if (s->lastsnd)
@@ -2005,6 +2025,16 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 			s.dctcp		= dctcp;
 		}
 
+		if (tb[INET_DIAG_BBRINFO]) {
+			const void *bbr_info = RTA_DATA(tb[INET_DIAG_BBRINFO]);
+			int len = min(RTA_PAYLOAD(tb[INET_DIAG_BBRINFO]),
+				      sizeof(*s.bbr_info));
+
+			s.bbr_info = calloc(1, sizeof(*s.bbr_info));
+			if (s.bbr_info && bbr_info)
+				memcpy(s.bbr_info, bbr_info, len);
+		}
+
 		if (rtt > 0 && info->tcpi_snd_mss && info->tcpi_snd_cwnd) {
 			s.send_bps = (double) info->tcpi_snd_cwnd *
 				(double)info->tcpi_snd_mss * 8000000. / rtt;
@@ -2027,6 +2057,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 			s.min_rtt = (double) info->tcpi_min_rtt / 1000;
 		tcp_stats_print(&s);
 		free(s.dctcp);
+		free(s.bbr_info);
 	}
 }
 
-- 
2.8.0.rc3.226.g39d4020
