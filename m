From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/5] udp: Add lockless transmit path
Date: Mon, 28 Feb 2011 19:41:01 +0800
Message-ID: <E1Pu1TJ-0005RA-DV@gondolin.me.apana.org.au>
References: <20110227110614.GA6246@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57502 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583Ab1B1LlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 06:41:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp: Add lockless transmit path

The UDP transmit path has been running under the socket lock
for a long time because of the corking feature.  This means that
transmitting to the same socket in multiple threads does not
scale at all.

However, as most users don't actually use corking, the locking
can be removed in the common case.

This patch creates a lockless fast path where corking is not used.

Please note that this does create a slight inaccuracy in the
enforcement of socket send buffer limits.  In particular, we
may exceed the socket limit by up to (number of CPUs) * (packet
size) because of the way the limit is computed.

As the primary purpose of socket buffers is to indicate congestion,
this should not be a great problem for now.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/udp.h     |   11 +++++
 include/net/udplite.h |   12 +++++
 net/ipv4/udp.c        |  104 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 126 insertions(+), 1 deletion(-)

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
index 8157b17..7fd3664 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -769,6 +769,95 @@ out:
 	return err;
 }
 
+static void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
+{
+	struct udphdr *uh = udp_hdr(skb);
+	struct sk_buff *frags = skb_shinfo(skb)->frag_list;
+	int offset = skb_transport_offset(skb);
+	int len = skb->len - offset;
+	int hlen = len;
+	__wsum csum = 0;
+
+	if (!frags) {
+		/*
+		 * Only one fragment on the socket.
+		 */
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_tcpudp_magic(src, dst, len,
+					       IPPROTO_UDP, 0);
+	} else {
+		/*
+		 * HW-checksum won't work as there are two or more
+		 * fragments on the socket so that all csums of sk_buffs
+		 * should be together
+		 */
+		do {
+			csum = csum_add(csum, frags->csum);
+			hlen -= frags->len;
+		} while ((frags = frags->next));
+
+		csum = skb_checksum(skb, offset, hlen, csum);
+		skb->ip_summed = CHECKSUM_NONE;
+
+		uh->check = csum_tcpudp_magic(src, dst, len, IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	}
+}
+
+static int udp_send_skb(struct sk_buff *skb, __be32 daddr, __be32 dport)
+{
+	struct sock *sk = skb->sk;
+	struct inet_sock *inet = inet_sk(sk);
+	struct udphdr *uh;
+	struct rtable *rt = (struct rtable *)skb_dst(skb);
+	int err = 0;
+	int is_udplite = IS_UDPLITE(sk);
+	int offset = skb_transport_offset(skb);
+	int len = skb->len - offset;
+	__wsum csum = 0;
+
+	/*
+	 * Create a UDP header
+	 */
+	uh = udp_hdr(skb);
+	uh->source = inet->inet_sport;
+	uh->dest = dport;
+	uh->len = htons(len);
+	uh->check = 0;
+
+	if (is_udplite)
+		csum = udplite_csum(skb);
+	else if (sk->sk_no_check == UDP_CSUM_NOXMIT) {
+		skb->ip_summed = CHECKSUM_NONE;
+		goto send;
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		udp4_hwcsum(skb, rt->rt_src, daddr);
+		goto send;
+	} else
+		csum = udp_csum(skb);
+
+	/* add protocol-dependent pseudo-header */
+	uh->check = csum_tcpudp_magic(rt->rt_src, daddr, len,
+				      sk->sk_protocol, csum);
+	if (uh->check == 0)
+		uh->check = CSUM_MANGLED_0;
+
+send:
+	err = ip_send_skb(skb);
+	if (err) {
+		if (err == -ENOBUFS && !inet->recverr) {
+			UDP_INC_STATS_USER(sock_net(sk),
+					   UDP_MIB_SNDBUFERRORS, is_udplite);
+			err = 0;
+		}
+	} else
+		UDP_INC_STATS_USER(sock_net(sk),
+				   UDP_MIB_OUTDATAGRAMS, is_udplite);
+	return err;
+}
+
 int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len)
 {
@@ -785,6 +874,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	int err, is_udplite = IS_UDPLITE(sk);
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
+	struct sk_buff *skb;
 
 	if (len > 0xFFFF)
 		return -EMSGSIZE;
@@ -799,6 +889,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
 
+	getfrag = is_udplite ? udplite_getfrag : ip_generic_getfrag;
+
 	if (up->pending) {
 		/*
 		 * There are pending frames.
@@ -923,6 +1015,17 @@ back_from_confirm:
 	if (!ipc.addr)
 		daddr = ipc.addr = rt->rt_dst;
 
+	/* Lockless fast path for the non-corking case. */
+	if (!corkreq) {
+		skb = ip_make_skb(sk, getfrag, msg->msg_iov, ulen,
+				  sizeof(struct udphdr), &ipc, &rt,
+				  msg->msg_flags);
+		err = PTR_ERR(skb);
+		if (skb && !IS_ERR(skb))
+			err = udp_send_skb(skb, daddr, dport);
+		goto out;
+	}
+
 	lock_sock(sk);
 	if (unlikely(up->pending)) {
 		/* The socket is already corked while preparing it. */
@@ -944,7 +1047,6 @@ back_from_confirm:
 
 do_append_data:
 	up->len += ulen;
-	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip_append_data(sk, getfrag, msg->msg_iov, ulen,
 			sizeof(struct udphdr), &ipc, &rt,
 			corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
