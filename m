From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_try_coalesce returns a boolean
Date: Tue, 24 Apr 2012 05:34:36 +0200
Message-ID: <1335238476.5205.122.camel@edumazet-glaptop>
References: <1335201102.5205.28.camel@edumazet-glaptop>
	 <CADVnQy=igJdbcG4J2HU7nEJUNM84qVcLa08h6g6MQQ8-fvgxHg@mail.gmail.com>
	 <20120423.224602.594997774992725103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, therbert@google.com,
	maze@google.com, ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34330 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508Ab2DXDel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 23:34:41 -0400
Received: by wejx9 with SMTP id x9so122303wej.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 20:34:40 -0700 (PDT)
In-Reply-To: <20120423.224602.594997774992725103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This clarifies code intention, as suggested by David.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bd7aef5..67f352a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4459,23 +4459,23 @@ static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
  * to reduce overall memory use and queue lengths, if cost is small.
  * Packets in ofo or receive queues can stay a long time.
  * Better try to coalesce them right now to avoid future collapses.
- * Returns > 0 value if caller should free @from instead of queueing it
+ * Returns true if caller should free @from instead of queueing it
  */
-static int tcp_try_coalesce(struct sock *sk,
-			    struct sk_buff *to,
-			    struct sk_buff *from)
+static bool tcp_try_coalesce(struct sock *sk,
+			     struct sk_buff *to,
+			     struct sk_buff *from)
 {
 	int len = from->len;
 
 	if (tcp_hdr(from)->fin)
-		return 0;
+		return false;
 	if (len <= skb_tailroom(to)) {
 		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
 merge:
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
 		TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
 		TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
-		return 1;
+		return true;
 	}
 	if (skb_headlen(from) == 0 &&
 	    !skb_has_frag_list(to) &&
@@ -4498,7 +4498,7 @@ merge:
 		to->data_len += len;
 		goto merge;
 	}
-	return 0;
+	return false;
 }
 
 static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
@@ -4539,7 +4539,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 	end_seq = TCP_SKB_CB(skb)->end_seq;
 
 	if (seq == TCP_SKB_CB(skb1)->end_seq) {
-		if (tcp_try_coalesce(sk, skb1, skb) <= 0) {
+		if (!tcp_try_coalesce(sk, skb1, skb)) {
 			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 		} else {
 			__kfree_skb(skb);
@@ -4671,7 +4671,7 @@ queue_and_out:
 				goto drop;
 
 			tail = skb_peek_tail(&sk->sk_receive_queue);
-			eaten = tail ? tcp_try_coalesce(sk, tail, skb) : -1;
+			eaten = (tail && tcp_try_coalesce(sk, tail, skb)) ? 1 : 0;
 			if (eaten <= 0) {
 				skb_set_owner_r(skb, sk);
 				__skb_queue_tail(&sk->sk_receive_queue, skb);
