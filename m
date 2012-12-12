From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 10/11] bridge: Implement untagged vlan handling
Date: Wed, 12 Dec 2012 15:01:16 -0500
Message-ID: <1355342477-4971-11-git-send-email-vyasevic@redhat.com>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, mst@redhat.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7060 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755204Ab2LLUBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 15:01:41 -0500
In-Reply-To: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an untagged frame arrives on a port that has untagged vlan set,
the frame is assigned to the untagged VLAN.  It will then procede
through the forwarding/egress process with the VLAN id set to the
untagged VLAN.

At egress, a frame with a VLAN id matching untagged vid will have its
vlan header stripped off.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c    |   25 +++++++++--
 net/bridge/br_forward.c   |  111 ++++++++++++++++++++++++++++++++++++++++++++-
 net/bridge/br_input.c     |   46 +++++++++++++++----
 net/bridge/br_multicast.c |   37 +++++++++------
 net/bridge/br_private.h   |   20 +++++---
 5 files changed, 202 insertions(+), 37 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 1f9d0f9..e96d58a 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -31,7 +31,8 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_bridge_mdb_entry *mdst;
 	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
 	struct net_bridge_vlan *vlan;
-	u16 vid;
+	struct br_input_skb_cb *brcb;
+	u16 vid = 0;
 
 	rcu_read_lock();
 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -47,15 +48,31 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
-	BR_INPUT_SKB_CB(skb)->brdev = dev;
+	brcb = BR_INPUT_SKB_CB(skb);
+	memset(brcb, 0, sizeof(struct br_input_skb_cb));
+	brcb->brdev = dev;
+
+	if (br_get_vlan(skb, &vid)) {
+		u16 untagged_vid;
+
+		/* Untagged frame.  See if there is an untagged VLAN
+		 * configured.
+		 */
+		if ((vlan = rcu_dereference(br->untagged)) != NULL &&
+	    	    (untagged_vid = vlan->vid) != BR_INVALID_VID) {
+			__vlan_hwaccel_put_tag(skb, untagged_vid);
+			brcb->untagged = 1;
+			goto skip_lookup;
+		}
+	}
 
 	/* Any vlan transmitted by the bridge itself is permitted.
 	 * Try to cache the vlan in the CB to speed up forwarding.
 	 */
-	vid = br_get_vlan(skb);
 	vlan = br_vlan_find(br, vid);
+skip_lookup:
 	if (vlan)
