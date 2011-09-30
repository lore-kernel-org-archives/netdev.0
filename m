From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: report ECN_SEEN in tcp_info
Date: Fri, 30 Sep 2011 06:44:57 +0200
Message-ID: <1317357897.3274.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54037 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875Ab1I3EpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 00:45:04 -0400
Received: by wyg34 with SMTP id 34so682939wyg.19
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2011 21:45:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows ss command (iproute2) to display "ecnseen" if at least one packet
with ECT(0) or ECT(1) or ECN was received by this socket.

"ecn" means ECN was negociated at session establishment (TCP level)

"ecnseen" means we received at least one packet with ECT fields set (IP
level)

ss -i
...
ESTAB      0      0   192.168.20.110:22  192.168.20.144:38016
ino:5950 sk:f178e400
	 mem:(r0,w0,f0,t0) ts sack ecn ecnseen bic wscale:7,8 rto:210
rtt:12.5/7.5 cwnd:10 send 9.3Mbps rcv_space:14480

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Stephen are you planning to provide an alternative git tree for
iproute2 ? Thanks !

 include/linux/tcp.h |    3 ++-
 net/ipv4/tcp.c      |    4 +++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 6b63b31..7f59ee9 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -111,7 +111,8 @@ enum {
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
 #define TCPI_OPT_WSCALE		4
-#define TCPI_OPT_ECN		8
+#define TCPI_OPT_ECN		8 /* ECN was negociated at TCP session init */
+#define TCPI_OPT_ECN_SEEN	16 /* we received at least one packet with ECT */
 
 enum tcp_ca_state {
 	TCP_CA_Open = 0,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 131c45f..4c0da24 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2455,8 +2455,10 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 		info->tcpi_rcv_wscale = tp->rx_opt.rcv_wscale;
 	}
 
-	if (tp->ecn_flags&TCP_ECN_OK)
+	if (tp->ecn_flags & TCP_ECN_OK)
 		info->tcpi_options |= TCPI_OPT_ECN;
+	if (tp->ecn_flags & TCP_ECN_SEEN)
+		info->tcpi_options |= TCPI_OPT_ECN_SEEN;
 
 	info->tcpi_rto = jiffies_to_usecs(icsk->icsk_rto);
 	info->tcpi_ato = jiffies_to_usecs(icsk->icsk_ack.ato);
