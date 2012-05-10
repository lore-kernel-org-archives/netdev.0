From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/3] tcp: Move rcvq sending to tcp_input.c
Date: Thu, 10 May 2012 15:49:41 +0400
Message-ID: <4FABAB55.5050803@parallels.com>
References: <4FABAB39.6090201@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32425 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759191Ab2EJLtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 07:49:49 -0400
In-Reply-To: <4FABAB39.6090201@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It actually works on the input queue and will use its read mem
routines, thus it's better to have in in the tcp_input.c file.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 include/net/tcp.h    |    3 +--
 net/ipv4/tcp.c       |   33 ---------------------------------
 net/ipv4/tcp_input.c |   35 ++++++++++++++++++++++++++++++++++-
 3 files changed, 35 insertions(+), 36 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 92faa6a..aaf5de9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -432,8 +432,7 @@ extern int tcp_disconnect(struct sock *sk, int flags);
 
 void tcp_connect_init(struct sock *sk);
 void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
-int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb,
-			       int hdrlen, bool *fragstolen);
+int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size);
 
 /* From syncookies.c */
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5654062..86e2cf2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -978,39 +978,6 @@ static inline int select_size(const struct sock *sk, bool sg)
 	return tmp;
 }
 
-static int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
-{
-	struct sk_buff *skb;
-	struct tcphdr *th;
-	bool fragstolen;
-
-	skb = alloc_skb(size + sizeof(*th), sk->sk_allocation);
-	if (!skb)
-		goto err;
-
-	th = (struct tcphdr *)skb_put(skb, sizeof(*th));
-	skb_reset_transport_header(skb);
-	memset(th, 0, sizeof(*th));
-
-	if (memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size))
-		goto err_free;
-
-	TCP_SKB_CB(skb)->seq = tcp_sk(sk)->rcv_nxt;
-	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + size;
-	TCP_SKB_CB(skb)->ack_seq = tcp_sk(sk)->snd_una - 1;
-
-	if (tcp_queue_rcv(sk, skb, sizeof(*th), &fragstolen)) {
-		WARN_ON_ONCE(fragstolen); /* should not happen */
-		__kfree_skb(skb);
-	}
-	return size;
-
-err_free:
-	kfree_skb(skb);
-err:
-	return -ENOMEM;
-}
-
 int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t size)
 {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eb58b94..7c6c99d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4746,7 +4746,7 @@ end:
 		skb_set_owner_r(skb, sk);
 }
 
-int tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int hdrlen,
+static int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int hdrlen,
 		  bool *fragstolen)
 {
 	int eaten;
@@ -4763,6 +4763,39 @@ int tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int hdrlen,
 	return eaten;
 }
 
+int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
+{
+	struct sk_buff *skb;
+	struct tcphdr *th;
+	bool fragstolen;
+
+	skb = alloc_skb(size + sizeof(*th), sk->sk_allocation);
+	if (!skb)
+		goto err;
+
+	th = (struct tcphdr *)skb_put(skb, sizeof(*th));
+	skb_reset_transport_header(skb);
+	memset(th, 0, sizeof(*th));
+
+	if (memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size))
+		goto err_free;
+
+	TCP_SKB_CB(skb)->seq = tcp_sk(sk)->rcv_nxt;
+	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + size;
+	TCP_SKB_CB(skb)->ack_seq = tcp_sk(sk)->snd_una - 1;
+
+	if (tcp_queue_rcv(sk, skb, sizeof(*th), &fragstolen)) {
+		WARN_ON_ONCE(fragstolen); /* should not happen */
+		__kfree_skb(skb);
+	}
+	return size;
+
+err_free:
+	kfree_skb(skb);
+err:
+	return -ENOMEM;
+}
+
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
-- 
1.5.5.6
