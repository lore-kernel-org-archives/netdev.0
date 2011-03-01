From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/5] udp: Switch to ip_finish_skb
Date: Tue, 01 Mar 2011 20:36:48 +0800
Message-ID: <E1PuOoq-0001y5-2f@gondolin.me.apana.org.au>
References: <20110301123519.GA7453@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34471 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781Ab1CAMhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 07:37:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp: Switch to ip_finish_skb

This patch converts UDP to use the new ip_finish_skb API.  This
would then allows us to more easily use ip_make_skb which allows
UDP to run without a socket lock.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/udp.h     |   11 ++++++
 include/net/udplite.h |   12 +++++++
 net/ipv4/udp.c        |   83 ++++++++++++++++++++++++++++++--------------------
 3 files changed, 73 insertions(+), 33 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index bb967dd..b8563ba 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -144,6 +144,17 @@ static inline __wsum udp_csum_outgoing(struct sock *sk, struct sk_buff *skb)
 	return csum;
 }
 
+static inline __wsum udp_csum(struct sk_buff *skb)
+{
+	__wsum csum = csum_partial(skb_transport_header(skb),
+				   sizeof(struct udphdr), skb->csum);
+
+	for (skb = skb_shinfo(skb)->frag_list; skb; skb = skb->next) {
+		csum = csum_add(csum, skb->csum);
+	}
+	return csum;
+}
+
 /* hash routines shared between UDPv4/6 and UDP-Litev4/6 */
 static inline void udp_lib_hash(struct sock *sk)
 {
diff --git a/include/net/udplite.h b/include/net/udplite.h
index afdffe6..673a024 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -115,6 +115,18 @@ static inline __wsum udplite_csum_outgoing(struct sock *sk, struct sk_buff *skb)
 	return csum;
 }
 
+static inline __wsum udplite_csum(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	int cscov = udplite_sender_cscov(udp_sk(sk), udp_hdr(skb));
+	const int off = skb_transport_offset(skb);
+	const int len = skb->len - off;
+
+	skb->ip_summed = CHECKSUM_NONE;     /* no HW support for checksumming */
+
+	return skb_checksum(skb, off, min(cscov, len), 0);
+}
+
 extern void	udplite4_register(void);
 extern int 	udplite_get_port(struct sock *sk, unsigned short snum,
 			int (*scmp)(const struct sock *, const struct sock *));
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8157b17..9a6d326 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -663,75 +663,72 @@ void udp_flush_pending_frames(struct sock *sk)
 EXPORT_SYMBOL(udp_flush_pending_frames);
 
 /**
- * 	udp4_hwcsum_outgoing  -  handle outgoing HW checksumming
- * 	@sk: 	socket we are sending on
+ * 	udp4_hwcsum  -  handle outgoing HW checksumming
  * 	@skb: 	sk_buff containing the filled-in UDP header
  * 	        (checksum field must be zeroed out)
+ *	@src:	source IP address
+ *	@dst:	destination IP address
  */
-static void udp4_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
-				 __be32 src, __be32 dst, int len)
+static void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
 {
-	unsigned int offset;
 	struct udphdr *uh = udp_hdr(skb);
+	struct sk_buff *frags = skb_shinfo(skb)->frag_list;
+	int offset = skb_transport_offset(skb);
+	int len = skb->len - offset;
+	int hlen = len;
 	__wsum csum = 0;
 
-	if (skb_queue_len(&sk->sk_write_queue) == 1) {
+	if (!frags) {
 		/*
 		 * Only one fragment on the socket.
 		 */
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct udphdr, check);
-		uh->check = ~csum_tcpudp_magic(src, dst, len, IPPROTO_UDP, 0);
+		uh->check = ~csum_tcpudp_magic(src, dst, len,
+					       IPPROTO_UDP, 0);
 	} else {
 		/*
 		 * HW-checksum won't work as there are two or more
 		 * fragments on the socket so that all csums of sk_buffs
 		 * should be together
 		 */
-		offset = skb_transport_offset(skb);
-		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+		do {
+			csum = csum_add(csum, frags->csum);
+			hlen -= frags->len;
+		} while ((frags = frags->next));
 
+		csum = skb_checksum(skb, offset, hlen, csum);
 		skb->ip_summed = CHECKSUM_NONE;
 
-		skb_queue_walk(&sk->sk_write_queue, skb) {
-			csum = csum_add(csum, skb->csum);
-		}
-
 		uh->check = csum_tcpudp_magic(src, dst, len, IPPROTO_UDP, csum);
 		if (uh->check == 0)
 			uh->check = CSUM_MANGLED_0;
 	}
 }
 
