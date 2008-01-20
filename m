From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 18/18]: Move protocol determination to seperate function
Date: Sun, 20 Jan 2008 18:11:42 +0100 (MET)
Message-ID: <20080120171142.7980.54350.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62385 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754367AbYATRLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:44 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Move protocol determination to seperate function

I think, that we can make this code flow easier to understand
by introducing the vlan_set_encap_proto() function (I hope the
name is good) to setup the skb proto and merge the paths calling
netif_rx() together.

[Patrick: Modified to apply on top of my previous patches]

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0e185e8a940c2780362ff815cfe638e7d1269972
tree 62b8568718057b7a12375c34af01d95bae463240
parent c314238cb2135e4bb812487ed47652a5e2e4b748
author Pavel Emelyanov <xemul@openvz.org> Sun, 20 Jan 2008 17:37:32 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:32 +0100

 net/8021q/vlan_dev.c |   63 ++++++++++++++++++++++++++++----------------------
 1 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 57799af..8059fa4 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -89,6 +89,40 @@ static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
 	return skb;
 }
 
+static inline void vlan_set_encap_proto(struct sk_buff *skb,
+		struct vlan_hdr *vhdr)
+{
+	__be16 proto;
+	unsigned char *rawp;
+
+	/*
+	 * Was a VLAN packet, grab the encapsulated protocol, which the layer
+	 * three protocols care about.
+	 */
+
+	proto = vhdr->h_vlan_encapsulated_proto;
+	if (ntohs(proto) >= 1536) {
+		skb->protocol = proto;
+		return;
+	}
+
+	rawp = skb->data;
+	if (*(unsigned short *)rawp == 0xFFFF)
+		/*
+		 * This is a magic hack to spot IPX packets. Older Novell
+		 * breaks the protocol design and runs IPX over 802.3 without
+		 * an 802.2 LLC layer. We look for FFFF which isn't a used
+		 * 802.2 SSAP/DSAP. This won't work for fault tolerant netware
+		 * but does for the rest.
+		 */
+		skb->protocol = htons(ETH_P_802_3);
+	else
+		/*
+		 * Real 802.2 LLC
+		 */
+		skb->protocol = htons(ETH_P_802_2);
+}
+
 /*
  *	Determine the packet's protocol ID. The rule here is that we
  *	assume 802.3 if the type field is short enough to be a length.
@@ -114,12 +148,10 @@ static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
 int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev)
 {
-	unsigned char *rawp;
 	struct vlan_hdr *vhdr;
 	unsigned short vid;
 	struct net_device_stats *stats;
 	unsigned short vlan_TCI;
-	__be16 proto;
 
 	if (dev->nd_net != &init_net)
 		goto err_free;
@@ -179,33 +211,8 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		break;
 	}
 
-	/*  Was a VLAN packet, grab the encapsulated protocol, which the layer
-	 * three protocols care about.
-	 */
-	proto = vhdr->h_vlan_encapsulated_proto;
-	if (ntohs(proto) >= 1536) {
-		skb->protocol = proto;
-		goto recv;
-	}
-
-	/*
-	 * This is a magic hack to spot IPX packets. Older Novell breaks
-	 * the protocol design and runs IPX over 802.3 without an 802.2 LLC
-	 * layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
-	 * won't work for fault tolerant netware but does for the rest.
-	 */
-	rawp = skb->data;
-	if (*(unsigned short *)rawp == 0xFFFF) {
-		skb->protocol = htons(ETH_P_802_3);
-		goto recv;
-	}
-
-	/*
-	 *	Real 802.2 LLC
-	 */
-	skb->protocol = htons(ETH_P_802_2);
+	vlan_set_encap_proto(skb, vhdr);
 
-recv:
 	skb = vlan_check_reorder_header(skb);
 	if (!skb) {
 		stats->rx_errors++;
