From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: display pacing_rate/max_pacing_rate
Date: Thu, 05 Jun 2014 06:47:37 -0700
Message-ID: <1401976057.3645.277.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:51690 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbaFENrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 09:47:39 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so1105740pdi.41
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 06:47:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since linux-3.15, kernel exports tcpi_pacing_rate and
tcpi_max_pacing_rate in tcp_info

Add TCP pacing_rate information on ss -i output :

lpaa23:~# ./ss -ti dst 10.246.7.151
State      Recv-Q Send-Q   Local Address:Port       Peer Address:Port   
ESTAB      0      325800    10.246.7.151:57614
10.246.7.152:46811   
	 cubic wscale:7,7 rto:201 rtt:0.081/0.006 mss:1448 cwnd:90 ssthresh:63
send 12871.1Mbps pacing_rate 15397.8Mbps unacked:90 retrans:0/305
rcv_space:29200


If SO_MAX_PACING_RATE is set on the socket, we add /max_pacing_rate as
in :

... pacing_rate 1570.5Mbps/2.0Gbps ...

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/ss.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index 187c852..c847954 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1583,6 +1583,16 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 					 / rtt));
 		}
 
+		if (info->tcpi_pacing_rate &&
+		    info->tcpi_pacing_rate != ~0ULL) {
+			printf(" pacing_rate %sbps",
+				sprint_bw(b1, info->tcpi_pacing_rate * 8.));
+
+			if (info->tcpi_max_pacing_rate &&
+			    info->tcpi_max_pacing_rate != ~0ULL)
+				printf("/%sbps",
+					sprint_bw(b1, info->tcpi_max_pacing_rate * 8.));
+		}
 		if (info->tcpi_unacked)
 			printf(" unacked:%u", info->tcpi_unacked);
 		if (info->tcpi_retrans || info->tcpi_total_retrans)
