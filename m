From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 3/3] packet: fix tpacket_snd max frame and vlan handling
Date: Tue, 10 Nov 2015 23:03:05 +0100
Message-ID: <f664dc9cf1d33a001fcdb0265833c96644db5bfd.1447191361.git.daniel@iogearbox.net>
References: <cover.1447191361.git.daniel@iogearbox.net>
Cc: edumazet@google.com, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33146 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393AbbKJWDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 17:03:16 -0500
In-Reply-To: <cover.1447191361.git.daniel@iogearbox.net>
In-Reply-To: <cover.1447191361.git.daniel@iogearbox.net>
References: <cover.1447191361.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There seem to be a couple of issues in tpacket_snd() path. Since it's
introduction in commit 69e3c75f4d54 ("net: TX_RING and packet mmap"),
TX_RING could be used from SOCK_DGRAM and SOCK_RAW side. When used
with SOCK_DGRAM only, the size_max > dev->mtu + reserve check should
have reserve as 0, but currently, this is unconditionally set (in it's
original form as dev->hard_header_len).

I think this is not correct since tpacket_fill_skb() would then take
dev->mtu and dev->hard_header_len into account for SOCK_DGRAM, the
extra VLAN_HLEN could be possible in both cases. Presumably, the
reserve code was copied from packet_snd(), but later on missed the
check.

Moreover, the check for ETH_P_8021Q seems buggy as we potentially
operate on non-linear header data. In sock_alloc_send_skb() we seem
to allocate enough linear head-room in most cases, so the test could
just yield false results. The sock_alloc_send_skb() has an extra room
of (for some reason) sizeof(struct sockaddr_ll), so we have enough
header room for at least ethernet header in case the device doesn't
ask for it. Note that in TX_RING's tpacket_fill_skb() we fetch the
frame data after the slot header (or at some provided offset), thus
from TX side (as opposed to RX_RING), it doesn't contain a sockaddr_ll
structure in between.

Anyway, the ETH_P_8021Q check would be better fixed in tpacket_fill_skb()
by making sure that in SOCK_RAW cases, where we deal with tp_len >
dev->mtu + dev->hard_header_len, to place at least the ethernet header
into the linear section (which is the case in SOCK_DGRAM already).
Doing this test on ring buffer data (either from set up skb or on data
directly) could race underneath us. The test is done at the end so we
can take both socket types into consideration. We check that
skb->protocol and also h_proto are correct in these cases. For packet
sockets that have proto of 0, guess the skb->protocol from the user
payload as suggested.

Fixes: 69e3c75f4d54 ("net: TX_RING and packet mmap")
Fixes: 52f1454f629f ("packet: allow to transmit +4 byte in TX_RING slot for VLAN case")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/packet/af_packet.c | 101 ++++++++++++++++++++++++++++++-------------------
 1 file changed, 63 insertions(+), 38 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index bdecf17..5d40ad3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2320,12 +2320,12 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 	sock_wfree(skb);
 }
 
