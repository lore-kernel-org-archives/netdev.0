From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: add more tcp socket diagnostics
Date: Wed, 01 Oct 2014 04:17:18 -0700
Message-ID: <1412162238.16704.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:47931 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbaJALRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 07:17:13 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so95906pab.12
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 04:17:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Display 4 additional tcp socket info fields :

backoff : exponential backoff
lastsnd : time in milli second since last send
lastrcv : time in milli second since last receive
lastack : time in milli second since last acknowledgement

$ ss -ti dst :22
State       Recv-Q Send-Q                  Local Address:Port
Peer Address:Port   
ESTAB       0      0                        172.16.5.1:58470
172.17.131.143:ssh     
	 cubic wscale:7,7 rto:228 rtt:30/20 ato:40 mss:1256 cwnd:6 ssthresh:4
send 2.0Mbps lastsnd:3480 lastrcv:3464 lastack:3464 rcv_rtt:81.5
rcv_space:87812

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/ss.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index c847954..2420b51 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1554,6 +1554,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 			       info->tcpi_rcv_wscale);
 		if (info->tcpi_rto && info->tcpi_rto != 3000000)
 			printf(" rto:%g", (double)info->tcpi_rto/1000);
+		if (info->tcpi_backoff)
+			printf(" backoff:%u", info->tcpi_backoff);
 		if (info->tcpi_rtt)
 			printf(" rtt:%g/%g", (double)info->tcpi_rtt/1000,
 			       (double)info->tcpi_rttvar/1000);
@@ -1583,6 +1585,15 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 					 / rtt));
 		}
 
+		if (info->tcpi_last_data_sent)
+			printf(" lastsnd:%u", info->tcpi_last_data_sent);
+
+		if (info->tcpi_last_data_recv)
+			printf(" lastrcv:%u", info->tcpi_last_data_recv);
+
+		if (info->tcpi_last_ack_recv)
+			printf(" lastack:%u", info->tcpi_last_ack_recv);
+
 		if (info->tcpi_pacing_rate &&
 		    info->tcpi_pacing_rate != ~0ULL) {
 			printf(" pacing_rate %sbps",
