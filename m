From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] packet: check for ndo_select_queue during queue selection
Date: Thu, 13 Feb 2014 18:18:55 +0100
Message-ID: <1392311935-10275-1-git-send-email-dborkman@redhat.com>
Cc: mathias.kretschmer@fokus.fraunhofer.de, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57744 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbaBMRTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 12:19:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathias reported that on an AMD Geode LX embedded board (ALiX)
with ath9k driver PACKET_QDISC_BYPASS triggers a WARN_ON()
coming from the driver itself via 066dae93bdf ("ath9k: rework
tx queue selection and fix queue stopping/waking"). The reason
why this happened is that ndo_select_queue() call is not
invoked from direct xmit path i.e. for ieee80211 subsystem
that sets queue and TID (similar to 802.1d tag) which is being
put into the frame through 802.11e (WMM, QoS). If that is not
set, pending frame counter for e.g. ath9k can get messed up.
So the WARN_ON() in ath9k is absolutely legitimate. Generally,
the hw queue selection in ieee80211 depends on the type of
traffic, and priorities are set according to ieee80211_ac_numbers
mapping; working in a similar way as DiffServ only on a lower
layer, so that the AP can favour frames that have "real-time"
requirements like voice or video data frames. We were evaluating
this and concluded that it's best for PACKET_QDISC_BYPASS to
just probe for existance of this function and invoke it if
available so that drivers that implement it can make an
informed decision to which hw queue the frame should be
dispatched to. Only few drivers implement this function, so
for the majority of drivers nothing changes. The original
pktgen scenario for which PACKET_QDISC_BYPASS was designed
for is still intact with this change anyway. We think
restricting this feature only to ethernet drivers would be an
artificial barrier where we would instead only need to call
ndo_select_queue(). Besides, checking for ARPHRD_ETHER as pktgen
does wouldn't be sufficient as also many ieee80211 drivers
use it as dev->type. If side-effects that we documented are
undesired or use case involves buffering, then people just go
with the normal dev_queue_xmit() that is on default enabled.

Reported-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 Intended for 3.14.

 include/linux/netdevice.h | 20 ++++++++++++++++++++
 net/core/flow_dissector.c | 13 +------------
 net/packet/af_packet.c    | 20 ++++++++++++++++----
 3 files changed, 37 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 440a02e..5f8c860 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2276,6 +2276,26 @@ static inline void netdev_reset_queue(struct net_device *dev_queue)
 }
 
 /**
+ * 	netdev_cap_txqueue - check if selected tx queue exceeds device queues
+ * 	@dev: network device
+ * 	@queue_index: given tx queue index
+ *
+ * 	Returns 0 if given tx queue index >= number of device tx queues,
+ * 	otherwise returns the originally passed tx queue index.
+ */
+static inline u16 netdev_cap_txqueue(struct net_device *dev, u16 queue_index)
+{
+	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
+		net_warn_ratelimited("%s selects TX queue %d, but real number of TX queues is %d\n",
+				     dev->name, queue_index,
+				     dev->real_num_tx_queues);
+		return 0;
+	}
+
+	return queue_index;
+}
+
+/**
  *	netif_running - test if up
  *	@dev: network device
  *
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 87577d4..d0e1fb1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -323,17 +323,6 @@ u32 __skb_get_poff(const struct sk_buff *skb)
 	return poff;
 }
 
-static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
-{
-	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
-		net_warn_ratelimited("%s selects TX queue %d, but real number of TX queues is %d\n",
-				     dev->name, queue_index,
-				     dev->real_num_tx_queues);
-		return 0;
-	}
-	return queue_index;
-}
-
 static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_XPS
@@ -409,7 +398,7 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 			queue_index = __netdev_pick_tx(dev, skb);
 
 		if (!accel_priv)
-			queue_index = dev_cap_txqueue(dev, queue_index);
+			queue_index = netdev_cap_txqueue(dev, queue_index);
 	}
 
 	skb_set_queue_mapping(skb, queue_index);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6a2bb37..562ced9 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -308,9 +308,19 @@ static bool packet_use_direct_xmit(const struct packet_sock *po)
 	return po->xmit == packet_direct_xmit;
 }
 
-static u16 packet_pick_tx_queue(struct net_device *dev)
+static void packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	return (u16) raw_smp_processor_id() % dev->real_num_tx_queues;
+	const struct net_device_ops *ops = dev->netdev_ops;
+	u16 queue_index;
+
+	if (ops->ndo_select_queue) {
+		queue_index = ops->ndo_select_queue(dev, skb, NULL);
+		queue_index = netdev_cap_txqueue(dev, queue_index);
+	} else {
+		queue_index = raw_smp_processor_id() % dev->real_num_tx_queues;
+	}
+
+	skb_set_queue_mapping(skb, queue_index);
 }
 
 /* register_prot_hook must be invoked with the po->bind_lock held,
@@ -2285,7 +2295,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			}
 		}
 
-		skb_set_queue_mapping(skb, packet_pick_tx_queue(dev));
+		packet_pick_tx_queue(dev, skb);
+
 		skb->destructor = tpacket_destruct_skb;
 		__packet_set_status(po, ph, TP_STATUS_SENDING);
 		packet_inc_pending(&po->tx_ring);
@@ -2499,7 +2510,8 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	skb_set_queue_mapping(skb, packet_pick_tx_queue(dev));
+
+	packet_pick_tx_queue(dev, skb);
 
 	if (po->has_vnet_hdr) {
 		if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-- 
1.7.11.7
