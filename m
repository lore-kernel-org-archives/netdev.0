From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v2 3/3] af_packet: simplify VLAN frame check in packet_snd
Date: Fri,  2 Aug 2013 11:37:41 +0200
Message-ID: <1375436261-6746-3-git-send-email-phil@nwl.cc>
References: <20130801.181208.804928209108880255.davem@davemloft.net>
 <1375436261-6746-1-git-send-email-phil@nwl.cc>
 <1375436261-6746-2-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:42153 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758603Ab3HBJiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 05:38:08 -0400
In-Reply-To: <1375436261-6746-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For ethernet frames, eth_type_trans() already parses the header, so one
can skip this when checking the frame size.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/packet/af_packet.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ce7b4f0..bbe1ece 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2333,23 +2333,16 @@ static int packet_snd(struct socket *sock,
 
 	if (dev->type == ARPHRD_ETHER) {
 		skb->protocol = eth_type_trans(skb, dev);
+		if (skb->protocol == htons(ETH_P_8021Q))
+			reserve += VLAN_HLEN;
 	} else {
 		skb->protocol = proto;
 		skb->dev = dev;
 	}
 
 	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
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
+		err = -EMSGSIZE;
+		goto out_free;
 	}
 
 	skb->priority = sk->sk_priority;
-- 
1.8.1.5
