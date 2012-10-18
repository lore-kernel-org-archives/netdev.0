From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix FIONREAD/SIOCINQ
Date: Thu, 18 Oct 2012 21:14:12 +0200
Message-ID: <1350587652.32642.215.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Elliot Hughes <enh@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37092 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab2JRTOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 15:14:23 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so4707872eek.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 12:14:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_ioctl() tries to take into account if tcp socket received a FIN
to report correct number bytes in receive queue.

But its flaky because if the application ate the last skb,
we return 1 instead of 0.

Correct way to detect that FIN was received is to test SOCK_DONE.

Reported-by: Elliot Hughes <enh@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/ipv4/tcp.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f32c02e..b7c2f43 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -549,14 +549,12 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 			 !tp->urg_data ||
 			 before(tp->urg_seq, tp->copied_seq) ||
 			 !before(tp->urg_seq, tp->rcv_nxt)) {
-			struct sk_buff *skb;
 
 			answ = tp->rcv_nxt - tp->copied_seq;
 
-			/* Subtract 1, if FIN is in queue. */
-			skb = skb_peek_tail(&sk->sk_receive_queue);
-			if (answ && skb)
-				answ -= tcp_hdr(skb)->fin;
+			/* Subtract 1, if FIN was received */
+			if (answ && sock_flag(sk, SOCK_DONE))
+				answ--;
 		} else
 			answ = tp->urg_seq - tp->copied_seq;
 		release_sock(sk);
