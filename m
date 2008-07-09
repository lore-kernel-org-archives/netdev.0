From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 06/08]: vlan: clean up vlan_dev_hard_header()
Date: Wed,  9 Jul 2008 14:09:53 +0200 (MEST)
Message-ID: <20080709120953.11669.94484.sendpatchset@localhost.localdomain>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58622 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930AbYGIMJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:09:54 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: clean up vlan_dev_hard_header()

Remove some debugging and excessive comments, merge the two dev_hard_header
calls into one.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 731075279c2229b454f9441da2b6bc82a39cde67
tree 4c7354bbc74d1d75da1a8fbc79fd6d19e7ec5021
parent b7ed86e1c799275adf2d36b8801abe91ffe66aec
author Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:57:00 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:57:00 +0200

 net/8021q/vlan_dev.c |   55 ++++++++------------------------------------------
 1 files changed, 9 insertions(+), 46 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 48617c1..8cd57c4 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -256,43 +256,18 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				unsigned int len)
 {
 	struct vlan_hdr *vhdr;
+	unsigned int vhdrlen = 0;
 	u16 vlan_tci = 0;
-	int rc = 0;
-	int build_vlan_header = 0;
-
-	pr_debug("%s: skb: %p type: %hx len: %u vlan_id: %hx, daddr: %p\n",
-		 __func__, skb, type, len, vlan_dev_info(dev)->vlan_id,
-		 daddr);
+	int rc;
 
 	if (WARN_ON(skb_headroom(skb) < dev->hard_header_len))
 		return -ENOSPC;
 
-	/* build vlan header only if re_order_header flag is NOT set.  This
-	 * fixes some programs that get confused when they see a VLAN device
-	 * sending a frame that is VLAN encoded (the consensus is that the VLAN
-	 * device should look completely like an Ethernet device when the
-	 * REORDER_HEADER flag is set)	The drawback to this is some extra
-	 * header shuffling in the hard_start_xmit.  Users can turn off this
-	 * REORDER behaviour with the vconfig tool.
-	 */
-	if (!(vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR))
-		build_vlan_header = 1;
-
-	if (build_vlan_header) {
+	if (!(vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR)) {
 		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
 
-		/* build the four bytes that make this a VLAN header. */
-
-		/* Now, construct the second two bytes. This field looks
-		 * something like:
-		 * usr_priority: 3 bits	 (high bits)
-		 * CFI		 1 bit
-		 * VLAN ID	 12 bits (low bits)
-		 *
-		 */
 		vlan_tci = vlan_dev_info(dev)->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
-
 		vhdr->h_vlan_TCI = htons(vlan_tci);
 
 		/*
@@ -300,37 +275,25 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		 *  put the length in here instead. It is up to the 802.2
 		 *  layer to carry protocol information.
 		 */
-
 		if (type != ETH_P_802_3)
 			vhdr->h_vlan_encapsulated_proto = htons(type);
 		else
 			vhdr->h_vlan_encapsulated_proto = htons(len);
 
 		skb->protocol = htons(ETH_P_8021Q);
+		type = ETH_P_8021Q;
+		vhdrlen = VLAN_HLEN;
 	}
 
 	/* Before delegating work to the lower layer, enter our MAC-address */
 	if (saddr == NULL)
 		saddr = dev->dev_addr;
 
+	/* Now make the underlying real hard header */
 	dev = vlan_dev_info(dev)->real_dev;
-
-	if (build_vlan_header) {
-		/* Now make the underlying real hard header */
-		rc = dev_hard_header(skb, dev, ETH_P_8021Q, daddr, saddr,
-				     len + VLAN_HLEN);
-		if (rc > 0)
-			rc += VLAN_HLEN;
-		else if (rc < 0)
-			rc -= VLAN_HLEN;
-	} else
-		/* If here, then we'll just make a normal looking ethernet
-		 * frame, but, the hard_start_xmit method will insert the tag
-		 * (it has to be able to do this for bridged and other skbs
-		 * that don't come down the protocol stack in an orderly manner.
-		 */
-		rc = dev_hard_header(skb, dev, type, daddr, saddr, len);
-
+	rc = dev_hard_header(skb, dev, type, daddr, saddr, len + vhdrlen);
+	if (rc > 0)
+		rc += vhdrlen;
 	return rc;
 }
 
