From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: increment retransmit counters in tlp and fast open
Date: Mon, 28 Apr 2014 22:00:29 -0700
Message-ID: <1398747629.29914.143.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44569 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152AbaD2FAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 01:00:30 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so6635982pad.35
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 22:00:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Both TLP and Fast Open call __tcp_retransmit_skb() instead of
tcp_retransmit_skb() to avoid changing tp->retrans_out.

This has the side effect of missing SNMP counters increments as well
as tcp_info tcpi_total_retrans updates.

Fix this by moving the stats increments of into __tcp_retransmit_skb()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 025e25093984..12d6016bdd9a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2441,8 +2441,14 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 	}
 
-	if (likely(!err))
+	if (likely(!err)) {
 		TCP_SKB_CB(skb)->sacked |= TCPCB_EVER_RETRANS;
+		/* Update global TCP statistics. */
+		TCP_INC_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS);
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
+		tp->total_retrans++;
+	}
 	return err;
 }
 
@@ -2452,12 +2458,6 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	int err = __tcp_retransmit_skb(sk, skb);
 
 	if (err == 0) {
-		/* Update global TCP statistics. */
-		TCP_INC_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS);
-		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
-			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
-		tp->total_retrans++;
-
 #if FASTRETRANS_DEBUG > 0
 		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
 			net_dbg_ratelimited("retrans_out leaked\n");
