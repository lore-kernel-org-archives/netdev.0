From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: add __rcu annotation to sk_filter
Date: Mon, 25 Oct 2010 15:47:05 +0200
Message-ID: <1288014425.2826.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48771 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab0JYNrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 09:47:10 -0400
Received: by wwe15 with SMTP id 15so3507504wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 06:47:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __rcu annotation to :
        (struct sock)->sk_filter

And use appropriate rcu primitives to reduce sparse warnings if
CONFIG_SPARSE_RCU_POINTER=y

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |    2 +-
 net/core/filter.c  |    4 ++--
 net/core/sock.c    |    2 +-
 net/ipv4/udp.c     |    2 +-
 net/ipv6/raw.c     |    2 +-
 net/ipv6/udp.c     |    2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 73a4f97..c7a7362 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -301,7 +301,7 @@ struct sock {
 	const struct cred	*sk_peer_cred;
 	long			sk_rcvtimeo;
 	long			sk_sndtimeo;
-	struct sk_filter      	*sk_filter;
+	struct sk_filter __rcu	*sk_filter;
 	void			*sk_protinfo;
 	struct timer_list	sk_timer;
 	ktime_t			sk_stamp;
diff --git a/net/core/filter.c b/net/core/filter.c
index 7adf503..7beaec3 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -89,8 +89,8 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 	rcu_read_lock_bh();
 	filter = rcu_dereference_bh(sk->sk_filter);
 	if (filter) {
-		unsigned int pkt_len = sk_run_filter(skb, filter->insns,
-				filter->len);
+		unsigned int pkt_len = sk_run_filter(skb, filter->insns, filter->len);
+
 		err = pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
 	}
 	rcu_read_unlock_bh();
diff --git a/net/core/sock.c b/net/core/sock.c
index 11db436..3eed542 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1225,7 +1225,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		sock_reset_flag(newsk, SOCK_DONE);
 		skb_queue_head_init(&newsk->sk_error_queue);
 
-		filter = newsk->sk_filter;
+		filter = rcu_dereference_protected(newsk->sk_filter, 1);
 		if (filter != NULL)
 			sk_filter_charge(newsk, filter);
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b3f7e8c..28cb2d7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1413,7 +1413,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	if (sk->sk_filter) {
+	if (rcu_dereference_raw(sk->sk_filter)) {
 		if (udp_lib_checksum_complete(skb))
 			goto drop;
 	}
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 45e6efb..86c3952 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -373,7 +373,7 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 
 static inline int rawv6_rcv_skb(struct sock * sk, struct sk_buff * skb)
 {
-	if ((raw6_sk(sk)->checksum || sk->sk_filter) &&
+	if ((raw6_sk(sk)->checksum || rcu_dereference_raw(sk->sk_filter)) &&
 	    skb_checksum_complete(skb)) {
 		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c84dad4..91def93 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -527,7 +527,7 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 		}
 	}
 
-	if (sk->sk_filter) {
+	if (rcu_dereference_raw(sk->sk_filter)) {
 		if (udp_lib_checksum_complete(skb))
 			goto drop;
 	}


