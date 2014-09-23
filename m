From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 3/3] tcp: better TCP_SKB_CB layout to reduce cache line misses
Date: Tue, 23 Sep 2014 03:34:12 -0700
Message-ID: <1411468452-3729-4-git-send-email-edumazet@google.com>
References: <1411468452-3729-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:44221 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755809AbaIWKeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 06:34:20 -0400
Received: by mail-ie0-f201.google.com with SMTP id rd18so705006iec.0
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 03:34:19 -0700 (PDT)
In-Reply-To: <1411468452-3729-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP maintains lists of skb in write queue, and in receive queues
(in order and out of order queues)

Scanning these lists both in input and output path usually requires
access to skb->next, TCP_SKB_CB(skb)->seq, and TCP_SKB_CB(skb)->end_seq

These fields are currently in two different cache lines, meaning we
waste lot of memory bandwidth when these queues are big and flows
have either packet drops or packet reorders.

We can move TCP_SKB_CB(skb)->header at the end of TCP_SKB_CB, because
this header is not used in fast path. This allows TCP to search much faster
in the skb lists.

Even with regular flows, we save one cache line miss in fast path.

Thanks to Christoph Paasch for noticing we need to cleanup
skb->cb[] (IPCB/IP6CB) before entering IP stack in tx path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     | 12 ++++++------
 net/ipv4/tcp_ipv4.c   |  7 +++++++
 net/ipv4/tcp_output.c |  5 +++++
 net/ipv6/tcp_ipv6.c   |  7 +++++++
 4 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a4201ef216e8..4dc6641ee990 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -696,12 +696,6 @@ static inline u32 tcp_skb_timestamp(const struct sk_buff *skb)
  * If this grows please adjust skbuff.h:skbuff->cb[xxx] size appropriately.
  */
 struct tcp_skb_cb {
-	union {
-		struct inet_skb_parm	h4;
-#if IS_ENABLED(CONFIG_IPV6)
-		struct inet6_skb_parm	h6;
-#endif
-	} header;	/* For incoming frames		*/
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	__u32		tcp_tw_isn;	/* isn chosen by tcp_timewait_state_process() */
@@ -720,6 +714,12 @@ struct tcp_skb_cb {
 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
 	/* 1 byte hole */
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
+	union {
+		struct inet_skb_parm	h4;
+#if IS_ENABLED(CONFIG_IPV6)
+		struct inet6_skb_parm	h6;
+#endif
+	} header;	/* For incoming frames		*/
 };
 
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 28ab90382c01..70c4a21f6f45 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1636,6 +1636,13 @@ int tcp_v4_rcv(struct sk_buff *skb)
 
 	th = tcp_hdr(skb);
 	iph = ip_hdr(skb);
+	/* This is tricky : We move IPCB at its correct location into TCP_SKB_CB()
+	 * barrier() makes sure compiler wont play fool^Waliasing games.
+	 */
+	memmove(&TCP_SKB_CB(skb)->header.h4, IPCB(skb),
+		sizeof(struct inet_skb_parm));
+	barrier();
+
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
 				    skb->len - th->doff * 4);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8c61a7c0c889..6c7949cafd99 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -974,6 +974,11 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	/* Our usage of tstamp should remain private */
 	skb->tstamp.tv64 = 0;
+
+	/* Cleanup our debris for IP stacks */
+	memset(skb->cb, 0, max(sizeof(struct inet_skb_parm),
+			       sizeof(struct inet6_skb_parm)));
+
 	err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
 
 	if (likely(err <= 0))
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9400b4326f22..132bac137aed 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1412,6 +1412,13 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 
 	th = tcp_hdr(skb);
 	hdr = ipv6_hdr(skb);
+	/* This is tricky : We move IPCB at its correct location into TCP_SKB_CB()
+	 * barrier() makes sure compiler wont play fool^Waliasing games.
+	 */
+	memmove(&TCP_SKB_CB(skb)->header.h6, IP6CB(skb),
+		sizeof(struct inet6_skb_parm));
+	barrier();
+
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
 				    skb->len - th->doff*4);
-- 
2.1.0.rc2.206.gedb03e5
