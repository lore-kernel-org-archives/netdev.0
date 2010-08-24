From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH RFC] net: save RX queue number in sock for dev_pick_tx() use
Date: Tue, 24 Aug 2010 17:01:59 +0800
Message-ID: <1282640519-15541-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:40789 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220Ab0HXJCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 05:02:55 -0400
Received: by pxi10 with SMTP id 10so2576618pxi.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 02:02:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the packets sent out from a local server socket, we can use the queue
from which the packets from the client socket are received.

It may help on a TCP or UDP server. Because I don't have a multiqueue NIC,
I don't even test it.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/net/sock.h  |   18 ++++++++++++++++++
 net/core/dev.c      |   25 ++++++++++++++++++-------
 net/ipv4/tcp_ipv4.c |    5 ++++-
 net/ipv4/udp.c      |    4 +++-
 4 files changed, 43 insertions(+), 9 deletions(-)
diff --git a/include/net/sock.h b/include/net/sock.h
index 100e43b..4e5f2f4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1231,6 +1231,24 @@ static inline int sk_tx_queue_get(const struct sock *sk)
 	return sk ? sk->sk_tx_queue_mapping : -1;
 }
 
+static inline void sk_rx_queue_save(struct sock *sk, struct sk_buff *skb)
+{
+	struct dst_entry *dst;
+	int rxqueue;
+
+	if (!skb_rx_queue_recorded(skb))
+		return;
+	rcu_read_lock();
+	dst = rcu_dereference_check(sk->sk_dst_cache, 1);
+	if (dst && !dst->dev->netdev_ops->ndo_select_queue &&
+	    dst->dev == skb->dev) {
+		rxqueue = skb_get_rx_queue(skb);
+		if (rxqueue != sk_tx_queue_get(sk))
+			sk_tx_queue_set(sk, rxqueue);
+	}
+	rcu_read_unlock();
+}
+
 static inline void sk_set_socket(struct sock *sk, struct socket *sock)
 {
 	sk_tx_queue_clear(sk);
diff --git a/net/core/dev.c b/net/core/dev.c
index 859e30f..8dc1904 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2054,6 +2054,18 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 	return queue_index;
 }
 
+static inline void dev_save_tx_queue(struct sk_buff *skb, struct sock *sk,
+				     int queue_index)
+{
+	if (sk) {
+		struct dst_entry *dst;
+
+		dst = rcu_dereference_check(sk->sk_dst_cache, 1);
+		if (dst && skb_dst(skb) == dst)
+			sk_tx_queue_set(sk, queue_index);
+	}
+}
+
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
@@ -2071,14 +2083,13 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 			queue_index = 0;
 			if (dev->real_num_tx_queues > 1)
 				queue_index = skb_tx_hash(dev, skb);
-
-			if (sk) {
-				struct dst_entry *dst = rcu_dereference_check(sk->sk_dst_cache, 1);
-
-				if (dst && skb_dst(skb) == dst)
-					sk_tx_queue_set(sk, queue_index);
-			}
+			dev_save_tx_queue(skb, sk, queue_index);
 		}
+	} else if (unlikely(queue_index >= dev->real_num_tx_queues)) {
+		do {
+			queue_index -= dev->real_num_tx_queues;
+		} while (unlikely(queue_index >= dev->real_num_tx_queues));
+		dev_save_tx_queue(skb, sk, queue_index);
 	}
 
 	skb_set_queue_mapping(skb, queue_index);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0207662..b1c6d3c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1560,6 +1560,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		sock_rps_save_rxhash(sk, skb->rxhash);
+		sk_rx_queue_save(sk, skb);
 		TCP_CHECK_TIMER(sk);
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
@@ -1584,8 +1585,10 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 			}
 			return 0;
 		}
-	} else
+	} else {
 		sock_rps_save_rxhash(sk, skb->rxhash);
+		sk_rx_queue_save(sk, skb);
+	}
 
 
 	TCP_CHECK_TIMER(sk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 86e757e..e59f3db 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1264,8 +1264,10 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 
-	if (inet_sk(sk)->inet_daddr)
+	if (inet_sk(sk)->inet_daddr) {
 		sock_rps_save_rxhash(sk, skb->rxhash);
+		sk_rx_queue_save(sk, skb);
+	}
 
 	rc = ip_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
