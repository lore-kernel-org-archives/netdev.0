From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH RFC 2/3] bridge: Prepare for 802.1ad vlan filtering support
Date: Mon, 10 Mar 2014 17:11:05 +0900
Message-ID: <1394439067-10477-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:57868 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbaCJILZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 04:11:25 -0400
In-Reply-To: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables a bridge to have vlan protocol informantion and allows vlan
filtering code to take vlan protocols into account.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_device.c  |  1 +
 net/bridge/br_input.c   |  2 +-
 net/bridge/br_private.h | 24 +++++++++++++++++++---
 net/bridge/br_vlan.c    | 53 ++++++++++++++++++++++++++++++++-----------------
 4 files changed, 58 insertions(+), 22 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index b063050..6cf2fbc 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -381,4 +381,5 @@ void br_dev_setup(struct net_device *dev)
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
 	br_multicast_init(br);
+	br_vlan_init(br);
 }
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 28d5446..8b69da6 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -146,7 +146,7 @@ static int br_handle_local_finish(struct sk_buff *skb)
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	u16 vid = 0;
 
-	br_vlan_get_tag(skb, &vid);
+	br_vlan_get_tag(skb, br_get_vlan_proto(p->br), &vid);
 	if (p->flags & BR_LEARNING)
 		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid, false);
 	return 0;	 /* process further */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index e1ca1dc..500cf0e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -292,6 +292,7 @@ struct net_bridge
 	struct kobject			*ifobj;
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	u8				vlan_enabled;
+	__be16				vlan_proto;
 	struct net_port_vlans __rcu	*vlan_info;
 #endif
 };
@@ -589,6 +590,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid);
 void br_vlan_flush(struct net_bridge *br);
 bool br_vlan_find(struct net_bridge *br, u16 vid);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
+void br_vlan_init(struct net_bridge *br);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
@@ -609,11 +611,12 @@ static inline struct net_port_vlans *nbp_get_vlan_info(
 /* Since bridge now depends on 8021Q module, but the time bridge sees the
  * skb, the vlan tag will always be present if the frame was tagged.
  */
-static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
+static inline int br_vlan_get_tag(const struct sk_buff *skb, __be16 proto,
+				  u16 *vid)
 {
 	int err = 0;
 
-	if (vlan_tx_tag_present(skb))
+	if (vlan_tx_tag_present(skb) && skb->vlan_proto == proto)
 		*vid = vlan_tx_tag_get(skb) & VLAN_VID_MASK;
 	else {
 		*vid = 0;
@@ -632,6 +635,11 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
 	return v->pvid ?: VLAN_N_VID;
 }
 
+static inline __be16 br_get_vlan_proto(const struct net_bridge *br)
+{
+	return br->vlan_proto;
+}
+
 #else
 static inline bool br_allowed_ingress(struct net_bridge *br,
 				      struct net_port_vlans *v,
@@ -674,6 +682,10 @@ static inline bool br_vlan_find(struct net_bridge *br, u16 vid)
 	return false;
 }
 
+static inline void br_vlan_init(struct net_bridge *br)
+{
+}
+
 static inline int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 {
 	return -EOPNOTSUPP;
@@ -704,7 +716,8 @@ static inline bool nbp_vlan_find(struct net_bridge_port *port, u16 vid)
 	return false;
 }
 
-static inline u16 br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
+static inline u16 br_vlan_get_tag(const struct sk_buff *skb, __be16 proto,
+				  u16 *tag)
 {
 	return 0;
 }
@@ -712,6 +725,11 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
 {
 	return VLAN_N_VID;	/* Returns invalid vid */
 }
+
+static inline __be16 br_get_vlan_proto(const struct net_bridge *br)
+{
+	return 0;
+}
 #endif
 
 /* br_netfilter.c */
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index cda93e2..f05ef6a 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -32,7 +32,7 @@ static void __vlan_add_flags(struct net_port_vlans *v, u16 vid, u16 flags)
 		set_bit(vid, v->untagged_bitmap);
 }
 
-static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
+static int __vlan_add(struct net_port_vlans *v, __be16 proto, u16 vid, u16 flags)
 {
 	struct net_bridge_port *p = NULL;
 	struct net_bridge *br;
@@ -60,7 +60,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 		 * that ever changes this code will allow tagged
 		 * traffic to enter the bridge.
 		 */
-		err = vlan_vid_add(dev, htons(ETH_P_8021Q), vid);
+		err = vlan_vid_add(dev, proto, vid);
 		if (err)
 			return err;
 	}
@@ -80,11 +80,11 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 
 out_filt:
 	if (p)
-		vlan_vid_del(dev, htons(ETH_P_8021Q), vid);
+		vlan_vid_del(dev, proto, vid);
 	return err;
 }
 