-static bool ll_header_truncated(const struct net_device *dev, int len)
+static bool ll_header_truncated(int hard_header_len, int len)
 {
 	/* net device doesn't like empty head */
-	if (unlikely(len <= dev->hard_header_len)) {
+	if (unlikely(len <= hard_header_len)) {
 		net_warn_ratelimited("%s: packet size is too short (%d <= %d)\n",
-				     current->comm, len, dev->hard_header_len);
+				     current->comm, len, hard_header_len);
 		return true;
 	}
 
@@ -2333,8 +2333,9 @@ static bool ll_header_truncated(const struct net_device *dev, int len)
 }
 
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
-		void *frame, struct net_device *dev, int size_max,
-		__be16 proto, unsigned char *addr, int hlen)
+			    void *frame, struct net_device *dev, int size_max,
+			    __be16 proto, unsigned char *addr, int hlen,
+			    int reserve)
 {
 	union tpacket_uhdr ph;
 	int to_write, offset, len, tp_len, nr_frags, len_max;
@@ -2400,22 +2401,45 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	to_write = tp_len;
 
 	if (sock->type == SOCK_DGRAM) {
-		err = dev_hard_header(skb, dev, ntohs(proto), addr,
-				NULL, tp_len);
+		/* In DGRAM sockets, we expect struct sockaddr_ll was filled
+		 * via struct msghdr, so we have dest mac and skb->protocol.
+		 * Otherwise there's not too much useful things we can do in
+		 * this flush run.
+		 */
+		err = dev_hard_header(skb, dev, ntohs(skb->protocol), addr,
+				      NULL, tp_len);
 		if (unlikely(err < 0))
 			return -EINVAL;
-	} else if (dev->hard_header_len) {
-		if (ll_header_truncated(dev, tp_len))
-			return -EINVAL;
+	} else {
+		/* If skb->protocol is still 0, try to infer/guess it. Might
+		 * not be fully reliable in the sense that a user could still
+		 * change/race data afterwards, but on the other hand the proto
+		 * can be set arbitrarily anyways. We only need to take care
+		 * in case of extra large VLAN frames.
+		 */
+		if (!skb->protocol && tp_len >= ETH_HLEN)
+			skb->protocol = ((struct ethhdr *)data)->h_proto;
 
-		skb_push(skb, dev->hard_header_len);
-		err = skb_store_bits(skb, 0, data,
-				dev->hard_header_len);
-		if (unlikely(err))
-			return err;
+		/* Copy Ethernet header in case we need to deal with extra
+		 * VLAN space as otherwise data could change underneath us.
+		 * The caller already accomodated for enough linear room.
+		 */
+		if (dev->hard_header_len || tp_len > dev->mtu + reserve) {
+			int hdr_len = dev->hard_header_len;
+
+			if (hdr_len < ETH_HLEN)
+				hdr_len = ETH_HLEN;
+			if (unlikely(ll_header_truncated(hdr_len, tp_len)))
+				return -EINVAL;
+
+			skb_push(skb, hdr_len);
+			err = skb_store_bits(skb, 0, data, hdr_len);
+			if (unlikely(err))
+				return err;
 
-		data += dev->hard_header_len;
-		to_write -= dev->hard_header_len;
+			data     += hdr_len;
+			to_write -= hdr_len;
+		}
 	}
 
 	offset = offset_in_page(data);
@@ -2447,6 +2471,20 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		len = ((to_write > len_max) ? len_max : to_write);
 	}
 
+	/* Check for full frame with extra VLAN space. We can probe
+	 * here on the linear header, if necessary. Earlier code
+	 * assumed this would be a VLAN pkt, double-check this now
+	 * that we have the actual packet and protocol at hand.
+	 */
+	if (tp_len > dev->mtu + reserve) {
+		if (skb->protocol != htons(ETH_P_8021Q))
+			return -EMSGSIZE;
+
+		skb_reset_mac_header(skb);
+		if (eth_hdr(skb)->h_proto != htons(ETH_P_8021Q))
+			return -EMSGSIZE;
+	}
+
 	skb_probe_transport_header(skb, 0);
 
 	return tp_len;
@@ -2493,12 +2531,12 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_put;
 
-	reserve = dev->hard_header_len + VLAN_HLEN;
-	size_max = po->tx_ring.frame_size
-		- (po->tp_hdrlen - sizeof(struct sockaddr_ll));
-
-	if (size_max > dev->mtu + reserve)
-		size_max = dev->mtu + reserve;
+	if (po->sk.sk_socket->type == SOCK_RAW)
+		reserve = dev->hard_header_len;
+	size_max = po->tx_ring.frame_size - (po->tp_hdrlen -
+					     sizeof(struct sockaddr_ll));
+	if (size_max > dev->mtu + reserve + VLAN_HLEN)
+		size_max = dev->mtu + reserve + VLAN_HLEN;
 
 	do {
 		ph = packet_current_frame(po, &po->tx_ring,
@@ -2523,20 +2561,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			goto out_status;
 		}
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
-					  addr, hlen);
-		if (likely(tp_len >= 0) &&
-		    tp_len > dev->mtu + dev->hard_header_len) {
-			struct ethhdr *ehdr;
-			/* Earlier code assumed this would be a VLAN pkt,
-			 * double-check this now that we have the actual
-			 * packet in hand.
-			 */
-
-			skb_reset_mac_header(skb);
-			ehdr = eth_hdr(skb);
-			if (ehdr->h_proto != htons(ETH_P_8021Q))
-				tp_len = -EMSGSIZE;
-		}
+					  addr, hlen, reserve);
 		if (unlikely(tp_len < 0)) {
 			if (po->tp_loss) {
 				__packet_set_status(po, ph,
@@ -2754,7 +2779,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 		if (unlikely(offset < 0))
 			goto out_free;
 	} else {
-		if (ll_header_truncated(dev, len))
+		if (unlikely(ll_header_truncated(dev->hard_header_len, len)))
 			goto out_free;
 	}
 
-- 
1.9.3
