From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/2] packet: do skb_probe_transport_header when we actually have data
Date: Fri,  6 Nov 2015 22:02:41 +0100
Message-ID: <5cdcd969eec9228a18c0dc54f9cc4b7b6b07ce05.1446842228.git.daniel@iogearbox.net>
References: <cover.1446842228.git.daniel@iogearbox.net>
Cc: davem@davemloft.net, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Jason Wang <jasowang@redhat.com>
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55344 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965991AbbKFVCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 16:02:47 -0500
In-Reply-To: <cover.1446842228.git.daniel@iogearbox.net>
In-Reply-To: <cover.1446842228.git.daniel@iogearbox.net>
References: <cover.1446842228.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tpacket_fill_skb() commit c1aad275b029 ("packet: set transport
header before doing xmit") and later on 40893fd0fd4e ("net: switch
to use skb_probe_transport_header()") was probing for a transport
header on the skb from a ring buffer slot, but at a time, where
the skb has _not even_ been filled with data yet. So that call into
the flow dissector is pretty useless. Lets do it after we've set
up the skb frags.

Fixes: c1aad275b029 ("packet: set transport header before doing xmit")
Reported-by: Eric Dumazet <edumazet@google.com>
Cc: Jason Wang <jasowang@redhat.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/packet/af_packet.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index af399ca..80c36c0 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2368,8 +2368,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
 
-	if (!packet_use_direct_xmit(po))
-		skb_probe_transport_header(skb, 0);
 	if (unlikely(po->tp_tx_has_off)) {
 		int off_min, off_max, off;
 		off_min = po->tp_hdrlen - sizeof(struct sockaddr_ll);
@@ -2449,6 +2447,9 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		len = ((to_write > len_max) ? len_max : to_write);
 	}
 
+	if (!packet_use_direct_xmit(po))
+		skb_probe_transport_header(skb, 0);
+
 	return tp_len;
 }
 
-- 
1.9.3
