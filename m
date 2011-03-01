From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/5] inet: Add ip_make_skb and ip_finish_skb
Date: Tue, 01 Mar 2011 20:36:47 +0800
Message-ID: <E1PuOop-0001xr-Py@gondolin.me.apana.org.au>
References: <20110301123519.GA7453@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:53465 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755041Ab1CAMhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 07:37:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet: Add ip_make_skb and ip_finish_skb

This patch adds the helper ip_make_skb which is like ip_append_data
and ip_push_pending_frames all rolled into one, except that it does
not send the skb produced.  The sending part is carried out by
ip_send_skb, which the transport protocol can call after it has
tweaked the skb.

It is meant to be called in cases where corking is not used should
have a one-to-one correspondence to sendmsg.

This patch also adds the helper ip_finish_skb which is meant to
be replace ip_push_pending_frames when corking is required.
Previously the protocol stack would peek at the socket write
queue and add its header to the first packet.  With ip_finish_skb,
the protocol stack can directly operate on the final skb instead,
just like the non-corking case with ip_make_skb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/ip.h     |   16 ++++++++++++
 net/ipv4/ip_output.c |   65 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 67 insertions(+), 14 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 67fac78..a4f6311 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -116,8 +116,24 @@ extern int		ip_append_data(struct sock *sk,
 extern int		ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb);
 extern ssize_t		ip_append_page(struct sock *sk, struct page *page,
 				int offset, size_t size, int flags);
+extern struct sk_buff  *__ip_make_skb(struct sock *sk,
+				      struct sk_buff_head *queue,
+				      struct inet_cork *cork);
+extern int		ip_send_skb(struct sk_buff *skb);
 extern int		ip_push_pending_frames(struct sock *sk);
 extern void		ip_flush_pending_frames(struct sock *sk);
+extern struct sk_buff  *ip_make_skb(struct sock *sk,
+				    int getfrag(void *from, char *to, int offset, int len,
+						int odd, struct sk_buff *skb),
+				    void *from, int length, int transhdrlen,
+				    struct ipcm_cookie *ipc,
+				    struct rtable **rtp,
+				    unsigned int flags);
+
+static inline struct sk_buff *ip_finish_skb(struct sock *sk)
+{
+	return __ip_make_skb(sk, &sk->sk_write_queue, &inet_sk(sk)->cork);
+}
 
 /* datagram.c */
 extern int		ip4_datagram_connect(struct sock *sk, 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1dd5ecc..460308c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1267,9 +1267,9 @@ static void ip_cork_release(struct inet_cork *cork)
  *	Combined all pending IP fragments on the socket as one IP datagram
  *	and push them out.
  */
-static int __ip_push_pending_frames(struct sock *sk,
-				    struct sk_buff_head *queue,
-				    struct inet_cork *cork)
+struct sk_buff *__ip_make_skb(struct sock *sk,
+			      struct sk_buff_head *queue,
+			      struct inet_cork *cork)
 {
 	struct sk_buff *skb, *tmp_skb;
 	struct sk_buff **tail_skb;
@@ -1280,7 +1280,6 @@ static int __ip_push_pending_frames(struct sock *sk,
 	struct iphdr *iph;
 	__be16 df = 0;
 	__u8 ttl;
-	int err = 0;
 
 	if ((skb = __skb_dequeue(queue)) == NULL)
 		goto out;
@@ -1351,28 +1350,37 @@ static int __ip_push_pending_frames(struct sock *sk,
 		icmp_out_count(net, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
-	/* Netfilter gets whole the not fragmented skb. */
+	ip_cork_release(cork);
+out:
+	return skb;
+}
+
+int ip_send_skb(struct sk_buff *skb)
+{
+	struct net *net = sock_net(skb->sk);
+	int err;
+
 	err = ip_local_out(skb);
 	if (err) {
 		if (err > 0)
 			err = net_xmit_errno(err);
 		if (err)
-			goto error;
+			IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
 	}
 
-out:
-	ip_cork_release(cork);
 	return err;
-
-error:
-	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
-	goto out;
 }
 
 int ip_push_pending_frames(struct sock *sk)
 {
-	return __ip_push_pending_frames(sk, &sk->sk_write_queue,
-					&inet_sk(sk)->cork);
+	struct sk_buff *skb;
+
+	skb = ip_finish_skb(sk);
+	if (!skb)
+		return 0;
+
+	/* Netfilter gets whole the not fragmented skb. */
+	return ip_send_skb(skb);
 }
 
 /*
@@ -1395,6 +1403,35 @@ void ip_flush_pending_frames(struct sock *sk)
 	__ip_flush_pending_frames(sk, &sk->sk_write_queue, &inet_sk(sk)->cork);
 }
 
+struct sk_buff *ip_make_skb(struct sock *sk,
+			    int getfrag(void *from, char *to, int offset,
+					int len, int odd, struct sk_buff *skb),
+			    void *from, int length, int transhdrlen,
+			    struct ipcm_cookie *ipc, struct rtable **rtp,
+			    unsigned int flags)
+{
+	struct inet_cork cork = {};
+	struct sk_buff_head queue;
+	int err;
+
+	if (flags & MSG_PROBE)
+		return NULL;
+
+	__skb_queue_head_init(&queue);
+
+	err = ip_setup_cork(sk, &cork, ipc, rtp);
+	if (err)
+		return ERR_PTR(err);
+
+	err = __ip_append_data(sk, &queue, &cork, getfrag,
+			       from, length, transhdrlen, flags);
+	if (err) {
+		__ip_flush_pending_frames(sk, &queue, &cork);
+		return ERR_PTR(err);
+	}
+
+	return __ip_make_skb(sk, &queue, &cork);
+}
 
 /*
  *	Fetch data from kernel space and fill in checksum if needed.
