From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: sk_drops consolidation
Date: Thu, 15 Oct 2009 04:47:40 +0200
Message-ID: <4AD68D4C.2080108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56421 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932375AbZJOCsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 22:48:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_queue_rcv_skb() can update sk_drops itself, removing need for
callers to take care of it. This is more consistent since
sock_queue_rcv_skb() also reads sk_drops when queueing a skb.

This adds sk_drops managment to many protocols that not cared yet.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/sock.c        |   15 +++++++--------
 net/ieee802154/dgram.c |    1 -
 net/ieee802154/raw.c   |    1 -
 net/ipv4/raw.c         |    1 -
 net/ipv4/udp.c         |   19 ++++++++-----------
 net/ipv6/raw.c         |    3 +--
 net/ipv6/udp.c         |    6 ++----
 net/phonet/datagram.c  |    6 ++----
 net/phonet/pep.c       |    2 --
 9 files changed, 20 insertions(+), 34 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 43ca2c9..38713aa 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -274,7 +274,7 @@ static void sock_disable_timestamp(struct sock *sk, int flag)
 
 int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
-	int err = 0;
+	int err;
 	int skb_len;
 	unsigned long flags;
 	struct sk_buff_head *list = &sk->sk_receive_queue;
@@ -284,17 +284,17 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	 */
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 	    (unsigned)sk->sk_rcvbuf) {
-		err = -ENOMEM;
-		goto out;
+		atomic_inc(&sk->sk_drops);
+		return -ENOMEM;
 	}
 
 	err = sk_filter(sk, skb);
 	if (err)
-		goto out;
+		return err;
 
 	if (!sk_rmem_schedule(sk, skb->truesize)) {
-		err = -ENOBUFS;
-		goto out;
+		atomic_inc(&sk->sk_drops);
+		return -ENOBUFS;
 	}
 
 	skb->dev = NULL;
@@ -314,8 +314,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_data_ready(sk, skb_len);
-out:
-	return err;
+	return 0;
 }
 EXPORT_SYMBOL(sock_queue_rcv_skb);
 
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 25ad956..9aac5ae 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -318,7 +318,6 @@ out:
 static int dgram_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
-		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 769c8d1..9c9b85c 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -206,7 +206,6 @@ out:
 static int raw_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
-		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index f18172b..39e2a6b 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -292,7 +292,6 @@ static int raw_rcv_skb(struct sock * sk, struct sk_buff * skb)
 	/* Charge it to the socket. */
 
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
-		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ee61b3f..45a8a7e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1063,25 +1063,22 @@ EXPORT_SYMBOL(udp_lib_unhash);
 
 static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
-	int is_udplite = IS_UDPLITE(sk);
-	int rc;
+	int rc = sock_queue_rcv_skb(sk, skb);
+
+	if (rc < 0) {
+		int is_udplite = IS_UDPLITE(sk);
 
-	if ((rc = sock_queue_rcv_skb(sk, skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
-		if (rc == -ENOMEM) {
+		if (rc == -ENOMEM)
 			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
 					 is_udplite);
-			atomic_inc(&sk->sk_drops);
-		}
-		goto drop;
+		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+		kfree_skb(skb);
+		return -1;
 	}
 
 	return 0;
 
-drop:
-	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
-	kfree_skb(skb);
-	return -1;
 }
 
 /* returns:
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d8375bc..fd737ef 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -381,8 +381,7 @@ static inline int rawv6_rcv_skb(struct sock * sk, struct sk_buff * skb)
 	}
 
 	/* Charge it to the socket. */
-	if (sock_queue_rcv_skb(sk,skb)<0) {
-		atomic_inc(&sk->sk_drops);
+	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1f8e2af..b86425b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -385,13 +385,11 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 			goto drop;
 	}
 
-	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
+	if ((rc = sock_queue_rcv_skb(sk, skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
-		if (rc == -ENOMEM) {
+		if (rc == -ENOMEM)
 			UDP6_INC_STATS_BH(sock_net(sk),
 					UDP_MIB_RCVBUFERRORS, is_udplite);
-			atomic_inc(&sk->sk_drops);
-		}
 		goto drop;
 	}
 
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index ef5c75c..67f072e 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -159,11 +159,9 @@ out_nofree:
 static int pn_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	int err = sock_queue_rcv_skb(sk, skb);
-	if (err < 0) {
+
+	if (err < 0)
 		kfree_skb(skb);
-		if (err == -ENOMEM)
-			atomic_inc(&sk->sk_drops);
-	}
 	return err ? NET_RX_DROP : NET_RX_SUCCESS;
 }
 
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 5f32d21..cbaa1d6 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -360,8 +360,6 @@ static int pipe_do_rcv(struct sock *sk, struct sk_buff *skb)
 			err = sock_queue_rcv_skb(sk, skb);
 			if (!err)
 				return 0;
-			if (err == -ENOMEM)
-				atomic_inc(&sk->sk_drops);
 			break;
 		}
 