-		BR_INPUT_SKB_CB(skb)->vlan = vlan;
+		brcb->vlan = vlan;
 
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 4ae5f55..2170e6b 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -31,7 +31,7 @@ static inline bool br_allowed_egress(const struct net_bridge_port *p,
 {
 	struct net_port_vlan *pve;
 	struct net_bridge_vlan *vlan = NULL;
-	u16 vid;
+	u16 vid = 0;
 
 	if (list_empty(&p->vlan_list))
 		return true;
@@ -49,7 +49,7 @@ static inline bool br_allowed_egress(const struct net_bridge_port *p,
 	/* We don't have cached vlan information, so we need to do
 	 * it the hard way.
 	 */
-	vid = br_get_vlan(skb);
+	br_get_vlan(skb, &vid);
 	pve = nbp_vlan_find(p, vid);
 	if (pve)
 		return true;
@@ -57,6 +57,105 @@ static inline bool br_allowed_egress(const struct net_bridge_port *p,
 	return false;
 }
 
+/* Almost an exact copy of vlan_untag.  Needed here since it's not exported
+ * and not available if vlan support isn't built in.
+ */
+static struct sk_buff *br_vlan_untag(struct sk_buff *skb)
+{
+	struct vlan_hdr *vhdr;
+
+	if (skb->protocol != htons(ETH_P_8021Q)) {
+		skb->vlan_tci = 0;
+		return skb;
+	}
+
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
+		goto err_free;
+
+	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN)))
+		goto err_free;
+
+	vhdr = (struct vlan_hdr *)skb->data;
+	skb_pull_rcsum(skb, VLAN_HLEN);
+	vlan_set_encap_proto(skb, vhdr);
+
+	if (skb_cow(skb, skb_headroom(skb)) < 0)
+		goto err;
+
+	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
+	skb->mac_header += VLAN_HLEN;
+	skb->vlan_tci = 0;
+	
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+	skb_reset_mac_len(skb);
+
+	return skb;
+
+err:
+	kfree_skb(skb);
+	return NULL;
+}
+			
+struct sk_buff *br_handle_vlan(const struct net_bridge *br,
+			      const struct net_bridge_port *p,
+			      struct sk_buff *skb)
+{
+	struct net_bridge_vlan *untag_vlan;
+	struct net_bridge_vlan *skb_vlan = BR_INPUT_SKB_CB(skb)->vlan;
+
+	if (p)
+		untag_vlan = rcu_dereference(p->untagged);
+	else if (br)
+		untag_vlan = rcu_dereference(br->untagged);
+	else {
+		kfree_skb(skb);
+		goto out;
+	}
+
+	if (BR_INPUT_SKB_CB(skb)->untagged) {
+		/* Frame arrived on an untagged vlan. If it is leaving
+		 * on untagged interface, remove the tag we added.
+		 */
+		if (skb_vlan && untag_vlan == skb_vlan) {
+			skb->vlan_tci = 0;
+			goto out;
+		}
+
+		/* Frame leaving on a tagged vlan.  If output device is the
+		 * bridge, we need to add the VLAN header.  If we sending to
+		 * port, we let dev_hard_start_xmit() add the header.
+		 */
+		if (br && !p) {
+			/* vlan_put_tag expects skb->data to point to mac
+			 * header.
+			 */
+			skb_push(skb, ETH_HLEN);
+			skb = __vlan_put_tag(skb, skb->vlan_tci);
+			if (!skb)
+				goto out;
+			/* put skb->data back to where it was */
+			skb_pull(skb, ETH_HLEN);
+			skb->vlan_tci = 0;
+		}
+	} else {
+		/* Frame arrived on a tagged vlan.  If the outgoing port is
+		 * not untagged, leave the frame alone. If it's leaving on
+		 * a valid untagged interface, need to strip the VLAN hader
+		 */
+		if (!untag_vlan ||
+		    (untag_vlan && untag_vlan->vid == BR_INVALID_VID))
+			goto out;
+
+		skb->vlan_tci = 0;
+		skb = br_vlan_untag(skb);
+	}
+
+out:
+	return skb;
+}
+
 /* Don't forward packets to originating port or forwarding diasabled */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
@@ -97,6 +196,10 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	skb->dev = to->dev;
 
+	skb = br_handle_vlan(NULL, to, skb);
+	if (!skb)
+		return;
+
 	if (unlikely(netpoll_tx_running(to->br->dev))) {
 		if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
 			kfree_skb(skb);
@@ -120,6 +223,10 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
+	skb = br_handle_vlan(NULL, to, skb);
+	if (!skb)
+		return;
+
 	indev = skb->dev;
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index e51eb24..048266f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -35,6 +35,10 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	brstats->rx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
+	skb = br_handle_vlan(br, NULL, skb);
+	if (!skb)
+		return NET_RX_DROP;
+
 	indev = skb->dev;
 	skb->dev = brdev;
 
@@ -43,11 +47,11 @@ static int br_pass_frame_up(struct sk_buff *skb)
 }
 
 static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb,
