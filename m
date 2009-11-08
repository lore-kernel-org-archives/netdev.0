From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/8] udp: add a counter into udp_hslot
Date: Sun, 08 Nov 2009 21:17:05 +0100
Message-ID: <4AF72741.5070405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39127 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120AbZKHURJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 15:17:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a counter in udp_hslot to keep an accurate count
of sockets present in chain.

This will permit to upcoming UDP lookup algo to chose
the shortest chain when secondary hash is added.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/udp.h |    8 ++++++++
 net/ipv4/udp.c    |    3 +++
 2 files changed, 11 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index 22aa2e7..9167281 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -50,8 +50,16 @@ struct udp_skb_cb {
 };
 #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
 
+/**
+ *	struct udp_hslot - UDP hash slot
+ *
+ *	@head:	head of list of sockets
+ *	@count:	number of sockets in 'head' list
+ *	@lock:	spinlock protecting changes to head/count
+ */
 struct udp_hslot {
 	struct hlist_nulls_head	head;
+	int			count;
 	spinlock_t		lock;
 } __attribute__((aligned(2 * sizeof(long))));
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d5e75e9..ffc8376 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -218,6 +218,7 @@ found:
 	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
 		sk_nulls_add_node_rcu(sk, &hslot->head);
+		hslot->count++;
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	}
 	error = 0;
@@ -1053,6 +1054,7 @@ void udp_lib_unhash(struct sock *sk)
 
 		spin_lock_bh(&hslot->lock);
 		if (sk_nulls_del_node_init_rcu(sk)) {
+			hslot->count--;
 			inet_sk(sk)->inet_num = 0;
 			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 		}
@@ -1862,6 +1864,7 @@ void __init udp_table_init(struct udp_table *table, const char *name)
 	}
 	for (i = 0; i <= table->mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
+		table->hash[i].count = 0;
 		spin_lock_init(&table->hash[i].lock);
 	}
 }
