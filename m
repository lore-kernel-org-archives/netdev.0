From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Mon, 23 Mar 2015 13:38:10 +0300
Message-ID: <1427107090-4100-1-git-send-email-alexey.kodanev@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Alexey Kodanev <alexey.kodanev@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Regression introduced by commit 2dc49d1680.

tcp_v6_fill_cb() will be called twice if socket's state changes from
TCP_TIME_WAIT to TCP_LISTEN. That can result in performance loss and
control buffer data corruption because in the second tcp_v6_fill_cb()
it's not copying the 'header' anymore, but 'seq', 'end_seq', etc.

Reproduced with LTP/tcp_fastopen test and netperf -t TCP_CRR, so when
we're constantly closing and opening TCP connections after several
requests/responses from client.

This can be fixed if we move 'header' union back to the beginning of
'struct tcp_skb_cb' and getting skb->next, TCP_SKB_CB(skb)->seq and
TCP_SKB_CB(skb)->end_seq on the same cache line by moving 'cb[48]'
closer to 'skb->next', above the *sk and *dev pointers.

Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 include/linux/skbuff.h |    5 +++--
 include/net/tcp.h      |   17 ++++++++---------
 net/ipv4/tcp_ipv4.c    |    6 ------
 net/ipv4/tcp_output.c  |    4 ----
 net/ipv6/tcp_ipv6.c    |   21 ++++-----------------
 5 files changed, 15 insertions(+), 38 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f54d665..8870d16 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -524,8 +524,6 @@ struct sk_buff {
 		};
 		struct rb_node	rbnode; /* used in netem & tcp stack */
 	};
-	struct sock		*sk;
-	struct net_device	*dev;
 
 	/*
 	 * This is the control buffer. It is free to use for every
@@ -535,6 +533,9 @@ struct sk_buff {
 	 */
 	char			cb[48] __aligned(8);
 
+	struct sock		*sk;
+	struct net_device	*dev;
+
 	unsigned long		_skb_refdst;
 	void			(*destructor)(struct sk_buff *skb);
 #ifdef CONFIG_XFRM
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8d6b983..1a5cf12 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -694,6 +694,13 @@ static inline u32 tcp_skb_timestamp(const struct sk_buff *skb)
  * If this grows please adjust skbuff.h:skbuff->cb[xxx] size appropriately.
  */
 struct tcp_skb_cb {
+	union {
+		struct inet_skb_parm	h4;
+#if IS_ENABLED(CONFIG_IPV6)
+		struct inet6_skb_parm	h6;
+#endif
+	} header;	/* For incoming frames		*/
+
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	union {
@@ -721,21 +728,13 @@ struct tcp_skb_cb {
 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
 	/* 1 byte hole */
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
-	union {
-		struct inet_skb_parm	h4;
-#if IS_ENABLED(CONFIG_IPV6)
-		struct inet6_skb_parm	h6;
-#endif
-	} header;	/* For incoming frames		*/
 };
 
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
 
 
 #if IS_ENABLED(CONFIG_IPV6)
-/* This is the variant of inet6_iif() that must be used by TCP,
- * as TCP moves IP6CB into a different location in skb->cb[]
- */
+/* This is the variant of inet6_iif() that must be used by TCP */
 static inline int tcp_v6_iif(const struct sk_buff *skb)
 {
 	return TCP_SKB_CB(skb)->header.h6.iif;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5a2dfed..43d6cd2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1622,12 +1622,6 @@ int tcp_v4_rcv(struct sk_buff *skb)
 
 	th = tcp_hdr(skb);
 	iph = ip_hdr(skb);
-	/* This is tricky : We move IPCB at its correct location into TCP_SKB_CB()
-	 * barrier() makes sure compiler wont play fool^Waliasing games.
-	 */
-	memmove(&TCP_SKB_CB(skb)->header.h4, IPCB(skb),
-		sizeof(struct inet_skb_parm));
-	barrier();
 
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a2a796c..7de50d0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1011,10 +1011,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	/* Our usage of tstamp should remain private */
 	skb->tstamp.tv64 = 0;
 
-	/* Cleanup our debris for IP stacks */
-	memset(skb->cb, 0, max(sizeof(struct inet_skb_parm),
-			       sizeof(struct inet6_skb_parm)));
-
 	err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
 
 	if (likely(err <= 0))
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5d46832..e8cc440 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1392,15 +1392,6 @@ ipv6_pktoptions:
 static void tcp_v6_fill_cb(struct sk_buff *skb, const struct ipv6hdr *hdr,
 			   const struct tcphdr *th)
 {
-	/* This is tricky: we move IP6CB at its correct location into
-	 * TCP_SKB_CB(). It must be done after xfrm6_policy_check(), because
-	 * _decode_session6() uses IP6CB().
-	 * barrier() makes sure compiler won't play aliasing games.
-	 */
-	memmove(&TCP_SKB_CB(skb)->header.h6, IP6CB(skb),
-		sizeof(struct inet6_skb_parm));
-	barrier();
-
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
 				    skb->len - th->doff*4);
@@ -1443,8 +1434,10 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	th = tcp_hdr(skb);
 	hdr = ipv6_hdr(skb);
 
+	tcp_v6_fill_cb(skb, hdr, th);
+
 	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest,
-				inet6_iif(skb));
+				tcp_v6_iif(skb));
 	if (!sk)
 		goto no_tcp_socket;
 
@@ -1460,8 +1453,6 @@ process:
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
-	tcp_v6_fill_cb(skb, hdr, th);
-
 #ifdef CONFIG_TCP_MD5SIG
 	if (tcp_v6_inbound_md5_hash(sk, skb))
 		goto discard_and_relse;
@@ -1493,8 +1484,6 @@ no_tcp_socket:
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
 
-	tcp_v6_fill_cb(skb, hdr, th);
-
 	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
 csum_error:
 		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
@@ -1518,8 +1507,6 @@ do_time_wait:
 		goto discard_it;
 	}
 
-	tcp_v6_fill_cb(skb, hdr, th);
-
 	if (skb->len < (th->doff<<2)) {
 		inet_twsk_put(inet_twsk(sk));
 		goto bad_packet;
@@ -1538,7 +1525,7 @@ do_time_wait:
 					    &ipv6_hdr(skb)->saddr, th->source,
 					    &ipv6_hdr(skb)->daddr,
 					    ntohs(th->dest), tcp_v6_iif(skb));
-		if (sk2 != NULL) {
+		if (sk2) {
 			struct inet_timewait_sock *tw = inet_twsk(sk);
 			inet_twsk_deschedule(tw, &tcp_death_row);
 			inet_twsk_put(tw);
-- 
1.7.1
