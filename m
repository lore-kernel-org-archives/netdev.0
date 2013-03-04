From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] tcp: fix double-counted receiver RTT when leaving receiver fast path
Date: Mon,  4 Mar 2013 11:23:05 -0500
Message-ID: <1362414185-9874-1-git-send-email-ncardwell@google.com>
Cc: edumazet@google.com, ycheng@google.com, nanditad@google.com,
	netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:60147 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756841Ab3CDQw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 11:52:29 -0500
Received: by mail-qc0-f202.google.com with SMTP id k26so170439qcs.5
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 08:52:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not update ts_recent and call tcp_rcv_rtt_measure_ts() both
before and after going to step5. That wastes CPU and double-counts the
receiver-side RTT sample.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a759e19..0d9bdac 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5485,6 +5485,9 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				if (tcp_checksum_complete_user(sk, skb))
 					goto csum_error;
 
+				if ((int)skb->truesize > sk->sk_forward_alloc)
+					goto step5;
+
 				/* Predicted packet is in window by definition.
 				 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
 				 * Hence, check seq<=rcv_wup reduces to:
@@ -5496,9 +5499,6 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 
 				tcp_rcv_rtt_measure_ts(sk, skb);
 
-				if ((int)skb->truesize > sk->sk_forward_alloc)
-					goto step5;
-
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITS);
 
 				/* Bulk data transfer: receiver */
-- 
1.8.1.3