-/*
- * Push out all pending data as one UDP datagram. Socket is locked.
- */
-static int udp_push_pending_frames(struct sock *sk)
+static int udp_send_skb(struct sk_buff *skb, __be32 daddr, __be32 dport)
 {
-	struct udp_sock  *up = udp_sk(sk);
+	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
-	struct flowi *fl = &inet->cork.fl;
-	struct sk_buff *skb;
 	struct udphdr *uh;
+	struct rtable *rt = (struct rtable *)skb_dst(skb);
 	int err = 0;
 	int is_udplite = IS_UDPLITE(sk);
+	int offset = skb_transport_offset(skb);
+	int len = skb->len - offset;
 	__wsum csum = 0;
 
-	/* Grab the skbuff where UDP header space exists. */
-	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
-		goto out;
-
 	/*
 	 * Create a UDP header
 	 */
 	uh = udp_hdr(skb);
-	uh->source = fl->fl_ip_sport;
-	uh->dest = fl->fl_ip_dport;
-	uh->len = htons(up->len);
+	uh->source = inet->inet_sport;
+	uh->dest = dport;
+	uh->len = htons(len);
 	uh->check = 0;
 
 	if (is_udplite)  				 /*     UDP-Lite      */
-		csum  = udplite_csum_outgoing(sk, skb);
+		csum = udplite_csum(skb);
 
 	else if (sk->sk_no_check == UDP_CSUM_NOXMIT) {   /* UDP csum disabled */
 
@@ -740,20 +737,20 @@ static int udp_push_pending_frames(struct sock *sk)
 
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
 
-		udp4_hwcsum_outgoing(sk, skb, fl->fl4_src, fl->fl4_dst, up->len);
+		udp4_hwcsum(skb, rt->rt_src, daddr);
 		goto send;
 
-	} else						 /*   `normal' UDP    */
-		csum = udp_csum_outgoing(sk, skb);
+	} else
+		csum = udp_csum(skb);
 
 	/* add protocol-dependent pseudo-header */
-	uh->check = csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst, up->len,
+	uh->check = csum_tcpudp_magic(rt->rt_src, daddr, len,
 				      sk->sk_protocol, csum);
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
 send:
-	err = ip_push_pending_frames(sk);
+	err = ip_send_skb(skb);
 	if (err) {
 		if (err == -ENOBUFS && !inet->recverr) {
 			UDP_INC_STATS_USER(sock_net(sk),
@@ -763,6 +760,26 @@ send:
 	} else
 		UDP_INC_STATS_USER(sock_net(sk),
 				   UDP_MIB_OUTDATAGRAMS, is_udplite);
+	return err;
+}
+
+/*
+ * Push out all pending data as one UDP datagram. Socket is locked.
+ */
+static int udp_push_pending_frames(struct sock *sk)
+{
+	struct udp_sock  *up = udp_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
+	struct flowi *fl = &inet->cork.fl;
+	struct sk_buff *skb;
+	int err = 0;
+
+	skb = ip_finish_skb(sk);
+	if (!skb)
+		goto out;
+
+	err = udp_send_skb(skb, fl->fl4_dst, fl->fl_ip_dport);
+
 out:
 	up->len = 0;
 	up->pending = 0;
