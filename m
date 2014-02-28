From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: snmp stats for Fast Open, SYN rtx, and data pkts
Date: Fri, 28 Feb 2014 14:47:22 -0800
Message-ID: <1393627642-19302-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Nandits Dukkipati <nanditad@google.com>,
	Larry Brakmo <brakmo@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f202.google.com ([209.85.160.202]:36237 "EHLO
	mail-yk0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaB1XQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 18:16:34 -0500
Received: by mail-yk0-f202.google.com with SMTP id 9so336507ykp.1
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 15:16:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the following snmp stats:

TCPFastOpenActiveFail: Fast Open attempts (SYN/data) failed beacuse
the remote does not accept it or the attempts timed out.

TCPSynRetrans: number of SYN and SYN/ACK retransmits to break down
retransmissions into SYN, fast-retransmits, timeout retransmits, etc.

TCPOrigDataSent: number of outgoing packets with original data (excluding
retransmission but including data-in-SYN). This counter is different from
TcpOutSegs because TcpOutSegs also tracks pure ACKs. TCPOrigDataSent is
more useful to track the TCP retransmission rate.

Change TCPFastOpenActive to track only successful Fast Opens to be symmetric to
TCPFastOpenPassive.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Nandits Dukkipati <nanditad@google.com>
Signed-off-by: Larry Brakmo <brakmo@google.com>
---
 include/uapi/linux/snmp.h | 3 +++
 net/ipv4/proc.c           | 3 +++
 net/ipv4/tcp_input.c      | 3 +++
 net/ipv4/tcp_ipv4.c       | 4 +++-
 net/ipv4/tcp_output.c     | 8 ++++++--
 net/ipv4/tcp_timer.c      | 3 +++
 net/ipv6/tcp_ipv6.c       | 4 +++-
 7 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 8d64a7e..df40137 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -252,6 +252,7 @@ enum
 	LINUX_MIB_TCPCHALLENGEACK,		/* TCPChallengeACK */
 	LINUX_MIB_TCPSYNCHALLENGE,		/* TCPSYNChallenge */
 	LINUX_MIB_TCPFASTOPENACTIVE,		/* TCPFastOpenActive */
+	LINUX_MIB_TCPFASTOPENACTIVEFAIL,	/* TCPFastOpenActiveFail */
 	LINUX_MIB_TCPFASTOPENPASSIVE,		/* TCPFastOpenPassive*/
 	LINUX_MIB_TCPFASTOPENPASSIVEFAIL,	/* TCPFastOpenPassiveFail */
 	LINUX_MIB_TCPFASTOPENLISTENOVERFLOW,	/* TCPFastOpenListenOverflow */
@@ -262,6 +263,8 @@ enum
 	LINUX_MIB_TCPFROMZEROWINDOWADV,		/* TCPFromZeroWindowAdv */
 	LINUX_MIB_TCPTOZEROWINDOWADV,		/* TCPToZeroWindowAdv */
 	LINUX_MIB_TCPWANTZEROWINDOWADV,		/* TCPWantZeroWindowAdv */
+	LINUX_MIB_TCPSYNRETRANS,		/* TCPSynRetrans */
+	LINUX_MIB_TCPORIGDATASENT,		/* TCPOrigDataSent */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 99d2e9b..ad737fa 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -273,6 +273,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPChallengeACK", LINUX_MIB_TCPCHALLENGEACK),
 	SNMP_MIB_ITEM("TCPSYNChallenge", LINUX_MIB_TCPSYNCHALLENGE),
 	SNMP_MIB_ITEM("TCPFastOpenActive", LINUX_MIB_TCPFASTOPENACTIVE),
+	SNMP_MIB_ITEM("TCPFastOpenActiveFail", LINUX_MIB_TCPFASTOPENACTIVEFAIL),
 	SNMP_MIB_ITEM("TCPFastOpenPassive", LINUX_MIB_TCPFASTOPENPASSIVE),
 	SNMP_MIB_ITEM("TCPFastOpenPassiveFail", LINUX_MIB_TCPFASTOPENPASSIVEFAIL),
 	SNMP_MIB_ITEM("TCPFastOpenListenOverflow", LINUX_MIB_TCPFASTOPENLISTENOVERFLOW),
@@ -283,6 +284,8 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPFromZeroWindowAdv", LINUX_MIB_TCPFROMZEROWINDOWADV),
 	SNMP_MIB_ITEM("TCPToZeroWindowAdv", LINUX_MIB_TCPTOZEROWINDOWADV),
 	SNMP_MIB_ITEM("TCPWantZeroWindowAdv", LINUX_MIB_TCPWANTZEROWINDOWADV),
+	SNMP_MIB_ITEM("TCPSynRetrans", LINUX_MIB_TCPSYNRETRANS),
+	SNMP_MIB_ITEM("TCPOrigDataSent", LINUX_MIB_TCPORIGDATASENT),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 23a41d9..6e48093 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5393,9 +5393,12 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 				break;
 		}
 		tcp_rearm_rto(sk);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENACTIVEFAIL);
 		return true;
 	}
 	tp->syn_data_acked = tp->syn_data;
+	if (tp->syn_data_acked)
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENACTIVE);
 	return false;
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 17c0fb1..c4f1d9a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -854,8 +854,10 @@ static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
 {
 	int res = tcp_v4_send_synack(sk, NULL, req, 0);
 
-	if (!res)
+	if (!res) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
+	}
 	return res;
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bf38b1f..aaa68f5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -86,6 +86,9 @@ static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
 	    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE) {
 		tcp_rearm_rto(sk);
 	}
+
+	NET_ADD_STATS_BH(sock_net(sk), LINUX_MIB_TCPORIGDATASENT,
+			 tcp_skb_pcount(skb));
 }
 
 /* SND.NXT, if window was not shrunk.
@@ -2433,7 +2436,8 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	if (err == 0) {
 		/* Update global TCP statistics. */
 		TCP_INC_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS);
-
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
 		tp->total_retrans++;
 
 #if FASTRETRANS_DEBUG > 0
@@ -2958,7 +2962,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 
 	if (tcp_transmit_skb(sk, syn_data, 0, sk->sk_allocation) == 0) {
 		tp->syn_data = (fo->copied > 0);
-		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPFASTOPENACTIVE);
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPORIGDATASENT);
 		goto done;
 	}
 	syn_data = NULL;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 64f0354..286227a 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -165,6 +165,9 @@ static int tcp_write_timeout(struct sock *sk)
 			dst_negative_advice(sk);
 			if (tp->syn_fastopen || tp->syn_data)
 				tcp_fastopen_cache_set(sk, 0, NULL, true);
+			if (tp->syn_data)
+				NET_INC_STATS_BH(sock_net(sk),
+						 LINUX_MIB_TCPFASTOPENACTIVEFAIL);
 		}
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 		syn_set = true;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 889079b..3277680 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -501,8 +501,10 @@ static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req)
 	int res;
 
 	res = tcp_v6_send_synack(sk, NULL, &fl6, req, 0);
-	if (!res)
+	if (!res) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
+	}
 	return res;
 }
 
-- 
1.9.0.279.gdc9e3eb
