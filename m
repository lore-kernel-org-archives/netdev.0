From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC][net-next-2.6 PATCH 2/4] net: 8021Q consolidate header_ops
	routines
Date: Thu, 21 Oct 2010 15:10:10 -0700
Message-ID: <20101021221010.22906.60238.stgit@jf-dev1-dcblab>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41308 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753720Ab0JUWNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 18:13:40 -0400
In-Reply-To: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only thing the 8021Q header ops routines are required
for is the VLAN_FLAG_REORDER_HDR otherwise by the time
the VLAN tag has been added the packet is already on
its way down the stack. In this case using the Ethernet
ops works OK.

At present the VLAN_FLAG_REORDER_HDR flag does not work
with vlan offloads. As I understand the flag the intent
is to allow taps on the vlan device and possibly the
QOS layer to see the vlan tag info.

By inserting the tag in vlan_tci any taps or QOS policies
should be able to retrieve the vlan info. This allows
the flag to work the same in both the offload case and
non-offloaded case. And allows us to use the underlying
ethernet ops.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/8021q/vlan_dev.c |   83 +++++++++++++-------------------------------------
 1 files changed, 21 insertions(+), 62 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 78b1618..1645c3c 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -32,39 +32,6 @@
 #include "vlanproc.h"
 #include <linux/if_vlan.h>
 
-/*
- *	Rebuild the Ethernet MAC header. This is called after an ARP
- *	(or in future other address resolution) has completed on this
- *	sk_buff. We now let ARP fill in the other fields.
- *
- *	This routine CANNOT use cached dst->neigh!
- *	Really, it is used only when dst->neigh is wrong.
- *
- * TODO:  This needs a checkup, I'm ignorant here. --BLG
- */
-static int vlan_dev_rebuild_header(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
-
-	switch (veth->h_vlan_encapsulated_proto) {
-#ifdef CONFIG_INET
-	case htons(ETH_P_IP):
-
-		/* TODO:  Confirm this will work with VLAN headers... */
-		return arp_find(veth->h_dest, skb);
-#endif
-	default:
-		pr_debug("%s: unable to resolve type %X addresses.\n",
-			 dev->name, ntohs(veth->h_vlan_encapsulated_proto));
-
-		memcpy(veth->h_source, dev->dev_addr, ETH_ALEN);
-		break;
-	}
-
-	return 0;
-}
-
 static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
 {
 	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
@@ -269,33 +236,26 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				const void *daddr, const void *saddr,
 				unsigned int len)
 {
-	struct vlan_hdr *vhdr;
-	unsigned int vhdrlen = 0;
-	u16 vlan_tci = 0;
 	int rc;
 
 	if (WARN_ON(skb_headroom(skb) < dev->hard_header_len))
 		return -ENOSPC;
 
+	/* When this flag is not set we make the vlan_tci visible
+	 * by setting the skb field.
+	 *
+	 * We do not immediately insert the tag here the intent
+	 * of setting VLAN_FLAG_REORDER_HDR is to make the vlan
+	 * info avaiable to tap devices and the QOS layer. Adding
+	 * the tag present bit shoould be enough for other layers
+	 * to learn the vlan tag.
+	 */
 	if (!(vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR)) {
-		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
+		u16 vlan_tci = 0;
 
 		vlan_tci = vlan_dev_info(dev)->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
-		vhdr->h_vlan_TCI = htons(vlan_tci);
-
-		/*
-		 *  Set the protocol type. For a packet of type ETH_P_802_3/2 we
-		 *  put the length in here instead.
-		 */
-		if (type != ETH_P_802_3 && type != ETH_P_802_2)
-			vhdr->h_vlan_encapsulated_proto = htons(type);
-		else
-			vhdr->h_vlan_encapsulated_proto = htons(len);
-
-		skb->protocol = htons(ETH_P_8021Q);
-		type = ETH_P_8021Q;
-		vhdrlen = VLAN_HLEN;
+		skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
 	}
 
 	/* Before delegating work to the lower layer, enter our MAC-address */
@@ -304,9 +264,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 
 	/* Now make the underlying real hard header */
 	dev = vlan_dev_info(dev)->real_dev;
-	rc = dev_hard_header(skb, dev, type, daddr, saddr, len + vhdrlen);
-	if (rc > 0)
-		rc += vhdrlen;
+	rc = dev_hard_header(skb, dev, type, daddr, saddr, len);
 	return rc;
 }
 
@@ -676,9 +634,11 @@ static void vlan_dev_set_lockdep_class(struct net_device *dev, int subclass)
 }
 
 static const struct header_ops vlan_header_ops = {
-	.create	 = vlan_dev_hard_header,
-	.rebuild = vlan_dev_rebuild_header,
-	.parse	 = eth_header_parse,
+	.create		= vlan_dev_hard_header,
+	.rebuild	= eth_rebuild_header,
+	.parse		= eth_header_parse,
+	.cache		= eth_header_cache,
+	.cache_update	= eth_header_cache_update,
 };
 
 static const struct net_device_ops vlan_netdev_ops, vlan_netdev_ops_sq;
@@ -713,13 +673,12 @@ static int vlan_dev_init(struct net_device *dev)
 	dev->fcoe_ddp_xid = real_dev->fcoe_ddp_xid;
 #endif
 
-	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
-		dev->header_ops      = real_dev->header_ops;
+	dev->header_ops = &vlan_header_ops;
+
+	if (real_dev->features & NETIF_F_HW_VLAN_TX)
 		dev->hard_header_len = real_dev->hard_header_len;
-	} else {
-		dev->header_ops      = &vlan_header_ops;
+	else
 		dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
-	}
 
 	if (real_dev->netdev_ops->ndo_select_queue)
 		dev->netdev_ops = &vlan_netdev_ops_sq;

