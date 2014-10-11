From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix ooo_okay setting vs Small Queues
Date: Fri, 10 Oct 2014 18:06:35 -0700
Message-ID: <1412989595.9362.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:64922 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaJKBGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 21:06:37 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so2491793pdj.23
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 18:06:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP Small Queues (tcp_tsq_handler()) can hold one reference on
sk->sk_wmem_alloc, preventing skb->ooo_okay being set.

We should relax test done to set skb->ooo_okay to take care
of this extra reference.

Minimal truesize of skb containing one byte of payload is
SKB_TRUESIZE(1)

Without this fix, we have more chance locking flows into the wrong
transmit queue.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8d4eac793700..e2be1f80e0be 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -914,9 +914,13 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		tcp_ca_event(sk, CA_EVENT_TX_START);
 
 	/* if no packet is in qdisc/device queue, then allow XPS to select
-	 * another queue.
+	 * another queue. We can be called from tcp_tsq_handler()
+	 * which holds one reference to sk_wmem_alloc.
+	 *
+	 * TODO: Ideally, in-flight pure ACK packets should not matter here.
+	 * One way to get this would be to set skb->truesize = 2 on them.
 	 */
-	skb->ooo_okay = sk_wmem_alloc_get(sk) == 0;
+	skb->ooo_okay = sk_wmem_alloc_get(sk) < SKB_TRUESIZE(1);
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
