From: =?UTF-8?q?Iv=C3=A1n=20Briano?= <ivan.briano@intel.com>
Subject: [PATCH net-next] net/packet: Fix Tx queue selection for AF_PACKET
Date: Fri, 30 Jun 2017 14:02:32 -0700
Message-ID: <20170630210232.18407-1-ivan.briano@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: jesus.sanchez-palencia@intel.com, vinicius.gomes@intel.com,
        andre.guedes@intel.com,
        =?UTF-8?q?Iv=C3=A1n=20Briano?= <ivan.briano@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6126 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752772AbdF3VCe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 17:02:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When PACKET_QDISC_BYPASS is not used, Tx queue selection will be done
before the packet is enqueued, taking into account any mappings set by
a queuing discipline such as mqprio without hardware offloading. This
selection may be affected by a previously saved queue_mapping, either on
the Rx path, or done before the packet reaches the device, as it's
currently the case for AF_PACKET.

In order for queue selection to work as expected when using traffic
control, there can't be another selection done before that point is
reached, so move the call to packet_pick_tx_queue to
packet_direct_xmit, leaving the default xmit path as it was before
PACKET_QDISC_BYPASS was introduced.

A forward declaration of packet_pick_tx_queue() is introduced to avoid
the need to reorder the functions within the file.

Signed-off-by: Iván Briano <ivan.briano@intel.com>
---
 net/packet/af_packet.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f9349a4..2169368 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -214,6 +214,7 @@ static void prb_clear_rxhash(struct tpacket_kbdq_core *,
 static void prb_fill_vlan_info(struct tpacket_kbdq_core *,
 		struct tpacket3_hdr *);
 static void packet_flush_mclist(struct sock *sk);
+static void packet_pick_tx_queue(struct net_device *dev, struct sk_buff *skb);
 
 struct packet_skb_cb {
 	union {
@@ -260,6 +261,7 @@ static int packet_direct_xmit(struct sk_buff *skb)
 	if (skb != orig_skb)
 		goto drop;
 
+	packet_pick_tx_queue(dev, skb);
 	txq = skb_get_tx_queue(dev, skb);
 
 	local_bh_disable();
@@ -2747,8 +2749,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			goto tpacket_error;
 		}
 
-		packet_pick_tx_queue(dev, skb);
-
 		skb->destructor = tpacket_destruct_skb;
 		__packet_set_status(po, ph, TP_STATUS_SENDING);
 		packet_inc_pending(&po->tx_ring);
@@ -2931,8 +2931,6 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	skb->priority = sk->sk_priority;
 	skb->mark = sockc.mark;
 
-	packet_pick_tx_queue(dev, skb);
-
 	if (po->has_vnet_hdr) {
 		err = virtio_net_hdr_to_skb(skb, &vnet_hdr, vio_le());
 		if (err)
-- 
2.9.4
