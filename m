From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v7 net-next 06/12] bridge: Implement vlan ingress/egress policy
Date: Wed, 30 Jan 2013 22:12:53 -0500
Message-ID: <1359601979-14942-7-git-send-email-vyasevic@redhat.com>
References: <1359601979-14942-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756348Ab3AaDNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 22:13:11 -0500
In-Reply-To: <1359601979-14942-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the ingress/egress policy.  At ingress,
any untagged traffic is assigned to the PVID.  Any tagged
traffic is filtered according to membership bitmap.

At egress, if the vlan matches the pvid, the frame is sent
untagged.  Otherwise the frame is sent tagged.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/8021q/vlan_core.c   |    1 +
 net/bridge/br_device.c  |    3 +-
 net/bridge/br_forward.c |    8 ++++
 net/bridge/br_input.c   |    7 +++-
 net/bridge/br_private.h |   38 ++++++++++++++------
 net/bridge/br_vlan.c    |   93 +++++++++++++++++++++++++++++++++++++++++++----
 6 files changed, 130 insertions(+), 20 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 71b64fd..f3b6f51 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -144,6 +144,7 @@ err_free:
 	kfree_skb(skb);
 	return NULL;
 }
+EXPORT_SYMBOL(vlan_untag);
 
 
 /*
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index d325c2d..bce7a52 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -30,6 +30,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
+	u16 vid = 0;
 
 	rcu_read_lock();
 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -45,7 +46,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
-	if (!br_allowed_ingress(br, br_get_vlan_info(br), skb))
+	if (!br_allowed_ingress(br, br_get_vlan_info(br), skb, &vid))
 		goto out;
 
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 35b0671..092b20e 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -64,6 +64,10 @@ int br_forward_finish(struct sk_buff *skb)
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
+	skb = br_handle_vlan(to->br, nbp_get_vlan_info(to), skb);
+	if (!skb)
+		return;
+
 	skb->dev = to->dev;
 
 	if (unlikely(netpoll_tx_running(to->br->dev))) {
@@ -89,6 +93,10 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
+	skb = br_handle_vlan(to->br, nbp_get_vlan_info(to), skb);
+	if (!skb)
+		return;
+
 	indev = skb->dev;
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 787d7da..a63f227 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -45,6 +45,10 @@ static int br_pass_frame_up(struct sk_buff *skb)
 		return NET_RX_DROP;
 	}
 
+	skb = br_handle_vlan(br, br_get_vlan_info(br), skb);
+	if (!skb)
+		return NET_RX_DROP;
+
 	indev = skb->dev;
 	skb->dev = brdev;
 
@@ -61,11 +65,12 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct sk_buff *skb2;
+	u16 vid = 0;
 
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
-	if (!br_allowed_ingress(p->br, nbp_get_vlan_info(p), skb))
+	if (!br_allowed_ingress(p->br, nbp_get_vlan_info(p), skb, &vid))
 		goto drop;
 
 	/* insert into forwarding database after filtering to avoid spoofing */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 108aeeb..62ff040 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -553,10 +553,13 @@ static inline void br_mdb_uninit(void)
 /* br_vlan.c */
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 extern bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
-			       struct sk_buff *skb);
+			       struct sk_buff *skb, u16 *vid);
 extern bool br_allowed_egress(struct net_bridge *br,
 			      const struct net_port_vlans *v,
 			      const struct sk_buff *skb);
+extern struct sk_buff *br_handle_vlan(struct net_bridge *br,
+				      const struct net_port_vlans *v,
+				      struct sk_buff *skb);
 extern int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
 extern int br_vlan_delete(struct net_bridge *br, u16 vid);
 extern void br_vlan_flush(struct net_bridge *br);
@@ -577,21 +580,24 @@ static inline struct net_port_vlans *nbp_get_vlan_info(
 	return rcu_dereference(p->vlan_info);
 }
 
-static inline u16 br_vlan_get_tag(const struct sk_buff *skb)
+
+static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
 {
-	u16 tag;
+	int rc = 0;
 
 	if (vlan_tx_tag_present(skb))
-		tag = vlan_tx_tag_get(skb);
-	else if (vlan_get_tag(skb, &tag))
-		tag = 0;
+		*tag = vlan_tx_tag_get(skb);
+	else
+		rc = vlan_get_tag(skb, tag);
 
-	return tag & VLAN_VID_MASK;
+	*tag = *tag & VLAN_VID_MASK;
+	return rc;
 }
 #else
 static inline bool br_allowed_ingress(struct net_bridge *br,
 				      struct net_port_vlans *v,
-				      struct sk_buff *skb)
+				      struct sk_buff *skb,
+				      u16 *vid)
 {
 	return true;
 }
@@ -603,6 +609,13 @@ static inline bool br_allowed_egress(struct net_bridge *br,
 	return true;
 }
 
