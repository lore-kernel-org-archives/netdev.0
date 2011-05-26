From: greearb@candelatech.com
Subject: [PATCH 2/2 v2] af-packet:  Add flag to distinguish VID 0 from no-vlan.
Date: Thu, 26 May 2011 16:55:41 -0700
Message-ID: <1306454141-1634-2-git-send-email-greearb@candelatech.com>
References: <1306454141-1634-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46746 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab1EZXzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 19:55:49 -0400
In-Reply-To: <1306454141-1634-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Currently, user-space cannot determine if a 0 tcp_vlan_tci
means there is no VLAN tag or the VLAN ID was zero.

Add flag to make this explicit.  User-space can check for
TP_STATUS_VLAN_VALID || tp_vlan_tci > 0, which will be backwards
compatible. Older could would have just checked for tp_vlan_tci,
so it will work no worse than before.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
v2:  add logic to tpacket_rcv too.

:100644 100644 72bfa5a... 6d66ce1... M	include/linux/if_packet.h
:100644 100644 f9b807d... 9c2d068... M	net/packet/af_packet.c
 include/linux/if_packet.h |    1 +
 net/packet/af_packet.c    |   14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 72bfa5a..6d66ce1 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -70,6 +70,7 @@ struct tpacket_auxdata {
 #define TP_STATUS_COPY		0x2
 #define TP_STATUS_LOSING	0x4
 #define TP_STATUS_CSUMNOTREADY	0x8
+#define TP_STATUS_VLAN_VALID   0x10 /* auxdata has valid tp_vlan_tci */
 
 /* Tx ring - header status */
 #define TP_STATUS_AVAILABLE	0x0
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f9b807d..9c2d068 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -818,7 +818,12 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 			getnstimeofday(&ts);
 		h.h2->tp_sec = ts.tv_sec;
 		h.h2->tp_nsec = ts.tv_nsec;
-		h.h2->tp_vlan_tci = vlan_tx_tag_get(skb);
+		if (vlan_tx_tag_present(skb)) {
+			h.h2->tp_vlan_tci = vlan_tx_tag_get(skb);
+			status |= TP_STATUS_VLAN_VALID;
+		}
+		else
+			h.h2->tp_vlan_tci = 0;
 		hdrlen = sizeof(*h.h2);
 		break;
 	default:
@@ -1763,7 +1768,12 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		aux.tp_snaplen = skb->len;
 		aux.tp_mac = 0;
 		aux.tp_net = skb_network_offset(skb);
-		aux.tp_vlan_tci = vlan_tx_tag_get(skb);
+		if (vlan_tx_tag_present(skb)) {
+			aux.tp_vlan_tci = vlan_tx_tag_get(skb);
+			aux.tp_status |= TP_STATUS_VLAN_VALID;
+		}
+		else
+			aux.tp_vlan_tci = 0;
 
 		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
 	}
-- 
1.7.3.4

