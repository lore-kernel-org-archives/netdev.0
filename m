From: greearb@candelatech.com
Subject: [PATCH 2/2] network: Allow af_packet to transmit +4 bytes for VLAN packets.
Date: Thu, 10 Feb 2011 13:59:09 -0800
Message-ID: <1297375149-18458-2-git-send-email-greearb@candelatech.com>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53506 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757161Ab1BJV7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 16:59:32 -0500
In-Reply-To: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows user-space to send a '1500' MTU VLAN packet on a
1500 MTU ethernet frame.  The extra 4 bytes of a VLAN header is
not usually charged against the MTU when other parts of the
network stack is transmitting vlans...

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 91cb1d7... ef7f378... M	net/packet/af_packet.c
 net/packet/af_packet.c |   31 +++++++++++++++++++++++++++++--
 1 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 91cb1d7..ef7f378 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -466,7 +466,7 @@ retry:
 	 */
 
 	err = -EMSGSIZE;
-	if (len > dev->mtu + dev->hard_header_len)
+	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN)
 		goto out_unlock;
 
 	if (!skb) {
@@ -497,6 +497,19 @@ retry:
 		goto retry;
 	}
 
+	if (len > (dev->mtu + dev->hard_header_len)) {
+		/* Earlier code assumed this would be a VLAN pkt,
+		 * double-check this now that we have the actual
+		 * packet in hand.
+		 */
+		struct ethhdr *ehdr;
+		skb_reset_mac_header(skb);
+		ehdr = eth_hdr(skb);
+		if (ehdr->h_proto != htons(ETH_P_8021Q)) {
+			err = -EMSGSIZE;
+			goto out_unlock;
+		}
+	}
 
 	skb->protocol = proto;
 	skb->dev = dev;
@@ -1200,7 +1213,7 @@ static int packet_snd(struct socket *sock,
 	}
 
 	err = -EMSGSIZE;
-	if (!gso_type && (len > dev->mtu+reserve))
+	if (!gso_type && (len > dev->mtu + reserve + ETH_HLEN))
 		goto out_unlock;
 
 	err = -ENOBUFS;
@@ -1225,6 +1238,20 @@ static int packet_snd(struct socket *sock,
 	if (err < 0)
 		goto out_free;
 
+	if (!gso_type && (len > dev->mtu + reserve)) {
+		/* Earlier code assumed this would be a VLAN pkt,
+		 * double-check this now that we have the actual
+		 * packet in hand.
+		 */
+		struct ethhdr *ehdr;
+		skb_reset_mac_header(skb);
+		ehdr = eth_hdr(skb);
+		if (ehdr->h_proto != htons(ETH_P_8021Q)) {
+			err = -EMSGSIZE;
+			goto out_free;
+		}
+	}
+
 	skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
-- 
1.7.2.3

