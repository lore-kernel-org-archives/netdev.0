From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/5] udp: Add lockless transmit path
Date: Tue, 01 Mar 2011 20:36:48 +0800
Message-ID: <E1PuOoq-0001yJ-Ax@gondolin.me.apana.org.au>
References: <20110301123519.GA7453@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:46084 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754777Ab1CAMhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 07:37:00 -0500
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

 net/ipv4/udp.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9a6d326..bb9f707 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -802,6 +802,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	int err, is_udplite = IS_UDPLITE(sk);
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
+	struct sk_buff *skb;
 
 	if (len > 0xFFFF)
 		return -EMSGSIZE;
@@ -816,6 +817,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
 
+	getfrag = is_udplite ? udplite_getfrag : ip_generic_getfrag;
+
 	if (up->pending) {
 		/*
 		 * There are pending frames.
@@ -940,6 +943,17 @@ back_from_confirm:
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
@@ -961,7 +975,6 @@ back_from_confirm:
 
 do_append_data:
 	up->len += ulen;
-	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip_append_data(sk, getfrag, msg->msg_iov, ulen,
 			sizeof(struct udphdr), &ipc, &rt,
 			corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
