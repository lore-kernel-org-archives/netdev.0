From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 2/6] ipv6: Append sending data to arbitrary queue
Date: Sat, 31 Jan 2015 10:40:14 -0500
Message-ID: <1422718818-21093-3-git-send-email-vyasevic@redhat.com>
References: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Cc: herbert@gondor.apana.org.au, hannes@stressinduktion.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:49350 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbbAaPk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 10:40:29 -0500
Received: by mail-qg0-f43.google.com with SMTP id e89so42243239qgf.2
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 07:40:28 -0800 (PST)
In-Reply-To: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ability to append data to arbitrary queue.  This
will be needed later to implement lockless UDP sends.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/ipv6/ip6_output.c | 106 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 67 insertions(+), 39 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f9f08c4..1b66453 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1041,6 +1041,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup_flow);
 
 static inline int ip6_ufo_append_data(struct sock *sk,
+			struct sk_buff_head *queue,
 			int getfrag(void *from, char *to, int offset, int len,
 			int odd, struct sk_buff *skb),
 			void *from, int length, int hh_len, int fragheaderlen,
@@ -1056,7 +1057,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	 * device, so create one single skb packet containing complete
 	 * udp datagram
 	 */
-	skb = skb_peek_tail(&sk->sk_write_queue);
+	skb = skb_peek_tail(queue);
 	if (skb == NULL) {
 		skb = sock_alloc_send_skb(sk,
 			hh_len + fragheaderlen + transhdrlen + 20,
@@ -1079,7 +1080,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->csum = 0;
 
-		__skb_queue_tail(&sk->sk_write_queue, skb);
+		__skb_queue_tail(queue, skb);
 	} else if (skb_is_gso(skb)) {
 		goto append;
 	}
@@ -1203,49 +1204,36 @@ static int ip6_setup_cork(struct sock *sk, struct inet_cork_full *cork,
 	return 0;
 }
 
-int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
-	int offset, int len, int odd, struct sk_buff *skb),
-	void *from, int length, int transhdrlen,
-	int hlimit, int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
-	struct rt6_info *rt, unsigned int flags, int dontfrag)
+static int __ip6_append_data(struct sock *sk,
+			     struct flowi6 *fl6,
+			     struct sk_buff_head *queue,
+			     struct inet_cork *cork,
+			     struct inet6_cork *v6_cork,
+			     struct page_frag *pfrag,
+			     int getfrag(void *from, char *to, int offset,
+					 int len, int odd, struct sk_buff *skb),
+			     void *from, int length, int transhdrlen,
+			     unsigned int flags, int dontfrag)
 {
-	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct inet_cork *cork;
 	struct sk_buff *skb, *skb_prev = NULL;
 	unsigned int maxfraglen, fragheaderlen, mtu, orig_mtu;
-	int exthdrlen;
-	int dst_exthdrlen;
+	int exthdrlen = 0;
+	int dst_exthdrlen = 0;
 	int hh_len;
 	int copy;
 	int err;
 	int offset = 0;
 	__u8 tx_flags = 0;
 	u32 tskey = 0;
+	struct rt6_info *rt = (struct rt6_info *)cork->dst;
+	struct ipv6_txoptions *opt = v6_cork->opt;
 
-	if (flags&MSG_PROBE)
-		return 0;
-	cork = &inet->cork.base;
-	if (skb_queue_empty(&sk->sk_write_queue)) {
-		/*
-		 * setup for corking
-		 */
-		err = ip6_setup_cork(sk, &inet->cork, &np->cork, hlimit,
-				     tclass, opt, rt, fl6);
-		if (err)
-			return err;
-		exthdrlen = (opt ? opt->opt_flen : 0);
-		length += exthdrlen;
-		transhdrlen += exthdrlen;
+	skb = skb_peek_tail(queue);
+	if (!skb) {
+		exthdrlen = opt ? opt->opt_flen : 0;
 		dst_exthdrlen = rt->dst.header_len - rt->rt6i_nfheader_len;
-	} else {
-		rt = (struct rt6_info *)cork->dst;
-		fl6 = &inet->cork.fl.u.ip6;
-		opt = np->cork.opt;
-		transhdrlen = 0;
-		exthdrlen = 0;
-		dst_exthdrlen = 0;
 	}
+
 	mtu = cork->fragsize;
 	orig_mtu = mtu;
 
@@ -1311,13 +1299,12 @@ emsgsize:
 	 * --yoshfuji
 	 */
 
-	skb = skb_peek_tail(&sk->sk_write_queue);
 	cork->length += length;
 	if (((length > mtu) ||
 	     (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO)) {
-		err = ip6_ufo_append_data(sk, getfrag, from, length,
+		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
 					  hh_len, fragheaderlen,
 					  transhdrlen, mtu, flags, rt);
 		if (err)
@@ -1458,7 +1445,7 @@ alloc_new_skb:
 			/*
 			 * Put the packet on the pending queue
 			 */
-			__skb_queue_tail(&sk->sk_write_queue, skb);
+			__skb_queue_tail(queue, skb);
 			continue;
 		}
 
@@ -1477,7 +1464,6 @@ alloc_new_skb:
 			}
 		} else {
 			int i = skb_shinfo(skb)->nr_frags;
-			struct page_frag *pfrag = sk_page_frag(sk);
 
 			err = -ENOMEM;
 			if (!sk_page_frag_refill(sk, pfrag))
@@ -1520,6 +1506,42 @@ error:
 	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
+
+int ip6_append_data(struct sock *sk,
+		    int getfrag(void *from, char *to, int offset, int len,
+				int odd, struct sk_buff *skb),
+		    void *from, int length, int transhdrlen, int hlimit,
+		    int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
+		    struct rt6_info *rt, unsigned int flags, int dontfrag)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	int exthdrlen;
+	int err;
+
+	if (flags&MSG_PROBE)
+		return 0;
+	if (skb_queue_empty(&sk->sk_write_queue)) {
+		/*
+		 * setup for corking
+		 */
+		err = ip6_setup_cork(sk, &inet->cork, &np->cork, hlimit,
+				     tclass, opt, rt, fl6);
+		if (err)
+			return err;
+
+		exthdrlen = (opt ? opt->opt_flen : 0);
+		length += exthdrlen;
+		transhdrlen += exthdrlen;
+	} else {
+		fl6 = &inet->cork.fl.u.ip6;
+		transhdrlen = 0;
+	}
+
+	return __ip6_append_data(sk, fl6, &sk->sk_write_queue, &inet->cork.base,
+				 &np->cork, sk_page_frag(sk), getfrag,
+				 from, length, transhdrlen, flags, dontfrag);
+}
 EXPORT_SYMBOL_GPL(ip6_append_data);
 
 static void ip6_cork_release(struct inet_cork_full *cork,
@@ -1627,11 +1649,12 @@ error:
 }
 EXPORT_SYMBOL_GPL(ip6_push_pending_frames);
 
-void ip6_flush_pending_frames(struct sock *sk)
+static void __ip6_flush_pending_frames(struct sock *sk,
+				       struct sk_buff_head *queue)
 {
 	struct sk_buff *skb;
 
-	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
+	while ((skb = __skb_dequeue_tail(queue)) != NULL) {
 		if (skb_dst(skb))
 			IP6_INC_STATS(sock_net(sk), ip6_dst_idev(skb_dst(skb)),
 				      IPSTATS_MIB_OUTDISCARDS);
@@ -1640,4 +1663,9 @@ void ip6_flush_pending_frames(struct sock *sk)
 
 	ip6_cork_release(&inet_sk(sk)->cork, &inet6_sk(sk)->cork);
 }
+
+void ip6_flush_pending_frames(struct sock *sk)
+{
+	__ip6_flush_pending_frames(sk, &sk->sk_write_queue);
+}
 EXPORT_SYMBOL_GPL(ip6_flush_pending_frames);
-- 
1.9.3
