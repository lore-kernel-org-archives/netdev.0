From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Fri, 14 Oct 2011 09:19:51 +0200
Message-ID: <1318576791.2533.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65190 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100Ab1JNHT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 03:19:57 -0400
Received: by wyg34 with SMTP id 34so2674715wyg.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 00:19:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many drivers allocates big skb to store a single TCP frame.
(WIFI drivers, or NIC using PAGE_SIZE fragments)

Its now common to get skb->truesize bigger than 4096 to store a ~1500
bytes TCP frame.

TCP sessions with large RTT and packet losses can fill their Out Of
Order queue with such oversized skbs, and hit their sk_rcvbuf limit,
starting a pruning of complete OFO queue, without giving chance to
receive the missing packet(s) and moving skbs from OFO to receive queue.

This patch adds skb_reduce_truesize() helper, and uses it for all skbs
queued into OFO queue.

Spending some time to perform a copy is worth the pain, since it permits
SACK processing to have a chance to complete over the RTT barrier.

This greatly improves user experience, without added cost on fast path.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_input.c |   24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c1653fe..1d10edb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4426,6 +4426,25 @@ static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
 	return 0;
 }
 
+/*
+ * Caller want to reduce memory needs before queueing skb
+ * The (expensive) copy should not be be done in fast path.
+ */
+static struct sk_buff *skb_reduce_truesize(struct sk_buff *skb)
+{
+	if (skb->truesize > 2 * SKB_TRUESIZE(skb->len)) {
+		struct sk_buff *nskb;
+
+		nskb = skb_copy_expand(skb, skb_headroom(skb), 0,
+				       GFP_ATOMIC | __GFP_NOWARN);
+		if (nskb) {
+			__kfree_skb(skb);
+			skb = nskb;
+		}
+	}
+	return skb;
+}
+
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcphdr *th = tcp_hdr(skb);
@@ -4553,6 +4572,11 @@ drop:
 	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
 		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
 
+	/* Since this skb might stay on ofo a long time, try to reduce
+	 * its truesize (if its too big) to avoid future pruning.
+	 * Many drivers allocate large buffers even to hold tiny frames.
+	 */
+	skb = skb_reduce_truesize(skb);
 	skb_set_owner_r(skb, sk);
 
 	if (!skb_peek(&tp->out_of_order_queue)) {
