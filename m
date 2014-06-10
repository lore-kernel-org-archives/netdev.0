From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net-next 2/4] bridge: Prepare for 802.1ad vlan filtering support
Date: Tue, 10 Jun 2014 20:59:23 +0900
Message-ID: <1402401565-15423-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1402401565-15423-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:47066 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaFJMAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 08:00:24 -0400
In-Reply-To: <1402401565-15423-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables a bridge to have vlan protocol informantion and allows vlan
tag manipulation (retrieve, insert and remove tags) according to the vlan
protocol.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_device.c  |  1 +
 net/bridge/br_private.h |  6 ++++++
 net/bridge/br_vlan.c    | 56 ++++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 51 insertions(+), 12 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 82a410a..1b797c4 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -388,4 +388,5 @@ void br_dev_setup(struct net_device *dev)
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
 	br_multicast_init(br);
+	br_vlan_init(br);
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index bc17210..b65fee9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -298,6 +298,7 @@ struct net_bridge
 	u32				auto_cnt;
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	u8				vlan_enabled;
+	__be16				vlan_proto;
 	struct net_port_vlans __rcu	*vlan_info;
 #endif
 };
@@ -598,6 +599,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid);
 void br_vlan_flush(struct net_bridge *br);
 bool br_vlan_find(struct net_bridge *br, u16 vid);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
+void br_vlan_init(struct net_bridge *br);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
@@ -693,6 +695,10 @@ static inline bool br_vlan_find(struct net_bridge *br, u16 vid)
 	return false;
 }
 
+static inline void br_vlan_init(struct net_bridge *br)
+{
+}
+
 static inline int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 {
 	return -EOPNOTSUPP;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index fcc9539..63bd981 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -60,7 +60,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 		 * that ever changes this code will allow tagged
 		 * traffic to enter the bridge.
 		 */
-		err = vlan_vid_add(dev, htons(ETH_P_8021Q), vid);
+		err = vlan_vid_add(dev, br->vlan_proto, vid);
 		if (err)
 			return err;
 	}
@@ -80,7 +80,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 
 out_filt:
 	if (p)
-		vlan_vid_del(dev, htons(ETH_P_8021Q), vid);
+		vlan_vid_del(dev, br->vlan_proto, vid);
 	return err;
 }
 
@@ -92,8 +92,10 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 	__vlan_delete_pvid(v, vid);
 	clear_bit(vid, v->untagged_bitmap);
 
-	if (v->port_idx)
-		vlan_vid_del(v->parent.port->dev, htons(ETH_P_8021Q), vid);
+	if (v->port_idx) {
+		struct net_bridge_port *p = v->parent.port;
+		vlan_vid_del(p->dev, p->br->vlan_proto, vid);
+	}
 
 	clear_bit(vid, v->vlan_bitmap);
 	v->num_vlans--;
@@ -158,7 +160,8 @@ out:
 bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 			struct sk_buff *skb, u16 *vid)
 {
-	int err;
+	bool tagged;
+	__be16 proto;
 
 	/* If VLAN filtering is disabled on the bridge, all packets are
 	 * permitted.
@@ -172,19 +175,41 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	if (!v)
 		goto drop;
 
+	proto = br->vlan_proto;
+
 	/* If vlan tx offload is disabled on bridge device and frame was
 	 * sent from vlan device on the bridge device, it does not have
 	 * HW accelerated vlan tag.
 	 */
 	if (unlikely(!vlan_tx_tag_present(skb) &&
-		     (skb->protocol == htons(ETH_P_8021Q) ||
-		      skb->protocol == htons(ETH_P_8021AD)))) {
+		     skb->protocol == proto)) {
 		skb = vlan_untag(skb);
 		if (unlikely(!skb))
 			return false;
 	}
 
-	err = br_vlan_get_tag(skb, vid);
+	if (!br_vlan_get_tag(skb, vid)) {
+		/* Tagged frame */
+		if (skb->vlan_proto != proto) {
+			/* Protocol-mismatch, empty out vlan_tci for new tag */
+			skb_push(skb, ETH_HLEN);
+			skb = __vlan_put_tag(skb, skb->vlan_proto,
+					     vlan_tx_tag_get(skb));
+			if (unlikely(!skb))
+				return false;
+
+			skb_pull(skb, ETH_HLEN);
+			skb_reset_mac_len(skb);
+			*vid = 0;
+			tagged = false;
+		} else {
+			tagged = true;
+		}
+	} else {
+		/* Untagged frame */
+		tagged = false;
+	}
+
 	if (!*vid) {
 		u16 pvid = br_get_pvid(v);
 
@@ -199,9 +224,9 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 		 * ingress frame is considered to belong to this vlan.
 		 */
 		*vid = pvid;
-		if (likely(err))
+		if (likely(!tagged))
 			/* Untagged Frame. */
-			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
+			__vlan_hwaccel_put_tag(skb, proto, pvid);
 		else
 			/* Priority-tagged Frame.
 			 * At this point, We know that skb->vlan_tci had
@@ -254,7 +279,9 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 	if (!v)
 		return false;
 
-	br_vlan_get_tag(skb, vid);
+	if (!br_vlan_get_tag(skb, vid) && skb->vlan_proto != br->vlan_proto)
+		*vid = 0;
+
 	if (!*vid) {
 		*vid = br_get_pvid(v);
 		if (*vid == VLAN_N_VID)
@@ -367,6 +394,11 @@ unlock:
 	return 0;
 }
 
+void br_vlan_init(struct net_bridge *br)
+{
+	br->vlan_proto = htons(ETH_P_8021Q);
+}
+
 /* Must be protected by RTNL.
  * Must be called with vid in range from 1 to 4094 inclusive.
  */
@@ -433,7 +465,7 @@ void nbp_vlan_flush(struct net_bridge_port *port)
 		return;
 
 	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
-		vlan_vid_del(port->dev, htons(ETH_P_8021Q), vid);
+		vlan_vid_del(port->dev, port->br->vlan_proto, vid);
 
 	__vlan_flush(pv);
 }
-- 
1.8.1.2
