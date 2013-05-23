From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: xps: fix reordering issues
Date: Thu, 23 May 2013 10:44:20 -0700
Message-ID: <1369331060.3301.396.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:49731 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758362Ab3EWRoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 13:44:22 -0400
Received: by mail-pa0-f44.google.com with SMTP id wp1so660160pac.31
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 10:44:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 3853b5841c01a ("xps: Improvements in TX queue selection")
introduced ooo_okay flag, but the condition to set it is slightly wrong.

In our traces, we have seen ACK packets being received out of order,
and RST packets sent in response.

We should test if we have any packets still in host queue.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 536d409..ec335fa 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -874,11 +874,13 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 							   &md5);
 	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
 
-	if (tcp_packets_in_flight(tp) == 0) {
+	if (tcp_packets_in_flight(tp) == 0)
 		tcp_ca_event(sk, CA_EVENT_TX_START);
-		skb->ooo_okay = 1;
-	} else
-		skb->ooo_okay = 0;
+
+	/* if no packet is in qdisc/device queue, then allow XPS to select
+	 * another queue.
+	 */
+	skb->ooo_okay = sk_wmem_alloc_get(sk) == 0;
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
