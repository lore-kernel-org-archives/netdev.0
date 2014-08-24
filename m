From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 3/3] packet: make use of deferred TX queue flushing
Date: Sun, 24 Aug 2014 15:42:18 +0200
Message-ID: <1408887738-7661-4-git-send-email-dborkman@redhat.com>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752694AbaHXNm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2014 09:42:26 -0400
In-Reply-To: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a first use-case of deferred tail pointer flushing
for AF_PACKET's TX_RING in QDISC_BYPASS mode.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/packet/af_packet.c | 49 +++++++++++++++++++++++++++++++++++++------------
 1 file changed, 37 insertions(+), 12 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0dfa990..27457e8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -216,7 +216,8 @@ static void prb_fill_vlan_info(struct tpacket_kbdq_core *,
 static void packet_flush_mclist(struct sock *sk);
 
 struct packet_skb_cb {
-	unsigned int origlen;
+	u32 enforce_flush:1,
+	    origlen:31;
 	union {
 		struct sockaddr_pkt pkt;
 		struct sockaddr_ll ll;
@@ -237,8 +238,11 @@ struct packet_skb_cb {
 static void __fanout_unlink(struct sock *sk, struct packet_sock *po);
 static void __fanout_link(struct sock *sk, struct packet_sock *po);
 
+#define PACKET_FLUSH_THRESH	8
+
 static int packet_direct_xmit(struct sk_buff *skb)
 {
+	bool flush = PACKET_SKB_CB(skb)->enforce_flush;
 	struct net_device *dev = skb->dev;
 	netdev_features_t features;
 	struct netdev_queue *txq;
@@ -261,9 +265,12 @@ static int packet_direct_xmit(struct sk_buff *skb)
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_xmit_frozen_or_drv_stopped(txq)) {
-		ret = netdev_start_xmit(skb, dev);
-		if (ret == NETDEV_TX_OK)
+		ret = __netdev_xmit_only(skb, dev);
+		if (ret == NETDEV_TX_OK) {
+			if (flush)
+				__netdev_xmit_flush(dev, queue_map);
 			txq_trans_update(txq);
+		}
 	}
 	HARD_TX_UNLOCK(dev, txq);
 
@@ -313,7 +320,7 @@ static u16 __packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb)
 	return (u16) raw_smp_processor_id() % dev->real_num_tx_queues;
 }
 
-static void packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb)
+static u16 packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	u16 queue_index;
@@ -327,6 +334,7 @@ static void packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb)
 	}
 
 	skb_set_queue_mapping(skb, queue_index);
+	return queue_index;
 }
 
 /* register_prot_hook must be invoked with the po->bind_lock held,
@@ -2237,7 +2245,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	unsigned char *addr;
 	int len_sum = 0;
 	int status = TP_STATUS_AVAILABLE;
-	int hlen, tlen;
+	int hlen, tlen, pending = 0;
+	u16 last_queue = 0;
 
 	mutex_lock(&po->pg_vec_lock);
 
@@ -2276,18 +2285,22 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		ph = packet_current_frame(po, &po->tx_ring,
 					  TP_STATUS_SEND_REQUEST);
 		if (unlikely(ph == NULL)) {
-			if (need_wait && need_resched())
+			if (need_wait && need_resched()) {
+				if (packet_use_direct_xmit(po) && pending > 0) {
+					__netdev_xmit_flush(dev, last_queue);
+					pending = 0;
+				}
 				schedule();
+			}
 			continue;
 		}
 
 		status = TP_STATUS_SEND_REQUEST;
 		hlen = LL_RESERVED_SPACE(dev);
-		tlen = dev->needed_tailroom;
-		skb = sock_alloc_send_skb(&po->sk,
-				hlen + tlen + sizeof(struct sockaddr_ll),
-				0, &err);
 
+		tlen = dev->needed_tailroom;
+		skb = sock_alloc_send_skb(&po->sk, hlen + tlen +
+					  sizeof(struct sockaddr_ll), 0, &err);
 		if (unlikely(skb == NULL))
 			goto out_status;
 
@@ -2319,13 +2332,18 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			}
 		}
 
-		packet_pick_tx_queue(dev, skb);
+		last_queue = packet_pick_tx_queue(dev, skb);
 
 		skb->destructor = tpacket_destruct_skb;
 		__packet_set_status(po, ph, TP_STATUS_SENDING);
 		packet_inc_pending(&po->tx_ring);
 
 		status = TP_STATUS_SEND_REQUEST;
+		if (pending >= PACKET_FLUSH_THRESH) {
+			PACKET_SKB_CB(skb)->enforce_flush = 1;
+			pending = -1;
+		}
+
 		err = po->xmit(skb);
 		if (unlikely(err > 0)) {
 			err = net_xmit_errno(err);
@@ -2340,7 +2358,11 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			 * let's treat it like congestion or err < 0
 			 */
 			err = 0;
+		} else {
+			/* Sucessfully sent out. */
+			pending++;
 		}
+
 		packet_increment_head(&po->tx_ring);
 		len_sum += tp_len;
 	} while (likely((ph != NULL) ||
@@ -2354,11 +2376,12 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 	err = len_sum;
 	goto out_put;
-
 out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
 out_put:
+	if (packet_use_direct_xmit(po) && pending > 0)
+		__netdev_xmit_flush(dev, last_queue);
 	dev_put(dev);
 out:
 	mutex_unlock(&po->pg_vec_lock);
@@ -2561,6 +2584,8 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
 
+	PACKET_SKB_CB(skb)->enforce_flush = 1;
+
 	err = po->xmit(skb);
 	if (err > 0 && (err = net_xmit_errno(err)) != 0)
 		goto out_unlock;
-- 
1.7.11.7
