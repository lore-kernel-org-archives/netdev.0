From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net] tcp: set retransmit_high on loop exit
Date: Sun, 11 May 2014 20:57:30 +0800
Message-ID: <b1093d318477c57478b0b64475d9066710d7c75b.1399812676.git.panweiping3@gmail.com>
Cc: Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34632 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757226AbaEKM6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 08:58:33 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so6360001pab.38
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 05:58:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To save some CPU cycles slightly.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/tcp_input.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6b46eb..e431037 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1941,8 +1941,13 @@ void tcp_enter_loss(struct sock *sk, int how)
 	tcp_clear_all_retrans_hints(tp);
 
 	tcp_for_write_queue(skb, sk) {
-		if (skb == tcp_send_head(sk))
+		if (skb == tcp_send_head(sk)) {
+			if (skb != tcp_write_queue_head(sk)) {
+				skb = tcp_write_queue_prev(sk, skb);
+				tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
+			}
 			break;
+		}
 
 		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
 			tp->undo_marker = 0;
@@ -1952,7 +1957,6 @@ void tcp_enter_loss(struct sock *sk, int how)
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 			tp->lost_out += tcp_skb_pcount(skb);
-			tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
 		}
 	}
 	tcp_verify_left_out(tp);
-- 
1.9.0
