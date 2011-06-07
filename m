From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] af_packet: prevent information leak
Date: Tue, 07 Jun 2011 07:02:19 +0200
Message-ID: <1307422939.2642.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36249 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952Ab1FGFCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 01:02:23 -0400
Received: by wya21 with SMTP id 21so3275311wya.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 22:02:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 2.6.27, commit 393e52e33c6c2 (packet: deliver VLAN TCI to userspace)
added a small information leak.

Add padding field and make sure its zeroed before copy to user.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
---
 include/linux/if_packet.h |    2 ++
 net/packet/af_packet.c    |    2 ++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 6d66ce1..7b31863 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -62,6 +62,7 @@ struct tpacket_auxdata {
 	__u16		tp_mac;
 	__u16		tp_net;
 	__u16		tp_vlan_tci;
+	__u16		tp_padding;
 };
 
 /* Rx ring - header status */
@@ -101,6 +102,7 @@ struct tpacket2_hdr {
 	__u32		tp_sec;
 	__u32		tp_nsec;
 	__u16		tp_vlan_tci;
+	__u16		tp_padding;
 };
 
 #define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr)) + sizeof(struct sockaddr_ll))
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ba248d9..c0c3cda 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -804,6 +804,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		} else {
 			h.h2->tp_vlan_tci = 0;
 		}
+		h.h2->tp_padding = 0;
 		hdrlen = sizeof(*h.h2);
 		break;
 	default:
@@ -1736,6 +1737,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		} else {
 			aux.tp_vlan_tci = 0;
 		}
+		aux.tp_padding = 0;
 		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
 	}
 