-			       u16 vid)
+			       u16 *vid)
 {
 	struct net_port_vlan *pve;
-
-	BR_INPUT_SKB_CB(skb)->vlan = NULL;
+	struct net_bridge_vlan *vlan;
+	struct br_input_skb_cb *brcb = BR_INPUT_SKB_CB(skb);
 
 	/* If there are no vlan in the permitted list, all packets are
 	 * permitted.
@@ -55,7 +59,27 @@ static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb,
 	if (list_empty(&p->vlan_list))
 		return true;
 
-	pve = nbp_vlan_find(p, vid);
+	if (br_get_vlan(skb, vid)) {
+		u16 untagged_vid;
+		/* Frame did not have a tag. See if untagged vlan is set
+		 * on this port.
+		 */
+		if ((vlan = rcu_dereference(p->untagged)) == NULL || 
+	    	    (untagged_vid = vlan->vid) == BR_INVALID_VID)
+			return false;
+
+		/* Untagged vlan is set on this port.  Any untagged ingress
+		 * frame is considered to belong to the untagged vlan, so
+		 * mark it as such.
+		 */
+		__vlan_hwaccel_put_tag(skb, untagged_vid);
+		brcb->vlan = vlan;
+		brcb->untagged = 1;
+		return true;
+	}
+
+	/* Frame has a valid vlan tag.  Find the VLAN it belongs to. */
+	pve = nbp_vlan_find(p, *vid);
 	if (pve) {
 		BR_INPUT_SKB_CB(skb)->vlan = pve->vlan;
 		return true;
@@ -73,13 +97,15 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct sk_buff *skb2;
-	u16 vid;
+	struct br_input_skb_cb *brcb = BR_INPUT_SKB_CB(skb);
+	u16 vid = 0;
 
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
-	vid = br_get_vlan(skb);
-	if (!br_allowed_ingress(p, skb, vid))
+	memset(brcb, 0, sizeof(struct br_input_skb_cb));
+
+	if (!br_allowed_ingress(p, skb, &vid))
 		goto drop;
 
 	/* insert into forwarding database after filtering to avoid spoofing */
@@ -93,7 +119,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (p->state == BR_STATE_LEARNING)
 		goto drop;
 
-	BR_INPUT_SKB_CB(skb)->brdev = br->dev;
+	brcb->brdev = br->dev;
 
 	/* The packet skb2 goes to the local host (NULL to skip). */
 	skb2 = NULL;
@@ -148,8 +174,10 @@ drop:
 static int br_handle_local_finish(struct sk_buff *skb)
 {
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
+	u16 vid = 0;
 
-	br_fdb_update(p->br, p, eth_hdr(skb)->h_source, br_get_vlan(skb));
+	br_get_vlan(skb, &vid);
+	br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid);
 	return 0;	 /* process further */
 }
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 072aa2d..a7fc2c7 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -905,6 +905,7 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 	int type;
 	int err = 0;
 	__be32 group;
+	u16 vid = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*ih)))
 		return -EINVAL;
@@ -940,8 +941,8 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 			continue;
 		}
 
-		err = br_ip4_multicast_add_group(br, port, group,
-						 br_get_vlan(skb));
+		br_get_vlan(skb, &vid);
+		err = br_ip4_multicast_add_group(br, port, group, vid);
 		if (err)
 			break;
 	}
@@ -960,6 +961,7 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 	int len;
 	int num;
 	int err = 0;
+	u16 vid = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*icmp6h)))
 		return -EINVAL;
@@ -1001,8 +1003,9 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 			continue;
 		}
 
+		br_get_vlan(skb, &vid);
 		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca,
-						 br_get_vlan(skb));
+						 vid);
 		if (!err)
 			break;
 	}
@@ -1086,6 +1089,7 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	unsigned long now = jiffies;
 	__be32 group;
 	int err = 0;
+	u16 vid = 0;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
@@ -1120,8 +1124,8 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group,
-			    br_get_vlan(skb));
+	br_get_vlan(skb, &vid);
+	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group, vid);
 	if (!mp)
 		goto out;
 
@@ -1162,6 +1166,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	unsigned long now = jiffies;
 	const struct in6_addr *group = NULL;
 	int err = 0;
