From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net v2] packet: on direct_xmit, limit tso and csum to supported devices
Date: Wed, 26 Oct 2016 11:23:07 -0400
Message-ID: <1477495387-36861-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, daniel@iogearbox.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:40328 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752208AbcJZPXd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 11:23:33 -0400
Received: by mail-qk0-f196.google.com with SMTP id z82so506759qkb.7
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 08:23:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When transmitting on a packet socket with PACKET_VNET_HDR and
PACKET_QDISC_BYPASS, validate device support for features requested
in vnet_hdr.

Drop TSO packets sent to devices that do not support TSO or have the
feature disabled. Note that the latter currently do process those
packets correctly, regardless of not advertising the feature.

Because of SKB_GSO_DODGY, it is not sufficient to test device features
with netif_needs_gso. Full validate_xmit_skb is needed.

Switch to software checksum for non-TSO packets that request checksum
offload if that device feature is unsupported or disabled. Note that
similar to the TSO case, device drivers may perform checksum offload
correctly even when not advertising it.

When switching to software checksum, packets hit skb_checksum_help,
which has two BUG_ON checksum not in linear segment. Packet sockets
always allocate at least up to csum_start + csum_off + 2 as linear.

Tested by running github.com/wdebruij/kerneltools/psock_txring_vnet.c

  ethtool -K eth0 tso off tx on
  psock_txring_vnet -d $dst -s $src -i eth0 -l 2000 -n 1 -q -v
  psock_txring_vnet -d $dst -s $src -i eth0 -l 2000 -n 1 -q -v -N

  ethtool -K eth0 tx off
  psock_txring_vnet -d $dst -s $src -i eth0 -l 1000 -n 1 -q -v -G
  psock_txring_vnet -d $dst -s $src -i eth0 -l 1000 -n 1 -q -v -G -N

v2:
  - add EXPORT_SYMBOL_GPL(validate_xmit_skb_list)

Fixes: d346a3fae3ff ("packet: introduce PACKET_QDISC_BYPASS socket option")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/dev.c         | 1 +
 net/packet/af_packet.c | 9 ++++-----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index dbc8713..f745112 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3035,6 +3035,7 @@ struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *d
 	}
 	return head;
 }
+EXPORT_SYMBOL_GPL(validate_xmit_skb_list);
 
 static void qdisc_pkt_len_init(struct sk_buff *skb)
 {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 11db0d6..d2238b2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -250,7 +250,7 @@ static void __fanout_link(struct sock *sk, struct packet_sock *po);
 static int packet_direct_xmit(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	netdev_features_t features;
+	struct sk_buff *orig_skb = skb;
 	struct netdev_queue *txq;
 	int ret = NETDEV_TX_BUSY;
 
@@ -258,9 +258,8 @@ static int packet_direct_xmit(struct sk_buff *skb)
 		     !netif_carrier_ok(dev)))
 		goto drop;
 
-	features = netif_skb_features(skb);
-	if (skb_needs_linearize(skb, features) &&
-	    __skb_linearize(skb))
+	skb = validate_xmit_skb_list(skb, dev);
+	if (skb != orig_skb)
 		goto drop;
 
 	txq = skb_get_tx_queue(dev, skb);
@@ -280,7 +279,7 @@ static int packet_direct_xmit(struct sk_buff *skb)
 	return ret;
 drop:
 	atomic_long_inc(&dev->tx_dropped);
-	kfree_skb(skb);
+	kfree_skb_list(skb);
 	return NET_XMIT_DROP;
 }
 
-- 
2.8.0.rc3.226.g39d4020
