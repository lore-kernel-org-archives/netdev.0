From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 2/3] udp: remove headers from UDP packets before queueing
Date: Tue,  5 Apr 2016 12:41:15 -0400
Message-ID: <1459874476-92838-3-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1459874476-92838-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, samanthakumar@google.com, edumazet@google.com,
	willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:35483 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758109AbcDEQlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 12:41:23 -0400
Received: by mail-qg0-f67.google.com with SMTP id b32so1717282qgf.2
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 09:41:23 -0700 (PDT)
In-Reply-To: <1459874476-92838-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: samanthakumar <samanthakumar@google.com>

Remove UDP transport headers before queueing packets for reception.
This change simplifies a follow-up patch to add MSG_PEEK support.

Signed-off-by: Sam Kumar <samanthakumar@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h |  1 +
 include/net/udp.h  |  9 +++++++++
 net/core/sock.c    | 19 +++++++++++++------
 net/ipv4/udp.c     | 20 +++++++++++---------
 net/ipv6/udp.c     | 12 +++++++-----
 5 files changed, 41 insertions(+), 20 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 09aec75..b759989 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1864,6 +1864,7 @@ void sk_reset_timer(struct sock *sk, struct timer_list *timer,
 
 void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 
+int __sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 
 int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb);
diff --git a/include/net/udp.h b/include/net/udp.h
index d870ec1..a0b0da9 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -158,6 +158,15 @@ static inline __sum16 udp_v4_check(int len, __be32 saddr,
 void udp_set_csum(bool nocheck, struct sk_buff *skb,
 		  __be32 saddr, __be32 daddr, int len);
 
+static inline void udp_csum_pull_header(struct sk_buff *skb)
+{
+	if (skb->ip_summed == CHECKSUM_NONE)
+		skb->csum = csum_partial(udp_hdr(skb), sizeof(struct udphdr),
+					 skb->csum);
+	skb_pull_rcsum(skb, sizeof(struct udphdr));
+	UDP_SKB_CB(skb)->cscov -= sizeof(struct udphdr);
+}
+
 struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 				 struct udphdr *uh);
 int udp_gro_complete(struct sk_buff *skb, int nhoff);
diff --git a/net/core/sock.c b/net/core/sock.c
index 2f517ea..e12197b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -402,9 +402,8 @@ static void sock_disable_timestamp(struct sock *sk, unsigned long flags)
 }
 
 
-int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+int __sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
-	int err;
 	unsigned long flags;
 	struct sk_buff_head *list = &sk->sk_receive_queue;
 
@@ -414,10 +413,6 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		return -ENOMEM;
 	}
 
-	err = sk_filter(sk, skb);
-	if (err)
-		return err;
-
 	if (!sk_rmem_schedule(sk, skb, skb->truesize)) {
 		atomic_inc(&sk->sk_drops);
 		return -ENOBUFS;
@@ -440,6 +435,18 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk->sk_data_ready(sk);
 	return 0;
 }
+EXPORT_SYMBOL(__sock_queue_rcv_skb);
+
+int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	int err;
+
+	err = sk_filter(sk, skb);
+	if (err)
+		return err;
+
+	return __sock_queue_rcv_skb(sk, skb);
+}
 EXPORT_SYMBOL(sock_queue_rcv_skb);
 
 int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 355bdb2..cf747e8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1309,7 +1309,7 @@ try_again:
 	if (!skb)
 		goto out;
 
-	ulen = skb->len - sizeof(struct udphdr);
+	ulen = skb->len;
 	copied = len;
 	if (copied > ulen)
 		copied = ulen;
@@ -1329,11 +1329,9 @@ try_again:
 	}
 
 	if (checksum_valid || skb_csum_unnecessary(skb))
-		err = skb_copy_datagram_msg(skb, sizeof(struct udphdr),
-					    msg, copied);
+		err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	else {
-		err = skb_copy_and_csum_datagram_msg(skb, sizeof(struct udphdr),
-						     msg);
+		err = skb_copy_and_csum_datagram_msg(skb, 0, msg);
 
 		if (err == -EINVAL)
 			goto csum_copy_err;
@@ -1500,7 +1498,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_incoming_cpu_update(sk);
 	}
 
-	rc = sock_queue_rcv_skb(sk, skb);
+	rc = __sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
 
@@ -1616,10 +1614,14 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	if (rcu_access_pointer(sk->sk_filter) &&
-	    udp_lib_checksum_complete(skb))
-		goto csum_error;
+	if (rcu_access_pointer(sk->sk_filter)) {
+		if (udp_lib_checksum_complete(skb))
+			goto csum_error;
+		if (sk_filter(sk, skb))
+			goto drop;
+	}
 
+	udp_csum_pull_header(skb);
 	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
 		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
 				 is_udplite);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 78a7dfd..84c8d7b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -376,7 +376,7 @@ try_again:
 	if (!skb)
 		goto out;
 
-	ulen = skb->len - sizeof(struct udphdr);
+	ulen = skb->len;
 	copied = len;
 	if (copied > ulen)
 		copied = ulen;
@@ -398,10 +398,9 @@ try_again:
 	}
 
 	if (checksum_valid || skb_csum_unnecessary(skb))
-		err = skb_copy_datagram_msg(skb, sizeof(struct udphdr),
-					    msg, copied);
+		err = skb_copy_datagram_msg(skb, 0, msg, copied);
 	else {
-		err = skb_copy_and_csum_datagram_msg(skb, sizeof(struct udphdr), msg);
+		err = skb_copy_and_csum_datagram_msg(skb, 0, msg);
 		if (err == -EINVAL)
 			goto csum_copy_err;
 	}
@@ -554,7 +553,7 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_incoming_cpu_update(sk);
 	}
 
-	rc = sock_queue_rcv_skb(sk, skb);
+	rc = __sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
 
@@ -648,8 +647,11 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (rcu_access_pointer(sk->sk_filter)) {
 		if (udp_lib_checksum_complete(skb))
 			goto csum_error;
+		if (sk_filter(sk, skb))
+			goto drop;
 	}
 
+	udp_csum_pull_header(skb);
 	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
 		UDP6_INC_STATS_BH(sock_net(sk),
 				  UDP_MIB_RCVBUFERRORS, is_udplite);
-- 
2.8.0.rc3.226.g39d4020
