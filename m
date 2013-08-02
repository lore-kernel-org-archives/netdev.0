From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v2 1/3] af_packet: when sending ethernet frames, parse header for skb->protocol
Date: Fri,  2 Aug 2013 11:37:39 +0200
Message-ID: <1375436261-6746-1-git-send-email-phil@nwl.cc>
References: <20130801.181208.804928209108880255.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:40834 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758520Ab3HBJiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 05:38:08 -0400
In-Reply-To: <20130801.181208.804928209108880255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This may be necessary when the SKB is passed to other layers on the go,
which check the protocol field on their own. An example is a VLAN packet
sent out using AF_PACKET on a bridge interface. The bridging code checks
the SKB size, accounting for any VLAN header only if the protocol field
is set accordingly.

Note that eth_type_trans() sets skb->dev to the passed argument, so this
can be skipped in packet_snd() for ethernet frames, as well.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since V1:
- minor lingual review of the comment
- added note about setting skb->dev for non-ethernet frames only
---
 net/packet/af_packet.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 20a1bd0..e549e17 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -88,6 +88,7 @@
 #include <linux/virtio_net.h>
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
+#include <linux/if_arp.h>
 
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -2005,6 +2006,9 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		if (unlikely(err))
 			return err;
 
+		if (dev->type == ARPHRD_ETHER)
+			skb->protocol = eth_type_trans(skb, dev);
+
 		data += dev->hard_header_len;
 		to_write -= dev->hard_header_len;
 	}
@@ -2324,6 +2328,13 @@ static int packet_snd(struct socket *sock,
 
 	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
+	if (dev->type == ARPHRD_ETHER) {
+		skb->protocol = eth_type_trans(skb, dev);
+	} else {
+		skb->protocol = proto;
+		skb->dev = dev;
+	}
+
 	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
 		/* Earlier code assumed this would be a VLAN pkt,
 		 * double-check this now that we have the actual
@@ -2338,8 +2349,6 @@ static int packet_snd(struct socket *sock,
 		}
 	}
 
-	skb->protocol = proto;
-	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-- 
1.8.1.5
