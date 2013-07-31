From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 1/3] af_packet: when sending ethernet frames, parse header for skb->protocol
Date: Wed, 31 Jul 2013 19:27:45 +0200
Message-ID: <1375291667-9572-2-git-send-email-phil@nwl.cc>
References: <20130729165357.GA23134@orbit.nwl.cc>
 <1375291667-9572-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:44443 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754304Ab3GaR2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 13:28:19 -0400
In-Reply-To: <1375291667-9572-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This may be necessary when the SKB is passed to other layers on the go,
which may check the protocol field on their own. An example is a VLAN
packet sent using AF_PACKET out on a bridge interface. The bridging code
does check the SKB size, accounting for any VLAN header only if the
protocol field is set accordingly.

Signed-off-by: Phil Sutter <phil@nwl.cc>
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
