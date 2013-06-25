From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: add more TCP_INFO components
Date: Tue, 25 Jun 2013 13:29:17 -0700
Message-ID: <1372192157.3301.118.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:56307 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab3FYU3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 16:29:05 -0400
Received: by mail-ee0-f49.google.com with SMTP id b57so6922572eek.36
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 13:29:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Allow ss -i to display more TCP informations :

unacked:N   Number of un-acked packets
retrans:X/Y   X: number of outstanding retransmit packets
              Y: total number of retransmits for the session
lost:N       Number of lost packets (tcpi_lost)
sacked:N     Number of sacked packets (tcpi_sacked)
facked:N     Number of facked packets (tcpi_facked)
reordering:N Reordering level (if different of 3)

Example :

$ ss -emoi dst 10.7.7.83
tcp   ESTAB      0      1154056   10.7.7.84:54127    10.7.7.83:34342
timer:(on,200ms,0) ino:57003 sk:ffff88063c51d0c0 <->
	 skmem:(r0,rb89280,t0,tb2097152,f726504,w1436184,o0,bl0) ts sack cubic
wscale:7,6 rto:310 rtt:107.375/1 mss:1448 cwnd:568 ssthresh:108 send
61.3Mbps unacked:568 retrans:0/21 reordering:127 rcv_space:29200

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 misc/ss.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index e0d11ff..c0369f1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1435,6 +1435,19 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 					 / rtt));
 		}
 
+		if (info->tcpi_unacked)
+			printf(" unacked:%u", info->tcpi_unacked);
+		if (info->tcpi_retrans || info->tcpi_total_retrans)
+			printf(" retrans:%u/%u", info->tcpi_retrans,
+			       info->tcpi_total_retrans);
+		if (info->tcpi_lost)
+			printf(" lost:%u", info->tcpi_lost);
+		if (info->tcpi_sacked && r->idiag_state != SS_LISTEN)
+			printf(" sacked:%u", info->tcpi_sacked);
+		if (info->tcpi_fackets)
+			printf(" fackets:%u", info->tcpi_fackets);
+		if (info->tcpi_reordering != 3)
+			printf(" reordering:%d", info->tcpi_reordering);
 		if (info->tcpi_rcv_rtt)
 			printf(" rcv_rtt:%g", (double) info->tcpi_rcv_rtt/1000);
 		if (info->tcpi_rcv_space)
