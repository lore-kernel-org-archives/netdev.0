From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] net: add ETH_P_802_3_MIN
Date: Thu, 21 Mar 2013 17:29:28 +0900
Message-ID: <1363854568-32228-1-git-send-email-horms@verge.net.au>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Jesse Gross <jesse@nicira.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	linux1394-devel@lists.sourceforge.net, linux-media@vger.kernel.org,
	dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51770 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356Ab3CUIaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 04:30:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new constant ETH_P_802_3_MIN, the minimum ethernet type for
an 802.3 frame. Frames with a lower value in the ethernet type field
are Ethernet II.

Also update all the users of this value that I could find to use the
new constant.

I anticipate adding some more users of this constant when
adding MPLS support to Open vSwtich.

As suggested by Jesse Gross.

Compile tested only.

Cc: Jesse Gross <jesse@nicira.com>
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
Cc: linux1394-devel@lists.sourceforge.net
Cc: linux-media@vger.kernel.org
Cc: dev@openvswitch.org
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 drivers/firewire/net.c           |    2 +-
 drivers/isdn/i4l/isdn_net.c      |    2 +-
 drivers/media/dvb-core/dvb_net.c |    6 +++---
 drivers/net/ethernet/sun/niu.c   |    2 +-
 drivers/net/plip/plip.c          |    2 +-
 include/uapi/linux/if_ether.h    |    3 +++
 net/ethernet/eth.c               |    2 +-
 net/openvswitch/datapath.c       |    2 +-
 8 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 2b27bff..bd34ca1 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -630,7 +630,7 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 			if (memcmp(eth->h_dest, net->dev_addr, net->addr_len))
 				skb->pkt_type = PACKET_OTHERHOST;
 		}
-		if (ntohs(eth->h_proto) >= 1536) {
+		if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN) {
 			protocol = eth->h_proto;
 		} else {
 			rawp = (u16 *)skb->data;
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index babc621..88d657d 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1385,7 +1385,7 @@ isdn_net_type_trans(struct sk_buff *skb, struct net_device *dev)
 		if (memcmp(eth->h_dest, dev->dev_addr, ETH_ALEN))
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		return eth->h_proto;
 
 	rawp = skb->data;
diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
index 44225b1..9fc82a1 100644
--- a/drivers/media/dvb-core/dvb_net.c
+++ b/drivers/media/dvb-core/dvb_net.c
@@ -185,7 +185,7 @@ static __be16 dvb_net_eth_type_trans(struct sk_buff *skb,
 			skb->pkt_type=PACKET_MULTICAST;
 	}
 
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		return eth->h_proto;
 
 	rawp = skb->data;
@@ -228,9 +228,9 @@ static int ule_test_sndu( struct dvb_net_priv *p )
 static int ule_bridged_sndu( struct dvb_net_priv *p )
 {
 	struct ethhdr *hdr = (struct ethhdr*) p->ule_next_hdr;
-	if(ntohs(hdr->h_proto) < 1536) {
+	if(ntohs(hdr->h_proto) < ETH_P_802_3_MIN) {
 		int framelen = p->ule_sndu_len - ((p->ule_next_hdr+sizeof(struct ethhdr)) - p->ule_skb->data);
-		/* A frame Type < 1536 for a bridged frame, introduces a LLC Length field. */
+		/* A frame Type < ETH_P_802_3_MIN for a bridged frame, introduces a LLC Length field. */
 		if(framelen != ntohs(hdr->h_proto)) {
 			return -1;
 		}
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index e4c1c88..95cff98 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6618,7 +6618,7 @@ static u64 niu_compute_tx_flags(struct sk_buff *skb, struct ethhdr *ehdr,
 	       (len << TXHDR_LEN_SHIFT) |
 	       ((l3off / 2) << TXHDR_L3START_SHIFT) |
 	       (ihl << TXHDR_IHL_SHIFT) |
-	       ((eth_proto_inner < 1536) ? TXHDR_LLC : 0) |
+	       ((eth_proto_inner < ETH_P_802_3_MIN) ? TXHDR_LLC : 0) |
 	       ((eth_proto == ETH_P_8021Q) ? TXHDR_VLAN : 0) |
 	       (ipv6 ? TXHDR_IP_VER : 0) |
 	       csum_bits);
diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index bed62d9..1f7bef9 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -560,7 +560,7 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 *	so don't forget to remove it.
 	 */
 
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		return eth->h_proto;
 
 	rawp = skb->data;
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 798032d..ade07f1 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -94,6 +94,9 @@
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_AF_IUCV   0xFBFB		/* IBM af_iucv [ NOT AN OFFICIALLY REGISTERED ID ] */
 
+#define ETH_P_802_3_MIN	0x0600		/* If the value in the ethernet type is less than this value
+					 * then the frame is Ethernet II. Else it is 802.3 */
+
 /*
  *	Non DIX types. Won't clash for 1500 types.
  */
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a36c85ea..5359560 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -195,7 +195,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	if (netdev_uses_trailer_tags(dev))
 		return htons(ETH_P_TRAILER);
 
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		return eth->h_proto;
 
 	/*
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d61cd99..8759265 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -681,7 +681,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	/* Normally, setting the skb 'protocol' field would be handled by a
 	 * call to eth_type_trans(), but it assumes there's a sending
 	 * device, which we may not have. */
-	if (ntohs(eth->h_proto) >= 1536)
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
 		packet->protocol = eth->h_proto;
 	else
 		packet->protocol = htons(ETH_P_802_2);
-- 
1.7.10.4
