From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 3/3] packet: check for ndo_select_queue during queue selection
Date: Sun, 16 Feb 2014 15:55:22 +0100
Message-ID: <1392562522-15585-4-git-send-email-dborkman@redhat.com>
References: <1392562522-15585-1-git-send-email-dborkman@redhat.com>
Cc: brouer@redhat.com, mathias.kretschmer@fokus.fraunhofer.de,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55098 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474AbaBPOzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Feb 2014 09:55:33 -0500
In-Reply-To: <1392562522-15585-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathias reported that on an AMD Geode LX embedded board (ALiX)
with ath9k driver PACKET_QDISC_BYPASS, introduced in commit
d346a3fae3ff ("packet: introduce PACKET_QDISC_BYPASS socket
option"), triggers a WARN_ON() coming from the driver itself
via 066dae93bdf ("ath9k: rework tx queue selection and fix
queue stopping/waking").

The reason why this happened is that ndo_select_queue() call
is not invoked from direct xmit path i.e. for ieee80211 subsystem
that sets queue and TID (similar to 802.1d tag) which is being
put into the frame through 802.11e (WMM, QoS). If that is not
set, pending frame counter for e.g. ath9k can get messed up.

So the WARN_ON() in ath9k is absolutely legitimate. Generally,
the hw queue selection in ieee80211 depends on the type of
traffic, and priorities are set according to ieee80211_ac_numbers
mapping; working in a similar way as DiffServ only on a lower
layer, so that the AP can favour frames that have "real-time"
requirements like voice or video data frames.

Therefore, check for presence of ndo_select_queue() in netdev
ops and, if available, invoke it with a fallback handler to
__packet_pick_tx_queue(), so that driver such as bnx2x, ixgbe,
or mlx4 can still select a hw queue for transmission in
relation to the current CPU while e.g. ieee80211 subsystem
can make their own choices.

Reported-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/packet/af_packet.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6a2bb37..b5dc116 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -308,11 +308,27 @@ static bool packet_use_direct_xmit(const struct packet_sock *po)
 	return po->xmit == packet_direct_xmit;
 }
 
-static u16 packet_pick_tx_queue(struct net_device *dev)
+static u16 __packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	return (u16) raw_smp_processor_id() % dev->real_num_tx_queues;
 }
 
+static void packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	u16 queue_index;
+
+	if (ops->ndo_select_queue) {
+		queue_index = ops->ndo_select_queue(dev, skb, NULL,
+						    __packet_pick_tx_queue);
+		queue_index = netdev_cap_txqueue(dev, queue_index);
+	} else {
+		queue_index = __packet_pick_tx_queue(dev, skb);
+	}
+
+	skb_set_queue_mapping(skb, queue_index);
+}
+
 /* register_prot_hook must be invoked with the po->bind_lock held,
  * or from a context in which asynchronous accesses to the packet
  * socket is not possible (packet_create()).
@@ -2285,7 +2301,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			}
 		}
 
-		skb_set_queue_mapping(skb, packet_pick_tx_queue(dev));
+		packet_pick_tx_queue(dev, skb);
+
 		skb->destructor = tpacket_destruct_skb;
 		__packet_set_status(po, ph, TP_STATUS_SENDING);
 		packet_inc_pending(&po->tx_ring);
@@ -2499,7 +2516,8 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
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
