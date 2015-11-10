From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 2/3] packet: always probe for transport header
Date: Tue, 10 Nov 2015 23:03:04 +0100
Message-ID: <4adce55fc6c4aa8f05306af650659a1326537a1a.1447191361.git.daniel@iogearbox.net>
References: <cover.1447191361.git.daniel@iogearbox.net>
Cc: edumazet@google.com, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33145 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbbKJWDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 17:03:16 -0500
In-Reply-To: <cover.1447191361.git.daniel@iogearbox.net>
In-Reply-To: <cover.1447191361.git.daniel@iogearbox.net>
References: <cover.1447191361.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We concluded that the skb_probe_transport_header() should better be
called unconditionally. Avoiding the call into the flow dissector has
also not really much to do with the direct xmit mode.

While it seems that only virtio_net code makes use of GSO from non
RX/TX ring packet socket paths, we should probe for a transport header
nevertheless before they hit devices.

Reference: http://thread.gmane.org/gmane.linux.network/386173/
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jason Wang <jasowang@redhat.com>
---
 net/packet/af_packet.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 80c36c0..bdecf17 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2447,8 +2447,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		len = ((to_write > len_max) ? len_max : to_write);
 	}
 
-	if (!packet_use_direct_xmit(po))
-		skb_probe_transport_header(skb, 0);
+	skb_probe_transport_header(skb, 0);
 
 	return tp_len;
 }
@@ -2808,8 +2807,8 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 		len += vnet_hdr_len;
 	}
 
-	if (!packet_use_direct_xmit(po))
-		skb_probe_transport_header(skb, reserve);
+	skb_probe_transport_header(skb, reserve);
+
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
 
-- 
1.9.3
