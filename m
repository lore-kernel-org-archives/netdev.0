From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: defer sacked assignment
Date: Wed, 17 Aug 2016 07:48:36 -0700
Message-ID: <1471445316.4943.40.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34858 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcHQOtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:49:09 -0400
Received: by mail-pa0-f68.google.com with SMTP id cf3so7348051pad.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:48:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While chasing tcp_xmit_retransmit_queue() kasan issue, I found
that we could avoid reading sacked field of skb that we wont send,
possibly removing one cache line miss.

Very minor change in slow path, but why not ? ;) 

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bdaef7fd6e47701b2d2280e1f40f816e1920c432..8b45794eb6b2600c914e504b8031f61dbbe164a3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2776,7 +2776,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 
 	max_segs = tcp_tso_autosize(sk, tcp_current_mss(sk));
 	tcp_for_write_queue_from(skb, sk) {
-		__u8 sacked = TCP_SKB_CB(skb)->sacked;
+		__u8 sacked;
 		int segs;
 
 		if (skb == tcp_send_head(sk))
@@ -2788,6 +2788,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		segs = tp->snd_cwnd - tcp_packets_in_flight(tp);
 		if (segs <= 0)
 			return;
+		sacked = TCP_SKB_CB(skb)->sacked;
 		/* In case tcp_shift_skb_data() have aggregated large skbs,
 		 * we need to make sure not sending too bigs TSO packets
 		 */
