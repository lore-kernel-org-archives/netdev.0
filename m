From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v3 5/5] packet: fix tpacket_snd max frame len
Date: Wed, 11 Nov 2015 23:25:44 +0100
Message-ID: <45ebab096c421823fdf50bd3ff8b2fafd55a0402.1447278504.git.daniel@iogearbox.net>
References: <cover.1447278504.git.daniel@iogearbox.net>
Cc: edumazet@google.com, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57181 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258AbbKKWZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 17:25:51 -0500
In-Reply-To: <cover.1447278504.git.daniel@iogearbox.net>
In-Reply-To: <cover.1447278504.git.daniel@iogearbox.net>
References: <cover.1447278504.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since it's introduction in commit 69e3c75f4d54 ("net: TX_RING and
packet mmap"), TX_RING could be used from SOCK_DGRAM and SOCK_RAW
side. When used with SOCK_DGRAM only, the size_max > dev->mtu +
reserve check should have reserve as 0, but currently, this is
unconditionally set (in it's original form as dev->hard_header_len).

I think this is not correct since tpacket_fill_skb() would then
take dev->mtu and dev->hard_header_len into account for SOCK_DGRAM,
the extra VLAN_HLEN could be possible in both cases. Presumably, the
reserve code was copied from packet_snd(), but later on missed the
check. Make it similar as we have it in packet_snd().

Fixes: 69e3c75f4d54 ("net: TX_RING and packet mmap")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/packet/af_packet.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0066da2..242bce1 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2510,12 +2510,13 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_put;
 
-	reserve = dev->hard_header_len + VLAN_HLEN;
+	if (po->sk.sk_socket->type == SOCK_RAW)
+		reserve = dev->hard_header_len;
 	size_max = po->tx_ring.frame_size
 		- (po->tp_hdrlen - sizeof(struct sockaddr_ll));
 
-	if (size_max > dev->mtu + reserve)
-		size_max = dev->mtu + reserve;
+	if (size_max > dev->mtu + reserve + VLAN_HLEN)
+		size_max = dev->mtu + reserve + VLAN_HLEN;
 
 	do {
 		ph = packet_current_frame(po, &po->tx_ring,
@@ -2542,7 +2543,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
 					  addr, hlen);
 		if (likely(tp_len >= 0) &&
-		    tp_len > dev->mtu + dev->hard_header_len &&
+		    tp_len > dev->mtu + reserve &&
 		    !packet_extra_vlan_len_allowed(dev, skb))
 			tp_len = -EMSGSIZE;
 
-- 
1.9.3
