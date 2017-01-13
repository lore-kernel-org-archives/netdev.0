From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next v2 01/13] tcp: new helper function for RACK loss detection
Date: Thu, 12 Jan 2017 22:11:30 -0800
Message-ID: <20170113061142.127344-2-ycheng@google.com>
References: <20170113061142.127344-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
        nanditad@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:32890 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdAMGMI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:12:08 -0500
Received: by mail-pf0-f177.google.com with SMTP id y143so26039955pfb.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:12:08 -0800 (PST)
In-Reply-To: <20170113061142.127344-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a new helper tcp_rack_mark_skb_lost to prepare the
upcoming RACK reordering timer support.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_recovery.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index e36df4fcfeba..f38dba5aed7a 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -3,6 +3,19 @@
 
 int sysctl_tcp_recovery __read_mostly = TCP_RACK_LOST_RETRANS;
 
+static void tcp_rack_mark_skb_lost(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	tcp_skb_mark_lost_uncond_verify(tp, skb);
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
+		/* Account for retransmits that are lost again */
+		TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
+		tp->retrans_out -= tcp_skb_pcount(skb);
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPLOSTRETRANSMIT);
+	}
+}
+
 /* Marks a packet lost, if some packet sent later has been (s)acked.
  * The underlying idea is similar to the traditional dupthresh and FACK
  * but they look at different metrics:
@@ -61,13 +74,7 @@ int tcp_rack_mark_lost(struct sock *sk)
 				continue;
 
 			/* skb is lost if packet sent later is sacked */
-			tcp_skb_mark_lost_uncond_verify(tp, skb);
-			if (scb->sacked & TCPCB_SACKED_RETRANS) {
-				scb->sacked &= ~TCPCB_SACKED_RETRANS;
-				tp->retrans_out -= tcp_skb_pcount(skb);
-				NET_INC_STATS(sock_net(sk),
-					      LINUX_MIB_TCPLOSTRETRANSMIT);
-			}
+			tcp_rack_mark_skb_lost(sk, skb);
 		} else if (!(scb->sacked & TCPCB_RETRANS)) {
 			/* Original data are sent sequentially so stop early
 			 * b/c the rest are all sent after rack_sent
-- 
2.11.0.483.g087da7b7c-goog
