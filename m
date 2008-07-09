From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 04/08]: packet: deliver VLAN TCI to userspace
Date: Wed,  9 Jul 2008 14:09:51 +0200 (MEST)
Message-ID: <20080709120950.11669.98921.sendpatchset@localhost.localdomain>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58622 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590AbYGIMJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:09:52 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

packet: deliver VLAN TCI to userspace

Store the VLAN tag in the auxillary data/tpacket2_hdr so userspace can properly
deal with hardware VLAN tagging/stripping.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 1e655d00db6762d05f8d99912a70f58fe4c4f977
tree 605cd8de3e2752890703706e7dd9acaaadcf5324
parent 67facd0da49b1c2061e17a6623904f675d0b1bc9
author Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:56:52 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:56:52 +0200

 include/linux/if_packet.h |    2 ++
 net/packet/af_packet.c    |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index d4d3c82..a630295 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -59,6 +59,7 @@ struct tpacket_auxdata
 	__u32		tp_snaplen;
 	__u16		tp_mac;
 	__u16		tp_net;
+	__u16		tp_vlan_tci;
 };
 
 struct tpacket_hdr
@@ -90,6 +91,7 @@ struct tpacket2_hdr
 	__u16		tp_net;
 	__u32		tp_sec;
 	__u32		tp_nsec;
+	__u16		tp_vlan_tci;
 };
 
 #define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr)) + sizeof(struct sockaddr_ll))
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 85ab3e3..250e9b8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -702,6 +702,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 			getnstimeofday(&ts);
 		h.h2->tp_sec = ts.tv_sec;
 		h.h2->tp_nsec = ts.tv_nsec;
+		h.h2->tp_vlan_tci = skb->vlan_tci;
 		hdrlen = sizeof(*h.h2);
 		break;
 	default:
@@ -1172,6 +1173,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		aux.tp_snaplen = skb->len;
 		aux.tp_mac = 0;
 		aux.tp_net = skb_network_offset(skb);
+		aux.tp_vlan_tci = skb->vlan_tci;
 
 		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
 	}
