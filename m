From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: account all retransmit failures
Date: Fri, 12 Jul 2013 11:33:04 -0700
Message-ID: <1373653984-30249-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f202.google.com ([209.85.160.202]:56965 "EHLO
	mail-gh0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965116Ab3GLSdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 14:33:18 -0400
Received: by mail-gh0-f202.google.com with SMTP id g24so863780ghb.1
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 11:33:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change snmp RETRANSFAILS stat to include timeout retransmit failures
in addition to other loss recoveries.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3d60949..92fde8d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2407,6 +2407,8 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		 * see tcp_input.c tcp_sacktag_write_queue().
 		 */
 		TCP_SKB_CB(skb)->ack_seq = tp->snd_nxt;
+	} else {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
 	}
 	return err;
 }
@@ -2528,10 +2530,9 @@ begin_fwd:
 		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
 			continue;
 
-		if (tcp_retransmit_skb(sk, skb)) {
-			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
+		if (tcp_retransmit_skb(sk, skb))
 			return;
-		}
+
 		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 
 		if (tcp_in_cwnd_reduction(sk))
-- 
1.8.3
