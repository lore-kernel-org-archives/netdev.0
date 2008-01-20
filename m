From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 17/18]: Clean up vlan_skb_recv()
Date: Sun, 20 Jan 2008 18:11:41 +0100 (MET)
Message-ID: <20080120171140.7980.20616.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62382 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754449AbYATRLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:42 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Clean up vlan_skb_recv()

- remove three instances of identical code
- remove unnecessary NULL initialization
- remove obvious and unnecessary comments

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c314238cb2135e4bb812487ed47652a5e2e4b748
tree 42969440a4ea33d5addcbbce4758ed5f377b4a7e
parent e7e221b07c3a3f77df617232ea0f76094edc1071
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:32 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:32 +0100

 net/8021q/vlan_dev.c |  113 +++++++++++---------------------------------------
 1 files changed, 24 insertions(+), 89 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index e19e491..57799af 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -114,77 +114,49 @@ static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
 int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev)
 {
-	unsigned char *rawp = NULL;
+	unsigned char *rawp;
 	struct vlan_hdr *vhdr;
 	unsigned short vid;
 	struct net_device_stats *stats;
 	unsigned short vlan_TCI;
 	__be16 proto;
 
-	if (dev->nd_net != &init_net) {
-		kfree_skb(skb);
-		return -1;
-	}
+	if (dev->nd_net != &init_net)
+		goto err_free;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (skb == NULL)
-		return -1;
-
-	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN))) {
-		kfree_skb(skb);
-		return -1;
-	}
+		goto err_free;
 
-	vhdr = (struct vlan_hdr *)(skb->data);
+	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN)))
+		goto err_free;
 
-	/* vlan_TCI = ntohs(get_unaligned(&vhdr->h_vlan_TCI)); */
+	vhdr = (struct vlan_hdr *)skb->data;
 	vlan_TCI = ntohs(vhdr->h_vlan_TCI);
-
 	vid = (vlan_TCI & VLAN_VID_MASK);
 
-	/* Ok, we will find the correct VLAN device, strip the header,
-	 * and then go on as usual.
-	 */
-
-	/* We have 12 bits of vlan ID.
-	 *
-	 * We must not drop allow preempt until we hold a
-	 * reference to the device (netif_rx does that) or we
-	 * fail.
-	 */
-
 	rcu_read_lock();
 	skb->dev = __find_vlan_dev(dev, vid);
 	if (!skb->dev) {
-		rcu_read_unlock();
 		pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
 			 __FUNCTION__, (unsigned int)vid, dev->name);
-		kfree_skb(skb);
-		return -1;
+		goto err_unlock;
 	}
 
 	skb->dev->last_rx = jiffies;
 
-	/* Bump the rx counters for the VLAN device. */
 	stats = &skb->dev->stats;
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 
-	/* Take off the VLAN header (4 bytes currently) */
 	skb_pull_rcsum(skb, VLAN_HLEN);
 
-	/*
-	 * Deal with ingress priority mapping.
-	 */
 	skb->priority = vlan_get_ingress_priority(skb->dev,
 						  ntohs(vhdr->h_vlan_TCI));
 
 	pr_debug("%s: priority: %u for TCI: %hu\n",
 		 __FUNCTION__, skb->priority, ntohs(vhdr->h_vlan_TCI));
 
-	/* The ethernet driver already did the pkt_type calculations
-	 * for us...
-	 */
 	switch (skb->pkt_type) {
 	case PACKET_BROADCAST: /* Yeah, stats collect these together.. */
 		/* stats->broadcast ++; // no such counter :-( */
@@ -201,7 +173,6 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		 */
 		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
 					skb->dev->dev_addr))
-			/* It is for our (changed) MAC-address! */
 			skb->pkt_type = PACKET_HOST;
 		break;
 	default:
@@ -211,81 +182,45 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	/*  Was a VLAN packet, grab the encapsulated protocol, which the layer
 	 * three protocols care about.
 	 */
-	/* proto = get_unaligned(&vhdr->h_vlan_encapsulated_proto); */
 	proto = vhdr->h_vlan_encapsulated_proto;
-
-	skb->protocol = proto;
 	if (ntohs(proto) >= 1536) {
-		/* place it back on the queue to be handled by
-		 * true layer 3 protocols.
-		 */
-
-		/* See if we are configured to re-write the VLAN header
-		 * to make it look like ethernet...
-		 */
-		skb = vlan_check_reorder_header(skb);
-
-		/* Can be null if skb-clone fails when re-ordering */
-		if (skb) {
-			netif_rx(skb);
-		} else {
-			/* TODO:  Add a more specific counter here. */
-			stats->rx_errors++;
-		}
-		rcu_read_unlock();
-		return 0;
+		skb->protocol = proto;
+		goto recv;
 	}
 
-	rawp = skb->data;
-
 	/*
 	 * This is a magic hack to spot IPX packets. Older Novell breaks
 	 * the protocol design and runs IPX over 802.3 without an 802.2 LLC
 	 * layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
 	 * won't work for fault tolerant netware but does for the rest.
 	 */
+	rawp = skb->data;
 	if (*(unsigned short *)rawp == 0xFFFF) {
 		skb->protocol = htons(ETH_P_802_3);
-		/* place it back on the queue to be handled by true layer 3
-		 * protocols. */
-
-		/* See if we are configured to re-write the VLAN header
-		 * to make it look like ethernet...
-		 */
-		skb = vlan_check_reorder_header(skb);
-
-		/* Can be null if skb-clone fails when re-ordering */
-		if (skb) {
-			netif_rx(skb);
-		} else {
-			/* TODO:  Add a more specific counter here. */
-			stats->rx_errors++;
-		}
-		rcu_read_unlock();
-		return 0;
+		goto recv;
 	}
 
 	/*
 	 *	Real 802.2 LLC
 	 */
 	skb->protocol = htons(ETH_P_802_2);
-	/* place it back on the queue to be handled by upper layer protocols.
-	 */
 
-	/* See if we are configured to re-write the VLAN header
-	 * to make it look like ethernet...
-	 */
+recv:
 	skb = vlan_check_reorder_header(skb);
-
-	/* Can be null if skb-clone fails when re-ordering */
-	if (skb) {
-		netif_rx(skb);
-	} else {
-		/* TODO:  Add a more specific counter here. */
+	if (!skb) {
 		stats->rx_errors++;
+		goto err_unlock;
 	}
+
+	netif_rx(skb);
 	rcu_read_unlock();
-	return 0;
+	return NET_RX_SUCCESS;
+
+err_unlock:
+	rcu_read_unlock();
+err_free:
+	kfree_skb(skb);
+	return NET_RX_DROP;
 }
 
 static inline unsigned short
