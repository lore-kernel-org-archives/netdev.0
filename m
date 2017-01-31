From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 5/5] bridge: vlan dst_metadata hooks in ingress and egress paths
Date: Mon, 30 Jan 2017 21:57:15 -0800
Message-ID: <1485842235-32343-6-git-send-email-roopa@cumulusnetworks.com>
References: <1485842235-32343-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34630 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbdAaF6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 00:58:49 -0500
Received: by mail-pf0-f181.google.com with SMTP id e4so99752593pfg.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 21:57:33 -0800 (PST)
In-Reply-To: <1485842235-32343-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

- ingress hook:
    - if port is a tunnel port, use tunnel info in
      attached dst_metadata to map it to a local vlan
- egress hook:
    - if port is a tunnel port, use tunnel info attached to
      vlan to set dst_metadata on the skb

CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_forward.c        |    2 +-
 net/bridge/br_input.c          |    8 ++++++-
 net/bridge/br_private.h        |    2 ++
 net/bridge/br_private_tunnel.h |    5 +++++
 net/bridge/br_vlan.c           |    7 ++++++
 net/bridge/br_vlan_tunnel.c    |   47 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 69 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index a0f9d00..e5d4821 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -80,7 +80,7 @@ static void __br_forward(const struct net_bridge_port *to,
 	int br_hook;
 
 	vg = nbp_vlan_group_rcu(to);
-	skb = br_handle_vlan(to->br, vg, skb);
+	skb = br_handle_vlan(to->br, to, vg, skb);
 	if (!skb)
 		return;
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 855b72f..fba38d8 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -21,6 +21,7 @@
 #include <linux/export.h>
 #include <linux/rculist.h>
 #include "br_private.h"
+#include "br_private_tunnel.h"
 
 /* Hook for brouter */
 br_should_route_hook_t __rcu *br_should_route_hook __read_mostly;
@@ -57,7 +58,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 
 	indev = skb->dev;
 	skb->dev = brdev;
-	skb = br_handle_vlan(br, vg, skb);
+	skb = br_handle_vlan(br, NULL, vg, skb);
 	if (!skb)
 		return NET_RX_DROP;
 	/* update the multicast stats if the packet is IGMP/MLD */
@@ -261,6 +262,11 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		return RX_HANDLER_CONSUMED;
 
 	p = br_port_get_rcu(skb->dev);
+	if (p->flags & BR_VLAN_TUNNEL) {
+		if (br_handle_ingress_vlan_tunnel(skb, p,
+						  nbp_vlan_group_rcu(p)))
+			goto drop;
+	}
 
 	if (unlikely(is_link_local_ether_addr(dest))) {
 		u16 fwd_mask = p->br->group_fwd_mask_required;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 61de90f..40177df 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -775,6 +775,7 @@ bool br_allowed_egress(struct net_bridge_vlan_group *vg,
 		       const struct sk_buff *skb);
 bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid);
 struct sk_buff *br_handle_vlan(struct net_bridge *br,
+			       const struct net_bridge_port *port,
 			       struct net_bridge_vlan_group *vg,
 			       struct sk_buff *skb);
 int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
@@ -874,6 +875,7 @@ static inline bool br_should_learn(struct net_bridge_port *p,
 }
 
 static inline struct sk_buff *br_handle_vlan(struct net_bridge *br,
+					     const struct net_bridge_port *port,
 					     struct net_bridge_vlan_group *vg,
 					     struct sk_buff *skb)
 {
diff --git a/net/bridge/br_private_tunnel.h b/net/bridge/br_private_tunnel.h
index 638d544..94c11d8 100644
--- a/net/bridge/br_private_tunnel.h
+++ b/net/bridge/br_private_tunnel.h
@@ -39,4 +39,9 @@ int br_fill_vlan_tunnel_info(struct sk_buff *skb,
 void nbp_vlan_tunnel_info_flush(struct net_bridge_port *port);
 void vlan_tunnel_info_del(struct net_bridge_vlan_group *vg,
 			  struct net_bridge_vlan *vlan);
+int br_handle_ingress_vlan_tunnel(struct sk_buff *skb,
+				  struct net_bridge_port *p,
+				  struct net_bridge_vlan_group *vg);
+int br_handle_egress_vlan_tunnel(struct sk_buff *skb,
+				 struct net_bridge_vlan *vlan);
 #endif
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 64002e3..62e68c0 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -341,6 +341,7 @@ static void __vlan_flush(struct net_bridge_vlan_group *vg)
 }
 
 struct sk_buff *br_handle_vlan(struct net_bridge *br,
+			       const struct net_bridge_port *p,
 			       struct net_bridge_vlan_group *vg,
 			       struct sk_buff *skb)
 {
@@ -381,6 +382,12 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 
 	if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
 		skb->vlan_tci = 0;
+
+	if (p && (p->flags & BR_VLAN_TUNNEL) &&
+	    br_handle_egress_vlan_tunnel(skb, v)) {
+		kfree_skb(skb);
+		return NULL;
+	}
 out:
 	return skb;
 }
diff --git a/net/bridge/br_vlan_tunnel.c b/net/bridge/br_vlan_tunnel.c
index 7b4525e..b2b79a0 100644
--- a/net/bridge/br_vlan_tunnel.c
+++ b/net/bridge/br_vlan_tunnel.c
@@ -154,3 +154,50 @@ void vlan_tunnel_deinit(struct net_bridge_vlan_group *vg)
 {
 	rhashtable_destroy(&vg->tunnel_hash);
 }
+
+int br_handle_ingress_vlan_tunnel(struct sk_buff *skb,
+				  struct net_bridge_port *p,
+				  struct net_bridge_vlan_group *vg)
+{
+	struct ip_tunnel_info *tinfo = skb_tunnel_info(skb);
+	struct net_bridge_vlan *vlan;
+
+	if (!vg || !tinfo)
+		return 0;
+
+	/* if already tagged, ignore */
+	if (skb_vlan_tagged(skb))
+		return 0;
+
+	/* lookup vid, given tunnel id */
+	vlan = br_vlan_tunnel_lookup(&vg->tunnel_hash, tinfo->key.tun_id);
+	if (!vlan)
+		return 0;
+
+	skb_dst_drop(skb);
+
+	__vlan_hwaccel_put_tag(skb, p->br->vlan_proto, vlan->vid);
+
+	return 0;
+}
+
+int br_handle_egress_vlan_tunnel(struct sk_buff *skb,
+				 struct net_bridge_vlan *vlan)
+{
+	int err;
+
+	if (!vlan || !vlan->tinfo.tunnel_id)
+		return 0;
+
+	if (unlikely(!skb_vlan_tag_present(skb)))
+		return 0;
+
+	skb_dst_drop(skb);
+	err = skb_vlan_pop(skb);
+	if (err)
+		return err;
+
+	skb_dst_set(skb, dst_clone(&vlan->tinfo.tunnel_dst->dst));
+
+	return 0;
+}
-- 
1.7.10.4
