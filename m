From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/2] vlan: Add GRO interfaces
Date: Tue, 6 Jan 2009 18:12:16 +1100
Message-ID: <20090106071216.GB27281@gondor.apana.org.au>
References: <20090102054714.GA23106@gondor.apana.org.au> <20090102054921.GA23174@gondor.apana.org.au> <20090104.225727.236263263.davem@davemloft.net> <20090105094730.GA15756@gondor.apana.org.au> <20090105095131.GA15851@gondor.apana.org.au> <20090106071142.GA27281@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38868 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751504AbZAFHMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 02:12:18 -0500
Content-Disposition: inline
In-Reply-To: <20090106071142.GA27281@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: Add GRO interfaces

This patch adds GRO interfaces for hardware-assisted VLAN reception.
With this in place we're now at parity with LRO as far as the
interface is concerned.  That is, you can now take any LRO driver
and convert it over to GRO.

As the CB memory clashes with GRO's use of CB, I've removed it
entirely by storing dev in skb->dev.  This is OK because VLAN
gets called first thing in netif_receive_skb and skb->dev is
not used in between us calling netif_rx and netif_receive_skb
getting called.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a5cb0c3..f8ff918 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -115,6 +115,11 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     u16 vlan_tci, int polling);
 extern int vlan_hwaccel_do_receive(struct sk_buff *skb);
+extern int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+			    unsigned int vlan_tci, struct sk_buff *skb);
+extern int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+			  unsigned int vlan_tci,
+			  struct napi_gro_fraginfo *info);
 
 #else
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
@@ -140,6 +145,20 @@ static inline int vlan_hwaccel_do_receive(struct sk_buff *skb)
 {
 	return 0;
 }
+
+static inline int vlan_gro_receive(struct napi_struct *napi,
+				   struct vlan_group *grp,
+				   unsigned int vlan_tci, struct sk_buff *skb)
+{
+	return NET_RX_DROP;
+}
+
+static inline int vlan_gro_frags(struct napi_struct *napi,
+				 struct vlan_group *grp, unsigned int vlan_tci,
+				 struct napi_gro_fraginfo *info)
+{
+	return NET_RX_DROP;
+}
 #endif
 
 /**
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index dd86a1d..6c13239 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -3,46 +3,35 @@
 #include <linux/if_vlan.h>
 #include "vlan.h"
 
-struct vlan_hwaccel_cb {
-	struct net_device	*dev;
-};
-
-static inline struct vlan_hwaccel_cb *vlan_hwaccel_cb(struct sk_buff *skb)
-{
-	return (struct vlan_hwaccel_cb *)skb->cb;
-}
-
 /* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
 int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		      u16 vlan_tci, int polling)
 {
-	struct vlan_hwaccel_cb *cb = vlan_hwaccel_cb(skb);
-
-	if (skb_bond_should_drop(skb)) {
-		dev_kfree_skb_any(skb);
-		return NET_RX_DROP;
-	}
+	if (skb_bond_should_drop(skb))
+		goto drop;
 
 	skb->vlan_tci = vlan_tci;
-	cb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+
+	if (!skb->dev)
+		goto drop;
 
 	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
+
+drop:
+	dev_kfree_skb_any(skb);
+	return NET_RX_DROP;
 }
 EXPORT_SYMBOL(__vlan_hwaccel_rx);
 
 int vlan_hwaccel_do_receive(struct sk_buff *skb)
 {
-	struct vlan_hwaccel_cb *cb = vlan_hwaccel_cb(skb);
-	struct net_device *dev = cb->dev;
+	struct net_device *dev = skb->dev;
 	struct net_device_stats *stats;
 
+	skb->dev = vlan_dev_info(dev)->real_dev;
 	netif_nit_deliver(skb);
 
-	if (dev == NULL) {
-		kfree_skb(skb);
-		return -1;
-	}
-
 	skb->dev = dev;
 	skb->priority = vlan_get_ingress_priority(dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
@@ -80,3 +69,79 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 	return vlan_dev_info(dev)->vlan_id;
 }
 EXPORT_SYMBOL_GPL(vlan_dev_vlan_id);
+
+static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
+			   unsigned int vlan_tci, struct sk_buff *skb)
+{
+	struct sk_buff *p;
+
+	if (skb_bond_should_drop(skb))
+		goto drop;
+
+	skb->vlan_tci = vlan_tci;
+	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+
+	if (!skb->dev)
+		goto drop;
+
+	for (p = napi->gro_list; p; p = p->next) {
+		NAPI_GRO_CB(p)->same_flow = p->dev == skb->dev;
+		NAPI_GRO_CB(p)->flush = 0;
+	}
+
+	return dev_gro_receive(napi, skb);
+
+drop:
+	return 2;
+}
+
+int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+		     unsigned int vlan_tci, struct sk_buff *skb)
+{
+	int err = NET_RX_SUCCESS;
+
+	switch (vlan_gro_common(napi, grp, vlan_tci, skb)) {
+	case -1:
+		return netif_receive_skb(skb);
+
+	case 2:
+		err = NET_RX_DROP;
+		/* fall through */
+
+	case 1:
+		kfree_skb(skb);
+		break;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(vlan_gro_receive);
+
+int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+		   unsigned int vlan_tci, struct napi_gro_fraginfo *info)
+{
+	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
+	int err = NET_RX_DROP;
+
+	if (!skb)
+		goto out;
+
+	err = NET_RX_SUCCESS;
+
+	switch (vlan_gro_common(napi, grp, vlan_tci, skb)) {
+	case -1:
+		return netif_receive_skb(skb);
+
+	case 2:
+		err = NET_RX_DROP;
+		/* fall through */
+
+	case 1:
+		napi_reuse_skb(napi, skb);
+		break;
+	}
+
+out:
+	return err;
+}
+EXPORT_SYMBOL(vlan_gro_frags);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
