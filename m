From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ip: support of usec rtt in tcp_metrics
Date: Fri, 05 Sep 2014 16:54:04 -0700
Message-ID: <1409961244.26422.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:61164 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaIEXyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 19:54:06 -0400
Received: by mail-pa0-f44.google.com with SMTP id rd3so23326449pab.31
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 16:54:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Starting from linux-3.15, kernel supports new tcp metric attributes :
TCP_METRIC_RTT_US & TCP_METRIC_RTTVAR_US

Update ip command to detect their use.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 ip/tcp_metrics.c |   31 ++++++++++++++++++++++++-------
 1 file changed, 24 insertions(+), 7 deletions(-)

diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index e0f0344..bbbb4cc 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -216,6 +216,7 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	a = attrs[TCP_METRICS_ATTR_VALS];
 	if (a) {
 		struct rtattr *m[TCP_METRIC_MAX + 1 + 1];
+		unsigned long rtt = 0, rttvar = 0;
 
 		parse_rtattr_nested(m, TCP_METRIC_MAX + 1, a);
 
@@ -225,18 +226,30 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 			a = m[i + 1];
 			if (!a)
 				continue;
-			if (metric_name[i])
-				fprintf(fp, " %s ", metric_name[i]);
-			else
-				fprintf(fp, " metric_%d ", i);
-
+			if (i != TCP_METRIC_RTT &&
+			    i != TCP_METRIC_RTT_US &&
+			    i != TCP_METRIC_RTTVAR &&
+			    i != TCP_METRIC_RTTVAR_US) {
+				if (metric_name[i])
+					fprintf(fp, " %s ", metric_name[i]);
+				else
+					fprintf(fp, " metric_%d ", i);
+			}
 			val = rta_getattr_u32(a);
 			switch (i) {
 			case TCP_METRIC_RTT:
-				fprintf(fp, "%luus", (val * 1000UL) >> 3);
+				if (!rtt)
+					rtt = (val * 1000UL) >> 3;
 				break;
 			case TCP_METRIC_RTTVAR:
-				fprintf(fp, "%luus", (val * 1000UL) >> 2);
+				if (!rttvar)
+					rttvar = (val * 1000UL) >> 2;
+				break;
+			case TCP_METRIC_RTT_US:
+				rtt = val >> 3;
+				break;
+			case TCP_METRIC_RTTVAR_US:
+				rttvar = val >> 2;
 				break;
 			case TCP_METRIC_SSTHRESH:
 			case TCP_METRIC_CWND:
@@ -246,6 +259,10 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 				break;
 			}
 		}
+		if (rtt)
+			fprintf(fp, " rtt %luus", rtt);
+		if (rttvar)
+			fprintf(fp, " rttvar %luus", rttvar);
 	}
 
 	a = attrs[TCP_METRICS_ATTR_FOPEN_MSS];
