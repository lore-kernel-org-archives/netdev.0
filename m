From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: sk_drops consolidation part 2
Date: Thu, 15 Oct 2009 12:12:40 +0200
Message-ID: <4AD6F598.4080007@gmail.com>
References: <4AD68D4C.2080108@gmail.com> <20091014.204021.97690983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57459 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755260AbZJOKNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 06:13:19 -0400
In-Reply-To: <20091014.204021.97690983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- skb_kill_datagram() can increment sk->sk_drops itself, not callers.

- UDP on IPV4 & IPV6 dropped frames (because of bad checksum or policy checks) increment sk_drops

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/datagram.c |    1 +
 net/ipv4/udp.c      |    2 ++
 net/ipv6/raw.c      |    1 -
 net/ipv6/udp.c      |    4 +++-
 4 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 1c6cf3a..4d57f5e 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -262,6 +262,7 @@ int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
 	}
 
 	kfree_skb(skb);
+	atomic_inc(&sk->sk_drops);
 	sk_mem_reclaim_partial(sk);
 
 	return err;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 45a8a7e..696e8c1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -866,6 +866,7 @@ static unsigned int first_packet_length(struct sock *sk)
 		udp_lib_checksum_complete(skb)) {
 		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
 				 IS_UDPLITE(sk));
+		atomic_inc(&sk->sk_drops);
 		__skb_unlink(skb, rcvq);
 		__skb_queue_tail(&list_kill, skb);
 	}
@@ -1185,6 +1186,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 drop:
 	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+	atomic_inc(&sk->sk_drops);
 	kfree_skb(skb);
 	return -1;
 }
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fd737ef..2f3f030 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -517,7 +517,6 @@ csum_copy_err:
 	   as some normal condition.
 	 */
 	err = (flags&MSG_DONTWAIT) ? -EAGAIN : -EHOSTUNREACH;
-	atomic_inc(&sk->sk_drops);
 	goto out;
 }
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b86425b..00c2da4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -390,11 +390,13 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 		if (rc == -ENOMEM)
 			UDP6_INC_STATS_BH(sock_net(sk),
 					UDP_MIB_RCVBUFERRORS, is_udplite);
-		goto drop;
+		goto drop_no_sk_drops_inc;
 	}
 
 	return 0;
 drop:
+	atomic_inc(&sk->sk_drops);
+drop_no_sk_drops_inc:
 	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return -1;
