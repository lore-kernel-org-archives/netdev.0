From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v3 3/5] packet: only allow extra vlan len on ethernet devices
Date: Wed, 11 Nov 2015 23:25:42 +0100
Message-ID: <45cbb079a6f1c88aff9da37198c8f8bb0414aefd.1447278504.git.daniel@iogearbox.net>
References: <cover.1447278504.git.daniel@iogearbox.net>
Cc: edumazet@google.com, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57170 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbbKKWZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 17:25:50 -0500
In-Reply-To: <cover.1447278504.git.daniel@iogearbox.net>
In-Reply-To: <cover.1447278504.git.daniel@iogearbox.net>
References: <cover.1447278504.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packet sockets can be used by various net devices and are not
really restricted to ARPHRD_ETHER device types. However, when
currently checking for the extra 4 bytes that can be transmitted
in VLAN case, our assumption is that we generally probe on
ARPHRD_ETHER devices. Therefore, before looking into Ethernet
header, check the device type first.

This also fixes the issue where non-ARPHRD_ETHER devices could
have no dev->hard_header_len in TX_RING SOCK_RAW case, and thus
the check would test unfilled linear part of the skb (instead
of non-linear).

Fixes: 57f89bfa2140 ("network: Allow af_packet to transmit +4 bytes for VLAN packets.")
Fixes: 52f1454f629f ("packet: allow to transmit +4 byte in TX_RING slot for VLAN case")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/packet/af_packet.c | 60 +++++++++++++++++++++-----------------------------
 1 file changed, 25 insertions(+), 35 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index bdecf17..8795b0f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1741,6 +1741,20 @@ static void fanout_release(struct sock *sk)
 		kfree_rcu(po->rollover, rcu);
 }
 
+static bool packet_extra_vlan_len_allowed(const struct net_device *dev,
+					  struct sk_buff *skb)
+{
+	/* Earlier code assumed this would be a VLAN pkt, double-check
+	 * this now that we have the actual packet in hand. We can only
+	 * do this check on Ethernet devices.
+	 */
+	if (unlikely(dev->type != ARPHRD_ETHER))
+		return false;
+
+	skb_reset_mac_header(skb);
+	return likely(eth_hdr(skb)->h_proto == htons(ETH_P_8021Q));
+}
+
 static const struct proto_ops packet_ops;
 
 static const struct proto_ops packet_ops_spkt;
@@ -1902,18 +1916,10 @@ retry:
 		goto retry;
 	}
 
-	if (len > (dev->mtu + dev->hard_header_len + extra_len)) {
-		/* Earlier code assumed this would be a VLAN pkt,
-		 * double-check this now that we have the actual
-		 * packet in hand.
-		 */
-		struct ethhdr *ehdr;
-		skb_reset_mac_header(skb);
-		ehdr = eth_hdr(skb);
-		if (ehdr->h_proto != htons(ETH_P_8021Q)) {
-			err = -EMSGSIZE;
-			goto out_unlock;
-		}
+	if (len > (dev->mtu + dev->hard_header_len + extra_len) &&
+	    !packet_extra_vlan_len_allowed(dev, skb)) {
+		err = -EMSGSIZE;
+		goto out_unlock;
 	}
 
 	skb->protocol = proto;
@@ -2525,18 +2531,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
 					  addr, hlen);
 		if (likely(tp_len >= 0) &&
-		    tp_len > dev->mtu + dev->hard_header_len) {
-			struct ethhdr *ehdr;
-			/* Earlier code assumed this would be a VLAN pkt,
-			 * double-check this now that we have the actual
-			 * packet in hand.
-			 */
+		    tp_len > dev->mtu + dev->hard_header_len &&
+		    !packet_extra_vlan_len_allowed(dev, skb))
+			tp_len = -EMSGSIZE;
 
-			skb_reset_mac_header(skb);
-			ehdr = eth_hdr(skb);
-			if (ehdr->h_proto != htons(ETH_P_8021Q))
-				tp_len = -EMSGSIZE;
-		}
 		if (unlikely(tp_len < 0)) {
 			if (po->tp_loss) {
 				__packet_set_status(po, ph,
@@ -2765,18 +2763,10 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 
 	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
-	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
-		/* Earlier code assumed this would be a VLAN pkt,
-		 * double-check this now that we have the actual
-		 * packet in hand.
-		 */
-		struct ethhdr *ehdr;
-		skb_reset_mac_header(skb);
-		ehdr = eth_hdr(skb);
-		if (ehdr->h_proto != htons(ETH_P_8021Q)) {
-			err = -EMSGSIZE;
-			goto out_free;
-		}
+	if (!gso_type && (len > dev->mtu + reserve + extra_len) &&
+	    !packet_extra_vlan_len_allowed(dev, skb)) {
+		err = -EMSGSIZE;
+		goto out_free;
 	}
 
 	skb->protocol = proto;
-- 
1.9.3