+	u16 vid = 0;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
@@ -1193,8 +1198,8 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group,
-			    br_get_vlan(skb));
+	br_get_vlan(skb, &vid);
+	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group, vid);
 	if (!mp)
 		goto out;
 
@@ -1343,6 +1348,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	unsigned int len;
 	unsigned int offset;
 	int err;
+	u16 vid = 0;
 
 	/* We treat OOM as packet loss for now. */
 	if (!pskb_may_pull(skb, sizeof(*iph)))
@@ -1410,8 +1416,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
-		err = br_ip4_multicast_add_group(br, port, ih->group,
-						 br_get_vlan(skb2));
+		vid = br_get_vlan(skb2, &vid);
+		err = br_ip4_multicast_add_group(br, port, ih->group, vid);
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
 		err = br_ip4_multicast_igmp3_report(br, port, skb2);
@@ -1420,8 +1426,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		err = br_ip4_multicast_query(br, port, skb2);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
-		br_ip4_multicast_leave_group(br, port, ih->group,
-					     br_get_vlan(skb2));
+		vid = br_get_vlan(skb2, &vid);
+		br_ip4_multicast_leave_group(br, port, ih->group, vid);
 		break;
 	}
 
@@ -1446,6 +1452,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	unsigned int len;
 	int offset;
 	int err;
+	u16 vid = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*ip6h)))
 		return -EINVAL;
@@ -1541,8 +1548,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 		}
 		mld = (struct mld_msg *)skb_transport_header(skb2);
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
-		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca,
-						 br_get_vlan(skb2));
+		br_get_vlan(skb2, &vid);
+		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca, vid);
 		break;
 	    }
 	case ICMPV6_MLD2_REPORT:
@@ -1559,8 +1566,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 			goto out;
 		}
 		mld = (struct mld_msg *)skb_transport_header(skb2);
-		br_ip6_multicast_leave_group(br, port, &mld->mld_mca,
-					     br_get_vlan(skb2));
+		br_get_vlan(skb2, &vid);
+		br_ip6_multicast_leave_group(br, port, &mld->mld_mca, vid);
 	    }
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f82d5f6..62fdf7e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -198,18 +198,20 @@ static inline struct net_bridge_port *br_port_get_rtnl(struct net_device *dev)
 		rtnl_dereference(dev->rx_handler_data) : NULL;
 }
 
-static inline u16 br_get_vlan(const struct sk_buff *skb)
+static inline int br_get_vlan(const struct sk_buff *skb, u16 *tag)
 {
-	u16 tag;
+	int rc = 0;
 
-	if (vlan_tx_tag_present(skb))
-		return vlan_tx_tag_get(skb) & VLAN_VID_MASK;
+	if (vlan_tx_tag_present(skb)) {
+		*tag = vlan_tx_tag_get(skb) & VLAN_VID_MASK;
+		return rc;
+	}
 
 	/* Untagged and VLAN 0 traffic is handled the same way */
-	if (vlan_get_tag(skb, &tag))
-		return 0;
+	rc = vlan_get_tag(skb, tag);
+	*tag = *tag & VLAN_VID_MASK;
 
-	return tag & VLAN_VID_MASK;
+	return rc;
 }
 
 struct br_cpu_netstats {
@@ -305,6 +307,7 @@ struct net_bridge
 struct br_input_skb_cb {
 	struct net_device *brdev;
 	struct net_bridge_vlan *vlan;
+	int untagged;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
 	int mrouters_only;
@@ -431,6 +434,9 @@ extern int br_forward_finish(struct sk_buff *skb);
 extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb);
 extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 			     struct sk_buff *skb2);
+extern struct sk_buff *br_handle_vlan(const struct net_bridge *br,
+				      const struct net_bridge_port *p,
+				      struct sk_buff *skb);
 
 /* br_if.c */
 extern void br_port_carrier_check(struct net_bridge_port *p);
-- 
1.7.7.6
