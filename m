From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 5/9] vlan: introduce *vlan_hwaccel_push_inside helpers
Date: Wed, 19 Nov 2014 14:04:59 +0100
Message-ID: <1416402303-25341-6-git-send-email-jiri@resnulli.us>
References: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:50313 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754913AbaKSNFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 08:05:11 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so774582wgh.23
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 05:05:10 -0800 (PST)
In-Reply-To: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use them to push skb->vlan_tci into the payload and avoid code
duplication.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---

v3->v4:
- fixed error path in ovs datapath

 drivers/net/vxlan.c         | 22 ++++++----------------
 include/linux/if_vlan.h     | 34 ++++++++++++++++++++++++++++++++++
 net/core/dev.c              |  8 ++------
 net/core/netpoll.c          |  4 +---
 net/ipv4/geneve.c           | 11 +++--------
 net/openvswitch/datapath.c  |  4 +---
 net/openvswitch/vport-gre.c | 12 ++++--------
 7 files changed, 51 insertions(+), 44 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bb8fbab..64d45fa 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1599,14 +1599,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	if (unlikely(err))
 		return err;
 
-	if (vlan_tx_tag_present(skb)) {
-		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
-						vlan_tx_tag_get(skb));
-		if (WARN_ON(!skb))
-			return -ENOMEM;
-
-		skb->vlan_tci = 0;
-	}
+	skb = vlan_hwaccel_push_inside(skb);
+	if (WARN_ON(!skb))
+		return -ENOMEM;
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
@@ -1643,14 +1638,9 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	if (unlikely(err))
 		return err;
 
-	if (vlan_tx_tag_present(skb)) {
-		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
-						vlan_tx_tag_get(skb));
-		if (WARN_ON(!skb))
-			return -ENOMEM;
-
-		skb->vlan_tci = 0;
-	}
+	skb = vlan_hwaccel_push_inside(skb);
+	if (WARN_ON(!skb))
+		return -ENOMEM;
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 46e4a15..291e670 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -341,6 +341,40 @@ static inline struct sk_buff *vlan_insert_tag_set_proto(struct sk_buff *skb,
 	return skb;
 }
 
+/*
+ * __vlan_hwaccel_push_inside - pushes vlan tag to the payload
+ * @skb: skbuff to tag
+ *
+ * Pushes the VLAN tag from @skb->vlan_tci inside to the payload.
+ *
+ * Following the skb_unshare() example, in case of error, the calling function
+ * doesn't have to worry about freeing the original skb.
+ */
+static inline struct sk_buff *__vlan_hwaccel_push_inside(struct sk_buff *skb)
+{
+	skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
+					vlan_tx_tag_get(skb));
+	if (likely(skb))
+		skb->vlan_tci = 0;
+	return skb;
+}
+/*
+ * vlan_hwaccel_push_inside - pushes vlan tag to the payload
+ * @skb: skbuff to tag
+ *
+ * Checks is tag is present in @skb->vlan_tci and if it is, it pushes the
+ * VLAN tag from @skb->vlan_tci inside to the payload.
+ *
+ * Following the skb_unshare() example, in case of error, the calling function
+ * doesn't have to worry about freeing the original skb.
+ */
+static inline struct sk_buff *vlan_hwaccel_push_inside(struct sk_buff *skb)
+{
+	if (vlan_tx_tag_present(skb))
+		skb = __vlan_hwaccel_push_inside(skb);
+	return skb;
+}
+
 /**
  * __vlan_hwaccel_put_tag - hardware accelerated VLAN inserting
  * @skb: skbuff to tag
diff --git a/net/core/dev.c b/net/core/dev.c
index 3611e60..ac48362 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2644,12 +2644,8 @@ static struct sk_buff *validate_xmit_vlan(struct sk_buff *skb,
 					  netdev_features_t features)
 {
 	if (vlan_tx_tag_present(skb) &&
-	    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
-		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
-						vlan_tx_tag_get(skb));
-		if (skb)
-			skb->vlan_tci = 0;
-	}
+	    !vlan_hw_offload_capable(features, skb->vlan_proto))
+		skb = __vlan_hwaccel_push_inside(skb);
 	return skb;
 }
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 65d3723..e0ad5d1 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -79,8 +79,7 @@ static int netpoll_start_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	if (vlan_tx_tag_present(skb) &&
 	    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
-		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
-						vlan_tx_tag_get(skb));
+		skb = __vlan_hwaccel_push_inside(skb);
 		if (unlikely(!skb)) {
 			/* This is actually a packet drop, but we
 			 * don't want the code that calls this
@@ -88,7 +87,6 @@ static int netpoll_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			 */
 			goto out;
 		}
-		skb->vlan_tci = 0;
 	}
 
 	status = netdev_start_xmit(skb, dev, txq, false);
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index fd430a6..a457232 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -131,14 +131,9 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 	if (unlikely(err))
 		return err;
 
-	if (vlan_tx_tag_present(skb)) {
-		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
-						vlan_tx_tag_get(skb));
-		if (unlikely(!skb)
-			return -ENOMEM;
-
-		skb->vlan_tci = 0;
-	}
+	skb = vlan_hwaccel_push_inside(skb);
+	if (unlikely(!skb))
+		return -ENOMEM;
 
 	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
 	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index c63e60e..f37ca3e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -425,12 +425,10 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		if (!nskb)
 			return -ENOMEM;
 
-		nskb = vlan_insert_tag_set_proto(nskb, nskb->vlan_proto,
-						 vlan_tx_tag_get(nskb));
+		nskb = __vlan_hwaccel_push_inside(nskb);
 		if (!nskb)
 			return -ENOMEM;
 
-		nskb->vlan_tci = 0;
 		skb = nskb;
 	}
 
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 777cd8c..6b69df5 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -175,14 +175,10 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 			goto err_free_rt;
 	}
 
-	if (vlan_tx_tag_present(skb)) {
-		skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
-						vlan_tx_tag_get(skb));
-		if (unlikely(!skb) {
-			err = -ENOMEM;
-			goto err_free_rt;
-		}
-		skb->vlan_tci = 0;
+	skb = vlan_hwaccel_push_inside(skb);
+	if (unlikely(!skb)) {
+		err = -ENOMEM;
+		goto err_free_rt;
 	}
 
 	/* Push Tunnel header. */
-- 
1.9.3
