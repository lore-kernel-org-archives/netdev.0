From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] af_packet: Raw socket destruction warning fix
Date: Wed, 10 Feb 2016 17:35:00 +0530
Message-ID: <1455105900-15710-1-git-send-email-maninder1.s@samsung.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ajeet.y@samsung.com, pankaj.m@samsung.com, gh007.kim@samsung.com,
	hakbong5.lee@samsung.com, akhilesh.k@samsung.com,
	Maninder Singh <maninder1.s@samsung.com>,
	Vaneet Narang <v.narang@samsung.com>,
	Amit Nagal <amit.nagal@samsung.com>
To: davem@davemloft.net, willemb@google.com, daniel@iogearbox.net,
	edumazet@google.com, al.drozdov@gmail.com, eyal.birger@gmail.com,
	tklauser@distanz.ch, fruggeri@aristanetworks.com,
	dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:34664 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305AbcBJMG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 07:06:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This Patch fixes below warning:-
WARNING: at net/packet/af_packet.c:xxx packet_sock_destruct

There is following race between packet_rcv and packet_close
which keeps unfree packet in receive queue.

CPU 1					CPU2
packet_rcv

					packet_close                       
skb_set_owner_r(skb, sk);

					skb_queue_purge(&sk->sk_receive_queue);

spin_lock(&sk->sk_receive_queue.lock);
__skb_queue_tail(&sk->sk_receive_queue, skb);
spin_unlock(&sk->sk_receive_queue.lock);

Signed-off-by: Vaneet Narang <v.narang@samsung.com>
Signed-off-by: Amit Nagal <amit.nagal@samsung.com>
Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
---
 net/packet/af_packet.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 992396a..e6047e6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1310,7 +1310,10 @@ static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 
 static void packet_sock_destruct(struct sock *sk)
 {
+	/* Purge queues */
+
 	skb_queue_purge(&sk->sk_error_queue);
+	skb_queue_purge(&sk->sk_receive_queue);
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
@@ -1991,6 +1994,9 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!net_eq(dev_net(dev), sock_net(sk)))
 		goto drop;
 
+	if (sock_flag(sk, SOCK_DEAD))
+		goto drop;
+
 	skb->dev = dev;
 
 	if (dev->header_ops) {
@@ -2053,7 +2059,6 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (pskb_trim(skb, snaplen))
 		goto drop_n_acct;
 
-	skb_set_owner_r(skb, sk);
 	skb->dev = NULL;
 	skb_dst_drop(skb);
 
@@ -2061,6 +2066,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	nf_reset(skb);
 
 	spin_lock(&sk->sk_receive_queue.lock);
+	skb_set_owner_r(skb, sk);
 	po->stats.stats1.tp_packets++;
 	sock_skb_set_dropcount(sk, skb);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
@@ -2899,9 +2905,6 @@ static int packet_release(struct socket *sock)
 	sock_orphan(sk);
 	sock->sk = NULL;
 
-	/* Purge queues */
-
-	skb_queue_purge(&sk->sk_receive_queue);
 	packet_free_pending(po);
 	sk_refcnt_debug_release(sk);
 
-- 
1.7.9.5
