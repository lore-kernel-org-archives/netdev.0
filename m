From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next v5 12/14] bridge: Implement vlan ingress/egress policy
Date: Wed,  9 Jan 2013 12:18:00 -0500
Message-ID: <1357751882-8619-14-git-send-email-vyasevic@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932308Ab3AIRS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 12:18:28 -0500
In-Reply-To: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the ingress/egress policy.  At ingress,
any untagged traffic is assigned to the PVID.  Any tagged
traffic is filtered according to membership bitmap.  The vlan
is cached in the skb.

At egress, if we haven't cached the vlan (traffic arrived on vlan
unaware interface), we try to find the vlan for egress port and
cache it.  If the egress port is vlan unaware, packet is forwared
as is.

When we do have the vlan cached, we check to see the "untagged"
bitmap to see if the traffic is supposed to leave untagged.  Otherwise
the traffic will leave with the vlan tag set.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c    |    1 +
 net/bridge/br_forward.c   |  107 +++++++++++++++++++++++++++++++++++++++++++--
 net/bridge/br_input.c     |   33 ++++++++++++--
 net/bridge/br_multicast.c |   37 +++++++++------
 net/bridge/br_private.h   |   19 +++++---
 5 files changed, 167 insertions(+), 30 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e0814ce..fc73538 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -46,6 +46,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
+	memset(BR_INPUT_SKB_CB(skb), 0, sizeof(struct br_input_skb_cb));
 	if (!br_allowed_ingress(&br->vlan_info, skb, &vid))
 		goto out;
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d95a30f..0597fd6 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -31,7 +31,7 @@ bool br_allowed_egress(const struct net_port_vlans *v,
 {
 	struct net_port_vlan *pve;
 	struct net_bridge_vlan *vlan = NULL;
-	u16 vid;
+	u16 vid = 0;
 
 	if (list_empty(&v->vlan_list))
 		return true;
@@ -47,16 +47,107 @@ bool br_allowed_egress(const struct net_port_vlans *v,
 	}
 
 	/* We don't have cached vlan information, so we need to do
-	 * it the hard way.
+	 * it the hard way.  Cache the vlan so we can check egress
+	 * policy later.
 	 */
-	vid = br_get_vlan(skb);
+	br_get_vlan(skb, &vid);
 	pve = nbp_vlan_find(v, vid);
-	if (pve)
+	if (pve) {
+		BR_INPUT_SKB_CB(skb)->vlan = rcu_dereference(pve->vlan);
 		return true;
+	}
 
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
+		goto err_free;
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
+err_free:
+	kfree_skb(skb);
+	return NULL;
+}
+
+struct sk_buff *br_handle_vlan(const struct net_port_vlans *pv,
+			       struct sk_buff *skb)
+{
+	struct net_bridge_vlan *skb_vlan = BR_INPUT_SKB_CB(skb)->vlan;
+
+	/* If there is no vlan policy on the egress port,
+	 * leave according to ingress policy.
+	 */
+	if (list_empty(&pv->vlan_list)) {
+		if (BR_INPUT_SKB_CB(skb)->untagged)
+			skb->vlan_tci = 0;
+		goto out;
+	}
+
+	/* Egress policy is provided by the vlan bitmaps.  We
+	 * are here since we are allowed to egress according to
+	 * the vlan membership.  Now consult the untagged bitmap to
+	 * see if we should be leaving untagged.
+	 */
+	if (test_bit(pv->port_idx, skb_vlan->untagged_bitmap))
+		skb = br_vlan_untag(skb);
+	else {
+		/* Egress policy says "send tagged".  If output device is the
+		 * bridge, we need to add the VLAN header ourselves since we'll
+		 * be going through the RX path.  Sending to ports puts
+		 * the frame on the TX path and  we let dev_hard_start_xmit()
+		 * add the header.
+		 */
+		if (skb->protocol != htons(ETH_P_8021Q) &&
+		    pv->port_idx == 0) {
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
+	}
+
+out:
+	return skb;
+}
+
 /* Don't forward packets to originating port or forwarding diasabled */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
@@ -95,6 +186,10 @@ int br_forward_finish(struct sk_buff *skb)
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
+	skb = br_handle_vlan(&to->vlan_info, skb);
+	if (!skb)
+		return;
+
 	skb->dev = to->dev;
 
 	if (unlikely(netpoll_tx_running(to->br->dev))) {
@@ -120,6 +215,10 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
+	skb = br_handle_vlan(&to->vlan_info, skb);
+	if (!skb)
+		return;
+
 	indev = skb->dev;
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 62173a5..3ebaf5d 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -45,6 +45,10 @@ static int br_pass_frame_up(struct sk_buff *skb)
 		return NET_RX_DROP;
 	}
 
+	skb = br_handle_vlan(&br->vlan_info, skb);
+	if (!skb)
+		return NET_RX_DROP;
+
 	indev = skb->dev;
 	skb->dev = brdev;
 
@@ -56,15 +60,33 @@ bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb, u16 *vid)
 {
 	struct net_port_vlan *pve;
 
-	BR_INPUT_SKB_CB(skb)->vlan = NULL;
-
 	/* If there are no vlan in the permitted list, all packets are
 	 * permitted.
 	 */
 	if (list_empty(&v->vlan_list))
 		return true;
 
-	*vid = br_get_vlan(skb);
+	if (br_get_vlan(skb, vid)) {
+		struct net_bridge_vlan *pvlan = rcu_dereference(v->pvlan);
+		u16 pvid;
+
+		/* Frame did not have a tag.  See if pvid is set
+		 * on this port.  That tells us which vlan untagged
+		 * traffic belongs to.
+		 */
+		if (!pvlan || (pvid = pvlan->vid) == BR_INVALID_VID)
+			return false;
+
+		/* PVID is set on this port.  Any untagged ingress
+		 * frame is considered to belong to this vlan.
+		 */
+		__vlan_hwaccel_put_tag(skb, pvid);
+		BR_INPUT_SKB_CB(skb)->vlan = pvlan;
+		BR_INPUT_SKB_CB(skb)->untagged = 1;
+		return true;
+	}
+
+	/* Frame had a valid vlan tag.  Find the VLAN it belongs to */
 	pve = nbp_vlan_find(v, *vid);
 	if (pve) {
 		BR_INPUT_SKB_CB(skb)->vlan = rcu_dereference(pve->vlan);
@@ -88,6 +110,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
+	memset(BR_INPUT_SKB_CB(skb), 0, sizeof(struct br_input_skb_cb));
 	if (!br_allowed_ingress(&p->vlan_info, skb, &vid))
 		goto drop;
 
@@ -157,8 +180,10 @@ drop:
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
index 9c0ac97..c2259b2 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -907,6 +907,7 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 	int type;
 	int err = 0;
 	__be32 group;
+	u16 vid = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*ih)))
 		return -EINVAL;
