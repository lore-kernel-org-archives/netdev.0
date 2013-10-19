From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH iproute2] ss: make socket statistic parseable
Date: Sat, 19 Oct 2013 19:54:12 +0200
Message-ID: <1382205252-14988-1-git-send-email-hagen@jauu.net>
Cc: shemminger@vyatta.com, Hagen Paul Pfeifer <hagen@jauu.net>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56811 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752456Ab3JSRyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 13:54:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently "ss -emoi" output is nearly perfect: key value(s) tuples are
delimited by colon. Except three groups: socket options, congestion
control algorithm and send data. Especially the first two groups prevent
automated parsing: what if a future congestion control algorithm is
named "faster" - is this a TCP flag or a congestion control algorithm?
The current syntax allow no parsing.

This patch harmonize the syntax for the last three remaining groups.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index c0369f1..beca2eb 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1386,20 +1386,22 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 			info = RTA_DATA(tb[INET_DIAG_INFO]);
 
 		if (show_options) {
+			int is_not_first_element = 0;
+			printf(" options:");
 			if (info->tcpi_options & TCPI_OPT_TIMESTAMPS)
-				printf(" ts");
+				printf("%cts", is_not_first_element++ ? ',' : '\0');
 			if (info->tcpi_options & TCPI_OPT_SACK)
-				printf(" sack");
+				printf("%csack", is_not_first_element++ ? ',' : '\0');
 			if (info->tcpi_options & TCPI_OPT_ECN)
-				printf(" ecn");
+				printf("%cecn", is_not_first_element++ ? ',' : '\0');
 			if (info->tcpi_options & TCPI_OPT_ECN_SEEN)
-				printf(" ecnseen");
+				printf("%cecnseen", is_not_first_element++ ? ',' : '\0');
 			if (info->tcpi_options & TCPI_OPT_SYN_DATA)
-				printf(" fastopen");
+				printf("%cfastopen", is_not_first_element++ ? ',' : '\0');
 		}
 
 		if (tb[INET_DIAG_CONG])
-			printf(" %s", rta_getattr_str(tb[INET_DIAG_CONG]));
+			printf(" cc:%s", rta_getattr_str(tb[INET_DIAG_CONG]));
 
 		if (info->tcpi_options & TCPI_OPT_WSCALE)
 			printf(" wscale:%d,%d", info->tcpi_snd_wscale,
@@ -1429,7 +1431,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		}
 
 		if (rtt > 0 && info->tcpi_snd_mss && info->tcpi_snd_cwnd) {
-			printf(" send %sbps",
+			printf(" send:%sbps",
 			       sprint_bw(b1, (double) info->tcpi_snd_cwnd *
 					 (double) info->tcpi_snd_mss * 8000000.
 					 / rtt));
-- 
1.8.4.rc3
