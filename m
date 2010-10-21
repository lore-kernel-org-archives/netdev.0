From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2 v3] xps: Improvements in TX queue selection
Date: Thu, 21 Oct 2010 13:17:08 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010211303390.30535@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:2593 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755940Ab0JUURN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 16:17:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dev_pick_tx, don't do work in calculating queue index or setting
the index in the sock unless the device has more than one queue.  This
allows the sock to be set only with a queue index of a multi-queue
device which is desirable if device are stacked like in a tunnel.

We also allow the mapping of a socket to queue to be changed.  To
maintain in order packet transmission a flag (ooo_okay) has been
added to the sk_buff structure.  If a transport layer sets this flag
on a packet, the transmit queue can be changed for the socket.
Presumably, the transport would set this if there was no possbility
of creating OOO packets (for instance, there are no packets in flight
for the socket).  This patch includes the modification in TCP output
for setting this flag.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h |    3 ++-
 net/core/dev.c         |   24 ++++++++++++++----------
 net/ipv4/tcp_output.c  |    4 +++-
 3 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e6ba898..19f37a6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -386,9 +386,10 @@ struct sk_buff {
 #else
 	__u8			deliver_no_wcard:1;
 #endif
+	__u8			ooo_okay:1;
 	kmemcheck_bitfield_end(flags2);
 
-	/* 0/14 bit hole */
+	/* 0/13 bit hole */
 
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
diff --git a/net/core/dev.c b/net/core/dev.c
index b2269ac..a538ed5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2123,28 +2123,32 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
 	int queue_index;
-	const struct net_device_ops *ops = dev->netdev_ops;
 
-	if (ops->ndo_select_queue) {
-		queue_index = ops->ndo_select_queue(dev, skb);
-		queue_index = dev_cap_txqueue(dev, queue_index);
-	} else {
+	if (dev->real_num_tx_queues > 1) {
 		struct sock *sk = skb->sk;
+
 		queue_index = sk_tx_queue_get(sk);
-		if (queue_index < 0) {
 
-			queue_index = 0;
-			if (dev->real_num_tx_queues > 1)
+		if (queue_index < 0 || skb->ooo_okay ||
+		    queue_index >= dev->real_num_tx_queues) {
+			const struct net_device_ops *ops = dev->netdev_ops;
+			int old_index = queue_index;
+
+			if (ops->ndo_select_queue) {
+				queue_index = ops->ndo_select_queue(dev, skb);
+				queue_index = dev_cap_txqueue(dev, queue_index);
+			} else
 				queue_index = skb_tx_hash(dev, skb);
 
-			if (sk) {
+			if (queue_index != old_index && sk) {
 				struct dst_entry *dst = rcu_dereference_check(sk->sk_dst_cache, 1);
 
 				if (dst && skb_dst(skb) == dst)
 					sk_tx_queue_set(sk, queue_index);
 			}
 		}
-	}
+	} else
+		queue_index = 0;
 
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 05b1ecf..67b9c9e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -822,8 +822,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 							   &md5);
 	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
 
-	if (tcp_packets_in_flight(tp) == 0)
+	if (tcp_packets_in_flight(tp) == 0) {
 		tcp_ca_event(sk, CA_EVENT_TX_START);
+		skb->ooo_okay = 1;
+	}
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
-- 
1.7.1