@@ -942,8 +943,8 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 			continue;
 		}
 
-		err = br_ip4_multicast_add_group(br, port, group,
-						 br_get_vlan(skb));
+		br_get_vlan(skb, &vid);
+		err = br_ip4_multicast_add_group(br, port, group, vid);
 		if (err)
 			break;
 	}
@@ -962,6 +963,7 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 	int len;
 	int num;
 	int err = 0;
+	u16 vid = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*icmp6h)))
 		return -EINVAL;
@@ -1003,8 +1005,9 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 			continue;
 		}
 
+		br_get_vlan(skb, &vid);
 		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca,
-						 br_get_vlan(skb));
+						 vid);
 		if (!err)
 			break;
 	}
@@ -1088,6 +1091,7 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	unsigned long now = jiffies;
 	__be32 group;
 	int err = 0;
+	u16 vid = 0;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
@@ -1122,8 +1126,8 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group,
-			    br_get_vlan(skb));
+	br_get_vlan(skb, &vid);
+	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group, vid);
 	if (!mp)
 		goto out;
 
@@ -1164,6 +1168,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	unsigned long now = jiffies;
 	const struct in6_addr *group = NULL;
 	int err = 0;
+	u16 vid = 0;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
@@ -1195,8 +1200,8 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group,
-			    br_get_vlan(skb));
+	br_get_vlan(skb, &vid);
+	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group, vid);
 	if (!mp)
 		goto out;
 
@@ -1346,6 +1351,7 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	unsigned int len;
 	unsigned int offset;
 	int err;
+	u16 vid = 0;
 
 	/* We treat OOM as packet loss for now. */
 	if (!pskb_may_pull(skb, sizeof(*iph)))
@@ -1413,8 +1419,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
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
@@ -1423,8 +1429,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		err = br_ip4_multicast_query(br, port, skb2);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
-		br_ip4_multicast_leave_group(br, port, ih->group,
-					     br_get_vlan(skb2));
+		vid = br_get_vlan(skb2, &vid);
+		br_ip4_multicast_leave_group(br, port, ih->group, vid);
 		break;
 	}
 
@@ -1449,6 +1455,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	unsigned int len;
 	int offset;
 	int err;
+	u16 vid = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*ip6h)))
 		return -EINVAL;
@@ -1544,8 +1551,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
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
@@ -1562,8 +1569,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
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
index 2e3317a..bc5a321 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -216,18 +216,20 @@ static inline struct net_bridge_port *vlans_to_port(struct net_port_vlans *vlans
 	return p;
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
@@ -335,6 +337,7 @@ static inline struct net_bridge *vlans_to_bridge(struct net_port_vlans *vlans)
 struct br_input_skb_cb {
 	struct net_device *brdev;
 	struct net_bridge_vlan *vlan;
+	int untagged;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
 	int mrouters_only;
@@ -463,6 +466,8 @@ extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 			     struct sk_buff *skb2);
 extern bool br_allowed_egress(const struct net_port_vlans *v,
 			      const struct sk_buff *skb);
+extern struct sk_buff *br_handle_vlan(const struct net_port_vlans *v,
+				      struct sk_buff *skb);
 
 /* br_if.c */
 extern void br_port_carrier_check(struct net_bridge_port *p);
-- 
1.7.7.6