+static inline struct sk_buff *br_handle_vlan(struct net_bridge *br,
+					     const struct net_port_vlans *v,
+					     struct sk_buff *skb)
+{
+	return skb;
+}
+
 static inline int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 {
 	return -EOPNOTSUPP;
@@ -631,16 +644,19 @@ static inline void nbp_vlan_flush(struct net_bridge_port *port)
 {
 }
 
-static inline struct net_port_vlans *br_get_vlan_info(struct net_bridge *br)
+static inline struct net_port_vlans *br_get_vlan_info(
+					const struct net_bridge *br)
 {
 	return NULL;
 }
-static inline struct net_port_vlans *nbp_get_vlan_info(struct net_bridge_port *p)
+
+static inline struct net_port_vlans *nbp_get_vlan_info(
+					const struct net_bridge_port *p)
 {
 	return NULL;
 }
 
-static inline u16 br_vlan_get_tag(const struct sk_buff *skb)
+static inline u16 br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
 {
 	return 0;
 }
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index f2ae529..16565d1 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -127,12 +127,74 @@ static void __vlan_flush(struct net_port_vlans *v)
 	kfree_rcu(v, rcu);
 }
 
+static inline u16 br_get_pvid(const struct net_port_vlans *v)
+{
+	smp_rmb();
+	return v->pvid;
+}
+
+/* Strip the tag from the packet.  Will return skb with tci set 0.  */
+static struct sk_buff *br_vlan_untag(struct sk_buff *skb)
+{
+	if (skb->protocol != htons(ETH_P_8021Q)) {
+		skb->vlan_tci = 0;
+		return skb;
+	}
+
+	skb->vlan_tci = 0;
+	skb = vlan_untag(skb);
+	if (skb)
+		skb->vlan_tci = 0;
+
+	return skb;
+}
+
+struct sk_buff *br_handle_vlan(struct net_bridge *br,
+			       const struct net_port_vlans *pv,
+			       struct sk_buff *skb)
+{
+	u16 vid = 0;
+
+	if (!br->vlan_enabled)
+		goto out;
+
+	/* At this point, we know that the frame was filtered and contains
+	 * a valid vlan id.  If the vlan id matches the pvid of current port
+	 * send untagged; otherwise, send taged.
+	 */
+	br_vlan_get_tag(skb, &vid);
+	if (vid == br_get_pvid(pv))
+		skb = br_vlan_untag(skb);
+	else {
+		/* Egress policy says "send tagged".  If output device
+		 * is the  bridge, we need to add the VLAN header
+		 * ourselves since we'll be going through the RX path.
+		 * Sending to ports puts the frame on the TX path and
+		 * we let dev_hard_start_xmit() add the header.
+		 */
+		if (skb->protocol != htons(ETH_P_8021Q) &&
+		    pv->port_idx == 0) {
+			/* vlan_put_tag expects skb->data to point to
+			 * mac header.
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
 /* Called under RCU */
 bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
-			struct sk_buff *skb)
+			struct sk_buff *skb, u16 *vid)
 {
-	u16 vid;
-
 	/* If VLAN filtering is disabled on the bridge, all packets are
 	 * permitted.
 	 */
@@ -145,8 +207,25 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	if (!v)
 		return false;
 
-	vid = br_vlan_get_tag(skb);
-	if (test_bit(vid, v->vlan_bitmap))
+	if (br_vlan_get_tag(skb, vid)) {
+		u16 pvid = br_get_pvid(v);
+
+		/* Frame did not have a tag.  See if pvid is set
+		 * on this port.  That tells us which vlan untagged
+		 * traffic belongs to.
+		 */
+		if (pvid == BR_INVALID_VID)
+			return false;
+
+		/* PVID is set on this port.  Any untagged ingress
+		 * frame is considered to belong to this vlan.
+		 */
+		__vlan_hwaccel_put_tag(skb, pvid);
+		return true;
+	}
+
+	/* Frame had a valid vlan tag.  See if vlan is allowed */
+	if (test_bit(*vid, v->vlan_bitmap))
 		return true;
 
 	return false;
@@ -157,7 +236,7 @@ bool br_allowed_egress(struct net_bridge *br,
 		       const struct net_port_vlans *v,
 		       const struct sk_buff *skb)
 {
-	u16 vid;
+	u16 vid = 0;
 
 	if (!br->vlan_enabled)
 		return true;
@@ -165,7 +244,7 @@ bool br_allowed_egress(struct net_bridge *br,
 	if (!v)
 		return false;
 
-	vid = br_vlan_get_tag(skb);
+	br_vlan_get_tag(skb, &vid);
 	if (test_bit(vid, v->vlan_bitmap))
 		return true;
 
-- 
1.7.7.6