-static int __vlan_del(struct net_port_vlans *v, u16 vid)
+static int __vlan_del(struct net_port_vlans *v, __be16 proto, u16 vid)
 {
 	if (!test_bit(vid, v->vlan_bitmap))
 		return -EINVAL;
@@ -93,7 +93,7 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 	clear_bit(vid, v->untagged_bitmap);
 
 	if (v->port_idx)
-		vlan_vid_del(v->parent.port->dev, htons(ETH_P_8021Q), vid);
+		vlan_vid_del(v->parent.port->dev, proto, vid);
 
 	clear_bit(vid, v->vlan_bitmap);
 	v->num_vlans--;
@@ -132,7 +132,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 	 * a valid vlan id.  If the vlan id is set in the untagged bitmap,
 	 * send untagged; otherwise, send tagged.
 	 */
-	br_vlan_get_tag(skb, &vid);
+	br_vlan_get_tag(skb, br_get_vlan_proto(br), &vid);
 	if (test_bit(vid, pv->untagged_bitmap))
 		skb->vlan_tci = 0;
 
@@ -145,6 +145,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 			struct sk_buff *skb, u16 *vid)
 {
 	int err;
+	__be16 proto = br_get_vlan_proto(br);
 
 	/* If VLAN filtering is disabled on the bridge, all packets are
 	 * permitted.
@@ -158,7 +159,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	if (!v)
 		return false;
 
-	err = br_vlan_get_tag(skb, vid);
+	err = br_vlan_get_tag(skb, proto, vid);
 	if (!*vid) {
 		u16 pvid = br_get_pvid(v);
 
@@ -173,16 +174,27 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 		 * ingress frame is considered to belong to this vlan.
 		 */
 		*vid = pvid;
-		if (likely(err))
+		if (likely(err)) {
 			/* Untagged Frame. */
-			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), pvid);
-		else
+			if (vlan_tx_tag_present(skb)) {
+				/* skb->vlan_proto was different from br->vlan_proto */
+				skb_push(skb, ETH_HLEN);
+				skb = __vlan_put_tag(skb, skb->vlan_proto,
+						     vlan_tx_tag_get(skb));
+				if (unlikely(!skb))
+					return false;
+				skb_pull(skb, ETH_HLEN);
+				skb_reset_mac_len(skb);
+			}
+			__vlan_hwaccel_put_tag(skb, proto, pvid);
+		} else {
 			/* Priority-tagged Frame.
 			 * At this point, We know that skb->vlan_tci had
 			 * VLAN_TAG_PRESENT bit and its VID field was 0x000.
 			 * We update only VID field and preserve PCP field.
 			 */
 			skb->vlan_tci |= pvid;
+		}
 
 		return true;
 	}
@@ -207,7 +219,7 @@ bool br_allowed_egress(struct net_bridge *br,
 	if (!v)
 		return false;
 
-	br_vlan_get_tag(skb, &vid);
+	br_vlan_get_tag(skb, br_get_vlan_proto(br), &vid);
 	if (test_bit(vid, v->vlan_bitmap))
 		return true;
 
@@ -226,7 +238,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 
 	pv = rtnl_dereference(br->vlan_info);
 	if (pv)
-		return __vlan_add(pv, vid, flags);
+		return __vlan_add(pv, br_get_vlan_proto(br), vid, flags);
 
 	/* Create port vlan infomration
 	 */
@@ -235,7 +247,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 		return -ENOMEM;
 
 	pv->parent.br = br;
-	err = __vlan_add(pv, vid, flags);
+	err = __vlan_add(pv, br_get_vlan_proto(br), vid, flags);
 	if (err)
 		goto out;
 
@@ -261,7 +273,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 
 	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
 
-	__vlan_del(pv, vid);
+	__vlan_del(pv, br_get_vlan_proto(br), vid);
 	return 0;
 }
 
@@ -311,6 +323,11 @@ unlock:
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
@@ -323,7 +340,7 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 
 	pv = rtnl_dereference(port->vlan_info);
 	if (pv)
-		return __vlan_add(pv, vid, flags);
+		return __vlan_add(pv, br_get_vlan_proto(port->br), vid, flags);
 
 	/* Create port vlan infomration
 	 */
@@ -335,7 +352,7 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 
 	pv->port_idx = port->port_no;
 	pv->parent.port = port;
-	err = __vlan_add(pv, vid, flags);
+	err = __vlan_add(pv, br_get_vlan_proto(port->br), vid, flags);
 	if (err)
 		goto clean_up;
 
@@ -362,7 +379,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 
 	br_fdb_find_delete_local(port->br, port, port->dev->dev_addr, vid);
 
-	return __vlan_del(pv, vid);
+	return __vlan_del(pv, br_get_vlan_proto(port->br), vid);
 }
 
 void nbp_vlan_flush(struct net_bridge_port *port)
@@ -377,7 +394,7 @@ void nbp_vlan_flush(struct net_bridge_port *port)
 		return;
 
 	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
-		vlan_vid_del(port->dev, htons(ETH_P_8021Q), vid);
+		vlan_vid_del(port->dev, br_get_vlan_proto(port->br), vid);
 
 	__vlan_flush(pv);
 }
-- 
1.8.1.2
