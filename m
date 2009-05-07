From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] tcp: tcp_prequeue() can use keyed wakeups
Date: Thu, 07 May 2009 19:20:39 +0200
Message-ID: <4A031867.9060806@cosmosbay.com>
References: <4A031596.4020904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55440 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbZEGRUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 13:20:41 -0400
In-Reply-To: <4A031596.4020904@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can avoid waking up tasks not interested in receive notifications,
using wake_up_interruptible_poll() instead of wake_up_interruptible()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


diff --git a/include/net/tcp.h b/include/net/tcp.h
index ac37228..87d210b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -908,7 +908,8 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 
 		tp->ucopy.memory = 0;
 	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
-		wake_up_interruptible(sk->sk_sleep);
+		wake_up_interruptible_poll(sk->sk_sleep,
+					   POLLIN | POLLRDNORM | POLLRDBAND);
 		if (!inet_csk_ack_scheduled(sk))
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
 						  (3 * TCP_RTO_MIN) / 4,

