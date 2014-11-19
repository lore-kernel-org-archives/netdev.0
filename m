From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 4/9] vlan: rename __vlan_put_tag to vlan_insert_tag_set_proto
Date: Wed, 19 Nov 2014 14:04:58 +0100
Message-ID: <1416402303-25341-5-git-send-email-jiri@resnulli.us>
References: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:52477 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910AbaKSNFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 08:05:10 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so774559wgh.23
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 05:05:09 -0800 (PST)
In-Reply-To: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Name fits better. Plus there's going to be introduced
__vlan_insert_tag later on.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/bonding/bond_main.c             |  4 ++--
 drivers/net/ethernet/emulex/benet/be_main.c |  6 ++++--
 drivers/net/vxlan.c                         | 12 ++++++------
 include/linux/if_vlan.h                     |  8 +++++---
 net/bridge/br_vlan.c                        |  4 ++--
 net/core/dev.c                              |  4 ++--
 net/core/netpoll.c                          |  4 ++--
 net/ipv4/geneve.c                           | 11 +++++------
 net/openvswitch/actions.c                   |  4 +++-
 net/openvswitch/datapath.c                  |  3 ++-
 net/openvswitch/vport-gre.c                 |  6 +++---
 11 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e26c682..c1d7da4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2146,8 +2146,8 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 
 		netdev_dbg(slave_dev, "inner tag: proto %X vid %X\n",
 			   ntohs(outer_tag->vlan_proto), tags->vlan_id);
-		skb = __vlan_put_tag(skb, tags->vlan_proto,
-				     tags->vlan_id);
+		skb = vlan_insert_tag_set_proto(skb, tags->vlan_proto,
+						tags->vlan_id);
 		if (!skb) {
 			net_err_ratelimited("failed to insert inner VLAN tag\n");
 			return;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 54160cc..d02fbc7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -887,7 +887,8 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 	}
 
 	if (vlan_tag) {
-		skb = __vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
+		skb = vlan_insert_tag_set_proto(skb, htons(ETH_P_8021Q),
+						vlan_tag);
 		if (unlikely(!skb))
 			return skb;
 		skb->vlan_tci = 0;
@@ -896,7 +897,8 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 	/* Insert the outer VLAN, if any */
 	if (adapter->qnq_vid) {
 		vlan_tag = adapter->qnq_vid;
-		skb = __vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
+		skb = vlan_insert_tag_set_proto(skb, htons(ETH_P_8021Q),
+						vlan_tag);
 		if (unlikely(!skb))
 			return skb;
 		if (skip_hw_vlan)
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 23b1e8c..bb8fbab 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1600,9 +1600,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 		return err;
 
 	if (vlan_tx_tag_present(skb)) {
-		if (WARN_ON(!__vlan_put_tag(skb,
-					    skb->vlan_proto,
-					    vlan_tx_tag_get(skb))))
+		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
+						vlan_tx_tag_get(skb));
+		if (WARN_ON(!skb))
 			return -ENOMEM;
 
 		skb->vlan_tci = 0;
@@ -1644,9 +1644,9 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		return err;
 
 	if (vlan_tx_tag_present(skb)) {
-		if (WARN_ON(!__vlan_put_tag(skb,
-					    skb->vlan_proto,
-					    vlan_tx_tag_get(skb))))
+		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
+						vlan_tx_tag_get(skb));
+		if (WARN_ON(!skb))
 			return -ENOMEM;
 
 		skb->vlan_tci = 0;
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 75b70a5..46e4a15 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -320,8 +320,9 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
 }
 
 /**
- * __vlan_put_tag - regular VLAN tag inserting
+ * vlan_insert_tag_set_proto - regular VLAN tag inserting
  * @skb: skbuff to tag
+ * @vlan_proto: VLAN encapsulation protocol
  * @vlan_tci: VLAN TCI to insert
  *
  * Inserts the VLAN tag into @skb as part of the payload
@@ -330,8 +331,9 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
  * Following the skb_unshare() example, in case of error, the calling function
  * doesn't have to worry about freeing the original skb.
  */
-static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb,
-					     __be16 vlan_proto, u16 vlan_tci)
+static inline struct sk_buff *vlan_insert_tag_set_proto(struct sk_buff *skb,
+							__be16 vlan_proto,
+							u16 vlan_tci)
 {
 	skb = vlan_insert_tag(skb, vlan_proto, vlan_tci);
 	if (skb)
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 150048f..97b8ddf 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -199,8 +199,8 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 		if (skb->vlan_proto != proto) {
 			/* Protocol-mismatch, empty out vlan_tci for new tag */
 			skb_push(skb, ETH_HLEN);
-			skb = __vlan_put_tag(skb, skb->vlan_proto,
-					     vlan_tx_tag_get(skb));
+			skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
+							vlan_tx_tag_get(skb));
 			if (unlikely(!skb))
 				return false;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 1ab168e..3611e60 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2645,8 +2645,8 @@ static struct sk_buff *validate_xmit_vlan(struct sk_buff *skb,
 {
 	if (vlan_tx_tag_present(skb) &&
 	    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
-		skb = __vlan_put_tag(skb, skb->vlan_proto,
-				     vlan_tx_tag_get(skb));
+		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
+						vlan_tx_tag_get(skb));
 		if (skb)
 			skb->vlan_tci = 0;
 	}
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index e6645b4..65d3723 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -79,8 +79,8 @@ static int netpoll_start_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	if (vlan_tx_tag_present(skb) &&
 	    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
-		skb = __vlan_put_tag(skb, skb->vlan_proto,
-				     vlan_tx_tag_get(skb));
+		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
+						vlan_tx_tag_get(skb));
 		if (unlikely(!skb)) {
 			/* This is actually a packet drop, but we
 			 * don't want the code that calls this
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 31802af..fd430a6 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -132,12 +132,11 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 		return err;
 
 	if (vlan_tx_tag_present(skb)) {
-		if (unlikely(!__vlan_put_tag(skb,
-					     skb->vlan_proto,
-					     vlan_tx_tag_get(skb)))) {
-			err = -ENOMEM;
-			return err;
-		}
+		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
+						vlan_tx_tag_get(skb));
+		if (unlikely(!skb)
+			return -ENOMEM;
+
 		skb->vlan_tci = 0;
 	}
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 749a301..426b913 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -287,7 +287,9 @@ static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
 		/* push down current VLAN tag */
 		current_tag = vlan_tx_tag_get(skb);
 
-		if (!__vlan_put_tag(skb, skb->vlan_proto, current_tag))
+		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
+						current_tag);
+		if (!skb)
 			return -ENOMEM;
 		/* Update mac_len for subsequent MPLS actions */
 		skb->mac_len += VLAN_HLEN;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ab141d4..c63e60e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -425,7 +425,8 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		if (!nskb)
 			return -ENOMEM;
 
-		nskb = __vlan_put_tag(nskb, nskb->vlan_proto, vlan_tx_tag_get(nskb));
+		nskb = vlan_insert_tag_set_proto(nskb, nskb->vlan_proto,
+						 vlan_tx_tag_get(nskb));
 		if (!nskb)
 			return -ENOMEM;
 
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 8e61a5c..777cd8c 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -176,9 +176,9 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	}
 
 	if (vlan_tx_tag_present(skb)) {
-		if (unlikely(!__vlan_put_tag(skb,
-					     skb->vlan_proto,
-					     vlan_tx_tag_get(skb)))) {
+		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
+						vlan_tx_tag_get(skb));
+		if (unlikely(!skb) {
 			err = -ENOMEM;
 			goto err_free_rt;
 		}
-- 
1.9.3
