From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: add OFO snmp counters
Date: Mon, 16 Jul 2012 13:41:36 +0200
Message-ID: <1342438896.23494.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46973 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421Ab2GPLlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 07:41:40 -0400
Received: by eaak11 with SMTP id k11so1618436eaa.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 04:41:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add three SNMP TCP counters, to better track TCP behavior
at global stage (netstat -s), when packets are received
Out Of Order (OFO)

TCPOFOQueue : Number of packets queued in OFO queue

TCPOFODrop  : Number of packets meant to be queued in OFO
              but dropped because socket rcvbuf limit hit.

TCPOFOMerge : Number of packets in OFO that were merged with
              other packets.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/snmp.h |    5 ++++-
 net/ipv4/proc.c      |    3 +++
 net/ipv4/tcp_input.c |    7 +++++--
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 2e68f5b..6e4c511 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -233,7 +233,10 @@ enum
 	LINUX_MIB_TCPREQQFULLDOCOOKIES,		/* TCPReqQFullDoCookies */
 	LINUX_MIB_TCPREQQFULLDROP,		/* TCPReqQFullDrop */
 	LINUX_MIB_TCPRETRANSFAIL,		/* TCPRetransFail */
-	LINUX_MIB_TCPRCVCOALESCE,			/* TCPRcvCoalesce */
+	LINUX_MIB_TCPRCVCOALESCE,		/* TCPRcvCoalesce */
+	LINUX_MIB_TCPOFOQUEUE,			/* TCPOFOQueue */
+	LINUX_MIB_TCPOFODROP,			/* TCPOFODrop */
+	LINUX_MIB_TCPOFOMERGE,			/* TCPOFOMerge */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8af0d44..dae25e76 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -258,6 +258,9 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPReqQFullDrop", LINUX_MIB_TCPREQQFULLDROP),
 	SNMP_MIB_ITEM("TCPRetransFail", LINUX_MIB_TCPRETRANSFAIL),
 	SNMP_MIB_ITEM("TCPRcvCoalesce", LINUX_MIB_TCPRCVCOALESCE),
+	SNMP_MIB_ITEM("TCPOFOQueue", LINUX_MIB_TCPOFOQUEUE),
+	SNMP_MIB_ITEM("TCPOFODrop", LINUX_MIB_TCPOFODROP),
+	SNMP_MIB_ITEM("TCPOFOMerge", LINUX_MIB_TCPOFOMERGE),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 055ac49..cc4e12f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4397,8 +4397,8 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 
 	TCP_ECN_check_ce(tp, skb);
 
-	if (tcp_try_rmem_schedule(sk, skb->truesize)) {
-		/* TODO: should increment a counter */
+	if (unlikely(tcp_try_rmem_schedule(sk, skb->truesize))) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFODROP);
 		__kfree_skb(skb);
 		return;
 	}
@@ -4407,6 +4407,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 	tp->pred_flags = 0;
 	inet_csk_schedule_ack(sk);
 
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFOQUEUE);
 	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
 		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
 
@@ -4460,6 +4461,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 	if (skb1 && before(seq, TCP_SKB_CB(skb1)->end_seq)) {
 		if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
 			/* All the bits are present. Drop. */
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFOMERGE);
 			__kfree_skb(skb);
 			skb = NULL;
 			tcp_dsack_set(sk, seq, end_seq);
@@ -4498,6 +4500,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 		__skb_unlink(skb1, &tp->out_of_order_queue);
 		tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
 				 TCP_SKB_CB(skb1)->end_seq);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFOMERGE);
 		__kfree_skb(skb1);
 	}
 
