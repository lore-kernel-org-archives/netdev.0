From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix tcp_grow_window() for large incoming frames
Date: Tue, 17 Apr 2012 11:28:07 +0200
Message-ID: <1334654887.2472.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52132 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755956Ab2DQJ2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 05:28:12 -0400
Received: by bkcik5 with SMTP id ik5so4350596bkc.19
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 02:28:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_grow_window() has to grow rcv_ssthresh up to window_clamp, allowing
sender to increase its window.

tcp_grow_window() still assumes a tcp frame is under MSS, but its no
longer true with LRO/GRO.

This patch fixes one of the performance issue we noticed with GRO on.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
---
Sorry for the delay, this was discussed a long time ago.

 net/ipv4/tcp_input.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9944c1d..3ff36406 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -335,6 +335,7 @@ static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 			incr = __tcp_grow_window(sk, skb);
 
 		if (incr) {
+			incr = max_t(int, incr, 2 * skb->len);
 			tp->rcv_ssthresh = min(tp->rcv_ssthresh + incr,
 					       tp->window_clamp);
 			inet_csk(sk)->icsk_ack.quick |= 1;
