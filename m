From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 1/2] macvtap: Add support of packet capture on macvtap device.
Date: Wed, 11 Dec 2013 13:27:10 -0500
Message-ID: <1386786431-22592-2-git-send-email-vyasevic@redhat.com>
References: <1386786431-22592-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, kaber@trash.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751111Ab3LKTH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 14:07:59 -0500
In-Reply-To: <1386786431-22592-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macvtap device currently doesn not allow a user to capture
traffic on due to the fact that it steals the packets
from the network stack before the skb->dev is set correctly
on the receive side, and that use uses macvlan transmit
path directly on the send side.  As a result, we never
get a change to give traffic to the taps while the correct
device is set in the skb.

This patch makes macvtap device behave almost exaclty like
macvlan.  On the send side, we switch to using dev_queue_xmit().
On the receive side, to deliver packets to macvtap, we now
use netif_rx and dev_forward_skb just like macvlan.  The only
differnce now is that macvtap has its own rx_handler which is
attached to the macvtap netdev.  It is here that we now steal
the packet and provide it to the socket.

As a result, we can now capture traffic on the macvtap device:
   tcpdump -i macvtap0

It also gives us the abilit to add tc actions to the macvtap
device and actually utilize different bandwidth management
queues on output.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 59 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 32 insertions(+), 27 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 4c6f84c..f9847da 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -70,6 +70,11 @@ static const struct proto_ops macvtap_socket_ops;
 #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
 #define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG)
 
+static struct macvlan_dev *macvtap_get_vlan_rcu(const struct net_device *dev)
+{
+	return rcu_dereference(dev->rx_handler_data);
+}
+
 /*
  * RCU usage:
  * The macvtap_queue and the macvlan_dev are loosely coupled, the
@@ -271,24 +276,27 @@ static void macvtap_del_queues(struct net_device *dev)
 		sock_put(&qlist[j]->sk);
 }
 
-/*
- * Forward happens for data that gets sent from one macvlan
- * endpoint to another one in bridge mode. We just take
- * the skb and put it into the receive queue.
- */
-static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
+static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 {
-	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
+	struct sk_buff *skb = *pskb;
+	struct net_device *dev = skb->dev;
+	struct macvlan_dev *vlan;
+	struct macvtap_queue *q;
 	netdev_features_t features = TAP_FEATURES;
 
+	vlan = macvtap_get_vlan_rcu(dev);
+	if (!vlan)
+		return RX_HANDLER_PASS;
+
+	q = macvtap_get_queue(dev, skb);
 	if (!q)
-		goto drop;
+		return RX_HANDLER_PASS;
 
 	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
 		goto drop;
 
-	skb->dev = dev;
+	skb_push(skb, ETH_HLEN);
+
 	/* Apply the forward feature mask so that we perform segmentation
 	 * according to users wishes.  This only works if VNET_HDR is
 	 * enabled.
@@ -320,22 +328,13 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
 
 wake_up:
 	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
-	return NET_RX_SUCCESS;
+	return RX_HANDLER_CONSUMED;
 
 drop:
+	/* Count errors/drops only here, thus don't care about args. */
+	macvlan_count_rx(vlan, 0, 0, 0);
 	kfree_skb(skb);
-	return NET_RX_DROP;
-}
-
-/*
- * Receive is for data from the external interface (lowerdev),
- * in case of macvtap, we can treat that the same way as
- * forward, which macvlan cannot.
- */
-static int macvtap_receive(struct sk_buff *skb)
-{
-	skb_push(skb, ETH_HLEN);
-	return macvtap_forward(skb->dev, skb);
+	return RX_HANDLER_CONSUMED;
 }
 
 static int macvtap_get_minor(struct macvlan_dev *vlan)
@@ -385,6 +384,8 @@ static int macvtap_newlink(struct net *src_net,
 			   struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	int err;
+
 	INIT_LIST_HEAD(&vlan->queue_list);
 
 	/* Since macvlan supports all offloads by default, make
@@ -392,16 +393,21 @@ static int macvtap_newlink(struct net *src_net,
 	 */
 	vlan->tap_features = TUN_OFFLOADS;
 
+	err = netdev_rx_handler_register(dev, macvtap_handle_frame, vlan);
+	if (err)
+		return err;
+
 	/* Don't put anything that may fail after macvlan_common_newlink
 	 * because we can't undo what it does.
 	 */
 	return macvlan_common_newlink(src_net, dev, tb, data,
-				      macvtap_receive, macvtap_forward);
+				      netif_rx, dev_forward_skb);
 }
 
 static void macvtap_dellink(struct net_device *dev,
 			    struct list_head *head)
 {
+	netdev_rx_handler_unregister(dev);
 	macvtap_del_queues(dev);
 	macvlan_dellink(dev, head);
 }
@@ -725,9 +731,8 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 	}
 	if (vlan) {
-		local_bh_disable();
-		macvlan_start_xmit(skb, vlan->dev);
-		local_bh_enable();
+		skb->dev = vlan->dev;
+		dev_queue_xmit(skb);
 	} else {
 		kfree_skb(skb);
 	}
-- 
1.8.4.2
