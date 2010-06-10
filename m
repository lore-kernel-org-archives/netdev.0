From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] econet: fix locking
Date: Thu, 10 Jun 2010 04:33:05 +0200
Message-ID: <1276137185.2475.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33504 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756284Ab0FJCdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 22:33:11 -0400
Received: by wyb40 with SMTP id 40so649543wyb.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 19:33:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

econet lacks proper locking. It holds econet_lock only when inserting or
deleting an entry in econet_sklist, not during lookups.

- convert econet_lock from rwlock to spinlock

- use econet_lock in ec_listening_socket() lookup

- use appropriate sock_hold() / sock_put() to avoid corruptions.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/econet/af_econet.c |   27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 2a5a805..dc54bd0 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -48,7 +48,7 @@
 
 static const struct proto_ops econet_ops;
 static struct hlist_head econet_sklist;
-static DEFINE_RWLOCK(econet_lock);
+static DEFINE_SPINLOCK(econet_lock);
 static DEFINE_MUTEX(econet_mutex);
 
 /* Since there are only 256 possible network numbers (or fewer, depends
@@ -98,16 +98,16 @@ struct ec_cb
 
 static void econet_remove_socket(struct hlist_head *list, struct sock *sk)
 {
-	write_lock_bh(&econet_lock);
+	spin_lock_bh(&econet_lock);
 	sk_del_node_init(sk);
-	write_unlock_bh(&econet_lock);
+	spin_unlock_bh(&econet_lock);
 }
 
 static void econet_insert_socket(struct hlist_head *list, struct sock *sk)
 {
-	write_lock_bh(&econet_lock);
+	spin_lock_bh(&econet_lock);
 	sk_add_node(sk, list);
-	write_unlock_bh(&econet_lock);
+	spin_unlock_bh(&econet_lock);
 }
 
 /*
@@ -782,15 +782,19 @@ static struct sock *ec_listening_socket(unsigned char port, unsigned char
 	struct sock *sk;
 	struct hlist_node *node;
 
+	spin_lock(&econet_lock);
 	sk_for_each(sk, node, &econet_sklist) {
 		struct econet_sock *opt = ec_sk(sk);
 		if ((opt->port == port || opt->port == 0) &&
 		    (opt->station == station || opt->station == 0) &&
-		    (opt->net == net || opt->net == 0))
+		    (opt->net == net || opt->net == 0)) {
+			sock_hold(sk);
 			goto found;
+		}
 	}
 	sk = NULL;
 found:
+	spin_unlock(&econet_lock);
 	return sk;
 }
 
@@ -852,7 +856,7 @@ static void aun_incoming(struct sk_buff *skb, struct aunhdr *ah, size_t len)
 {
 	struct iphdr *ip = ip_hdr(skb);
 	unsigned char stn = ntohl(ip->saddr) & 0xff;
-	struct sock *sk;
+	struct sock *sk = NULL;
 	struct sk_buff *newskb;
 	struct ec_device *edev = skb->dev->ec_ptr;
 
@@ -882,10 +886,13 @@ static void aun_incoming(struct sk_buff *skb, struct aunhdr *ah, size_t len)
 	}
 
 	aun_send_response(ip->saddr, ah->handle, 3, 0);
+	sock_put(sk);
 	return;
 
 bad:
 	aun_send_response(ip->saddr, ah->handle, 4, 0);
+	if (sk)
+		sock_put(sk);
 }
 
 /*
@@ -1050,7 +1057,7 @@ release:
 static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct ec_framehdr *hdr;
-	struct sock *sk;
+	struct sock *sk = NULL;
 	struct ec_device *edev = dev->ec_ptr;
 
 	if (!net_eq(dev_net(dev), &init_net))
@@ -1085,10 +1092,12 @@ static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	if (ec_queue_packet(sk, skb, edev->net, hdr->src_stn, hdr->cb,
 			    hdr->port))
 		goto drop;
-
+	sock_put(sk);
 	return NET_RX_SUCCESS;
 
 drop:
+	if (sk)
+		sock_put(sk);
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }


